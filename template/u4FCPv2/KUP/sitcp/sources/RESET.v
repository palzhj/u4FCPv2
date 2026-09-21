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

//------------------------------------------------------------------------------
// reset_pulse_extender
//
// Stretches a short, asynchronous reset request into a long, clean reset pulse,
// so brief rst_in events (an 8 ns power-on glitch, for example) cannot be
// missed by the logic they reset.
//
//   rst_in   asynchronous request, active high; any width, any clock phase
//   rst_out  extended reset, active high
//
// Parameters
//   CLK_FREQ_HZ     frequency of clk, used to turn PULSE_WIDTH_NS into cycles
//   PULSE_WIDTH_NS  how long rst_out is held after the last request; must be
//                   at least one clock period
//
// Behaviour
//   * rst_out is 0 at power-up and stays 0 while no reset is requested.
//   * A request asserts rst_out asynchronously: no clock edge is needed.
//   * rst_out is never released while rst_in is asserted.
//   * After the last request rst_out is held for COUNT_MAX clock cycles, where
//     COUNT_MAX = PULSE_WIDTH_NS * CLK_FREQ_HZ / 1e9, and is then released
//     synchronously. The hold is therefore at least PULSE_WIDTH_NS and at most
//     one clock period longer.
//   * A request during the hold reloads the counter, so a full period runs
//     again from the last request (retriggerable) and rst_out never glitches.
//------------------------------------------------------------------------------
module reset_pulse_extender (
    input  wire clk,          // system clock
    input  wire rst_in,       // asynchronous reset request, ~8 ns pulse
    output reg  rst_out       // extended reset, active high, default 0
);

    parameter CLK_FREQ_HZ    = 125_000_000;
    parameter PULSE_WIDTH_NS = 1_000_000;

    // Hold length in whole clock cycles. The 64 bit divisor keeps the product
    // (1.25e14 with the defaults) from wrapping a 32 bit intermediate.
    localparam COUNT_MAX     = (CLK_FREQ_HZ * PULSE_WIDTH_NS) / 64'd1_000_000_000;
    localparam COUNTER_WIDTH = $clog2(COUNT_MAX + 1);

    reg [COUNTER_WIDTH-1:0] hold_cycles;  // clock cycles left to hold rst_out

    // Power-up state: idle, so rst_out is a defined 0 from t = 0 rather than X.
    // This is the simulation / FPGA configuration value; the idle branch below
    // drives the same 0 on the first clock edge, so a build that cannot use an
    // initial value still settles at 0 after one clock.
    initial begin
        hold_cycles = {COUNTER_WIDTH{1'b0}};
        rst_out     = 1'b0;
    end

    always @(posedge clk or posedge rst_in) begin
        if (rst_in) begin
            // Assert at once and reload the full period. Every clock edge while
            // rst_in is high reloads it again, so the hold always runs from the
            // moment the request is released.
            hold_cycles <= COUNT_MAX;
            rst_out     <= 1'b1;
        end
        else if (hold_cycles != {COUNTER_WIDTH{1'b0}}) begin
            // Count the hold down one clock at a time; the output stays high.
            hold_cycles <= hold_cycles - 1'b1;
            rst_out     <= 1'b1;
        end
        else begin
            // Idle: output released and held at its default 0.
            rst_out <= 1'b0;
        end
    end

endmodule
