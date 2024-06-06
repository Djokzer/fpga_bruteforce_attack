library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;

entity packet_receiver is
	port (
		-- GENERAL
		clk   : in std_logic;
		reset : in std_logic;
		
		-- UART RX
		rx_valid : in std_logic;
		rx_data  : in std_logic_vector(7 downto 0);

		-- BUFFER INTERFACE
		packet_data : out std_logic_vector(7 downto 0);
		packet_data_valid : out std_logic;
		packet_incomming : out std_logic;
		packet_valid : out std_logic
	);
end entity packet_receiver;

architecture rtl of packet_receiver is
	-- SIGNALS
	signal packet_start : std_logic := '0';
	signal packet_valid_s : std_logic := '0';
	signal data_out : std_logic_vector(7 downto 0);
	signal data_out_valid : std_logic := '0';

	signal cobs_count : integer := 0;
	signal cobs_next : integer := 0;
	signal cobs_load : std_logic := '0';
	signal cobs_header : std_logic := '0';

	signal payload_load : std_logic := '0';
	signal payload_count_load : integer := 0;
	signal payload_count : integer := 0;

	signal crc_s : std_logic_vector(7 downto 0):= x"00";
	signal crc_in : std_logic_vector(7 downto 0) := x"00";
	signal crc_out : std_logic_vector(7 downto 0):= x"00";
	signal payload_finish : std_logic := '0';
begin
	-- packet out
	packet_incomming <= packet_start;
	packet_data_valid <= data_out_valid;
	packet_data <= data_out;
	packet_valid <= packet_valid_s;

	-- check end of packet
	check_end : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				packet_start <= '0';
			else
				if rx_valid = '1' then
					if rx_data = x"00" then
						-- END OF PACKET
						packet_start <= '0';
					else
						-- PACKET COMING
						packet_start <= '1';
					end if;
                elsif payload_finish = '1' then
                    -- END OF PACKET
                    packet_start <= '0';
				end if;
			end if;
		end if;
	end process;

	-- cobs counter
	cobs_counter : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				cobs_count <= 0;
			else
				if cobs_load = '1' then
					-- INIT COBS COUNTER, (NEXT 0x00 OFFSET)
					cobs_count <= cobs_next - 1;
				elsif rx_valid = '1' then
					if cobs_count /= 0  then
						-- DECREMENT COBS COUNTER
						cobs_count <= cobs_count - 1;
					end if;
				end if;
			end if;
		end if;
	end process;

	-- payload counter
	payload_counter : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				payload_count <= 0;
			else        
				if payload_load = '1' then
					-- INIT PAYLOAD COUNTER
					payload_count <= payload_count_load - 1;
				elsif rx_valid = '1' then
					if payload_count /= 0 then
						-- DECREMENT PAYLOAD COUNTER
						payload_count <= payload_count - 1;
					end if;
				end if;           
			end if;
		end if;
	end process;
	
	-- cobs decoder
	cobs_decoder : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				cobs_load <= '0';
				data_out_valid <= '0';
				cobs_next <= 0;
				cobs_header <= '0';
				data_out <= x"00";
				payload_load <= '0';
				payload_count_load <= 0;
				payload_finish <= '0';
			else
				if rx_valid = '1' then
					-- IF NEW DATA IN
					if rx_data = x"00" then
						-- END OF PACKET
						cobs_load <= '0';
						data_out_valid <= '0';
						cobs_header <= '0';
						payload_load <= '0';
						payload_finish <= '0';
					elsif packet_start = '0' then
						-- COBS HEADER
						cobs_load <= '1';
						cobs_next <= to_integer(unsigned(rx_data));
						data_out_valid <= '0';
						payload_load <= '0';
						payload_finish <= '0';
						cobs_header <= '1';
					elsif cobs_header = '1' then
						-- PAYLOAD LENGTH
						cobs_header <= '0';
						cobs_load <= '0';
						payload_finish <= '0';
						payload_load <= '1';
						payload_count_load <= to_integer(unsigned(rx_data));
					else
						-- GET DECODED DATA
						if cobs_count = 0 then
							-- DATA : 0x00
							data_out <= x"00";

							-- COBS NEXT 0x00
							cobs_load <= '1';
							cobs_next <= to_integer(unsigned(rx_data));
						else
							cobs_load <= '0';
							data_out <= rx_data;
						end if;
						cobs_header <= '0';
						payload_load <= '0';
						data_out_valid <= '1';
						
						if payload_count = 0 then
							-- GET CRC FROM PACKET
							payload_finish <= '1';
							data_out_valid <= '0';
						end if;
					end if;
				else
					cobs_load <= '0';
					data_out_valid <= '0';
				end if;
			end if;
		end if;
	end process;

	-- crc module
	crc_m: entity work.crc
		port map (
			crcIn   => crc_in,
			data 	=> data_out,
			crcOut	=> crc_out
		);
	
	crc_in <= crc_s;
	
	-- crc check
	crc_check : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				crc_s <= x"00";
			    packet_valid_s <= '0';
			else
				if data_out_valid = '1' then
					crc_s <= crc_out;
					packet_valid_s <= '0';
				elsif payload_finish = '1' then
					if crc_s = data_out then
						packet_valid_s <= '1';
					else
						packet_valid_s <= '0';
					end if;
					crc_s <= x"00";
				end if;
			end if;
		end if;
	end process;
end architecture;