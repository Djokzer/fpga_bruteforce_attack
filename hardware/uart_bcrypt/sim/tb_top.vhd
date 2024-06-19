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

    constant PACKET : std_logic_vector(823 downto 0) :=
    x"02_63_02_05_01_01_28_e0_c5_40_97_0a_eb_bb_49_c6_86_81_e8_07" &
    x"9a_94_7e_d3_90_9f_d8_d7_43_2b_3e_fc_f7_ad_85_ce_57_3a_3d_ec" &
    x"f9_12_e7_ad_82_19_01_01_01_01_01_01_01_01_01_01_01_01_01_01" &
    x"01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01" &
    x"01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_01_03" &
    x"01_c0_00";

	constant PACKET_BYTE_SIZE : integer := 103;

	-- --------------------------------------------------------------------- --
	--                               Signals
	-- --------------------------------------------------------------------- --
	-- GENERAL
	signal clk      : std_logic := '0';     -- clock signal
	signal rst      : std_logic;     -- reset signal (enable high)

	-- UART interface
	signal tx_o       :  std_logic;
	signal rx_i       :  std_logic;
	
	-- UART TX USER INTERFACE (DEBUG ONLY)
	signal tx_valid       :  std_logic;
	signal tx_data        :  std_logic_vector(7 downto 0);
	signal tx_busy        :  std_logic;

	-- OUTPUT
	signal leds     : std_logic_vector(7 downto 0);
begin
	-- CLOCK AND RESET SIGNAL
	clk  <= not clk after CLK_PERIOD / 2;
	rst <= '1', '0'  after CLK_PERIOD * 10;

	-- UUT INSTANTIATION
	uut : entity work.top_debug
	port map(
		-- GENERAL
		clk         => clk,
		reset       => rst,
		
		-- UART interface
		tx          => tx_o,
		rx          => rx_i,
		
		-- UART TX USER INTERFACE (DEBUG ONLY)
		tx_valid_i  => tx_valid,
		tx_data_i   => tx_data,
		tx_busy_o   => tx_busy,

		-- OUTPUT
		leds        => leds
	);
	
	-- LOOP BACK UART (FOR DEBUG)
	rx_i <= tx_o;

	-- stimulus
	stim_proc : process
	begin
		-- Wait for reset to be released
		wait until rst = '0';
		wait for CLK_PERIOD;

        report "Start Sending Packet !" severity note;

		-- Send Packet
        for i in PACKET_BYTE_SIZE-1 downto 0 loop
            --report integer'image(i) severity note;
			uart_tx_byte(clk, tx_valid, tx_data, tx_busy, PACKET((i*8)+7 downto i*8));
        end loop;
        
        report "Attack Started !" severity note;
	end process;

	-- check output
	check_out : process
	begin 
		-- Wait for reset to be released
		wait until rst = '0';
		wait for CLK_PERIOD;

		wait until leds(1) = '1'; -- Success signal
		wait for CLK_PERIOD * 10;

		report "Attack finished !" severity note;
		report "-- Simulation completed successfully --" severity note;
        finish;
	end process;
end architecture;