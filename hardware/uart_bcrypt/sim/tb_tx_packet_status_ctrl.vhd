entity tb_tx_packet_status_ctrl is
end entity tb_tx_packet_status_ctrl;

architecture rtl of tb_tx_packet_status_ctrl is

	-- GENERAL
	constant CLK_PERIOD : time := 10 ns;
    
    signal clk_i  : std_logic := '0';
    signal reset  : std_logic;

	-- BCRYPT CRACKER INTERFACE
	-- STATUS INTERFACE
	signal crack_count_index   : std_logic_vector(7 downto 0);
	signal crack_count         : std_logic_vector (31 downto 0);
	-- PWD FOUND INTERFACE
	signal done                : std_logic;
	signal success             : std_logic;
	signal dout_we             : std_logic;
	signal dout                : std_logic_vector (31 downto 0);

	-- TX PIPELINE INTERFACE
	signal status_ready        : std_logic;
	signal status_clear        : std_logic;
	signal pwd_ready           : std_logic;
	signal pwd_clear           : std_logic;
	signal data                : std_logic_vector(7 downto 0);

	-- CRACK COUNT BUFFER
    type data_32_buffer is array (0 to 3) of std_logic_vector(31 downto 0);
    signal crack_buffer   : data_32_buffer := ((x"14"), (x"24"), (x"34"), (x"f1"));  -- Default initialization
begin

    -- CLOCK AND RESET SIGNAL
    clk_i  <= not clk_i after CLK_PERIOD / 2;
    reset <= '1', '0'  after CLK_PERIOD * 10;

	uut : entity work.tx_packet_status_ctrl
    generic map (
		NUMBER_OF_QUADCORES => 1,
	)
    port map (
		-- GENERAL
		clk         => clk,
		reset       => rst,
		
 		-- BCRYPT CRACKER INTERFACE
        -- STATUS INTERFACE
        crack_count_index   => crack_count_index,
        crack_count         => crack_count,
        -- PWD FOUND INTERFACE
        done                => done,
        success             => success,
        dout_we             => dout_we,
        dout                => dout,

        -- TX PIPELINE INTERFACE
        status_ready        => status_ready,
        status_clear        => status_clear,
        pwd_ready           => pwd_ready,
        pwd_clear           => pwd_clear,
        data                => data
    );
	crack_count <= crack_buffer(to_integer(unsigned(crack_count_index)));

	stimuli : process
    begin
		-- Init
		status_clear <= '0';
		pwd_clear <= '0';
        -- Wait for reset to be released
        wait until reset = '0';
        wait for CLK_PERIOD * 2;

		wait until status_ready = '1';
		status_clear <= '1';

        wait for CLK_PERIOD;
    end process;

    check_output : process
    begin
        -- Wait for reset to be released
        wait until reset = '0';
        wait for CLK_PERIOD * 2;

        wait for CLK_PERIOD*100000;
        report "Simulation Finished !" severity note;
        finish;
    end process;

end architecture;