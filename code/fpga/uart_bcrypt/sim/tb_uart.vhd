----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.11.2023 15:31:56
-- Design Name: 
-- Module Name: tb_uart - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

library std;
use std.env.finish;

library uart;
use uart.uart_pkg.all;

entity tb_uart is
end tb_uart;

architecture Behavioral of tb_uart is
    -- UUT PROTOTYPE
    component uart is
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
    end component;

    -- SIGNALS
    signal clk_i  : std_logic := '0';
    signal resetn : std_logic;
    signal tx_valid_i : std_logic;
    signal tx_data_i : std_logic_vector(7 downto 0);
    signal tx_busy_o : std_logic;
    signal rx_valid_o : std_logic;
    signal rx_data_o  : std_logic_vector(7 downto 0);
    signal tx_o       : std_logic;
    signal rx_i       : std_logic;
    
    constant CLK_PERIOD : time := 10 ns;
begin
    -- CLOCK AND RESET SIGNAL
    clk_i  <= not clk_i after CLK_PERIOD / 2;
    resetn <= '0', '1'  after CLK_PERIOD * 10;
    
    -- UUT INSTANTIATION
    uut : uart
    generic map (
          CLK_FREQ => 100,
          BAUDRATE => 115200)
    port map (
        clk_i       => clk_i,
        resetn      => resetn,
        -- User interface
        tx_valid_i  => tx_valid_i,
        tx_data_i   => tx_data_i, 
        tx_busy_o   => tx_busy_o, 
        --
        rx_valid_o  => rx_valid_o,
        rx_data_o   => rx_data_o,
        -- UART interface
        tx_o        => tx_o,
        rx_i        => rx_i
    );

    rx_i <= tx_o;

    stimuli : process
    begin
        -- Wait for reset to be released
        wait until resetn = '1';
        wait for CLK_PERIOD;
        
        for i in 97 to 103 loop
            uart_tx_byte(clk_i, tx_valid_i, tx_data_i, tx_busy_o, std_logic_vector(to_unsigned(i, tx_data_i'length)));
        end loop;
    end process;
    
    check_out : process
    begin
        -- Wait for reset to be released
        wait until resetn = '1';
        wait for CLK_PERIOD;
        
        for i in 97 to 103 loop
            wait until rx_valid_o = '1';
            assert rx_data_o = std_logic_vector(to_unsigned(i, tx_data_i'length)) report "ERROR : RX DATA BAD !" severity failure;
            wait for CLK_PERIOD;
        end loop;
        
        report "-- Simulation completed successfully --";
        finish;
    end process;
end Behavioral;
