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
-- Module Name: uart - arch
-- Target Device: digilentinc.com:nexys_video:part0:1.2 xc7a200tsbg484-1
-- Tool version: 2023.1
-- Description: UART module
--
-- Last update: 2023-11-27
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
    generic (
      CLK_FREQ : integer := 100;
      BAUDRATE : integer := 115200
    );
  port (
    clk_i    : in  std_logic;
    resetn   : in  std_logic;
    -- User interface
    tx_valid_i : in  std_logic;
    tx_data_i  : in  std_logic_vector(7 downto 0);
    tx_busy_o  : out std_logic;
    --
    rx_valid_o : out std_logic;
    rx_data_o  : out std_logic_vector(7 downto 0);
    -- UART interface
    tx_o       : out std_logic;
    rx_i       : in  std_logic
    );
end entity uart;


architecture arch of uart is

  component uart_tx is
    generic (
      CLK_FREQ : integer := 100;
      BAUDRATE : integer := 115200
    );
    port (
      clk_i    : in  std_logic;
      resetn   : in  std_logic;
      -- User interface
      tx_valid_i : in  std_logic;
      tx_data_i  : in  std_logic_vector(7 downto 0);
      tx_busy_o  : out std_logic;
      -- UART interface
      tx_o       : out std_logic
      );
  end component;
  
  
  component uart_rx is
      generic (
      CLK_FREQ : integer := 100;
      BAUDRATE : integer := 115200
    );
    port (
      clk_i    : in  std_logic;
      resetn   : in  std_logic;
      -- User interface
      rx_valid_o : out std_logic;
      rx_data_o  : out std_logic_vector(7 downto 0);
      -- UART interface
      rx_i       : in  std_logic
      );
  end component;
  
begin

  uart_tx_i : uart_tx
    generic map (
      CLK_FREQ => CLK_FREQ,
      BAUDRATE => BAUDRATE
    )
    port map (
      clk_i    => clk_i,
      resetn   => resetn,
      tx_valid_i => tx_valid_i,
      tx_data_i  => tx_data_i,
      tx_busy_o  => tx_busy_o,
      tx_o       => tx_o
      );


  uart_rx_i : uart_rx
      generic map (
      CLK_FREQ => CLK_FREQ,
      BAUDRATE => BAUDRATE
      )
    port map (
      clk_i    => clk_i,
      resetn   => resetn,
      rx_valid_o => rx_valid_o,
      rx_data_o  => rx_data_o,
      rx_i       => rx_i
      );
  
end arch;
