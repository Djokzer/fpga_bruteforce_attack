library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;

entity rx_packet_process is
    port (
        -- GENERAL
        clk                 : in std_logic;
        reset               : in std_logic;
        
        -- PACKET RECEIVER
        packet_data         : in std_logic_vector(7 downto 0);
		packet_data_valid   : in std_logic;
		packet_incomming    : in std_logic;
		packet_valid        : in std_logic;

        -- LEDS OUTPUT
        leds_out            : out std_logic_vector(7 downto 0);
        out_en              : out std_logic
    );
end entity rx_packet_process;

architecture rtl of rx_packet_process is

    -- PACKET DATA BUFFER
    constant PACKET_DATA_SIZE : integer := 1;
    type data_buffer is array (0 to PACKET_DATA_SIZE-1) of std_logic_vector(7 downto 0);
    signal packet_data_buffer : data_buffer;
    
    -- PACKET DATA COUNTER
    signal packet_data_counter : integer := 0;
    signal packet_data_rst : std_logic := '0';
    
begin
    
    -- PACKET DATA COUNTER
    counter_proc : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                packet_data_counter <= 0;
            else
                if packet_incomming = '1' then
                    packet_data_counter <= 0;
                elsif packet_data_valid = '1' then
                    if packet_data_counter < PACKET_DATA_SIZE then
                        packet_data_counter <= packet_data_counter + 1;
                    else
                        packet_data_counter <= 0;
                    end if;
                end if;
            end if;
        end if;
        
    end process;
    
    -- PACKET DATA BUFFER
    packet_buffer_proc : process(clk)
    begin
     if rising_edge(clk) then
            if reset = '1' then
            else
                if packet_data_valid = '1' then
                    packet_data_buffer(packet_data_counter) <= packet_data;
                end if;
            end if;
        end if;
    end process;
    
    -- MEMORIZE OUTPUT DATA
    mem_data_proc : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                leds_out <= x"00";
            else
                if packet_valid = '1' then
                    out_en <= '1';
                    leds_out <= packet_data_buffer(0);
                else
                    out_en <= '0';
                end if;
            end if;
        end if;
    end process;
    
    
end architecture;