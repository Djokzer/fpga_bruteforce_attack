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

    -- Packet transmitter
    signal payload_incomming   : std_logic;
    signal payload_length      : std_logic_vector(7 downto 0);     
    signal data                : std_logic_vector(7 downto 0);
    signal data_valid          : std_logic;
    signal transmit_busy       : std_logic;

    -- STATE MACHINE
    type states_t is (
        S_RESET,
        WAIT_FOR_RETURN,
		WAIT_FOR_READY, 
		SEND_CTRL, SEND_DATA
    );
    signal current_state : states_t := S_RESET;
    signal next_state    : states_t := S_RESET;

	-- RETURN LOGIC
	signal return_packet       : std_logic_vector(7 downto 0);
	signal return_buff         : std_logic_vector(7 downto 0);
	signal return_we           : std_logic;

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

    -- FSM 
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

	fsm_ctrl : process(current_state, packet_processed, error_code, transmit_busy)
	begin
		-- Defaults
		next_state <= current_state;
		return_packet <= x"FF";
		return_we <= '0';
		payload_length <= x"00";
		payload_incomming <= '0';
        data_valid <= '0';

		case current_state is
			when S_RESET =>
				next_state <= WAIT_FOR_RETURN;
				-- DEFAULT VALUES
				payload_length <= x"00";
			when WAIT_FOR_RETURN =>
                -- DEFAULT VALUES
				payload_length <= x"00";
				-- WAIT FOR STATUS RETURN FROM RX
				if packet_processed = '1' then
					return_packet <= x"00";
					return_we <= '1';
					next_state <= WAIT_FOR_READY;
				elsif error_code /= "000" then
					return_packet <= "00000" & error_code;
					return_we <= '1';
					next_state <= WAIT_FOR_READY;
				end if;
			when WAIT_FOR_READY =>
				if transmit_busy = '0' then
					next_state <= SEND_CTRL;
				end if;
			when SEND_CTRL =>
				payload_incomming <= '1';
				payload_length <= x"01";
				next_state <= SEND_DATA;
			when SEND_DATA =>
			    payload_length <= x"01";
                data_valid <= '1';
                next_state <= WAIT_FOR_RETURN;
		end case ;
	end process;

    -- RETURN DATA
    ret_data: process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                return_buff <= x"FF";
            else
                if return_we = '1' then
                    return_buff <= return_packet;
                end if;
            end if; -- rst
        end if; -- clk
    end process;
    
    data <= return_buff;


end architecture;