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

module reset_pulse_extender (
    input  wire clk,          // 125 MHz
    input  wire rst_in,       // Async input reset, ~8 ns pulse
    output reg  rst_out       // Extended reset, 1 ms, active high
);

    parameter CLK_FREQ_HZ    = 125_000_000;
    parameter PULSE_WIDTH_NS = 1_000_000;

    // Safe 64-bit intermediate — avoids integer-division truncation
    localparam COUNT_MAX     = CLK_FREQ_HZ * PULSE_WIDTH_NS / 1_000_000_000;
    localparam COUNTER_WIDTH = $clog2(COUNT_MAX);

    reg [COUNTER_WIDTH-1:0] counter;
    reg extending;

    // Single source of truth for "extension finished this cycle"
    wire extender_done = extending && (counter == COUNT_MAX - 1);

    // ---- Async-capture front-end ----
    // Async SET on rst_in (catches the 8 ns pulse regardless of clock phase)
    // Sync CLEAR when extension completes.
    reg pulse_captured;

    always @(posedge clk or posedge rst_in) begin
        if (rst_in)
            pulse_captured <= 1'b1;
        else if (extender_done)
            pulse_captured <= 1'b0;
    end

    // ---- Synchronous 1 ms extender ----
    always @(posedge clk) begin
        if (pulse_captured && !extending) begin
            counter   <= {COUNTER_WIDTH{1'b0}};
            extending <= 1'b1;
            rst_out   <= 1'b1;
        end
        else
            if (extending) begin
                if (counter == COUNT_MAX - 1) begin
                    counter   <= {COUNTER_WIDTH{1'b0}};
                    extending <= 1'b0;
                    rst_out   <= 1'b0;
                end
                else begin
                    counter <= counter + 1'b1;
                    rst_out <= 1'b1;
                end
            end
            else begin
                rst_out <= 1'b0;
            end
    end

endmodule