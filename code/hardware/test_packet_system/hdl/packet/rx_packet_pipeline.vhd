----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.06.2024 15:33:06
-- Design Name: 
-- Module Name: rx_packet_pipeline - Behavioral
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
use ieee.math_real.all;

library work;

entity rx_packet_pipeline is
	port (
		-- GENERAL
		clk           : in std_logic;
		reset         : in std_logic;
		
		-- UART RX
		rx_valid      : in std_logic;
		rx_data       : in std_logic_vector(7 downto 0);
		
		-- OUTPUT
        leds_out      : out std_logic_vector(7 downto 0);
        out_en        : out std_logic

	);
end rx_packet_pipeline;

architecture Behavioral of rx_packet_pipeline is
    
    -- SIGNALS
    signal data_out : std_logic_vector(7 downto 0);
    signal data_valid : std_logic;
    signal data_incomming : std_logic;
    signal packet_valid : std_logic;

begin
    
    -- PACKET RECEIVER
    pckt_receiver : entity work.packet_receiver
    port map(
        clk => clk,
        reset => reset,
        rx_valid => rx_valid,
        rx_data => rx_data,
        packet_data => data_out,
        packet_data_valid => data_valid,
        packet_incomming => data_incomming,
        packet_valid => packet_valid
    );
    
    -- PACKET PROCESS
    pckt_process : entity work.rx_packet_process
    port map(
        clk => clk,
        reset => reset,
        packet_data => data_out,
        packet_data_valid => data_valid,
        packet_incomming => data_incomming,
        packet_valid => packet_valid,
        leds_out => leds_out,
        out_en => out_en
    );


end Behavioral;
