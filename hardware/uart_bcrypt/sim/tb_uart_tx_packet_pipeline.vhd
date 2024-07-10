library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library std;
use std.env.finish;

library uart;
use uart.uart_pkg.all;

entity tb_uart_tx_packet_pipeline is
end entity tb_uart_tx_packet_pipeline;

architecture rtl of tb_uart_tx_packet_pipeline is
    
    constant CLK_PERIOD : time := 10 ns;
    
    signal clk_i  : std_logic := '0';
    signal reset  : std_logic;

    -- UART SIGNALS
    signal resetn  : std_logic;
    signal tx_valid_i : std_logic;
    signal tx_data_i : std_logic_vector(7 downto 0);
    signal tx_busy_o : std_logic;
    signal rx_valid_o : std_logic;
    signal rx_data_o  : std_logic_vector(7 downto 0);
    signal tx_o       : std_logic;
    signal rx_i       : std_logic;

    -- PACKET RETURN SIGNALS
    signal packet_processed    : std_logic;
    signal error_code          : std_logic_vector(2 downto 0);
    
    signal packet_sended : std_logic;

    -- Procedure to check output data
    procedure check_out_data(
        correct_data : in std_logic_vector(7 downto 0);
        signal data : in std_logic_vector(7 downto 0);
        signal valid : in std_logic
    ) is
    begin
        wait until valid = '1';
        assert correct_data = data report "Incorrect data byte" severity failure;
        wait for CLK_PERIOD;
    end procedure; 
begin

    -- CLOCK AND RESET SIGNAL
    clk_i  <= not clk_i after CLK_PERIOD / 2;
    reset <= '1', '0'  after CLK_PERIOD * 10;
    
    -- UART COM
    uart : entity work.uart
    generic map (
            CLK_FREQ => 100,
            BAUDRATE => 115200)
    port map (
        clk_i       => clk_i,
        resetn      => resetn,
        -- User interface
        tx_valid_i  => tx_valid_i,
        tx_data_i   => tx_data_i, 
        tx_busy_o   => tx_busy_o, 
        --
        rx_valid_o  => rx_valid_o,
        rx_data_o   => rx_data_o,
        -- UART interface
        tx_o        => tx_o,
        rx_i        => rx_i
    );
    rx_i <= tx_o;
    resetn <= not reset;

    uut : entity work.tx_packet_pipeline
    port map(
        -- GENERAL
        clk                 => clk_i,
        reset               => reset,
        -- UART TX
        tx_valid            => tx_valid_i,
        tx_data             => tx_data_i,
        tx_busy             => tx_busy_o,
        -- PACKET RETURN
        packet_processed    => packet_processed,
        error_code          => error_code     
    );

    stimuli : process
    begin
        packet_processed <= '0';
        error_code <= "000";
        -- Wait for reset to be released
        wait until reset = '0';
        wait for CLK_PERIOD * 2;

--        -- PACKET 1 - CRC WRONG
--        error_code <= "100";
--        wait for CLK_PERIOD;
--        error_code <= "000";
--        wait until packet_sended = '1';

--        -- PACKET 2 - ID WRONG
--        error_code <= "011";
--        wait for CLK_PERIOD;
--        error_code <= "000";
--        wait until packet_sended = '1';

        -- PACKET 3 - ALL CORRECT
        packet_processed <= '1';
        wait for CLK_PERIOD;
        packet_processed <= '0';
        --wait until packet_sended = '1';
        
        wait for CLK_PERIOD;
    end process;

    check_output : process
    begin
        packet_sended <= '0';
        -- Wait for reset to be released
        wait until reset = '0';
        wait for CLK_PERIOD * 2;

--        -- PACKET 1 - CRC WRONG
--        check_out_data(x"04", rx_data_o, rx_valid_o);
--        check_out_data(x"01", rx_data_o, rx_valid_o);
--        check_out_data(x"04", rx_data_o, rx_valid_o);
--        check_out_data(x"1c", rx_data_o, rx_valid_o);
--        check_out_data(x"00", rx_data_o, rx_valid_o);
--        packet_sended <= '1';
--        wait for CLK_PERIOD;
--        packet_sended <= '0';
--        wait for CLK_PERIOD;

--        -- PACKET 2 - ID WRONG
--        check_out_data(x"04", rx_data_o, rx_valid_o);
--        check_out_data(x"01", rx_data_o, rx_valid_o);
--        check_out_data(x"03", rx_data_o, rx_valid_o);
--        check_out_data(x"09", rx_data_o, rx_valid_o);
--        check_out_data(x"00", rx_data_o, rx_valid_o);
--        packet_sended <= '1';
--        wait for CLK_PERIOD;
--        packet_sended <= '0';
--        wait for CLK_PERIOD;

--        -- PACKET 3 - ALL CORRECT
--        check_out_data(x"02", rx_data_o, rx_valid_o);
--        check_out_data(x"01", rx_data_o, rx_valid_o);
--        check_out_data(x"01", rx_data_o, rx_valid_o);
--        check_out_data(x"01", rx_data_o, rx_valid_o);
--        check_out_data(x"00", rx_data_o, rx_valid_o);
--        packet_sended <= '1'
--        wait for CLK_PERIOD;
--        packet_sended <= '0'
--        wait for CLK_PERIOD;

        wait for CLK_PERIOD*100000;
        report "Simulation Finished !" severity note;
        finish;
    end process;

end architecture;