library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.pkg_bcrypt.all;
use work.rzi_helper.all;

library work;

entity rx_packet_process is
    port (
        -- GENERAL
        clk                 : in std_logic;
        reset               : in std_logic;
        
        -- PACKET RECEIVER
        packet_data         : in std_logic_vector(7 downto 0);
		packet_data_valid   : in std_logic;
		packet_incomming    : in std_logic;
		packet_valid        : in std_logic

        -- QUADCORE OUTPUT
        quadcore_id         : out std_logic_vector(7 downto 0);
        crack_max           : out std_logic_vector(31 downto 0);
        salt                : out std_logic_vector(SALT_LENGTH-1 downto 0);
        hash                : out std_logic_vector(HASH_LENGTH-1 downto 0);
        pwd_count_init      : out std_logic_vector(PWD_LENGTH*CHARSET_OF_BIT-1 downto 0);
        pwd_len_init        : out std_logic_vector(PWD_BITLEN - 1 downto 0);
    );
end entity rx_packet_process;

architecture rtl of rx_packet_process is

begin

    

end architecture;