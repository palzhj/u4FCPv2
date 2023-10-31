`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:        zhj@ihep.ac.cn
//
// Create Date:     
// Design Name:
// Module Name:     RBCP to Wishbone converter
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module RBCP2WB (
  // system
  input           clk,      // in
  input           rst,      // in
  // RBCP
  input           rbcp_we,  // in
  input           rbcp_re,  // in
  input   [7 :0]  rbcp_wd,  // in
  input   [31:0]  rbcp_addr,// in
  input           rbcp_act,
  output  [7 :0]  rbcp_rd,  // out
  output          rbcp_ack, // out
  // Wishbone bus
  output  [31:0]  adr,      // out
  input   [7 :0]  din,      // in
  output  [7 :0]  dout,     // out
  output          cyc,      // out
  output          stb,      // out
  output          we,       // out
  output          sel,      // out
  input           ack,      // in
  input           err,      // in
  input           rty       // in
);

//  Input buffer
reg   [31:0]  irAddr;
reg   [7 :0]  irWd;
always@ (posedge clk) begin
  if(rst) begin
    irAddr <= 0;
    irWd   <= 0;
  end
  else if(rbcp_we | rbcp_re) begin
    irAddr[31:0]<= rbcp_addr[31:0];
    irWd[7:0]   <= rbcp_wd[7:0];
  end
end

reg           irWR;
always @(posedge clk)
  if(rst) irWR <= 0;
  else if(rbcp_we) irWR <= 1'b1;
    else if(ack | err | rty | ~rbcp_act) irWR <= 0;

reg           irCyc;
always @(posedge clk)
  if(rst) irCyc <= 0;
  else if(rbcp_we | rbcp_re) irCyc <= 1'b1;
    else if(ack | err | rty | ~rbcp_act) irCyc <= 0;

assign adr  = irAddr;
assign dout = irWd;
assign cyc  = irCyc;
assign stb  = irCyc;
assign sel  = irCyc;
assign we   = irWR;

assign rbcp_rd  = din;
assign rbcp_ack = ack;

endmodule

  