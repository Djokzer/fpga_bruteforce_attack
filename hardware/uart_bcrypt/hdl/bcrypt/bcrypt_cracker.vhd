library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pkg_bcrypt.all;
use work.rzi_helper.all;
use work.pkg_sbox_init.all;

entity bcrypt_cracker is
    generic (
        INITIALIZATION_LATENCY  : positive := INIT_PIPELINE;
        NUMBER_OF_QUADCORES     : positive := CORE_INSTANCES);
    port (
        -- GENERAL
        clk     : in  std_logic;
        rst     : in  std_logic;

        -- CONFIG
        config_enable   : in std_logic;
        quadcore_id     : in std_logic_vector(7 downto 0);
        number_of_cracks: in std_logic_vector (31 downto 0);
        t_salt          : in  std_logic_vector (SALT_LENGTH-1 downto 0);
        t_hash          : in  std_logic_vector (HASH_LENGTH-1 downto 0);
        vec_init        : in std_logic_vector (PWD_LENGTH*CHARSET_OF_BIT-1 downto 0);
        vec_length      : in std_logic_vector(PWD_BITLEN - 1 downto 0);

        -- CRACK RESULT
        done    : out std_logic;
        success : out std_logic;
        dout_we : out std_logic;
        dout    : out std_logic_vector (31 downto 0);
        
        -- STATUS RETURN
        crack_count_index   : in std_logic_vector(7 downto 0);
        crack_count         : out std_logic_vector (31 downto 0)
    );
end bcrypt_cracker;

architecture Behavioral of bcrypt_cracker is
    -- --------------------------------------------------------------------- --
    --                              Constants
    -- --------------------------------------------------------------------- --
    constant SUBKEY_INIT : std_logic_vector(575 downto 0) :=
           x"243F6A88_85A308D3_13198A2E_03707344_A4093822_299F31D0" &
           x"082EFA98_EC4E6C89_452821E6_38D01377_BE5466CF_34E90C6C" &
           x"C0AC29B7_C97C50DD_3F84D5B5_B5470917_9216D5D9_8979FB1B";

    -- --------------------------------------------------------------------- --
    -- Signals
    -- --------------------------------------------------------------------- --
    -- init controll signals
    signal memory_init      : std_logic;
    signal pipeline_full    : std_logic;
    signal pipeline_full_ce : std_logic;
    signal pipeline_full_sr : std_logic;
    -- sbox
    signal sbox0_init_addr : std_logic_vector ( 8 downto 0);
    signal sbox1_init_addr : std_logic_vector ( 8 downto 0);
    signal sbox2_init_addr : std_logic_vector ( 8 downto 0);
    signal sbox3_init_addr : std_logic_vector ( 8 downto 0);
    -- sbox address
    signal sbox_addr_cnt_ce     : std_logic;
    signal sbox_addr_cnt_sr     : std_logic;
    signal sbox_addr_cnt_dout   : std_logic_vector ( 8 downto 0);
    -- subkey
    signal skinit_sr        : std_logic;
    signal skinit_ce        : std_logic;
    -- sbox pipe
    signal sbox_pipe_sr     : std_logic_vector (3 downto 0);
    signal sbox_pipe_ce     : std_logic_vector (3 downto 0);
    signal sbox_pipe_din    : slv32_ary_t (3 downto 0);
    signal sbox_pipe_dout   : slv32_ary_t (3 downto 0);
    -- sbox address pipe
    signal sbox_addr_cnt_pipe_sr    : std_logic;
    signal sbox_addr_cnt_pipe_ce    : std_logic;
    signal sbox_addr_cnt_pipe_dout  : std_logic_vector ( 8 downto 0);
    -- subkey pipe
    signal skinit_pipe_sr   : std_logic;
    signal skinit_pipe_ce   : std_logic;
    signal skinit_pipe_din  : std_logic_vector (31 downto 0);
    signal skinit_pipe_dout : std_logic_vector (31 downto 0);

    -- bcrypt quadcore signals
    signal bcrypt_done     : std_logic_vector (NUMBER_OF_QUADCORES-1 downto 0);
    signal bcrypt_success  : std_logic_vector (NUMBER_OF_QUADCORES-1 downto 0);
    signal bcrypt_mem_init : std_logic_vector (NUMBER_OF_QUADCORES-1 downto 0);
    signal bcrypt_dout_we  : std_logic_vector (NUMBER_OF_QUADCORES-1 downto 0);
    signal bcrypt_dout     : slv32_ary_t (NUMBER_OF_QUADCORES-1 downto 0);
    
    -- STATUS RETURN
    signal crack_count_all  : slv32_ary_t (NUMBER_OF_QUADCORES-1 downto 0);

	-- reduction signals
	signal reduction_ctrl : std_logic_vector(NUMBER_OF_QUADCORES-1 downto 0);
	signal reduction_din  : std_logic_vector((NUMBER_OF_QUADCORES)*32 - 1 downto 0);
	signal reduction_dout : std_logic_vector(31 downto 0);
	signal reduction_valid: std_logic;

    -- config signals
    signal config         : std_logic_vector(NUMBER_OF_QUADCORES-1 downto 0);
    signal start_attack   : std_logic := '0';
    signal ready          : std_logic_vector(NUMBER_OF_QUADCORES-1 downto 0);
begin

    -- --------------------------------------------------------------------- --
    -- Instantiation    Initial SBox
    -- --------------------------------------------------------------------- --
    sbox01_init : entity work.bram
        generic map (
            DATA_WIDTH       => 32,
            ADDRESS_WIDTH    => 9,
            RW_MODE          => "RW",
            INIT_MEMORY      => true,
            INIT_FILL_ZEROES => true,
            INIT_FROM_FILE   => false,
            INIT_REVERSED    => false,
            INIT_FORMAT_HEX  => true,
            --INIT_FILE        => "sbox01_init.mif",
            INIT_VECTOR      => SBOX01_INIT_VEC
        )
        port map (
            clkA  => clk,
            weA   => '0',
            rstA  => '0',
            addrA => sbox0_init_addr,
            dinA  => (others => '0'),
            doutA => sbox_pipe_din(0),
            clkB  => clk,
            weB   => '0',
            rstB  => '0',
            addrB => sbox1_init_addr,
            dinB  => (others => '0'),
            doutB => sbox_pipe_din(1)
        );

    -- Initial Values of Sbox 2 and 3 in one BRAM core
    sbox23_init : entity work.bram
        generic map (
            DATA_WIDTH       => 32,
            ADDRESS_WIDTH    => 9,
            RW_MODE          => "RW",
            INIT_MEMORY      => true,
            INIT_FILL_ZEROES => true,
            INIT_FROM_FILE   => false,
            INIT_REVERSED    => false,
            INIT_FORMAT_HEX  => true,
            --INIT_FILE        => "sbox23_init.mif",
            INIT_VECTOR      => SBOX23_INIT_VEC
        )
        port map (
            clkA  => clk,
            weA   => '0',
            rstA  => '0',
            addrA => sbox2_init_addr,
            dinA  => (others => '0'),
            doutA => sbox_pipe_din(2),
            clkB  => clk,
            weB   => '0',
            rstB  => '0',
            addrB => sbox3_init_addr,
            dinB  => (others => '0'),
            doutB => sbox_pipe_din(3)
        );

    -- subkey initialization shiftreg
    subkey_init_reg : entity work.nxmBitShiftReg
        generic map (
            ASYNC => false,
            N     => 18,
            M     => 32
        )
        port map (
            clk    => clk,
            sr     => skinit_sr,
            srinit => SUBKEY_INIT,
            ce     => skinit_ce,
            opmode => "01", -- [Rot?, Left?] -- [shift,right]
            din    => const_slv(0, 32),
            dout   => skinit_pipe_din,
            dout_f => open
        );
	skinit_sr             <= memory_init;
	skinit_ce <= '1';

    -- --------------------------------------------------------------------- --
    -- Instantiation    Pipeline for Initialization Memories (SBox0-3, subkey)
    -- --------------------------------------------------------------------- --
    sbox_pipelines : for i in 0 to 3 generate
        sbox_i_pipeline : entity work.nxmBitShiftReg
            generic map (
                ASYNC => false,
                N     => INITIALIZATION_LATENCY-1,
                M     => 32
            )
            port map (
                clk    => clk,
                sr     => sbox_pipe_sr(i),
                srinit => const_slv(0, 32*(INITIALIZATION_LATENCY-1)),
                ce     => sbox_pipe_ce(i),
                opmode => "01", -- [Rot?, Left?] -- [shift,right]
                din    => sbox_pipe_din(i),
                dout   => sbox_pipe_dout(i),
                dout_f => open
            );
			sbox_pipe_sr(i) <= memory_init;
			sbox_pipe_ce(i) <= '1';
    end generate sbox_pipelines;

    skinit_pipeline : entity work.nxmBitShiftReg
        generic map (
            ASYNC => false,
            N     => INITIALIZATION_LATENCY,
            M     => 32
        )
        port map (
            clk    => clk,
            sr     => skinit_pipe_sr,
            srinit => const_slv(0, 32*INITIALIZATION_LATENCY),
            ce     => skinit_pipe_ce,
            opmode => "01", -- [Rot?, Left?] -- [shift,right]
            din    => skinit_pipe_din,
            dout   => skinit_pipe_dout,
            dout_f => open
        );
	skinit_pipe_sr <= memory_init;
	skinit_pipe_ce <= '1';

	pipeline_full_dff : entity work.dff
		generic map (
			ASYNC => false
		)
		port map (
			clk    => clk,
			sr     => pipeline_full_sr,
			srinit => '0',
			ce     => pipeline_full_ce,
			D      => '1',
			Q      => pipeline_full
		);
	pipeline_full_sr    <= memory_init;
	pipeline_full_ce <= '1' when unsigned(sbox_addr_cnt_dout) = INITIALIZATION_LATENCY-2 else '0';


    -- --------------------------------------------------------------------- --
    -- Instantiation    SBox Address Counter and Pipeline
    -- --------------------------------------------------------------------- --
    -- sbox init address counter
    sbox_init_counter : entity work.nBitCounter
        generic map (
            ASYNC       => false,
            BIT_WIDTH   => 9
        )
        port map (
            clk         => clk,
            ce          => sbox_addr_cnt_ce,
            sr          => sbox_addr_cnt_sr,
            srinit      => const_slv(0, 9),
            count_up    => '1',
            dout        => sbox_addr_cnt_dout
        );
	sbox_addr_cnt_sr <= memory_init;
	sbox_addr_cnt_ce <= '1';

    sbox_add_cnt_pipeline : entity work.nxmBitShiftReg
        generic map (
            ASYNC => false,
            N     => INITIALIZATION_LATENCY,
            M     => 9
        )
        port map (
            clk    => clk,
            sr     => sbox_addr_cnt_pipe_sr,
            srinit => const_slv(0, 9*INITIALIZATION_LATENCY),
            ce     => sbox_addr_cnt_pipe_ce,
            opmode => "01", -- [Rot?, Left?] -- [shift,right]
            din    => sbox_addr_cnt_dout,
            dout   => sbox_addr_cnt_pipe_dout,
            dout_f => open
        );
	sbox_addr_cnt_pipe_sr <= memory_init;
	sbox_addr_cnt_pipe_ce <= '1';

    -- --------------------------------------------------------------------- --
    -- Instantiation    bcrypt quadcores
    -- --------------------------------------------------------------------- --
    bcrypt_quad_cores : for i in 0 to NUMBER_OF_QUADCORES-1 generate
        -- ----------------------------------------------------------------- --
        -- Instantiation    bcrypt quadcore
        -- ----------------------------------------------------------------- --
        bcrypt_quad_core : entity work.bcrypt_quad_core
            generic map (
                INDEX => i
            )
            port map (
                -- GENERAL
                clk     => clk,
                rst     => rst,
                
                -- CONFIG
                config          => config(i),
                number_of_cracks=> number_of_cracks,
                t_salt          => t_salt,    
                t_hash          => t_hash,   
                vec_init        => vec_init,   
                vec_length      => vec_length,
                
                -- BCRYPT
                memory_init     => bcrypt_mem_init(i),
                pipeline_full   => pipeline_full,
                sbox_init_addr  => sbox_addr_cnt_pipe_dout,
                sbox0_init_dout => sbox_pipe_dout(0),
                sbox1_init_dout => sbox_pipe_dout(1),
                sbox2_init_dout => sbox_pipe_dout(2),
                sbox3_init_dout => sbox_pipe_dout(3),
                skinit_dout     => skinit_pipe_dout,

                -- CRACK RESULT
                done    => bcrypt_done(i),
                success => bcrypt_success(i),
                dout_we => bcrypt_dout_we(i),
                dout    => bcrypt_dout(i),
                -- STATUS RETURN
                crack_count => crack_count_all(i),
                ready       => ready(i),
                start_attack => start_attack
            );
		-- generate reduction input
		reduction_ctrl(i) <= bcrypt_success(i) and bcrypt_dout_we(i);
		reduction_din((i+1)*32 - 1 downto i*32) <= bcrypt_dout(i);

    end generate bcrypt_quad_cores;

	-- generate a buffered tree reduction of the result
	result_reduction_buffer : entity work.tree_buffer
		generic map (
			ASYNC   => false,
			N       => NUMBER_OF_QUADCORES,
			M       => 32,
			LUTSIZE => 4
		)
		port map (
			clk   => clk,
			rst   => rst,
			ce    => '1',
			din   => reduction_din,
			ctrl  => reduction_ctrl,
			dout  => reduction_dout,
			valid => reduction_valid
		);

    sbox0_init_addr <= '0' & sbox_addr_cnt_dout(7 downto 0);
    sbox1_init_addr <= '1' & sbox_addr_cnt_dout(7 downto 0);
    sbox2_init_addr <= '0' & sbox_addr_cnt_dout(7 downto 0);
    sbox3_init_addr <= '1' & sbox_addr_cnt_dout(7 downto 0);

    -- config enable mux to the right quadcore
    config_mux : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                config <= (others => '0');
            else
                if config_enable = '1' then
                    config(to_integer(unsigned(quadcore_id))) <= '1';
                else
                    config <= (others => '0');
                end if;
            end if;
        end if;
    end process;

	-- check if all quadcore are ready
    check_all_ready : process(ready)
    begin
        start_attack <= '1';
        for i in ready'range loop
            if ready(i) = '0' then
                start_attack <= '0';
                exit;
            end if;
        end loop;
    end process;
    
    -- init memory of bcrypt cores
    memory_init <= bcrypt_mem_init(0);
	
	-- store success flag
	success_dff : entity work.dff
		generic map (
			ASYNC => false
		)
		port map (
			clk    => clk,
			sr     => rst,
			srinit => '0',
			ce     => reduction_valid, -- dout_we signal
			D      => '1',
			Q      => success
		);

	-- output generation: use reduced output
	dout    <= reduction_dout;
	dout_we <= reduction_valid;
	-- use the done signal of the last quadcore to signal the end of the run
	done    <= bcrypt_done(NUMBER_OF_QUADCORES-1);

    -- return crack count of the selected quadcore
    crack_count <= crack_count_all(to_integer(unsigned(crack_count_index)));
end Behavioral;
