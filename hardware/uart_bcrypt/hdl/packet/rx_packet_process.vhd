library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.pkg_bcrypt.all;
use work.rzi_helper.all;

library work;

entity rx_packet_process is
    generic (
        NUMBER_OF_QUADCORES : integer := 1
    );
    port (
        -- GENERAL
        clk                 : in std_logic;
        reset               : in std_logic;
        
        -- PACKET RECEIVER
        packet_data         : in std_logic_vector(7 downto 0);
		packet_data_valid   : in std_logic;
		packet_incomming    : in std_logic;
		packet_valid        : in std_logic;

        -- QUADCORE OUTPUT
        quadcore_id         : out std_logic_vector(7 downto 0);
        crack_max           : out std_logic_vector(31 downto 0);
        salt                : out std_logic_vector(SALT_LENGTH-1 downto 0);
        hash                : out std_logic_vector(HASH_LENGTH-1 downto 0);
        pwd_count_init      : out std_logic_vector(PWD_LENGTH*CHARSET_OF_BIT-1 downto 0);
        pwd_len_init        : out std_logic_vector(PWD_BITLEN - 1 downto 0);
        
        -- RETURN
        output_en           : out std_logic;
        error_code          : out std_logic_vector(1 downto 0)
          
    );
end entity rx_packet_process;

architecture rtl of rx_packet_process is

    -- PACKET DATA BUFFER
    constant PACKET_DATA_SIZE : integer := 99;
    type data_buffer is array (0 to PACKET_DATA_SIZE-1) of std_logic_vector(7 downto 0);
    signal packet_data_buffer : data_buffer;
    
    -- PACKET DATA COUNTER
    signal packet_data_counter : integer := 0;
    signal packet_data_rst : std_logic := '0';
    
    -- ERROR
    signal packet_too_big : std_logic := '0';
    
    -- FUNCTION
    function concat_array_to_slv(data_array : data_buffer; size : integer; index : integer) return std_logic_vector is
        variable slv : std_logic_vector((8 * size) - 1 downto 0);
        variable pos : integer := 0;
    begin
        for i in index to index+size loop
            slv((pos * 8) + 7 downto pos * 8) := data_array(i);  
            pos := pos + 1;
        end loop;
        return slv;
    end function; 

begin
    -- PACKET DATA COUNTER
    counter_proc : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                packet_data_counter <= 0;
                packet_too_big <= '0';
            else
                if packet_incomming = '0' then
                    packet_data_counter <= 0;
                    packet_too_big <= '0';
                elsif packet_data_valid = '1' then
                    if packet_data_counter < PACKET_DATA_SIZE then
                        packet_data_counter <= packet_data_counter + 1;
                    else
                        -- SHOULDN'T HAPPEN TOO MUCH DATA
                        packet_data_counter <= 0;
                        packet_too_big <= '1';
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

    -- CHECK ERROR AND OUTPUT ENABLE
    error_check_proc : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                output_en <= '0';
                error_code <= "00";
            else
                if packet_valid = '1' then
                    -- IF PACKET SIZE TOO BIG
                    if packet_too_big = '1' then
                        output_en <= '0';
                        error_code <= "01";
                    -- IF QUADCORE ID IS NOT IN RANGE
                    elsif to_integer(unsigned(packet_data_buffer(0))) >= NUMBER_OF_QUADCORES then
                        output_en <= '0';
                        error_code <= "10";
                    else
                        error_code <= "00";
                        output_en <= '1';
                    end if;
                else
                    error_code <= "00";
                    output_en <= '0';
                end if;
            end if;
        end if;
    end process;
    
    -- OUTPUT
    quadcore_id         <= packet_data_buffer(0);
    crack_max           <= concat_array_to_slv(packet_data_buffer, 4, 1);
    salt                <= concat_array_to_slv(packet_data_buffer, 16, 5);
    hash                <= concat_array_to_slv(packet_data_buffer, 23, 21);
    pwd_count_init      <= concat_array_to_slv(packet_data_buffer, 54, 44);
    pwd_len_init        <= packet_data_buffer(98);
    
    
end architecture;