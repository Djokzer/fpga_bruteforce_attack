----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.06.2024 15:24:38
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.pkg_bcrypt.all;
use work.rzi_helper.all;

entity top is
	port (
		-- GENERAL
		clk         : in std_logic;
		reset       : in std_logic;
		
		-- UART interface
		tx          : out std_logic;
		rx          : in  std_logic;

		-- OUTPUT
		leds        : out std_logic_vector(7 downto 0)
	);
end top;

architecture Behavioral of top is
	-- CONSTANTS
	constant NUMBER_OF_QUADCORES : integer := 1;
	
	-- UART SIGNALS
	signal resetn  : std_logic;
	signal tx_valid_i : std_logic;
	signal tx_data_i : std_logic_vector(7 downto 0);
	signal tx_busy_o : std_logic;
	signal rx_valid_o : std_logic;
	signal rx_data_o  : std_logic_vector(7 downto 0);

	-- RX PIPELINE OUTPUT
	signal quadcore_id      : std_logic_vector(7 downto 0);
	signal crack_max        : std_logic_vector(31 downto 0);
	signal salt             : std_logic_vector(SALT_LENGTH-1 downto 0);
	signal hash             : std_logic_vector(HASH_LENGTH-1 downto 0);
	signal pwd_count_init   : std_logic_vector(PWD_LENGTH*CHARSET_OF_BIT-1 downto 0);
	signal pwd_len_init     : std_logic_vector(PWD_BITLEN - 1 downto 0);

	-- RX PIPELINE OUPTUT REGISTER
	signal quadcore_id_reg      : std_logic_vector(7 downto 0);
	signal crack_max_reg        : std_logic_vector(31 downto 0);
	signal salt_reg             : std_logic_vector(SALT_LENGTH-1 downto 0);
	signal hash_reg             : std_logic_vector(HASH_LENGTH-1 downto 0);
	signal pwd_count_init_reg   : std_logic_vector(PWD_LENGTH*CHARSET_OF_BIT-1 downto 0);
	signal pwd_len_init_reg     : std_logic_vector(PWD_BITLEN - 1 downto 0);
	
	-- RX PIPELINE RETURN SIGNAL
	signal output_en    : std_logic;
	signal output_en_reg: std_logic;
	signal error_status : std_logic_vector(2 downto 0);

	-- BCRYPT CRACKER CRACK RESULT
	signal done 	: std_logic;
	signal success 	: std_logic;
	signal dout_we 	: std_logic;
	signal dout 	: std_logic_vector(31 downto 0);
	
	-- OUTPUT
	signal leds_reg : std_logic_vector(7 downto 0) := x"00";
	
begin
	-- UART COM
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
		tx_o        => tx,
		rx_i        => rx
	);
	resetn <= not reset;
	
	-- RX PACKET PIPELINE
	rx_pckt_pipeline : entity work.rx_packet_pipeline
	generic map(
		NUMBER_OF_QUADCORES => NUMBER_OF_QUADCORES
	)
	port map(
		-- GENERAL
		clk         => clk,
		reset       => reset,
		-- UART RX
		rx_valid    => rx_valid_o,
		rx_data     => rx_data_o,
		-- OUTPUT
		quadcore_id     => quadcore_id,
		crack_max       => crack_max,
		salt            => salt,
		hash            => hash,
		pwd_count_init  => pwd_count_init,
		pwd_len_init    => pwd_len_init,
		-- RETURN
		output_en       => output_en,
		error_status    => error_status
	);

	tx_pckt_pipeline : entity work.tx_packet_pipeline
    port map(
        -- GENERAL
        clk                 => clk,
        reset               => reset,
        -- UART TX
        tx_valid            => tx_valid_i,
        tx_data             => tx_data_i,
        tx_busy             => tx_busy_o,
        -- PACKET RETURN
        packet_processed    => output_en,
        error_code          => error_status     
    );

	-- BCRPYT CRACKER
	cracker : entity work.bcrypt_cracker
	generic map(
		NUMBER_OF_QUADCORES => NUMBER_OF_QUADCORES
	)
	port map(
		-- GENERAL
		clk         => clk,
		rst       	=> reset,

		-- CONFIG
		config_enable		=> output_en_reg,
		quadcore_id     	=> quadcore_id_reg,
		number_of_cracks	=> crack_max_reg,
		t_salt            	=> salt_reg,
		t_hash            	=> hash_reg,
		vec_init 		 	=> pwd_count_init_reg,
		vec_length    		=> pwd_len_init_reg,

		-- CRACK RESULT
		done 	=> done, 
		success	=> success,
		dout_we => dout_we,
		dout 	=> dout
	);

	-- MEMORIZE CONFIG DATA WHEN ENABLE
	mem_congig : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				output_en_reg 		<= '0';
				quadcore_id_reg 	<= (others => '0');
				crack_max_reg 		<= (others => '0');
				salt_reg 			<= (others => '0');
				hash_reg 			<= (others => '0');
				pwd_count_init_reg 	<= (others => '0');
				pwd_len_init_reg 	<= (others => '0');
			else
				if output_en = '1' then
					output_en_reg 		<= '1';
					quadcore_id_reg 	<= quadcore_id;
					crack_max_reg 		<= crack_max;
					salt_reg 			<= salt;
					hash_reg 			<= hash;
					pwd_count_init_reg 	<= pwd_count_init;
					pwd_len_init_reg 	<= pwd_len_init;
				else
					output_en_reg 		<= '0';
					quadcore_id_reg 	<= quadcore_id;
					crack_max_reg 		<= crack_max;
					salt_reg 			<= salt;
					hash_reg 			<= hash;
					pwd_count_init_reg 	<= pwd_count_init;
					pwd_len_init_reg 	<= pwd_len_init;
				end if;
			end if;
		end if;
	end process;

	leds_proc : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				leds_reg <= x"00";
			else
				leds_reg(4 downto 0) <= "000" & success & done;
				leds_reg(7 downto 5) <= leds_reg(7 downto 5) or error_status;
			end if;
		end if;
	end process;

	-- LEDS OUTPUT
	leds <= leds_reg;

end Behavioral;
