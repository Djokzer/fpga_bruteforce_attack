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
use work.pkg_bcrypt.all;
use work.rzi_helper.all;

entity rx_packet_pipeline is
	port (
		-- GENERAL
		clk           : in std_logic;
		reset         : in std_logic;
		
		-- UART RX
		rx_valid      : in std_logic;
		rx_data       : in std_logic_vector(7 downto 0);
		
		-- OUTPUT
        quadcore_id         : out std_logic_vector(7 downto 0);
        crack_max           : out std_logic_vector(31 downto 0);
        salt                : out std_logic_vector(SALT_LENGTH-1 downto 0);
        hash                : out std_logic_vector(HASH_LENGTH-1 downto 0);
        pwd_count_init      : out std_logic_vector(PWD_LENGTH*CHARSET_OF_BIT-1 downto 0);
        pwd_len_init        : out std_logic_vector(PWD_BITLEN - 1 downto 0);
        
        -- RETURN
        output_en           : out std_logic;
        error_status        : out std_logic_vector(2 downto 0)
	);
end rx_packet_pipeline;

architecture Behavioral of rx_packet_pipeline is
    
    -- SIGNALS
    signal data_out : std_logic_vector(7 downto 0);
    signal data_valid : std_logic;
    signal data_incomming : std_logic;
    signal data_incomming_d : std_logic;
    signal packet_valid : std_logic;
    signal error_code : std_logic_vector(1 downto 0);
    signal crc_error : std_logic := '0';

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
        quadcore_id => quadcore_id,
        crack_max => crack_max,
        salt => salt,
        hash => hash,
        pwd_count_init => pwd_count_init,
        pwd_len_init => pwd_len_init,
        output_en => output_en,
        error_code => error_code
    );

    -- DELAY INCOMMING SIGNAL (FOR FALLING EDGE)
    delay_proc : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                data_incomming_d <= '0';
            else
                data_incomming_d <= data_incomming;
            end if;
        end if;
    end process;
    
    -- CHECK IF CRC ERROR
    crc_check_proc : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                crc_error <= '0';
            else
                -- CHECK FALLING EDGE
                if data_incomming = '0' and data_incomming_d = '1' then
                    if packet_valid = '0' then
                        crc_error <= '1'; 
                    else
                        crc_error <= '0'; 
                    end if;
                else
                    crc_error <= '0';
                end if;
            end if;
        end if;
    end process;

    -- RETURN ERROR
    error_status <= crc_error & error_code;
end Behavioral;
