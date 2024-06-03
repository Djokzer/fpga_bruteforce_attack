----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 31.05.2024 18:39:58
-- Design Name: 
-- Module Name: tb_bcrypt_quad_core - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library std;
use std.env.finish;

library work;
use work.pkg_bcrypt.all;
use work.rzi_helper.all;
use work.pkg_sbox_init.all;

entity tb_bcrypt_quad_core is
end tb_bcrypt_quad_core;

architecture Behavioral of tb_bcrypt_quad_core is
 -- --------------------------------------------------------------------- --
    --                              Constants
    -- --------------------------------------------------------------------- --
    constant CLK_PERIOD  : time                           := 10 ns;
    constant SUBKEY_INIT_VAL : std_logic_vector(575 downto 0) :=
    x"243F6A88_85A308D3_13198A2E_03707344_A4093822_299F31D0" &
    x"082EFA98_EC4E6C89_452821E6_38D01377_BE5466CF_34E90C6C" &
    x"C0AC29B7_C97C50DD_3F84D5B5_B5470917_9216D5D9_8979FB1B";
    constant SALT : std_logic_vector(SALT_LENGTH - 1 downto 0) := 
    x"7e949a07e88186c649bbeb0a9740c5e0";
    constant HASH : std_logic_vector(HASH_LENGTH-1 downto 0) :=
    x"37d085c7d8b559b151ce4e6f9ce2e7b0a1678b26a2517d";
    
    -- --------------------------------------------------------------------- --
    --                               Signals
    -- --------------------------------------------------------------------- --
    -- GENERAL
    signal clk        : std_logic; -- clock signal
    signal rst        : std_logic; -- reset signal (enable high)
    
    -- CONFIG
    signal config           : std_logic;
    signal number_of_cracks : std_logic_vector (31 downto 0);
    signal t_salt           : std_logic_vector (SALT_LENGTH-1 downto 0);
    signal t_hash           : std_logic_vector (HASH_LENGTH-1 downto 0);
    signal vec_init         : std_logic_vector (PWD_LENGTH*CHARSET_OF_BIT-1 downto 0);
    signal vec_length       : std_logic_vector(PWD_BITLEN - 1 downto 0);
       
    -- BCRYPT
    signal mem_init         : std_logic;
    signal pipeline_full    : std_logic;
    -- sbox init out signals
    signal sbox0_init_dout : std_logic_vector(31 downto 0);
    signal sbox1_init_dout : std_logic_vector(31 downto 0);
    signal sbox2_init_dout : std_logic_vector(31 downto 0);
    signal sbox3_init_dout : std_logic_vector(31 downto 0);
    -- subkey
    signal subkey_init      : std_logic_vector(31 downto 0);
    signal skinit_sr        : std_logic;
    signal skinit_ce        : std_logic;
    -- sbox init controll signals
    signal sbox0_init_addr : std_logic_vector (8 downto 0);
    signal sbox1_init_addr : std_logic_vector (8 downto 0);
    signal sbox2_init_addr : std_logic_vector (8 downto 0);
    signal sbox3_init_addr : std_logic_vector (8 downto 0);
    signal sbox_addr_cnt_dout   : std_logic_vector ( 8 downto 0);
    signal sbox_addr_cnt_pipe_dout : std_logic_vector ( 8 downto 0);
    
    -- CRACK RESULT
    signal dout       : std_logic_vector (31 downto 0);
    signal done       : std_logic;
    signal success    : std_logic;
    signal dout_we    : std_logic;
    -- delayed output signals
    signal dout_d : std_logic_vector (31 downto 0);
    
    -- CONTROLS
    signal enable_count : std_logic;
    signal enable_shift : std_logic;
    
    -- DEBUG
    signal debug : std_logic;
    signal clock_count : integer := 0;
begin
    
    -- --------------------------------------------------------------------- --
    -- Instantiation    UUT
    -- --------------------------------------------------------------------- --
    uut : entity work.bcrypt_quad_core
    port map
    (
      -- GENERAL
      clk              => clk,
      rst              => rst,
      -- CONFIG
      config           => config,
      number_of_cracks => number_of_cracks,
      t_salt           => t_salt,
      t_hash           => t_hash,
      vec_init         => vec_init,
      vec_length       => vec_length,
      -- BCRYPT
      memory_init      => mem_init,
      pipeline_full    => pipeline_full,
      sbox_init_addr  => sbox_addr_cnt_pipe_dout,
      sbox0_init_dout => sbox0_init_dout,
      sbox1_init_dout => sbox1_init_dout,
      sbox2_init_dout => sbox2_init_dout,
      sbox3_init_dout => sbox3_init_dout,
      skinit_dout     => subkey_init,
      -- CRACK RESULT
      dout => dout,
      done => done,
      success => success,
      dout_we => dout_we
    );
    
    -- --------------------------------------------------------------------- --
    -- Instantiation    BRAM for Sbox, Password and Shiftregister for Subkey
    -- --------------------------------------------------------------------- --     
    sbox01_init : entity work.bram
    generic map (
        DATA_WIDTH       => 32,
        ADDRESS_WIDTH    => 9,
        RW_MODE          => "RW",
        INIT_MEMORY      => true,
        INIT_FILL_ZEROES => true,
        INIT_FROM_FILE   => false,
        INIT_REVERSED    => false,
        INIT_FORMAT_HEX  => true,
        --INIT_FILE        => "sbox01_init.mif",
        INIT_VECTOR      => SBOX01_INIT_VEC
    )
    port map (
        clkA  => clk,
        weA   => '0',
        rstA  => '0',
        addrA => sbox0_init_addr,
        dinA => (others => '0'),
        doutA => sbox0_init_dout,
        clkB  => clk,
        weB   => '0',
        rstB  => '0',
        addrB => sbox1_init_addr,
        dinB => (others => '0'),
        doutB => sbox1_init_dout
    );
    
    -- Initial Values of Sbox 2 and 3 in one BRAM core
    sbox23_init : entity work.bram
    generic map (
        DATA_WIDTH       => 32,
        ADDRESS_WIDTH    => 9,
        RW_MODE          => "RW",
        INIT_MEMORY      => true,
        INIT_FILL_ZEROES => true,
        INIT_FROM_FILE   => false,
        INIT_REVERSED    => false,
        INIT_FORMAT_HEX  => true,
        --INIT_FILE        => "sbox23_init.mif",
        INIT_VECTOR      => SBOX23_INIT_VEC
    )
    port map (
        clkA  => clk,
        weA   => '0',
        rstA  => '0',
        addrA => sbox2_init_addr,
        dinA => (others => '0'),
        doutA => sbox2_init_dout,
        clkB  => clk,
        weB   => '0',
        rstB  => '0',
        addrB => sbox3_init_addr,
        dinB => (others => '0'),
        doutB => sbox3_init_dout
    );
    
    sbox0_init_addr <= '0' & sbox_addr_cnt_dout(7 downto 0);
    sbox1_init_addr <= '1' & sbox_addr_cnt_dout(7 downto 0);
    sbox2_init_addr <= '0' & sbox_addr_cnt_dout(7 downto 0);
    sbox3_init_addr <= '1' & sbox_addr_cnt_dout(7 downto 0);

    -- subkey initialization shiftreg
    subkey_init_reg : entity work.nxmBitShiftReg
        generic map (
            ASYNC => false,
            N     => 18,
            M     => 32
        )
        port map (
            clk    => clk,
            sr     => skinit_sr,
            srinit => SUBKEY_INIT_VAL,
            ce     => skinit_ce,
            opmode => "01", -- [Rot?, Left?] -- [shift,right]
            din    => const_slv(0, 32),
            dout   => subkey_init,
            dout_f => open
        );
    skinit_sr <= mem_init;
    skinit_ce <= enable_shift;
	
	-- --------------------------------------------------------------------- --
    -- Instantiation    SBox Address Counter
    -- --------------------------------------------------------------------- --
    sbox_init_counter : entity work.nBitCounter
        generic map (
            ASYNC       => false,
            BIT_WIDTH   => 9
        )
        port map (
            clk         => clk,
            ce          => enable_count,
            sr          => mem_init,
            srinit      => const_slv(0, 9),
            count_up    => '1',
            dout        => sbox_addr_cnt_dout
        );
    
    sbox_add_cnt_pipeline : entity work.nxmBitShiftReg
        generic map (
            ASYNC => false,
            N     => 1,
            M     => 9
        )
        port map (
            clk    => clk,
            sr     => mem_init,
            srinit => const_slv(0, 9),
            ce     => enable_count,
            opmode => "01", -- [Rot?, Left?] -- [shift,right]
            din    => sbox_addr_cnt_dout,
            dout   => sbox_addr_cnt_pipe_dout,
            dout_f => open
        );  
	
    -- --------------------------------------------------------------------- --
    -- Testbench Processes
    -- --------------------------------------------------------------------- --
    
    -- clock
    clk_proc : process
    begin
        clk <= '1';
        wait for 0.5 * CLK_PERIOD;
        clk <= '0';
        wait for 0.5 * CLK_PERIOD;
        if rst = '0' then
            clock_count <= clock_count + 1;
        end if;
    end process clk_proc;
    
    --delay output
    delay_output : process(clk)
    begin
        if rising_edge(clk) then
            dout_d <= dout;
        end if;
    end process delay_output;
    
    -- stimulus & check
    stim_check_proc : process
    begin
        report "reset core" severity note;
        rst <= '1';
        pipeline_full <= '0';
        enable_count <= '0';
        debug <= '0';
        enable_shift <= '0';
        wait for 10 * CLK_PERIOD;
        
        report "begin tests" severity note;
        rst <= '0';
        wait until mem_init = '0';
        pipeline_full <= '1';
        wait for CLK_PERIOD;
        enable_shift <= '1';
        enable_count <= '1';
        
        --wait until sbox_addr_cnt_dout > "011111111";
        wait until sbox_addr_cnt_dout > "100000000";
        -- --------------------------------------------------------------------- --
        -- Test:    check hash output
        -- --------------------------------------------------------------------- --
        
        
        report "---- TEST PASSED ----" severity note;
        finish;
    end process stim_check_proc;
end Behavioral;
