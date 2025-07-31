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

set PROJECT_NAME top
set PART  xc7k325tffg900-2
set TOPLEVEL top
set SIM_TOPLEVEL top

set VERILOG_FILES "\
  top.v \
  RESET.v \
  RBCP_REG.v \
  SiTCP/SITCP.v \
  SiTCP/MDIO_INIT.v \
  SiTCP/SiTCP_XC7K_32K_BBT_V110.V \
  SiTCP/TIMER.v \
  SiTCP/tri_mode_eth_mac_v5_5_rgmii_v2_0_if.v \
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
  DDR3L/example_top.v \
  DDR3L/mig_7series_v4_2_traffic_gen_top.v \
  DDR3L/mig_7series_v4_2_chk_win.v \
  DDR3L/mig_7series_v4_2_memc_traffic_gen.v \
  DDR3L/mig_7series_v4_2_init_mem_pattern_ctr.v \
  DDR3L/mig_7series_v4_2_cmd_gen.v \
  DDR3L/mig_7series_v4_2_memc_flow_vcontrol.v \
  DDR3L/mig_7series_v4_2_tg_status.v \
  DDR3L/mig_7series_v4_2_read_data_path.v \
  DDR3L/mig_7series_v4_2_write_data_path.v \
  DDR3L/mig_7series_v4_2_afifo.v \
  DDR3L/mig_7series_v4_2_cmd_prbs_gen.v \
  DDR3L/mig_7series_v4_2_rd_data_gen.v \
  DDR3L/mig_7series_v4_2_read_posted_fifo.v \
  DDR3L/mig_7series_v4_2_wr_data_gen.v \
  DDR3L/mig_7series_v4_2_s7ven_data_gen.v \
  DDR3L/mig_7series_v4_2_vio_init_pattern_bram.v \
  DDR3L/mig_7series_v4_2_data_prbs_gen.v \
  DDR3L/mig_7series_v4_2_tg_prbs_gen.v \
  "

set VHDL_FILES ""

set NGC_FILES "\
  SiTCP/SiTCP_XC7K_32K_BBT_V110.edf \
  "

set SIM_FILES ""

set WCFG_FILES ""

set XCI_FILES "\
  ip/clk_wiz.xci \
  ip/ila64.xci \
  ip/sitcp_fifo.xci \
  ip/xadc_wiz.xci\
  ip/ila_ddr3_native.xci \
  ip/vio_twm_ddrx.xci \
  "

set XDC_FILES "uRTMv2_top.xdc"

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

foreach XDC_FILE $XDC_FILES {
  read_xdc -verbose ${firmware_dir}/constraints/${XDC_FILE}
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
foreach ip [get_ips -exclude_bd_ips] {
    set run [create_ip_run [get_ips $ip]]
    launch_run $run
    if { $IP_RUNS < $MAX_IP_RUNS } {
        set IP_RUNS [expr $IP_RUNS + 1]
    } else {
        #Wait on run, only if IP_RUNS == 6, run 6 ip cores parallel.
        wait_on_run $run
        set IP_RUNS 0
    }
}
#wait for the last run.
wait_on_run $run
export_simulation -of_objects [get_ips -exclude_bd_ips] -force -quiet

add_files -norecurse ${firmware_dir}/sources/ip/ddr3/mig_7series_0.xci
add_files -norecurse ${firmware_dir}/sources/ip/ddr3/mig_b.prj