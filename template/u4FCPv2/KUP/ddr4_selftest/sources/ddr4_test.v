`timescale 1ps/1ps
/*******************************************************************************
* System      : u4FCP v2 DDR4 self-test                                        *
* Module      : ddr4_test                                                      *
*                                                                              *
* Description : Register file and clock domain crossing wrapper for one DDR4    *
*               self-test engine.                                              *
*                                                                              *
*               The module is a sub-device of the generic user wishbone window  *
*               (RBCP device 0x0005). Each instance owns a 64-byte block,       *
*               selected by WB_ADR[7:6] == BASE_ADDR[7:6].                     *
*                                                                              *
*               Register map (offset relative to BASE_ADDR, 8 bit accesses):    *
*                 0x00 CTRL       W: [0] start, [1] abort, [3:2] pattern        *
*                                 R: {4'h0, pattern, 2'b00}                     *
*                 0x01 STA        R: [0] calib, [1] busy, [2] pass, [3] fail,   *
*                                    [6:4] phase, [7] done                      *
*                 0x02 ERR_LANE   R: [2:0] lowest failing 64-bit lane           *
*                 0x03 LIMIT_MB   W/R: limit [7:0], 0 = whole memory            *
*                 0x04 LIMIT_MB   W/R: limit [15:8]                             *
*                 0x05 ERR_CNT    R: failing 64-byte words [7:0]                *
*                 0x06             R: [15:8]                                    *
*                 0x07             R: [23:16]                                   *
*                 0x08             R: [31:24]                                   *
*                 0x09 ERR_ADDR   R: APP address of first error [7:0]           *
*                 0x0A             R: [15:8]                                    *
*                 0x0B             R: [23:16]                                   *
*                 0x0C             R: [31:24]   (unit = 8 bytes)                *
*                 0x0D CUR_ADDR   R: current sweep address [7:0]                *
*                 0x0E             R: [15:8]                                    *
*                 0x0F             R: [23:16]                                   *
*                 0x10             R: [31:24]   (unit = 8 bytes)                *
*                 0x11 EXP_DATA   R: expected data of first error [7:0]         *
*                 0x12             R: [15:8]                                    *
*                 0x13             R: [23:16]                                   *
*                 0x14             R: [31:24]                                   *
*                 0x15             R: [39:32]                                   *
*                 0x16             R: [47:40]                                   *
*                 0x17             R: [55:48]                                   *
*                 0x18             R: [63:56]                                   *
*                 0x19 RD_DATA    R: read data of first error [7:0]             *
*                 0x1A             R: [15:8]                                    *
*                 0x1B             R: [23:16]                                   *
*                 0x1C             R: [31:24]                                   *
*                 0x1D             R: [39:32]                                   *
*                 0x1E             R: [47:40]                                   *
*                 0x1F             R: [55:48]                                   *
*                 0x20             R: [63:56]                                   *
*                 0x3F ID         R: 0xD4 (self-test firmware present)          *
*                                                                              *
*               A wishbone access to an address that belongs to this block is   *
*               always acknowledged, so the RBCP bus never hangs.               *
*******************************************************************************/
module ddr4_test #(
  parameter [7:0] BASE_ADDR = 8'h00
)(
  input               CLK,              // 125 MHz register clock
  input               RST,              // active high, register clock domain
  // Wishbone slave (already gated by the RBCP device select)
  input               WB_STB,
  input               WB_WE,
  input      [15:0]   WB_ADR,
  input      [7 :0]   WB_DAT,
  output     [7 :0]   WB_RD,
  output              WB_ACK,
  // MIG user clock domain
  input               CLK_UI,           // MIG ui_clk
  input               RST_UI,           // MIG ui_clk_sync_rst
  // MIG user interface
  output     [30:0]   APP_ADDR,
  output     [2 :0]   APP_CMD,
  output              APP_EN,
  output     [511:0]  APP_WDF_DATA,
  output              APP_WDF_WREN,
  input               APP_RDY,
  input               APP_WDF_RDY,
  input      [511:0]  APP_RD_DATA,
  input               APP_RD_DATA_VALID,
  input               CALIB_DONE
);

localparam [2:0] PH_IDLE = 3'd0;
localparam [2:0] PH_DONE = 3'd4;

////////////////////////////////////////////////////////////////////////////////
// Mailbox between the MIG user clock domain and the register clock domain
wire        SNAP_ACK;
wire        SNAP_CALIB;
wire        SNAP_BUSY;
wire        SNAP_PASS;
wire [2 :0] SNAP_STATE;
wire [31:0] SNAP_ERR_CNT;
wire [31:0] SNAP_ERR_ADDR;
wire [2 :0] SNAP_ERR_LANE;
wire [63:0] SNAP_ERR_EXP;
wire [63:0] SNAP_ERR_RD;
wire [31:0] SNAP_CUR_ADDR;

////////////////////////////////////////////////////////////////////////////////
// Wishbone access decode
wire        blk_sel = (WB_ADR[7:6] == BASE_ADDR[7:6]);
wire        loc_stb = WB_STB & blk_sel;
wire [5 :0] rd_off  = WB_ADR[5:0];

assign WB_ACK = loc_stb;

////////////////////////////////////////////////////////////////////////////////
// Register clock domain control registers
reg  [1 :0] pattern;
reg  [15:0] limit_mb;
reg         start_tog;
reg         abort_tog;
reg         snap_req;
reg         s_done;

wire wr         = loc_stb & WB_WE;
wire ctrl_start = wr & (rd_off == 6'h00) & WB_DAT[0];
wire ctrl_abort = wr & (rd_off == 6'h00) & WB_DAT[1];

always @(posedge CLK) begin
  if (RST) begin
    pattern   <= 2'd0;
    limit_mb  <= 16'd0;
    start_tog <= 1'b0;
    abort_tog <= 1'b0;
  end
  else if (wr) begin
    case (rd_off)
      6'h00: begin
        pattern <= WB_DAT[3:2];
        if (WB_DAT[0]) start_tog <= ~start_tog;
        if (WB_DAT[1]) abort_tog <= ~abort_tog;
      end
      6'h03: limit_mb[7:0]  <= WB_DAT;
      6'h04: limit_mb[15:8] <= WB_DAT;
      default: ;
    endcase
  end
end

////////////////////////////////////////////////////////////////////////////////
// Snapshot handshake into the MIG user clock domain
reg  [9 :0] snap_div;
reg  [1 :0] snap_ack_sync;

wire snap_ack_edge = snap_ack_sync[1] ^ snap_ack_sync[0];

always @(posedge CLK) begin
  if (RST) begin
    snap_div      <= 10'd0;
    snap_ack_sync <= 2'b00;
    snap_req      <= 1'b0;
  end
  else begin
    snap_div      <= snap_div + 10'd1;
    snap_ack_sync <= {snap_ack_sync[0], SNAP_ACK};
    if (snap_div == 10'h3FF) snap_req <= ~snap_req;  // every 1024 cycles (~8 us)
  end
end

////////////////////////////////////////////////////////////////////////////////
// Latched status (updated whenever the mailbox handshake completed)
reg         s_calib;
reg         s_busy;
reg         s_pass;
reg  [2 :0] s_state;
reg  [31:0] s_err_cnt;
reg  [31:0] s_err_addr;
reg  [2 :0] s_lane;
reg  [31:0] s_cur_addr;
reg  [63:0] s_exp;
reg  [63:0] s_rd;

always @(posedge CLK) begin
  if (RST) begin
    s_done     <= 1'b0;
    s_calib    <= 1'b0;
    s_busy     <= 1'b0;
    s_pass     <= 1'b0;
    s_state    <= PH_IDLE;
    s_err_cnt  <= 32'd0;
    s_err_addr <= 32'd0;
    s_lane     <= 3'd0;
    s_cur_addr <= 32'd0;
    s_exp      <= 64'd0;
    s_rd       <= 64'd0;
  end
  else if (snap_ack_edge) begin
    s_calib    <= SNAP_CALIB;
    s_busy     <= SNAP_BUSY;
    s_pass     <= SNAP_PASS;
    s_state    <= SNAP_STATE;
    s_err_cnt  <= SNAP_ERR_CNT;
    s_err_addr <= SNAP_ERR_ADDR;
    s_lane     <= SNAP_ERR_LANE;
    s_cur_addr <= SNAP_CUR_ADDR;
    s_exp      <= SNAP_ERR_EXP;
    s_rd       <= SNAP_ERR_RD;
    // "done" is set when a finished run is seen, and cleared as soon as a new
    // run becomes visible (busy) or when the host starts a new run
    if (SNAP_STATE == PH_DONE)          s_done <= 1'b1;
    else if (SNAP_STATE != PH_IDLE)     s_done <= 1'b0;
  end
  else if (ctrl_start) begin
    s_done <= 1'b0;
  end
end

wire s_fail = s_done & ~s_pass;

////////////////////////////////////////////////////////////////////////////////
// Read data mux
reg [7:0] rd_mux;
always @(*) begin
  case (rd_off)
    6'h00: rd_mux = {4'h0, pattern, 2'b00};
    6'h01: rd_mux = {s_done, s_state, s_fail, s_pass, s_busy, s_calib};
    6'h02: rd_mux = {5'h0, s_lane};
    6'h03: rd_mux = limit_mb[7:0];
    6'h04: rd_mux = limit_mb[15:8];
    6'h05: rd_mux = s_err_cnt[7:0];
    6'h06: rd_mux = s_err_cnt[15:8];
    6'h07: rd_mux = s_err_cnt[23:16];
    6'h08: rd_mux = s_err_cnt[31:24];
    6'h09: rd_mux = s_err_addr[7:0];
    6'h0A: rd_mux = s_err_addr[15:8];
    6'h0B: rd_mux = s_err_addr[23:16];
    6'h0C: rd_mux = s_err_addr[31:24];
    6'h0D: rd_mux = s_cur_addr[7:0];
    6'h0E: rd_mux = s_cur_addr[15:8];
    6'h0F: rd_mux = s_cur_addr[23:16];
    6'h10: rd_mux = s_cur_addr[31:24];
    6'h11: rd_mux = s_exp[7:0];
    6'h12: rd_mux = s_exp[15:8];
    6'h13: rd_mux = s_exp[23:16];
    6'h14: rd_mux = s_exp[31:24];
    6'h15: rd_mux = s_exp[39:32];
    6'h16: rd_mux = s_exp[47:40];
    6'h17: rd_mux = s_exp[55:48];
    6'h18: rd_mux = s_exp[63:56];
    6'h19: rd_mux = s_rd[7:0];
    6'h1A: rd_mux = s_rd[15:8];
    6'h1B: rd_mux = s_rd[23:16];
    6'h1C: rd_mux = s_rd[31:24];
    6'h1D: rd_mux = s_rd[39:32];
    6'h1E: rd_mux = s_rd[47:40];
    6'h1F: rd_mux = s_rd[55:48];
    6'h20: rd_mux = s_rd[63:56];
    6'h3F: rd_mux = 8'hD4;
    default: rd_mux = 8'h00;
  endcase
end

assign WB_RD = blk_sel ? rd_mux : 8'h00;

////////////////////////////////////////////////////////////////////////////////
// Test engine (MIG user clock domain)
ddr4_test_engine #(
  .DRAIN_CYCLES (2048)
) u_engine (
  .CLK                (CLK_UI),
  .RST                (RST_UI),
  .START_TOGGLE       (start_tog),
  .ABORT_TOGGLE       (abort_tog),
  .PATTERN            (pattern),
  .LIMIT_MB           (limit_mb),
  .SNAP_REQ           (snap_req),
  .SNAP_ACK           (SNAP_ACK),
  .ST_CALIB           (SNAP_CALIB),
  .ST_BUSY            (SNAP_BUSY),
  .ST_STATE           (SNAP_STATE),
  .ST_PASS            (SNAP_PASS),
  .ST_ERR_CNT         (SNAP_ERR_CNT),
  .ST_ERR_ADDR        (SNAP_ERR_ADDR),
  .ST_ERR_LANE        (SNAP_ERR_LANE),
  .ST_ERR_EXP         (SNAP_ERR_EXP),
  .ST_ERR_RD          (SNAP_ERR_RD),
  .ST_CUR_ADDR        (SNAP_CUR_ADDR),
  .APP_ADDR           (APP_ADDR),
  .APP_CMD            (APP_CMD),
  .APP_EN             (APP_EN),
  .APP_WDF_DATA       (APP_WDF_DATA),
  .APP_WDF_WREN       (APP_WDF_WREN),
  .APP_RDY            (APP_RDY),
  .APP_WDF_RDY        (APP_WDF_RDY),
  .APP_RD_DATA        (APP_RD_DATA),
  .APP_RD_DATA_VALID  (APP_RD_DATA_VALID),
  .CALIB_DONE         (CALIB_DONE)
);

endmodule
