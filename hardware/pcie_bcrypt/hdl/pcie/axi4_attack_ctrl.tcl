
################################################################
# This is a generated script based on design: axi4_attack_ctrl
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2024.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source axi4_attack_ctrl_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# cracker_regs

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcku5p-ffvb676-2-e
   set_property BOARD_PART xilinx.com:kcu116:part0:1.5 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name axi4_attack_ctrl

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axi_bram_ctrl:4.1\
xilinx.com:ip:blk_mem_gen:8.4\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
cracker_regs\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set S_AXI_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_0 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {15} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $S_AXI_0


  # Create ports
  set s_axi_aclk_0 [ create_bd_port -dir I -type clk s_axi_aclk_0 ]
  set s_axi_aresetn_0 [ create_bd_port -dir I -type rst s_axi_aresetn_0 ]
  set cracker_addra [ create_bd_port -dir I -from 31 -to 0 cracker_addra ]
  set cracker_addrb [ create_bd_port -dir I -from 31 -to 0 cracker_addrb ]
  set cracker_cycle [ create_bd_port -dir I cracker_cycle ]
  set cracker_douta [ create_bd_port -dir O -from 31 -to 0 cracker_douta ]
  set cracker_doutb [ create_bd_port -dir O -from 31 -to 0 cracker_doutb ]
  set cracker_start [ create_bd_port -dir O cracker_start ]

  # Create instance: cracker_regs_0, and set properties
  set block_name cracker_regs
  set block_cell_name cracker_regs_0
  if { [catch {set cracker_regs_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $cracker_regs_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0 ]

  # Create instance: blk_mem_gen_0, and set properties
  set blk_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_0 ]
  set_property -dict [list \
    CONFIG.Memory_Type {True_Dual_Port_RAM} \
    CONFIG.PRIM_type_to_Implement {URAM} \
  ] $blk_mem_gen_0


  # Create interface connections
  connect_bd_intf_net -intf_net S_AXI_0_1 [get_bd_intf_ports S_AXI_0] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]

  # Create port connections
  connect_bd_net -net axi_bram_ctrl_0_bram_addr_a [get_bd_pins axi_bram_ctrl_0/bram_addr_a] [get_bd_pins cracker_regs_0/axi_ctrl_addra]
  connect_bd_net -net axi_bram_ctrl_0_bram_addr_b [get_bd_pins axi_bram_ctrl_0/bram_addr_b] [get_bd_pins cracker_regs_0/axi_ctrl_addrb]
  connect_bd_net -net axi_bram_ctrl_0_bram_en_a [get_bd_pins axi_bram_ctrl_0/bram_en_a] [get_bd_pins cracker_regs_0/axi_ctrl_ena]
  connect_bd_net -net axi_bram_ctrl_0_bram_en_b [get_bd_pins axi_bram_ctrl_0/bram_en_b] [get_bd_pins cracker_regs_0/axi_ctrl_enb]
  connect_bd_net -net axi_bram_ctrl_0_bram_rst_a [get_bd_pins axi_bram_ctrl_0/bram_rst_a] [get_bd_pins cracker_regs_0/axi_ctrl_rsta]
  connect_bd_net -net axi_bram_ctrl_0_bram_rst_b [get_bd_pins axi_bram_ctrl_0/bram_rst_b] [get_bd_pins cracker_regs_0/axi_ctrl_rstb]
  connect_bd_net -net axi_bram_ctrl_0_bram_we_a [get_bd_pins axi_bram_ctrl_0/bram_we_a] [get_bd_pins cracker_regs_0/axi_ctrl_wea]
  connect_bd_net -net axi_bram_ctrl_0_bram_we_b [get_bd_pins axi_bram_ctrl_0/bram_we_b] [get_bd_pins cracker_regs_0/axi_ctrl_web]
  connect_bd_net -net axi_bram_ctrl_0_bram_wrdata_a [get_bd_pins axi_bram_ctrl_0/bram_wrdata_a] [get_bd_pins cracker_regs_0/axi_ctrl_dina]
  connect_bd_net -net axi_bram_ctrl_0_bram_wrdata_b [get_bd_pins axi_bram_ctrl_0/bram_wrdata_b] [get_bd_pins cracker_regs_0/axi_ctrl_dinb]
  connect_bd_net -net blk_mem_gen_0_douta [get_bd_pins blk_mem_gen_0/douta] [get_bd_pins cracker_regs_0/bram_rddata_a]
  connect_bd_net -net blk_mem_gen_0_doutb [get_bd_pins blk_mem_gen_0/doutb] [get_bd_pins cracker_regs_0/bram_rddata_b]
  connect_bd_net -net cracker_addra_0_1 [get_bd_ports cracker_addra] [get_bd_pins cracker_regs_0/cracker_addra]
  connect_bd_net -net cracker_addrb_0_1 [get_bd_ports cracker_addrb] [get_bd_pins cracker_regs_0/cracker_addrb]
  connect_bd_net -net cracker_cycle_0_1 [get_bd_ports cracker_cycle] [get_bd_pins cracker_regs_0/cracker_cycle]
  connect_bd_net -net cracker_regs_0_axi_ctrl_douta [get_bd_pins cracker_regs_0/axi_ctrl_douta] [get_bd_pins axi_bram_ctrl_0/bram_rddata_a]
  connect_bd_net -net cracker_regs_0_axi_ctrl_doutb [get_bd_pins cracker_regs_0/axi_ctrl_doutb] [get_bd_pins axi_bram_ctrl_0/bram_rddata_b]
  connect_bd_net -net cracker_regs_0_bram_addr_a [get_bd_pins cracker_regs_0/bram_addr_a] [get_bd_pins blk_mem_gen_0/addra]
  connect_bd_net -net cracker_regs_0_bram_addr_b [get_bd_pins cracker_regs_0/bram_addr_b] [get_bd_pins blk_mem_gen_0/addrb]
  connect_bd_net -net cracker_regs_0_bram_en_a [get_bd_pins cracker_regs_0/bram_en_a] [get_bd_pins blk_mem_gen_0/ena]
  connect_bd_net -net cracker_regs_0_bram_en_b [get_bd_pins cracker_regs_0/bram_en_b] [get_bd_pins blk_mem_gen_0/enb]
  connect_bd_net -net cracker_regs_0_bram_rst_a [get_bd_pins cracker_regs_0/bram_rst_a] [get_bd_pins blk_mem_gen_0/rsta]
  connect_bd_net -net cracker_regs_0_bram_rst_b [get_bd_pins cracker_regs_0/bram_rst_b] [get_bd_pins blk_mem_gen_0/rstb]
  connect_bd_net -net cracker_regs_0_bram_we_a [get_bd_pins cracker_regs_0/bram_we_a] [get_bd_pins blk_mem_gen_0/wea]
  connect_bd_net -net cracker_regs_0_bram_we_b [get_bd_pins cracker_regs_0/bram_we_b] [get_bd_pins blk_mem_gen_0/web]
  connect_bd_net -net cracker_regs_0_bram_wrdata_a [get_bd_pins cracker_regs_0/bram_wrdata_a] [get_bd_pins blk_mem_gen_0/dina]
  connect_bd_net -net cracker_regs_0_bram_wrdata_b [get_bd_pins cracker_regs_0/bram_wrdata_b] [get_bd_pins blk_mem_gen_0/dinb]
  connect_bd_net -net cracker_regs_0_cracker_douta [get_bd_pins cracker_regs_0/cracker_douta] [get_bd_ports cracker_douta]
  connect_bd_net -net cracker_regs_0_cracker_doutb [get_bd_pins cracker_regs_0/cracker_doutb] [get_bd_ports cracker_doutb]
  connect_bd_net -net cracker_regs_0_cracker_start [get_bd_pins cracker_regs_0/cracker_start] [get_bd_ports cracker_start]
  connect_bd_net -net s_axi_aclk_0_1 [get_bd_ports s_axi_aclk_0] [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins blk_mem_gen_0/clka] [get_bd_pins blk_mem_gen_0/clkb] [get_bd_pins cracker_regs_0/clk]
  connect_bd_net -net s_axi_aresetn_0_1 [get_bd_ports s_axi_aresetn_0] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins cracker_regs_0/rst]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces S_AXI_0] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


