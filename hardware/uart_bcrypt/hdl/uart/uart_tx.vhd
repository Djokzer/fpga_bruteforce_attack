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
-- Module Name: uart_tx - arch
-- Target Device: digilentinc.com:nexys_video:part0:1.2 xc7a200tsbg484-1
-- Tool version: 2023.1
-- Description: UART Transmitter
--
-- Last update: 2023-11-27
--
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
  generic (
    CLK_FREQ : integer := 100; -- Clock frequency in MHz
    BAUDRATE : integer := 115200 -- UART baudrate
  );
  port (
    clk_i      : in  std_logic;
    resetn     : in  std_logic;
    tx_valid_i : in  std_logic;
    tx_data_i  : in  std_logic_vector(7 downto 0);
    tx_busy_o  : out std_logic;
    tx_o       : out std_logic
    );
end uart_tx;


architecture arch of uart_tx is

  ---------------------------------------------------------------------------------
  -- UART TX clock generator
  ---------------------------------------------------------------------------------
  component uart_tx_clock is
    generic (
      CLK_FREQ : integer := 100;
      BAUDRATE : integer := 115200
    );
    port (
      clk_i      : in  std_logic;
      resetn     : in  std_logic;
      -- Clock output
      tx_clock_o : out std_logic
      );
  end component;

  -- Signal used to detect rising edge on generated clock
  signal uart_clock_s, prev_uart_clock_s : std_logic := '0';

  -- FSM states
  type SENDER_FSM_STATE_TYPE is (INIT, SYNC_TX_CLOCK, START, DATA, STOP);
  signal sender_fsm_state, next_sender_fsm_state : SENDER_FSM_STATE_TYPE := INIT;

  -- Byte count
  signal byte_count_s, new_byte_count_s : integer := 0;

  ---------------------------------------------------------------------------------
  -- Serializer
  ---------------------------------------------------------------------------------
  component serializer
    port (
      clk_i    : in  std_logic;
      resetn   : in  std_logic;
      load_i   : in  std_logic;
      bit_en_i : in  std_logic;
      data_i   : in  std_logic_vector(7 downto 0);
      bit_o    : out std_logic
      );
  end component;

  signal ser_load_i   : std_logic                    := '0';
  signal ser_bit_en_i : std_logic                    := '0';
  signal ser_data_i   : std_logic_vector(7 downto 0) := (others => '0');
  signal ser_bit_o    : std_logic                    := '0';

begin

  ---------------------------------------------------------------------------------
  uart_tx_clock_i : uart_tx_clock
    generic map (
      CLK_FREQ => CLK_FREQ,
      BAUDRATE => BAUDRATE
    )
    port map (
      clk_i      => clk_i,
      resetn     => resetn,
      tx_clock_o => uart_clock_s
      );

  ---------------------------------------------------------------------------------
  -- Register previous clock value for edge detection
  ---------------------------------------------------------------------------------
  prev_uart_clock_s_proc : process (clk_i)
  begin
    if rising_edge(clk_i) then
      if resetn = '0' then
        prev_uart_clock_s <= '1';
      else
        prev_uart_clock_s <= uart_clock_s;
      end if;
    end if;
  end process;

  ---------------------------------------------------------------------------------
  -- TX state machine
  ---------------------------------------------------------------------------------
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if resetn = '0' then
        sender_fsm_state <= INIT;
        byte_count_s     <= 0;
      else
        sender_fsm_state <= next_sender_fsm_state;
        byte_count_s     <= new_byte_count_s;
      end if;
    end if;
  end process;

  process (byte_count_s, tx_valid_i, sender_fsm_state, tx_data_i, ser_bit_o, ser_bit_en_i,
           uart_clock_s, prev_uart_clock_s)
  begin
    -- Default values
    next_sender_fsm_state <= sender_fsm_state;
    tx_o                  <= '1';
    tx_busy_o             <= '0';
    new_byte_count_s      <= byte_count_s;
    --
    ser_load_i            <= '0';
    ser_bit_en_i          <= '0';
    ser_data_i            <= (others => '0');

    case sender_fsm_state is
      ----------------------------------------------------------------
      when INIT =>
        tx_o <= '1';
        if tx_valid_i = '1' then
          -- Load the shift register
          ser_load_i            <= '1';
          ser_data_i            <= tx_data_i;
          --
          next_sender_fsm_state <= SYNC_TX_CLOCK;
        end if;
      ----------------------------------------------------------------
      when SYNC_TX_CLOCK =>
        tx_busy_o <= '1';
        if uart_clock_s = '1' and prev_uart_clock_s = '0' then  -- uart_clock_s rising edge
          tx_o                  <= '0';
          --
          next_sender_fsm_state <= START;
        end if;
      ----------------------------------------------------------------
      when START =>
        tx_o      <= '0';
        tx_busy_o <= '1';
        if uart_clock_s = '1' and prev_uart_clock_s = '0' then  -- uart_clock_s rising edge
          -- Bit enable must asserted for one cycle only
          ser_bit_en_i          <= '1';
          next_sender_fsm_state <= DATA;
        end if;
      ----------------------------------------------------------------
      when DATA =>
        tx_o      <= ser_bit_o;
        tx_busy_o <= '1';
        -- Shift enable must be asserted during one cycle only
        if uart_clock_s = '1' and prev_uart_clock_s = '0' then  -- uart_clock_s rising edge
          ser_bit_en_i <= '1';
          --
          if byte_count_s = 7 then
            new_byte_count_s      <= 0;
            ser_bit_en_i          <= '0';
            next_sender_fsm_state <= STOP;
          else
            new_byte_count_s <= byte_count_s + 1;
          end if;
        end if;
      ----------------------------------------------------------------
      when STOP =>
        tx_o      <= '1';
        tx_busy_o <= '1';
        if uart_clock_s = '1' and prev_uart_clock_s = '0' then  -- uart_clock_s rising edge
          next_sender_fsm_state <= INIT;
        end if;
      ----------------------------------------------------------------
      when others =>
        next_sender_fsm_state <= INIT;
    end case;
  end process;

  ---------------------------------------------------------------------------------
  tx_serializer : serializer
    port map (
      clk_i    => clk_i,
      resetn   => resetn,
      load_i   => ser_load_i,
      bit_en_i => ser_bit_en_i,
      data_i   => ser_data_i,
      bit_o    => ser_bit_o
      );

end arch;
