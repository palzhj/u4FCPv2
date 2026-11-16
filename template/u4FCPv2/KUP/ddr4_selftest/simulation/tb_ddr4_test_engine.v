`timescale 1ns/1ps
/*******************************************************************************
* System      : u4FCP v2 DDR4 self-test                                        *
* Module      : tb_ddr4_test_engine                                            *
*                                                                              *
* Description : Self checking test bench for the DDR4 self-test engine. The     *
*               MIG native interface is modelled with a simple behavioural      *
*               memory that supports write data before command, read latency    *
*               and periodic ready de-assertion.                               *
*                                                                              *
*               1) clean run, pattern 0  -> pass, 0 errors                     *
*               2) word corrupted during the read pass -> fail, address        *
*                  reported, lane reported                                     *
*               3) clean run, pattern 1  -> pass, 0 errors                     *
*               4) clean run, pattern 3  -> pass, 0 errors                     *
*               5) abort during a run    -> engine returns to idle             *
*******************************************************************************/
module tb_ddr4_test_engine;

localparam integer MEM_WORDS = 16384;          // 1 MB / 64 B
localparam integer RD_LAT    = 24;

reg  clk = 1'b0;
reg  rst = 1'b1;
always #2 clk = ~clk;                          // 250 MHz

//------------------------------------------------------------------ DUT control
reg         start_tog = 1'b0;
reg         abort_tog = 1'b0;
reg         snap_req  = 1'b0;
reg  [1 :0] pattern   = 2'd0;
reg  [15:0] limit_mb  = 16'd1;                 // 1 MB sweep

//------------------------------------------------------------------ APP signals
wire [511:0] app_wdf_data;
wire         app_wdf_wren;
wire [30:0]  app_addr;
wire [2 :0]  app_cmd;
wire         app_en;
reg          app_rdy;
reg          app_wdf_rdy;
reg  [511:0] app_rd_data;
reg          app_rd_data_valid;
reg          app_rd_data_end;

//------------------------------------------------------------------ status
wire        snap_ack;
wire        st_calib, st_busy, st_pass;
wire [2:0]  st_state;
wire [31:0] st_err_cnt, st_err_addr, st_cur_addr;
wire [2:0]  st_err_lane;
wire [63:0] st_err_exp, st_err_rd;

//------------------------------------------------------------------ DUT
ddr4_test_engine #(
  .DRAIN_CYCLES (2048)
) dut (
  .CLK               (clk),
  .RST               (rst),
  .START_TOGGLE      (start_tog),
  .ABORT_TOGGLE      (abort_tog),
  .PATTERN           (pattern),
  .LIMIT_MB          (limit_mb),
  .SNAP_REQ          (snap_req),
  .SNAP_ACK          (snap_ack),
  .ST_CALIB          (st_calib),
  .ST_BUSY           (st_busy),
  .ST_STATE          (st_state),
  .ST_PASS           (st_pass),
  .ST_ERR_CNT        (st_err_cnt),
  .ST_ERR_ADDR       (st_err_addr),
  .ST_ERR_LANE       (st_err_lane),
  .ST_ERR_EXP        (st_err_exp),
  .ST_ERR_RD         (st_err_rd),
  .ST_CUR_ADDR       (st_cur_addr),
  .APP_ADDR          (app_addr),
  .APP_CMD           (app_cmd),
  .APP_EN            (app_en),
  .APP_WDF_DATA      (app_wdf_data),
  .APP_WDF_WREN      (app_wdf_wren),
  .APP_RDY           (app_rdy),
  .APP_WDF_RDY       (app_wdf_rdy),
  .APP_RD_DATA       (app_rd_data),
  .APP_RD_DATA_VALID (app_rd_data_valid),
  .CALIB_DONE        (1'b1)
);

//------------------------------------------------------------------ memory model
reg [511:0] mem [0:MEM_WORDS-1];

// write data fifo (the engine presents data before the write command)
reg [511:0] wdf_fifo [0:7];
reg [2:0]   wdf_wr = 3'd0, wdf_rd = 3'd0;

// read command pipeline
reg [30:0]     rd_addr_pipe [0:RD_LAT];
reg [RD_LAT:0] rd_vld_pipe;

reg [3:0] bp = 4'd0;
always @(posedge clk) bp <= bp + 4'd1;

integer i;

always @(posedge clk) begin
  app_rdy     <= (bp != 4'd11);
  app_wdf_rdy <= (bp != 4'd6);
end

// write data capture
always @(posedge clk) begin
  if (app_wdf_wren && app_wdf_rdy) begin
    wdf_fifo[wdf_wr[2:0]] <= app_wdf_data;
    wdf_wr <= wdf_wr + 3'd1;
  end
end

// read latency pipeline
always @(posedge clk) begin
  for (i = RD_LAT; i > 0; i = i - 1) begin
    rd_addr_pipe[i] <= rd_addr_pipe[i-1];
    rd_vld_pipe[i]  <= rd_vld_pipe[i-1];
  end
  rd_addr_pipe[0]    <= app_addr;
  rd_vld_pipe[0]     <= app_en && app_rdy && (app_cmd == 3'b001);
  app_rd_data_valid  <= rd_vld_pipe[RD_LAT];
  app_rd_data_end    <= rd_vld_pipe[RD_LAT];
  app_rd_data        <= mem[rd_addr_pipe[RD_LAT][16:3]];
end

// command processing
always @(posedge clk) begin
  if (app_en && app_rdy && (app_cmd == 3'b000)) begin
    mem[app_addr[16:3]] <= wdf_fifo[wdf_rd[2:0]];
    wdf_rd <= wdf_rd + 3'd1;
  end
end

//------------------------------------------------------------------ status snapshot
reg  [1:0]  ack_sync = 2'b00;
reg         st_pass_r = 1'b0;
reg  [2:0]  st_state_r = 3'd0;
reg         st_busy_r = 1'b0;
reg  [31:0] st_err_cnt_r = 32'd0, st_err_addr_r = 32'd0;
reg  [2:0]  st_lane_r = 3'd0;

always @(posedge clk) begin
  ack_sync <= {ack_sync[0], snap_ack};
  if (ack_sync[1] ^ ack_sync[0]) begin
    st_pass_r     <= st_pass;
    st_state_r    <= st_state;
    st_busy_r     <= st_busy;
    st_err_cnt_r  <= st_err_cnt;
    st_err_addr_r <= st_err_addr;
    st_lane_r     <= st_err_lane;
  end
end

reg [5:0] snap_div = 6'd0;
always @(posedge clk) begin
  snap_div <= snap_div + 6'd1;
  if (snap_div == 6'h3F) snap_req <= ~snap_req;
end

//------------------------------------------------------------------ error injection
integer     corrupt_idx = 2000;
reg         corrupt_arm = 1'b0;
reg         corrupt_done = 1'b0;

always @(posedge clk) begin
  if (corrupt_arm && !corrupt_done && (st_state_r == 3'd3)) begin
    mem[corrupt_idx] <= ~mem[corrupt_idx];
    corrupt_done <= 1'b1;
    $display("INFO : injecting one word error at index %0d", corrupt_idx);
  end
end

//------------------------------------------------------------------ test sequence
integer errors = 0;
integer n;

task start_test;
  begin
    @(posedge clk);
    start_tog <= ~start_tog;
    @(posedge clk);
  end
endtask

task wait_done;
  input integer max_cycles;
  integer c;
  begin
    c = 0;
    while ((st_state_r != 3'd1) && (st_state_r != 3'd2) && (st_state_r != 3'd3) && (c < max_cycles)) begin
      @(posedge clk); c = c + 1;
    end
    while ((st_state_r != 3'd4) && (c < max_cycles)) begin
      @(posedge clk); c = c + 1;
    end
    if (st_state_r != 3'd4) begin
      $display("ERROR: timeout waiting for DONE (state=%0d)", st_state_r);
      errors = errors + 1;
    end
  end
endtask

task check_clean;
  input [8*32-1:0] name;
  begin
    if (!st_pass_r || (st_err_cnt_r != 0)) begin
      $display("ERROR: %0s failed (pass=%0d err_cnt=%0d)", name, st_pass_r, st_err_cnt_r);
      errors = errors + 1;
    end
    else $display("PASS : %0s", name);
  end
endtask

initial begin
  for (n = 0; n < MEM_WORDS; n = n + 1) mem[n] = 512'd0;

  $display("=== DDR4 self-test engine test bench ===");

  repeat (20) @(posedge clk);
  rst <= 1'b0;
  repeat (10) @(posedge clk);

  // 1) clean run, pattern 0
  pattern  <= 2'd0;
  limit_mb <= 16'd1;
  start_test;
  wait_done(2000000);
  check_clean("clean run 1 (pattern 0, 1 MB)");
  if (st_busy_r) begin
    $display("ERROR: busy is still set after the run finished");
    errors = errors + 1;
  end
  else $display("PASS : busy cleared after the run");

  // 2) inject a single word error during the read pass
  corrupt_arm  <= 1'b1;
  corrupt_done <= 1'b0;
  start_test;
  wait_done(2000000);
  if (st_pass_r || (st_err_cnt_r < 1)) begin
    $display("ERROR: injected error not detected (pass=%0d err_cnt=%0d)", st_pass_r, st_err_cnt_r);
    errors = errors + 1;
  end
  else if (st_err_addr_r !== (corrupt_idx * 8)) begin
    $display("ERROR: wrong first error address %0d (expected %0d)", st_err_addr_r, corrupt_idx*8);
    errors = errors + 1;
  end
  else $display("PASS : injected error detected (addr=%0d, lane=%0d, err_cnt>=1)",
                st_err_addr_r, st_lane_r);
  corrupt_arm <= 1'b0;

  // 3) clean run, walking one
  pattern  <= 2'd1;
  start_test;
  wait_done(2000000);
  check_clean("clean run 2 (pattern 1, 1 MB)");

  // 4) clean run, checker board
  pattern  <= 2'd3;
  start_test;
  wait_done(2000000);
  check_clean("clean run 3 (pattern 3, 1 MB)");

  // 5) abort
  pattern  <= 2'd0;
  start_test;
  repeat (2000) @(posedge clk);
  @(posedge clk); abort_tog <= ~abort_tog;
  repeat (3000) @(posedge clk);
  if (st_state_r != 3'd0) begin
    $display("ERROR: abort did not return to idle (state=%0d)", st_state_r);
    errors = errors + 1;
  end
  else $display("PASS : abort");

  if (errors == 0) $display("=== ALL TESTS PASSED ===");
  else             $display("=== %0d TEST(S) FAILED ===", errors);
  $finish;
end

endmodule
