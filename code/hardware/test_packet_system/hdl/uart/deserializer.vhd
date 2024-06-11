----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.11.2023 14:36:44
-- Design Name: 
-- Module Name: deserializer - Behavioral
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

entity deserializer is
    port (
      clk_i    : in  std_logic;
      resetn   : in  std_logic;
      bit_en_i   : in  std_logic;
      bit_i   : in  std_logic;
      data_o : out std_logic_vector(7 downto 0)
      );
end deserializer;

architecture Behavioral of deserializer is
signal data : std_logic_vector(7 downto 0) := (others => '0');
begin

proc_data_in : process(clk_i)
begin
    if rising_edge(clk_i) then
        if resetn = '0' then
            data <= (others => '0');
        else
            if bit_en_i = '1' then
                data <= bit_i & data(7 downto 1);
            end if;
        end if;
    end if;
end process;

-- UPDATE DATA OUT
data_o <= data;

end Behavioral;
