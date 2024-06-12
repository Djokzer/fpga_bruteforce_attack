----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.02.2024 12:03:31
-- Design Name: 
-- Module Name: top_tb - Behavioral
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


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pkg_bcrypt.all;
use work.rzi_helper.all;

library std;
use std.env.finish;

entity top_tb is
end top_tb;

architecture Behavioral of top_tb is
    -- --------------------------------------------------------------------- --
    --                              Constants
    -- --------------------------------------------------------------------- --
    constant CLK_PERIOD : time := 10 ns;
    
     -- --------------------------------------------------------------------- --
    --                               Signals
    -- --------------------------------------------------------------------- --
    signal clk      : std_logic := '1';     -- clock signal
    signal rst      : std_logic := '1';     -- reset signal (enable high)
    signal start    : std_logic;
    signal found    : std_logic;
    signal done     : std_logic;
  
    signal count_cycle : integer := 0;
begin
    -- --------------------------------------------------------------------- --
    -- Instantiation    UUT
    -- --------------------------------------------------------------------- --
    uut : entity work.top
    port map (
        clk     => clk,       -- clock signal
        rst     => rst,     -- reset signal
        start  => start,
        found  => found,
        done    => done
    );
    
    -- CLOCK AND RESET PROCESS
    clk_process : clk <= not clk after CLK_PERIOD / 2;
    rst_process : rst <= '1', '0' after CLK_PERIOD * 2;
    
    -- COUNT CLOCK CYCLES FOR CRACK
    counter : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                count_cycle <= 0;
            else
                count_cycle <= count_cycle + 1;
            end if;
        end if;
    end process counter;
    
    -- OUTPUT CHECK
    check_proc : process
    begin
        wait until rst = '0';
        report "CRACKING BEGIN" severity note;
        
        wait until done = '1';
        assert found = '1' report "PASSWORD NOT FOUND..." severity failure;
        
        report "PASWORD FOUND !!!" severity note;
        report "TOOK " & integer'image(count_cycle) & " CLOCK CYCLES !" severity note;
        
        wait for 1000*CLK_PERIOD;
        finish;
    end process check_proc;

end Behavioral;
