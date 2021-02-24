
################################################################
# This is a generated script based on design: design
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
set scripts_vivado_version 2019.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_script.tcl


# The design that will be created by this Tcl script contains the following
# module references:
# adder, counter

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xczu19eg-ffvc1760-2-e
   set_property BOARD_PART sugon:nf_card:part0:2.0 [current_project]
}


# CHANGE DESIGN NAME HERE
set design_name mpsoc

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
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

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

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create instance: axi_gpio to alu and set properties
  set axi_gpio_alu_operand [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_alu_operand ]
  set_property -dict [ list CONFIG.C_ALL_INPUTS {0} \
		CONFIG.C_ALL_OUTPUTS {1} \
		CONFIG.C_GPIO_WIDTH {32} \
		CONFIG.C_IS_DUAL {1} \
		CONFIG.C_ALL_INPUTS_2 {0} \
		CONFIG.C_ALL_OUTPUTS_2 {1} \
		CONFIG.C_GPIO2_WIDTH {32} ] $axi_gpio_alu_operand

  set axi_gpio_alu_op [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_alu_op ]
  set_property -dict [ list CONFIG.C_ALL_INPUTS {0} \
		CONFIG.C_ALL_OUTPUTS {1} \
		CONFIG.C_GPIO_WIDTH {3} ] $axi_gpio_alu_op

  set axi_gpio_alu_res [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_alu_res ]
  set_property -dict [ list CONFIG.C_ALL_INPUTS {1} \
		CONFIG.C_ALL_OUTPUTS {0} \
		CONFIG.C_GPIO_WIDTH {32} \
		CONFIG.C_IS_DUAL {1} \
		CONFIG.C_ALL_INPUTS_2 {1} \
		CONFIG.C_ALL_OUTPUTS_2 {0} \
		CONFIG.C_GPIO2_WIDTH {3} ] $axi_gpio_alu_res

  # Create instance: axi_gpio to reg_file and set properties
  set axi_gpio_gpr_wr [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_gpr_wr ]
  set_property -dict [ list CONFIG.C_ALL_INPUTS {0} \
		CONFIG.C_ALL_OUTPUTS {1} \
		CONFIG.C_GPIO_WIDTH {5} \
		CONFIG.C_IS_DUAL {1} \
		CONFIG.C_ALL_INPUTS_2 {0} \
		CONFIG.C_ALL_OUTPUTS_2 {1} \
		CONFIG.C_GPIO2_WIDTH {32} ] $axi_gpio_gpr_wr

  set axi_gpio_gpr_wen [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_gpr_wen ]
  set_property -dict [ list CONFIG.C_ALL_INPUTS {0} \
		CONFIG.C_ALL_OUTPUTS {1} \
		CONFIG.C_GPIO_WIDTH {1} ] $axi_gpio_gpr_wen

  set axi_gpio_gpr_raddr [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_gpr_raddr ]
  set_property -dict [ list CONFIG.C_ALL_INPUTS {0} \
		CONFIG.C_ALL_OUTPUTS {1} \
		CONFIG.C_GPIO_WIDTH {5} \
		CONFIG.C_IS_DUAL {1} \
		CONFIG.C_ALL_INPUTS_2 {0} \
		CONFIG.C_ALL_OUTPUTS_2 {1} \
		CONFIG.C_GPIO2_WIDTH {5} ] $axi_gpio_gpr_raddr

  set axi_gpio_gpr_rdata [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_gpr_rdata ]
  set_property -dict [ list CONFIG.C_ALL_INPUTS {1} \
		CONFIG.C_ALL_OUTPUTS {0} \
		CONFIG.C_GPIO_WIDTH {32} \
		CONFIG.C_IS_DUAL {1} \
		CONFIG.C_ALL_INPUTS_2 {1} \
		CONFIG.C_ALL_OUTPUTS_2 {0} \
		CONFIG.C_GPIO2_WIDTH {32} ] $axi_gpio_gpr_rdata

  # Create instance: ps8_0_axi_periph, and set properties
  set ps8_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 ps8_0_axi_periph ]
  set_property -dict [ list CONFIG.NUM_MI {7} ] $ps8_0_axi_periph


  set axi_mmio [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 axi_mmio ]
  set_property -dict [list CONFIG.ADDR_WIDTH {26}\
     CONFIG.PROTOCOL {AXI4LITE}\
  ] [get_bd_intf_ports axi_mmio]

  set ps_user_resetn [ create_bd_port -dir I -type rst ps_user_resetn ]
  set ps_fclk_clk [ create_bd_port -dir I -type clk ps_fclk_clk ]
  set_property -dict [ list \
        CONFIG.ASSOCIATED_BUSIF  axi_mmio  \
        CONFIG.ASSOCIATED_RESET  ps_user_resetn \
  ] [get_bd_ports ps_fclk_clk]  

  # Create interface connections
  connect_bd_intf_net -intf_net ps8_0_axi_periph_M00_AXI [get_bd_intf_pins axi_gpio_alu_operand/S_AXI] [get_bd_intf_pins ps8_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net ps8_0_axi_periph_M01_AXI [get_bd_intf_pins axi_gpio_alu_op/S_AXI] [get_bd_intf_pins ps8_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net ps8_0_axi_periph_M02_AXI [get_bd_intf_pins axi_gpio_alu_res/S_AXI] [get_bd_intf_pins ps8_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net ps8_0_axi_periph_M03_AXI [get_bd_intf_pins axi_gpio_gpr_wr/S_AXI] [get_bd_intf_pins ps8_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net ps8_0_axi_periph_M04_AXI [get_bd_intf_pins axi_gpio_gpr_wen/S_AXI] [get_bd_intf_pins ps8_0_axi_periph/M04_AXI]
  connect_bd_intf_net -intf_net ps8_0_axi_periph_M05_AXI [get_bd_intf_pins axi_gpio_gpr_raddr/S_AXI] [get_bd_intf_pins ps8_0_axi_periph/M05_AXI]
  connect_bd_intf_net -intf_net ps8_0_axi_periph_M06_AXI [get_bd_intf_pins axi_gpio_gpr_rdata/S_AXI] [get_bd_intf_pins ps8_0_axi_periph/M06_AXI]
  connect_bd_intf_net -intf_net zynq_ultra_ps_e_0_M_AXI_HPM0_LPD [get_bd_intf_pins ps8_0_axi_periph/S00_AXI] [get_bd_intf_ports axi_mmio]

  # Create port connections

  # block of alu
  set block_name alu
  set block_cell_name u_alu
  create_bd_cell -type module -reference $block_name $block_cell_name

  connect_bd_net -net axi_gpio_alu_operand_gpio_io_o [get_bd_pins u_alu/A] [get_bd_pins axi_gpio_alu_operand/gpio_io_o]
  connect_bd_net -net axi_gpio_alu_operand_gpio2_io_o [get_bd_pins u_alu/B] [get_bd_pins axi_gpio_alu_operand/gpio2_io_o]
  connect_bd_net -net axi_gpio_alu_op_gpio_io_o [get_bd_pins u_alu/ALUop] [get_bd_pins axi_gpio_alu_op/gpio_io_o]
  connect_bd_net -net axi_gpio_alu_res_gpio_io_i [get_bd_pins u_alu/Result] [get_bd_pins axi_gpio_alu_res/gpio_io_i]
	  
  set concat_alu_tag [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 concat_alu_tag ]
  set_property -dict [ list CONFIG.NUM_PORTS {3} ] $concat_alu_tag
  connect_bd_net [get_bd_pins u_alu/Overflow] [get_bd_pins concat_alu_tag/In0]
  connect_bd_net [get_bd_pins u_alu/CarryOut] [get_bd_pins concat_alu_tag/In1]
  connect_bd_net [get_bd_pins u_alu/Zero] [get_bd_pins concat_alu_tag/In2]
  connect_bd_net -net axi_gpio_alu_res_gpio2_io_i [get_bd_pins concat_alu_tag/dout] [get_bd_pins axi_gpio_alu_res/gpio2_io_i]
	  
  # block of register file
  set block_name reg_file
  set block_cell_name u_reg_file
  create_bd_cell -type module -reference $block_name $block_cell_name
  
  connect_bd_net -net axi_gpio_gpr_wr_gpio_io_o [get_bd_pins u_reg_file/waddr] [get_bd_pins axi_gpio_gpr_wr/gpio_io_o]
  connect_bd_net -net axi_gpio_gpr_wr_gpio2_io_o [get_bd_pins u_reg_file/wdata] [get_bd_pins axi_gpio_gpr_wr/gpio2_io_o]
  connect_bd_net -net axi_gpio_gpr_wen_gpio_io_o [get_bd_pins u_reg_file/wen] [get_bd_pins axi_gpio_gpr_wen/gpio_io_o]
  connect_bd_net -net axi_gpio_gpr_raddr_gpio_io_o [get_bd_pins u_reg_file/raddr1] [get_bd_pins axi_gpio_gpr_raddr/gpio_io_o]
  connect_bd_net -net axi_gpio_gpr_raddr_gpio2_io_o [get_bd_pins u_reg_file/raddr2] [get_bd_pins axi_gpio_gpr_raddr/gpio2_io_o]
  
  connect_bd_net -net axi_gpio_gpr_rdata_gpio_io_i [get_bd_pins u_reg_file/rdata1] [get_bd_pins axi_gpio_gpr_rdata/gpio_io_i]
  connect_bd_net -net axi_gpio_gpr_rdata_gpio2_io_i [get_bd_pins u_reg_file/rdata2] [get_bd_pins axi_gpio_gpr_rdata/gpio2_io_i]

  set reg_file_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 reg_file_reset ]
  set_property -dict [ list CONFIG.C_OPERATION {not} \
				CONFIG.C_SIZE {1} ] $reg_file_reset

  # system reset
  
  connect_bd_net -net aresetn   [get_bd_ports ps_user_resetn]\
				[get_bd_pins axi_gpio_alu_operand/s_axi_aresetn] \
				[get_bd_pins axi_gpio_alu_op/s_axi_aresetn] \
				[get_bd_pins axi_gpio_alu_res/s_axi_aresetn] \
				[get_bd_pins axi_gpio_gpr_wr/s_axi_aresetn] \
				[get_bd_pins axi_gpio_gpr_wen/s_axi_aresetn] \
				[get_bd_pins axi_gpio_gpr_raddr/s_axi_aresetn] \
				[get_bd_pins axi_gpio_gpr_rdata/s_axi_aresetn] \
				[get_bd_pins ps8_0_axi_periph/M00_ARESETN] \
				[get_bd_pins ps8_0_axi_periph/M01_ARESETN] \
				[get_bd_pins ps8_0_axi_periph/M02_ARESETN] \
				[get_bd_pins ps8_0_axi_periph/M03_ARESETN] \
				[get_bd_pins ps8_0_axi_periph/M04_ARESETN] \
				[get_bd_pins ps8_0_axi_periph/M05_ARESETN] \
				[get_bd_pins ps8_0_axi_periph/M06_ARESETN] \
				[get_bd_pins ps8_0_axi_periph/S00_ARESETN] \
				[get_bd_pins ps8_0_axi_periph/ARESETN] \
				[get_bd_pins axi_gpio_alu_operand/s_axi_aresetn] \
				[get_bd_pins reg_file_reset/Op1]

  connect_bd_net -net ps_clk    [get_bd_ports ps_fclk_clk]\
				[get_bd_pins axi_gpio_alu_operand/s_axi_aclk] \
				[get_bd_pins axi_gpio_alu_op/s_axi_aclk] \
				[get_bd_pins axi_gpio_alu_res/s_axi_aclk] \
				[get_bd_pins axi_gpio_gpr_wr/s_axi_aclk] \
				[get_bd_pins axi_gpio_gpr_wen/s_axi_aclk] \
				[get_bd_pins axi_gpio_gpr_raddr/s_axi_aclk] \
				[get_bd_pins axi_gpio_gpr_rdata/s_axi_aclk] \
				[get_bd_pins ps8_0_axi_periph/ACLK] \
				[get_bd_pins ps8_0_axi_periph/M00_ACLK] \
				[get_bd_pins ps8_0_axi_periph/M01_ACLK] \
				[get_bd_pins ps8_0_axi_periph/M02_ACLK] \
				[get_bd_pins ps8_0_axi_periph/M03_ACLK] \
				[get_bd_pins ps8_0_axi_periph/M04_ACLK] \
				[get_bd_pins ps8_0_axi_periph/M05_ACLK] \
				[get_bd_pins ps8_0_axi_periph/M06_ACLK] \
				[get_bd_pins ps8_0_axi_periph/S00_ACLK] \
  				[get_bd_pins u_reg_file/clk]
	  
  connect_bd_net [get_bd_pins reg_file_reset/Res] [get_bd_pins u_reg_file/rst]
	  
				
  # Create address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x00000000 [get_bd_addr_spaces axi_mmio] [get_bd_addr_segs axi_gpio_alu_operand/S_AXI/Reg] SEG_axi_gpio_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x00010000 [get_bd_addr_spaces axi_mmio] [get_bd_addr_segs axi_gpio_alu_op/S_AXI/Reg] SEG_axi_gpio_1_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x00020000 [get_bd_addr_spaces axi_mmio] [get_bd_addr_segs axi_gpio_alu_res/S_AXI/Reg] SEG_axi_gpio_2_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x00030000 [get_bd_addr_spaces axi_mmio] [get_bd_addr_segs axi_gpio_gpr_wr/S_AXI/Reg] SEG_axi_gpio_3_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x00040000 [get_bd_addr_spaces axi_mmio] [get_bd_addr_segs axi_gpio_gpr_wen/S_AXI/Reg] SEG_axi_gpio_4_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x00050000 [get_bd_addr_spaces axi_mmio] [get_bd_addr_segs axi_gpio_gpr_raddr/S_AXI/Reg] SEG_axi_gpio_5_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x00060000 [get_bd_addr_spaces axi_mmio] [get_bd_addr_segs axi_gpio_gpr_rdata/S_AXI/Reg] SEG_axi_gpio_6_Reg

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


