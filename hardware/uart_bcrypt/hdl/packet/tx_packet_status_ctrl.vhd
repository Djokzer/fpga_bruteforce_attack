library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;

entity tx_packet_status_ctrl is
    generic (
        NUMBER_OF_QUADCORES : integer := 1
    );
    port (
        -- GENERAL
        clk                 : in std_logic;
        reset               : in std_logic;
        
        -- BCRYPT CRACKER INTERFACE
        -- STATUS INTERFACE
        crack_count_index   : out std_logic_vector(7 downto 0);
        crack_count         : in std_logic_vector (31 downto 0);
        -- PWD FOUND INTERFACE
        done                : in std_logic;
        success             : in std_logic;
        dout_we             : in std_logic;
        dout                : in std_logic_vector (31 downto 0);

        -- TX PIPELINE INTERFACE
        status_ready        : out std_logic;
        status_clear        : in std_logic;
        pwd_ready           : out std_logic;
        pwd_clear           : in std_logic;
        data                : out std_logic_vector(7 downto 0)
    );
end entity tx_packet_status_ctrl;

architecture rtl of tx_packet_status_ctrl is

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
        READY_TO_SEND, WAIT_FOR_CLEAR,
        SEND_DATA
    );
    signal current_state_stat : states_stat_t := S_RESET;
    signal next_state_stat    : states_stat_t := S_RESET;

    -- STATE MACHINE PWD
    type states_pwd_t is (
        S_RESET,
        WAIT_FOR_SUCCESS,
        GET_PASSWORD, 
        READY_TO_SEND, WAIT_FOR_CLEAR,
        SEND_DATA
    );
    signal current_state_pwd : states_pwd_t := S_RESET;
    signal next_state_pwd    : states_pwd_t := S_RESET;

    -- CONTROL SIGNALS
    signal status_rts : std_logic := '0';
    signal select_status : std_logic := '0';
    signal pwd_rts : std_logic := '0';
    signal select_pwd : std_logic := '0';

    -- COUNTERS SIGNALS FOR DATA OUT
    signal data_0_count       : integer := 0;
    signal data_0_count_en    : std_logic := '0'; 
    signal data_0_count_load  : std_logic := '0'; 
    signal data_0_count_in    : integer := 0;
    signal data_1_count       : integer := 0;
    signal data_1_count_en    : std_logic := '0'; 
    signal data_1_count_load  : std_logic := '0'; 
    signal data_1_count_in    : integer := 0;
begin

-- TO DO :
--  PERIODICALLY FETCH CRACK COUNT OF EACH QUADCORE ON A BUFFER
--  WHEN BUFFER IS FULL, SEND A PACKET WITH ALL FETCHED COUNT
--  WHEN PASSWORD HAS BEEN FOUND, SHOULD SIGNAL IT AND SEND A PACKET WITH THE PASSWORD IN

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
    fsm_ctrl_stat : process(current_state_stat, crack_count, select_status, status_clear)
	begin
        -- Defaults
        next_state_stat <= current_state_stat;
        quadcore_count_load <= '0';
        quadcore_count_in <= 0;
        quadcore_count_en <= '0';
        status_rts <= '0';
        status_ready <= '0';

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
                if crack_count = NUMBER_OF_QUADCORES-1 then
                    next_state_stat <= READY_TO_SEND;
                end if;
            when READY_TO_SEND =>
                status_rts <= '1';
                if select_status = '1' then
                    next_state_stat <= WAIT_FOR_CLEAR;
                end if;
            when WAIT_FOR_CLEAR =>
                status_rts <= '1';
                status_ready <= '1';
                -- INIT COUNTERS FOR DATA OUT
                data_0_count_load <= '1';
                data_0_count_in <= 0;
                data_1_count_load <= '1';
                data_1_count_in <= 0;
                -- IF TX PIPELINE INTERFACE IS READY
                if status_clear = '1' then
                    next_state_stat <= SEND_DATA;
                end if;
            when SEND_DATA =>
                status_rts <= '1';
                -- ENABLE 8 BIT INDEX COUNTER OF 32 BITS DATA
                data_0_count_en <= '1';
                -- IF ALL 32 BITS HAVE BEEN TRANSMITTED
                if data_0_count = 3 then
                    -- ENABLE BUFFER INDEX COUNTER
                    data_1_count_en <= '1';
                    -- RESET 8 BIT INDEX COUNTER
                    data_0_count_load <= '1';
                    data_0_count_in <= 0;
                end if;
                -- IF ALL BUFFER HAVE BEEN TRANSMITTED
                if data_1_count = NUMBER_OF_QUADCORES-1 then
                    next_state_stat <= RESTART;
                end if;
        end case;
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
    fsm_ctrl_pwd : process(current_state_pwd)
	begin
        -- Defaults
        next_state_pwd <= current_state_pwd;

        case current_state_pwd is
            when S_RESET =>
                next_state_pwd <= WAIT_FOR_SUCCESS;
            when WAIT_FOR_SUCCESS =>
            when GET_PASSWORD =>
            when READY_TO_SEND =>
            when WAIT_FOR_CLEAR =>
            when SEND_DATA =>
        end case;
    end process;

    -- SELECT WHETHER OUTPUT STATUS OR PASSWORD
    select_status <= '1'; -- FOR NOW ONLY OUTPUT STATUS

    -- OUTPUT DATA
    data <= crack_count_buffer(data_1_count)((4-data_0_count * 8) - 1 downto (3-data_0_count * 8));
end architecture;