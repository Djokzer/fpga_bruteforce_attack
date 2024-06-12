-------------------------------------------------------------------------------
-- Title      : bcrypt - Testbench
-- Project    : bcrypt Bruteforce
-- ----------------------------------------------------------------------------
-- File       : bcrypt_tb.vhd
-- Author     : Abivarman Kandiah
-- Company    : 
-- Created    : 28-11-2023
-- Last update: 05-12-2023
-- Platform   : Vivado 2023
-- Standard   : VHDL 2008
-- ----------------------------------------------------------------------------
-- Description: This module provides a testbench for the bcytp core.
-- ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

library work;
use work.pkg_bcrypt.all;
use work.rzi_helper.all;

use std.env.finish;

entity bcrypt_tb is
end bcrypt_tb;

architecture Behavioral of bcrypt_tb is
    
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
    constant PASSWORD : std_logic_vector(575 downto 0) := 
    x"6200620062006200620062006200620062006200620062006200" &
    x"6200620062006200620062006200620062006200620062006200" &
    x"6200620062006200620062006200620062006200";
    constant HASH : std_logic_vector(HASH_LENGTH-1 downto 0) :=
    x"37d085c7d8b559b151ce4e6f9ce2e7b0a1678b26a2517d";
    
    -- --------------------------------------------------------------------- --
    --                               Signals
    -- --------------------------------------------------------------------- --
    signal clk        : std_logic; -- clock signal
    signal rst        : std_logic; -- reset signal (enable high)
    signal dout       : std_logic_vector (63 downto 0);
    signal dout_valid : std_logic;
    
    -- ADDED SIGNALS
    signal start_expand_key : std_logic;
    signal mem_init         : std_logic;
    signal pipeline_full    : std_logic;
    signal subkey_init      : std_logic_vector(31 downto 0);
    signal key_addr         : std_logic_vector (4 downto 0);
    signal key_dout         : std_logic_vector (31 downto 0);
    signal dummy            : std_logic_vector (31 downto 0);
    signal key_done         : std_logic;
    signal debug            : std_logic;
    -- subkey
    signal skinit_sr        : std_logic;
    signal skinit_ce        : std_logic;
    signal pwd_addr         : std_logic_vector (4 downto 0);
    
    -- sbox init out signals
    signal sbox0_init_dout : std_logic_vector(31 downto 0);
    signal sbox1_init_dout : std_logic_vector(31 downto 0);
    signal sbox2_init_dout : std_logic_vector(31 downto 0);
    signal sbox3_init_dout : std_logic_vector(31 downto 0);
    -- sbox init controll signals
    signal sbox0_init_addr : std_logic_vector (8 downto 0);
    signal sbox1_init_addr : std_logic_vector (8 downto 0);
    signal sbox2_init_addr : std_logic_vector (8 downto 0);
    signal sbox3_init_addr : std_logic_vector (8 downto 0);
    signal sbox_addr_cnt_dout   : std_logic_vector ( 8 downto 0);
    signal sbox_addr_cnt_pipe_dout : std_logic_vector ( 8 downto 0);
    
    signal enable_count : std_logic;
    signal enable_shift : std_logic;
    
    signal clock_count : integer := 0;
    
    -- delayed output signals
    signal dout_valid_d : std_logic;
    signal dout_d : std_logic_vector (63 downto 0);
begin
    
    -- --------------------------------------------------------------------- --
    -- Instantiation    UUT
    -- --------------------------------------------------------------------- --
    uut : entity work.bcrypt
    port map
    (
      clk              => clk,
      rst              => rst,
      salt             => SALT,
      start_expand_key => start_expand_key,
      memory_init      => mem_init,
      pipeline_full    => pipeline_full,
      -- sbox init access
      sbox_init_addr  => sbox_addr_cnt_pipe_dout,
      sbox0_init_dout => sbox0_init_dout,
      sbox1_init_dout => sbox1_init_dout,
      sbox2_init_dout => sbox2_init_dout,
      sbox3_init_dout => sbox3_init_dout,
      skinit_dout     => subkey_init,
      -- key access
      key_addr => key_addr,
      key_dout => key_dout,
      key_done => key_done,
      -- valid output data
      dout_valid => dout_valid,
      -- output data
      dout => dout
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
        INIT_FROM_FILE   => true,
        INIT_REVERSED    => true,
        INIT_FORMAT_HEX  => true,
        INIT_FILE        => "sbox01_init.mif",
        INIT_VECTOR      => "0"
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
        INIT_FROM_FILE   => true,
        INIT_REVERSED    => true,
        INIT_FORMAT_HEX  => true,
        INIT_FILE        => "sbox23_init.mif",
        INIT_VECTOR      => "0"
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
    
    pwd_mem : entity work.bram
        generic map (
            DATA_WIDTH       => 32,
            ADDRESS_WIDTH    => 5,
            RW_MODE          => "RW",
            INIT_MEMORY      => true,
            INIT_VECTOR      => PASSWORD,
            INIT_REVERSED    => false
        )
        port map (
            clkA  => clk,
            weA   => '0',
            rstA  => '0',
            addrA => pwd_addr,
            dinA  => (others => '0'),
            doutA => key_dout,
            clkB  => clk,
            weB   => '0',
            rstB  => '1',
            addrB => pwd_addr,
            dinB  => (others => '0'),
            doutB => dummy
        );
    -- BRAM PWD IS STORED FROM THE MIDDLE TO THE LAST ADDRESS (31 Last address - 17 Last address(from 0) = 14 offset)
    pwd_addr <= std_logic_vector(unsigned(key_addr) + 14);

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
            dout_valid_d <= dout_valid;
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
        start_expand_key <= '0';
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
        start_expand_key <= '1';
        -- --------------------------------------------------------------------- --
        -- Test:    check hash output
        -- --------------------------------------------------------------------- --
        wait until dout_valid_d = '1';
        debug <= '1';
        wait for CLK_PERIOD;
        report "finished hashing, check output" severity note;
        report "First chunk: " & to_hstring(dout_d);
        report "First real : " & to_hstring(HASH(HASH_LENGTH-1 downto 120));
        assert dout_d = HASH(HASH_LENGTH-1 downto 120) report "Hash incorrect" severity failure;
        debug <= '0';
        wait until dout_valid_d = '1';
        debug <= '1';
        wait for CLK_PERIOD;
        report "Second chunk: " & to_hstring(dout_d);
        report "Second real : " & to_hstring(HASH(119 downto 56));
        assert dout_d = HASH(119 downto 56) report "Hash incorrect" severity failure;
        debug <= '0';
        wait until dout_valid_d = '1';
        debug <= '1';
        wait for CLK_PERIOD;
        report "Third chunk: " & to_hstring(dout_d);
        report "Third real : " & to_hstring(HASH(55 downto 0));
        assert dout_d(63 downto 8) = HASH(55 downto 0) report "Hash incorrect" severity failure;
        debug <= '0';
        
        report "---- TEST PASSED ----" severity note;
        finish;
    end process stim_check_proc;

end Behavioral;