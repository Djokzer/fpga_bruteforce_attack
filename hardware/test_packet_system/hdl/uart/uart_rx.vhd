----------------------------------------------------------------------------------
--                                 _             _
--                                | |_  ___ _ __(_)__ _
--                                | ' \/ -_) '_ \ / _` |
--                                |_||_\___| .__/_\__,_|
--                                         |_|
--
----------------------------------------------------------------------------------
--
-- Company: HEPIA
-- Author: Laurent Gantel <laurent.gantel@hesge.ch>
--
-- Module Name: uart_rx - arch
-- Target Device: digilentinc.com:nexys_video:part0:1.2 xc7a200tsbg484-1
-- Tool version: 2023.1
-- Description: UART Receiver
--
-- Last update: 2023-11-27
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity uart_rx is
  generic (
    CLK_FREQ : integer := 100; -- Clock frequency in MHz
    BAUDRATE : integer := 115200 -- UART baudrate
  );
  port (
    clk_i    : in  std_logic;
    resetn   : in  std_logic;
    -- User interface
    rx_valid_o : out std_logic;
    rx_data_o  : out std_logic_vector(7 downto 0);
    -- UART interface
    rx_i       : in  std_logic
    );
end entity uart_rx;


architecture arch of uart_rx is

  ---------------------------------------------------------------------------------
  -- UART RX clock generator
  ---------------------------------------------------------------------------------
  component uart_rx_clock is
    port (
      clk_i       : in  std_logic;
      resetn      : in  std_logic;
      rx_clock_en : in  std_logic;
      rx_clock_o  : out std_logic
      );
  end component;

  signal rx_clock_en                     : std_logic := '0';
  signal uart_clock_s, prev_uart_clock_s : std_logic := '0';
  signal byte_count_s, new_byte_count_s  : integer   := 0;

  -- FSM states
  type RX_FSM_STATE_TYPE is (IDLE, START, DATA, STOP);
  signal rx_fsm_state, next_rx_fsm_state : RX_FSM_STATE_TYPE := IDLE;

  ---------------------------------------------------------------------------------
  -- Synchronizer
  ---------------------------------------------------------------------------------
  component synchronizer is
    port (
      clk_i  : in  std_logic;
      resetn : in  std_logic;
      d_i      : in  std_logic;
      q_o      : out std_logic
      );
  end component synchronizer;

  signal rx_sync      : std_logic := '0';
  signal prev_rx_sync : std_logic := '0';

  ---------------------------------------------------------------------------------
  -- Deserializer
  ---------------------------------------------------------------------------------
  component deserializer
    port (
      clk_i    : in  std_logic;
      resetn   : in  std_logic;
      bit_en_i   : in  std_logic;
      bit_i   : in  std_logic;
      data_o : out std_logic_vector(7 downto 0)
      );
  end component;

  signal deser_bit_en_i   : std_logic                    := '0';
  signal deser_bit_i   : std_logic                    := '0';
  signal deser_data_o : std_logic_vector(7 downto 0) := (others => '0');
  
begin

  ---------------------------------------------------------------------------------
  uart_rx_clock_i : uart_rx_clock
    port map (
      clk_i       => clk_i,
      resetn      => resetn,
      rx_clock_en => rx_clock_en,
      rx_clock_o  => uart_clock_s
      );

  ---------------------------------------------------------------------------------
  -- RX input synchronization
  ---------------------------------------------------------------------------------
  synchronizer_i : synchronizer
    port map (
      clk_i  => clk_i,
      resetn => resetn,
      d_i      => rx_i,
      q_o      => rx_sync
      );

  ---------------------------------------------------------------------------------
  -- Clock and RX input latching
  ---------------------------------------------------------------------------------
  prev_uart_clock_s_proc : process (clk_i)
  begin
    if rising_edge(clk_i) then
      if resetn = '0' then
        prev_uart_clock_s <= '1';
        prev_rx_sync      <= '0';
      else
        prev_uart_clock_s <= uart_clock_s;
        prev_rx_sync      <= rx_sync;
      end if;
    end if;
  end process;

  ---------------------------------------------------------------------------------
  -- RX state machine
  ---------------------------------------------------------------------------------
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if resetn = '0' then
        rx_fsm_state <= IDLE;
        byte_count_s <= 0;
      else
        rx_fsm_state <= next_rx_fsm_state;
        byte_count_s <= new_byte_count_s;
      end if;
    end if;
  end process;

  process (byte_count_s, prev_rx_sync, prev_uart_clock_s, rx_fsm_state,
           rx_sync, uart_clock_s)
  begin
    -- Default values
    next_rx_fsm_state <= rx_fsm_state;
    new_byte_count_s  <= byte_count_s;
    --
    rx_clock_en       <= '0';
    rx_valid_o          <= '0';
    deser_bit_en_i         <= '0';


    case rx_fsm_state is
      ----------------------------------------------------------------
      when IDLE =>
        -- Check for a falling edge on the RX input
        if prev_rx_sync = '1' and rx_sync = '0' then
          next_rx_fsm_state <= START;
        end if;
      ----------------------------------------------------------------
      when START =>
        rx_clock_en <= '1';
        --
        if uart_clock_s = '1' and prev_uart_clock_s = '0' then  -- uart_clock_s rising edge
          next_rx_fsm_state <= DATA;
        end if;
      ----------------------------------------------------------------
      when DATA =>
        rx_clock_en <= '1';
        --
        if uart_clock_s = '1' and prev_uart_clock_s = '0' then  -- uart_clock_s rising edge
          deser_bit_en_i <= '1';
          --
          if byte_count_s = 7 then
            new_byte_count_s  <= 0;
            next_rx_fsm_state <= STOP;
          else
            new_byte_count_s <= byte_count_s + 1;
          end if;
        end if;
      ----------------------------------------------------------------
      when STOP =>
        rx_clock_en <= '1';
        if uart_clock_s = '1' and prev_uart_clock_s = '0' then  -- uart_clock_s rising edge
          rx_valid_o          <= '1';
          next_rx_fsm_state <= IDLE;
        end if;
      ----------------------------------------------------------------
      when others =>
        next_rx_fsm_state <= IDLE;
    end case;
  end process;

  ---------------------------------------------------------------------------------
  rx_deserializer : deserializer
    port map (
      clk_i    => clk_i,
      resetn   => resetn,
      bit_en_i   => deser_bit_en_i,
      bit_i   => deser_bit_i,
      data_o => deser_data_o
      );

  rx_data_o   <= deser_data_o;
  deser_bit_i <= rx_sync;
  
end arch;
