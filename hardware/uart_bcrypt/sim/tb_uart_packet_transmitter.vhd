library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library std;
use std.env.finish;

library uart;
use uart.uart_pkg.all;

entity tb_uart_packet_transmitter is
end entity tb_uart_packet_transmitter;

architecture rtl of tb_uart_packet_transmitter is

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

    signal payload_incomming    : std_logic; 
    signal payload_length       : std_logic_vector(7 downto 0);
    signal data                 : std_logic_vector(7 downto 0);
    signal data_valid           : std_logic;
    signal transmit_busy        : std_logic;

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

    uut : entity work.packet_transmitter
    port map(
        -- GENERAL
        clk                 => clk_i,
        reset               => reset,
        -- UART TX
        tx_valid            => tx_valid_i,
        tx_data             => tx_data_i,
        tx_busy             => tx_busy_o,
        -- PAYLOAD INTERFACE
        payload_incomming   => payload_incomming,
        payload_length      => payload_length,     
        data                => data,
        data_valid          => data_valid,
        transmit_busy       => transmit_busy
    );
    
    stimuli : process
    begin
        payload_incomming <= '0';
        payload_length <= x"00";
        data <= x"00";
        data_valid <= '0';
        -- Wait for reset to be released
        wait until reset = '0';
        wait for CLK_PERIOD;
        
        -- Send data
        payload_incomming <= '1';
        payload_length <= x"01";
        wait for CLK_PERIOD;
        data <= x"55";
        data_valid <= '1';
        wait for CLK_PERIOD;
        
    end process;
    
    check_output : process
    begin
        -- Wait for reset to be released
        wait until reset = '0';
        wait for CLK_PERIOD;
        
        check_out_data(x"04", rx_data_o, rx_valid_o);
        check_out_data(x"01", rx_data_o, rx_valid_o);
        check_out_data(x"55", rx_data_o, rx_valid_o);
        check_out_data(x"ac", rx_data_o, rx_valid_o);
        check_out_data(x"00", rx_data_o, rx_valid_o);
        
        wait for CLK_PERIOD * 10;
        report "Simulation Finished !" severity note;
        finish;
    end process;

end architecture;