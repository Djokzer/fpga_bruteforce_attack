-- (c) Copyright 1995-2024 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: xilinx.com:module_ref:cracker_regs:1.0
-- IP Revision: 1

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY axi4_attack_ctrl_cracker_regs_0_0 IS
  PORT (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    axi_ctrl_addra : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
    axi_ctrl_dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    axi_ctrl_douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    axi_ctrl_ena : IN STD_LOGIC;
    axi_ctrl_rsta : IN STD_LOGIC;
    axi_ctrl_wea : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    axi_ctrl_addrb : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
    axi_ctrl_doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    axi_ctrl_dinb : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    axi_ctrl_enb : IN STD_LOGIC;
    axi_ctrl_rstb : IN STD_LOGIC;
    axi_ctrl_web : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    bram_addr_a : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    bram_wrdata_a : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    bram_rddata_a : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    bram_en_a : OUT STD_LOGIC;
    bram_rst_a : OUT STD_LOGIC;
    bram_we_a : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    bram_addr_b : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    bram_wrdata_b : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    bram_rddata_b : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    bram_en_b : OUT STD_LOGIC;
    bram_rst_b : OUT STD_LOGIC;
    bram_we_b : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    cracker_start : OUT STD_LOGIC;
    cracker_cycle : IN STD_LOGIC
  );
END axi4_attack_ctrl_cracker_regs_0_0;

ARCHITECTURE axi4_attack_ctrl_cracker_regs_0_0_arch OF axi4_attack_ctrl_cracker_regs_0_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF axi4_attack_ctrl_cracker_regs_0_0_arch: ARCHITECTURE IS "yes";
  COMPONENT cracker_regs IS
    PORT (
      clk : IN STD_LOGIC;
      rst : IN STD_LOGIC;
      axi_ctrl_addra : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
      axi_ctrl_dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      axi_ctrl_douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      axi_ctrl_ena : IN STD_LOGIC;
      axi_ctrl_rsta : IN STD_LOGIC;
      axi_ctrl_wea : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      axi_ctrl_addrb : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
      axi_ctrl_doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      axi_ctrl_dinb : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      axi_ctrl_enb : IN STD_LOGIC;
      axi_ctrl_rstb : IN STD_LOGIC;
      axi_ctrl_web : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      bram_addr_a : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      bram_wrdata_a : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      bram_rddata_a : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      bram_en_a : OUT STD_LOGIC;
      bram_rst_a : OUT STD_LOGIC;
      bram_we_a : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      bram_addr_b : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      bram_wrdata_b : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      bram_rddata_b : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      bram_en_b : OUT STD_LOGIC;
      bram_rst_b : OUT STD_LOGIC;
      bram_we_b : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      cracker_start : OUT STD_LOGIC;
      cracker_cycle : IN STD_LOGIC
    );
  END COMPONENT cracker_regs;
  ATTRIBUTE X_CORE_INFO : STRING;
  ATTRIBUTE X_CORE_INFO OF axi4_attack_ctrl_cracker_regs_0_0_arch: ARCHITECTURE IS "cracker_regs,Vivado 2019.2";
  ATTRIBUTE CHECK_LICENSE_TYPE : STRING;
  ATTRIBUTE CHECK_LICENSE_TYPE OF axi4_attack_ctrl_cracker_regs_0_0_arch : ARCHITECTURE IS "axi4_attack_ctrl_cracker_regs_0_0,cracker_regs,{}";
  ATTRIBUTE CORE_GENERATION_INFO : STRING;
  ATTRIBUTE CORE_GENERATION_INFO OF axi4_attack_ctrl_cracker_regs_0_0_arch: ARCHITECTURE IS "axi4_attack_ctrl_cracker_regs_0_0,cracker_regs,{x_ipProduct=Vivado 2019.2,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=cracker_regs,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VHDL,x_ipSimLanguage=MIXED}";
  ATTRIBUTE IP_DEFINITION_SOURCE : STRING;
  ATTRIBUTE IP_DEFINITION_SOURCE OF axi4_attack_ctrl_cracker_regs_0_0_arch: ARCHITECTURE IS "module_ref";
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER OF rst: SIGNAL IS "XIL_INTERFACENAME rst, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF rst: SIGNAL IS "xilinx.com:signal:reset:1.0 rst RST";
  ATTRIBUTE X_INTERFACE_PARAMETER OF clk: SIGNAL IS "XIL_INTERFACENAME clk, ASSOCIATED_RESET rst, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN axi4_attack_ctrl_s_axi_aclk_0, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF clk: SIGNAL IS "xilinx.com:signal:clock:1.0 clk CLK";
BEGIN
  U0 : cracker_regs
    PORT MAP (
      clk => clk,
      rst => rst,
      axi_ctrl_addra => axi_ctrl_addra,
      axi_ctrl_dina => axi_ctrl_dina,
      axi_ctrl_douta => axi_ctrl_douta,
      axi_ctrl_ena => axi_ctrl_ena,
      axi_ctrl_rsta => axi_ctrl_rsta,
      axi_ctrl_wea => axi_ctrl_wea,
      axi_ctrl_addrb => axi_ctrl_addrb,
      axi_ctrl_doutb => axi_ctrl_doutb,
      axi_ctrl_dinb => axi_ctrl_dinb,
      axi_ctrl_enb => axi_ctrl_enb,
      axi_ctrl_rstb => axi_ctrl_rstb,
      axi_ctrl_web => axi_ctrl_web,
      bram_addr_a => bram_addr_a,
      bram_wrdata_a => bram_wrdata_a,
      bram_rddata_a => bram_rddata_a,
      bram_en_a => bram_en_a,
      bram_rst_a => bram_rst_a,
      bram_we_a => bram_we_a,
      bram_addr_b => bram_addr_b,
      bram_wrdata_b => bram_wrdata_b,
      bram_rddata_b => bram_rddata_b,
      bram_en_b => bram_en_b,
      bram_rst_b => bram_rst_b,
      bram_we_b => bram_we_b,
      cracker_start => cracker_start,
      cracker_cycle => cracker_cycle
    );
END axi4_attack_ctrl_cracker_regs_0_0_arch;
