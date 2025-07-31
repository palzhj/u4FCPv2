`timescale 1ps/1ps
/*******************************************************************************
* System      : uRTM GbE readout                                           *
* Version     : v 1.0 2023/09/30                                               *
*                                                                              *
* Description : Top Module                                                     *
*                                                                              *
* Designer    : zhj@ihep.ac.cn                                                 *
*                                                                              *
*******************************************************************************/
module top #(
  parameter         USE_CHIPSCOPE = 1,
  parameter [31:0]  SYN_DATE      = 32'h0, // the date of compiling
  parameter [7:0]   FPGA_VER      = 8'h1,         // the code version
  parameter [31:0]  BASE_IP_ADDR  = 32'hC0A8_0A10, // 192.168.10.16
  parameter [4 :0]  PHY_ADDRESS   = 5'b0,
  parameter [3 :0]  I2C_NUM       = 1,
  parameter [3 :0]  SPI_NUM       = 1,
  parameter [3 :0]  UART_NUM      = 1
)(
  input             RST_B,
  input             CLK_IN_200_P,
  input             CLK_IN_200_N,
  input             CLK_IN_PL_P,
  input             CLK_IN_PL_N,
  input             CLK_IN_SW_P,
  input             CLK_IN_SW_N,
  output            CLK_OUT_P,
  output            CLK_OUT_N,
// I/O
  input   [7 : 0]   DIPSW,
  output  [3 : 0]   TESTPIN,        // Test Pin
  output            RLED_B,
  output            GLED_B,
  output            BLED_B,
  input             LEMO_IN_P,
  input             LEMO_IN_N,
  output            MMCX_TEST_P,
  output            MMCX_TEST_N,
  inout             FPGA_SCL,
  inout             FPGA_SDA,
  output            UART_TX,
  input             UART_RX,
// FAN
  input             FANFAIL_B,
  input             OT_B,
// GbE PHY - RGMII
  input             PHY_CLK,
  output            PHY_TX_CLK,
  output            PHY_TX_CTRL,
  output  [3 : 0]   PHY_TX_D,
  input             PHY_RX_CLK,
  input             PHY_RX_CTRL,
  input   [3 : 0]   PHY_RX_D,
  inout   [1 : 0]   PHY_GPIO,
  output            PHY_PWDN_B,
  output            PHY_RST_B,
  inout             PHY_MDC,
  inout             PHY_MDIO,
// FMC2
  input             FMC2_PRSNT_B,

  input             FMC2_CLK1_IN_P,
  input             FMC2_CLK1_IN_N,
  output            FMC2_CLK_DIR,  // High: Output
  input             FMC2_CLK3_IN_P,
  input             FMC2_CLK3_IN_N,
  output            FMC2_CLK3_OUT_P,
  output            FMC2_CLK3_OUT_N,

  output            FMC2_LA_P0,
  input             FMC2_LA_N0,
  output            FMC2_LA_P1,
  input             FMC2_LA_N1,
  output            FMC2_LA_P2,
  input             FMC2_LA_N2,
  output            FMC2_LA_P3,
  input             FMC2_LA_N3,
  output            FMC2_LA_P4,
  input             FMC2_LA_N4,
  output            FMC2_LA_P5,
  input             FMC2_LA_N5,
  output            FMC2_LA_P6,
  input             FMC2_LA_N6,
  output            FMC2_LA_P7,
  input             FMC2_LA_N7,
  output            FMC2_LA_P8,
  input             FMC2_LA_N8,
  output            FMC2_LA_P9,
  input             FMC2_LA_N9,
  output            FMC2_LA_P10,
  input             FMC2_LA_N10,
  output            FMC2_LA_P11,
  input             FMC2_LA_N11,
  output            FMC2_LA_P12,
  input             FMC2_LA_N12,
  output            FMC2_LA_P13,
  input             FMC2_LA_N13,
  output            FMC2_LA_P14,
  input             FMC2_LA_N14,
  output            FMC2_LA_P15,
  input             FMC2_LA_N15,
  output            FMC2_LA_P16,
  input             FMC2_LA_N16,

  output            FMC2_LA_P17,
  input             FMC2_LA_N17,
  output            FMC2_LA_P18,
  input             FMC2_LA_N18,
  output            FMC2_LA_P19,
  input             FMC2_LA_N19,
  output            FMC2_LA_P20,
  input             FMC2_LA_N20,
  output            FMC2_LA_P21,
  input             FMC2_LA_N21,
  output            FMC2_LA_P22,
  input             FMC2_LA_N22,
  output            FMC2_LA_P23,
  input             FMC2_LA_N23,
  output            FMC2_LA_P24,
  input             FMC2_LA_N24,
  output            FMC2_LA_P25,
  input             FMC2_LA_N25,
  output            FMC2_LA_P26,
  input             FMC2_LA_N26,
  output            FMC2_LA_P27,
  input             FMC2_LA_N27,
  output            FMC2_LA_P28,
  input             FMC2_LA_N28,
  output            FMC2_LA_P29,
  input             FMC2_LA_N29,
  output            FMC2_LA_P30,
  input             FMC2_LA_N30,
  output            FMC2_LA_P31,
  input             FMC2_LA_N31,
  output            FMC2_LA_P32,
  input             FMC2_LA_N32,
  output            FMC2_LA_P33,
  input             FMC2_LA_N33,

  output            FMC2_HB_P0,
  input             FMC2_HB_N0,
  output            FMC2_HB_P1,
  input             FMC2_HB_N1,
  output            FMC2_HB_P2,
  input             FMC2_HB_N2,
  output            FMC2_HB_P3,
  input             FMC2_HB_N3,
  output            FMC2_HB_P4,
  input             FMC2_HB_N4,
  input             FMC2_HB_P5,
  input             FMC2_HB_N5,

// FMC3
  input             FMC3_PRSNT_B,

  input             FMC3_CLK1_IN_P,
  input             FMC3_CLK1_IN_N,
  output            FMC3_CLK_DIR,  // High: Output
  input             FMC3_CLK3_IN_P,
  input             FMC3_CLK3_IN_N,
  output            FMC3_CLK3_OUT_P,
  output            FMC3_CLK3_OUT_N,

  output            FMC3_LA_P0,
  input             FMC3_LA_N0,
  output            FMC3_LA_P1,
  input             FMC3_LA_N1,
  output            FMC3_LA_P2,
  input             FMC3_LA_N2,
  output            FMC3_LA_P3,
  input             FMC3_LA_N3,
  output            FMC3_LA_P4,
  input             FMC3_LA_N4,
  output            FMC3_LA_P5,
  input             FMC3_LA_N5,
  output            FMC3_LA_P6,
  input             FMC3_LA_N6,
  output            FMC3_LA_P7,
  input             FMC3_LA_N7,
  output            FMC3_LA_P8,
  input             FMC3_LA_N8,
  output            FMC3_LA_P9,
  input             FMC3_LA_N9,
  output            FMC3_LA_P10,
  input             FMC3_LA_N10,
  output            FMC3_LA_P11,
  input             FMC3_LA_N11,
  output            FMC3_LA_P12,
  input             FMC3_LA_N12,
  output            FMC3_LA_P13,
  input             FMC3_LA_N13,
  output            FMC3_LA_P14,
  input             FMC3_LA_N14,
  output            FMC3_LA_P15,
  input             FMC3_LA_N15,
  output            FMC3_LA_P16,
  input             FMC3_LA_N16,

  output            FMC3_LA_P17,
  input             FMC3_LA_N17,
  output            FMC3_LA_P18,
  input             FMC3_LA_N18,
  output            FMC3_LA_P19,
  input             FMC3_LA_N19,
  output            FMC3_LA_P20,
  input             FMC3_LA_N20,
  output            FMC3_LA_P21,
  input             FMC3_LA_N21,
  output            FMC3_LA_P22,
  input             FMC3_LA_N22,
  output            FMC3_LA_P23,
  input             FMC3_LA_N23,
  output            FMC3_LA_P24,
  input             FMC3_LA_N24,
  output            FMC3_LA_P25,
  input             FMC3_LA_N25,
  output            FMC3_LA_P26,
  input             FMC3_LA_N26,
  output            FMC3_LA_P27,
  input             FMC3_LA_N27,
  output            FMC3_LA_P28,
  input             FMC3_LA_N28,
  output            FMC3_LA_P29,
  input             FMC3_LA_N29,
  output            FMC3_LA_P30,
  input             FMC3_LA_N30,
  output            FMC3_LA_P31,
  input             FMC3_LA_N31,
  output            FMC3_LA_P32,
  input             FMC3_LA_N32,
  output            FMC3_LA_P33,
  input             FMC3_LA_N33,

  output            FMC3_HA_P0,
  input             FMC3_HA_N0,
  output            FMC3_HA_P1,
  input             FMC3_HA_N1,
  output            FMC3_HA_P2,
  input             FMC3_HA_N2,
  output            FMC3_HA_P3,
  input             FMC3_HA_N3,
  output            FMC3_HA_P4,
  input             FMC3_HA_N4,
  output            FMC3_HA_P5,
  input             FMC3_HA_N5,
  output            FMC3_HA_P6,
  input             FMC3_HA_N6,
  output            FMC3_HA_P7,
  input             FMC3_HA_N7,
  output            FMC3_HA_P8,
  input             FMC3_HA_N8,
  output            FMC3_HA_P9,
  input             FMC3_HA_N9,
  output            FMC3_HA_P10,
  input             FMC3_HA_N10,
  output            FMC3_HA_P11,
  input             FMC3_HA_N11,
  output            FMC3_HA_P12,
  input             FMC3_HA_N12,
  output            FMC3_HA_P13,
  input             FMC3_HA_N13,
  output            FMC3_HA_P14,
  input             FMC3_HA_N14,
  output            FMC3_HA_P15,
  input             FMC3_HA_N15,
  output            FMC3_HA_P16,
  input             FMC3_HA_N16,
  output            FMC3_HA_P17,
  input             FMC3_HA_N17,
  output            FMC3_HA_P18,
  input             FMC3_HA_N18,
  output            FMC3_HA_P19,
  input             FMC3_HA_N19,
  output            FMC3_HA_P20,
  input             FMC3_HA_N20,
  output            FMC3_HA_P21,
  input             FMC3_HA_N21,
  output            FMC3_HA_P22,
  input             FMC3_HA_N22,
  output            FMC3_HA_P23,
  input             FMC3_HA_N23,

  output            FMC3_HB_P0,
  input             FMC3_HB_N0,
  output            FMC3_HB_P1,
  input             FMC3_HB_N1,
  output            FMC3_HB_P2,
  input             FMC3_HB_N2,
  output            FMC3_HB_P3,
  input             FMC3_HB_N3,
  output            FMC3_HB_P4,
  input             FMC3_HB_N4,
  output            FMC3_HB_P5,
  input             FMC3_HB_N5,

// DDR3L
  // output [1 : 0]   DDR3_CK_P,
  // output [1 : 0]   DDR3_CK_N,
  output [1 : 0]    DDR3_CKE,
  output [1 : 0]    DDR3_CS_N,
  output [1 : 0]    DDR3_ODT,
  output [15: 0]    DDR3_ADDR,
  output [2 : 0]    DDR3_BA,
  output            DDR3_RAS_N,
  output            DDR3_CAS_N,
  output            DDR3_WE_N,
  output            DDR3_RESET_N,
  input             DDR3_TEMP_EVENT,
  inout  [63: 0]    DDR3_DQ,
  inout  [7 : 0]    DDR3_DQS_P,
  inout  [7 : 0]    DDR3_DQS_N,

// FireFly
  // output [3 : 0]   TX117_P,
  // output [3 : 0]   TX117_N,
  // input  [3 : 0]   RX117_P,
  // input  [3 : 0]   RX117_N,
  // input            MGTCLK117_P0,
  // input            MGTCLK117_N0,
  // input            MGTCLK117_P1,
  // input            MGTCLK117_N1,
  output            MODPRSL117,
  output            MODSEL117,
  input             INTL117,
  output            RESETL117,

  // output [3 : 0]   TX118_P,
  // output [3 : 0]   TX118_N,
  // input  [3 : 0]   RX118_P,
  // input  [3 : 0]   RX118_N,
  // input            MGTCLK118_P0,
  // input            MGTCLK118_N0,
  // input            MGTCLK118_P1,
  // input            MGTCLK118_N1,
  output            MODPRSL118,
  output            MODSEL118,
  input             INTL118,
  output            RESETL118,

// MMCX
  // output [3 : 0]   TX116_P,
  // output [3 : 0]   TX116_N,
  // input  [3 : 0]   RX116_P,
  // input  [3 : 0]   RX116_N,
  // input            MGTCLK116_P0,
  // input            MGTCLK116_N0,
  // input            MGTCLK116_P1,
  // input            MGTCLK116_N1,

// RTM
  // output [19:16]   RTM2AMC_P,
  // output [19:16]   RTM2AMC_N,
  // input  [19:16]   AMC2RTM_P,
  // input  [19:16]   AMC2RTM_N,
  // input            MGTCLK115_P0,
  // input            MGTCLK115_N0,
  // input            MGTCLK115_P1,
  // input            MGTCLK115_N1,

  inout             RTM_IO0,
  inout             RTM_IO1,
  inout             RTM_IO2,
  inout             RTM_IO3,

  input             RTM_MODE,
  output            RTM_INTL
);

////////////////////////////////////////////////////////////////////////////////
//  Clock
wire clk200_in, clk200_int;
IBUFDS IBUFDS_clk200 (
  .O            (clk200_in),
  .I            (CLK_IN_200_P),
  .IB           (CLK_IN_200_N)
);
BUFG BUFG_200 (
  .O            (clk200_int),
  .I            (clk200_in)
);

wire clk40_int, clk100_int, clk125_int, locked;
clk_wiz clk_wiz(
  // Clock in ports
  .clk_in1      (clk200_int),
  // Clock out ports
  .clk_out1     (clk40_int),
  .clk_out2     (clk100_int),
  .clk_out3     (clk125_int),
  // Status and control signals
  .resetn       (RST_B),
  .locked       (locked)
);

////////////////////////////////////////////////////////////////////////////////
//  Clock PLL and SW
wire pll_clk_in, pll_clk_156;
IBUFDS #(
  .DIFF_TERM    ("FALSE")
) IBUFDS_pll_clk_156 (
  .O            (pll_clk_in),
  .I            (CLK_IN_PL_P),
  .IB           (CLK_IN_PL_N)
);
BUFG BUFG_156 (
  .O            (pll_clk_156),
  .I            (pll_clk_in)
);

wire sw_clk_in, sw_clk_125;
IBUFDS #(
  .DIFF_TERM    ("FALSE")
) IBUFDS_sw_clk_125 (
  .O            (sw_clk_in),
  .I            (CLK_IN_SW_P),
  .IB           (CLK_IN_SW_N)
);
BUFG BUFG_125 (
  .O            (sw_clk_125),
  .I            (sw_clk_in)
);

////////////////////////////////////////////////////////////////////////////////
//  Clock output
OBUFDS OBUFDS_clkout (
  .O            (CLK_OUT_P),    // 1-bit output: Diff_p output (connect directly to top-level port)
  .OB           (CLK_OUT_N),    // 1-bit output: Diff_n output (connect directly to top-level port)
  .I            (clk125_int)    // 1-bit input: Buffer input
);

// An IDELAYCTRL primitive needs to be instantiated for the Fixed Tap Delay
// mode of the IDELAY.
wire dlyctrl_rdy;
IDELAYCTRL dlyctrl (
  .RDY          (dlyctrl_rdy),
  .REFCLK       (clk200_int),
  .RST          (~RST_B)
);

////////////////////////////////////////////////////////////////////////////////
// System clock and reset
wire usrclk, rst;
assign usrclk = clk125_int;

async2sync_reset reset_usrclk(
  .rst_in       (~(locked & dlyctrl_rdy)),
  .clk          (usrclk),
  .rst_out      (rst)
);

////////////////////////////////////////////////////////////////////////////////
// SiTCP interface
wire            tim_1s;

wire            tcp_open;
wire            tcp_error;
wire            tcp_rst;
wire            tcp_close;

wire            tcp_rx_wr;
wire    [7 : 0] tcp_rx_data;
wire    [15: 0] tcp_rx_wc;

wire            tcp_tx_wr;
wire    [7 : 0] tcp_tx_data;
wire            tcp_tx_full;

wire    [31: 0] rbcp_addr;
wire            rbcp_we;
wire    [7 : 0] rbcp_wd;
wire            rbcp_re;
wire            rbcp_act;
wire            rbcp_ack;
wire    [7 : 0] rbcp_rd;

SITCP #(
  .USE_CHIPSCOPE(0),
  .BASE_IP_ADDR (BASE_IP_ADDR),
  .PHY_ADDRESS  (PHY_ADDRESS),
  .MAC_IP_WIDTH (0)
)sitcp(
  .RST          (rst),
  .USRCLK       (clk125_int),
  .CLKOUT       (),
  .MAC_SELECT   (0),
  .IP_SELECT    (0),
  .TIM_1US      (),         // out: 1 us interval
  .TIM_10US     (),
  .TIM_100US    (),
  .TIM_1MS      (),         // out: 1 ms interval
  .TIM_10MS     (),
  .TIM_100MS    (),
  .TIM_1S       (tim_1s),   // out: 1 s interval
  .TIM_1M       (),         // out: 1 min interval
  // TCP
  .TCP_OPEN     (tcp_open),
  .TCP_ERROR    (tcp_error),
  .TCP_RST      (tcp_rst),
  .TCP_CLOSE    (tcp_close),
  .TCP_RX_WC    (tcp_rx_wc[15:0]),
  .TCP_RX_WR    (tcp_rx_wr),
  .TCP_RX_DATA  (tcp_rx_data),
  .TCP_TX_FULL  (tcp_tx_full),
  .TCP_TX_WR    (tcp_tx_wr),
  .TCP_TX_DATA  (tcp_tx_data),
  // UDP
  .RBCP_ADDR    (rbcp_addr),
  .RBCP_WE      (rbcp_we),
  .RBCP_WD      (rbcp_wd),
  .RBCP_RE      (rbcp_re),
  .RBCP_ACT     (rbcp_act),
  .RBCP_ACK     (rbcp_ack),
  .RBCP_RD      (rbcp_rd),
  // PHY
  .PHY_RSTn     (PHY_RST_B),
  .RGMII_TXC    (PHY_TX_CLK),
  .RGMII_TXD    (PHY_TX_D),
  .RGMII_TX_CTL (PHY_TX_CTRL),
  .RGMII_RXC    (PHY_RX_CLK),
  .RGMII_RXD    (PHY_RX_D),
  .RGMII_RX_CTL (PHY_RX_CTRL),
  .MDC          (PHY_MDC),
  .MDIO         (PHY_MDIO)
);

assign PHY_PWDN_B = 1'b1;
assign PHY_GPIO = 2'bzz;

////////////////////////////////////////////////////////////////////////////////
//  TCP loopback FIFO
wire sitcpFifoEmpty, sitcpFifoRe;
assign tcp_rx_wc[15:11] = 5'b11111;

sitcp_fifo sitcp_fifo(
  .clk          (clk125_int),
  .srst         (~tcp_open),
  .data_count   (tcp_rx_wc[10:0]),
  .full         (),
  .wr_en        (tcp_rx_wr),
  .din          (tcp_rx_data[7:0]),
  .empty        (sitcpFifoEmpty),
  .rd_en        (sitcpFifoRe),
  .dout         (tcp_tx_data[7:0]),
  .valid        (tcp_tx_wr)
);

assign  sitcpFifoRe = ~tcp_tx_full & ~sitcpFifoEmpty;

////////////////////////////////////////////////////////////////////////////////
//  Register controll

wire [I2C_NUM-1: 0] scl_i, sda_i, scl_o, sda_o, scl_oen, sda_oen;

RBCP_REG #(
  .USE_CHIPSCOPE(0),
  .SYN_DATE     (SYN_DATE),
  .FPGA_VER     (FPGA_VER),
  .I2C_NUM      (I2C_NUM),
  .SPI_NUM      (SPI_NUM),
  .UART_NUM     (UART_NUM)
)RBCP_REG(
  // System
  .CLK          (clk125_int),     // in : System clock
  .RST          (tcp_rst),        // in : System reset
  // RBCP I/F
  .RBCP_ACT     (rbcp_act),       // in : Active
  .RBCP_ADDR    (rbcp_addr),      // in : Address[31:0]
  .RBCP_WE      (rbcp_we),        // in : Write enable
  .RBCP_WD      (rbcp_wd),        // in : Write data[7:0]
  .RBCP_RE      (rbcp_re),        // in : Read enable
  .RBCP_RD      (rbcp_rd),        // out  : Read data[7:0]
  .RBCP_ACK     (rbcp_ack),       // out  : Acknowledge
  // User IO
  .VP_IN        (FMC2_HB_P5),
  .VN_IN        (FMC2_HB_N5),
  .SCL          (scl_i),
  .SCL_OEN      (scl_oen),
  .SCL_O        (scl_o),
  .SDA          (sda_i),
  .SDA_OEN      (sda_oen),
  .SDA_O        (sda_o),
  .SCK          (),
  .MOSI_O       (),
  .MISO_I       (1'b0),
  .UART_RX      (UART_RX),
  .UART_TX      (UART_TX)
);

assign scl_i[0] = FPGA_SCL;
assign FPGA_SCL = scl_oen[0] ? 1'bz: scl_o[0];

assign sda_i[0] = FPGA_SDA;
assign FPGA_SDA = sda_oen[0] ? 1'bz: sda_o[0];

///////////////////////////////////////////////////////////////////////////////
// FMC test

reg [23:0] cnt;
always @(posedge clk125_int)
  if(rst) cnt = 0;
  else cnt <= cnt + 1'b1;

wire temp = cnt[2];

assign FMC2_LA_P0 = temp;
assign FMC2_LA_P1 = temp;
assign FMC2_LA_P2 = temp;
assign FMC2_LA_P3 = temp;
assign FMC2_LA_P4 = temp;
assign FMC2_LA_P5 = temp;
assign FMC2_LA_P6 = temp;
assign FMC2_LA_P7 = temp;
assign FMC2_LA_P8 = temp;
assign FMC2_LA_P9 = temp;
assign FMC2_LA_P10 = temp;
assign FMC2_LA_P11 = temp;
assign FMC2_LA_P12 = temp;
assign FMC2_LA_P13 = temp;
assign FMC2_LA_P14 = temp;
assign FMC2_LA_P15 = temp;
assign FMC2_LA_P16 = temp;

assign FMC2_LA_P17 = temp;
assign FMC2_LA_P18 = temp;
assign FMC2_LA_P19 = temp;
assign FMC2_LA_P20 = temp;
assign FMC2_LA_P21 = temp;
assign FMC2_LA_P22 = temp;
assign FMC2_LA_P23 = temp;
assign FMC2_LA_P24 = temp;
assign FMC2_LA_P25 = temp;
assign FMC2_LA_P26 = temp;
assign FMC2_LA_P27 = temp;
assign FMC2_LA_P28 = temp;
assign FMC2_LA_P29 = temp;
assign FMC2_LA_P30 = temp;
assign FMC2_LA_P31 = temp;
assign FMC2_LA_P32 = temp;
assign FMC2_LA_P33 = temp;

assign FMC2_HB_P0 = temp;
assign FMC2_HB_P1 = temp;
assign FMC2_HB_P2 = temp;
assign FMC2_HB_P3 = temp;
assign FMC2_HB_P4 = temp;
// assign FMC2_HB_P5 = temp;

assign FMC3_LA_P0 = temp;
assign FMC3_LA_P1 = temp;
assign FMC3_LA_P2 = temp;
assign FMC3_LA_P3 = temp;
assign FMC3_LA_P4 = temp;
assign FMC3_LA_P5 = temp;
assign FMC3_LA_P6 = temp;
assign FMC3_LA_P7 = temp;
assign FMC3_LA_P8 = temp;
assign FMC3_LA_P9 = temp;
assign FMC3_LA_P10 = temp;
assign FMC3_LA_P11 = temp;
assign FMC3_LA_P12 = temp;
assign FMC3_LA_P13 = temp;
assign FMC3_LA_P14 = temp;
assign FMC3_LA_P15 = temp;
assign FMC3_LA_P16 = temp;

assign FMC3_LA_P17 = temp;
assign FMC3_LA_P18 = temp;
assign FMC3_LA_P19 = temp;
assign FMC3_LA_P20 = temp;
assign FMC3_LA_P21 = temp;
assign FMC3_LA_P22 = temp;
assign FMC3_LA_P23 = temp;
assign FMC3_LA_P24 = temp;
assign FMC3_LA_P25 = temp;
assign FMC3_LA_P26 = temp;
assign FMC3_LA_P27 = temp;
assign FMC3_LA_P28 = temp;
assign FMC3_LA_P29 = temp;
assign FMC3_LA_P30 = temp;
assign FMC3_LA_P31 = temp;
assign FMC3_LA_P32 = temp;
assign FMC3_LA_P33 = temp;

assign FMC3_HA_P0 = temp;
assign FMC3_HA_P1 = temp;
assign FMC3_HA_P2 = temp;
assign FMC3_HA_P3 = temp;
assign FMC3_HA_P4 = temp;
assign FMC3_HA_P5 = temp;
assign FMC3_HA_P6 = temp;
assign FMC3_HA_P7 = temp;
assign FMC3_HA_P8 = temp;
assign FMC3_HA_P9 = temp;
assign FMC3_HA_P10 = temp;
assign FMC3_HA_P11 = temp;
assign FMC3_HA_P12 = temp;
assign FMC3_HA_P13 = temp;
assign FMC3_HA_P14 = temp;
assign FMC3_HA_P15 = temp;
assign FMC3_HA_P16 = temp;

assign FMC3_HA_P17 = temp;
assign FMC3_HA_P18 = temp;
assign FMC3_HA_P19 = temp;
assign FMC3_HA_P20 = temp;
assign FMC3_HA_P21 = temp;
assign FMC3_HA_P22 = temp;
assign FMC3_HA_P23 = temp;

assign FMC3_HB_P0 = temp;
assign FMC3_HB_P1 = temp;
assign FMC3_HB_P2 = temp;
assign FMC3_HB_P3 = temp;
assign FMC3_HB_P4 = temp;
assign FMC3_HB_P5 = temp;

assign FMC2_CLK_DIR = 1'b1;
assign FMC3_CLK_DIR = 1'b1;

IBUFDS #(
  .DIFF_TERM("FALSE")
)ibuf_fmc2_clk_m2c_1(
  .I  (FMC2_CLK1_IN_P),
  .IB (FMC2_CLK1_IN_N),
  .O  (fmc2_clk_m2c_1)
);

IBUFDS #(
  .DIFF_TERM("FALSE")
)ibuf_fmc2_clk_m2c_3(
  .I  (FMC2_CLK3_IN_P),
  .IB (FMC2_CLK3_IN_N),
  .O  (fmc2_clk_m2c_3)
);

OBUFDS OBUFDS_fmc2_clk_c2m (
  .O  (FMC2_CLK3_OUT_P),     // Diff_p output (connect directly to top-level port)
  .OB (FMC2_CLK3_OUT_N),   // Diff_n output (connect directly to top-level port)
  .I  (clk40_int)      // Buffer input
);

IBUFDS #(
  .DIFF_TERM("FALSE")
)ibuf_fmc3_clk_m2c_1(
  .I  (FMC3_CLK1_IN_P),
  .IB (FMC3_CLK1_IN_N),
  .O  (fmc3_clk_m2c_1)
);

IBUFDS #(
  .DIFF_TERM("FALSE")
)ibuf_fmc3_clk_m2c_3(
  .I  (FMC3_CLK3_IN_P),
  .IB (FMC3_CLK3_IN_N),
  .O  (fmc3_clk_m2c_3)
);

OBUFDS OBUFDS_fmc3_clk_c2m (
  .O  (FMC3_CLK3_OUT_P),     // Diff_p output (connect directly to top-level port)
  .OB (FMC3_CLK3_OUT_N),   // Diff_n output (connect directly to top-level port)
  .I  (clk40_int)      // Buffer input
);

//////////////////////////////////////////////////////////////////////////////
// Test
IBUFDS #(
  .DIFF_TERM("FALSE")
)ibuf_lemo_in(
  .I  (LEMO_IN_P),
  .IB (LEMO_IN_N),
  .O  (lemo_in)
);

assign MMCX_TEST_P = temp;
assign MMCX_TEST_N = ~temp;

assign TESTPIN[3:0] = {4{temp}};

//////////////////////////////////////////////////////////////////////////////
// Debug
reg ledr;
always @(posedge clk125_int)
  if(tim_1s) ledr <= ~ledr;

assign BLED_B = ledr;

reg [26:0] ledg;
always @(posedge pll_clk_156)
  ledg <= ledg + 1'b1;

assign GLED_B = ledg[26];

reg [26:0] ledb;
always @(posedge sw_clk_125)
  ledb <= ledb + 1'b1;

assign RLED_B = ledb[26];

//////////////////////////////////////////////////////////////////////////////
// Monitor
wire [63:0] probe0;
ila64 ila64_0 (
  .clk(clk125_int),
  .probe0(probe0)
);
// FMC 2
assign probe0[0] = FMC2_LA_N0;
assign probe0[1] = FMC2_LA_N1;
assign probe0[2] = FMC2_LA_N2;
assign probe0[3] = FMC2_LA_N3;
assign probe0[4] = FMC2_LA_N4;
assign probe0[5] = FMC2_LA_N5;
assign probe0[6] = FMC2_LA_N6;
assign probe0[7] = FMC2_LA_N7;
assign probe0[8] = FMC2_LA_N8;
assign probe0[9] = FMC2_LA_N9;
assign probe0[10] = FMC2_LA_N10;
assign probe0[11] = FMC2_LA_N11;
assign probe0[12] = FMC2_LA_N12;
assign probe0[13] = FMC2_LA_N13;
assign probe0[14] = FMC2_LA_N14;
assign probe0[15] = FMC2_LA_N15;
assign probe0[16] = FMC2_LA_N16;
assign probe0[17] = FMC2_LA_N17;
assign probe0[18] = FMC2_LA_N18;
assign probe0[19] = FMC2_LA_N19;
assign probe0[20] = FMC2_LA_N20;
assign probe0[21] = FMC2_LA_N21;
assign probe0[22] = FMC2_LA_N22;
assign probe0[23] = FMC2_LA_N23;
assign probe0[24] = FMC2_LA_N24;
assign probe0[25] = FMC2_LA_N25;
assign probe0[26] = FMC2_LA_N26;
assign probe0[27] = FMC2_LA_N27;
assign probe0[28] = FMC2_LA_N28;
assign probe0[29] = FMC2_LA_N29;
assign probe0[30] = FMC2_LA_N30;
assign probe0[31] = FMC2_LA_N31;
assign probe0[32] = FMC2_LA_N32;
assign probe0[33] = FMC2_LA_N33;

assign probe0[34] = FMC2_HB_N0;
assign probe0[35] = FMC2_HB_N1;
assign probe0[36] = FMC2_HB_N2;
assign probe0[37] = FMC2_HB_N3;
assign probe0[38] = FMC2_HB_N4;
assign probe0[39] = 0;

assign probe0[40] = FMC2_PRSNT_B;
assign probe0[41] = FMC2_CLK_DIR;

assign probe0[42] = fmc2_clk_m2c_1;
assign probe0[43] = fmc2_clk_m2c_3;

assign probe0[63:44] = 0;

wire [63:0] probe1;
ila64 ila64_1 (
  .clk(clk125_int),
  .probe0(probe1)
);

// FMC 3
assign probe1[0] = FMC3_LA_N0;
assign probe1[1] = FMC3_LA_N1;
assign probe1[2] = FMC3_LA_N2;
assign probe1[3] = FMC3_LA_N3;
assign probe1[4] = FMC3_LA_N4;
assign probe1[5] = FMC3_LA_N5;
assign probe1[6] = FMC3_LA_N6;
assign probe1[7] = FMC3_LA_N7;
assign probe1[8] = FMC3_LA_N8;
assign probe1[9] = FMC3_LA_N9;
assign probe1[10] = FMC3_LA_N10;
assign probe1[11] = FMC3_LA_N11;
assign probe1[12] = FMC3_LA_N12;
assign probe1[13] = FMC3_LA_N13;
assign probe1[14] = FMC3_LA_N14;
assign probe1[15] = FMC3_LA_N15;
assign probe1[16] = FMC3_LA_N16;
assign probe1[17] = FMC3_LA_N17;
assign probe1[18] = FMC3_LA_N18;
assign probe1[19] = FMC3_LA_N19;
assign probe1[20] = FMC3_LA_N20;
assign probe1[21] = FMC3_LA_N21;
assign probe1[22] = FMC3_LA_N22;
assign probe1[23] = FMC3_LA_N23;
assign probe1[24] = FMC3_LA_N24;
assign probe1[25] = FMC3_LA_N25;
assign probe1[26] = FMC3_LA_N26;
assign probe1[27] = FMC3_LA_N27;
assign probe1[28] = FMC3_LA_N28;
assign probe1[29] = FMC3_LA_N29;
assign probe1[30] = FMC3_LA_N30;
assign probe1[31] = FMC3_LA_N31;
assign probe1[32] = FMC3_LA_N32;
assign probe1[33] = FMC3_LA_N33;

assign probe1[34] = FMC3_HB_N0;
assign probe1[35] = FMC3_HB_N1;
assign probe1[36] = FMC3_HB_N2;
assign probe1[37] = FMC3_HB_N3;
assign probe1[38] = FMC3_HB_N4;
assign probe1[39] = FMC3_HB_N5;

assign probe1[40] = FMC3_PRSNT_B;
assign probe1[41] = FMC3_CLK_DIR;

assign probe1[42] = fmc3_clk_m2c_1;
assign probe1[43] = fmc3_clk_m2c_3;

assign probe1[63:44] = 0;

// Test
wire [63:0] probe2;
ila64 ila64_2 (
  .clk(clk125_int),
  .probe0(probe2)
);

assign probe2[7:0] = DIPSW[7:0];
assign probe2[8] = RST_B;
assign probe2[9] = lemo_in;

assign probe2[10] = FMC3_HA_N0;
assign probe2[11] = FMC3_HA_N1;
assign probe2[12] = FMC3_HA_N2;
assign probe2[13] = FMC3_HA_N3;
assign probe2[14] = FMC3_HA_N4;
assign probe2[15] = FMC3_HA_N5;
assign probe2[16] = FMC3_HA_N6;
assign probe2[17] = FMC3_HA_N7;
assign probe2[18] = FMC3_HA_N8;
assign probe2[19] = FMC3_HA_N9;
assign probe2[20] = FMC3_HA_N10;
assign probe2[21] = FMC3_HA_N11;
assign probe2[22] = FMC3_HA_N12;
assign probe2[23] = FMC3_HA_N13;
assign probe2[24] = FMC3_HA_N14;
assign probe2[25] = FMC3_HA_N15;
assign probe2[26] = FMC3_HA_N16;
assign probe2[27] = FMC3_HA_N17;
assign probe2[28] = FMC3_HA_N18;
assign probe2[29] = FMC3_HA_N19;
assign probe2[30] = FMC3_HA_N20;
assign probe2[31] = FMC3_HA_N21;
assign probe2[32] = FMC3_HA_N22;
assign probe2[33] = FMC3_HA_N23;

assign probe2[63:34] = 0;

endmodule
