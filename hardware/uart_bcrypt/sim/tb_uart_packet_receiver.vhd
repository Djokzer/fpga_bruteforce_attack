----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.05.2024 10:10:17
-- Design Name: 
-- Module Name: tb_packet_receiver - Behavioral
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

entity tb_uart_packet_receiver is
end tb_uart_packet_receiver;

architecture Behavioral of tb_uart_packet_receiver is

    constant CLK_PERIOD : time := 10 ns;
    
    signal clk_i  : std_logic := '0';
    signal reset  : std_logic;
    
    -- UUT SIGNALS
    signal data_out : std_logic_vector(7 downto 0);
    signal data_valid : std_logic;
    signal data_incomming : std_logic;
    signal packet_valid : std_logic;
    
    -- UART SIGNALS
    signal resetn  : std_logic;
    signal tx_valid_i : std_logic;
    signal tx_data_i : std_logic_vector(7 downto 0);
    signal tx_busy_o : std_logic;
    signal rx_valid_o : std_logic;
    signal rx_data_o  : std_logic_vector(7 downto 0);
    signal tx_o       : std_logic;
    signal rx_i       : std_logic;
    
    -- Procedure to check output data
    procedure check_out_data(
        correct_data : in std_logic_vector(7 downto 0);
        signal data : in std_logic_vector(7 downto 0);
        signal valid : in std_logic
    ) is
    begin
        wait until valid = '1';
        assert correct_data = data report "Incorrect data byte" severity note;
        wait for CLK_PERIOD;
    end procedure; 

begin

    -- CLOCK AND RESET SIGNAL
    clk_i  <= not clk_i after CLK_PERIOD / 2;
    reset <= '1', '0'  after CLK_PERIOD * 10;
    
    -- UART COM
    uart : entity work.uart
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
    resetn <= not reset;
    
    -- UUT INSTANTIATION
    uut : entity work.packet_receiver
    port map(
        clk => clk_i,
        reset => reset,
        rx_valid => rx_valid_o,
        rx_data => rx_data_o,
        packet_data => data_out,
        packet_data_valid => data_valid,
        packet_incomming => data_incomming,
        packet_valid => packet_valid
    );
    
    stimuli : process
    begin
        -- Wait for reset to be released
        wait until reset = '0';
        wait for CLK_PERIOD;
        
        -- FIRST PACKET (Payload : 1, 0, 2)
        uart_tx_byte(clk_i, tx_valid_i, tx_data_i, tx_busy_o, x"03");
        uart_tx_byte(clk_i, tx_valid_i, tx_data_i, tx_busy_o, x"03");
        uart_tx_byte(clk_i, tx_valid_i, tx_data_i, tx_busy_o, x"01");
        uart_tx_byte(clk_i, tx_valid_i, tx_data_i, tx_busy_o, x"03");
        uart_tx_byte(clk_i, tx_valid_i, tx_data_i, tx_busy_o, x"02");
        uart_tx_byte(clk_i, tx_valid_i, tx_data_i, tx_busy_o, x"65");
        uart_tx_byte(clk_i, tx_valid_i, tx_data_i, tx_busy_o, x"00");
        
        
        -- SECOND PACKET (Payload : 0, 0, 2, 255, 0)
        uart_tx_byte(clk_i, tx_valid_i, tx_data_i, tx_busy_o, x"02");
        uart_tx_byte(clk_i, tx_valid_i, tx_data_i, tx_busy_o, x"05");
        uart_tx_byte(clk_i, tx_valid_i, tx_data_i, tx_busy_o, x"01");
        uart_tx_byte(clk_i, tx_valid_i, tx_data_i, tx_busy_o, x"03");
        uart_tx_byte(clk_i, tx_valid_i, tx_data_i, tx_busy_o, x"02");
        uart_tx_byte(clk_i, tx_valid_i, tx_data_i, tx_busy_o, x"ff");
        uart_tx_byte(clk_i, tx_valid_i, tx_data_i, tx_busy_o, x"02");
        uart_tx_byte(clk_i, tx_valid_i, tx_data_i, tx_busy_o, x"01");
        uart_tx_byte(clk_i, tx_valid_i, tx_data_i, tx_busy_o, x"00");
        
    end process;
    
    check_output : process
    begin
        -- Wait for reset to be released
        wait until reset = '0';
        wait for CLK_PERIOD;
        
        check_out_data(x"01", data_out, data_valid);
        check_out_data(x"00", data_out, data_valid);
        check_out_data(x"02", data_out, data_valid);
        
        report "-- First packet succefull --";
        
        wait until packet_valid = '1';
        wait for CLK_PERIOD * 2;
        
        check_out_data(x"00", data_out, data_valid);
        check_out_data(x"00", data_out, data_valid);
        check_out_data(x"02", data_out, data_valid);
        check_out_data(x"FF", data_out, data_valid);
        check_out_data(x"00", data_out, data_valid);
        
        report "-- Second packet succefull --";
        
        wait until packet_valid = '1';
        wait for CLK_PERIOD * 2;
        
        report "-- Simulation completed successfully --";
        finish;
    end process;
end Behavioral;