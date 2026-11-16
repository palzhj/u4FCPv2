module mdio_init(
// System
  input clk,            // in : system clock (125M)
  input rst,            // in : system reset
// PHY
  input [4:0] phyaddr,  // in : [4:0] PHY address
// MII
  output reg mdc,       // out: clock (1/128 system clock)
  output mdio_out,      // out: connect this to "PCS/PMA + RocketIO" module .mdio?_i()
// status
  output reg complete   // out: initializing sequence has completed (active H)
);

// clock
reg [6:0] cntMdc;
always @ (posedge clk or posedge rst)
  if(rst) cntMdc <= 0;
  else cntMdc <= cntMdc + 7'd1;

always @ (posedge clk) mdc <= cntMdc[6];

wire gShiftDataEn = (cntMdc[6:0] == 7'd0);

////////////////////////////////////////////////////////////////////////////////
// reset states
reg [7:0] cntResets;
always @ (posedge clk or posedge rst)
  if(rst) cntResets <= 8'd0;
  else if(gShiftDataEn) cntResets <= cntResets + 8'd1;

// waits 128 MDCs after rst before outputting mdio_out
reg gWaitn;
always @ (posedge clk or posedge rst)
  if(rst) gWaitn <= 1'd0;
  else if(~gWaitn & cntResets[7]) gWaitn <= 1'd1;

// waits 128 (gWaitn) + 32 (mdio_out) + 32 (margin) MDCs after RSTn before having complete stand
always @ (posedge clk or posedge rst)
  if(rst) complete <= 1'd0;
  else if(~complete && (cntResets[7:5] == 3'b110)) complete <= 1'd1;

////////////////////////////////////////////////////////////////////////////////
// mdio_out shifter
reg [32:0] mdioData;
always @ (posedge clk or posedge rst) begin
  if(rst) mdioData[32:0] <= {
    1'b1,                   // preamble
    2'b01,                  // start opcode
    2'b01,                  // write opcode
    phyaddr[4:0],           // PHY address
    5'h0,                   // register address
    2'b10,                  // turn-around
    16'b0001_0001_0100_0000 // control register
  };
  else if(gWaitn & gShiftDataEn) mdioData[32:0] <= {mdioData[31:0], 1'b1};
end

assign mdio_out = mdioData[32];

endmodule
