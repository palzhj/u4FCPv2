/*******************************************************************************
*                                                                              *
* Module      : RBCP_REG                                                       *
* Version     : v 0.2.0 2010/03/31                                             *
*                                                                              *
* Description : Register file                                                  *
*                                                                              *
*                                                                              *
*******************************************************************************/
module RBCP_REG #(
  parameter [31:0]  SYN_DATE = 32'h2011_1501,
  parameter [7 :0]  FPGA_VER = 8'h01,
  parameter [3 :0]  NUMBER_I2C  = 2,
  parameter [3 :0]  NUMBER_SPI  = 2
)(
  // System
  input           CLK,        // in : System clock
  input           RST,        // in : System reset
  // RBCP I/F
  input           RBCP_ACT,   // in : Active
  input   [31:0]  RBCP_ADDR,  // in : Address[31:0]
  input           RBCP_WE,    // in : Write enable
  input   [7 :0]  RBCP_WD,    // in : Write data[7:0]
  input           RBCP_RE,    // in : Read enable
  output  [7 :0]  RBCP_RD,    // out  : Read data[7:0]
  output          RBCP_ACK,   // out  : Acknowledge
  // User IO

  output  [7 :0]  LED,        // out  : LED[6:0]
  input   [7 :0]  DIP_SW,     // in : DIP_SW[3:0]
  input           SCL,
  output          SCL_OEN,
  output          SCL_O,
  input           SDA,
  output          SDA_OEN,
  output          SDA_O
);
//------------------------------------------------------------------------------
//  Input buffer
reg   [7:0]   regCs;
reg           i2cCs;
reg           smonCs;
reg   [7 :0]  irAddr;
reg           irWe;
reg   [7 :0]  irWd;
reg           irRe;
always@ (posedge CLK) begin
  if(RST) begin
    regCs  <= 0;
    i2cCs  <= 0;
    smonCs <= 0;
    irAddr <= 0;
    irWe   <= 0;
    irWd   <= 0;
    irRe   <= 0;
  end
  else begin
    regCs[0]    <= (RBCP_ADDR[31:4]==28'h0); // 0x0~0xF
    regCs[1]    <= (RBCP_ADDR[31:4]==28'h1); // 0x10~0x1F
    regCs[2]    <= (RBCP_ADDR[31:4]==28'h2); // 0x20~0x2F
    regCs[3]    <= (RBCP_ADDR[31:4]==28'h3); // 0x30~0x3F
    regCs[4]    <= (RBCP_ADDR[31:4]==28'h4); // 0x40~0x4F
    regCs[5]    <= (RBCP_ADDR[31:4]==28'h5); // 0x50~0x5F
    regCs[6]    <= (RBCP_ADDR[31:4]==28'h6); // 0x60~0x6F
    regCs[7]    <= (RBCP_ADDR[31:4]==28'h7); // 0x70~0x7F
    i2cCs       <= (RBCP_ADDR[31:8]==24'h1); // 0x100~0x1FF
    smonCs      <= (RBCP_ADDR[31:8]==24'h2); // 0x200~0x2FF
    irAddr[7:0] <= RBCP_ADDR[7:0];
    irWe        <= RBCP_WE;
    irRe        <= RBCP_RE;
    irWd[7:0]   <= RBCP_WD[7:0];
  end
end

//------------------------------------------------------------------------------
//  Registers
reg   [7:0]   x00_Reg;
reg   [7:0]   x01_Reg;
reg   [7:0]   x02_Reg;
reg   [7:0]   x03_Reg;
reg   [7:0]   x04_Reg;
reg   [7:0]   x05_Reg;
reg   [7:0]   x06_Reg;
reg   [7:0]   x07_Reg;
reg   [7:0]   x08_Reg;
reg   [7:0]   x09_Reg;
reg   [7:0]   x0A_Reg;
reg   [7:0]   x0B_Reg;
reg   [7:0]   x0C_Reg;
reg   [7:0]   x0D_Reg;
reg   [7:0]   x0E_Reg;
reg   [7:0]   x0F_Reg;

reg   [7:0]   x10_Reg;
reg   [7:0]   x11_Reg;
reg   [7:0]   x12_Reg;
reg   [7:0]   x13_Reg;
reg   [7:0]   x14_Reg;
reg   [7:0]   x15_Reg;
reg   [7:0]   x16_Reg;
reg   [7:0]   x17_Reg;
reg   [7:0]   x18_Reg;
reg   [7:0]   x19_Reg;
reg   [7:0]   x1A_Reg;
reg   [7:0]   x1B_Reg;
reg   [7:0]   x1C_Reg;
reg   [7:0]   x1D_Reg;
reg   [7:0]   x1E_Reg;
reg   [7:0]   x1F_Reg;

reg   [7:0]   x20_Reg;
reg   [7:0]   x21_Reg;
reg   [7:0]   x22_Reg;
reg   [7:0]   x23_Reg;
reg   [7:0]   x24_Reg;
reg   [7:0]   x25_Reg;
reg   [7:0]   x26_Reg;
reg   [7:0]   x27_Reg;
reg   [7:0]   x28_Reg;
reg   [7:0]   x29_Reg;
reg   [7:0]   x2A_Reg;
reg   [7:0]   x2B_Reg;
reg   [7:0]   x2C_Reg;
reg   [7:0]   x2D_Reg;
reg   [7:0]   x2E_Reg;
reg   [7:0]   x2F_Reg;

reg   [7:0]   x30_Reg;
reg   [7:0]   x31_Reg;
reg   [7:0]   x32_Reg;
reg   [7:0]   x33_Reg;
reg   [7:0]   x34_Reg;
reg   [7:0]   x35_Reg;
reg   [7:0]   x36_Reg;
reg   [7:0]   x37_Reg;
reg   [7:0]   x38_Reg;
reg   [7:0]   x39_Reg;
reg   [7:0]   x3A_Reg;
reg   [7:0]   x3B_Reg;
reg   [7:0]   x3C_Reg;
reg   [7:0]   x3D_Reg;
reg   [7:0]   x3E_Reg;
reg   [7:0]   x3F_Reg;

reg   [7:0]   x40_Reg;
reg   [7:0]   x41_Reg;
reg   [7:0]   x42_Reg;
reg   [7:0]   x43_Reg;
reg   [7:0]   x44_Reg;
reg   [7:0]   x45_Reg;
reg   [7:0]   x46_Reg;
reg   [7:0]   x47_Reg;
reg   [7:0]   x48_Reg;
reg   [7:0]   x49_Reg;
reg   [7:0]   x4A_Reg;
reg   [7:0]   x4B_Reg;
reg   [7:0]   x4C_Reg;
reg   [7:0]   x4D_Reg;
reg   [7:0]   x4E_Reg;
reg   [7:0]   x4F_Reg;

reg   [7:0]   x50_Reg;
reg   [7:0]   x51_Reg;
reg   [7:0]   x52_Reg;
reg   [7:0]   x53_Reg;
reg   [7:0]   x54_Reg;
reg   [7:0]   x55_Reg;
reg   [7:0]   x56_Reg;
reg   [7:0]   x57_Reg;
reg   [7:0]   x58_Reg;
reg   [7:0]   x59_Reg;
reg   [7:0]   x5A_Reg;
reg   [7:0]   x5B_Reg;
reg   [7:0]   x5C_Reg;
reg   [7:0]   x5D_Reg;
reg   [7:0]   x5E_Reg;
reg   [7:0]   x5F_Reg;

reg   [7:0]   x60_Reg;
reg   [7:0]   x61_Reg;
reg   [7:0]   x62_Reg;
reg   [7:0]   x63_Reg;
reg   [7:0]   x64_Reg;
reg   [7:0]   x65_Reg;
reg   [7:0]   x66_Reg;
reg   [7:0]   x67_Reg;
reg   [7:0]   x68_Reg;
reg   [7:0]   x69_Reg;
reg   [7:0]   x6A_Reg;
reg   [7:0]   x6B_Reg;
reg   [7:0]   x6C_Reg;
reg   [7:0]   x6D_Reg;
reg   [7:0]   x6E_Reg;
reg   [7:0]   x6F_Reg;

reg   [7:0]   x70_Reg;
reg   [7:0]   x71_Reg;
reg   [7:0]   x72_Reg;
reg   [7:0]   x73_Reg;
reg   [7:0]   x74_Reg;
reg   [7:0]   x75_Reg;
reg   [7:0]   x76_Reg;
reg   [7:0]   x77_Reg;
reg   [7:0]   x78_Reg;
reg   [7:0]   x79_Reg;
reg   [7:0]   x7A_Reg;
reg   [7:0]   x7B_Reg;
reg   [7:0]   x7C_Reg;
reg   [7:0]   x7D_Reg;
reg   [7:0]   x7E_Reg;
reg   [7:0]   x7F_Reg;

always@ (posedge CLK) begin
  if(RST)begin
    x00_Reg[7:0]    <= SYN_DATE[31:24];
    x01_Reg[7:0]    <= SYN_DATE[23:16];
    x02_Reg[7:0]    <= SYN_DATE[15: 8];
    x03_Reg[7:0]    <= SYN_DATE[ 7: 0];
    x04_Reg[7:0]    <= FPGA_VER[ 7: 0];
    x05_Reg[7:0]    <= 8'h0;
    x06_Reg[7:0]    <= 8'h0;
    x07_Reg[7:0]    <= 8'h0;
    x08_Reg[7:0]    <= 8'h0;
    x09_Reg[7:0]    <= 8'h0;
    x0A_Reg[7:0]    <= 8'h0;
    x0B_Reg[7:0]    <= 8'h0;
    x0C_Reg[7:0]    <= 8'h0;
    x0D_Reg[7:0]    <= 8'h0;
    x0E_Reg[7:0]    <= 8'h0;
    x0F_Reg[7:0]    <= 8'h0;

    x10_Reg[7:0]    <= 8'h0;
    x11_Reg[7:0]    <= 8'h0;
    x12_Reg[7:0]    <= 8'h0;
    x13_Reg[7:0]    <= 8'h0;
    x14_Reg[7:0]    <= 8'h0;
    x15_Reg[7:0]    <= 8'h0;
    x16_Reg[7:0]    <= 8'h0;
    x17_Reg[7:0]    <= 8'h0;
    x18_Reg[7:0]    <= 8'h0;
    x19_Reg[7:0]    <= 8'h0;
    x1A_Reg[7:0]    <= 8'h0;
    x1B_Reg[7:0]    <= 8'h0;
    x1C_Reg[7:0]    <= 8'h0;
    x1D_Reg[7:0]    <= 8'h0;
    x1E_Reg[7:0]    <= 8'h0;
    x1F_Reg[7:0]    <= 8'h0;

    x20_Reg[7:0]    <= 8'h0;
    x21_Reg[7:0]    <= 8'h0;
    x22_Reg[7:0]    <= 8'h0;
    x23_Reg[7:0]    <= 8'h0;
    x24_Reg[7:0]    <= 8'h0;
    x25_Reg[7:0]    <= 8'h0;
    x26_Reg[7:0]    <= 8'h0;
    x27_Reg[7:0]    <= 8'h0;
    x28_Reg[7:0]    <= 8'h0;
    x29_Reg[7:0]    <= 8'h0;
    x2A_Reg[7:0]    <= 8'h0;
    x2B_Reg[7:0]    <= 8'h0;
    x2C_Reg[7:0]    <= 8'h0;
    x2D_Reg[7:0]    <= 8'h0;
    x2E_Reg[7:0]    <= 8'h0;
    x2F_Reg[7:0]    <= 8'h0;

    x30_Reg[7:0]    <= 8'h0;
    x31_Reg[7:0]    <= 8'h0;
    x32_Reg[7:0]    <= 8'h0;
    x33_Reg[7:0]    <= 8'h0;
    x34_Reg[7:0]    <= 8'h0;
    x35_Reg[7:0]    <= 8'h0;
    x36_Reg[7:0]    <= 8'h0;
    x37_Reg[7:0]    <= 8'h0;
    x38_Reg[7:0]    <= 8'h0;
    x39_Reg[7:0]    <= 8'h0;
    x3A_Reg[7:0]    <= 8'h0;
    x3B_Reg[7:0]    <= 8'h0;
    x3C_Reg[7:0]    <= 8'h0;
    x3D_Reg[7:0]    <= 8'h0;
    x3E_Reg[7:0]    <= 8'h0;
    x3F_Reg[7:0]    <= 8'h0;

    x40_Reg[7:0]    <= 8'h0;
    x41_Reg[7:0]    <= 8'h0;
    x42_Reg[7:0]    <= 8'h0;
    x43_Reg[7:0]    <= 8'h0;
    x44_Reg[7:0]    <= 8'h0;
    x45_Reg[7:0]    <= 8'h0;
    x46_Reg[7:0]    <= 8'h0;
    x47_Reg[7:0]    <= 8'h0;
    x48_Reg[7:0]    <= 8'h0;
    x49_Reg[7:0]    <= 8'h0;
    x4A_Reg[7:0]    <= 8'h0;
    x4B_Reg[7:0]    <= 8'h0;
    x4C_Reg[7:0]    <= 8'h0;
    x4D_Reg[7:0]    <= 8'h0;
    x4E_Reg[7:0]    <= 8'h0;
    x4F_Reg[7:0]    <= 8'h0;

    x50_Reg[7:0]    <= 8'h0;
    x51_Reg[7:0]    <= 8'h0;
    x52_Reg[7:0]    <= 8'h0;
    x53_Reg[7:0]    <= 8'h0;
    x54_Reg[7:0]    <= 8'h0;
    x55_Reg[7:0]    <= 8'h0;
    x56_Reg[7:0]    <= 8'h0;
    x57_Reg[7:0]    <= 8'h0;
    x58_Reg[7:0]    <= 8'h0;
    x59_Reg[7:0]    <= 8'h0;
    x5A_Reg[7:0]    <= 8'h0;
    x5B_Reg[7:0]    <= 8'h0;
    x5C_Reg[7:0]    <= 8'h0;
    x5D_Reg[7:0]    <= 8'h0;
    x5E_Reg[7:0]    <= 8'h0;
    x5F_Reg[7:0]    <= 8'h0;

    x60_Reg[7:0]    <= 8'h0;
    x61_Reg[7:0]    <= 8'h0;
    x62_Reg[7:0]    <= 8'h0;
    x63_Reg[7:0]    <= 8'h0;
    x64_Reg[7:0]    <= 8'h0;
    x65_Reg[7:0]    <= 8'h0;
    x66_Reg[7:0]    <= 8'h0;
    x67_Reg[7:0]    <= 8'h0;
    x68_Reg[7:0]    <= 8'h0;
    x69_Reg[7:0]    <= 8'h0;
    x6A_Reg[7:0]    <= 8'h0;
    x6B_Reg[7:0]    <= 8'h0;
    x6C_Reg[7:0]    <= 8'h0;
    x6D_Reg[7:0]    <= 8'h0;
    x6E_Reg[7:0]    <= 8'h0;
    x6F_Reg[7:0]    <= 8'h0;

    x70_Reg[7:0]    <= 8'h0;
    x71_Reg[7:0]    <= 8'h0;
    x72_Reg[7:0]    <= 8'h0;
    x73_Reg[7:0]    <= 8'h0;
    x74_Reg[7:0]    <= 8'h0;
    x75_Reg[7:0]    <= 8'h0;
    x76_Reg[7:0]    <= 8'h0;
    x77_Reg[7:0]    <= 8'h0;
    x78_Reg[7:0]    <= 8'h0;
    x79_Reg[7:0]    <= 8'h0;
    x7A_Reg[7:0]    <= 8'h0;
    x7B_Reg[7:0]    <= 8'h0;
    x7C_Reg[7:0]    <= 8'h0;
    x7D_Reg[7:0]    <= 8'h0;
    x7E_Reg[7:0]    <= 8'h0;
    x7F_Reg[7:0]    <= 8'h0;
  end
  else begin
    x05_Reg[7:0]    <= DIP_SW;
    if(irWe)begin
      // x00~x04 readonly
      // x05 is changed by logic
      x06_Reg[7:0]    <= (regCs[0] & (irAddr[3:0]==4'h6) ? irWd[7:0] : x06_Reg[7:0]);
      x07_Reg[7:0]    <= (regCs[0] & (irAddr[3:0]==4'h7) ? irWd[7:0] : x07_Reg[7:0]);
      x08_Reg[7:0]    <= (regCs[0] & (irAddr[3:0]==4'h8) ? irWd[7:0] : x08_Reg[7:0]);
      x09_Reg[7:0]    <= (regCs[0] & (irAddr[3:0]==4'h9) ? irWd[7:0] : x09_Reg[7:0]);
      x0A_Reg[7:0]    <= (regCs[0] & (irAddr[3:0]==4'hA) ? irWd[7:0] : x0A_Reg[7:0]);
      x0B_Reg[7:0]    <= (regCs[0] & (irAddr[3:0]==4'hB) ? irWd[7:0] : x0B_Reg[7:0]);
      x0C_Reg[7:0]    <= (regCs[0] & (irAddr[3:0]==4'hC) ? irWd[7:0] : x0C_Reg[7:0]);
      x0D_Reg[7:0]    <= (regCs[0] & (irAddr[3:0]==4'hD) ? irWd[7:0] : x0D_Reg[7:0]);
      x0E_Reg[7:0]    <= (regCs[0] & (irAddr[3:0]==4'hE) ? irWd[7:0] : x0E_Reg[7:0]);
      x0F_Reg[7:0]    <= (regCs[0] & (irAddr[3:0]==4'hF) ? irWd[7:0] : x0F_Reg[7:0]);

      x10_Reg[7:0]    <= (regCs[1] & (irAddr[3:0]==4'h0) ? irWd[7:0] : x10_Reg[7:0]);
      x11_Reg[7:0]    <= (regCs[1] & (irAddr[3:0]==4'h1) ? irWd[7:0] : x11_Reg[7:0]);
      x12_Reg[7:0]    <= (regCs[1] & (irAddr[3:0]==4'h2) ? irWd[7:0] : x12_Reg[7:0]);
      x13_Reg[7:0]    <= (regCs[1] & (irAddr[3:0]==4'h3) ? irWd[2:0] : x13_Reg[7:0]);
      x14_Reg[7:0]    <= (regCs[1] & (irAddr[3:0]==4'h4) ? irWd[7:0] : x14_Reg[7:0]);
      x15_Reg[7:0]    <= (regCs[1] & (irAddr[3:0]==4'h5) ? irWd[7:0] : x15_Reg[7:0]);
      x16_Reg[7:0]    <= (regCs[1] & (irAddr[3:0]==4'h6) ? irWd[7:0] : x16_Reg[7:0]);
      x17_Reg[7:0]    <= (regCs[1] & (irAddr[3:0]==4'h7) ? irWd[7:0] : x17_Reg[7:0]);
      x18_Reg[7:0]    <= (regCs[1] & (irAddr[3:0]==4'h8) ? irWd[7:0] : x17_Reg[7:0]);
      x19_Reg[7:0]    <= (regCs[1] & (irAddr[3:0]==4'h9) ? irWd[7:0] : x17_Reg[7:0]);
      x1A_Reg[7:0]    <= (regCs[1] & (irAddr[3:0]==4'hA) ? irWd[7:0] : x17_Reg[7:0]);
      x1B_Reg[7:0]    <= (regCs[1] & (irAddr[3:0]==4'hB) ? irWd[7:0] : x17_Reg[7:0]);
      x1C_Reg[7:0]    <= (regCs[1] & (irAddr[3:0]==4'hC) ? irWd[7:0] : x1C_Reg[7:0]);
      x1D_Reg[7:0]    <= (regCs[1] & (irAddr[3:0]==4'hD) ? irWd[7:0] : x1D_Reg[7:0]);
      x1E_Reg[7:0]    <= (regCs[1] & (irAddr[3:0]==4'hE) ? irWd[7:0] : x1E_Reg[7:0]);
      x1F_Reg[7:0]    <= (regCs[1] & (irAddr[3:0]==4'hF) ? irWd[7:0] : x1F_Reg[7:0]);

      x20_Reg[7:0]    <= (regCs[2] & (irAddr[3:0]==4'h0) ? irWd[7:0] : x20_Reg[7:0]);
      x21_Reg[7:0]    <= (regCs[2] & (irAddr[3:0]==4'h1) ? irWd[7:0] : x21_Reg[7:0]);
      x22_Reg[7:0]    <= (regCs[2] & (irAddr[3:0]==4'h2) ? irWd[7:0] : x22_Reg[7:0]);
      x23_Reg[7:0]    <= (regCs[2] & (irAddr[3:0]==4'h3) ? irWd[7:0] : x23_Reg[7:0]);
      x24_Reg[7:0]    <= (regCs[2] & (irAddr[3:0]==4'h4) ? irWd[7:0] : x24_Reg[7:0]);
      x25_Reg[7:0]    <= (regCs[2] & (irAddr[3:0]==4'h5) ? irWd[7:0] : x25_Reg[7:0]);
      x26_Reg[7:0]    <= (regCs[2] & (irAddr[3:0]==4'h6) ? irWd[7:0] : x26_Reg[7:0]);
      x27_Reg[7:0]    <= (regCs[2] & (irAddr[3:0]==4'h7) ? irWd[7:0] : x27_Reg[7:0]);
      x28_Reg[7:0]    <= (regCs[2] & (irAddr[3:0]==4'h8) ? irWd[7:0] : x28_Reg[7:0]);
      x29_Reg[7:0]    <= (regCs[2] & (irAddr[3:0]==4'h9) ? irWd[7:0] : x29_Reg[7:0]);
      x2A_Reg[7:0]    <= (regCs[2] & (irAddr[3:0]==4'hA) ? irWd[7:0] : x2A_Reg[7:0]);
      x2B_Reg[7:0]    <= (regCs[2] & (irAddr[3:0]==4'hB) ? irWd[7:0] : x2B_Reg[7:0]);
      x2C_Reg[7:0]    <= (regCs[2] & (irAddr[3:0]==4'hC) ? irWd[7:0] : x2C_Reg[7:0]);
      x2D_Reg[7:0]    <= (regCs[2] & (irAddr[3:0]==4'hD) ? irWd[7:0] : x2D_Reg[7:0]);
      x2E_Reg[7:0]    <= (regCs[2] & (irAddr[3:0]==4'hE) ? irWd[7:0] : x2E_Reg[7:0]);
      x2F_Reg[7:0]    <= (regCs[2] & (irAddr[3:0]==4'hF) ? irWd[7:0] : x2F_Reg[7:0]);

      x30_Reg[7:0]    <= (regCs[3] & (irAddr[3:0]==4'h0) ? irWd[7:0] : x30_Reg[7:0]);
      x31_Reg[7:0]    <= (regCs[3] & (irAddr[3:0]==4'h1) ? irWd[7:0] : x31_Reg[7:0]);
      x32_Reg[7:0]    <= (regCs[3] & (irAddr[3:0]==4'h2) ? irWd[7:0] : x32_Reg[7:0]);
      x33_Reg[7:0]    <= (regCs[3] & (irAddr[3:0]==4'h3) ? irWd[7:0] : x33_Reg[7:0]);
      x34_Reg[7:0]    <= (regCs[3] & (irAddr[3:0]==4'h4) ? irWd[7:0] : x34_Reg[7:0]);
      x35_Reg[7:0]    <= (regCs[3] & (irAddr[3:0]==4'h5) ? irWd[7:0] : x35_Reg[7:0]);
      x36_Reg[7:0]    <= (regCs[3] & (irAddr[3:0]==4'h6) ? irWd[7:0] : x36_Reg[7:0]);
      x37_Reg[7:0]    <= (regCs[3] & (irAddr[3:0]==4'h7) ? irWd[7:0] : x37_Reg[7:0]);
      x38_Reg[7:0]    <= (regCs[3] & (irAddr[3:0]==4'h8) ? irWd[7:0] : x38_Reg[7:0]);
      x39_Reg[7:0]    <= (regCs[3] & (irAddr[3:0]==4'h9) ? irWd[7:0] : x39_Reg[7:0]);
      x3A_Reg[7:0]    <= (regCs[3] & (irAddr[3:0]==4'hA) ? irWd[7:0] : x3A_Reg[7:0]);
      x3B_Reg[7:0]    <= (regCs[3] & (irAddr[3:0]==4'hB) ? irWd[7:0] : x3B_Reg[7:0]);
      x3C_Reg[7:0]    <= (regCs[3] & (irAddr[3:0]==4'hC) ? irWd[7:0] : x3C_Reg[7:0]);
      x3D_Reg[7:0]    <= (regCs[3] & (irAddr[3:0]==4'hD) ? irWd[7:0] : x3D_Reg[7:0]);
      x3E_Reg[7:0]    <= (regCs[3] & (irAddr[3:0]==4'hE) ? irWd[7:0] : x3E_Reg[7:0]);
      x3F_Reg[7:0]    <= (regCs[3] & (irAddr[3:0]==4'hF) ? irWd[7:0] : x3F_Reg[7:0]);

      x40_Reg[7:0]    <= (regCs[4] & (irAddr[3:0]==4'h0) ? irWd[7:0] : x40_Reg[7:0]);
      x41_Reg[7:0]    <= (regCs[4] & (irAddr[3:0]==4'h1) ? irWd[7:0] : x41_Reg[7:0]);
      x42_Reg[7:0]    <= (regCs[4] & (irAddr[3:0]==4'h2) ? irWd[7:0] : x42_Reg[7:0]);
      x43_Reg[7:0]    <= (regCs[4] & (irAddr[3:0]==4'h3) ? irWd[7:0] : x43_Reg[7:0]);
      x44_Reg[7:0]    <= (regCs[4] & (irAddr[3:0]==4'h4) ? irWd[7:0] : x44_Reg[7:0]);
      x45_Reg[7:0]    <= (regCs[4] & (irAddr[3:0]==4'h5) ? irWd[7:0] : x45_Reg[7:0]);
      x46_Reg[7:0]    <= (regCs[4] & (irAddr[3:0]==4'h6) ? irWd[7:0] : x46_Reg[7:0]);
      x47_Reg[7:0]    <= (regCs[4] & (irAddr[3:0]==4'h7) ? irWd[7:0] : x47_Reg[7:0]);
      x48_Reg[7:0]    <= (regCs[4] & (irAddr[3:0]==4'h8) ? irWd[7:0] : x48_Reg[7:0]);
      x49_Reg[7:0]    <= (regCs[4] & (irAddr[3:0]==4'h9) ? irWd[7:0] : x49_Reg[7:0]);
      x4A_Reg[7:0]    <= (regCs[4] & (irAddr[3:0]==4'hA) ? irWd[7:0] : x4A_Reg[7:0]);
      x4B_Reg[7:0]    <= (regCs[4] & (irAddr[3:0]==4'hB) ? irWd[7:0] : x4B_Reg[7:0]);
      x4C_Reg[7:0]    <= (regCs[4] & (irAddr[3:0]==4'hC) ? irWd[7:0] : x4C_Reg[7:0]);
      x4D_Reg[7:0]    <= (regCs[4] & (irAddr[3:0]==4'hD) ? irWd[7:0] : x4D_Reg[7:0]);
      x4E_Reg[7:0]    <= (regCs[4] & (irAddr[3:0]==4'hE) ? irWd[7:0] : x4E_Reg[7:0]);
      x4F_Reg[7:0]    <= (regCs[4] & (irAddr[3:0]==4'hF) ? irWd[7:0] : x4F_Reg[7:0]);

      x50_Reg[7:0]    <= (regCs[5] & (irAddr[3:0]==4'h0) ? irWd[7:0] : x50_Reg[7:0]);
      x51_Reg[7:0]    <= (regCs[5] & (irAddr[3:0]==4'h1) ? irWd[7:0] : x51_Reg[7:0]);
      x52_Reg[7:0]    <= (regCs[5] & (irAddr[3:0]==4'h2) ? irWd[7:0] : x52_Reg[7:0]);
      x53_Reg[7:0]    <= (regCs[5] & (irAddr[3:0]==4'h3) ? irWd[7:0] : x53_Reg[7:0]);
      x54_Reg[7:0]    <= (regCs[5] & (irAddr[3:0]==4'h4) ? irWd[7:0] : x54_Reg[7:0]);
      x55_Reg[7:0]    <= (regCs[5] & (irAddr[3:0]==4'h5) ? irWd[7:0] : x55_Reg[7:0]);
      x56_Reg[7:0]    <= (regCs[5] & (irAddr[3:0]==4'h6) ? irWd[7:0] : x56_Reg[7:0]);
      x57_Reg[7:0]    <= (regCs[5] & (irAddr[3:0]==4'h7) ? irWd[7:0] : x57_Reg[7:0]);
      x58_Reg[7:0]    <= (regCs[5] & (irAddr[3:0]==4'h8) ? irWd[7:0] : x58_Reg[7:0]);
      x59_Reg[7:0]    <= (regCs[5] & (irAddr[3:0]==4'h9) ? irWd[7:0] : x59_Reg[7:0]);
      x5A_Reg[7:0]    <= (regCs[5] & (irAddr[3:0]==4'hA) ? irWd[7:0] : x5A_Reg[7:0]);
      x5B_Reg[7:0]    <= (regCs[5] & (irAddr[3:0]==4'hB) ? irWd[7:0] : x5B_Reg[7:0]);
      x5C_Reg[7:0]    <= (regCs[5] & (irAddr[3:0]==4'hC) ? irWd[7:0] : x5C_Reg[7:0]);
      x5D_Reg[7:0]    <= (regCs[5] & (irAddr[3:0]==4'hD) ? irWd[7:0] : x5D_Reg[7:0]);
      x5E_Reg[7:0]    <= (regCs[5] & (irAddr[3:0]==4'hE) ? irWd[7:0] : x5E_Reg[7:0]);
      x5F_Reg[7:0]    <= (regCs[5] & (irAddr[3:0]==4'hF) ? irWd[7:0] : x5F_Reg[7:0]);

      x60_Reg[7:0]    <= (regCs[6] & (irAddr[3:0]==4'h0) ? irWd[7:0] : x60_Reg[7:0]);
      x61_Reg[7:0]    <= (regCs[6] & (irAddr[3:0]==4'h1) ? irWd[7:0] : x61_Reg[7:0]);
      x62_Reg[7:0]    <= (regCs[6] & (irAddr[3:0]==4'h2) ? irWd[7:0] : x62_Reg[7:0]);
      x63_Reg[7:0]    <= (regCs[6] & (irAddr[3:0]==4'h3) ? irWd[7:0] : x63_Reg[7:0]);
      x64_Reg[7:0]    <= (regCs[6] & (irAddr[3:0]==4'h4) ? irWd[7:0] : x64_Reg[7:0]);
      x65_Reg[7:0]    <= (regCs[6] & (irAddr[3:0]==4'h5) ? irWd[7:0] : x65_Reg[7:0]);
      x66_Reg[7:0]    <= (regCs[6] & (irAddr[3:0]==4'h6) ? irWd[7:0] : x66_Reg[7:0]);
      x67_Reg[7:0]    <= (regCs[6] & (irAddr[3:0]==4'h7) ? irWd[7:0] : x67_Reg[7:0]);
      x68_Reg[7:0]    <= (regCs[6] & (irAddr[3:0]==4'h8) ? irWd[7:0] : x68_Reg[7:0]);
      x69_Reg[7:0]    <= (regCs[6] & (irAddr[3:0]==4'h9) ? irWd[7:0] : x69_Reg[7:0]);
      x6A_Reg[7:0]    <= (regCs[6] & (irAddr[3:0]==4'hA) ? irWd[7:0] : x6A_Reg[7:0]);
      x6B_Reg[7:0]    <= (regCs[6] & (irAddr[3:0]==4'hB) ? irWd[7:0] : x6B_Reg[7:0]);
      x6C_Reg[7:0]    <= (regCs[6] & (irAddr[3:0]==4'hC) ? irWd[7:0] : x6C_Reg[7:0]);
      x6D_Reg[7:0]    <= (regCs[6] & (irAddr[3:0]==4'hD) ? irWd[7:0] : x6D_Reg[7:0]);
      x6E_Reg[7:0]    <= (regCs[6] & (irAddr[3:0]==4'hE) ? irWd[7:0] : x6E_Reg[7:0]);
      x6F_Reg[7:0]    <= (regCs[6] & (irAddr[3:0]==4'hF) ? irWd[7:0] : x6F_Reg[7:0]);

      x70_Reg[7:0]    <= (regCs[7] & (irAddr[3:0]==4'h0) ? irWd[7:0] : x70_Reg[7:0]);
      x71_Reg[7:0]    <= (regCs[7] & (irAddr[3:0]==4'h1) ? irWd[7:0] : x71_Reg[7:0]);
      x72_Reg[7:0]    <= (regCs[7] & (irAddr[3:0]==4'h2) ? irWd[7:0] : x72_Reg[7:0]);
      x73_Reg[7:0]    <= (regCs[7] & (irAddr[3:0]==4'h3) ? irWd[7:0] : x73_Reg[7:0]);
      x74_Reg[7:0]    <= (regCs[7] & (irAddr[3:0]==4'h4) ? irWd[7:0] : x74_Reg[7:0]);
      x75_Reg[7:0]    <= (regCs[7] & (irAddr[3:0]==4'h5) ? irWd[7:0] : x75_Reg[7:0]);
      x76_Reg[7:0]    <= (regCs[7] & (irAddr[3:0]==4'h6) ? irWd[7:0] : x76_Reg[7:0]);
      x77_Reg[7:0]    <= (regCs[7] & (irAddr[3:0]==4'h7) ? irWd[7:0] : x77_Reg[7:0]);
      x78_Reg[7:0]    <= (regCs[7] & (irAddr[3:0]==4'h8) ? irWd[7:0] : x78_Reg[7:0]);
      x79_Reg[7:0]    <= (regCs[7] & (irAddr[3:0]==4'h9) ? irWd[7:0] : x79_Reg[7:0]);
      x7A_Reg[7:0]    <= (regCs[7] & (irAddr[3:0]==4'hA) ? irWd[7:0] : x7A_Reg[7:0]);
      x7B_Reg[7:0]    <= (regCs[7] & (irAddr[3:0]==4'hB) ? irWd[7:0] : x7B_Reg[7:0]);
      x7C_Reg[7:0]    <= (regCs[7] & (irAddr[3:0]==4'hC) ? irWd[7:0] : x7C_Reg[7:0]);
      x7D_Reg[7:0]    <= (regCs[7] & (irAddr[3:0]==4'hD) ? irWd[7:0] : x7D_Reg[7:0]);
      x7E_Reg[7:0]    <= (regCs[7] & (irAddr[3:0]==4'hE) ? irWd[7:0] : x7E_Reg[7:0]);
      x7F_Reg[7:0]    <= (regCs[7] & (irAddr[3:0]==4'hF) ? irWd[7:0] : x7F_Reg[7:0]);
    end
  end
end

//------------------------------------------------------------------------------
wire  [6 :0]  smonAddr = irAddr[7:1];
reg           smonDs;
reg           smonRe;
reg   [1 :0]  smonWe;
reg   [15:0]  smonWd;
reg   [1 :0]  smonAck;
wire  [15:0]  smonRd;
wire          smonRdy;
reg   [15:0]  rdDataMon;
always@ (posedge CLK) begin
  smonDs <= smonCs & (~irAddr[0] & irRe | irAddr[0] & irWe);

  smonRe    <= smonCs &  irAddr[0] & irRe;

  smonWe[0] <= smonCs & ~irAddr[0] & irWe;
  smonWe[1] <= smonCs &  irAddr[0] & irWe;

  if(irWe)begin
    smonWd[15:8] <= (~irAddr[0] ? irWd[7:0] : smonWd[15:8]);
    smonWd[7:0]  <= irWd[7:0];
  end
end

// System monitor
xadc_wiz_0 xadc_wiz_0(
  .dclk_in            (CLK),          // Clock input for the dynamic reconfiguration port
  .reset_in           (RST),          // Reset signal for the System Monitor control logic
  .daddr_in           (smonAddr[6:0]),// Address bus for the dynamic reconfiguration port
  .den_in             (smonDs),       // Enable Signal for the dynamic reconfiguration port
  .dwe_in             (smonWe[1]),    // Write Enable for the dynamic reconfiguration port
  .di_in              (smonWd[15:0]), // Input data bus for the dynamic reconfiguration port
  .do_out             (smonRd[15:0]), // Output data bus for dynamic reconfiguration port
  .drdy_out           (smonRdy),      // Data ready signal for the dynamic reconfiguration port
  .busy_out           (), // ADC Busy signal
  .channel_out        (), // Channel Selection Outputs
  .eoc_out            (), // End of Conversion Signal
  .eos_out            (), // End of Sequence Signal
  .alarm_out          (), // OR'ed output of all the Alarms
  // .jtagbusy_out       (), // JTAG DRP transaction is in progress signal
  // .jtaglocked_out     (), // DRP port lock request has been made by JTAG
  // .jtagmodified_out   (), // Indicates JTAG Write to the DRP has occurred
  // .ot_out             (), // Over-Temperature alarm output
  // .vccaux_alarm_out   (), // VCCAUX-sensor alarm output
  // .vccint_alarm_out   (), // VCCINT-sensor alarm output
  // .user_temp_alarm_out(), // Temperature-sensor alarm output
  .vp_in              (), // Dedicated Analog Input Pair
  .vn_in              ()
);

wire  [7:0]   i2cRd;
wire          i2cAck;
wire  [31:0]  wb_adr;
wire  [7 :0]  wb_dat_i, wb_dat_o;
wire          wb_we;
wire          wb_stb;
wire          wb_cyc;
wire          wb_ack;
RBCP2WB RBCP_to_WishboneBus(
  // system
  .clk        (CLK),        // in
  .rst        (RST),        // in
  // RBCP
  .rbcp_we    (RBCP_WE),    // in
  .rbcp_re    (RBCP_RE),    // in
  .rbcp_wd    (RBCP_WD),    // in
  .rbcp_addr  (RBCP_ADDR),  // in
  .rbcp_act   (RBCP_ACT),   // in
  .rbcp_rd    (i2cRd),      // out
  .rbcp_ack   (i2cAck),     // out
  // Wishbone bus
  .adr        (wb_adr),     // out
  .din        (wb_dat_i),   // in
  .dout       (wb_dat_o),   // out
  .cyc        (wb_cyc),     // out
  .stb        (wb_stb),     // out
  .we         (wb_we),      // out
  .sel        (),           // out
  .ack        (wb_ack),     // in
  .err        (0),          // in
  .rty        (0)           // in
);

wire wb_stb_i2c = wb_stb & i2cCs;
wire scl, scl_o, scl_oen;
wire sda, sda_o, sda_oen;
i2c_master_top i2c(
  // wishbone interface
  .wb_clk_i     (CLK),
  .wb_rst_i     (RST),
  .arst_i       (0),
  .wb_adr_i     (wb_adr[2:0]),
  .wb_dat_i     (wb_dat_o),
  .wb_dat_o     (wb_dat_i),
  .wb_we_i      (wb_we),
  .wb_stb_i     (wb_stb_i2c),
  .wb_cyc_i     (wb_cyc),
  .wb_ack_o     (wb_ack),
  .wb_inta_o    (),
  // i2c signals
  .scl_pad_i    (SCL),
  .scl_pad_o    (SCL_O),
  .scl_padoen_o (SCL_OEN),
  .sda_pad_i    (SDA),
  .sda_pad_o    (SDA_O),
  .sda_padoen_o (SDA_OEN)
);

//--------------------------------------
//  Read data mux.
//--------------------------------------
reg   [7 :0]  rdDataA;
reg   [7 :0]  rdDataB;
reg   [7 :0]  rdDataC;
reg   [7 :0]  rdDataD;
reg   [7 :0]  rdDataE;
reg   [7 :0]  rdDataF;
reg   [7 :0]  rdDataG;
reg   [7 :0]  rdDataH;
reg   [7 :0]  regRv;
reg           regAck;
always@ (posedge CLK) begin
  case(irAddr[3:0])
    4'h0:   rdDataA[7:0]    <= x00_Reg[7:0];
    4'h1:   rdDataA[7:0]    <= x01_Reg[7:0];
    4'h2:   rdDataA[7:0]    <= x02_Reg[7:0];
    4'h3:   rdDataA[7:0]    <= x03_Reg[7:0];
    4'h4:   rdDataA[7:0]    <= x04_Reg[7:0];
    4'h5:   rdDataA[7:0]    <= x05_Reg[7:0];
    4'h6:   rdDataA[7:0]    <= x06_Reg[7:0];
    4'h7:   rdDataA[7:0]    <= x07_Reg[7:0];
    4'h8:   rdDataA[7:0]    <= x08_Reg[7:0];
    4'h9:   rdDataA[7:0]    <= x09_Reg[7:0];
    4'hA:   rdDataA[7:0]    <= x0A_Reg[7:0];
    4'hB:   rdDataA[7:0]    <= x0B_Reg[7:0];
    4'hC:   rdDataA[7:0]    <= x0C_Reg[7:0];
    4'hD:   rdDataA[7:0]    <= x0D_Reg[7:0];
    4'hE:   rdDataA[7:0]    <= x0E_Reg[7:0];
    4'hF:   rdDataA[7:0]    <= x0F_Reg[7:0];
  endcase
  case(irAddr[3:0])
    4'h0:   rdDataB[7:0]    <= x10_Reg[7:0];
    4'h1:   rdDataB[7:0]    <= x11_Reg[7:0];
    4'h2:   rdDataB[7:0]    <= x12_Reg[7:0];
    4'h3:   rdDataB[7:0]    <= x13_Reg[7:0];
    4'h4:   rdDataB[7:0]    <= x14_Reg[7:0];
    4'h5:   rdDataB[7:0]    <= x15_Reg[7:0];
    4'h6:   rdDataB[7:0]    <= x16_Reg[7:0];
    4'h7:   rdDataB[7:0]    <= x17_Reg[7:0];
    4'h8:   rdDataB[7:0]    <= x18_Reg[7:0];
    4'h9:   rdDataB[7:0]    <= x19_Reg[7:0];
    4'hA:   rdDataB[7:0]    <= x1A_Reg[7:0];
    4'hB:   rdDataB[7:0]    <= x1B_Reg[7:0];
    4'hC:   rdDataB[7:0]    <= x1C_Reg[7:0];
    4'hD:   rdDataB[7:0]    <= x1D_Reg[7:0];
    4'hE:   rdDataB[7:0]    <= x1E_Reg[7:0];
    4'hF:   rdDataB[7:0]    <= x1F_Reg[7:0];
  endcase
  case(irAddr[3:0])
    4'h0:   rdDataC[7:0]    <= x20_Reg[7:0];
    4'h1:   rdDataC[7:0]    <= x21_Reg[7:0];
    4'h2:   rdDataC[7:0]    <= x22_Reg[7:0];
    4'h3:   rdDataC[7:0]    <= x23_Reg[7:0];
    4'h4:   rdDataC[7:0]    <= x24_Reg[7:0];
    4'h5:   rdDataC[7:0]    <= x25_Reg[7:0];
    4'h6:   rdDataC[7:0]    <= x26_Reg[7:0];
    4'h7:   rdDataC[7:0]    <= x27_Reg[7:0];
    4'h8:   rdDataC[7:0]    <= x28_Reg[7:0];
    4'h9:   rdDataC[7:0]    <= x29_Reg[7:0];
    4'hA:   rdDataC[7:0]    <= x2A_Reg[7:0];
    4'hB:   rdDataC[7:0]    <= x2B_Reg[7:0];
    4'hC:   rdDataC[7:0]    <= x2C_Reg[7:0];
    4'hD:   rdDataC[7:0]    <= x2D_Reg[7:0];
    4'hE:   rdDataC[7:0]    <= x2E_Reg[7:0];
    4'hF:   rdDataC[7:0]    <= x2F_Reg[7:0];
  endcase
  case(irAddr[3:0])
    4'h0:   rdDataD[7:0]    <= x30_Reg[7:0];
    4'h1:   rdDataD[7:0]    <= x31_Reg[7:0];
    4'h2:   rdDataD[7:0]    <= x32_Reg[7:0];
    4'h3:   rdDataD[7:0]    <= x33_Reg[7:0];
    4'h4:   rdDataD[7:0]    <= x34_Reg[7:0];
    4'h5:   rdDataD[7:0]    <= x35_Reg[7:0];
    4'h6:   rdDataD[7:0]    <= x36_Reg[7:0];
    4'h7:   rdDataD[7:0]    <= x37_Reg[7:0];
    4'h8:   rdDataD[7:0]    <= x38_Reg[7:0];
    4'h9:   rdDataD[7:0]    <= x39_Reg[7:0];
    4'hA:   rdDataD[7:0]    <= x3A_Reg[7:0];
    4'hB:   rdDataD[7:0]    <= x3B_Reg[7:0];
    4'hC:   rdDataD[7:0]    <= x3C_Reg[7:0];
    4'hD:   rdDataD[7:0]    <= x3D_Reg[7:0];
    4'hE:   rdDataD[7:0]    <= x3E_Reg[7:0];
    4'hF:   rdDataD[7:0]    <= x3F_Reg[7:0];
  endcase
  case(irAddr[3:0])
    4'h0:   rdDataE[7:0]    <= x40_Reg[7:0];
    4'h1:   rdDataE[7:0]    <= x41_Reg[7:0];
    4'h2:   rdDataE[7:0]    <= x42_Reg[7:0];
    4'h3:   rdDataE[7:0]    <= x43_Reg[7:0];
    4'h4:   rdDataE[7:0]    <= x44_Reg[7:0];
    4'h5:   rdDataE[7:0]    <= x45_Reg[7:0];
    4'h6:   rdDataE[7:0]    <= x46_Reg[7:0];
    4'h7:   rdDataE[7:0]    <= x47_Reg[7:0];
    4'h8:   rdDataE[7:0]    <= x48_Reg[7:0];
    4'h9:   rdDataE[7:0]    <= x49_Reg[7:0];
    4'hA:   rdDataE[7:0]    <= x4A_Reg[7:0];
    4'hB:   rdDataE[7:0]    <= x4B_Reg[7:0];
    4'hC:   rdDataE[7:0]    <= x4C_Reg[7:0];
    4'hD:   rdDataE[7:0]    <= x4D_Reg[7:0];
    4'hE:   rdDataE[7:0]    <= x4E_Reg[7:0];
    4'hF:   rdDataE[7:0]    <= x4F_Reg[7:0];
  endcase
  case(irAddr[3:0])
    4'h0:   rdDataF[7:0]    <= x50_Reg[7:0];
    4'h1:   rdDataF[7:0]    <= x51_Reg[7:0];
    4'h2:   rdDataF[7:0]    <= x52_Reg[7:0];
    4'h3:   rdDataF[7:0]    <= x53_Reg[7:0];
    4'h4:   rdDataF[7:0]    <= x54_Reg[7:0];
    4'h5:   rdDataF[7:0]    <= x55_Reg[7:0];
    4'h6:   rdDataF[7:0]    <= x56_Reg[7:0];
    4'h7:   rdDataF[7:0]    <= x57_Reg[7:0];
    4'h8:   rdDataF[7:0]    <= x58_Reg[7:0];
    4'h9:   rdDataF[7:0]    <= x59_Reg[7:0];
    4'hA:   rdDataF[7:0]    <= x5A_Reg[7:0];
    4'hB:   rdDataF[7:0]    <= x5B_Reg[7:0];
    4'hC:   rdDataF[7:0]    <= x5C_Reg[7:0];
    4'hD:   rdDataF[7:0]    <= x5D_Reg[7:0];
    4'hE:   rdDataF[7:0]    <= x5E_Reg[7:0];
    4'hF:   rdDataF[7:0]    <= x5F_Reg[7:0];
  endcase
  case(irAddr[3:0])
    4'h0:   rdDataG[7:0]    <= x60_Reg[7:0];
    4'h1:   rdDataG[7:0]    <= x61_Reg[7:0];
    4'h2:   rdDataG[7:0]    <= x62_Reg[7:0];
    4'h3:   rdDataG[7:0]    <= x63_Reg[7:0];
    4'h4:   rdDataG[7:0]    <= x64_Reg[7:0];
    4'h5:   rdDataG[7:0]    <= x65_Reg[7:0];
    4'h6:   rdDataG[7:0]    <= x66_Reg[7:0];
    4'h7:   rdDataG[7:0]    <= x67_Reg[7:0];
    4'h8:   rdDataG[7:0]    <= x68_Reg[7:0];
    4'h9:   rdDataG[7:0]    <= x69_Reg[7:0];
    4'hA:   rdDataG[7:0]    <= x6A_Reg[7:0];
    4'hB:   rdDataG[7:0]    <= x6B_Reg[7:0];
    4'hC:   rdDataG[7:0]    <= x6C_Reg[7:0];
    4'hD:   rdDataG[7:0]    <= x6D_Reg[7:0];
    4'hE:   rdDataG[7:0]    <= x6E_Reg[7:0];
    4'hF:   rdDataG[7:0]    <= x6F_Reg[7:0];
  endcase
  case(irAddr[3:0])
    4'h0:   rdDataH[7:0]    <= x70_Reg[7:0];
    4'h1:   rdDataH[7:0]    <= x71_Reg[7:0];
    4'h2:   rdDataH[7:0]    <= x72_Reg[7:0];
    4'h3:   rdDataH[7:0]    <= x73_Reg[7:0];
    4'h4:   rdDataH[7:0]    <= x74_Reg[7:0];
    4'h5:   rdDataH[7:0]    <= x75_Reg[7:0];
    4'h6:   rdDataH[7:0]    <= x76_Reg[7:0];
    4'h7:   rdDataH[7:0]    <= x77_Reg[7:0];
    4'h8:   rdDataH[7:0]    <= x78_Reg[7:0];
    4'h9:   rdDataH[7:0]    <= x79_Reg[7:0];
    4'hA:   rdDataH[7:0]    <= x7A_Reg[7:0];
    4'hB:   rdDataH[7:0]    <= x7B_Reg[7:0];
    4'hC:   rdDataH[7:0]    <= x7C_Reg[7:0];
    4'hD:   rdDataH[7:0]    <= x7D_Reg[7:0];
    4'hE:   rdDataH[7:0]    <= x7E_Reg[7:0];
    4'hF:   rdDataH[7:0]    <= x7F_Reg[7:0];
  endcase
  regRv[7:0]  <= (irRe    ? regCs[7:0] : 8'd0);
  regAck      <= (|regCs[7:0]) & (irWe | irRe);

  if(smonRdy) rdDataMon[15:0]<= smonRd[15:0];
  smonAck[0]  <= smonCs & smonRdy;
  smonAck[1]  <= smonRe | smonWe[0];
end

//------------------------------------------------------------------------------
//  Output
reg           orAck;
reg   [7:0]   orRd;
always@ (posedge CLK) begin
  orAck     <= regAck | i2cAck | smonAck[1] | smonAck[0];
  orRd[7:0] <=  (regRv[0]   ? rdDataA[7:0]  : 8'd0)|
                (regRv[1]   ? rdDataB[7:0]  : 8'd0)|
                (regRv[2]   ? rdDataC[7:0]  : 8'd0)|
                (regRv[3]   ? rdDataD[7:0]  : 8'd0)|
                (regRv[4]   ? rdDataE[7:0]  : 8'd0)|
                (regRv[5]   ? rdDataF[7:0]  : 8'd0)|
                (regRv[6]   ? rdDataG[7:0]  : 8'd0)|
                (regRv[7]   ? rdDataH[7:0]  : 8'd0)|
                (i2cAck     ? i2cRd[7:0]    : 8'd0)|
                (smonAck[0] ? rdDataMon[15:8] : 8'd0)|
                (smonAck[1] ? rdDataMon[7:0]  : 8'd0);
end

assign  RBCP_ACK      = orAck;
assign  RBCP_RD[7:0]  = orRd[7:0];

//------------------------------------------------------------------------------
assign  LED[7:0]  = x06_Reg[7:0];

endmodule
