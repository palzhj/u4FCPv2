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
  parameter [1:0] TCP_MODE_INITIAL_VALUE = 2'h0,
  parameter [7:0] TCP_TEST_TX_RATE_INITIAL_VALUE = 8'h01,
  parameter [63:0] TCP_TEST_NUM_OF_DATA_INITIAL_VALUE = 64'h0000000000004000,
  parameter TCP_TEST_DATA_GEN_INITIAL_VALUE = 1'h0,
  parameter [2:0] TCP_TEST_WORD_LEN_INITIAL_VALUE = 3'h7,
  parameter TCP_TEST_SELECT_SEQ_INITIAL_VALUE = 1'h0,
  parameter [31:0] TCP_TEST_SEQ_PATTERN_INITIAL_VALUE = 32'h60808040,
  parameter [23:0] TCP_TEST_BLK_SIZE_INITIAL_VALUE = 24'h000400,
  parameter TCP_TEST_INS_ERROR_INITIAL_VALUE = 1'h0
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
  input [63:0] i_fpga_dna,
  output [1:0] o_tcp_mode,
  output [7:0] o_tcp_test_tx_rate,
  output [63:0] o_tcp_test_num_of_data,
  output o_tcp_test_data_gen,
  output [2:0] o_tcp_test_word_len,
  output o_tcp_test_select_seq,
  output [31:0] o_tcp_test_seq_pattern,
  output [23:0] o_tcp_test_blk_size,
  output o_tcp_test_ins_error_trigger
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
  wire [767:0] w_register_value;
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
      .o_register_value       (w_register_value[64+:8]),
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
  generate if (1) begin : g_fpga_dna
    wire w_bit_field_valid;
    wire [63:0] w_bit_field_read_mask;
    wire [63:0] w_bit_field_write_mask;
    wire [63:0] w_bit_field_write_data;
    wire [63:0] w_bit_field_read_data;
    wire [63:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(64, 64'hffffffffffffffff, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (0),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h05),
      .BUS_WIDTH      (8),
      .DATA_WIDTH     (64)
    ) u_register (
      .i_clk                  (i_clk),
      .i_rst_n                (i_rst_n),
      .i_register_valid       (w_register_valid),
      .i_register_access      (w_register_access),
      .i_register_address     (w_register_address),
      .i_register_write_data  (w_register_write_data),
      .i_register_strobe      (w_register_strobe),
      .o_register_active      (w_register_active[2+:1]),
      .o_register_ready       (w_register_ready[2+:1]),
      .o_register_status      (w_register_status[4+:2]),
      .o_register_read_data   (w_register_read_data[16+:8]),
      .o_register_value       (w_register_value[128+:64]),
      .o_bit_field_valid      (w_bit_field_valid),
      .o_bit_field_read_mask  (w_bit_field_read_mask),
      .o_bit_field_write_mask (w_bit_field_write_mask),
      .o_bit_field_write_data (w_bit_field_write_data),
      .i_bit_field_read_data  (w_bit_field_read_data),
      .i_bit_field_value      (w_bit_field_value)
    );
    if (1) begin : g_fpga_dna
      rggen_bit_field #(
        .WIDTH              (64),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_valid         (w_bit_field_valid),
        .i_sw_read_mask     (w_bit_field_read_mask[0+:64]),
        .i_sw_write_enable  (1'b0),
        .i_sw_write_mask    (w_bit_field_write_mask[0+:64]),
        .i_sw_write_data    (w_bit_field_write_data[0+:64]),
        .o_sw_read_data     (w_bit_field_read_data[0+:64]),
        .o_sw_value         (w_bit_field_value[0+:64]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({64{1'b0}}),
        .i_hw_set           ({64{1'b0}}),
        .i_hw_clear         ({64{1'b0}}),
        .i_value            (i_fpga_dna),
        .i_mask             ({64{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_tcp_mode
    wire w_bit_field_valid;
    wire [7:0] w_bit_field_read_mask;
    wire [7:0] w_bit_field_write_mask;
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
      .i_clk                  (i_clk),
      .i_rst_n                (i_rst_n),
      .i_register_valid       (w_register_valid),
      .i_register_access      (w_register_access),
      .i_register_address     (w_register_address),
      .i_register_write_data  (w_register_write_data),
      .i_register_strobe      (w_register_strobe),
      .o_register_active      (w_register_active[3+:1]),
      .o_register_ready       (w_register_ready[3+:1]),
      .o_register_status      (w_register_status[6+:2]),
      .o_register_read_data   (w_register_read_data[24+:8]),
      .o_register_value       (w_register_value[192+:8]),
      .o_bit_field_valid      (w_bit_field_valid),
      .o_bit_field_read_mask  (w_bit_field_read_mask),
      .o_bit_field_write_mask (w_bit_field_write_mask),
      .o_bit_field_write_data (w_bit_field_write_data),
      .i_bit_field_read_data  (w_bit_field_read_data),
      .i_bit_field_value      (w_bit_field_value)
    );
    if (1) begin : g_tcp_mode
      rggen_bit_field #(
        .WIDTH          (2),
        .INITIAL_VALUE  (TCP_MODE_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_valid         (w_bit_field_valid),
        .i_sw_read_mask     (w_bit_field_read_mask[0+:2]),
        .i_sw_write_enable  (1'b1),
        .i_sw_write_mask    (w_bit_field_write_mask[0+:2]),
        .i_sw_write_data    (w_bit_field_write_data[0+:2]),
        .o_sw_read_data     (w_bit_field_read_data[0+:2]),
        .o_sw_value         (w_bit_field_value[0+:2]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({2{1'b0}}),
        .i_hw_set           ({2{1'b0}}),
        .i_hw_clear         ({2{1'b0}}),
        .i_value            ({2{1'b0}}),
        .i_mask             ({2{1'b1}}),
        .o_value            (o_tcp_mode),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_tcp_test_tx_rate
    wire w_bit_field_valid;
    wire [7:0] w_bit_field_read_mask;
    wire [7:0] w_bit_field_write_mask;
    wire [7:0] w_bit_field_write_data;
    wire [7:0] w_bit_field_read_data;
    wire [7:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(8, 8'hff, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h0e),
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
      .o_register_active      (w_register_active[4+:1]),
      .o_register_ready       (w_register_ready[4+:1]),
      .o_register_status      (w_register_status[8+:2]),
      .o_register_read_data   (w_register_read_data[32+:8]),
      .o_register_value       (w_register_value[256+:8]),
      .o_bit_field_valid      (w_bit_field_valid),
      .o_bit_field_read_mask  (w_bit_field_read_mask),
      .o_bit_field_write_mask (w_bit_field_write_mask),
      .o_bit_field_write_data (w_bit_field_write_data),
      .i_bit_field_read_data  (w_bit_field_read_data),
      .i_bit_field_value      (w_bit_field_value)
    );
    if (1) begin : g_tcp_test_tx_rate
      rggen_bit_field #(
        .WIDTH          (8),
        .INITIAL_VALUE  (TCP_TEST_TX_RATE_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_valid         (w_bit_field_valid),
        .i_sw_read_mask     (w_bit_field_read_mask[0+:8]),
        .i_sw_write_enable  (1'b1),
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
        .i_value            ({8{1'b0}}),
        .i_mask             ({8{1'b1}}),
        .o_value            (o_tcp_test_tx_rate),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_tcp_test_num_of_data
    wire w_bit_field_valid;
    wire [63:0] w_bit_field_read_mask;
    wire [63:0] w_bit_field_write_mask;
    wire [63:0] w_bit_field_write_data;
    wire [63:0] w_bit_field_read_data;
    wire [63:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(64, 64'hffffffffffffffff, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h0f),
      .BUS_WIDTH      (8),
      .DATA_WIDTH     (64)
    ) u_register (
      .i_clk                  (i_clk),
      .i_rst_n                (i_rst_n),
      .i_register_valid       (w_register_valid),
      .i_register_access      (w_register_access),
      .i_register_address     (w_register_address),
      .i_register_write_data  (w_register_write_data),
      .i_register_strobe      (w_register_strobe),
      .o_register_active      (w_register_active[5+:1]),
      .o_register_ready       (w_register_ready[5+:1]),
      .o_register_status      (w_register_status[10+:2]),
      .o_register_read_data   (w_register_read_data[40+:8]),
      .o_register_value       (w_register_value[320+:64]),
      .o_bit_field_valid      (w_bit_field_valid),
      .o_bit_field_read_mask  (w_bit_field_read_mask),
      .o_bit_field_write_mask (w_bit_field_write_mask),
      .o_bit_field_write_data (w_bit_field_write_data),
      .i_bit_field_read_data  (w_bit_field_read_data),
      .i_bit_field_value      (w_bit_field_value)
    );
    if (1) begin : g_tcp_test_num_of_data
      rggen_bit_field #(
        .WIDTH          (64),
        .INITIAL_VALUE  (TCP_TEST_NUM_OF_DATA_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_valid         (w_bit_field_valid),
        .i_sw_read_mask     (w_bit_field_read_mask[0+:64]),
        .i_sw_write_enable  (1'b1),
        .i_sw_write_mask    (w_bit_field_write_mask[0+:64]),
        .i_sw_write_data    (w_bit_field_write_data[0+:64]),
        .o_sw_read_data     (w_bit_field_read_data[0+:64]),
        .o_sw_value         (w_bit_field_value[0+:64]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({64{1'b0}}),
        .i_hw_set           ({64{1'b0}}),
        .i_hw_clear         ({64{1'b0}}),
        .i_value            ({64{1'b0}}),
        .i_mask             ({64{1'b1}}),
        .o_value            (o_tcp_test_num_of_data),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_tcp_test_data_gen
    wire w_bit_field_valid;
    wire [7:0] w_bit_field_read_mask;
    wire [7:0] w_bit_field_write_mask;
    wire [7:0] w_bit_field_write_data;
    wire [7:0] w_bit_field_read_data;
    wire [7:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(8, 8'h01, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h17),
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
      .o_register_active      (w_register_active[6+:1]),
      .o_register_ready       (w_register_ready[6+:1]),
      .o_register_status      (w_register_status[12+:2]),
      .o_register_read_data   (w_register_read_data[48+:8]),
      .o_register_value       (w_register_value[384+:8]),
      .o_bit_field_valid      (w_bit_field_valid),
      .o_bit_field_read_mask  (w_bit_field_read_mask),
      .o_bit_field_write_mask (w_bit_field_write_mask),
      .o_bit_field_write_data (w_bit_field_write_data),
      .i_bit_field_read_data  (w_bit_field_read_data),
      .i_bit_field_value      (w_bit_field_value)
    );
    if (1) begin : g_tcp_test_data_gen
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (TCP_TEST_DATA_GEN_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_valid         (w_bit_field_valid),
        .i_sw_read_mask     (w_bit_field_read_mask[0+:1]),
        .i_sw_write_enable  (1'b1),
        .i_sw_write_mask    (w_bit_field_write_mask[0+:1]),
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
        .o_value            (o_tcp_test_data_gen),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_tcp_test_word_len
    wire w_bit_field_valid;
    wire [7:0] w_bit_field_read_mask;
    wire [7:0] w_bit_field_write_mask;
    wire [7:0] w_bit_field_write_data;
    wire [7:0] w_bit_field_read_data;
    wire [7:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(8, 8'h07, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h18),
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
      .o_register_active      (w_register_active[7+:1]),
      .o_register_ready       (w_register_ready[7+:1]),
      .o_register_status      (w_register_status[14+:2]),
      .o_register_read_data   (w_register_read_data[56+:8]),
      .o_register_value       (w_register_value[448+:8]),
      .o_bit_field_valid      (w_bit_field_valid),
      .o_bit_field_read_mask  (w_bit_field_read_mask),
      .o_bit_field_write_mask (w_bit_field_write_mask),
      .o_bit_field_write_data (w_bit_field_write_data),
      .i_bit_field_read_data  (w_bit_field_read_data),
      .i_bit_field_value      (w_bit_field_value)
    );
    if (1) begin : g_tcp_test_word_len
      rggen_bit_field #(
        .WIDTH          (3),
        .INITIAL_VALUE  (TCP_TEST_WORD_LEN_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_valid         (w_bit_field_valid),
        .i_sw_read_mask     (w_bit_field_read_mask[0+:3]),
        .i_sw_write_enable  (1'b1),
        .i_sw_write_mask    (w_bit_field_write_mask[0+:3]),
        .i_sw_write_data    (w_bit_field_write_data[0+:3]),
        .o_sw_read_data     (w_bit_field_read_data[0+:3]),
        .o_sw_value         (w_bit_field_value[0+:3]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({3{1'b0}}),
        .i_hw_set           ({3{1'b0}}),
        .i_hw_clear         ({3{1'b0}}),
        .i_value            ({3{1'b0}}),
        .i_mask             ({3{1'b1}}),
        .o_value            (o_tcp_test_word_len),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_tcp_test_select_seq
    wire w_bit_field_valid;
    wire [7:0] w_bit_field_read_mask;
    wire [7:0] w_bit_field_write_mask;
    wire [7:0] w_bit_field_write_data;
    wire [7:0] w_bit_field_read_data;
    wire [7:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(8, 8'h01, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h19),
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
      .o_register_active      (w_register_active[8+:1]),
      .o_register_ready       (w_register_ready[8+:1]),
      .o_register_status      (w_register_status[16+:2]),
      .o_register_read_data   (w_register_read_data[64+:8]),
      .o_register_value       (w_register_value[512+:8]),
      .o_bit_field_valid      (w_bit_field_valid),
      .o_bit_field_read_mask  (w_bit_field_read_mask),
      .o_bit_field_write_mask (w_bit_field_write_mask),
      .o_bit_field_write_data (w_bit_field_write_data),
      .i_bit_field_read_data  (w_bit_field_read_data),
      .i_bit_field_value      (w_bit_field_value)
    );
    if (1) begin : g_tcp_test_select_seq
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (TCP_TEST_SELECT_SEQ_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_valid         (w_bit_field_valid),
        .i_sw_read_mask     (w_bit_field_read_mask[0+:1]),
        .i_sw_write_enable  (1'b1),
        .i_sw_write_mask    (w_bit_field_write_mask[0+:1]),
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
        .o_value            (o_tcp_test_select_seq),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_tcp_test_seq_pattern
    wire w_bit_field_valid;
    wire [31:0] w_bit_field_read_mask;
    wire [31:0] w_bit_field_write_mask;
    wire [31:0] w_bit_field_write_data;
    wire [31:0] w_bit_field_read_data;
    wire [31:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(32, 32'hffffffff, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h1a),
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
      .o_register_active      (w_register_active[9+:1]),
      .o_register_ready       (w_register_ready[9+:1]),
      .o_register_status      (w_register_status[18+:2]),
      .o_register_read_data   (w_register_read_data[72+:8]),
      .o_register_value       (w_register_value[576+:32]),
      .o_bit_field_valid      (w_bit_field_valid),
      .o_bit_field_read_mask  (w_bit_field_read_mask),
      .o_bit_field_write_mask (w_bit_field_write_mask),
      .o_bit_field_write_data (w_bit_field_write_data),
      .i_bit_field_read_data  (w_bit_field_read_data),
      .i_bit_field_value      (w_bit_field_value)
    );
    if (1) begin : g_tcp_test_seq_pattern
      rggen_bit_field #(
        .WIDTH          (32),
        .INITIAL_VALUE  (TCP_TEST_SEQ_PATTERN_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_valid         (w_bit_field_valid),
        .i_sw_read_mask     (w_bit_field_read_mask[0+:32]),
        .i_sw_write_enable  (1'b1),
        .i_sw_write_mask    (w_bit_field_write_mask[0+:32]),
        .i_sw_write_data    (w_bit_field_write_data[0+:32]),
        .o_sw_read_data     (w_bit_field_read_data[0+:32]),
        .o_sw_value         (w_bit_field_value[0+:32]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({32{1'b0}}),
        .i_hw_set           ({32{1'b0}}),
        .i_hw_clear         ({32{1'b0}}),
        .i_value            ({32{1'b0}}),
        .i_mask             ({32{1'b1}}),
        .o_value            (o_tcp_test_seq_pattern),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_tcp_test_blk_size
    wire w_bit_field_valid;
    wire [23:0] w_bit_field_read_mask;
    wire [23:0] w_bit_field_write_mask;
    wire [23:0] w_bit_field_write_data;
    wire [23:0] w_bit_field_read_data;
    wire [23:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(24, 24'hffffff, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h1e),
      .BUS_WIDTH      (8),
      .DATA_WIDTH     (24)
    ) u_register (
      .i_clk                  (i_clk),
      .i_rst_n                (i_rst_n),
      .i_register_valid       (w_register_valid),
      .i_register_access      (w_register_access),
      .i_register_address     (w_register_address),
      .i_register_write_data  (w_register_write_data),
      .i_register_strobe      (w_register_strobe),
      .o_register_active      (w_register_active[10+:1]),
      .o_register_ready       (w_register_ready[10+:1]),
      .o_register_status      (w_register_status[20+:2]),
      .o_register_read_data   (w_register_read_data[80+:8]),
      .o_register_value       (w_register_value[640+:24]),
      .o_bit_field_valid      (w_bit_field_valid),
      .o_bit_field_read_mask  (w_bit_field_read_mask),
      .o_bit_field_write_mask (w_bit_field_write_mask),
      .o_bit_field_write_data (w_bit_field_write_data),
      .i_bit_field_read_data  (w_bit_field_read_data),
      .i_bit_field_value      (w_bit_field_value)
    );
    if (1) begin : g_tcp_test_blk_size
      rggen_bit_field #(
        .WIDTH          (24),
        .INITIAL_VALUE  (TCP_TEST_BLK_SIZE_INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_valid         (w_bit_field_valid),
        .i_sw_read_mask     (w_bit_field_read_mask[0+:24]),
        .i_sw_write_enable  (1'b1),
        .i_sw_write_mask    (w_bit_field_write_mask[0+:24]),
        .i_sw_write_data    (w_bit_field_write_data[0+:24]),
        .o_sw_read_data     (w_bit_field_read_data[0+:24]),
        .o_sw_value         (w_bit_field_value[0+:24]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({24{1'b0}}),
        .i_hw_set           ({24{1'b0}}),
        .i_hw_clear         ({24{1'b0}}),
        .i_value            ({24{1'b0}}),
        .i_mask             ({24{1'b1}}),
        .o_value            (o_tcp_test_blk_size),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_tcp_test_ins_error
    wire w_bit_field_valid;
    wire [7:0] w_bit_field_read_mask;
    wire [7:0] w_bit_field_write_mask;
    wire [7:0] w_bit_field_write_data;
    wire [7:0] w_bit_field_read_data;
    wire [7:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(8, 8'h01, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (0),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (8),
      .OFFSET_ADDRESS (8'h21),
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
      .o_register_active      (w_register_active[11+:1]),
      .o_register_ready       (w_register_ready[11+:1]),
      .o_register_status      (w_register_status[22+:2]),
      .o_register_read_data   (w_register_read_data[88+:8]),
      .o_register_value       (w_register_value[704+:8]),
      .o_bit_field_valid      (w_bit_field_valid),
      .o_bit_field_read_mask  (w_bit_field_read_mask),
      .o_bit_field_write_mask (w_bit_field_write_mask),
      .o_bit_field_write_data (w_bit_field_write_data),
      .i_bit_field_read_data  (w_bit_field_read_data),
      .i_bit_field_value      (w_bit_field_value)
    );
    if (1) begin : g_tcp_test_ins_error
      rggen_bit_field_w01trg #(
        .TRIGGER_VALUE  (1'b1),
        .WIDTH          (1)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_valid         (w_bit_field_valid),
        .i_sw_read_mask     (w_bit_field_read_mask[0+:1]),
        .i_sw_write_enable  (1'b1),
        .i_sw_write_mask    (w_bit_field_write_mask[0+:1]),
        .i_sw_write_data    (w_bit_field_write_data[0+:1]),
        .o_sw_read_data     (w_bit_field_read_data[0+:1]),
        .o_sw_value         (w_bit_field_value[0+:1]),
        .i_value            ({1{1'b0}}),
        .o_trigger          (o_tcp_test_ins_error_trigger)
      );
    end
  end endgenerate
endmodule
