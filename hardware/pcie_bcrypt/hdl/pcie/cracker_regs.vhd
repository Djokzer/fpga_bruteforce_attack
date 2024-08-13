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

entity cracker_regs is
  port (
    -- General
    clk              : STD_LOGIC;
    rst              : STD_LOGIC;

    -- AXI BRAM CONTROLLER INTERFACE
    axi_ctrl_addra   : in STD_LOGIC_VECTOR ( 15 downto 0 );
    axi_ctrl_dina    : in STD_LOGIC_VECTOR ( 31 downto 0 );
    axi_ctrl_douta   : out STD_LOGIC_VECTOR ( 31 downto 0 );
    axi_ctrl_ena     : in STD_LOGIC;
    axi_ctrl_rsta    : in STD_LOGIC;
    axi_ctrl_wea     : in STD_LOGIC_VECTOR ( 3 downto 0 );

    axi_ctrl_addrb   : in STD_LOGIC_VECTOR ( 15 downto 0 );
    axi_ctrl_doutb   : out STD_LOGIC_VECTOR ( 31 downto 0 );
    axi_ctrl_dinb    : in STD_LOGIC_VECTOR ( 31 downto 0 );
    axi_ctrl_enb     : in STD_LOGIC;
    axi_ctrl_rstb    : in STD_LOGIC;
    axi_ctrl_web     : in STD_LOGIC_VECTOR ( 3 downto 0 );

    -- BRAM INTERFACE
    bram_addr_a     : out STD_LOGIC_VECTOR ( 31 downto 0 );
    bram_wrdata_a   : out STD_LOGIC_VECTOR ( 31 downto 0 );
    bram_rddata_a   : in STD_LOGIC_VECTOR ( 31 downto 0 );
    bram_en_a       : out STD_LOGIC;
    bram_rst_a      : out STD_LOGIC;
    bram_we_a       : out STD_LOGIC_VECTOR ( 3 downto 0 );
    
    bram_addr_b     : out STD_LOGIC_VECTOR ( 31 downto 0 );
    bram_wrdata_b   : out STD_LOGIC_VECTOR ( 31 downto 0 );
    bram_rddata_b   : in STD_LOGIC_VECTOR ( 31 downto 0 );
    bram_en_b       : out STD_LOGIC;
    bram_rst_b      : out STD_LOGIC;
    bram_we_b       : out STD_LOGIC_VECTOR ( 3 downto 0 );

--    -- BCRYPT CRACKER INTERFACE
--    -- (FOR PASSWORD)
--    cracker_addra   : in STD_LOGIC_VECTOR ( 31 downto 0 );
--    cracker_douta   : out STD_LOGIC_VECTOR ( 31 downto 0 );
--    cracker_addrb   : in STD_LOGIC_VECTOR ( 31 downto 0 );
--    cracker_doutb   : out STD_LOGIC_VECTOR ( 31 downto 0 );
    -- (CTRL)
    cracker_start   : out STD_LOGIC;
    cracker_cycle   : in STD_LOGIC

  );
end cracker_regs;

architecture Behavioral of cracker_regs is
	-- START ATTACK REGISTER ADRESS
	constant START_REG_ADDR : STD_LOGIC_VECTOR(15 downto 0) := std_logic_vector(to_unsigned(10368, axi_ctrl_addra'length));  -- Address just after passwords
	-- START ATTACK REGISTER
    signal start_attack : STD_LOGIC := '0';  -- '0' for AXI BRAM controller, '1' for bcrypt cracker
	signal start_read_reg : std_logic_vector(31 downto 0) := (others => '0');
begin

    -- Control Logic: Determines who has access to the BRAM
    process(clk)
    begin
    if rst = '0' then
        start_attack <= '0';  -- Reset to AXI BRAM controller access
    elsif rising_edge(clk) then
		-- If start register is written (implies AXI controller initiates the cracker)
		if (axi_ctrl_wea and "0001") = "0001" and axi_ctrl_addra = START_REG_ADDR then
			start_attack <= '1';  -- Give control to bcrypt cracker
		elsif (axi_ctrl_web and "0001") = "0001" and axi_ctrl_addrb = START_REG_ADDR then
			start_attack <= '1';  -- Give control to bcrypt cracker
		end if;
				
		-- If bcrypt cracker completes its operation
		if cracker_cycle = '1' then
			start_attack <= '0';  -- Return control to AXI BRAM controller
		end if;
    end if;
    end process;

	-- Read register when cracker initiated
	start_read_reg(31 downto 1) <= (others => '0');
	start_read_reg(0) <= start_attack;

	-- Output attack
	cracker_start <= start_attack;
    
    -- MUX for BRAM port A
    --bram_addr_a <= axi_ctrl_addra when start_attack = '0' else cracker_addra;
    bram_addr_a <= "0000000000000000" & axi_ctrl_addra when start_attack = '0' else x"00000000";
    bram_wrdata_a <= axi_ctrl_dina when start_attack = '0' and axi_ctrl_addra /= START_REG_ADDR else (others => '0');
    axi_ctrl_douta <= bram_rddata_a when start_attack = '0' else start_read_reg;
    --cracker_douta <= bram_rddata_a when start_attack = '1' else (others => '0');
    bram_en_a <= axi_ctrl_ena when start_attack = '0' else '1';
    bram_rst_a <= axi_ctrl_rsta when start_attack = '0' else rst;
    bram_we_a <= axi_ctrl_wea when start_attack = '0' else (others => '0');
    
    -- MUX for BRAM port B
    --bram_addr_b <= axi_ctrl_addrb when start_attack = '0' else cracker_addrb;
    bram_addr_b <= "0000000000000000" & axi_ctrl_addrb when start_attack = '0' else x"00000000";
    bram_wrdata_b <= axi_ctrl_dinb when start_attack = '0' and axi_ctrl_addrb /= START_REG_ADDR else (others => '0');
    axi_ctrl_doutb <= bram_rddata_b when start_attack = '0' else start_read_reg;
    --cracker_doutb <= bram_rddata_b when start_attack = '1' else (others => '0');
    bram_en_b <= axi_ctrl_enb when start_attack = '0' else '1';
    bram_rst_b <= axi_ctrl_rstb when start_attack = '0' else rst;
    bram_we_b <= axi_ctrl_web when start_attack = '0' else (others => '0');

end Behavioral;