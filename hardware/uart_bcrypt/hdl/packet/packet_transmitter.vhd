entity packet_transmitter is
    port (
        -- GENERAL
        clk                 : in std_logic;
        reset               : in std_logic;

        -- UART TX
        tx_valid            : out  std_logic;
		tx_data             : out  std_logic_vector(7 downto 0);
		tx_busy             : in std_logic;
        
        -- PAYLOAD INTERFACE
        payload_incomming   : in std_logic;
        payload_length      : in std_logic_vector(7 downto 0);     
        data                : in std_logic_vector(7 downto 0);
        data_valid          : in std_logic;
        transmit_busy       : out std_logic
    );
end entity packet_transmitter;

architecture rtl of packet_transmitter is

    -- PACKET DATA BUFFER
    constant PAYLOAD_DATA_SIZE : integer := 252; -- Packer Max Size : 256, Control Bytes : 4
    type data_buffer is array (0 to PAYLOAD_DATA_SIZE-1) of std_logic_vector(7 downto 0);
    signal payload_buffer : data_buffer;
    
    -- STATE MACHINE
    type states_t is (
        RESET,
        WAIT_FOR_DATA, GET_DATA,
        COBS_ENCODE,
        TRANSMIT
	);
    signal current_state : states_t := RESET;
    signal next_state    : states_t := RESET;

    -- COUNTER
    signal counter : integer := 0;
    signal counter_init : std_logic := '0';

    -- CRC
    signal crc_in : std_logic_vector(7 downto 0) := x"00";
    signal crc_data : std_logic_vector(7 downto 0) := x"00";
	signal crc_out : std_logic_vector(7 downto 0):= x"00";
begin

    -- COUNTERS
	payload_counter : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				counter <= 0;
			else        
				if counter_init = '1' then
					-- INIT PAYLOAD COUNTER
                    counter <= 0;
				elsif data_valid = '1' then
                    -- INCREMENT PAYLOAD COUNTER
                    counter <= counter + 1;
					end if;
				end if;           
			end if;
		end if;
	end process;

    -- FSM
    fsm_state : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_state <= RESET;
            else
                current_state <= next_state;
            end if; -- rst
        end if; -- clk
    end process fsm_state;
    
    fsm_ctrl : process (current_state, payload_incomming, counter, data, data_valid)
    begin
        -- Defaults
        next_state <= current_state;
        counter_init <= '0';
        payload_buffer(counter) <= payload_buffer(counter);
        crc_in <= x"00";

        -- FSM Cases
        case current_state is
            when RESET =>
                next_state <= WAIT_FOR_DATA;
            when WAIT_FOR_DATA =>
                if payload_incomming = '1' then
                    counter_init <= '1';
                    next_state <= GET_DATA;
                end if;
            when GET_DATA =>
                if counter >= payload_length then
                    next_state <= COBS_ENCODE;
                else
                    if data_valid = '1' then
                        if counter = 0 then
                            crc_in <= x"00";
                        else
                            crc_in <= crc_out;
                        end if;
                        crc_data <= data;
                        payload_buffer(counter) <= data;
                    end if;
                end if;
            when COBS_ENCODE =>
            when TRANSMIT =>
        end case;
    end process;

    -- CRC
    crc_m: entity work.crc
    port map (
        crcIn   => crc_in,
        data 	=> crc_data,
        crcOut	=> crc_out
    );

end architecture;