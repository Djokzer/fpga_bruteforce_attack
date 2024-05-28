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

entity tb_packet_receiver is
end tb_packet_receiver;

architecture Behavioral of tb_packet_receiver is

    constant CLK_PERIOD : time := 10 ns;
    
    signal clk_i  : std_logic := '0';
    signal reset  : std_logic;
    signal rx_valid : std_logic := '0';
    signal rx_data : std_logic_vector(7 downto 0) := x"00";
    signal data_out : std_logic_vector(7 downto 0);
    signal data_valid : std_logic;
    signal data_incomming : std_logic;
    signal packet_valid : std_logic;
    
    procedure data_write(
        data_in : in std_logic_vector(7 downto 0);
        signal data_out : out std_logic_vector(7 downto 0);
        signal data_valid : out std_logic
    ) is
    begin
        data_out <= data_in;
        data_valid <= '1';
        wait for CLK_PERIOD;
        data_valid <= '0';
        wait for CLK_PERIOD;
    end procedure;
    
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
    
    -- UUT INSTANTIATION
    uut : entity work.packet_receiver
    port map(
        clk => clk_i,
        reset => reset,
        rx_valid => rx_valid,
        rx_data => rx_data,
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
    data_write(x"03", rx_data, rx_valid);
    data_write(x"03", rx_data, rx_valid);
    data_write(x"01", rx_data, rx_valid);
    data_write(x"03", rx_data, rx_valid);
    data_write(x"02", rx_data, rx_valid);
    data_write(x"65", rx_data, rx_valid);
    data_write(x"00", rx_data, rx_valid);
    
    
    -- SECOND PACKET (Payload : 0, 0, 2, 255, 0)
    data_write(x"02", rx_data, rx_valid);
    data_write(x"05", rx_data, rx_valid);
    data_write(x"01", rx_data, rx_valid);
    data_write(x"03", rx_data, rx_valid);
    data_write(x"02", rx_data, rx_valid);
    data_write(x"ff", rx_data, rx_valid);
    data_write(x"02", rx_data, rx_valid);
    data_write(x"01", rx_data, rx_valid);
    data_write(x"00", rx_data, rx_valid);
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
