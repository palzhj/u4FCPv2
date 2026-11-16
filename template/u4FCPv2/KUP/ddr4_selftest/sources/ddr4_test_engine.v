`timescale 1ps/1ps
/*******************************************************************************
* System      : u4FCP v2 DDR4 self-test                                        *
* Module      : ddr4_test_engine                                               *
*                                                                              *
* Description : DDR4 memory self-test engine working on the MIG native (APP)    *
*               user interface.                                                *
*                                                                              *
*               Write pass:  for every 64-byte word of the selected address     *
*                            range an address dependent pattern is written.     *
*               Read  pass:  the range is read back in the same order and the   *
*                            data is compared against the expected pattern.    *
*                            Errors are counted; the first failing word / byte  *
*                            lane is latched for diagnostics.                   *
*                                                                              *
*               The MIG native interface of the ddr4 IP used here is a 4:1      *
*               interface with a 512-bit APP data bus. One APP request always   *
*               transfers one 512-bit (64 byte) word, therefore APP_ADDR is     *
*               incremented by 8 (8-byte units) per request.                    *
*                                                                              *
*               All control inputs come from the 125 MHz register clock domain  *
*               as toggles, all status outputs are returned through a           *
*               request/acknowledge mailbox handshake.                          *
*******************************************************************************/
module ddr4_test_engine #(
  parameter integer DRAIN_CYCLES = 2048   // wait after the write pass before reading
)(
  input               CLK,                // MIG ui_clk (250 MHz)
  input               RST,                // active high, ui_clk domain
  // Control, level+edge from the register clock domain
  input               START_TOGGLE,       // toggles on every "start" request
  input               ABORT_TOGGLE,       // toggles on every "abort" request
  input      [1 :0]   PATTERN,            // 0 = address random, 1 = walk1, 2 = walk0, 3 = checker
  input      [15:0]   LIMIT_MB,           // 0 or >= 16384 = whole memory
  // Status mailbox handshake
  input               SNAP_REQ,           // toggles when a snapshot is wanted
  output reg          SNAP_ACK,           // toggles after the mailbox was updated
  output reg          ST_CALIB,
  output reg          ST_BUSY,
  output reg  [2 :0]  ST_STATE,
  output reg          ST_PASS,
  output reg  [31:0]  ST_ERR_CNT,
  output reg  [31:0]  ST_ERR_ADDR,
  output reg  [2 :0]  ST_ERR_LANE,
  output reg  [63:0]  ST_ERR_EXP,
  output reg  [63:0]  ST_ERR_RD,
  output reg  [31:0]  ST_CUR_ADDR,
  // MIG user interface
  output reg  [30:0]  APP_ADDR,
  output reg  [2 :0]  APP_CMD,
  output reg          APP_EN,
  output reg  [511:0] APP_WDF_DATA,
  output reg          APP_WDF_WREN,
  input               APP_RDY,
  input               APP_WDF_RDY,
  input      [511:0]  APP_RD_DATA,
  input               APP_RD_DATA_VALID,
  input               CALIB_DONE
);

localparam [2:0] APP_CMD_WRITE = 3'b000;
localparam [2:0] APP_CMD_READ  = 3'b001;

// FSM states, also reported as ST_STATE
localparam [2:0] PH_IDLE  = 3'd0;
localparam [2:0] PH_WRITE = 3'd1;
localparam [2:0] PH_DRAIN = 3'd2;
localparam [2:0] PH_READ  = 3'd3;
localparam [2:0] PH_DONE  = 3'd4;

// The MIG of this project maps 16 GB of non-ECC memory into APP_ADDR[30:0],
// where one APP_ADDR unit is 8 bytes  ->  full range = 0x8000_0000.
localparam [31:0] FULL_RANGE = 32'h8000_0000;

////////////////////////////////////////////////////////////////////////////////
// Clock domain crossing: control toggles / snapshot request
reg  [1:0] start_sync, abort_sync, req_sync;

always @(posedge CLK) begin
  start_sync <= {start_sync[0], START_TOGGLE};
  abort_sync <= {abort_sync[0], ABORT_TOGGLE};
  req_sync   <= {req_sync[0],   SNAP_REQ};
end

wire start_pulse = start_sync[1] ^ start_sync[0];
wire abort_pulse = abort_sync[1] ^ abort_sync[0];
wire snap_pulse  = req_sync[1]   ^ req_sync[0];

////////////////////////////////////////////////////////////////////////////////
// Test pattern generator
//   Every word is a function of the 31-bit APP address, so that address decoding
//   errors (rank, bank group, bank, row, column) change the expected data.

function [511:0] gen_word;
  input [31:0] a;
  input [1 :0] p;
  reg   [63:0] x;
  reg   [511:0] w;
  integer      k;
  begin
    x = {33'b0, a[30:0]};
    x = x ^ (x << 17);
    x = x ^ (x >> 29);
    x = x ^ (x << 5);

    case (p)
      2'd0: begin // address mixed pseudo random data
        for (k = 0; k < 8; k = k + 1)
          w[k*64 +: 64] = x ^ (64'h0102_0304_0506_0708 + k * 64'h0101_0101_0101_0101);
      end
      2'd1: w = 512'h1 << a[11:3];    // walking one
      2'd2: w = ~(512'h1 << a[11:3]); // walking zero
      default: begin                  // checker board, different per lane/address
        for (k = 0; k < 8; k = k + 1)
          w[k*64 +: 64] = {8{8'h5A ^ (k * 8'h11) ^ {8{a[3]}}}};
      end
    endcase
    gen_word = w;
  end
endfunction

////////////////////////////////////////////////////////////////////////////////
// Calibration status, synchronized so that the MIG calibration register is not
// in the same combinational path as the FSM decision logic
reg  [1:0] calib_sync;
always @(posedge CLK)
  calib_sync <= {calib_sync[0], CALIB_DONE};
wire calib_ok = calib_sync[1];

////////////////////////////////////////////////////////////////////////////////
// Test FSM registers
reg  [2 :0] state;
reg  [31:0] addr_cnt;        // address currently presented to the MIG
reg  [31:0] limit_addr;      // end address of the sweep (exclusive)
reg  [31:0] rd_addr;         // expected address of the returning read data
reg  [31:0] err_cnt;
reg  [31:0] err_addr;
reg  [2 :0] err_lane;
reg  [63:0] err_exp;
reg  [63:0] err_rd;
reg         pass_r;
reg  [1 :0] pattern_r;
reg  [15:0] drain_cnt;
reg         rd_all_issued;
reg         wr_data_done;
// Read data capture stage: the returning word, its expected value and address
// are registered first so that the pattern generator is not in the same
// combinational path as the compare / error logging logic.
reg         rd_vld_q;
reg  [511:0] rd_data_q;
reg  [511:0] rd_exp_q;
reg  [31:0]  rd_addr_q;
reg         rd_last_d;      // last read word seen (delayed, lets the compare finish)

wire [511:0] exp_rd_word = gen_word(rd_addr, pattern_r);

////////////////////////////////////////////////////////////////////////////////
// Error detection helpers
wire [7 :0] lane_bad;
genvar gi;
generate
  for (gi = 0; gi < 8; gi = gi + 1) begin: gen_lane_cmp
    assign lane_bad[gi] = (rd_data_q[gi*64 +: 64] != rd_exp_q[gi*64 +: 64]);
  end
endgenerate

reg  [2:0] first_lane;
integer    li;
always @(*) begin
  first_lane = 3'd7;
  for (li = 7; li >= 0; li = li - 1)
    if (lane_bad[li]) first_lane = li;
end

wire [31:0] limit_calc = (LIMIT_MB == 16'd0 || LIMIT_MB >= 16'd16384)
                         ? FULL_RANGE : ({16'd0, LIMIT_MB} << 17);

wire [31:0] cur_addr = (state == PH_READ) ? rd_addr : addr_cnt;

always @(posedge CLK) begin
  if (RST) begin
    state        <= PH_IDLE;
    addr_cnt     <= 32'd0;
    limit_addr   <= FULL_RANGE;
    rd_addr      <= 32'd0;
    err_cnt      <= 32'd0;
    err_addr     <= 32'd0;
    err_lane     <= 3'd0;
    err_exp      <= 64'd0;
    err_rd       <= 64'd0;
    pass_r       <= 1'b0;
    pattern_r    <= 2'd0;
    drain_cnt    <= 16'd0;
    rd_all_issued<= 1'b0;
    wr_data_done <= 1'b0;
    rd_vld_q     <= 1'b0;
    rd_data_q    <= 512'd0;
    rd_exp_q     <= 512'd0;
    rd_addr_q    <= 32'd0;
    rd_last_d    <= 1'b0;
    APP_ADDR     <= 31'd0;
    APP_CMD      <= APP_CMD_WRITE;
    APP_EN       <= 1'b0;
    APP_WDF_DATA <= 512'd0;
    APP_WDF_WREN <= 1'b0;
  end
  else if (abort_pulse || (state != PH_IDLE && !calib_ok)) begin
    // abort from the register interface, or calibration was lost
    state        <= PH_IDLE;
    APP_EN       <= 1'b0;
    APP_WDF_WREN <= 1'b0;
    wr_data_done <= 1'b0;
    pass_r       <= 1'b0;
  end
  // A new run can be started from idle or directly after a finished run
  // (the PH_DONE state is kept until the next start so that the register file
  // and the host software can read the result).
  else if (start_pulse && calib_ok && ((state == PH_IDLE) || (state == PH_DONE))) begin
    limit_addr    <= limit_calc;
    pattern_r     <= PATTERN;
    addr_cnt      <= 32'd0;
    rd_addr       <= 32'd0;
    err_cnt       <= 32'd0;
    err_addr      <= 32'd0;
    err_lane      <= 3'd0;
    err_exp       <= 64'd0;
    err_rd        <= 64'd0;
    pass_r        <= 1'b1;
    rd_all_issued <= 1'b0;
    wr_data_done  <= 1'b0;
    APP_ADDR      <= 31'd0;
    APP_CMD       <= APP_CMD_WRITE;
    APP_EN        <= 1'b0;
    APP_WDF_DATA  <= gen_word(32'd0, PATTERN);
    APP_WDF_WREN  <= 1'b1;
    state         <= PH_WRITE;
  end
  else begin
    //------------------------------------------------------------------
    // Read data capture stage (registered, keeps the pattern generator out of
    // the compare path) and error logging of the previous word.
    rd_vld_q <= APP_RD_DATA_VALID && (state == PH_READ);
    if (APP_RD_DATA_VALID && (state == PH_READ)) begin
      rd_data_q <= APP_RD_DATA;
      rd_exp_q  <= exp_rd_word;
      rd_addr_q <= rd_addr;
    end

    if (rd_vld_q) begin
      if (rd_data_q !== rd_exp_q) begin
        err_cnt <= err_cnt + 32'd1;
        if (err_cnt == 32'd0) begin
          err_addr <= rd_addr_q;
          err_lane <= first_lane;
          err_exp  <= rd_exp_q[first_lane*64 +: 64];
          err_rd   <= rd_data_q[first_lane*64 +: 64];
          pass_r   <= 1'b0;
        end
      end
    end

    case (state)
      //------------------------------------------------------------------
      PH_IDLE: begin
        APP_EN       <= 1'b0;
        APP_WDF_WREN <= 1'b0;
      end
      //------------------------------------------------------------------
      PH_WRITE: begin
        APP_ADDR <= addr_cnt[30:0];
        APP_CMD  <= APP_CMD_WRITE;
        // The write data is always accepted before the command (MIG allows
        // data-first), because a command that was accepted without data
        // cannot be repeated.
        if (!wr_data_done) begin
          APP_EN <= 1'b0;
          if (APP_WDF_WREN && APP_WDF_RDY) begin
            APP_WDF_WREN <= 1'b0;
            wr_data_done <= 1'b1;
            APP_EN       <= 1'b1;
          end
        end
        else begin
          APP_EN <= 1'b1;
          if (APP_EN && APP_RDY) begin
            APP_EN       <= 1'b0;
            wr_data_done <= 1'b0;
            if (addr_cnt + 32'd8 >= limit_addr) begin
              addr_cnt      <= 32'd0;
              APP_WDF_WREN  <= 1'b0;
              drain_cnt     <= DRAIN_CYCLES[15:0];
              state         <= PH_DRAIN;
            end
            else begin
              addr_cnt     <= addr_cnt + 32'd8;
              APP_ADDR     <= addr_cnt + 32'd8;
              APP_WDF_DATA <= gen_word(addr_cnt + 32'd8, pattern_r);
              APP_WDF_WREN <= 1'b1;
            end
          end
        end
      end
      //------------------------------------------------------------------
      PH_DRAIN: begin
        APP_EN        <= 1'b0;
        APP_WDF_WREN  <= 1'b0;
        wr_data_done  <= 1'b0;
        if (drain_cnt == 16'd0) begin
          addr_cnt      <= 32'd0;
          rd_addr       <= 32'd0;
          APP_ADDR      <= 31'd0;
          APP_CMD       <= APP_CMD_READ;
          APP_EN        <= 1'b1;
          rd_all_issued <= 1'b0;
          state         <= PH_READ;
        end
        else begin
          drain_cnt <= drain_cnt - 16'd1;
        end
      end
      //------------------------------------------------------------------
      PH_READ: begin
        APP_CMD <= APP_CMD_READ;

        // request side
        if (!rd_all_issued) begin
          APP_EN <= 1'b1;
          if (APP_EN && APP_RDY) begin
            if (addr_cnt + 32'd8 >= limit_addr) begin
              APP_EN        <= 1'b0;
              addr_cnt      <= 32'd0;
              rd_all_issued <= 1'b1;
            end
            else begin
              addr_cnt <= addr_cnt + 32'd8;
              APP_ADDR <= addr_cnt + 32'd8;
            end
          end
        end
        else begin
          APP_EN <= 1'b0;
        end

        // response side, read data returns in the order it was requested
        rd_last_d <= APP_RD_DATA_VALID && (rd_addr + 32'd8 >= limit_addr);
        if (APP_RD_DATA_VALID) begin
          rd_addr <= rd_addr + 32'd8;
        end
        // one cycle delay so the last word is compared before DONE is reported
        if (rd_last_d)
          state <= PH_DONE;
      end
      //------------------------------------------------------------------
      PH_DONE: begin
        APP_EN       <= 1'b0;
        APP_WDF_WREN <= 1'b0;
      end
      default: begin
        state        <= PH_IDLE;
        APP_EN       <= 1'b0;
        APP_WDF_WREN <= 1'b0;
      end
    endcase
  end
end

////////////////////////////////////////////////////////////////////////////////
// Status mailbox, updated on every snapshot request from the register clock
// domain. The mailbox registers are static while SNAP_ACK toggles, so the
// multi-bit data can be sampled safely in the other clock domain.
always @(posedge CLK) begin
  if (RST) begin
    SNAP_ACK    <= 1'b0;
    ST_CALIB    <= 1'b0;
    ST_BUSY     <= 1'b0;
    ST_STATE    <= PH_IDLE;
    ST_PASS     <= 1'b0;
    ST_ERR_CNT  <= 32'd0;
    ST_ERR_ADDR <= 32'd0;
    ST_ERR_LANE <= 3'd0;
    ST_ERR_EXP  <= 64'd0;
    ST_ERR_RD   <= 64'd0;
    ST_CUR_ADDR <= 32'd0;
  end
  else if (snap_pulse) begin
    ST_CALIB    <= calib_ok;
    // busy is only reported while a pass is actually running; a finished run
    // is reported through the DONE state instead
    ST_BUSY     <= (state == PH_WRITE) || (state == PH_DRAIN) || (state == PH_READ);
    ST_STATE    <= state;
    // "pass" is only meaningful (and only reported) for a finished run
    ST_PASS     <= pass_r && (state == PH_DONE);
    ST_ERR_CNT  <= err_cnt;
    ST_ERR_ADDR <= err_addr;
    ST_ERR_LANE <= err_lane;
    ST_ERR_EXP  <= err_exp;
    ST_ERR_RD   <= err_rd;
    ST_CUR_ADDR <= cur_addr;
    SNAP_ACK    <= ~SNAP_ACK;
  end
end

endmodule
