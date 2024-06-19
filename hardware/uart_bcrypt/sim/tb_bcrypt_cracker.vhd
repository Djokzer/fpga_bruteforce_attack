library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;
use std.env.finish;

library work;
use work.pkg_bcrypt.all;
use work.rzi_helper.all;

entity tb_bcrypt_cracker is
end tb_bcrypt_cracker;

architecture Behavioral of tb_bcrypt_cracker is

    -- --------------------------------------------------------------------- --
    --                              Constants
    -- --------------------------------------------------------------------- --
    constant CLK_PERIOD : time := 10 ns;
    signal PWD : std_logic_vector(95 downto 0) := x"616161616200616161616200";
    
    constant NUMBER_OF_QUADCORES : integer := 1;
    constant C_VEC_INIT : std_logic_vector (PWD_LENGTH*CHARSET_OF_BIT-1 downto 0)
    := const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT) &
       const_slv(0,CHARSET_OF_BIT) & const_slv(0,CHARSET_OF_BIT);
   constant C_VEC_LENGTH : integer := 1;

    -- --------------------------------------------------------------------- --
    --                               Signals
    -- --------------------------------------------------------------------- --
    -- GENERAL
    signal clk      : std_logic;     -- clock signal
    signal rst      : std_logic;     -- reset signal (enable high)
    signal rst_a    : std_logic;     -- reset signal (enable high) aligned

    -- CONFIG
    signal config_enable   : std_logic;
    signal quadcore_id     : std_logic_vector(7 downto 0);
    signal number_of_cracks: std_logic_vector (31 downto 0);
    signal t_salt          : std_logic_vector (SALT_LENGTH-1 downto 0);
    signal t_hash          : std_logic_vector (HASH_LENGTH-1 downto 0);
    signal vec_init        : std_logic_vector (PWD_LENGTH*CHARSET_OF_BIT-1 downto 0);
    signal vec_length      : std_logic_vector(PWD_BITLEN - 1 downto 0);

    -- CRACK RESULT
    signal done     : std_logic;
    signal success  : std_logic;
    signal dout_we  : std_logic;
    signal dout     : std_logic_vector (31 downto 0);
    
begin

    -- --------------------------------------------------------------------- --
    -- Instantiation    UUT
    -- --------------------------------------------------------------------- --
    uut : entity work.bcrypt_cracker
    generic map(
        NUMBER_OF_QUADCORES => NUMBER_OF_QUADCORES
    )
    port map (
        -- GENERAL
        clk     => clk,
        rst     => rst_a,  
        
        -- CONFIG
        config_enable    => config_enable, 
        quadcore_id      => quadcore_id, 
        number_of_cracks => number_of_cracks, 
        t_salt           => t_salt, 
        t_hash           => t_hash, 
        vec_init         => vec_init, 
        vec_length       => vec_length,

        -- CRACK RESULT
        done    => done,
        success => success,
        dout_we => dout_we,
        dout    => dout
    );

    -- --------------------------------------------------------------------- --
    -- Testbench Processes
    -- --------------------------------------------------------------------- --

    -- align
    align_proc : process(clk)
    begin
        if rising_edge(clk) then
            rst_a  <= rst;
        end if;
    end process align_proc;

    -- clock
    clk_proc : process
    begin
        clk <= '1';
        wait for 0.5*CLK_PERIOD;
        clk <= '0';
        wait for 0.5*CLK_PERIOD;
    end process clk_proc;

    -- stimulus
    stim_proc : process
    begin
        report "Begin Testbench" severity note;
        rst <= '1';
        wait for 10*CLK_PERIOD;
        rst <= '0';
        wait for 2*CLK_PERIOD;

        report "Config Quadcore" severity note;
        config_enable    <= '1';
        quadcore_id      <= std_logic_vector(to_unsigned(0, quadcore_id'length));
        number_of_cracks <= std_logic_vector(to_unsigned(10, number_of_cracks'length));
        vec_init         <= C_VEC_INIT;
        vec_length       <= std_logic_vector(to_unsigned(C_VEC_LENGTH, vec_length'length));

        -- SALT
        t_salt <= x"7e949a07e88186c649bbeb0a9740c5e0";
        
        -- PASSWORD
        -- one character password
        t_hash <= x"1982ade712f9ec3d3a57ce85adf7fc3e2b43d7d89f90d3";    -- a cost 4
        --t_hash <= x"37d085c7d8b559b151ce4e6f9ce2e7b0a1678b26a2517d";    -- b cost 4
        --t_hash <= x"f31c6c5da150c28ada3fe7566bcdf35314de5b8825dd23";    -- c cost 4
        --t_hash <= x"a2a4f09f9ed6d6f9f0e1747dd709f95809f27129279c92";    -- z cost 4
        

        -- 5 character password - Change VEC_INIT and VEC_LENGTH for faster results
        --t_hash <= x"f900c98260aa954ca16bb5708de618104871d8c8f5e773";    -- aaaaa cost 4
        --t_hash <= x"d86d48abc6671334fd1fba805ee98b4841ce9ec37096d0";    -- aaaab cost 4

        wait for CLK_PERIOD;
        config_enable    <= '0';

        report "Check Results" severity note;
        wait until success = '1';
        for i in 0 to 17 loop
            wait for CLK_PERIOD;
            report integer'image(i) severity note;
            --assert dout = PWD(95 - (32 * (i mod 3)) downto 64 - (32 * (i mod 3))) report "checking dout" severity failure;
            assert dout = x"61006100" report "checking dout" severity failure;  -- a cost 4
            --assert dout = x"62006200" report "checking dout" severity failure;    -- b cost 4
            --assert dout = x"63006300" report "checking dout" severity failure;    -- c cost 4
            --assert dout = x"7a007a00" report "checking dout" severity failure;    -- z cost 4
        end loop;

        wait for CLK_PERIOD;
        report "----------------------- Test Report -----------------------" severity note;
        
        
        report "---------------------- Password Found ---------------------" severity note;
        
        
        report "---------------------- End of Report ----------------------" severity note;
        finish;
    end process stim_proc;

end Behavioral;
