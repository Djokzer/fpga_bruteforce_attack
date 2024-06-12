-------------------------------------------------------------------------------
-- Title      : bcrypt_cracker - Testbench
-- Project    : bcrypt bruteforce
-- ----------------------------------------------------------------------------
-- File       : bcrypt_cracker_tb.vhd
-- Author     : Friedrich Wiemer <friedrich.wiemer@rub.de>
-- Company    : Ruhr-University Bochum
-- Created    : 2014-04-01
-- Last update: 2014-04-01
-- Platform   : Xilinx Toolchain
-- Standard   : VHDL'93/02
-- ----------------------------------------------------------------------------
-- Description: This module provides a testbench for the bcrypt cracker
--              module with a simulater, i.e., ISIM or ModelSim.
-- ----------------------------------------------------------------------------
-- Copyright (c) 2012-2014 Ruhr-University Bochum
-- ----------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-04-01  1.0      fwi     Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

library work;
use work.pkg_bcrypt.all;
use work.rzi_helper.all;

entity bcrypt_cracker_tb is
end bcrypt_cracker_tb;

architecture Behavioral of bcrypt_cracker_tb is

    -- --------------------------------------------------------------------- --
    --                              Constants
    -- --------------------------------------------------------------------- --
    constant CLK_PERIOD : time := 10 ns;
    signal PWD : std_logic_vector(95 downto 0) := x"616161616200616161616200";

    -- --------------------------------------------------------------------- --
    --                               Signals
    -- --------------------------------------------------------------------- --
    signal clk      : std_logic;     -- clock signal
    signal rst      : std_logic;     -- reset signal (enable high)
    signal rst_a    : std_logic;     -- reset signal (enable high) aligned
    signal t_salt   : std_logic_vector (SALT_LENGTH-1 downto 0);
    signal salt_a   : std_logic_vector (SALT_LENGTH-1 downto 0);
    signal t_hash   : std_logic_vector (HASH_LENGTH-1 downto 0);
    signal hash_a   : std_logic_vector (HASH_LENGTH-1 downto 0);
    signal done     : std_logic;
    signal success  : std_logic;
    signal dout_we  : std_logic;
    signal dout     : std_logic_vector (31 downto 0);
    
begin

    -- --------------------------------------------------------------------- --
    -- Instantiation    UUT
    -- --------------------------------------------------------------------- --
    uut : entity work.bcrypt_cracker
    port map (
        clk     => clk,       -- clock signal
        rst     => rst_a,     -- reset signal
        t_salt  => salt_a,
        t_hash  => hash_a,
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
            salt_a <= t_salt;
            hash_a <= t_hash;
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
        report "Begin of Testbench"
        severity note;
    -- --------------------------------------------------------------------- --
    -- Setup
    -- --------------------------------------------------------------------- --
        wait for CLK_PERIOD;
        report "reset module, setup target salt and hash"
        severity note;
        rst <= '1';
        
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

     -- --------------------------------------------------------------------- --
    -- Test
    -- --------------------------------------------------------------------- --
        wait for 2*CLK_PERIOD;
        report "begin tests" severity note;
        rst <= '0';

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
        wait until done = '1';

    -- --------------------------------------------------------------------- --
    -- Report
    -- --------------------------------------------------------------------- --
        wait for CLK_PERIOD;
        report "----------------------- Test Report -----------------------" severity note;
        
        
        report "---------------------- Password Found ---------------------" severity note;
        
        
        report "---------------------- End of Report ----------------------" severity note;
        assert false report "End of Testbench" severity failure;
    end process stim_proc;

end Behavioral;
