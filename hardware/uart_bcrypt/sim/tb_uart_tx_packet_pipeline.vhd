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

    -- BCRYPT CRACKER INTERFACE
	-- STATUS INTERFACE
	signal crack_count_index   : std_logic_vector(7 downto 0);
	signal crack_count         : std_logic_vector (31 downto 0);
	-- PWD FOUND INTERFACE
	signal done                : std_logic;
	signal success             : std_logic;
	signal dout_we             : std_logic;
	signal dout                : std_logic_vector (31 downto 0);

	-- CRACK COUNT BUFFER
    type data_32_buffer is array (0 to 3) of std_logic_vector(31 downto 0);
    signal crack_buffer   : data_32_buffer := ((x"10121416"), (x"20222426"), (x"30323436"), (x"40424446"));  -- Default initialization
    
    signal packet_sended : std_logic;

    -- Procedure to check output data
    procedure check_out_data(
        correct_data : in std_logic_vector(7 downto 0);
        signal data : in std_logic_vector(7 downto 0);
        signal valid : in std_logic
    ) is
    begin
        wait until valid = '1';
        assert correct_data = data report "Incorrect data byte" severity note;
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
    generic map (
		NUMBER_OF_QUADCORES => 4
	)
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
        error_code          => error_code,
        
        -- BCRYPT CRACKER INTERFACE
        -- STATUS INTERFACE
        crack_count_index   => crack_count_index,
        crack_count         => crack_count,
        -- PWD FOUND INTERFACE
        done                => done,
        success             => success,
        dout_we             => dout_we,
        dout                => dout
    );

    ---------------------------- CRACK COUNT PACKET TEST ----------------------------------
    crack_count <= crack_buffer(to_integer(unsigned(crack_count_index)));


    stimuli : process
    begin
        packet_processed <= '0';
        error_code <= "000";
        dout_we <= '0';
        dout <= x"42424242";
        -- Wait for reset to be released
        wait until reset = '0';
        wait for CLK_PERIOD * 2;

        ---------------------------- PASSWORD PACKET TEST ---------------------------------
        dout_we <= '1';
        wait for CLK_PERIOD;
        dout <= x"61006100";    -- PASSWORD
        wait for CLK_PERIOD *17;
        dout_we <= '0';
        wait for CLK_PERIOD;
        dout <= x"42424242";
        -----------------------------------------------------------------------------------

        ---------------------------- RETURN PACKET TEST -----------------------------------
--        -- PACKET 1 - CRC WRONG
--        report "First packet Sent - CRC ERROR !" severity note;
--        error_code <= "100";
--        wait for CLK_PERIOD;
--        error_code <= "000";
--        wait until packet_sended = '1';

--        -- PACKET 2 - ID WRONG
--        report "Second packet Sent - ID ERROR !" severity note;
--        error_code <= "011";
--        wait for CLK_PERIOD;
--        error_code <= "000";
--        wait until packet_sended = '1';

--        -- PACKET 3 - ALL CORRECT
--        report "Third packet Sent - ALL GOOD !" severity note;
--        packet_processed <= '1';
--        wait for CLK_PERIOD;
--        packet_processed <= '0';
--        wait until packet_sended = '1';
        -------------------------------------------------------------------------------------
        wait for CLK_PERIOD;
    end process;

    check_output : process
    begin
        packet_sended <= '0';
        -- Wait for reset to be released
        wait until reset = '0';
        wait for CLK_PERIOD * 2;
        
        ---------------------------- PASSWORD PACKET TEST ---------------------------------
        check_out_data(x"04", rx_data_o, rx_valid_o);   -- COBS HEADER
        check_out_data(x"49", rx_data_o, rx_valid_o);   -- PAYLOAD SIZE
        check_out_data(x"10", rx_data_o, rx_valid_o);   -- PAYLOAD : TYPE BYTE
        for i in 0 to 35 loop
            -- PAYLOAD : PWD
            check_out_data(x"61", rx_data_o, rx_valid_o);   -- PAYLOAD : TYPE BYTE
            check_out_data(x"02", rx_data_o, rx_valid_o);   -- PAYLOAD : TYPE BYTE
        end loop;
        check_out_data(x"c2", rx_data_o, rx_valid_o);   -- CRC
        check_out_data(x"00", rx_data_o, rx_valid_o);   -- COBS END
        report "CRACK COUNT PACKET RECEIVED !" severity note;
        -----------------------------------------------------------------------------------
        
        ---------------------------- RETURN PACKET TEST -----------------------------------
--        -- PACKET 1 - CRC WRONG
--        check_out_data(x"04", rx_data_o, rx_valid_o);   -- COBS HEADER
--        check_out_data(x"01", rx_data_o, rx_valid_o);   -- PAYLOAD SIZE
--        check_out_data(x"04", rx_data_o, rx_valid_o);   -- PAYLOAD : TYPE BYTE + RETURN
--        check_out_data(x"1c", rx_data_o, rx_valid_o);   -- CRC
--        check_out_data(x"00", rx_data_o, rx_valid_o);   -- COBS END
--        report "First packet Received - CRC ERROR !" severity note;
--        packet_sended <= '1';
--        wait for CLK_PERIOD;
--        packet_sended <= '0';
--        wait for CLK_PERIOD;

--        -- PACKET 2 - ID WRONG
--        check_out_data(x"04", rx_data_o, rx_valid_o);   -- COBS HEADER
--        check_out_data(x"01", rx_data_o, rx_valid_o);   -- PAYLOAD SIZE
--        check_out_data(x"03", rx_data_o, rx_valid_o);   -- PAYLOAD : TYPE BYTE + RETURN
--        check_out_data(x"09", rx_data_o, rx_valid_o);   -- CRC
--        check_out_data(x"00", rx_data_o, rx_valid_o);   -- COBS END
--        report "Second packet Received - ID ERROR !" severity note;
--        packet_sended <= '1';
--        wait for CLK_PERIOD;
--        packet_sended <= '0';
--        wait for CLK_PERIOD;

--        -- PACKET 3 - ALL CORRECT
--        check_out_data(x"02", rx_data_o, rx_valid_o);   -- COBS HEADER
--        check_out_data(x"01", rx_data_o, rx_valid_o);   -- PAYLOAD SIZE
--        check_out_data(x"01", rx_data_o, rx_valid_o);   -- PAYLOAD : TYPE BYTE + RETURN
--        check_out_data(x"01", rx_data_o, rx_valid_o);   -- CRC
--        check_out_data(x"00", rx_data_o, rx_valid_o);   -- COBS END
--        report "Third packet Received - ALL GOOD !" severity note;
--        packet_sended <= '1';
--        wait for CLK_PERIOD;
--        packet_sended <= '0';
--        wait for CLK_PERIOD;
        -------------------------------------------------------------------------------------
        ---------------------------- CRACK COUNT PACKET TEST --------------------------------
--        check_out_data(x"14", rx_data_o, rx_valid_o);   -- COBS HEADER
--        check_out_data(x"11", rx_data_o, rx_valid_o);   -- PAYLOAD SIZE
--        check_out_data(x"08", rx_data_o, rx_valid_o);   -- PAYLOAD : TYPE BYTE
--        for i in 0 to 3 loop
--            for j in 0 to 3 loop
--                -- PAYLOAD : CRACK COUNT
--                check_out_data(crack_buffer(i)(((4-j) * 8) - 1 downto ((3-j) * 8)), rx_data_o, rx_valid_o);     
--            end loop;
--        end loop;
--        check_out_data(x"f4", rx_data_o, rx_valid_o);   -- CRC
--        check_out_data(x"00", rx_data_o, rx_valid_o);   -- COBS END
--        report "CRACK COUNT PACKET RECEIVED !" severity note;
        -------------------------------------------------------------------------------------

        wait for CLK_PERIOD*100000;
        report "Simulation Finished !" severity note;
        finish;
    end process;

end architecture;