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
    type states_ret_t is (
        S_RESET,
        WAIT_FOR_RETURN,
		WAIT_FOR_READY, 
		SEND_CTRL, SEND_DATA
    );
    signal current_state_ret : states_ret_t := S_RESET;
    signal next_state_ret    : states_ret_t := S_RESET;

	signal return_packet       : std_logic_vector(7 downto 0);
	signal return_buff         : std_logic_vector(7 downto 0);
	signal return_we           : std_logic;
    
    signal return_valid        : std_logic;
    ---------------------------------------------------------------------
    --------------------- STATUS RETURN SIGNALS -------------------------
    -- CRACK COUNT BUFFER
    type crack_count_32_buffer is array (0 to NUMBER_OF_QUADCORES-1) of std_logic_vector(31 downto 0);
    signal crack_count_buffer   : crack_count_32_buffer := (others => (others => '0'));  -- Default initialization
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
    signal stat_0_count       : integer := 0;
    signal stat_0_count_en    : std_logic := '0'; 
    signal stat_0_count_load  : std_logic := '0'; 
    signal stat_0_count_in    : integer := 0;
    signal stat_1_count       : integer := 0;
    signal stat_1_count_en    : std_logic := '0'; 
    signal stat_1_count_load  : std_logic := '0'; 
    signal stat_1_count_in    : integer := 0;

    signal status_valid        : std_logic;
    ---------------------------------------------------------------------
    -------------------- PASSWORD RETURN SIGNALS ------------------------
    -- CRACK COUNT BUFFER
    constant PWD_32_SIZE : integer := 18;
    type pwd_32_buffer is array (0 to PWD_32_SIZE-1) of std_logic_vector(31 downto 0);
    signal pwd_buffer   : pwd_32_buffer := (others => (others => '0'));  -- Default initialization
    signal pwd_count       : integer := 0;
    signal pwd_count_en    : std_logic := '0'; 
    signal pwd_count_load  : std_logic := '0'; 
    signal pwd_count_in    : integer := 0;

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

    -- COUNTERS SIGNALS FOR DATA OUT
    signal pwd_0_count       : integer := 0;
    signal pwd_0_count_en    : std_logic := '0'; 
    signal pwd_0_count_load  : std_logic := '0'; 
    signal pwd_0_count_in    : integer := 0;
    signal pwd_1_count       : integer := 0;
    signal pwd_1_count_en    : std_logic := '0'; 
    signal pwd_1_count_load  : std_logic := '0'; 
    signal pwd_1_count_in    : integer := 0;

    signal pwd_valid        : std_logic;
    ---------------------------------------------------------------------
    --------------------- GLOBAL CONTROL LOGIC -------------------------
    -- STATE MACHINE GLOBAL
    type states_g_t is (
        S_RESET,
        WAIT_FOR_READY,
        SEND_TYPE,
        SEND_PWD, SEND_RETURN, SEND_STATUS
    );
    signal current_state_global : states_g_t := S_RESET;
    signal next_state_global    : states_g_t := S_RESET;
    
    signal return_rts : std_logic := '0';
    signal select_return : std_logic := '0';
    signal return_finish : std_logic := '0'; 
    signal status_rts : std_logic := '0';
    signal select_status : std_logic := '0';
    signal status_finish : std_logic := '0'; 
    signal pwd_rts : std_logic := '0';
    signal select_pwd : std_logic := '0';
    signal pwd_finish : std_logic := '0'; 
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
    fsm_state_ret : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                current_state_ret <= S_RESET;
            else
                current_state_ret <= next_state_ret;
            end if; -- rst
        end if; -- clk
    end process;

	fsm_ctrl_ret : process(current_state_ret, packet_processed, error_code, select_return)
	begin
		-- Defaults
		next_state_ret <= current_state_ret;
		return_packet <= x"FF";
		return_we <= '0';
        return_valid <= '0';
        return_rts <= '0';
        return_finish <= '0';

		case current_state_ret is
			when S_RESET =>
				next_state_ret <= WAIT_FOR_RETURN;
			when WAIT_FOR_RETURN =>
				-- WAIT FOR STATUS RETURN FROM RX
				if packet_processed = '1' then
					return_packet <= x"00";
					return_we <= '1';
					next_state_ret <= WAIT_FOR_READY;
				elsif error_code /= "000" then
					return_packet <= "00000" & error_code;
					return_we <= '1';
					next_state_ret <= WAIT_FOR_READY;
				end if;
			when WAIT_FOR_READY =>
                return_rts <= '1';
				if select_return = '1' then
					next_state_ret <= SEND_CTRL;
				end if;
			when SEND_CTRL =>
                -- WAIT ONE CYCLE FOR CTRL SETUP
                return_rts <= '1';
                return_valid <= '1';
				next_state_ret <= SEND_DATA;
			when SEND_DATA =>
                return_rts <= '1';
                return_valid <= '1';
                return_finish <= '1';
                next_state_ret <= WAIT_FOR_RETURN;
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
    stat_out_counter_0 : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                stat_0_count <= 0;
            else
                if stat_0_count_load = '1' then
                    stat_0_count <= stat_0_count_in;
                elsif stat_0_count_en = '1' then
                    stat_0_count <= stat_0_count + 1;
                end if;
            end if;
        end if;
    end process;

    -- DATA OUT COUNTER 1
    stat_out_counter_1 : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                stat_1_count <= 0;
            else
                if stat_1_count_load = '1' then
                    stat_1_count <= stat_1_count_in;
                elsif stat_1_count_en = '1' then
                    stat_1_count <= stat_1_count + 1;
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
    fsm_ctrl_stat : process(current_state_stat, select_status, stat_0_count, stat_1_count, quadcore_count)
    begin
        -- Defaults
        next_state_stat <= current_state_stat;
        quadcore_count_load <= '0';
        quadcore_count_in <= 0;
        quadcore_count_en <= '0';
        status_rts <= '0';
        stat_0_count_en <= '0';
        stat_0_count_load <= '0';
        stat_0_count_in <= 0;
        stat_1_count_en <= '0';
        stat_1_count_load <= '0';
        stat_1_count_in <= 0;
        status_valid <= '0';
        status_finish <= '0';

        case current_state_stat is
            when S_RESET =>
                next_state_stat <= RESTART;
            when RESTART =>
                -- RESTART COUNTER
                quadcore_count_load <= '1';
                quadcore_count_in <= 0;
                next_state_stat <= FILL_BUFFER;
            when FILL_BUFFER =>
                -- INIT COUNTER FOR WAITING
                stat_0_count_load <= '1';
                stat_0_count_in <= 0;
                -- ENABLE COUNTER TO FILL THE BUFFER
                quadcore_count_en <= '1';
                if quadcore_count = NUMBER_OF_QUADCORES-1 then
                    quadcore_count_en <= '0'; -- disable counter to avoid overflow
                    next_state_stat <= WAIT_FOR_READY;
                end if;
            when WAIT_FOR_READY =>
                -- ENABLE COUNTER FOR WAITING
                stat_0_count_en <= '1';
                -- WHEN 1 SECOND PASSED
                if stat_0_count >= 100000000 then
                    status_rts <= '1';
                end if;
                if select_status = '1' then
                    next_state_stat <= SEND_CTRL;
                end if;
			when SEND_CTRL =>
                status_rts <= '1';
                -- INIT COUNTERS FOR DATA OUT
                stat_0_count_load <= '1';
                stat_0_count_in <= 0;
                stat_1_count_load <= '1';
                stat_1_count_in <= 0;
                -- NEXT STATE
				next_state_stat <= SEND_DATA;
            when SEND_DATA =>
                status_rts <= '1';
                status_valid <= '1';
                -- ENABLE 8 BIT INDEX COUNTER OF 32 BITS DATA
                stat_0_count_en <= '1';
                -- IF ALL 32 BITS HAVE BEEN TRANSMITTED
                if stat_0_count = 3 then
                    -- IF ALL BUFFER HAVE BEEN TRANSMITTED
                    if stat_1_count = NUMBER_OF_QUADCORES-1 then
                        stat_0_count_en <= '0';
                        status_finish <= '1';
                        next_state_stat <= RESTART;
                    else
                        -- ENABLE BUFFER INDEX COUNTER
                        stat_1_count_en <= '1';
                        -- RESET 8 BIT INDEX COUNTER
                        stat_0_count_load <= '1';
                        stat_0_count_in <= 0;
                    end if;
                end if;
        end case;
    end process;
    --------------------------------------------------------------------
    -------------------- PASSWORD RETURN LOGIC -------------------------
    -- COUNT TO GET ALL 32 BITS WORD OF PASSWORD
    password_counter : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                pwd_count <= 0;
            else
                if pwd_count_load = '1' then
                    pwd_count <= pwd_count_in;
                elsif pwd_count_en = '1' then
                    pwd_count <= pwd_count + 1;
                end if;
            end if;
        end if;
    end process;

    -- STORE PASSWORD IN THE BUFFER
    store_password : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                pwd_buffer <= (others => (others => '0'));  -- Default initialization
            else
                if pwd_count < PWD_32_SIZE then
                    pwd_buffer(pwd_count) <= dout;
                end if;
            end if;
        end if;
    end process;
    
    -- PWD OUT COUNTER 0
    pwd_out_counter_0 : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                pwd_0_count <= 0;
            else
                if pwd_0_count_load = '1' then
                    pwd_0_count <= pwd_0_count_in;
                elsif pwd_0_count_en = '1' then
                    pwd_0_count <= pwd_0_count + 1;
                end if;
            end if;
        end if;
    end process;

    -- PWD OUT COUNTER 1
    pwd_out_counter_1 : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                pwd_1_count <= 0;
            else
                if pwd_1_count_load = '1' then
                    pwd_1_count <= pwd_1_count_in;
                elsif pwd_1_count_en = '1' then
                    pwd_1_count <= pwd_1_count + 1;
                end if;
            end if;
        end if;
    end process;

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
    fsm_ctrl_pwd : process(current_state_pwd, dout_we, pwd_count, select_pwd, pwd_0_count, pwd_1_count)
	begin
        -- Defaults
        next_state_pwd <= current_state_pwd;
        pwd_count_en <= '0'; 
        pwd_count_load <= '0';
        pwd_count_in <= 0;
        pwd_rts <= '0';
        pwd_0_count_load <= '0';
        pwd_0_count_in <= 0;
        pwd_1_count_load <= '0';
        pwd_1_count_in <= 0;
        pwd_valid <= '0';
        pwd_0_count_en <= '0';
        pwd_1_count_en <= '0';
        pwd_finish <= '0';
        

        case current_state_pwd is
            when S_RESET =>
                next_state_pwd <= WAIT_FOR_SUCCESS;
            when WAIT_FOR_SUCCESS =>
                if dout_we = '1' then
                    pwd_count_load <= '1';
                    pwd_count_in <= 0;
                    next_state_pwd <= GET_PASSWORD;
                end if;
            when GET_PASSWORD =>
                -- ENABLE COUNTER TO FILL THE BUFFER
                pwd_count_en <= '1';
                if pwd_count = PWD_32_SIZE-1 then
                    --pwd_count_en <= '0'; -- disable counter to avoid overflow
                    next_state_pwd <= WAIT_FOR_READY;
                end if;
            when WAIT_FOR_READY =>
                pwd_rts <= '1';
                if select_pwd = '1' then
                    next_state_pwd <= SEND_CTRL;
                end if;
            when SEND_CTRL =>
                pwd_rts <= '1';
                -- INIT COUNTERS FOR DATA OUT
                pwd_0_count_load <= '1';
                pwd_0_count_in <= 0;
                pwd_1_count_load <= '1';
                pwd_1_count_in <= 0;
                -- NEXT STATE
                next_state_pwd <= SEND_DATA;
            when SEND_DATA =>
                pwd_rts <= '1';
                pwd_valid <= '1';
                -- ENABLE 8 BIT INDEX COUNTER OF 32 BITS DATA
                pwd_0_count_en <= '1';
                -- IF ALL 32 BITS HAVE BEEN TRANSMITTED
                if pwd_0_count = 3 then
                    -- IF ALL BUFFER HAVE BEEN TRANSMITTED
                    if pwd_1_count = PWD_32_SIZE-1 then
                        pwd_0_count_en <= '0';
                        pwd_finish <= '1';
                        next_state_pwd <= WAIT_FOR_SUCCESS;
                    else
                        -- ENABLE BUFFER INDEX COUNTER
                        pwd_1_count_en <= '1';
                        -- RESET 8 BIT INDEX COUNTER
                        pwd_0_count_load <= '1';
                        pwd_0_count_in <= 0;
                    end if;
                end if;
        end case;
    end process;
    --------------------------------------------------------------------
    --------------------- GLOBAL CONTROL LOGIC -------------------------
    -- FSM 
    fsm_state_global : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                current_state_global <= S_RESET;
            else
                current_state_global <= next_state_global;
            end if; -- rst
        end if; -- clk
    end process;
    
    output_ctrl : process(current_state_global, return_rts, status_rts, pwd_rts, return_valid, status_valid, pwd_valid, tx_busy, 
    crack_count_buffer, stat_0_count, stat_1_count, return_finish, status_finish, pwd_finish, pwd_0_count, pwd_1_count, pwd_buffer, return_buff)
    begin
        -- DEFAULTS
        next_state_global <= current_state_global;
        select_pwd <= '0';
        select_return <= '0';
        select_status <= '0';
        payload_incomming <= '0';
        payload_length <= x"E7";
        data <= x"E7"; 
        data_valid <= '0';

        case current_state_global is
            when S_RESET =>
                next_state_global <= WAIT_FOR_READY;
            when WAIT_FOR_READY =>
                -- SELECT RETURN OR TYPE BYTE OF OTHER CASES
                if pwd_rts = '1' and tx_busy = '0' then
                    payload_incomming <= '1';
                    payload_length <= std_logic_vector(to_unsigned((PWD_32_SIZE * 4) + 1, payload_length'length));
                    select_pwd <= '1';
                    next_state_global <= SEND_TYPE;
                elsif return_rts = '1' and tx_busy = '0'  then
                    payload_incomming <= '1';
                    payload_length <= x"01";
                    select_return <= '1';
                    next_state_global <= SEND_RETURN;
                elsif status_rts = '1' and tx_busy = '0'  then
                    payload_incomming <= '1';
                    payload_length <= std_logic_vector(to_unsigned((NUMBER_OF_QUADCORES * 4) + 1, payload_length'length));
                    select_status <= '1';
                    next_state_global <= SEND_TYPE;
                end if;
            when SEND_TYPE =>
                -- SELECT WHETHER OUTPUT STATUS OR PASSWORD
                if pwd_rts = '1' then
                    payload_length <= std_logic_vector(to_unsigned((PWD_32_SIZE * 4) + 1, payload_length'length));
                    data <= x"10";
                    data_valid <= '1';
                    next_state_global <= SEND_PWD;
                elsif status_rts = '1' then
                    payload_length <= std_logic_vector(to_unsigned((NUMBER_OF_QUADCORES * 4) + 1, payload_length'length));
                    data <= x"08";
                    data_valid <= '1';
                    next_state_global <= SEND_STATUS;
                end if;
            when SEND_PWD =>
                payload_length <= std_logic_vector(to_unsigned((PWD_32_SIZE * 4) + 1, payload_length'length));
                data <= pwd_buffer(pwd_1_count)(((4-pwd_0_count) * 8) - 1 downto ((3-pwd_0_count) * 8));
                data_valid <= pwd_valid;
                if pwd_finish = '1' then
                    next_state_global <= WAIT_FOR_READY;
                end if;
            when SEND_RETURN =>
                payload_length <= x"01";
                data <= return_buff;
                data_valid <= return_valid;
                if return_finish = '1' then
                    next_state_global <= WAIT_FOR_READY;
                end if;
            when SEND_STATUS =>
                payload_length <= std_logic_vector(to_unsigned((NUMBER_OF_QUADCORES * 4) + 1, payload_length'length));
                data <= crack_count_buffer(stat_1_count)(((4-stat_0_count) * 8) - 1 downto ((3-stat_0_count) * 8));
                data_valid <= status_valid;
                if status_finish = '1' then
                    next_state_global <= WAIT_FOR_READY;
                end if;
        end case;
    end process;
    --------------------------------------------------------------------
end architecture;