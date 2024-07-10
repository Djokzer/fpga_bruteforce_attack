library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;
use std.env.finish;

library uart;
use uart.uart_pkg.all;

library work;
use work.pkg_bcrypt.all;
use work.rzi_helper.all;

entity tb_top is
end entity tb_top;

architecture rtl of tb_top is

	-- --------------------------------------------------------------------- --
	--                              Constants
	-- --------------------------------------------------------------------- --
	constant CLK_PERIOD : time := 10 ns;

    -- PASSWORD : a
    constant CORRECT_PACKET : std_logic_vector(823 downto 0) :=
    x"02_63_02_05_01_01_28_e0_c5_40_97_0a_eb_bb_49_c6_86_81_e8_07" &
    x"9a_94_7e_d3_90_9f_d8_d7_43_2b_3e_fc_f7_ad_85_ce_57_3a_3d_ec" &
    x"f9_12_e7_ad_82_19_01_01_01_01_01_01_01_01_01_01_01_01_01_01" &
    x"01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01" &
    x"01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_03" &
    x"01_c0_00";
    
    -- PASSWORD : a, crc : error
    constant CRC_ERROR_PACKET : std_logic_vector(823 downto 0) :=
    x"02_63_02_05_01_01_28_e0_c5_40_97_0a_eb_bb_49_c6_86_81_e8_07" &
    x"9a_94_7e_d3_90_9f_d8_d7_43_2b_3e_fc_f7_ad_85_ce_57_3a_3d_ec" &
    x"f9_12_e7_ad_82_19_01_01_01_01_01_01_01_01_01_01_01_01_01_01" &
    x"01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01" &
    x"01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_03" &
    x"01_c2_00";

    -- PASSWORD : a, id : error
    constant ID_ERROR_PACKET : std_logic_vector(823 downto 0) :=
    x"04_63_05_05_01_01_28_e0_c5_40_97_0a_eb_bb_49_c6_86_81_e8_07" &
    x"9a_94_7e_d3_90_9f_d8_d7_43_2b_3e_fc_f7_ad_85_ce_57_3a_3d_ec" &
    x"f9_12_e7_ad_82_19_01_01_01_01_01_01_01_01_01_01_01_01_01_01" &
    x"01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01" &
    x"01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_03" &
    x"01_50_00";

	constant PACKET_BYTE_SIZE : integer := 103;

	-- --------------------------------------------------------------------- --
	--                               Signals
	-- --------------------------------------------------------------------- --
	-- GENERAL
	signal clk      : std_logic := '0';     -- clock signal
	signal rst      : std_logic;     -- reset signal (enable high)

	-- UART interface
	signal tx_debug       :  std_logic;
	signal rx_debug       :  std_logic;
	
    -- UART SIGNALS
    signal resetn  : std_logic;
    signal tx_valid_i : std_logic;
    signal tx_data_i : std_logic_vector(7 downto 0);
    signal tx_busy_o : std_logic;
    signal rx_valid_o : std_logic;
    signal rx_data_o  : std_logic_vector(7 downto 0);

	-- OUTPUT
	signal leds     : std_logic_vector(7 downto 0);

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
	clk  <= not clk after CLK_PERIOD / 2;
	rst <= '1', '0'  after CLK_PERIOD * 10;

	-- UUT INSTANTIATION
	uut : entity work.top
	port map(
		-- GENERAL
		clk         => clk,
		reset       => rst,
		
		-- UART interface
		tx          => tx_debug,
		rx          => rx_debug,
		
        -- OUTPUT
		leds        => leds
	);
	
	-- UART (FOR DEBUG)
    uart : entity work.uart
    generic map (
            CLK_FREQ => 100,
            BAUDRATE => 115200)
    port map (
        clk_i       => clk,
        resetn      => resetn,
        -- User interface
        tx_valid_i  => tx_valid_i,
        tx_data_i   => tx_data_i, 
        tx_busy_o   => tx_busy_o, 
        --
        rx_valid_o  => rx_valid_o,
        rx_data_o   => rx_data_o,
        -- UART interface
        tx_o        => rx_debug,
        rx_i        => tx_debug
    );
    resetn <= not rst;

	-- stimulus
	stim_proc : process
	begin
		-- Wait for reset to be released
		wait until rst = '0';
		wait for CLK_PERIOD;

        report "Start Sending Packet !" severity note;

        report "First packet : CRC error !" severity note;
		-- Send Packet
        for i in PACKET_BYTE_SIZE-1 downto 0 loop
            --report integer'image(i) severity note;
			uart_tx_byte(clk, tx_valid_i, tx_data_i, tx_busy_o, CRC_ERROR_PACKET((i*8)+7 downto i*8));
        end loop;
        wait until packet_sended = '1';

        report "Second packet : ID error !" severity note;
		-- Send Packet
        for i in PACKET_BYTE_SIZE-1 downto 0 loop
            --report integer'image(i) severity note;
			uart_tx_byte(clk, tx_valid_i, tx_data_i, tx_busy_o, ID_ERROR_PACKET((i*8)+7 downto i*8));
        end loop;
        wait until packet_sended = '1';

        report "Last packet : should find pwd => 'a' !" severity note;
		-- Send Packet
        for i in PACKET_BYTE_SIZE-1 downto 0 loop
            --report integer'image(i) severity note;
			uart_tx_byte(clk, tx_valid_i, tx_data_i, tx_busy_o, CORRECT_PACKET((i*8)+7 downto i*8));
        end loop;        
        report "Attack Started !" severity note;
	end process;

	-- check output
	check_out : process
	begin 
        packet_sended <= '0';
		-- Wait for reset to be released
		wait until rst = '0';
		wait for CLK_PERIOD;

        -- PACKET 1 - CRC WRONG
        check_out_data(x"04", rx_data_o, rx_valid_o);
        check_out_data(x"01", rx_data_o, rx_valid_o);
        check_out_data(x"04", rx_data_o, rx_valid_o);
        check_out_data(x"1c", rx_data_o, rx_valid_o);
        check_out_data(x"00", rx_data_o, rx_valid_o);
        report "Returned packet : CRC error !" severity note;
        packet_sended <= '1';
        wait for CLK_PERIOD;
        packet_sended <= '0';
        wait for CLK_PERIOD;

        -- PACKET 2 - ID WRONG
        check_out_data(x"04", rx_data_o, rx_valid_o);
        check_out_data(x"01", rx_data_o, rx_valid_o);
        check_out_data(x"03", rx_data_o, rx_valid_o);
        check_out_data(x"09", rx_data_o, rx_valid_o);
        check_out_data(x"00", rx_data_o, rx_valid_o);
        report "Returned packet : ID error !" severity note;
        packet_sended <= '1';
        wait for CLK_PERIOD;
        packet_sended <= '0';
        wait for CLK_PERIOD;

        -- PACKET 3 - ALL CORRECT
        check_out_data(x"02", rx_data_o, rx_valid_o);
        check_out_data(x"01", rx_data_o, rx_valid_o);
        check_out_data(x"01", rx_data_o, rx_valid_o);
        check_out_data(x"01", rx_data_o, rx_valid_o);
        check_out_data(x"00", rx_data_o, rx_valid_o);
        report "Returned packet : All good !" severity note;

		wait until leds(1) = '1'; -- Success signal
		wait for CLK_PERIOD * 10;

		report "Attack finished !" severity note;
		report "-- Simulation completed successfully --" severity note;
        finish;
	end process;
end architecture;