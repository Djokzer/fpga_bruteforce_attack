entity tx_packet_status_ctrl is
    generic (
        NUMBER_OF_QUADCORES : integer := 1
    );
    port (
        -- GENERAL
        clk                 : in std_logic;
        reset               : in std_logic;
        
        -- BCRYPT CRACKER INTERFACE
        -- STATUS INTERFACE
        crack_count_index   : out std_logic_vector(7 downto 0);
        crack_count         : in std_logic_vector (31 downto 0);
        -- PWD FOUND INTERFACE
        done                : in std_logic;
        success             : in std_logic;
        dout_we             : in std_logic;
        dout                : in std_logic_vector (31 downto 0);

        -- TX PIPELINE INTERFACE
        status_ready        : in std_logic;
        status_clear        : in std_logic;
        pwd_ready           : in std_logic;
        pwd_clear           : in std_logic
        data                : out std_logic_vector(7 downto 0);
    );
end entity tx_packet_status_ctrl;

architecture rtl of tx_packet_status_ctrl is

    -- CRACK COUNT BUFFER
    type data_32_buffer is array (0 to NUMBER_OF_QUADCORES-1) of std_logic_vector(31 downto 0);
    signal crack_count_buffer   : data_32_buffer := (others => (others => '0'));  -- Default initialization
    signal quadcore_count       : integer := 0;
    signal quadcore_count_en    : std_logic := '0'; 
    signal quadcore_count_load  : std_logic := '0'; 
    signal quadcore_count_in    : integer := 0;

begin

-- TO DO :
--  PERIODICALLY FETCH CRACK COUNT OF EACH QUADCORE ON A BUFFER
--  WHEN BUFFER IS FULL, SEND A PACKET WITH ALL FETCHED COUNT
--  WHEN PASSWORD HAS BEEN FOUND, SHOULD SIGNAL IT AND SEND A PACKET WITH THE PASSWORD IN

    -- COUNT TO ADDRESS EACH QUADCORE
    quadcore_counter : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                quadcore_count <= 0;
            else
                if quadcore_count_load = '1' then
                    quadcore_count <= quadcore_count_in;
                elsif quadcore_count_en = '1' then
                    quadcore_count <= quadcore_count + 1;
                end if;
            end if;
        end if;
    end process;
    crack_count_index <= std_logic_vector(to_unsigned(quadcore_count, crack_count_index'length));   -- ADDRESS QUADCORE

    -- STORE CRACK COUNT IN THE BUFFER
    store_crack_count : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                crack_count_buffer <= (others => (others => '0'));  -- Default initialization
            else
                crack_count_buffer(quadcore_count) <= crack_count;
            end if;
        end if;
    end process;

    -- FSM / 


end architecture;