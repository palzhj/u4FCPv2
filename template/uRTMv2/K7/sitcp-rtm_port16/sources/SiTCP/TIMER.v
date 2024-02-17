/*******************************************************************************
*                                                                              *
* Module      : TIMER                                                          *
* Version     : v 0.2.0 2010/03/31                                             *
*               v 3.0  2010/04/21 Change polarity of system reset              *
*                                                                              *
* Description : TIMER                                                          *
*                                                                              *
*                Copyright (c) 2010 Bee Beans Technologies Co.,Ltd.            *
*                All rights reserved                                           *
*                                                                              *
*******************************************************************************/
module TIMER #(
  parameter [7:0] CLK_FREQ = 125  // MHz
)(
// System
  input   CLK,        // in : System clock
  input   RST,        // in : System reset
// Intrrupts
  output  TIM_1US,    // out  : 1 us interval
  output  TIM_10US,   // out  : 10 us interval
  output  TIM_100US,  // out  : 100 us interval
  output  TIM_1MS,    // out  : 1 ms interval
  output  TIM_10MS,   // out  : 10 ms interval
  output  TIM_100MS,  // out  : 100 ms interval
  output  TIM_1S,     // out  : 1 s interval
  output  TIM_1M      // out  : 1 m interval
);

// Parameter: 158(160M), 123(125M), 48(50MHz), 23(25MHz), 18(20MHz), 8(10Mz)
localparam [7:0] TIM_PERIOD = CLK_FREQ-2; // for 25MHz, 1us/40ns-2 = 23

reg   pulse1us;
reg   pulse10us;
reg   pulse100us;
reg   pulse1ms;
reg   pulse10ms;
reg   pulse100ms;
reg   pulse1s;
reg   pulse1m;

//------------------------------------------------------------------------------
//  Timer
//------------------------------------------------------------------------------
reg         usCry;
reg [7:0]   usTim;
always@ (posedge CLK) begin
  if(RST) {usCry,usTim[7:0]} <= 9'd0;
  else {usCry,usTim[7:0]} <= (usCry ? {1'b0,TIM_PERIOD[7:0]} : {usCry,usTim[7:0]} - 9'd1);
end

reg [4:0]   Tim10us;
reg [7:0]   Tim100us;
reg [10:0]  Tim1ms;
reg [4:0]   Tim10ms;
reg [7:0]   Tim100ms;
reg [10:0]  Tim1s;
reg [6:0]   Tim1min;
always@ (posedge CLK) begin
  if(RST)begin
    Tim10us[4:0] <= 5'h0;
    Tim100us[7:0] <= 8'h0;
    Tim1ms[10:0] <= 11'h0;
    Tim10ms[4:0] <= 5'h0;
    Tim100ms[7:0] <= 8'h0;
    Tim1s[10:0]  <= 11'h0;
    Tim1min[6:0] <= 7'h0;
  end else begin
    if(usCry)begin
      Tim10us[4:0] <= (Tim10us[4] ? 5'd8 : Tim10us[4:0] - 5'd1);
      Tim100us[7:0] <= (Tim100us[7] ? 8'd98 : Tim100us[7:0] - 8'd1);
      Tim1ms[10:0] <= (Tim1ms[10] ? 11'd998 : Tim1ms[10:0] - 11'd1);
    end
    if(usCry & Tim1ms[10])begin
      Tim10ms[4:0] <= (Tim10ms[4] ? 5'd8 : Tim10ms[4:0] - 5'd1);
      Tim100ms[7:0] <= (Tim100ms[7] ? 8'd98 : Tim100ms[7:0] - 8'd1);
      Tim1s[10:0]  <= (Tim1s[10]  ? 11'd998 : Tim1s[10:0] - 11'd1);
    end
    if(usCry & Tim1ms[10] & Tim1s[10])begin
      Tim1min[6:0] <= (Tim1min[6] ? 7'd58 : Tim1min[6:0] - 7'd1);
    end
  end
end

always@ (posedge CLK) begin
  pulse1us  <= usCry;
  pulse10us <= usCry & Tim10us[4];
  pulse100us<= usCry & Tim100us[7];
  pulse1ms  <= usCry & Tim1ms[10];
  pulse10ms <= usCry & Tim1ms[10] & Tim10ms[4];
  pulse100ms<= usCry & Tim1ms[10] & Tim100ms[7];
  pulse1s   <= usCry & Tim1ms[10] & Tim1s[10];
  pulse1m   <= usCry & Tim1ms[10] & Tim1s[10] & Tim1min[6];
end

assign  TIM_1US = pulse1us;
assign  TIM_10US = pulse10us;
assign  TIM_100US = pulse100us;
assign  TIM_1MS = pulse1ms;
assign  TIM_10MS = pulse10ms;
assign  TIM_100MS = pulse100ms;
assign  TIM_1S  = pulse1s;
assign  TIM_1M  = pulse1m;

endmodule
