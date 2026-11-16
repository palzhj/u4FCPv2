# Copyright (C) 2001-2021 CERN for the benefit of the ATLAS collaboration.
# Authors:
#               Frans Schreuder
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

if { ![info exists ::civ]} {
  set PART xcku15p-ffve1517-2-e
} elseif {$::civ == 0} {
  set PART xcku15p-ffve1517-2-e
} else {
  set PART xcku15p_CIV-ffve1517-2-e
}

set PROJECT_NAME top
set TOPLEVEL top
set SIM_TOPLEVEL top

set VERILOG_FILES "\
  top.v \
  RESET.v \
  RBCP_REG.v \
  ddr4_test.v \
  ddr4_test_engine.v \
  SiTCP/SITCP.v \
  SiTCP/MDIO_INIT.v \
  SiTCP/SiTCP_XC7K_32K_BBT_V110.V \
  SiTCP/TIMER.v \
  SiTCP/gig_ethernet_pcs_pma_support.v \
  wishbone/RBCP2WB.v \
  wishbone/wb_reg/reg_table.v \
  wishbone/wb_reg/rggen-verilog-rtl/rggen_rtl_macros.vh \
  wishbone/wb_reg/rggen-verilog-rtl/rggen_bit_field.v \
  wishbone/wb_reg/rggen-verilog-rtl/rggen_default_register.v \
  wishbone/wb_reg/rggen-verilog-rtl/rggen_register_common.v \
  wishbone/wb_reg/rggen-verilog-rtl/rggen_address_decoder.v \
  wishbone/wb_reg/rggen-verilog-rtl/rggen_wishbone_adapter.v \
  wishbone/wb_reg/rggen-verilog-rtl/rggen_adapter_common.v \
  wishbone/wb_reg/rggen-verilog-rtl/rggen_mux.v \
  wishbone/wb_reg/rggen-verilog-rtl/rggen_or_reducer.v \
  wishbone/wb_reg/rggen-verilog-rtl/rggen_bit_field_w01trg.v \
  wishbone/wb_i2c/i2c_master_top.v \
  wishbone/wb_i2c/i2c_master_bit_ctrl.v \
  wishbone/wb_i2c/i2c_master_byte_ctrl.v \
  wishbone/wb_spi/simple_spi_top.v \
  wishbone/wb_spi/fifo4.v \
  wishbone/wb_uart/uart_top.v \
  wishbone/wb_uart/uart_wb.v \
  wishbone/wb_uart/uart_regs.v \
  wishbone/wb_uart/uart_transmitter.v \
  wishbone/wb_uart/uart_sync_flops.v \
  wishbone/wb_uart/uart_receiver.v \
  wishbone/wb_uart/uart_rfifo.v \
  wishbone/wb_uart/uart_tfifo.v \
  wishbone/wb_uart/raminfr.v \
  "

set VHDL_FILES "\
  machine_clock_decode.vhd"

set NGC_FILES "\
  SiTCP/SiTCP_XC7K_32K_BBT_V110.edf"

set SIM_FILES ""

set WCFG_FILES ""

set XCI_FILES "\
  ip/clk_wiz.xci \
  ip/clk_wiz_200Mto64M.xci \
  ip/clk_wiz_64M.xci \
  ip/ila64.xci \
  ip/sitcp_fifo.xci \
  ip/xadc_wiz.xci \
  ip/gig_ethernet_pcs_pma.xci \
  ip/gig_ethernet_pcs_pma_gt.xci\
  "

set XDC_FILES "u4fcpv2_top.xdc"

# implementation only constraint (uses the MIG ui_clk names, which are not
# present during top level synthesis because the MIGs are OOC)
set XDC_IMPL_FILES "ddr4_timing.xdc"

# Set the supportfiles directory path
set scriptdir [pwd]
set firmware_dir $scriptdir/../
# Vivado project directory:
set project_dir $firmware_dir/Projects/$PROJECT_NAME


close_project -quiet
create_project -force -part $PART $PROJECT_NAME $firmware_dir/Projects/$PROJECT_NAME
set_property target_language Verilog [current_project]
set_property default_lib work [current_project]
set_property XPM_LIBRARIES {XPM_CDC XPM_MEMORY XPM_FIFO} [current_project]

foreach VERILOG_FILE $VERILOG_FILES {
  set file_path [file normalize ${firmware_dir}/sources/${VERILOG_FILE}]
  if {!($file_path in [get_files])} {
    read_verilog -library work $file_path
  }
}

foreach VHDL_FILE $VHDL_FILES {
  set file_path [file normalize ${firmware_dir}/sources/${VHDL_FILE}]
  if {!($file_path in [get_files])} {
    read_vhdl -library work $file_path
    set_property FILE_TYPE {VHDL 2008} [get_files ${file_path}]
  }
}

foreach NGC_FILE $NGC_FILES {
  set file_path [file normalize ${firmware_dir}/sources/${NGC_FILE}]
  if {!($file_path in [get_files])} {
    read_edif $file_path
  }
}

foreach XCI_FILE $XCI_FILES {
  set file_path [file normalize ${firmware_dir}/sources/${XCI_FILE}]
  if {!($file_path in [get_files])} {
    import_ip $file_path
  }
}

#-------------------------------------------------------------------------------
# DDR4 MIG IPs
#
# Two independent 64-bit non-ECC DDR4 SODIMM controllers (16 GB each). Both use
# a "No Buffer" system clock, so the single 125 MHz input buffer built in top.v
# (CLK_IN_PL) feeds both controllers instead of instantiating two input buffers
# on the same pin pair.
#-------------------------------------------------------------------------------
proc create_ddr4_ip {ip_name} {
  if {[llength [get_ips -quiet $ip_name]] != 0} {
    return
  }
  create_ip -name ddr4 -vendor xilinx.com -library ip -module_name $ip_name
  set_property -dict [list \
    {CONFIG.C0.DDR4_MemoryType}                   {SODIMMs} \
    {CONFIG.C0.DDR4_MemoryPart}                   {MTA16ATF2G64HZ-2G3} \
    {CONFIG.C0.DDR4_DataWidth}                    {64} \
    {CONFIG.C0.DDR4_Ecc}                          {false} \
    {CONFIG.C0.DDR4_MCS_ECC}                      {false} \
    {CONFIG.C0.DDR4_TimePeriod}                   {1000} \
    {CONFIG.C0.DDR4_InputClockPeriod}             {8000} \
    {CONFIG.C0.DDR4_PhyClockRatio}                {4:1} \
    {CONFIG.C0.DDR4_MemoryVoltage}                {1.2V} \
    {CONFIG.C0.DDR4_DataMask}                     {DM_NO_DBI} \
    {CONFIG.C0.DDR4_AxiSelection}                 {false} \
    {CONFIG.C0.DDR4_Capacity}                     {512} \
    {CONFIG.C0.DDR4_Mem_Add_Map}                  {ROW_COLUMN_BANK} \
    {CONFIG.C0.DDR4_CasLatency}                   {15} \
    {CONFIG.C0.DDR4_CasWriteLatency}              {14} \
    {CONFIG.C0.DDR4_Ordering}                     {Normal} \
    {CONFIG.C0.DDR4_OutputDriverImpedenceControl} {RZQ/7} \
    {CONFIG.C0.DDR4_OnDieTermination}             {RZQ/6} \
    {CONFIG.C0.DDR4_isCustom}                     {false} \
    {CONFIG.System_Clock}                         {No Buffer} \
    {CONFIG.Reference_Clock}                      {Differential} \
    {CONFIG.Example_TG}                           {SIMPLE_TG} \
    {CONFIG.Debug_Signal}                         {Disable} \
    {CONFIG.IOPowerReduction}                     {OFF} \
    {CONFIG.No_Controller}                        {1} \
    {CONFIG.Phy_Only}                             {Complete_Memory_Controller} \
  ] [get_ips $ip_name]
}

create_ddr4_ip ddr4_0
create_ddr4_ip ddr4_1

foreach XDC_FILE $XDC_FILES {
  read_xdc -verbose ${firmware_dir}/constraints/${XDC_FILE}
}

foreach XDC_FILE $XDC_IMPL_FILES {
  set xdc_path [file normalize ${firmware_dir}/constraints/${XDC_FILE}]
  read_xdc -verbose $xdc_path
  set_property used_in_synthesis false [get_files $xdc_path]
}

set_property SOURCE_SET sources_1 [get_filesets sim_1]

foreach SIM_FILE $SIM_FILES {
    add_files -fileset sim_1 -force -norecurse ${firmware_dir}/simulation/$SIM_FILE
    set_property library work [get_files  ${firmware_dir}/simulation/$SIM_FILE]
    set_property file_type {VHDL 2008} [get_files  ${firmware_dir}/simulation/$SIM_FILE]
}

foreach WCFG_FILE $WCFG_FILES {
    add_files -fileset sim_1 -force -norecurse ${firmware_dir}/simulation/$WCFG_FILE
}

if {[info exists TOPLEVEL_SIM]} {
    set_property top $TOPLEVEL_SIM [get_filesets sim_1]
}
update_compile_order -fileset sim_1

set_property -name {xsim.simulate.runtime} -value {5 us} -objects [current_fileset -simset]

set_property top $TOPLEVEL [current_fileset]
upgrade_ip [get_ips -exclude_bd_ips]
generate_target all [get_ips -exclude_bd_ips]
export_ip_user_files -of_objects [get_ips -exclude_bd_ips] -no_script -force -quiet
set MAX_IP_RUNS 6
set IP_RUNS 0
set ALL_IP_RUNS {}
foreach ip [get_ips -exclude_bd_ips] {
    set run [create_ip_run [get_ips $ip]]
    lappend ALL_IP_RUNS $run
    launch_run $run
    if { $IP_RUNS < $MAX_IP_RUNS } {
        set IP_RUNS [expr $IP_RUNS + 1]
    } else {
        #Wait on run, only if IP_RUNS == 6, run 6 ip cores parallel.
        wait_on_run $run
        set IP_RUNS 0
    }
}
# wait for every IP run, so that the following implementation run always finds
# a complete set of IP synthesis results
foreach run $ALL_IP_RUNS {
    wait_on_run $run
}
export_simulation -of_objects [get_ips -exclude_bd_ips] -force -quiet
