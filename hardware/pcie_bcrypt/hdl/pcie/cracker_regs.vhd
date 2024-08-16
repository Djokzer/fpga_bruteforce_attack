----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.08.2024 15:42:56
-- Design Name: 
-- Module Name: cracker_regs - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.pkg_bcrypt.all;

entity cracker_regs is
	generic (
		NUMBER_OF_QUADCORES     : positive := 1);
	port (
		-- General
		clk              : std_logic;
		rst              : std_logic;

		-- AXI BRAM CONTROLLER INTERFACE
		axi_ctrl_addra   : in std_logic_vector ( 15 downto 0 );
		axi_ctrl_dina    : in std_logic_vector ( 31 downto 0 );
		axi_ctrl_douta   : out std_logic_vector ( 31 downto 0 );
		axi_ctrl_ena     : in std_logic;
		axi_ctrl_rsta    : in std_logic;
		axi_ctrl_wea     : in std_logic_vector ( 3 downto 0 );

		axi_ctrl_addrb   : in std_logic_vector ( 15 downto 0 );
		axi_ctrl_doutb   : out std_logic_vector ( 31 downto 0 );
		axi_ctrl_dinb    : in std_logic_vector ( 31 downto 0 );
		axi_ctrl_enb     : in std_logic;
		axi_ctrl_rstb    : in std_logic;
		axi_ctrl_web     : in std_logic_vector ( 3 downto 0 );

		-- BRAM INTERFACE
		bram_addr_a     : out std_logic_vector ( 31 downto 0 );
		bram_wrdata_a   : out std_logic_vector ( 31 downto 0 );
		bram_rddata_a   : in std_logic_vector ( 31 downto 0 );
		bram_en_a       : out std_logic;
		bram_rst_a      : out std_logic;
		bram_we_a       : out std_logic_vector ( 3 downto 0 );

		bram_addr_b     : out std_logic_vector ( 31 downto 0 );
		bram_wrdata_b   : out std_logic_vector ( 31 downto 0 );
		bram_rddata_b   : in std_logic_vector ( 31 downto 0 );
		bram_en_b       : out std_logic;
		bram_rst_b      : out std_logic;
		bram_we_b       : out std_logic_vector ( 3 downto 0 );

		-- BCRYPT CRACKER INTERFACE
		-- (FOR PASSWORD)
		cracker_addra   : in std_logic_vector ( 31 downto 0 );
		cracker_douta   : out std_logic_vector ( 31 downto 0 );
		cracker_addrb   : in std_logic_vector ( 31 downto 0 );
		cracker_doutb   : out std_logic_vector ( 31 downto 0 );
		-- (FOR ATTACK)
		cracker_hash    : out std_logic_vector(HASH_LENGTH-1 downto 0);
		cracker_salt    : out std_logic_vector(SALT_LENGTH-1 downto 0);
		-- (CTRL)
		cracker_start   : out std_logic;
		cracker_cycle   : in std_logic
		-- (PASSWORD FOUND)
		-- done    		: in std_logic;
		-- success 		: in std_logic;
		-- dout_we 		: in std_logic;
		-- dout    		: in std_logic_vector (31 downto 0)
	);
end cracker_regs;

architecture Behavioral of cracker_regs is
	-- ATTACK SPECIFIC
	constant PASSWORD_COUNT : integer := NUMBER_OF_QUADCORES * 4 * PWD_LENGTH;
	constant HASH_BYTE_LENGTH : integer := 24; -- IT SHOULD BE 23, BUT PUT 24 TO ALIGN WITH 32 BITS TRANSFERT
	constant HASH_BYTE_REAL_LENGTH : integer := 23; -- IT SHOULD BE 23, BUT PUT 24 TO ALIGN WITH 32 BITS TRANSFERT
	constant SALT_BYTE_LENGTH : integer := 16;

	-- REGISTER ADRESSES
	constant PASSWORD_REG_ADDR : integer := 0;  									-- PASSWORDS START ADDRESS
	constant HASH_REG_ADDR : integer := PASSWORD_COUNT;  							-- HASH ADDRESS
	constant HASH_END_REG_ADDR : integer := HASH_REG_ADDR + HASH_BYTE_REAL_LENGTH;  -- HASH END ADDRESS
	constant SALT_REG_ADDR : integer := HASH_REG_ADDR + HASH_BYTE_LENGTH;  			-- SALT ADDRESS
	constant START_ATTACK_REG_ADDR : integer := SALT_REG_ADDR + SALT_BYTE_LENGTH;  	-- START ATTACK REGISTER ADDRESS
	constant CRACKER_STATE_REG_ADDR : integer := START_ATTACK_REG_ADDR + 4;  		-- CRACKER STATE REGISTER ADDRESS
	constant FOUND_PASSWORD_REG_ADDR : integer := CRACKER_STATE_REG_ADDR + 4;  		-- FOUND PASSWORD REGISTER ADDRESS
	-- REGISTERS
	signal hash_reg : std_logic_vector(HASH_LENGTH-1 downto 0);
	signal salt_reg : std_logic_vector(SALT_LENGTH-1 downto 0);
    signal start_attack_reg : std_logic := '0';  -- '0' for AXI BRAM controller, '1' for bcrypt cracker
	signal start_attack_reg_word : std_logic_vector(31 downto 0) := (others => '0'); -- Same register but in 32 bits format
	signal cracker_state_reg	 : std_logic_vector(31 downto 0) := (others => '0'); -- BIT 0 : PWD_FOUND, BIT 1 : DONE, BIT 2 - 31 : NOT USED
	
	-- AXI ADDRESSES IN INTEGER
	signal axi_addr_a_int : integer;
	signal axi_addr_b_int : integer;

	-- FOUND PASSWORD SIGNAL
	signal pwd_found : std_logic := '0';
	signal pwd_stored : std_logic := '0';
begin
    
    -- Get AXI addresses in integer
    axi_addr_a_int <= to_integer(unsigned(axi_ctrl_addra));
    axi_addr_b_int <= to_integer(unsigned(axi_ctrl_addrb));

    -- Control Logic: Determines who has access to the BRAM
    process(clk)
    begin
    if rst = '0' then
        start_attack_reg <= '0';  -- Reset to AXI BRAM controller access
    elsif rising_edge(clk) then
        -- If writing in Port A from AXI
        if axi_ctrl_ena = '1' and axi_ctrl_wea /= "0000" then
            for i in 0 to 3 loop
                if axi_ctrl_wea(i) = '1' then
                    case axi_addr_a_int is
                        -- ADDRESS RANGE FOR PASSWORDS
                        when PASSWORD_REG_ADDR to HASH_REG_ADDR-1 =>
                            -- DO NOTHING
                        
                        -- ADDRESS RANGE FOR HASH
                        when HASH_REG_ADDR to HASH_END_REG_ADDR-1 =>
                            hash_reg(8*(axi_addr_a_int-HASH_REG_ADDR+1)-1 downto 8*(axi_addr_a_int-HASH_REG_ADDR)) <= axi_ctrl_dina(8*(i+1)-1 downto 8*i);
                        
                        -- ADDRESS RANGE FOR SALT
                        when SALT_REG_ADDR to START_ATTACK_REG_ADDR-1 =>
                            salt_reg(8*(axi_addr_a_int-SALT_REG_ADDR+1)-1 downto 8*(axi_addr_a_int-SALT_REG_ADDR)) <= axi_ctrl_dina(8*(i+1)-1 downto 8*i);
                        
                        -- ADDRESS FOR START ATTACK
                        when START_ATTACK_REG_ADDR =>
                            start_attack_reg <= '1';  -- Give URAM control to bcrypt cracker

						when others =>
							-- DO NOTHING
                    end case;
                end if;
            end loop;
        end if;
        
        -- If writing in Port B from AXI
        if axi_ctrl_enb = '1' and axi_ctrl_web /= "0000" then
            for i in 0 to 3 loop
                if axi_ctrl_web(i) = '1' then
                    case axi_addr_b_int is
                        -- ADDRESS RANGE FOR PASSWORDS
                        when PASSWORD_REG_ADDR to HASH_REG_ADDR-1 =>
                            -- DO NOTHING
                        
                        -- ADDRESS RANGE FOR HASH
                        when HASH_REG_ADDR to HASH_END_REG_ADDR-1 =>
                            hash_reg(8*(axi_addr_b_int-HASH_REG_ADDR+1)-1 downto 8*(axi_addr_b_int-HASH_REG_ADDR)) <= axi_ctrl_dinb(8*(i+1)-1 downto 8*i);
                        
                        -- ADDRESS RANGE FOR SALT
                        when SALT_REG_ADDR to START_ATTACK_REG_ADDR-1 =>
                            salt_reg(8*(axi_addr_b_int-SALT_REG_ADDR+1)-1 downto 8*(axi_addr_b_int-SALT_REG_ADDR)) <= axi_ctrl_dinb(8*(i+1)-1 downto 8*i);
                        
                        -- ADDRESS FOR START ATTACK
                        when START_ATTACK_REG_ADDR =>
                            start_attack_reg <= '1';  -- Give URAM control to bcrypt cracker

						when others =>
							-- DO NOTHING
                    end case;
                end if;
            end loop;
        end if;
				
		-- If bcrypt cracker completes its operation
		if cracker_cycle = '1' then
			start_attack_reg <= '0';  -- Return control to AXI BRAM controller
		end if;
    end if;
    end process;

	-- Read register when cracker initiated
	start_attack_reg_word(31 downto 1) <= (others => '0');
	start_attack_reg_word(0) <= start_attack_reg;

	-- Output for bcrypt cracker attack
    cracker_hash <= hash_reg;
    cracker_salt <= salt_reg;
	cracker_start <= start_attack_reg;
	
	
    -- MUX for BRAM port A
    bram_addr_a <= "0000000000000000" & axi_ctrl_addra when start_attack_reg = '0' else cracker_addra;
    bram_wrdata_a <= axi_ctrl_dina when start_attack_reg = '0' else (others => '0');
    axi_ctrl_douta <= bram_rddata_a when start_attack_reg = '0' else start_attack_reg_word;
    cracker_douta <= bram_rddata_a when start_attack_reg = '1' else (others => '0');
    bram_en_a <= axi_ctrl_ena when start_attack_reg = '0' else '1';
    bram_rst_a <= axi_ctrl_rsta when start_attack_reg = '0' else rst;
    bram_we_a <= axi_ctrl_wea when start_attack_reg = '0' else (others => '0');
    
    -- MUX for BRAM port B
    bram_addr_b <= "0000000000000000" & axi_ctrl_addrb when start_attack_reg = '0' else cracker_addrb;
    bram_wrdata_b <= axi_ctrl_dinb when start_attack_reg = '0' else (others => '0');
    axi_ctrl_doutb <= bram_rddata_b when start_attack_reg = '0' else start_attack_reg_word;
    cracker_doutb <= bram_rddata_b when start_attack_reg = '1' else (others => '0');
    bram_en_b <= axi_ctrl_enb when start_attack_reg = '0' else '1';
    bram_rst_b <= axi_ctrl_rstb when start_attack_reg = '0' else rst;
    bram_we_b <= axi_ctrl_web when start_attack_reg = '0' else (others => '0');

end Behavioral;