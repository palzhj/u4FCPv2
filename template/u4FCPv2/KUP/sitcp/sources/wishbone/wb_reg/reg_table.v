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
  parameter [7:0] SYN_VER_INITIAL_VALUE = 8'h00
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
  output [7:0] o_wb_dat
);
  wire w_register_valid;
  wire [1:0] w_register_access;
  wire [7:0] w_register_address;
  wire [7:0] w_register_write_data;
  wire [7:0] w_register_strobe;
  wire [1:0] w_register_active;
  wire [1:0] w_register_ready;
  wire [3:0] w_register_status;
  wire [15:0] w_register_read_data;
  wire [63:0] w_register_value;
  rggen_wishbone_adapter #(
    .ADDRESS_WIDTH        (ADDRESS_WIDTH),
    .LOCAL_ADDRESS_WIDTH  (8),
    .BUS_WIDTH            (8),
    .REGISTERS            (2),
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
    wire w_bit_field_valid;
    wire [31:0] w_bit_field_read_mask;
    wire [31:0] w_bit_field_write_mask;
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
      .i_clk                  (i_clk),
      .i_rst_n                (i_rst_n),
      .i_register_valid       (w_register_valid),
      .i_register_access      (w_register_access),
      .i_register_address     (w_register_address),
      .i_register_write_data  (w_register_write_data),
      .i_register_strobe      (w_register_strobe),
      .o_register_active      (w_register_active[0+:1]),
      .o_register_ready       (w_register_ready[0+:1]),
      .o_register_status      (w_register_status[0+:2]),
      .o_register_read_data   (w_register_read_data[0+:8]),
      .o_register_value       (w_register_value[0+:32]),
      .o_bit_field_valid      (w_bit_field_valid),
      .o_bit_field_read_mask  (w_bit_field_read_mask),
      .o_bit_field_write_mask (w_bit_field_write_mask),
      .o_bit_field_write_data (w_bit_field_write_data),
      .i_bit_field_read_data  (w_bit_field_read_data),
      .i_bit_field_value      (w_bit_field_value)
    );
    if (1) begin : g_hour
      rggen_bit_field #(
        .WIDTH              (8),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1)
      ) u_bit_field (
        .i_clk              (1'b0),
        .i_rst_n            (1'b0),
        .i_sw_valid         (w_bit_field_valid),
        .i_sw_read_mask     (w_bit_field_read_mask[0+:8]),
        .i_sw_write_enable  (1'b0),
        .i_sw_write_mask    (w_bit_field_write_mask[0+:8]),
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
        .i_sw_valid         (w_bit_field_valid),
        .i_sw_read_mask     (w_bit_field_read_mask[8+:8]),
        .i_sw_write_enable  (1'b0),
        .i_sw_write_mask    (w_bit_field_write_mask[8+:8]),
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
        .i_sw_valid         (w_bit_field_valid),
        .i_sw_read_mask     (w_bit_field_read_mask[16+:8]),
        .i_sw_write_enable  (1'b0),
        .i_sw_write_mask    (w_bit_field_write_mask[16+:8]),
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
        .i_sw_valid         (w_bit_field_valid),
        .i_sw_read_mask     (w_bit_field_read_mask[24+:8]),
        .i_sw_write_enable  (1'b0),
        .i_sw_write_mask    (w_bit_field_write_mask[24+:8]),
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
    wire w_bit_field_valid;
    wire [7:0] w_bit_field_read_mask;
    wire [7:0] w_bit_field_write_mask;
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
      .i_clk                  (i_clk),
      .i_rst_n                (i_rst_n),
      .i_register_valid       (w_register_valid),
      .i_register_access      (w_register_access),
      .i_register_address     (w_register_address),
      .i_register_write_data  (w_register_write_data),
      .i_register_strobe      (w_register_strobe),
      .o_register_active      (w_register_active[1+:1]),
      .o_register_ready       (w_register_ready[1+:1]),
      .o_register_status      (w_register_status[2+:2]),
      .o_register_read_data   (w_register_read_data[8+:8]),
      .o_register_value       (w_register_value[32+:8]),
      .o_bit_field_valid      (w_bit_field_valid),
      .o_bit_field_read_mask  (w_bit_field_read_mask),
      .o_bit_field_write_mask (w_bit_field_write_mask),
      .o_bit_field_write_data (w_bit_field_write_data),
      .i_bit_field_read_data  (w_bit_field_read_data),
      .i_bit_field_value      (w_bit_field_value)
    );
    if (1) begin : g_syn_ver
      rggen_bit_field #(
        .WIDTH              (8),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1)
      ) u_bit_field (
        .i_clk              (1'b0),
        .i_rst_n            (1'b0),
        .i_sw_valid         (w_bit_field_valid),
        .i_sw_read_mask     (w_bit_field_read_mask[0+:8]),
        .i_sw_write_enable  (1'b0),
        .i_sw_write_mask    (w_bit_field_write_mask[0+:8]),
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
endmodule
