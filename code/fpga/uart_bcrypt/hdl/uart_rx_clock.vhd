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
-- Module Name: uart_rx_clock - arch
-- Target Device: digilentinc.com:nexys_video:part0:1.2 xc7a200tsbg484-1
-- Tool version: 2023.1
-- Description: Clock generator for the UART Receiver
--
-- Last update: 2023-11-27
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library uart;
use uart.uart_pkg.all;

entity uart_rx_clock is
  generic (
    CLK_FREQ : integer := 100; -- Clock frequency in MHz
    BAUDRATE : integer := 115200 -- UART baudrate
  );
  port (
    clk_i       : in  std_logic;
    resetn      : in  std_logic;
    -- Clock enable
    rx_clock_en : in  std_logic;
    -- Clock output
    rx_clock_o  : out std_logic
    );
end entity uart_rx_clock;


architecture arch of uart_rx_clock is

  ---------------------------------------------------------------------------------
  -- Constants
  --------------------------------------------------------------------------------- 
  constant BAUDRATE_COUNT : integer := comp_baudrate_count(CLK_FREQ, BAUDRATE);

  ---------------------------------------------------------------------------------
  -- Signals
  ---------------------------------------------------------------------------------
  signal rx_clock_s     : std_logic := '1';
  signal rx_clock_count : integer   := 0;
  
begin

  gen_rx_tick : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if resetn = '0' then
        rx_clock_s     <= '0';
        rx_clock_count <= 0;
      elsif rx_clock_count = (BAUDRATE_COUNT / 2 - 1) then
        rx_clock_s     <= not rx_clock_s;
        rx_clock_count <= 0;
      elsif rx_clock_en = '1' then
        rx_clock_s     <= rx_clock_s;
        rx_clock_count <= rx_clock_count + 1;
      else
        rx_clock_s     <= '0';
        rx_clock_count <= 0;
      end if;
    end if;
  end process;

  rx_clock_o <= rx_clock_s;

end arch;
