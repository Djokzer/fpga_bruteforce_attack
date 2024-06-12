----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Abivarman Kandiah
-- 
-- Create Date: 28.11.2023 14:22:35
-- Design Name: 
-- Module Name: synchronizer - Behavioral
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

entity synchronizer is
    port (
        clk_i  : in  std_logic;
        resetn : in  std_logic;
        d_i      : in  std_logic;
        q_o      : out std_logic
    );
end synchronizer;

architecture Behavioral of synchronizer is
signal d_tmp : STD_LOGIC;
begin

proc_sync : process(clk_i)
begin
    if rising_edge(clk_i) then
        if resetn = '0' then
            d_tmp <= '0';
        else
            d_tmp <= d_i;
        end if;
        q_o <= d_tmp;
    end if;
end process;

end Behavioral;
