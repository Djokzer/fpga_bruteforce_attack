----------------------------------------------------------------------------------
--                                 _             _
--                                | |_  ___ _ __(_)__ _
--                                | ' \/ -_) '_ \ / _` |
--                                |_||_\___| .__/_\__,_|
--                                         |_|
--
----------------------------------------------------------------------------------
--
-- Company: HEPIA
-- Author: Laurent Gantel <laurent.gantel@hesge.ch>
--
-- Module Name: serializer - arch
-- Target Device: digilentinc.com:nexys_video:part0:1.2 xc7a200tsbg484-1
-- Tool version: 2023.1
-- Description: Serializer
--
-- Last update: 2023-11-27
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


entity serializer is
  generic (
    C_DATA_WIDTH : integer := 8
    );
  port (
    clk_i   : in  std_logic;
    resetn  : in  std_logic;
    load_i  : in  std_logic;
    bit_en_i  : in  std_logic;
    data_i : in  std_logic_vector((C_DATA_WIDTH - 1) downto 0);
    bit_o : out std_logic
    );
end entity serializer;


architecture arch of serializer is

  -- Internal register
  signal shift_reg : std_logic_vector((C_DATA_WIDTH - 1) downto 0) := (others => '0');
  -- Registered output
  signal shift_out : std_logic := '0';
  
begin

  shift_din_proc : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if resetn = '0' then
        shift_reg <= (7 => '0', others => '1');
      elsif load_i = '1' then
        shift_reg <= data_i;
      -- When bit_en is asserted, the internal register is shifted
      -- When the bit_en is asserted for the first time, shift_out should keep the current value on bit 0
      elsif bit_en_i = '1' then
        shift_out <= shift_reg(0);
        -- Rotation to the right
        shift_reg <= shift_reg(0) & shift_reg(C_DATA_WIDTH - 1 downto 1);
      end if;
    end if;
  end process shift_din_proc;

  bit_o <= shift_out;
  
end arch;
