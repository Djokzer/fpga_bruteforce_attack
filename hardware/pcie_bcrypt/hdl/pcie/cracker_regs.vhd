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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cracker_regs is
  port (
    -- General
    clk              : STD_LOGIC;
    rst              : STD_LOGIC;

    -- AXI BRAM CONTROLLER INTERFACE
    axi_ctrl_addra   : in STD_LOGIC_VECTOR ( 11 downto 0 );
    axi_ctrl_dina    : in STD_LOGIC_VECTOR ( 31 downto 0 );
    axi_ctrl_douta   : out STD_LOGIC_VECTOR ( 31 downto 0 );
    axi_ctrl_ena     : in STD_LOGIC;
    axi_ctrl_rsta    : in STD_LOGIC;
    axi_ctrl_wea     : in STD_LOGIC_VECTOR ( 3 downto 0 );

    axi_ctrl_addrb   : in STD_LOGIC_VECTOR ( 11 downto 0 );
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

    -- BCRYPT CRACKER INTERFACE
    -- (FOR PASSWORD)
    cracker_addra   : in STD_LOGIC_VECTOR ( 31 downto 0 );
    cracker_douta   : out STD_LOGIC_VECTOR ( 31 downto 0 );
    cracker_addrb   : in STD_LOGIC_VECTOR ( 31 downto 0 );
    cracker_doutb   : out STD_LOGIC_VECTOR ( 31 downto 0 );
    -- (CTRL)
    cracker_start   : out STD_LOGIC;
    cracker_cycle   : in STD_LOGIC

  );
end cracker_regs;

architecture Behavioral of cracker_regs is

begin


end Behavioral;