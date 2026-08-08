//------------------------------------------------------------------------------
// Description: This module holds the asynchronous reset, and release as synchronous reset
`timescale 1 ps/1 ps

module async2sync_reset(
input        rst_in,          // Asynchronous reset for entire core.
input        clk,             // System clock
output       rst_out          // Synchronous reset
);

(* ASYNC_REG = "TRUE" *)
reg   [3:0]  reset_pipe; // flip-flop pipeline for reset duration stretch

always@(posedge clk or posedge rst_in)
  if (rst_in) reset_pipe <= 4'b1111;
  else reset_pipe <= {reset_pipe[2:0], rst_in};

assign rst_out = reset_pipe[3];

endmodule
