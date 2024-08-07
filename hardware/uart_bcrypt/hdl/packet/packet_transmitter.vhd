library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;

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
    
    -- PACKET DATA BUFFER (2 write channel)
    constant PACKET_DATA_SIZE : integer := 256; -- Packer Max Size : 256, Control Bytes : 4
    constant PAYLOAD_BASE_INDEX : integer := 2;
    type data_buffer is array (0 to PACKET_DATA_SIZE-1) of std_logic_vector(7 downto 0);
    signal packet_buffer : data_buffer := (others => (others => '0'));  -- Default initialization
    
    signal buffer_we_0 : std_logic := '0';
    signal buffer_wr_0_i : integer := 0;
    signal buffer_wr_0_data : std_logic_vector(7 downto 0) := x"00";
    
    signal buffer_we_1 : std_logic := '0';
    signal buffer_wr_1_i : integer := 0;
    signal buffer_wr_1_data : std_logic_vector(7 downto 0) := x"00";
        
    -- STATE MACHINE
    type states_t is (
        S_RESET,
        WAIT_FOR_DATA, GET_DATA, WAIT_BUFFER_WRITE,
        COBS_ENCODE, WAIT_CYCLE,
        TRANSMIT
	);
    signal current_state : states_t := S_RESET;
    signal next_state    : states_t := S_RESET;

    -- COUNTER
    signal counter : integer := 0;
    signal counter_init : std_logic := '0';
    signal counter_init_val : integer := 0;
    signal counter_enable : std_logic := '0';
    signal counter_up : std_logic := '0';
    signal c_counter : integer := 0;
    signal c_counter_init : std_logic := '0';
    signal c_counter_enable : std_logic := '0';

    -- CRC
    signal crc_in : std_logic_vector(7 downto 0) := x"00";
    signal crc_data : std_logic_vector(7 downto 0) := x"00";
	signal crc_out : std_logic_vector(7 downto 0):= x"00";
	signal crc_out_reg : std_logic_vector(7 downto 0):= x"00";
    signal payload_crc : std_logic_vector(7 downto 0) := x"00";
    
    -- UART TRANSMIT
    signal transmit_enable : std_logic := '0';
    signal transmit_finished : std_logic := '0';
    signal tx_enable : std_logic := '0';
    
    signal payload_length_reg : std_logic_vector(7 downto 0) := x"00";     
    
    -- Intermediate signals
    signal counter_reg : integer := 0;
    signal buffer_wr_0_i_reg : integer := 0;
    signal buffer_we_0_reg : std_logic := '0';
    signal buffer_wr_0_data_reg : std_logic_vector(7 downto 0) := x"00";
    signal counter_enable_d : std_logic := '0';
    signal counter_up_d : std_logic := '0';
    
begin

    -- COUNTERS with additional pipelining
    payload_counter : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                counter_reg <= 0;
                counter_enable_d <= '0';
                counter_up_d <= '0';
            else        
                counter_enable_d <= counter_enable;
                counter_up_d <= counter_up;
                if counter_init = '1' then
                    counter_reg <= counter_init_val;
                elsif counter_enable_d = '1' then
                    if counter_up_d = '1' then
                        counter_reg <= counter_reg + 1;
                    else
                        if counter_reg > 0 then
                            counter_reg <= counter_reg - 1;
                        end if;
                    end if;
                end if;           
            end if;
        end if;
    end process;
    
    cobs_counter : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				c_counter <= 0;
			else        
				if c_counter_init = '1' then
					-- INIT PAYLOAD COUNTER
                    c_counter <= 1;
				elsif c_counter_enable = '1' then
                    -- INCREMENT PAYLOAD COUNTER
                    c_counter <= c_counter + 1;
				end if;           
			end if;
		end if;
	end process;

    -- Pipelined version of the FSM
    fsm_ctrl : process (current_state, payload_incomming, counter_reg, data, data_valid, payload_length, crc_out_reg, transmit_finished, tx_busy, tx_enable, packet_buffer, c_counter, payload_length_reg)
    begin
        -- Defaults
        next_state <= current_state;
        counter_init <= '0';
        counter_init_val <= 0;
        counter_enable <= '0';
        counter_up <= '0';
        c_counter_init <= '1';
        c_counter_enable <= '0';
        crc_data <= x"00";
        transmit_busy <= '0';
        transmit_enable <= '0';
        buffer_we_0 <= '0';
        buffer_wr_0_i <= 0;
        buffer_wr_0_data <= x"00";
        buffer_we_1 <= '0';
        buffer_wr_1_i <= 0;
        buffer_wr_1_data <= x"00";
        
        -- FSM Cases
        case current_state is
            when S_RESET =>
                next_state <= WAIT_FOR_DATA;
            when WAIT_FOR_DATA =>
                if payload_incomming = '1' then
                    -- INIT PACKET BUFFER HEADER
                    buffer_we_0 <= '1';
                    buffer_wr_0_i <= 0;
                    buffer_wr_0_data <= x"00";
                    buffer_we_1 <= '1';
                    buffer_wr_1_i <= 1;
                    buffer_wr_1_data <= payload_length;
                    -- INIT COUNTER
                    counter_init <= '1';
                    counter_init_val <= 0;
                    counter_enable <= '1';
                    counter_up <= '1';
                    -- NEXT STATE
                    next_state <= GET_DATA;
                end if;
            when GET_DATA =>
                if counter_reg = to_integer(unsigned(payload_length_reg)) then
                    counter_enable <= '1';
                    counter_up <= '1';
                elsif counter_reg > to_integer(unsigned(payload_length_reg)) then
                    -- SET NEW COUNTER
                    counter_init <= '1';
                    counter_init_val <= counter_reg + PAYLOAD_BASE_INDEX - 1;
                    -- INIT PACKET BUFFER FOOTER
                    buffer_we_0 <= '1';
                    buffer_wr_0_i <= counter_reg + PAYLOAD_BASE_INDEX - 1;
                    buffer_wr_0_data <= crc_out_reg;
                    buffer_we_1 <= '1';
                    buffer_wr_1_i <= counter_reg + PAYLOAD_BASE_INDEX;
                    buffer_wr_1_data <= x"00";
                    -- NEXT STATE
                    next_state <= WAIT_BUFFER_WRITE;
                else
                    if data_valid = '1' then
                        counter_enable <= '1';
                        counter_up <= '1';
                        crc_data <= data;
                        -- FILL BUFFER WITH DATA
                        buffer_we_0 <= '1';
                        buffer_wr_0_i <= counter_reg + PAYLOAD_BASE_INDEX;
                        buffer_wr_0_data <= data;
                    end if;
                end if;
            when WAIT_BUFFER_WRITE =>
                counter_enable <= '1';
                counter_up <= '0';
                next_state <= COBS_ENCODE;
            when COBS_ENCODE =>
                transmit_busy <= '1';
                counter_enable <= '1';
                counter_up <= '0';
                c_counter_enable <= '1';
                c_counter_init <= '0';
                
                if packet_buffer(counter_reg) = x"00" then
                    buffer_we_0 <= '1';
                    buffer_wr_0_i <= counter_reg;
                    buffer_wr_0_data <= std_logic_vector(to_unsigned(c_counter, packet_buffer(counter_reg)'length));
                    c_counter_init <= '1';
                end if;

                if counter_reg = 0 then
                    next_state <= WAIT_CYCLE;
                end if;
            when WAIT_CYCLE =>
                transmit_busy <= '1';
                next_state <= TRANSMIT;
            when TRANSMIT =>
                counter_up <= '1';
                transmit_enable <= '1';
                transmit_busy <= '1';
                
                if (not tx_busy and tx_enable) = '1' then
                    counter_enable <= '1';
                end if;
                
                if transmit_finished = '1' then
                    next_state <= WAIT_FOR_DATA;
                end if;
        end case;
    end process;

    -- Buffer write index registered
    pckt_buff_write : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                packet_buffer <= (others => (others => '0'));  -- Default initialization
                buffer_wr_0_i_reg <= 0;
                buffer_we_0_reg <= '0';
                buffer_wr_0_data_reg <= x"00";
            else
                if buffer_we_0_reg = '1' then
                    packet_buffer(buffer_wr_0_i_reg) <= buffer_wr_0_data_reg;
                end if;
                
                if buffer_we_1 = '1' then
                    packet_buffer(buffer_wr_1_i) <= buffer_wr_1_data;
                end if;
                
                -- Register buffer port 0 write
                buffer_wr_0_i_reg <= buffer_wr_0_i;
                buffer_we_0_reg <= buffer_we_0;
                buffer_wr_0_data_reg <= buffer_wr_0_data;
            end if; -- rst
        end if; -- clk
    end process;
    
    payload_length_reg <= packet_buffer(1);

    -- FSM State
    fsm_state : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                current_state <= S_RESET;
            else
                current_state <= next_state;
            end if; -- rst
        end if; -- clk
    end process fsm_state;

    -- CRC
    crc_m: entity work.crc
    port map (
        crcIn   => crc_in,
        data    => crc_data,
        crcOut  => crc_out
    );
    crc_in <= crc_out_reg;
    
    crc_update : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                crc_out_reg <= x"00";
            else
                if transmit_finished = '1' then
                    crc_out_reg <= x"00";
                elsif data_valid = '1' and counter_reg < to_integer(unsigned(payload_length_reg)) then
                    crc_out_reg <= crc_out;
                end if;
            end if; -- rst
        end if; -- clk
    end process;
    
    -- UART Transmit
    tx_valid <= not tx_busy and tx_enable;
        
    uart_process : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                tx_data  <= x"00";
                tx_enable <= '0';
                transmit_finished <= '0';
            else
                transmit_finished <= '0';
                if transmit_enable = '1' then
                    tx_enable <= '1';
                    tx_data  <= packet_buffer(counter_reg);
                    if counter_reg = (to_integer(unsigned(packet_buffer(1))) + PAYLOAD_BASE_INDEX + 2) then
                        transmit_finished <= '1';
                    end if;
                else
                    tx_enable <= '0';
                end if;
            end if; -- rst
        end if; -- clk
    end process;

end architecture;