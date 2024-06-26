entity packet_transmitter is
    port (
        -- GENERAL
        clk             : in std_logic;
        reset           : in std_logic;

        -- UART TX
        tx_valid        : out  std_logic;
		tx_data         : out  std_logic_vector(7 downto 0);
		tx_busy         : in std_logic;
        
        -- DATA BUFFER INTERFACE
        data_incomming  : in std_logic;
        data            : in std_logic_vector(7 downto 0);
        data_valid      : in std_logic
    );
end entity packet_transmitter;

architecture rtl of packet_transmitter is

begin

    

end architecture;