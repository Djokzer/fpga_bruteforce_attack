----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.06.2024 15:24:38
-- Design Name: 
-- Module Name: top - Behavioral
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

entity top is
	port (
		-- GENERAL
		clk         : in std_logic;
		reset       : in std_logic;
		
        -- UART interface
        tx          : out std_logic;
        rx          : in  std_logic;
		
		-- OUTPUT
        leds        : out std_logic_vector(7 downto 0)
	);
end top;

architecture Behavioral of top is

    -- UART SIGNALS
    signal resetn  : std_logic;
    signal tx_valid_i : std_logic;
    signal tx_data_i : std_logic_vector(7 downto 0);
    signal tx_busy_o : std_logic;
    signal rx_valid_o : std_logic;
    signal rx_data_o  : std_logic_vector(7 downto 0);

    -- PIPELINE OUTPUT
    signal leds_packet : std_logic_vector(7 downto 0);
    signal output_en : std_logic;
    
    -- OUTPUT MEM
    signal leds_mem : std_logic_vector(7 downto 0);
begin

    -- UART COM
    uart : entity work.uart
    generic map (
          CLK_FREQ => 100,
          BAUDRATE => 115200)
    port map (
        clk_i       => clk,
        resetn      => resetn,
        -- User interface
        tx_valid_i  => tx_valid_i,
        tx_data_i   => tx_data_i, 
        tx_busy_o   => tx_busy_o, 
        --
        rx_valid_o  => rx_valid_o,
        rx_data_o   => rx_data_o,
        -- UART interface
        tx_o        => tx,
        rx_i        => rx
    );
    resetn <= not reset;
    
    -- RX PACKET PIPELINE
    pckt_pipeline : entity work.rx_packet_pipeline
    port map(
        clk         => clk,
        reset       => reset,
        rx_valid    => rx_valid_o,
        rx_data     => rx_data_o,
        leds_out    => leds_packet,
        out_en      => output_en
    );
    
    -- NEW DATA OUTPUT
    output_proc : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                  leds_mem <= x"00";
            else
                if output_en = '1' then
                    leds_mem <= leds_packet;
                else
                    leds_mem <= leds_mem;
                end if;
            end if;
        end if;
    end process;
    leds <= leds_mem;

end Behavioral;
