/*******************************************************************************
*                                                                              *
* Module      : RBCP_REG                                                       *
* Version     : v 1.0.0 2024/01/11                                             *
*                                                                              *
* Description : Register file                                                  *
*                                                                              *
*                                                                              *
*******************************************************************************/
module RBCP_REG #(
  parameter         USE_CHIPSCOPE = 0,
  parameter [31:0]  SYN_DATE      = 32'h0,
  parameter [7 :0]  FPGA_VER      = 8'h0,
  parameter [3 :0]  I2C_NUM       = 1,
  parameter [3 :0]  SPI_NUM       = 1,
  parameter [3 :0]  UART_NUM      = 1
)(
  // System
  input             CLK,        // in : System clock
  input             RST,        // in : System reset
  // RBCP I/F
  input             RBCP_ACT,   // in : Active
  input   [31:0]    RBCP_ADDR,  // in : Address[31:0]
  input             RBCP_WE,    // in : Write enable
  input   [7 :0]    RBCP_WD,    // in : Write data[7:0]
  input             RBCP_RE,    // in : Read enable
  output  [7 :0]    RBCP_RD,    // out: Read data[7:0]
  output            RBCP_ACK,   // out: Acknowledge
  // User IO
  input             VP_IN,
  input             VN_IN,
  // I2C
  input   [I2C_NUM-1:0]   SCL,
  output  [I2C_NUM-1:0]   SCL_OEN,
  output  [I2C_NUM-1:0]   SCL_O,
  input   [I2C_NUM-1:0]   SDA,
  output  [I2C_NUM-1:0]   SDA_OEN,
  output  [I2C_NUM-1:0]   SDA_O,
  // SPI
  output  [SPI_NUM-1:0]   SCK,
  output  [SPI_NUM-1:0]   MOSI_O,
  input   [SPI_NUM-1:0]   MISO_I,
  // UART
  input   [UART_NUM-1:0]  UART_RX,
  output  [UART_NUM-1:0]  UART_TX
);
////////////////////////////////////////////////////////////////////////////////
// WishBone bus arbitrator
// reg:             0x0000_0000 to 0x0000_FFFF
// system_monitor:  0x0001_0000 to 0x0001_FFFF (sub address:          0x0 to 0x3FC)
// i2c  x I2C_NUM:  0x0002_0000 to 0x0002_FFFF (each i2c sub address: 0x0 to 0x4 or 0xFF )
// spi  x SPI_NUM:  0x0003_0000 to 0x0003_FFFF (each spi sub address: 0x0 to 0x3 or 0xFF)
// uart x UART_NUM: 0x0004_0000 to 0x0004_FFFF (each uart sub address: 0x0 to 0x6 or 0xFF)

// SiTCP:           0xFFFF_0000 to 0xFFFF_FDFF, Reserved
//                  0xFFFF_FE00 to 0xFFFF_FEFF, Ethernet PHY MIF I/F
//                  0xFFFF_FF00 to 0xFFFF_FFFF, SITCP controll register

reg           reg_cs;
reg           smon_cs;
reg           i2c_cs;
reg           spi_cs;
reg           uart_cs;

//  Input buffer
reg   [15:0]  ir_addr;
reg           ir_we;
reg   [7 :0]  ir_wd;
reg           ir_re;

wire [15: 0]  arb_addr = RBCP_ADDR[31:16];

always@ (posedge CLK) begin
  if(RST) begin
    reg_cs  <= 0;
    smon_cs <= 0;
    i2c_cs  <= 0;
    spi_cs  <= 0;
    uart_cs <= 0;

    ir_addr <= 0;
    ir_we   <= 0;
    ir_wd   <= 0;
    ir_re   <= 0;
  end
  else begin
    reg_cs   <= (arb_addr==16'h0);
    smon_cs  <= (arb_addr==16'h1);
    i2c_cs   <= (arb_addr==16'h2);
    spi_cs   <= (arb_addr==16'h3);
    uart_cs  <= (arb_addr==16'h4);

    ir_addr  <= RBCP_ADDR[15:0];
    ir_we    <= RBCP_WE;
    ir_re    <= RBCP_RE;
    ir_wd    <= RBCP_WD;
  end
end

////////////////////////////////////////////////////////////////////////////////
wire  [6 :0]  smon_addr = ir_addr[7:1];
reg           smon_ds;
reg           smon_re;
reg   [1 :0]  smon_we;
reg   [15:0]  smon_wd;
reg   [1 :0]  smon_ack;
wire  [15:0]  smon_rd;
wire          smon_rdy;
reg   [15:0]  smon_rd_dat;
always@ (posedge CLK) begin
  smon_ds    <= smon_cs & (~ir_addr[0] & ir_re | ir_addr[0] & ir_we);
  smon_re    <= smon_cs &  ir_addr[0] & ir_re;
  smon_we[0] <= smon_cs & ~ir_addr[0] & ir_we;
  smon_we[1] <= smon_cs &  ir_addr[0] & ir_we;
  if(ir_we)begin
    smon_wd[15:8] <= (~ir_addr[0] ? ir_wd[7:0] : smon_wd[15:8]);
    smon_wd[7:0]  <= ir_wd[7:0];
  end
end

// System monitor
xadc_wiz xadc_wiz(
  .dclk_in            (CLK),          // Clock input for the dynamic reconfiguration port
  .reset_in           (RST),          // Reset signal for the System Monitor control logic
  .daddr_in           (smon_addr[6:0]),// Address bus for the dynamic reconfiguration port
  .den_in             (smon_ds),      // Enable Signal for the dynamic reconfiguration port
  .dwe_in             (smon_we[1]),   // Write Enable for the dynamic reconfiguration port
  .di_in              (smon_wd[15:0]),// Input data bus for the dynamic reconfiguration port
  .do_out             (smon_rd[15:0]), // Output data bus for dynamic reconfiguration port
  .drdy_out           (smon_rdy),     // Data ready signal for the dynamic reconfiguration port
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
  .vp_in              (VP_IN), // Dedicated Analog Input Pair
  .vn_in              (VN_IN)
);

always@ (posedge CLK) begin
  if(smon_rdy) smon_rd_dat[15:0]<= smon_rd[15:0];
  smon_ack[0]  <= smon_cs & smon_rdy;
  smon_ack[1]  <= smon_re | smon_we[0];
end

////////////////////////////////////////////////////////////////////////////////
// RBCP and WishBone Bus bridge
wire  [7:0]   w2r_dat;
wire          w2r_ack;
wire  [15:0]  wb_adr;
reg   [7 :0]  wb_dat_slave;
wire  [7 :0]  wb_dat_master;
wire          wb_we;
wire          wb_stb;
wire          wb_cyc;
wire          wb_ack;
RBCP2WB RBCP_to_WishboneBus(
  // system
  .clk        (CLK),          // in
  .rst        (RST),          // in
  // RBCP
  .rbcp_we    (RBCP_WE),      // in
  .rbcp_re    (RBCP_RE),      // in
  .rbcp_wd    (RBCP_WD),      // in
  .rbcp_addr  (RBCP_ADDR[15:0]),// in
  .rbcp_act   (RBCP_ACT),     // in
  .rbcp_rd    (w2r_dat),       // out
  .rbcp_ack   (w2r_ack),      // out
  // WishBone bus
  .adr        (wb_adr),       // out
  .din        (wb_dat_slave), // in
  .dout       (wb_dat_master),// out
  .cyc        (wb_cyc),       // out
  .stb        (wb_stb),       // out
  .we         (wb_we),        // out
  .sel        (),             // out
  .ack        (wb_ack),       // in
  .err        (0),            // in
  .rty        (0)             // in
);

//------------------------------------------------------------------------------
//  Output
reg           or_ack;
reg   [7 :0]  or_dat;
always@ (posedge CLK) begin
  or_ack <= w2r_ack | smon_ack[1] | smon_ack[0];
  or_dat <=  (w2r_ack     ? w2r_dat[7:0]      : 8'd0)|
            (smon_ack[0] ? smon_rd_dat[15:8] : 8'd0)|
            (smon_ack[1] ? smon_rd_dat[7:0]  : 8'd0);
end

assign  RBCP_ACK  = or_ack;
assign  RBCP_RD   = or_dat;

//------------------------------------------------------------------------------
// WishBone bus devices

wire [7 : 0]  sub_arb_addr = RBCP_ADDR[15:8];

wire [7 : 0]  wb_reg_dat;
wire          wb_reg_ack;

reg_table #(
  .ADDRESS_WIDTH                (16),
  .USE_STALL                    (1),
  .SYN_INFO_YEAR_INITIAL_VALUE  (SYN_DATE[31:24]),
  .SYN_INFO_MONTH_INITIAL_VALUE (SYN_DATE[23:16]),
  .SYN_INFO_DATE_INITIAL_VALUE  (SYN_DATE[15:8]),
  .SYN_INFO_HOUR_INITIAL_VALUE  (SYN_DATE[7:0]),
  .SYN_VER_INITIAL_VALUE        (FPGA_VER)
)reg_table(
  .i_clk      (CLK),
  .i_rst_n    (~RST),
  .i_wb_cyc   (wb_cyc),
  .i_wb_stb   (wb_stb & reg_cs),
  .i_wb_adr   (wb_adr),
  .i_wb_we    (wb_we),
  .i_wb_dat   (wb_dat_master),
  .i_wb_sel   (4'b1),
  .o_wb_dat   (wb_reg_dat),
  .o_wb_ack   (wb_reg_ack),
  .o_wb_err   (),
  .o_wb_rty   (),
  .o_wb_stall ()
);


genvar i;

wire [I2C_NUM*8-1:0] wb_i2c_dat;
wire [I2C_NUM-1  :0] wb_i2c_ack;
generate
  for (i = 0; i < I2C_NUM; i = i+1) begin: i2c_gen
    i2c_master_top i2c(
      // wishbone interface
      .wb_clk_i     (CLK),
      .wb_rst_i     (RST),
      .arst_i       (0),
      .wb_adr_i     (wb_adr[2:0]),
      .wb_dat_i     (wb_dat_master),
      .wb_dat_o     (wb_i2c_dat[i*8+7:i*8]),
      .wb_we_i      (wb_we),
      .wb_stb_i     (wb_stb & i2c_cs & (sub_arb_addr==i)),
      .wb_cyc_i     (wb_cyc),
      .wb_ack_o     (wb_i2c_ack[i]),
      .wb_inta_o    (),
      // i2c signals
      .scl_pad_i    (SCL[i]),
      .scl_pad_o    (SCL_O[i]),
      .scl_padoen_o (SCL_OEN[i]),
      .sda_pad_i    (SDA[i]),
      .sda_pad_o    (SDA_O[i]),
      .sda_padoen_o (SDA_OEN[i])
    );
  end
endgenerate

wire [SPI_NUM*8-1:0] wb_spi_dat;
wire [SPI_NUM-1  :0] wb_spi_ack;
generate
  for (i = 0; i < SPI_NUM; i = i+1) begin: spi_gen
    simple_spi_top spi(
      .clk_i  (CLK),
      .rst_i  (~RST),
      .cyc_i  (wb_cyc),
      .stb_i  (wb_stb & spi_cs & (sub_arb_addr==i)),
      .adr_i  (wb_adr[1:0]),
      .we_i   (wb_we),
      .dat_i  (wb_dat_master),
      .dat_o  (wb_spi_dat[i*8+7:i*8]),
      .ack_o  (wb_spi_ack[i]),
      .inta_o (),
      .sck_o  (SCK[i]),
      .mosi_o (MOSI_O[i]),
      .miso_i (MISO_I[i])
    );
  end
endgenerate

wire [UART_NUM*8-1:0] wb_uart_dat;
wire [UART_NUM-1  :0] wb_uart_ack;
generate
  for (i = 0; i < UART_NUM; i = i+1) begin: uart_gen
    uart_top uart(
      .wb_clk_i  (CLK),
      .wb_rst_i  (RST),
      .wb_adr_i  (wb_adr[2:0]),
      .wb_dat_i  (wb_dat_master),
      .wb_dat_o  (wb_uart_dat[i*8+7:i*8]),
      .wb_we_i   (wb_we),
      .wb_stb_i  (wb_stb & uart_cs & (sub_arb_addr==i)),
      .wb_cyc_i  (wb_cyc),
      .wb_sel_i  (4'b1),
      .wb_ack_o  (wb_uart_ack[i]),
      .int_o     (),
      .srx_pad_i (UART_RX[i]),
      .stx_pad_o (UART_TX[i]),
      .rts_pad_o (),
      .cts_pad_i (1'b1),
      .dtr_pad_o (),
      .dsr_pad_i (1'b1),
      .ri_pad_i  (1'b1),
      .dcd_pad_i (1'b1)
    );
  end
endgenerate

//------------------------------------------------------------------------------
//  Output
assign  wb_ack = wb_reg_ack|(|wb_i2c_ack)|(|wb_spi_ack)|(|wb_uart_ack);

integer index, jndex;
always @(*) begin
  wb_dat_slave = wb_reg_ack? wb_reg_dat : 8'b0;
  for(index = 0; index < I2C_NUM; index = index+1) begin
    for(jndex = 0; jndex < 8; jndex = jndex+1)
      wb_dat_slave[jndex] = wb_dat_slave[jndex] | wb_i2c_ack[index] & wb_i2c_dat[8*index+jndex];
  end
  for(index = 0; index < SPI_NUM; index = index+1) begin
    for(jndex = 0; jndex < 8; jndex = jndex+1)
      wb_dat_slave[jndex] = wb_dat_slave[jndex] | wb_spi_ack[index] & wb_spi_dat[8*index+jndex];
  end
  for(index = 0; index < UART_NUM; index = index+1) begin
    for(jndex = 0; jndex < 8; jndex = jndex+1)
      wb_dat_slave[jndex] = wb_dat_slave[jndex] | wb_uart_ack[index] & wb_uart_dat[8*index+jndex];
  end
end

// integer index;
// always @(*) begin
//   wb_dat_slave = 0;
//   for(index = 0; index < I2C_NUM; index = index+1) begin
//     wb_dat_slave[7:0] = wb_dat_slave[7:0] | {8{wb_i2c_ack[index]}} & wb_i2c_dat[8*index+7:8*index];
//   end
//   for(index = 0; index < SPI_NUM; index = index+1) begin
//     wb_dat_slave[7:0] = wb_dat_slave[7:0] | {8{wb_spi_ack[index]}} & wb_spi_dat[8*index+7:8*index];
//   end
//   for(index = 0; index < UART_NUM; index = index+1) begin
//     wb_dat_slave[7:0] = wb_dat_slave[7:0] | {8{wb_uart_ack[index]}} & wb_uart_dat[8*index+7:8*index];
//   end
// end

//------------------------------------------------------------------------------

generate
if (USE_CHIPSCOPE == 1) begin
  wire [63:0] probe0;
  ila64 ila64_1 (
      .clk(CLK),
      .probe0(probe0)
  );
  assign probe0[15:0] = wb_adr[15:0];
  assign probe0[23:16] = wb_dat_slave;
  assign probe0[31:24] = wb_dat_master;
  assign probe0[32] = wb_we;
  assign probe0[33] = wb_stb;
  assign probe0[34] = wb_cyc;
  assign probe0[35] = wb_ack;

  assign probe0[63:36] = 0;

end
endgenerate

endmodule
