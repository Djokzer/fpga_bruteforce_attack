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
-- Module Name: uart_tx_clock - arch
-- Target Device: digilentinc.com:nexys_video:part0:1.2 xc7a200tsbg484-1
-- Tool version: 2023.1
-- Description: UART transmitter clock generator
--
-- Last update: 2023-11-27
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library uart;
use uart.uart_pkg.all;

entity uart_tx_clock is
  generic (
    CLK_FREQ : integer := 100; -- Clock frequency in MHz
    BAUDRATE : integer := 115200 -- UART baudrate
  );
  port (
    clk_i    : in    std_logic;
    resetn    : in    std_logic;
    tx_clock_o : out   std_logic
  );
end uart_tx_clock;


architecture arch of uart_tx_clock is

  -- Number of clock cycles required to match the UART baudrate
  constant BAUDRATE_COUNT : integer := comp_baudrate_count(CLK_FREQ, BAUDRATE);

  signal tx_clock_s : std_logic := '1';
  signal tx_clock_count : integer := 0;

begin

    gen_tick : process(clk_i)
    begin
        if rising_edge(clk_i) then
            if resetn = '0' then
                tx_clock_s <= '1';
                tx_clock_count <= 0;
            elsif tx_clock_count = (BAUDRATE_COUNT / 2 - 1) then
                tx_clock_s <= not tx_clock_s;
                tx_clock_count <= 0;
            else
                tx_clock_s <= tx_clock_s;
                tx_clock_count <= tx_clock_count + 1;
            end if;
        end if;
    end process;
    
    tx_clock_o <= tx_clock_s;

end arch;
