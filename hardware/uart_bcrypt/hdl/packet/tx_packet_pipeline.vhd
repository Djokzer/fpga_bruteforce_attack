library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;

entity tx_packet_pipeline is
    port (
        -- GENERAL
        clk   : in std_logic;
        reset : in std_logic;
        
        -- UART TX
        tx_valid            : out  std_logic;
		tx_data             : out  std_logic_vector(7 downto 0);
		tx_busy             : in std_logic;

        -- Packet return
        packet_processed    : in std_logic;
        error_code          : in std_logic_vector(2 downto 0)
    );
end entity tx_packet_pipeline;

architecture rtl of tx_packet_pipeline is

    signal payload_incomming   : std_logic;
    signal payload_length      : std_logic_vector(7 downto 0);     
    signal data                : std_logic_vector(7 downto 0);
    signal data_valid          : std_logic;
    signal transmit_busy       : std_logic;

    signal return_flag         : std_logic := '0';
    signal return_process      : std_logic := '0';
    signal return_packet       : std_logic_vector(7 downto 0);
begin

    -- PACKET TRANSMITTER
    pckt_transmitter : entity work.packet_transmitter
    port map(
        -- GENERAL
        clk                 => clk,
        reset               => reset,

        -- UART TX
        tx_valid            => tx_valid,
		tx_data             => tx_data,
		tx_busy             => tx_busy,
        
        -- PAYLOAD INTERFACE
        payload_incomming   => payload_incomming,
        payload_length      => payload_length,     
        data                => data,
        data_valid          => data_valid,
        transmit_busy       => transmit_busy
    );

    -- REPLACE ALL BY A STATE MACHINE

    check_error_code : process(packet_processed, error_code)
    begin
        if packet_processed = '1' or
            -- RECEIVED PACKET CORRECT 
            return_flag <= '1';
            return_packet <= x"00";
        elsif error_code /= '000' then
            -- RECEIVED PACKET WRONG 
            return_flag <= '1';
            return_packet <= '00000' & error_code;
        else
            return_flag <= '0';
            return_packet <= x"00";
        end if;
    end process;

    get_status : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                return_process <= '0';
                return_packet <= x"00";
            else
                if return_flag = '1' and return_process = '0' then
                    return_process <= '1';
                end if;
            end if;
        end if;
    end process;

end architecture;