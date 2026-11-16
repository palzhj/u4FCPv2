`include "rggen_rtl_macros.vh"
module reg_table #(
  parameter ADDRESS_WIDTH = 8,
  parameter PRE_DECODE = 0,
  parameter [ADDRESS_WIDTH-1:0] BASE_ADDRESS = 0,
  parameter ERROR_STATUS = 0,
  parameter [7:0] DEFAULT_READ_DATA = 0,
  parameter INSERT_SLICER = 0,
  parameter USE_STALL = 1,
  parameter [7:0] SYN_INFO_HOUR_INITIAL_VALUE = 8'h00,
  parameter [7:0] SYN_INFO_DATE_INITIAL_VALUE = 8'h00,
  parameter [7:0] SYN_INFO_MONTH_INITIAL_VALUE = 8'h00,
  parameter [7:0] SYN_INFO_YEAR_INITIAL_VALUE = 8'h00,
  parameter [7:0] SYN_VER_INITIAL_VALUE = 8'h00,
  parameter SYS_RST_USR_RST_INITIAL_VALUE = 1'h0,
  parameter SYS_RST_DDR_RST_INITIAL_VALUE = 1'h0,
  parameter MOD_RST_MOD_RST_INITIAL_VALUE = 1'h0,
  parameter MOD_RST_QSFP_RST_INITIAL_VALUE = 1'h0,
  parameter SYS_STA_CLK_LOCK_INITIAL_VALUE = 1'h0,
  parameter SYS_STA_LCH_CLK_LOCK_INITIAL_VALUE = 1'h0,
  parameter MOD_STA_TEMP_ALM_INITIAL_VALUE = 1'h0,
  parameter MOD_STA_LV_ALM_INITIAL_VALUE = 1'h0,
  parameter MOD_STA_HV_ALM_INITIAL_VALUE = 1'h0,
  parameter MOD_STA_QSFP_ALM_INITIAL_VALUE = 1'h0,
  parameter MOD_STA_QSFP_PRS_INITIAL_VALUE = 1'h0,
  parameter MOD_STA_LCH_TEMP_ALM_INITIAL_VALUE = 1'h0,
  parameter MOD_STA_LCH_LV_ALM_INITIAL_VALUE = 1'h0,
  parameter MOD_STA_LCH_HV_ALM_INITIAL_VALUE = 1'h0,
  parameter MOD_STA_LCH_QSFP_ALM_INITIAL_VALUE = 1'h0,
  parameter MOD_STA_LCH_QSFP_PRS_INITIAL_VALUE = 1'h0,
  parameter CLK_EXT_EN_INITIAL_VALUE = 1'h0,
  parameter LV_ENABLE_INITIAL_VALUE = 1'h0,
  parameter LV_OT_AUTO_OFF_INITIAL_VALUE = 1'h0,
  parameter HV_STOP_INITIAL_VALUE = 1'h1,
  parameter HV_OC_AUTO_OFF_INITIAL_VALUE = 1'h0,
  parameter QSFP_LPMODE_INITIAL_VALUE = 1'h0
)(
  input i_clk,
  input i_rst_n,
  input i_wb_cyc,
  input i_wb_stb,
  output o_wb_stall,
  input [ADDRESS_WIDTH-1:0] i_wb_adr,
  input i_wb_we,
  input [7:0] i_wb_dat,
  input i_wb_sel,
  output o_wb_ack,
  output o_wb_err,
  output o_wb_rty,
  output [7:0] o_wb_dat,
  output o_sys_rst_usr_rst_trigger,
  output o_sys_rst_ddr_rst_trigger,
  output o_mod_rst_mod_rst_trigger,
  output o_mod_rst_qsfp_rst_trigger,
  input i_sys_sta_clk_lock,
  input i_sys_sta_lch_clk_lock,
  output o_sys_sta_lch_clk_lock_read_trigger,
  input i_mod_sta_temp_alm,
  input i_mod_sta_lv_alm,
  input i_mod_sta_hv_alm,
  input i_mod_sta_qsfp_alm,
  input i_mod_sta_qsfp_prs,
  input i_mod_sta_lch_temp_alm,
  output o_mod_sta_lch_temp_alm_read_trigger,
  input i_mod_sta_lch_lv_alm,
  output o_mod_sta_lch_lv_alm_read_trigger,
  input i_mod_sta_lch_hv_alm,
  output o_mod_sta_lch_hv_alm_read_trigger,
  input i_mod_sta_lch_qsfp_alm,
  output o_mod_sta_lch_qsfp_alm_read_trigger,
  input i_mod_sta_lch_qsfp_prs,
  output o_mod_sta_lch_qsfp_prs_read_trigger,
  output o_clk_ext_en,
  output o_lv_enable,
  output o_lv_ot_auto_off,
  output o_hv_stop,
  output o_hv_oc_auto_off,
  output o_qsfp_lpmode
);
  wire w_register_valid;
  wire [1:0] w_register_access;
  wire [7:0] w_register_address;
  wire [7:0] w_register_write_data;
  wire [7:0] w_register_strobe;
  wire [11:0] w_register_active;
  wire [11:0] w_register_ready;
  wire [23:0] w_register_status;
  wire [95:0] w_register_read_data;
  wire [383:0] w_register_value;
  rggen_wishbone_adapter #(
    .ADDRESS_WIDTH        (ADDRESS_WIDTH),
    .LOCAL_ADDRESS_WIDTH  (8),
    .BUS_WIDTH            (8),
    .REGISTERS            (12),
    .PRE_DECODE           (PRE_DECODE),
    .BASE_ADDRESS         (BASE_ADDRESS),
    .BYTE_SIZE            (256),
    .ERROR_STATUS         (ERROR_STATUS),
    .DEFAULT_READ_DATA    (DEFAULT_READ_DATA),
    .INSERT_SLICER        (INSERT_SLICER),
    .USE_STALL            (USE_STALL)
  ) u_adapter (
    .i_clk                  (i_clk),
    .i_rst_n                (i_rst_n),
    .i_wb_cyc               (i_wb_cyc),
    .i_wb_stb               (i_wb_stb),
    .o_wb_stall             (o_wb_stall),
    .i_wb_adr               (i_wb_adr),
    .i_wb_we                (i_wb_we),
    .i_wb_dat               (i_wb_dat),
    .i_wb_sel               (i_wb_sel),
    .o_wb_ack               (o_wb_ack),
    .o_wb_err               (o_wb_err),
    .o_wb_rty               (o_wb_rty),
    .o_wb_dat               (o_wb_dat),
    .o_register_valid       (w_register_valid),
    .o_register_access      (w_register_access),
    .o_register_address     (w_register_address),
    .o_register_write_data  (w_register_write_data),
    .o_register_strobe      (w_register_strobe),
    .i_register_active      (w_register_active),
    .i_register_ready       (w_register_ready),
    .i_register_status      (w_register_status),
    .i_register_read_data   (w_register_read_data)
  );
  generate if (1) begin : g_syn_info
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [31:0] w_bit_field_mask;
    wire [31:0] w_bit_field_write_data;
    wire [31:0] w_bit_field_read_data;
    wire [31:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(32, 32'hffffffff, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (0),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h00),
      .BUS_WIDTH      (8),
      .DATA_WIDTH     (32)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[0+:1]),
      .o_register_ready         (w_register_ready[0+:1]),
      .o_register_status        (w_register_status[0+:2]),
      .o_register_read_data     (w_register_read_data[0+:8]),
      .o_register_value         (w_register_value[0+:32]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_hour
      rggen_bit_field #(
        .WIDTH              (8),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1)
      ) u_bit_field (
        .i_clk              (1'b0),
        .i_rst_n            (1'b0),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[0+:8]),
        .i_sw_write_data    (w_bit_field_write_data[0+:8]),
        .o_sw_read_data     (w_bit_field_read_data[0+:8]),
        .o_sw_value         (w_bit_field_value[0+:8]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({8{1'b0}}),
        .i_hw_set           ({8{1'b0}}),
        .i_hw_clear         ({8{1'b0}}),
        .i_value            (SYN_INFO_HOUR_INITIAL_VALUE),
        .i_mask             ({8{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_date
      rggen_bit_field #(
        .WIDTH              (8),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1)
      ) u_bit_field (
        .i_clk              (1'b0),
        .i_rst_n            (1'b0),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[8+:8]),
        .i_sw_write_data    (w_bit_field_write_data[8+:8]),
        .o_sw_read_data     (w_bit_field_read_data[8+:8]),
        .o_sw_value         (w_bit_field_value[8+:8]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({8{1'b0}}),
        .i_hw_set           ({8{1'b0}}),
        .i_hw_clear         ({8{1'b0}}),
        .i_value            (SYN_INFO_DATE_INITIAL_VALUE),
        .i_mask             ({8{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_month
      rggen_bit_field #(
        .WIDTH              (8),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1)
      ) u_bit_field (
        .i_clk              (1'b0),
        .i_rst_n            (1'b0),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[16+:8]),
        .i_sw_write_data    (w_bit_field_write_data[16+:8]),
        .o_sw_read_data     (w_bit_field_read_data[16+:8]),
        .o_sw_value         (w_bit_field_value[16+:8]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({8{1'b0}}),
        .i_hw_set           ({8{1'b0}}),
        .i_hw_clear         ({8{1'b0}}),
        .i_value            (SYN_INFO_MONTH_INITIAL_VALUE),
        .i_mask             ({8{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_year
      rggen_bit_field #(
        .WIDTH              (8),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1)
      ) u_bit_field (
        .i_clk              (1'b0),
        .i_rst_n            (1'b0),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[24+:8]),
        .i_sw_write_data    (w_bit_field_write_data[24+:8]),
        .o_sw_read_data     (w_bit_field_read_data[24+:8]),
        .o_sw_value         (w_bit_field_value[24+:8]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({8{1'b0}}),
        .i_hw_set           ({8{1'b0}}),
        .i_hw_clear         ({8{1'b0}}),
        .i_value            (SYN_INFO_YEAR_INITIAL_VALUE),
        .i_mask             ({8{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_syn_ver
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [7:0] w_bit_field_mask;
    wire [7:0] w_bit_field_write_data;
    wire [7:0] w_bit_field_read_data;
    wire [7:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(8, 8'hff, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (0),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h04),
      .BUS_WIDTH      (8),
      .DATA_WIDTH     (8)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[1+:1]),
      .o_register_ready         (w_register_ready[1+:1]),
      .o_register_status        (w_register_status[2+:2]),
      .o_register_read_data     (w_register_read_data[8+:8]),
      .o_register_value         (w_register_value[32+:8]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_syn_ver
      rggen_bit_field #(
        .WIDTH              (8),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1)
      ) u_bit_field (
        .i_clk              (1'b0),
        .i_rst_n            (1'b0),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[0+:8]),
        .i_sw_write_data    (w_bit_field_write_data[0+:8]),
        .o_sw_read_data     (w_bit_field_read_data[0+:8]),
        .o_sw_value         (w_bit_field_value[0+:8]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({8{1'b0}}),
        .i_hw_set           ({8{1'b0}}),
        .i_hw_clear         ({8{1'b0}}),
        .i_value            (SYN_VER_INITIAL_VALUE),
        .i_mask             ({8{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_sys_rst
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [7:0] w_bit_field_mask;
    wire [7:0] w_bit_field_write_data;
    wire [7:0] w_bit_field_read_data;
    wire [7:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(8, 8'h03, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (0),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h05),
      .BUS_WIDTH      (8),
      .DATA_WIDTH     (8)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[2+:1]),
      .o_register_ready         (w_register_ready[2+:1]),
      .o_register_status        (w_register_status[4+:2]),
      .o_register_read_data     (w_register_read_data[16+:8]),
      .o_register_value         (w_register_value[64+:8]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_usr_rst
      rggen_bit_field_w01trg #(
        .TRIGGER_VALUE  (1'b1),
        .WIDTH          (1)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[0+:1]),
        .i_sw_write_data    (w_bit_field_write_data[0+:1]),
        .o_sw_read_data     (w_bit_field_read_data[0+:1]),
        .o_sw_value         (w_bit_field_value[0+:1]),
        .i_value            ({1{1'b0}}),
        .o_trigger          (o_sys_rst_usr_rst_trigger)
      );
    end
    if (1) begin : g_ddr_rst
      rggen_bit_field_w01trg #(
        .TRIGGER_VALUE  (1'b1),
        .WIDTH          (1)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[1+:1]),
        .i_sw_write_data    (w_bit_field_write_data[1+:1]),
        .o_sw_read_data     (w_bit_field_read_data[1+:1]),
        .o_sw_value         (w_bit_field_value[1+:1]),
        .i_value            ({1{1'b0}}),
        .o_trigger          (o_sys_rst_ddr_rst_trigger)
      );
    end
  end endgenerate
  generate if (1) begin : g_mod_rst
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [7:0] w_bit_field_mask;
    wire [7:0] w_bit_field_write_data;
    wire [7:0] w_bit_field_read_data;
    wire [7:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(8, 8'h03, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (0),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h06),
      .BUS_WIDTH      (8),
      .DATA_WIDTH     (8)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[3+:1]),
      .o_register_ready         (w_register_ready[3+:1]),
      .o_register_status        (w_register_status[6+:2]),
      .o_register_read_data     (w_register_read_data[24+:8]),
      .o_register_value         (w_register_value[96+:8]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_mod_rst
      rggen_bit_field_w01trg #(
        .TRIGGER_VALUE  (1'b1),
        .WIDTH          (1)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[0+:1]),
        .i_sw_write_data    (w_bit_field_write_data[0+:1]),
        .o_sw_read_data     (w_bit_field_read_data[0+:1]),
        .o_sw_value         (w_bit_field_value[0+:1]),
        .i_value            ({1{1'b0}}),
        .o_trigger          (o_mod_rst_mod_rst_trigger)
      );
    end
    if (1) begin : g_qsfp_rst
      rggen_bit_field_w01trg #(
        .TRIGGER_VALUE  (1'b1),
        .WIDTH          (1)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[1+:1]),
        .i_sw_write_data    (w_bit_field_write_data[1+:1]),
        .o_sw_read_data     (w_bit_field_read_data[1+:1]),
        .o_sw_value         (w_bit_field_value[1+:1]),
        .i_value            ({1{1'b0}}),
        .o_trigger          (o_mod_rst_qsfp_rst_trigger)
      );
    end
  end endgenerate
  generate if (1) begin : g_sys_sta
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [7:0] w_bit_field_mask;
    wire [7:0] w_bit_field_write_data;
    wire [7:0] w_bit_field_read_data;
    wire [7:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(8, 8'h01, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (0),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h07),
      .BUS_WIDTH      (8),
      .DATA_WIDTH     (8)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[4+:1]),
      .o_register_ready         (w_register_ready[4+:1]),
      .o_register_status        (w_register_status[8+:2]),
      .o_register_read_data     (w_register_read_data[32+:8]),
      .o_register_value         (w_register_value[128+:8]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_clk_lock
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[0+:1]),
        .i_sw_write_data    (w_bit_field_write_data[0+:1]),
        .o_sw_read_data     (w_bit_field_read_data[0+:1]),
        .o_sw_value         (w_bit_field_value[0+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            (i_sys_sta_clk_lock),
        .i_mask             ({1{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_sys_sta_lch
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [7:0] w_bit_field_mask;
    wire [7:0] w_bit_field_write_data;
    wire [7:0] w_bit_field_read_data;
    wire [7:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(8, 8'h01, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (0),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h08),
      .BUS_WIDTH      (8),
      .DATA_WIDTH     (8)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[5+:1]),
      .o_register_ready         (w_register_ready[5+:1]),
      .o_register_status        (w_register_status[10+:2]),
      .o_register_read_data     (w_register_read_data[40+:8]),
      .o_register_value         (w_register_value[160+:8]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_clk_lock
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (1)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[0+:1]),
        .i_sw_write_data    (w_bit_field_write_data[0+:1]),
        .o_sw_read_data     (w_bit_field_read_data[0+:1]),
        .o_sw_value         (w_bit_field_value[0+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (o_sys_sta_lch_clk_lock_read_trigger),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            (i_sys_sta_lch_clk_lock),
        .i_mask             ({1{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_mod_sta
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [7:0] w_bit_field_mask;
    wire [7:0] w_bit_field_write_data;
    wire [7:0] w_bit_field_read_data;
    wire [7:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(8, 8'h1f, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (0),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h09),
      .BUS_WIDTH      (8),
      .DATA_WIDTH     (8)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[6+:1]),
      .o_register_ready         (w_register_ready[6+:1]),
      .o_register_status        (w_register_status[12+:2]),
      .o_register_read_data     (w_register_read_data[48+:8]),
      .o_register_value         (w_register_value[192+:8]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_temp_alm
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[0+:1]),
        .i_sw_write_data    (w_bit_field_write_data[0+:1]),
        .o_sw_read_data     (w_bit_field_read_data[0+:1]),
        .o_sw_value         (w_bit_field_value[0+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            (i_mod_sta_temp_alm),
        .i_mask             ({1{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_lv_alm
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[1+:1]),
        .i_sw_write_data    (w_bit_field_write_data[1+:1]),
        .o_sw_read_data     (w_bit_field_read_data[1+:1]),
        .o_sw_value         (w_bit_field_value[1+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            (i_mod_sta_lv_alm),
        .i_mask             ({1{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_hv_alm
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[2+:1]),
        .i_sw_write_data    (w_bit_field_write_data[2+:1]),
        .o_sw_read_data     (w_bit_field_read_data[2+:1]),
        .o_sw_value         (w_bit_field_value[2+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            (i_mod_sta_hv_alm),
        .i_mask             ({1{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_qsfp_alm
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[3+:1]),
        .i_sw_write_data    (w_bit_field_write_data[3+:1]),
        .o_sw_read_data     (w_bit_field_read_data[3+:1]),
        .o_sw_value         (w_bit_field_value[3+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            (i_mod_sta_qsfp_alm),
        .i_mask             ({1{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_qsfp_prs
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[4+:1]),
        .i_sw_write_data    (w_bit_field_write_data[4+:1]),
        .o_sw_read_data     (w_bit_field_read_data[4+:1]),
        .o_sw_value         (w_bit_field_value[4+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            (i_mod_sta_qsfp_prs),
        .i_mask             ({1{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_mod_sta_lch
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [7:0] w_bit_field_mask;
    wire [7:0] w_bit_field_write_data;
    wire [7:0] w_bit_field_read_data;
    wire [7:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(8, 8'h1f, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (0),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h0a),
      .BUS_WIDTH      (8),
      .DATA_WIDTH     (8)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[7+:1]),
      .o_register_ready         (w_register_ready[7+:1]),
      .o_register_status        (w_register_status[14+:2]),
      .o_register_read_data     (w_register_read_data[56+:8]),
      .o_register_value         (w_register_value[224+:8]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_temp_alm
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (1)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[0+:1]),
        .i_sw_write_data    (w_bit_field_write_data[0+:1]),
        .o_sw_read_data     (w_bit_field_read_data[0+:1]),
        .o_sw_value         (w_bit_field_value[0+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (o_mod_sta_lch_temp_alm_read_trigger),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            (i_mod_sta_lch_temp_alm),
        .i_mask             ({1{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_lv_alm
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (1)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[1+:1]),
        .i_sw_write_data    (w_bit_field_write_data[1+:1]),
        .o_sw_read_data     (w_bit_field_read_data[1+:1]),
        .o_sw_value         (w_bit_field_value[1+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (o_mod_sta_lch_lv_alm_read_trigger),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            (i_mod_sta_lch_lv_alm),
        .i_mask             ({1{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_hv_alm
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (1)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[2+:1]),
        .i_sw_write_data    (w_bit_field_write_data[2+:1]),
        .o_sw_read_data     (w_bit_field_read_data[2+:1]),
        .o_sw_value         (w_bit_field_value[2+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (o_mod_sta_lch_hv_alm_read_trigger),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            (i_mod_sta_lch_hv_alm),
        .i_mask             ({1{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_qsfp_alm
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (1)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[3+:1]),
        .i_sw_write_data    (w_bit_field_write_data[3+:1]),
        .o_sw_read_data     (w_bit_field_read_data[3+:1]),
        .o_sw_value         (w_bit_field_value[3+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (o_mod_sta_lch_qsfp_alm_read_trigger),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            (i_mod_sta_lch_qsfp_alm),
        .i_mask             ({1{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_qsfp_prs
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (1)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[4+:1]),
        .i_sw_write_data    (w_bit_field_write_data[4+:1]),
        .o_sw_read_data     (w_bit_field_read_data[4+:1]),
        .o_sw_value         (w_bit_field_value[4+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (o_mod_sta_lch_qsfp_prs_read_trigger),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            (i_mod_sta_lch_qsfp_prs),
        .i_mask             ({1{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_clk
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [7:0] w_bit_field_mask;
    wire [7:0] w_bit_field_write_data;
    wire [7:0] w_bit_field_read_data;
    wire [7:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(8, 8'h01, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h0b),
      .BUS_WIDTH      (8),
      .DATA_WIDTH     (8)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[8+:1]),
      .o_register_ready         (w_register_ready[8+:1]),
      .o_register_status        (w_register_status[16+:2]),
      .o_register_read_data     (w_register_read_data[64+:8]),
      .o_register_value         (w_register_value[256+:8]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_ext_en
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (CLK_EXT_EN_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[0+:1]),
        .i_sw_write_data    (w_bit_field_write_data[0+:1]),
        .o_sw_read_data     (w_bit_field_read_data[0+:1]),
        .o_sw_value         (w_bit_field_value[0+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_clk_ext_en),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_lv
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [7:0] w_bit_field_mask;
    wire [7:0] w_bit_field_write_data;
    wire [7:0] w_bit_field_read_data;
    wire [7:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(8, 8'h03, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h0c),
      .BUS_WIDTH      (8),
      .DATA_WIDTH     (8)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[9+:1]),
      .o_register_ready         (w_register_ready[9+:1]),
      .o_register_status        (w_register_status[18+:2]),
      .o_register_read_data     (w_register_read_data[72+:8]),
      .o_register_value         (w_register_value[288+:8]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_enable
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (LV_ENABLE_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[0+:1]),
        .i_sw_write_data    (w_bit_field_write_data[0+:1]),
        .o_sw_read_data     (w_bit_field_read_data[0+:1]),
        .o_sw_value         (w_bit_field_value[0+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_lv_enable),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_ot_auto_off
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (LV_OT_AUTO_OFF_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[1+:1]),
        .i_sw_write_data    (w_bit_field_write_data[1+:1]),
        .o_sw_read_data     (w_bit_field_read_data[1+:1]),
        .o_sw_value         (w_bit_field_value[1+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_lv_ot_auto_off),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_hv
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [7:0] w_bit_field_mask;
    wire [7:0] w_bit_field_write_data;
    wire [7:0] w_bit_field_read_data;
    wire [7:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(8, 8'h03, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h0d),
      .BUS_WIDTH      (8),
      .DATA_WIDTH     (8)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[10+:1]),
      .o_register_ready         (w_register_ready[10+:1]),
      .o_register_status        (w_register_status[20+:2]),
      .o_register_read_data     (w_register_read_data[80+:8]),
      .o_register_value         (w_register_value[320+:8]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_stop
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (HV_STOP_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[0+:1]),
        .i_sw_write_data    (w_bit_field_write_data[0+:1]),
        .o_sw_read_data     (w_bit_field_read_data[0+:1]),
        .o_sw_value         (w_bit_field_value[0+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_hv_stop),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_oc_auto_off
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (HV_OC_AUTO_OFF_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[1+:1]),
        .i_sw_write_data    (w_bit_field_write_data[1+:1]),
        .o_sw_read_data     (w_bit_field_read_data[1+:1]),
        .o_sw_value         (w_bit_field_value[1+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_hv_oc_auto_off),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_qsfp
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [7:0] w_bit_field_mask;
    wire [7:0] w_bit_field_write_data;
    wire [7:0] w_bit_field_read_data;
    wire [7:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(8, 8'h01, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h0e),
      .BUS_WIDTH      (8),
      .DATA_WIDTH     (8)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[11+:1]),
      .o_register_ready         (w_register_ready[11+:1]),
      .o_register_status        (w_register_status[22+:2]),
      .o_register_read_data     (w_register_read_data[88+:8]),
      .o_register_value         (w_register_value[352+:8]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_lpmode
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (QSFP_LPMODE_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[0+:1]),
        .i_sw_write_data    (w_bit_field_write_data[0+:1]),
        .o_sw_read_data     (w_bit_field_read_data[0+:1]),
        .o_sw_value         (w_bit_field_value[0+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_qsfp_lpmode),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
endmodule
