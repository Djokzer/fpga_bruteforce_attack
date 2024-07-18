library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;

entity tx_packet_pipeline is
    generic (
        NUMBER_OF_QUADCORES : integer := 1
    );
    port (
        -- GENERAL
        clk   : in std_logic;
        reset : in std_logic;
        
        -- UART TX
        tx_valid            : out  std_logic;
		tx_data             : out  std_logic_vector(7 downto 0);
		tx_busy             : in std_logic;

        -- RX PIPELINE INTERFACE
        packet_processed    : in std_logic;
        error_code          : in std_logic_vector(2 downto 0);

        -- BCRYPT CRACKER INTERFACE
        -- STATUS INTERFACE
        crack_count_index   : out std_logic_vector(7 downto 0);
        crack_count         : in std_logic_vector (31 downto 0);
        -- PWD FOUND INTERFACE
        done                : in std_logic;
        success             : in std_logic;
        dout_we             : in std_logic;
        dout                : in std_logic_vector (31 downto 0)
    );
end entity tx_packet_pipeline;

architecture rtl of tx_packet_pipeline is

    -- Packet transmitter
    signal payload_incomming   : std_logic;
    signal payload_length      : std_logic_vector(7 downto 0);     
    signal data                : std_logic_vector(7 downto 0);
    signal data_valid          : std_logic;
    signal transmit_busy       : std_logic;
    
    --------------------- PACKET RETURN SIGNALS -------------------------
    -- STATE MACHINE
    type states_t is (
        S_RESET,
        WAIT_FOR_RETURN,
		WAIT_FOR_READY, 
		SEND_CTRL, SEND_DATA
    );
    signal current_state : states_t := S_RESET;
    signal next_state    : states_t := S_RESET;

	signal return_packet       : std_logic_vector(7 downto 0);
	signal return_buff         : std_logic_vector(7 downto 0);
	signal return_we           : std_logic;
    
    signal return_valid        : std_logic;
    ---------------------------------------------------------------------
    --------------------- STATUS RETURN SIGNALS -------------------------
    -- CRACK COUNT BUFFER
    type data_32_buffer is array (0 to NUMBER_OF_QUADCORES-1) of std_logic_vector(31 downto 0);
    signal crack_count_buffer   : data_32_buffer := (others => (others => '0'));  -- Default initialization
    signal quadcore_count       : integer := 0;
    signal quadcore_count_en    : std_logic := '0'; 
    signal quadcore_count_load  : std_logic := '0'; 
    signal quadcore_count_in    : integer := 0;

    -- STATE MACHINE STATUS
    type states_stat_t is (
        S_RESET,
        RESTART,
        FILL_BUFFER,
        WAIT_FOR_READY,
        SEND_CTRL, SEND_DATA
    );
    signal current_state_stat : states_stat_t := S_RESET;
    signal next_state_stat    : states_stat_t := S_RESET;

    -- COUNTERS SIGNALS FOR DATA OUT
    signal data_0_count       : integer := 0;
    signal data_0_count_en    : std_logic := '0'; 
    signal data_0_count_load  : std_logic := '0'; 
    signal data_0_count_in    : integer := 0;
    signal data_1_count       : integer := 0;
    signal data_1_count_en    : std_logic := '0'; 
    signal data_1_count_load  : std_logic := '0'; 
    signal data_1_count_in    : integer := 0;

    signal status_valid        : std_logic;
    ---------------------------------------------------------------------
    -------------------- PASSWORD RETURN SIGNALS -------------------------
    -- STATE MACHINE PWD
    type states_pwd_t is (
        S_RESET,
        WAIT_FOR_SUCCESS,
        GET_PASSWORD, 
        WAIT_FOR_READY,
        SEND_CTRL, SEND_DATA
    );
    signal current_state_pwd : states_pwd_t := S_RESET;
    signal next_state_pwd    : states_pwd_t := S_RESET;

    signal pwd_valid        : std_logic;
    ---------------------------------------------------------------------
    --------------------- GLOBAL CONTROL LOGIC -------------------------
    signal return_rts : std_logic := '0';
    signal select_return : std_logic := '0';
    signal status_rts : std_logic := '0';
    signal select_status : std_logic := '0';
    signal pwd_rts : std_logic := '0';
    signal select_pwd : std_logic := '0';
    ---------------------------------------------------------------------
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

    --------------------- PACKET RETURN LOGIC -------------------------
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

	fsm_ctrl : process(current_state, packet_processed, error_code, select_return)
	begin
		-- Defaults
		next_state <= current_state;
		return_packet <= x"FF";
		return_we <= '0';
        return_valid <= '0';
        return_rts <= '0';

		case current_state is
			when S_RESET =>
				next_state <= WAIT_FOR_RETURN;
			when WAIT_FOR_RETURN =>
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
                return_rts <= '1';
				if select_return = '1' then
					next_state <= SEND_CTRL;
				end if;
			when SEND_CTRL =>
                -- WAIT ONE CYCLE FOR CTRL SETUP
                return_rts <= '1';
				next_state <= SEND_DATA;
			when SEND_DATA =>
                return_rts <= '1';
                return_valid <= '1';
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
    ---------------------------------------------------------------------
    --------------------- STATUS RETURN LOGIC -------------------------
    -- COUNT TO GET EACH QUADCORE
    quadcore_counter : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                quadcore_count <= 0;
            else
                if quadcore_count_load = '1' then
                    quadcore_count <= quadcore_count_in;
                elsif quadcore_count_en = '1' then
                    quadcore_count <= quadcore_count + 1;
                end if;
            end if;
        end if;
    end process;
    crack_count_index <= std_logic_vector(to_unsigned(quadcore_count, crack_count_index'length));   -- ADDRESS QUADCORE

    -- STORE CRACK COUNT IN THE BUFFER
    store_crack_count : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                crack_count_buffer <= (others => (others => '0'));  -- Default initialization
            else
                crack_count_buffer(quadcore_count) <= crack_count;
            end if;
        end if;
    end process;

    -- DATA OUT COUNTER 0
    data_out_counter_0 : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                data_0_count <= 0;
            else
                if data_0_count_load = '1' then
                    data_0_count <= data_0_count_in;
                elsif data_0_count_en = '1' then
                    data_0_count <= data_0_count + 1;
                end if;
            end if;
        end if;
    end process;

    -- DATA OUT COUNTER 1
    data_out_counter_1 : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                data_1_count <= 0;
            else
                if data_1_count_load = '1' then
                    data_1_count <= data_1_count_in;
                elsif data_1_count_en = '1' then
                    data_1_count <= data_1_count + 1;
                end if;
            end if;
        end if;
    end process;

    -- FSM STATUS
    -- FSM UPDATE
    fsm_state_stat : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                current_state_stat <= S_RESET;
            else
                current_state_stat <= next_state_stat;
            end if; -- rst
        end if; -- clk
    end process;

    -- FSM LOGIC
    fsm_ctrl_stat : process(current_state_stat, select_status, data_0_count, data_1_count, quadcore_count)
    begin
        -- Defaults
        next_state_stat <= current_state_stat;
        quadcore_count_load <= '0';
        quadcore_count_in <= 0;
        quadcore_count_en <= '0';
        status_rts <= '0';
        data_0_count_en <= '0';
        data_0_count_load <= '0';
        data_0_count_in <= 0;
        data_1_count_en <= '0';
        data_1_count_load <= '0';
        data_1_count_in <= 0;
        status_valid <= '0';

        case current_state_stat is
            when S_RESET =>
                next_state_stat <= RESTART;
            when RESTART =>
                -- RESTART COUNTER
                quadcore_count_load <= '1';
                quadcore_count_in <= 0;
                next_state_stat <= FILL_BUFFER;
            when FILL_BUFFER =>
                -- ENABLE COUNTER TO FILL THE BUFFER
                quadcore_count_en <= '1';
                if quadcore_count = NUMBER_OF_QUADCORES-1 then
                    quadcore_count_en <= '0'; -- disable counter to avoid overflow
                    next_state_stat <= WAIT_FOR_READY;
                end if;
            when WAIT_FOR_READY =>
                status_rts <= '1';
                if select_status = '1' then
                    next_state_stat <= SEND_CTRL;
                end if;
			when SEND_CTRL =>
                status_rts <= '1';
                -- INIT COUNTERS FOR DATA OUT
                data_0_count_load <= '1';
                data_0_count_in <= 0;
                data_1_count_load <= '1';
                data_1_count_in <= 0;
                -- NEXT STATE
				next_state_stat <= SEND_DATA;
            when SEND_DATA =>
                status_rts <= '1';
                status_valid <= '1';
                -- ENABLE 8 BIT INDEX COUNTER OF 32 BITS DATA
                data_0_count_en <= '1';
                -- IF ALL 32 BITS HAVE BEEN TRANSMITTED
                if data_0_count = 3 then
                    -- IF ALL BUFFER HAVE BEEN TRANSMITTED
                    if data_1_count = NUMBER_OF_QUADCORES-1 then
                        data_0_count_en <= '0';
                        next_state_stat <= RESTART;
                    else
                        -- ENABLE BUFFER INDEX COUNTER
                        data_1_count_en <= '1';
                        -- RESET 8 BIT INDEX COUNTER
                        data_0_count_load <= '1';
                        data_0_count_in <= 0;
                    end if;
                end if;
        end case;
    end process;
    --------------------------------------------------------------------
    -------------------- PASSWORD RETURN LOGIC -------------------------
    -- FSM PASSWORD
    -- FSM UPDATE
    fsm_state_pwd : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                current_state_pwd <= S_RESET;
            else
                current_state_pwd <= next_state_pwd;
            end if; -- rst
        end if; -- clk
    end process;

    -- FSM LOGIC
    fsm_ctrl_pwd : process(current_state_pwd)
	begin
        -- Defaults
        next_state_pwd <= current_state_pwd;

        case current_state_pwd is
            when S_RESET =>
                next_state_pwd <= WAIT_FOR_SUCCESS;
            when WAIT_FOR_SUCCESS =>
            when GET_PASSWORD =>
            when WAIT_FOR_READY =>
            when SEND_CTRL =>
            when SEND_DATA =>
        end case;
    end process;
    --------------------------------------------------------------------
    --------------------- GLOBAL CONTROL LOGIC -------------------------
    output_ctrl : process(return_rts, status_rts, pwd_rts, return_valid, status_valid, pwd_valid, tx_busy, crack_count_buffer, data_0_count, data_1_count)
    begin
        -- DEFAULTS
        select_pwd <= '0';
        select_return <= '0';
        select_status <= '0';
        payload_incomming <= '0';
        payload_length <= x"E7";
        data <= x"E7"; 
        data_valid <= '0';

        -- SELECT WHETHER OUTPUT RETURN, STATUS OR PASSWORD
        if pwd_rts = '1' and tx_busy = '0' then
            select_pwd <= '1';
            data <= x"42";
        elsif return_rts = '1' and tx_busy = '0'  then
            payload_incomming <= '1';
            payload_length <= x"01";
            data <= return_buff;
            data_valid <= return_valid;
            select_return <= '1';
        elsif status_rts = '1' and tx_busy = '0'  then
            payload_incomming <= '1';
            payload_length <= std_logic_vector(to_unsigned(NUMBER_OF_QUADCORES * 4, payload_length'length));
            data <= crack_count_buffer(data_1_count)(((4-data_0_count) * 8) - 1 downto ((3-data_0_count) * 8));
            data_valid <= status_valid;
            select_status <= '1';
        end if;
    end process;
    --------------------------------------------------------------------
end architecture;