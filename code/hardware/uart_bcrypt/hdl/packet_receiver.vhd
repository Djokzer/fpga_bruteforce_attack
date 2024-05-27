library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;

entity packet_receiver is
    port (
        clk   : in std_logic;
        reset : in std_logic;
        
        -- UART RX
        rx_valid : in std_logic;
        rx_data  : in std_logic_vector(7 downto 0);

        -- ROUTER INTERFACE
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

	signal crc_s : std_logic_vector(7 downto 0):= x"00";
	signal crc_in : std_logic_vector(7 downto 0) := x"00";
	signal crc_out : std_logic_vector(7 downto 0):= x"00";
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
			if rx_valid = '1' then
				if rx_data = x"00" then
					-- END OF PACKET
					packet_start <= '0';
				else
					-- PACKET COMING
					packet_start <= '1';
				end if;
			end if;
		end if;
	end process;

	-- cobs counter
	cobs_counter : process(clk)
	begin
		if rising_edge(clk) then
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
	end process;
    
	-- cobs decoder
	cobs_decoder : process(clk)
	begin
		if rising_edge(clk) then
			if rx_valid = '1' then
				-- IF NEW DATA IN
				if rx_data = x"00" then
					-- END OF PACKET
					cobs_load <= '0';
					data_out_valid <= '0';
				elsif packet_start = '0' then
					-- COBS HEADER
					cobs_load <= '1';
					cobs_next <= to_integer(unsigned(rx_data));
					data_out_valid <= '0';
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
					data_out_valid <= '1';
				end if;
			else	
				-- IF NO DATA IN
				cobs_load <= '0';
				data_out_valid <= '0';
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
			if data_out_valid = '1' then
				crc_s <= crc_out;
			else
				if crc_out = x"00" then
					packet_valid_s <= '1';
				else
					packet_valid_s <= '0';
				end if;
			end if;
		end if;
	end process;

end architecture;