--Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
--Date        : Mon Aug 12 16:32:21 2024
--Host        : HEPIA-WS-1644 running 64-bit major release  (build 9200)
--Command     : generate_target axi4_attack_ctrl.bd
--Design      : axi4_attack_ctrl
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity axi4_attack_ctrl is
  port (
    S_AXI_0_araddr : in STD_LOGIC_VECTOR ( 14 downto 0 );
    S_AXI_0_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_0_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_0_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S_AXI_0_arlock : in STD_LOGIC;
    S_AXI_0_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_0_arready : out STD_LOGIC;
    S_AXI_0_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_0_arvalid : in STD_LOGIC;
    S_AXI_0_awaddr : in STD_LOGIC_VECTOR ( 14 downto 0 );
    S_AXI_0_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_0_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_0_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S_AXI_0_awlock : in STD_LOGIC;
    S_AXI_0_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_0_awready : out STD_LOGIC;
    S_AXI_0_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_0_awvalid : in STD_LOGIC;
    S_AXI_0_bready : in STD_LOGIC;
    S_AXI_0_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_0_bvalid : out STD_LOGIC;
    S_AXI_0_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_0_rlast : out STD_LOGIC;
    S_AXI_0_rready : in STD_LOGIC;
    S_AXI_0_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_0_rvalid : out STD_LOGIC;
    S_AXI_0_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_0_wlast : in STD_LOGIC;
    S_AXI_0_wready : out STD_LOGIC;
    S_AXI_0_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_0_wvalid : in STD_LOGIC;
    cracker_cycle : in STD_LOGIC;
    cracker_start : out STD_LOGIC;
    s_axi_aclk_0 : in STD_LOGIC;
    s_axi_aresetn_0 : in STD_LOGIC
  );
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of axi4_attack_ctrl : entity is "axi4_attack_ctrl,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=axi4_attack_ctrl,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=3,numReposBlks=3,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=1,numPkgbdBlks=0,bdsource=USER,da_bram_cntlr_cnt=2,synth_mode=OOC_per_IP}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of axi4_attack_ctrl : entity is "axi4_attack_ctrl.hwdef";
end axi4_attack_ctrl;

architecture STRUCTURE of axi4_attack_ctrl is
  component axi4_attack_ctrl_axi_bram_ctrl_0_0 is
  port (
    s_axi_aclk : in STD_LOGIC;
    s_axi_aresetn : in STD_LOGIC;
    s_axi_awaddr : in STD_LOGIC_VECTOR ( 14 downto 0 );
    s_axi_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_awlock : in STD_LOGIC;
    s_axi_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_awvalid : in STD_LOGIC;
    s_axi_awready : out STD_LOGIC;
    s_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_wlast : in STD_LOGIC;
    s_axi_wvalid : in STD_LOGIC;
    s_axi_wready : out STD_LOGIC;
    s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_bvalid : out STD_LOGIC;
    s_axi_bready : in STD_LOGIC;
    s_axi_araddr : in STD_LOGIC_VECTOR ( 14 downto 0 );
    s_axi_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_arlock : in STD_LOGIC;
    s_axi_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_arvalid : in STD_LOGIC;
    s_axi_arready : out STD_LOGIC;
    s_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_rlast : out STD_LOGIC;
    s_axi_rvalid : out STD_LOGIC;
    s_axi_rready : in STD_LOGIC;
    bram_rst_a : out STD_LOGIC;
    bram_clk_a : out STD_LOGIC;
    bram_en_a : out STD_LOGIC;
    bram_we_a : out STD_LOGIC_VECTOR ( 3 downto 0 );
    bram_addr_a : out STD_LOGIC_VECTOR ( 14 downto 0 );
    bram_wrdata_a : out STD_LOGIC_VECTOR ( 31 downto 0 );
    bram_rddata_a : in STD_LOGIC_VECTOR ( 31 downto 0 );
    bram_rst_b : out STD_LOGIC;
    bram_clk_b : out STD_LOGIC;
    bram_en_b : out STD_LOGIC;
    bram_we_b : out STD_LOGIC_VECTOR ( 3 downto 0 );
    bram_addr_b : out STD_LOGIC_VECTOR ( 14 downto 0 );
    bram_wrdata_b : out STD_LOGIC_VECTOR ( 31 downto 0 );
    bram_rddata_b : in STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component axi4_attack_ctrl_axi_bram_ctrl_0_0;
  component axi4_attack_ctrl_axi_bram_ctrl_0_bram_0 is
  port (
    clka : in STD_LOGIC;
    rsta : in STD_LOGIC;
    ena : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 3 downto 0 );
    addra : in STD_LOGIC_VECTOR ( 31 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 31 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 31 downto 0 );
    clkb : in STD_LOGIC;
    rstb : in STD_LOGIC;
    enb : in STD_LOGIC;
    web : in STD_LOGIC_VECTOR ( 3 downto 0 );
    addrb : in STD_LOGIC_VECTOR ( 31 downto 0 );
    dinb : in STD_LOGIC_VECTOR ( 31 downto 0 );
    doutb : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component axi4_attack_ctrl_axi_bram_ctrl_0_bram_0;
  component axi4_attack_ctrl_cracker_regs_0_0 is
  port (
    clk : in STD_LOGIC;
    rst : in STD_LOGIC;
    axi_ctrl_addra : in STD_LOGIC_VECTOR ( 14 downto 0 );
    axi_ctrl_dina : in STD_LOGIC_VECTOR ( 31 downto 0 );
    axi_ctrl_douta : out STD_LOGIC_VECTOR ( 31 downto 0 );
    axi_ctrl_ena : in STD_LOGIC;
    axi_ctrl_rsta : in STD_LOGIC;
    axi_ctrl_wea : in STD_LOGIC_VECTOR ( 3 downto 0 );
    axi_ctrl_addrb : in STD_LOGIC_VECTOR ( 14 downto 0 );
    axi_ctrl_doutb : out STD_LOGIC_VECTOR ( 31 downto 0 );
    axi_ctrl_dinb : in STD_LOGIC_VECTOR ( 31 downto 0 );
    axi_ctrl_enb : in STD_LOGIC;
    axi_ctrl_rstb : in STD_LOGIC;
    axi_ctrl_web : in STD_LOGIC_VECTOR ( 3 downto 0 );
    bram_addr_a : out STD_LOGIC_VECTOR ( 31 downto 0 );
    bram_wrdata_a : out STD_LOGIC_VECTOR ( 31 downto 0 );
    bram_rddata_a : in STD_LOGIC_VECTOR ( 31 downto 0 );
    bram_en_a : out STD_LOGIC;
    bram_rst_a : out STD_LOGIC;
    bram_we_a : out STD_LOGIC_VECTOR ( 3 downto 0 );
    bram_addr_b : out STD_LOGIC_VECTOR ( 31 downto 0 );
    bram_wrdata_b : out STD_LOGIC_VECTOR ( 31 downto 0 );
    bram_rddata_b : in STD_LOGIC_VECTOR ( 31 downto 0 );
    bram_en_b : out STD_LOGIC;
    bram_rst_b : out STD_LOGIC;
    bram_we_b : out STD_LOGIC_VECTOR ( 3 downto 0 );
    cracker_start : out STD_LOGIC;
    cracker_cycle : in STD_LOGIC
  );
  end component axi4_attack_ctrl_cracker_regs_0_0;
  signal S_AXI_0_1_ARADDR : STD_LOGIC_VECTOR ( 14 downto 0 );
  signal S_AXI_0_1_ARBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal S_AXI_0_1_ARCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal S_AXI_0_1_ARLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal S_AXI_0_1_ARLOCK : STD_LOGIC;
  signal S_AXI_0_1_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal S_AXI_0_1_ARREADY : STD_LOGIC;
  signal S_AXI_0_1_ARSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal S_AXI_0_1_ARVALID : STD_LOGIC;
  signal S_AXI_0_1_AWADDR : STD_LOGIC_VECTOR ( 14 downto 0 );
  signal S_AXI_0_1_AWBURST : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal S_AXI_0_1_AWCACHE : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal S_AXI_0_1_AWLEN : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal S_AXI_0_1_AWLOCK : STD_LOGIC;
  signal S_AXI_0_1_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal S_AXI_0_1_AWREADY : STD_LOGIC;
  signal S_AXI_0_1_AWSIZE : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal S_AXI_0_1_AWVALID : STD_LOGIC;
  signal S_AXI_0_1_BREADY : STD_LOGIC;
  signal S_AXI_0_1_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal S_AXI_0_1_BVALID : STD_LOGIC;
  signal S_AXI_0_1_RDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal S_AXI_0_1_RLAST : STD_LOGIC;
  signal S_AXI_0_1_RREADY : STD_LOGIC;
  signal S_AXI_0_1_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal S_AXI_0_1_RVALID : STD_LOGIC;
  signal S_AXI_0_1_WDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal S_AXI_0_1_WLAST : STD_LOGIC;
  signal S_AXI_0_1_WREADY : STD_LOGIC;
  signal S_AXI_0_1_WSTRB : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal S_AXI_0_1_WVALID : STD_LOGIC;
  signal axi_bram_ctrl_0_bram_addr_a : STD_LOGIC_VECTOR ( 14 downto 0 );
  signal axi_bram_ctrl_0_bram_addr_b : STD_LOGIC_VECTOR ( 14 downto 0 );
  signal axi_bram_ctrl_0_bram_douta : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal axi_bram_ctrl_0_bram_doutb : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal axi_bram_ctrl_0_bram_en_a : STD_LOGIC;
  signal axi_bram_ctrl_0_bram_en_b : STD_LOGIC;
  signal axi_bram_ctrl_0_bram_rst_a : STD_LOGIC;
  signal axi_bram_ctrl_0_bram_rst_b : STD_LOGIC;
  signal axi_bram_ctrl_0_bram_we_a : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal axi_bram_ctrl_0_bram_we_b : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal axi_bram_ctrl_0_bram_wrdata_a : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal axi_bram_ctrl_0_bram_wrdata_b : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal cracker_cycle_0_1 : STD_LOGIC;
  signal cracker_regs_0_axi_ctrl_douta : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal cracker_regs_0_axi_ctrl_doutb : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal cracker_regs_0_bram_addr_a : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal cracker_regs_0_bram_addr_b : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal cracker_regs_0_bram_en_a : STD_LOGIC;
  signal cracker_regs_0_bram_en_b : STD_LOGIC;
  signal cracker_regs_0_bram_rst_a : STD_LOGIC;
  signal cracker_regs_0_bram_rst_b : STD_LOGIC;
  signal cracker_regs_0_bram_we_a : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal cracker_regs_0_bram_we_b : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal cracker_regs_0_bram_wrdata_a : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal cracker_regs_0_bram_wrdata_b : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal cracker_regs_0_cracker_start : STD_LOGIC;
  signal s_axi_aclk_0_1 : STD_LOGIC;
  signal s_axi_aresetn_0_1 : STD_LOGIC;
  signal NLW_axi_bram_ctrl_0_bram_clk_a_UNCONNECTED : STD_LOGIC;
  signal NLW_axi_bram_ctrl_0_bram_clk_b_UNCONNECTED : STD_LOGIC;
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of S_AXI_0_arlock : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 ARLOCK";
  attribute X_INTERFACE_INFO of S_AXI_0_arready : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 ARREADY";
  attribute X_INTERFACE_INFO of S_AXI_0_arvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 ARVALID";
  attribute X_INTERFACE_INFO of S_AXI_0_awlock : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 AWLOCK";
  attribute X_INTERFACE_INFO of S_AXI_0_awready : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 AWREADY";
  attribute X_INTERFACE_INFO of S_AXI_0_awvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 AWVALID";
  attribute X_INTERFACE_INFO of S_AXI_0_bready : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 BREADY";
  attribute X_INTERFACE_INFO of S_AXI_0_bvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 BVALID";
  attribute X_INTERFACE_INFO of S_AXI_0_rlast : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 RLAST";
  attribute X_INTERFACE_INFO of S_AXI_0_rready : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 RREADY";
  attribute X_INTERFACE_INFO of S_AXI_0_rvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 RVALID";
  attribute X_INTERFACE_INFO of S_AXI_0_wlast : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 WLAST";
  attribute X_INTERFACE_INFO of S_AXI_0_wready : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 WREADY";
  attribute X_INTERFACE_INFO of S_AXI_0_wvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 WVALID";
  attribute X_INTERFACE_INFO of s_axi_aclk_0 : signal is "xilinx.com:signal:clock:1.0 CLK.S_AXI_ACLK_0 CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of s_axi_aclk_0 : signal is "XIL_INTERFACENAME CLK.S_AXI_ACLK_0, ASSOCIATED_BUSIF S_AXI_0, ASSOCIATED_RESET s_axi_aresetn_0, CLK_DOMAIN axi4_attack_ctrl_s_axi_aclk_0, FREQ_HZ 100000000, INSERT_VIP 0, PHASE 0.000";
  attribute X_INTERFACE_INFO of s_axi_aresetn_0 : signal is "xilinx.com:signal:reset:1.0 RST.S_AXI_ARESETN_0 RST";
  attribute X_INTERFACE_PARAMETER of s_axi_aresetn_0 : signal is "XIL_INTERFACENAME RST.S_AXI_ARESETN_0, INSERT_VIP 0, POLARITY ACTIVE_LOW";
  attribute X_INTERFACE_INFO of S_AXI_0_araddr : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 ARADDR";
  attribute X_INTERFACE_PARAMETER of S_AXI_0_araddr : signal is "XIL_INTERFACENAME S_AXI_0, ADDR_WIDTH 15, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN axi4_attack_ctrl_s_axi_aclk_0, DATA_WIDTH 32, FREQ_HZ 100000000, HAS_BRESP 1, HAS_BURST 1, HAS_CACHE 1, HAS_LOCK 1, HAS_PROT 1, HAS_QOS 0, HAS_REGION 0, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 0, INSERT_VIP 0, MAX_BURST_LENGTH 256, NUM_READ_OUTSTANDING 2, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 2, NUM_WRITE_THREADS 1, PHASE 0.000, PROTOCOL AXI4, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 1, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0";
  attribute X_INTERFACE_INFO of S_AXI_0_arburst : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 ARBURST";
  attribute X_INTERFACE_INFO of S_AXI_0_arcache : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 ARCACHE";
  attribute X_INTERFACE_INFO of S_AXI_0_arlen : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 ARLEN";
  attribute X_INTERFACE_INFO of S_AXI_0_arprot : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 ARPROT";
  attribute X_INTERFACE_INFO of S_AXI_0_arsize : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 ARSIZE";
  attribute X_INTERFACE_INFO of S_AXI_0_awaddr : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 AWADDR";
  attribute X_INTERFACE_INFO of S_AXI_0_awburst : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 AWBURST";
  attribute X_INTERFACE_INFO of S_AXI_0_awcache : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 AWCACHE";
  attribute X_INTERFACE_INFO of S_AXI_0_awlen : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 AWLEN";
  attribute X_INTERFACE_INFO of S_AXI_0_awprot : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 AWPROT";
  attribute X_INTERFACE_INFO of S_AXI_0_awsize : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 AWSIZE";
  attribute X_INTERFACE_INFO of S_AXI_0_bresp : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 BRESP";
  attribute X_INTERFACE_INFO of S_AXI_0_rdata : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 RDATA";
  attribute X_INTERFACE_INFO of S_AXI_0_rresp : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 RRESP";
  attribute X_INTERFACE_INFO of S_AXI_0_wdata : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 WDATA";
  attribute X_INTERFACE_INFO of S_AXI_0_wstrb : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 WSTRB";
begin
  S_AXI_0_1_ARADDR(14 downto 0) <= S_AXI_0_araddr(14 downto 0);
  S_AXI_0_1_ARBURST(1 downto 0) <= S_AXI_0_arburst(1 downto 0);
  S_AXI_0_1_ARCACHE(3 downto 0) <= S_AXI_0_arcache(3 downto 0);
  S_AXI_0_1_ARLEN(7 downto 0) <= S_AXI_0_arlen(7 downto 0);
  S_AXI_0_1_ARLOCK <= S_AXI_0_arlock;
  S_AXI_0_1_ARPROT(2 downto 0) <= S_AXI_0_arprot(2 downto 0);
  S_AXI_0_1_ARSIZE(2 downto 0) <= S_AXI_0_arsize(2 downto 0);
  S_AXI_0_1_ARVALID <= S_AXI_0_arvalid;
  S_AXI_0_1_AWADDR(14 downto 0) <= S_AXI_0_awaddr(14 downto 0);
  S_AXI_0_1_AWBURST(1 downto 0) <= S_AXI_0_awburst(1 downto 0);
  S_AXI_0_1_AWCACHE(3 downto 0) <= S_AXI_0_awcache(3 downto 0);
  S_AXI_0_1_AWLEN(7 downto 0) <= S_AXI_0_awlen(7 downto 0);
  S_AXI_0_1_AWLOCK <= S_AXI_0_awlock;
  S_AXI_0_1_AWPROT(2 downto 0) <= S_AXI_0_awprot(2 downto 0);
  S_AXI_0_1_AWSIZE(2 downto 0) <= S_AXI_0_awsize(2 downto 0);
  S_AXI_0_1_AWVALID <= S_AXI_0_awvalid;
  S_AXI_0_1_BREADY <= S_AXI_0_bready;
  S_AXI_0_1_RREADY <= S_AXI_0_rready;
  S_AXI_0_1_WDATA(31 downto 0) <= S_AXI_0_wdata(31 downto 0);
  S_AXI_0_1_WLAST <= S_AXI_0_wlast;
  S_AXI_0_1_WSTRB(3 downto 0) <= S_AXI_0_wstrb(3 downto 0);
  S_AXI_0_1_WVALID <= S_AXI_0_wvalid;
  S_AXI_0_arready <= S_AXI_0_1_ARREADY;
  S_AXI_0_awready <= S_AXI_0_1_AWREADY;
  S_AXI_0_bresp(1 downto 0) <= S_AXI_0_1_BRESP(1 downto 0);
  S_AXI_0_bvalid <= S_AXI_0_1_BVALID;
  S_AXI_0_rdata(31 downto 0) <= S_AXI_0_1_RDATA(31 downto 0);
  S_AXI_0_rlast <= S_AXI_0_1_RLAST;
  S_AXI_0_rresp(1 downto 0) <= S_AXI_0_1_RRESP(1 downto 0);
  S_AXI_0_rvalid <= S_AXI_0_1_RVALID;
  S_AXI_0_wready <= S_AXI_0_1_WREADY;
  cracker_cycle_0_1 <= cracker_cycle;
  cracker_start <= cracker_regs_0_cracker_start;
  s_axi_aclk_0_1 <= s_axi_aclk_0;
  s_axi_aresetn_0_1 <= s_axi_aresetn_0;
axi_bram_ctrl_0: component axi4_attack_ctrl_axi_bram_ctrl_0_0
     port map (
      bram_addr_a(14 downto 0) => axi_bram_ctrl_0_bram_addr_a(14 downto 0),
      bram_addr_b(14 downto 0) => axi_bram_ctrl_0_bram_addr_b(14 downto 0),
      bram_clk_a => NLW_axi_bram_ctrl_0_bram_clk_a_UNCONNECTED,
      bram_clk_b => NLW_axi_bram_ctrl_0_bram_clk_b_UNCONNECTED,
      bram_en_a => axi_bram_ctrl_0_bram_en_a,
      bram_en_b => axi_bram_ctrl_0_bram_en_b,
      bram_rddata_a(31 downto 0) => cracker_regs_0_axi_ctrl_douta(31 downto 0),
      bram_rddata_b(31 downto 0) => cracker_regs_0_axi_ctrl_doutb(31 downto 0),
      bram_rst_a => axi_bram_ctrl_0_bram_rst_a,
      bram_rst_b => axi_bram_ctrl_0_bram_rst_b,
      bram_we_a(3 downto 0) => axi_bram_ctrl_0_bram_we_a(3 downto 0),
      bram_we_b(3 downto 0) => axi_bram_ctrl_0_bram_we_b(3 downto 0),
      bram_wrdata_a(31 downto 0) => axi_bram_ctrl_0_bram_wrdata_a(31 downto 0),
      bram_wrdata_b(31 downto 0) => axi_bram_ctrl_0_bram_wrdata_b(31 downto 0),
      s_axi_aclk => s_axi_aclk_0_1,
      s_axi_araddr(14 downto 0) => S_AXI_0_1_ARADDR(14 downto 0),
      s_axi_arburst(1 downto 0) => S_AXI_0_1_ARBURST(1 downto 0),
      s_axi_arcache(3 downto 0) => S_AXI_0_1_ARCACHE(3 downto 0),
      s_axi_aresetn => s_axi_aresetn_0_1,
      s_axi_arlen(7 downto 0) => S_AXI_0_1_ARLEN(7 downto 0),
      s_axi_arlock => S_AXI_0_1_ARLOCK,
      s_axi_arprot(2 downto 0) => S_AXI_0_1_ARPROT(2 downto 0),
      s_axi_arready => S_AXI_0_1_ARREADY,
      s_axi_arsize(2 downto 0) => S_AXI_0_1_ARSIZE(2 downto 0),
      s_axi_arvalid => S_AXI_0_1_ARVALID,
      s_axi_awaddr(14 downto 0) => S_AXI_0_1_AWADDR(14 downto 0),
      s_axi_awburst(1 downto 0) => S_AXI_0_1_AWBURST(1 downto 0),
      s_axi_awcache(3 downto 0) => S_AXI_0_1_AWCACHE(3 downto 0),
      s_axi_awlen(7 downto 0) => S_AXI_0_1_AWLEN(7 downto 0),
      s_axi_awlock => S_AXI_0_1_AWLOCK,
      s_axi_awprot(2 downto 0) => S_AXI_0_1_AWPROT(2 downto 0),
      s_axi_awready => S_AXI_0_1_AWREADY,
      s_axi_awsize(2 downto 0) => S_AXI_0_1_AWSIZE(2 downto 0),
      s_axi_awvalid => S_AXI_0_1_AWVALID,
      s_axi_bready => S_AXI_0_1_BREADY,
      s_axi_bresp(1 downto 0) => S_AXI_0_1_BRESP(1 downto 0),
      s_axi_bvalid => S_AXI_0_1_BVALID,
      s_axi_rdata(31 downto 0) => S_AXI_0_1_RDATA(31 downto 0),
      s_axi_rlast => S_AXI_0_1_RLAST,
      s_axi_rready => S_AXI_0_1_RREADY,
      s_axi_rresp(1 downto 0) => S_AXI_0_1_RRESP(1 downto 0),
      s_axi_rvalid => S_AXI_0_1_RVALID,
      s_axi_wdata(31 downto 0) => S_AXI_0_1_WDATA(31 downto 0),
      s_axi_wlast => S_AXI_0_1_WLAST,
      s_axi_wready => S_AXI_0_1_WREADY,
      s_axi_wstrb(3 downto 0) => S_AXI_0_1_WSTRB(3 downto 0),
      s_axi_wvalid => S_AXI_0_1_WVALID
    );
axi_bram_ctrl_0_bram: component axi4_attack_ctrl_axi_bram_ctrl_0_bram_0
     port map (
      addra(31 downto 0) => cracker_regs_0_bram_addr_a(31 downto 0),
      addrb(31 downto 0) => cracker_regs_0_bram_addr_b(31 downto 0),
      clka => s_axi_aclk_0_1,
      clkb => s_axi_aclk_0_1,
      dina(31 downto 0) => cracker_regs_0_bram_wrdata_a(31 downto 0),
      dinb(31 downto 0) => cracker_regs_0_bram_wrdata_b(31 downto 0),
      douta(31 downto 0) => axi_bram_ctrl_0_bram_douta(31 downto 0),
      doutb(31 downto 0) => axi_bram_ctrl_0_bram_doutb(31 downto 0),
      ena => cracker_regs_0_bram_en_a,
      enb => cracker_regs_0_bram_en_b,
      rsta => cracker_regs_0_bram_rst_a,
      rstb => cracker_regs_0_bram_rst_b,
      wea(3 downto 0) => cracker_regs_0_bram_we_a(3 downto 0),
      web(3 downto 0) => cracker_regs_0_bram_we_b(3 downto 0)
    );
cracker_regs_0: component axi4_attack_ctrl_cracker_regs_0_0
     port map (
      axi_ctrl_addra(14 downto 0) => axi_bram_ctrl_0_bram_addr_a(14 downto 0),
      axi_ctrl_addrb(14 downto 0) => axi_bram_ctrl_0_bram_addr_b(14 downto 0),
      axi_ctrl_dina(31 downto 0) => axi_bram_ctrl_0_bram_wrdata_a(31 downto 0),
      axi_ctrl_dinb(31 downto 0) => axi_bram_ctrl_0_bram_wrdata_b(31 downto 0),
      axi_ctrl_douta(31 downto 0) => cracker_regs_0_axi_ctrl_douta(31 downto 0),
      axi_ctrl_doutb(31 downto 0) => cracker_regs_0_axi_ctrl_doutb(31 downto 0),
      axi_ctrl_ena => axi_bram_ctrl_0_bram_en_a,
      axi_ctrl_enb => axi_bram_ctrl_0_bram_en_b,
      axi_ctrl_rsta => axi_bram_ctrl_0_bram_rst_a,
      axi_ctrl_rstb => axi_bram_ctrl_0_bram_rst_b,
      axi_ctrl_wea(3 downto 0) => axi_bram_ctrl_0_bram_we_a(3 downto 0),
      axi_ctrl_web(3 downto 0) => axi_bram_ctrl_0_bram_we_b(3 downto 0),
      bram_addr_a(31 downto 0) => cracker_regs_0_bram_addr_a(31 downto 0),
      bram_addr_b(31 downto 0) => cracker_regs_0_bram_addr_b(31 downto 0),
      bram_en_a => cracker_regs_0_bram_en_a,
      bram_en_b => cracker_regs_0_bram_en_b,
      bram_rddata_a(31 downto 0) => axi_bram_ctrl_0_bram_douta(31 downto 0),
      bram_rddata_b(31 downto 0) => axi_bram_ctrl_0_bram_doutb(31 downto 0),
      bram_rst_a => cracker_regs_0_bram_rst_a,
      bram_rst_b => cracker_regs_0_bram_rst_b,
      bram_we_a(3 downto 0) => cracker_regs_0_bram_we_a(3 downto 0),
      bram_we_b(3 downto 0) => cracker_regs_0_bram_we_b(3 downto 0),
      bram_wrdata_a(31 downto 0) => cracker_regs_0_bram_wrdata_a(31 downto 0),
      bram_wrdata_b(31 downto 0) => cracker_regs_0_bram_wrdata_b(31 downto 0),
      clk => s_axi_aclk_0_1,
      cracker_cycle => cracker_cycle_0_1,
      cracker_start => cracker_regs_0_cracker_start,
      rst => s_axi_aresetn_0_1
    );
end STRUCTURE;
