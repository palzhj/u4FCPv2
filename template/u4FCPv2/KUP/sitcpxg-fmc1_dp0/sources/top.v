`timescale 1ps/1ps
/*******************************************************************************
* System      : u4FCP 10 GbE readout                                           *
* Version     : v 1.1 2025/01/23                                               *
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
  parameter [4 :0]  PHY_ADDRESS   = 5'b1,
  parameter [3 :0]  I2C_NUM       = 1,
  parameter [3 :0]  SPI_NUM       = 1,
  parameter [3 :0]  UART_NUM      = 1
)(
  input             CLK_IN_200_P,
  input             CLK_IN_200_N,
  input             CLK_IN_PL_P,
  input             CLK_IN_PL_N,
  input             CLK_IN_SW_P,
  input             CLK_IN_SW_N,
  output            CLK_OUT_P,
  output            CLK_OUT_N,
// I/O
  input             RST_B,
  input             LEMO_IN_P,
  input             LEMO_IN_N,
  input             MMCX_TEST_P,
  input             MMCX_TEST_N,
  output  [3 : 0]   TESTPIN,        // Test Pin
  input   [7 : 0]   DIPSW,
  output            RLED_B,
  output            GLED_B,
  output            BLED_B,
// I2C
  inout             FPGA_SCL,
  inout             FPGA_SDA,
// UART
  output            UART_TX,
  input             UART_RX,
// DDR4 A
  // output            C0_DDR4_ACT_B,
  // output  [16: 0]   C0_DDR4_ADDR,
  // output  [1 : 0]   C0_DDR4_BA,
  // output  [1 : 0]   C0_DDR4_BG,
  // output  [1 : 0]   C0_DDR4_CKE,
  // output  [1 : 0]   C0_DDR4_ODT,
  // output  [1 : 0]   C0_DDR4_CS_B,
  // output  [1 : 0]   C0_DDR4_CK_T,
  // output  [1 : 0]   C0_DDR4_CK_C,
  // output            C0_DDR4_RESET_B,
  // inout   [7 : 0]   C0_DDR4_DM,
  // inout   [63: 0]   C0_DDR4_DQ,
  // inout   [7 : 0]   C0_DDR4_DQS_C,
  // inout   [7 : 0]   C0_DDR4_DQS_T,
// DDR4 B
  // output            C1_DDR4_ACT_B,
  // output  [16: 0]   C1_DDR4_ADDR,
  // output  [1 : 0]   C1_DDR4_BA,
  // output  [1 : 0]   C1_DDR4_BG,
  // output  [1 : 0]   C1_DDR4_CKE,
  // output  [1 : 0]   C1_DDR4_ODT,
  // output  [1 : 0]   C1_DDR4_CS_B,
  // output  [1 : 0]   C1_DDR4_CK_T,
  // output  [1 : 0]   C1_DDR4_CK_C,
  // output            C1_DDR4_RESET_B,
  // inout   [7 : 0]   C1_DDR4_DM,
  // inout   [63: 0]   C1_DDR4_DQ,
  // inout   [7 : 0]   C1_DDR4_DQS_C,
  // inout   [7 : 0]   C1_DDR4_DQS_T,
// FMC0
  input             FMC0_PRSNT_B,
  output            FMC0_CLK_DIR, // high for output
  input             FMC0_CLK_M2C_P1,
  input             FMC0_CLK_M2C_N1,
  input             FMC0_CLK_M2C_P3,
  input             FMC0_CLK_M2C_N3,
  output            FMC0_CLK_C2M_P3,
  output            FMC0_CLK_C2M_N3,
  input             FMC0_LA_P0,
  input             FMC0_LA_N0,
  input             FMC0_LA_P1,
  input             FMC0_LA_N1,
  input             FMC0_LA_P2,
  input             FMC0_LA_N2,
  input             FMC0_LA_P3,
  input             FMC0_LA_N3,
  input             FMC0_LA_P4,
  input             FMC0_LA_N4,
  input             FMC0_LA_P5,
  input             FMC0_LA_N5,
  input             FMC0_LA_P6,
  input             FMC0_LA_N6,
  input             FMC0_LA_P7,
  input             FMC0_LA_N7,
  input             FMC0_LA_P8,
  input             FMC0_LA_N8,
  input             FMC0_LA_P9,
  input             FMC0_LA_N9,
  input             FMC0_LA_P10,
  input             FMC0_LA_N10,
  input             FMC0_LA_P11,
  input             FMC0_LA_N11,
  input             FMC0_LA_P12,
  input             FMC0_LA_N12,
  input             FMC0_LA_P13,
  input             FMC0_LA_N13,
  input             FMC0_LA_P14,
  input             FMC0_LA_N14,
  input             FMC0_LA_P15,
  input             FMC0_LA_N15,
  input             FMC0_LA_P16,
  input             FMC0_LA_N16,

  input             FMC0_HB_P0,
  input             FMC0_HB_N0,
  input             FMC0_HB_P1,
  input             FMC0_HB_N1,
  input             FMC0_HB_P2,
  input             FMC0_HB_N2,
  input             FMC0_HB_P3,
  input             FMC0_HB_N3,
  input             FMC0_HB_P4,
  input             FMC0_HB_N4,
  input             FMC0_HB_P5,
  input             FMC0_HB_N5,
  input             FMC0_HB_P6,
  input             FMC0_HB_N6,
  input             FMC0_HB_P7,
  input             FMC0_HB_N7,

  // input             FMC0_DP_M2C_P0,
  // input             FMC0_DP_M2C_N0,
  // input             FMC0_DP_M2C_P1,
  // input             FMC0_DP_M2C_N1,
  // input             FMC0_DP_M2C_P2,
  // input             FMC0_DP_M2C_N2,
  // input             FMC0_DP_M2C_P3,
  // input             FMC0_DP_M2C_N3,
  // output            FMC0_DP_C2M_P0,
  // output            FMC0_DP_C2M_N0,
  // output            FMC0_DP_C2M_P1,
  // output            FMC0_DP_C2M_N1,
  // output            FMC0_DP_C2M_P2,
  // output            FMC0_DP_C2M_N2,
  // output            FMC0_DP_C2M_P3,
  // output            FMC0_DP_C2M_N3,
  // input             MGTCLK128_P0,
  // input             MGTCLK128_N0,
  // input             MGTCLK128_P1,
  // input             MGTCLK128_N1,

  // input             FMC0_DP_M2C_P4,
  // input             FMC0_DP_M2C_N4,
  // input             FMC0_DP_M2C_P5,
  // input             FMC0_DP_M2C_N5,
  // input             FMC0_DP_M2C_P6,
  // input             FMC0_DP_M2C_N6,
  // input             FMC0_DP_M2C_P7,
  // input             FMC0_DP_M2C_N7,
  // output            FMC0_DP_C2M_P4,
  // output            FMC0_DP_C2M_N4,
  // output            FMC0_DP_C2M_P5,
  // output            FMC0_DP_C2M_N5,
  // output            FMC0_DP_C2M_P6,
  // output            FMC0_DP_C2M_N6,
  // output            FMC0_DP_C2M_P7,
  // output            FMC0_DP_C2M_N7,
  // input             MGTCLK127_P0,
  // input             MGTCLK127_N0,
  // input             MGTCLK127_P1,
  // input             MGTCLK127_N1,

// FMC1
  input             FMC1_PRSNT_B,
  output            FMC1_CLK_DIR, // high for output
  input             FMC1_CLK_M2C_P1,
  input             FMC1_CLK_M2C_N1,
  input             FMC1_CLK_M2C_P3,
  input             FMC1_CLK_M2C_N3,
  output            FMC1_CLK_C2M_P3,
  output            FMC1_CLK_C2M_N3,
  input             FMC1_LA_P0,
  input             FMC1_LA_N0,
  input             FMC1_LA_P1,
  input             FMC1_LA_N1,
  input             FMC1_LA_P2,
  input             FMC1_LA_N2,
  input             FMC1_LA_P3,
  input             FMC1_LA_N3,
  input             FMC1_LA_P4,
  input             FMC1_LA_N4,
  input             FMC1_LA_P5,
  input             FMC1_LA_N5,
  input             FMC1_LA_P6,
  input             FMC1_LA_N6,
  input             FMC1_LA_P7,
  input             FMC1_LA_N7,
  input             FMC1_LA_P8,
  input             FMC1_LA_N8,
  input             FMC1_LA_P9,
  input             FMC1_LA_N9,
  input             FMC1_LA_P10,
  input             FMC1_LA_N10,
  input             FMC1_LA_P11,
  input             FMC1_LA_N11,
  input             FMC1_LA_P12,
  input             FMC1_LA_N12,
  input             FMC1_LA_P13,
  input             FMC1_LA_N13,
  input             FMC1_LA_P14,
  input             FMC1_LA_N14,
  input             FMC1_LA_P15,
  input             FMC1_LA_N15,
  input             FMC1_LA_P16,
  input             FMC1_LA_N16,

  input             FMC1_HB_P0,
  input             FMC1_HB_N0,
  input             FMC1_HB_P1,
  input             FMC1_HB_N1,
  input             FMC1_HB_P2,
  input             FMC1_HB_N2,
  input             FMC1_HB_P3,
  input             FMC1_HB_N3,
  input             FMC1_HB_P4,
  input             FMC1_HB_N4,
  input             FMC1_HB_P5,
  input             FMC1_HB_N5,
  input             FMC1_HB_P6,
  input             FMC1_HB_N6,
  input             FMC1_HB_P7,
  input             FMC1_HB_N7,

  input             FMC1_DP_M2C_P0,
  input             FMC1_DP_M2C_N0,
  // input             FMC1_DP_M2C_P1,
  // input             FMC1_DP_M2C_N1,
  // input             FMC1_DP_M2C_P2,
  // input             FMC1_DP_M2C_N2,
  // input             FMC1_DP_M2C_P3,
  // input             FMC1_DP_M2C_N3,
  output            FMC1_DP_C2M_P0,
  output            FMC1_DP_C2M_N0,
  // output            FMC1_DP_C2M_P1,
  // output            FMC1_DP_C2M_N1,
  // output            FMC1_DP_C2M_P2,
  // output            FMC1_DP_C2M_N2,
  // output            FMC1_DP_C2M_P3,
  // output            FMC1_DP_C2M_N3,
  input             MGTCLK130_P0,
  input             MGTCLK130_N0,
  // input             MGTCLK130_P1,
  // input             MGTCLK130_N1,

  // input             FMC1_DP_M2C_P4,
  // input             FMC1_DP_M2C_N4,
  // input             FMC1_DP_M2C_P5,
  // input             FMC1_DP_M2C_N5,
  // input             FMC1_DP_M2C_P6,
  // input             FMC1_DP_M2C_N6,
  // input             FMC1_DP_M2C_P7,
  // input             FMC1_DP_M2C_N7,
  // output            FMC1_DP_C2M_P4,
  // output            FMC1_DP_C2M_N4,
  // output            FMC1_DP_C2M_P5,
  // output            FMC1_DP_C2M_N5,
  // output            FMC1_DP_C2M_P6,
  // output            FMC1_DP_C2M_N6,
  // output            FMC1_DP_C2M_P7,
  // output            FMC1_DP_C2M_N7,
  // input             MGTCLK129_P0,
  // input             MGTCLK129_N0,
  // input             MGTCLK129_P1,
  // input             MGTCLK129_N1,

// Firefly
  // output            FIREFLY_MODSEL,   // pulled low when I2C are used
  // input             FIREFLY_MODPRSL,  // low to indicate present
  // input             FIREFLY_INTL,     // low to indicate a fault condition
  // output            FIREFLY_RESETL,   // pulled low for more than 200 us when reset

  // input             FIREFLY_M2C_P0,
  // input             FIREFLY_M2C_N0,
  // input             FIREFLY_M2C_P1,
  // input             FIREFLY_M2C_N1,
  // input             FIREFLY_M2C_P2,
  // input             FIREFLY_M2C_N2,
  // input             FIREFLY_M2C_P3,
  // input             FIREFLY_M2C_N3,
  // output            FIREFLY_C2M_P0,
  // output            FIREFLY_C2M_N0,
  // output            FIREFLY_C2M_P1,
  // output            FIREFLY_C2M_N1,
  // output            FIREFLY_C2M_P2,
  // output            FIREFLY_C2M_N2,
  // output            FIREFLY_C2M_P3,
  // output            FIREFLY_C2M_N3,
  // input             MGTCLK132_P0,
  // input             MGTCLK132_N0,

// AMC
  input             AMC_MODE,
  // output            AMC_TX_P0,
  // output            AMC_TX_N0,
  // output            AMC_TX_P1,
  // output            AMC_TX_N1,
  // output            AMC_TX_P2,
  // output            AMC_TX_N2,
  // output            AMC_TX_P3,
  // output            AMC_TX_N3,
  // input             AMC_RX_P0,
  // input             AMC_RX_N0,
  // input             AMC_RX_P1,
  // input             AMC_RX_N1,
  // input             AMC_RX_P2,
  // input             AMC_RX_N2,
  // input             AMC_RX_P3,
  // input             AMC_RX_N3,
  // input             MGTCLK231_P0,
  // input             MGTCLK231_N0,
  // input             MGTCLK231_P1,
  // input             MGTCLK231_N1,

  // output            AMC_TX_P4,
  // output            AMC_TX_N4,
  // output            AMC_TX_P5,
  // output            AMC_TX_N5,
  // output            AMC_TX_P6,
  // output            AMC_TX_N6,
  // output            AMC_TX_P7,
  // output            AMC_TX_N7,
  // input             AMC_RX_P4,
  // input             AMC_RX_N4,
  // input             AMC_RX_P5,
  // input             AMC_RX_N5,
  // input             AMC_RX_P6,
  // input             AMC_RX_N6,
  // input             AMC_RX_P7,
  // input             AMC_RX_N7,
  // input             MGTCLK229_P0,
  // input             MGTCLK229_N0,

  // output            AMC_TX_P8,
  // output            AMC_TX_N8,
  // output            AMC_TX_P9,
  // output            AMC_TX_N9,
  // output            AMC_TX_P10,
  // output            AMC_TX_N10,
  // output            AMC_TX_P11,
  // output            AMC_TX_N11,
  // input             AMC_RX_P8,
  // input             AMC_RX_N8,
  // input             AMC_RX_P9,
  // input             AMC_RX_N9,
  // input             AMC_RX_P10,
  // input             AMC_RX_N10,
  // input             AMC_RX_P11,
  // input             AMC_RX_N11,
  // input             MGTCLK228_P0,
  // input             MGTCLK228_N0,

  // output            AMC_TX_P12,
  // output            AMC_TX_N12,
  // output            AMC_TX_P13,
  // output            AMC_TX_N13,
  // output            AMC_TX_P14,
  // output            AMC_TX_N14,
  // output            AMC_TX_P15,
  // output            AMC_TX_N15,
  // input             AMC_RX_P12,
  // input             AMC_RX_N12,
  // input             AMC_RX_P13,
  // input             AMC_RX_N13,
  // input             AMC_RX_P14,
  // input             AMC_RX_N14,
  // input             AMC_RX_P15,
  // input             AMC_RX_N15,
  // input             MGTCLK230_P0,
  // input             MGTCLK230_N0,

  // output            AMC_TX17,
  // output            AMC_TX18,
  // output            AMC_TX19,
  // output            AMC_TX20,
  // output            AMC_TX_DE17,
  // output            AMC_TX_DE18,
  // output            AMC_TX_DE19,
  // output            AMC_TX_DE20,
  // input             AMC_RX17,
  // input             AMC_RX18,
  // input             AMC_RX19,
  // input             AMC_RX20,
  // output            AMC_RX_DE17,
  // output            AMC_RX_DE18,
  // output            AMC_RX_DE19,
  // output            AMC_RX_DE20,

// RTM
  // input             RTM_PS_B,
  // input             RTM_IO0,
  // input             RTM_IO1,
  // input             RTM_IO2,
  // input             RTM_IO3,

  // output            AMC2RTM_P0,
  // output            AMC2RTM_N0,
  // output            AMC2RTM_P1,
  // output            AMC2RTM_N1,
  // output            AMC2RTM_P2,
  // output            AMC2RTM_N2,
  // output            AMC2RTM_P3,
  // output            AMC2RTM_N3,
  // input             RTM2AMC_P0,
  // input             RTM2AMC_N0,
  // input             RTM2AMC_P1,
  // input             RTM2AMC_N1,
  // input             RTM2AMC_P2,
  // input             RTM2AMC_N2,
  // input             RTM2AMC_P3,
  // input             RTM2AMC_N3,
  // input             MGTCLK227_P0,
  // input             MGTCLK227_N0,
  // input             MGTCLK227_P1,
  // input             MGTCLK227_N1,

  // output            AMC2RTM_P4,
  // output            AMC2RTM_N4,
  // output            AMC2RTM_P5,
  // output            AMC2RTM_N5,
  // output            AMC2RTM_P6,
  // output            AMC2RTM_N6,
  // output            AMC2RTM_P7,
  // output            AMC2RTM_N7,
  // input             RTM2AMC_P4,
  // input             RTM2AMC_N4,
  // input             RTM2AMC_P5,
  // input             RTM2AMC_N5,
  // input             RTM2AMC_P6,
  // input             RTM2AMC_N6,
  // input             RTM2AMC_P7,
  // input             RTM2AMC_N7,
  // input             MGTCLK226_P0,
  // input             MGTCLK226_N0,
  // input             MGTCLK226_P1,
  // input             MGTCLK226_N1,

  // output            AMC2RTM_P8,
  // output            AMC2RTM_N8,
  // output            AMC2RTM_P9,
  // output            AMC2RTM_N9,
  // output            AMC2RTM_P10,
  // output            AMC2RTM_N10,
  // output            AMC2RTM_P11,
  // output            AMC2RTM_N11,
  // input             RTM2AMC_P8,
  // input             RTM2AMC_N8,
  // input             RTM2AMC_P9,
  // input             RTM2AMC_N9,
  // input             RTM2AMC_P10,
  // input             RTM2AMC_N10,
  // input             RTM2AMC_P11,
  // input             RTM2AMC_N11,
  // input             MGTCLK225_P0,
  // input             MGTCLK225_N0,
  // input             MGTCLK225_P1,
  // input             MGTCLK225_N1,

  // output            AMC2RTM_P12,
  // output            AMC2RTM_N12,
  // output            AMC2RTM_P13,
  // output            AMC2RTM_N13,
  // output            AMC2RTM_P14,
  // output            AMC2RTM_N14,
  // output            AMC2RTM_P15,
  // output            AMC2RTM_N15,
  // input             RTM2AMC_P12,
  // input             RTM2AMC_N12,
  // input             RTM2AMC_P13,
  // input             RTM2AMC_N13,
  // input             RTM2AMC_P14,
  // input             RTM2AMC_N14,
  // input             RTM2AMC_P15,
  // input             RTM2AMC_N15,
  // input             MGTCLK224_P0,
  // input             MGTCLK224_N0,
  // input             MGTCLK224_P1,
  // input             MGTCLK224_N1,

  // output            AMC2RTM_P16,
  // output            AMC2RTM_N16,
  // output            AMC2RTM_P17,
  // output            AMC2RTM_N17,
  // output            AMC2RTM_P18,
  // output            AMC2RTM_N18,
  // output            AMC2RTM_P19,
  // output            AMC2RTM_N19,
  // input             RTM2AMC_P16,
  // input             RTM2AMC_N16,
  // input             RTM2AMC_P17,
  // input             RTM2AMC_N17,
  // input             RTM2AMC_P18,
  // input             RTM2AMC_N18,
  // input             RTM2AMC_P19,
  // input             RTM2AMC_N19,
  // input             MGTCLK131_P0,
  // input             MGTCLK131_N0,

  output            TP24
);

localparam DEBUG_SITCPXG  = 1;
localparam DEBUG_RBCP_REG = 1;

////////////////////////////////////////////////////////////////////////////////
//  Clock
wire clk200_in, clk200_int;
IBUFDS #(
  .DIFF_TERM    ("FALSE")
) IBUFDS_clk200 (
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

OBUFDS OBUFDS_clkout (
  .O            (CLK_OUT_P),    // 1-bit output: Diff_p output (connect directly to top-level port)
  .OB           (CLK_OUT_N),    // 1-bit output: Diff_n output (connect directly to top-level port)
  .I            (clk125_int)    // 1-bit input: Buffer input
);

OBUFDS OBUFDS_fmc0_clkout3 (
  .O            (FMC0_CLK_C2M_P3),    // 1-bit output: Diff_p output (connect directly to top-level port)
  .OB           (FMC0_CLK_C2M_N3),    // 1-bit output: Diff_n output (connect directly to top-level port)
  .I            (0)    // 1-bit input: Buffer input
);

OBUFDS OBUFDS_fmc1_clkout3 (
  .O            (FMC1_CLK_C2M_P3),    // 1-bit output: Diff_p output (connect directly to top-level port)
  .OB           (FMC1_CLK_C2M_N3),    // 1-bit output: Diff_n output (connect directly to top-level port)
  .I            (0)    // 1-bit input: Buffer input
);

// An IDELAYCTRL primitive needs to be instantiated for the Fixed Tap Delay mode of the IDELAY.
wire dlyctrl_rdy;
IDELAYCTRL #(
  .SIM_DEVICE ("ULTRASCALE")  // Set the device version for simulation functionality (ULTRASCALE)
)
IDELAYCTRL_inst (
  .RDY        (dlyctrl_rdy),  // 1-bit output: Ready output
  .REFCLK     (clk200_int),   // 1-bit input: Reference clock input
  .RST        (~RST_B)        // 1-bit input: Active-High reset input. Asynchronous assert, synchronous deassert to REFCLK.
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
wire            tcp_rst;
wire            tcp_close;

wire    [15:0]  tcp_rx_size;    // Receive buffer size(byte). Caution: Set a value of 4000 or more and (memory size-16) or less
wire            tcp_rx_clr_enb; // Receive buffer Clear Enable
wire            tcp_rx_clr_req; // Receive buffer Clear Request
wire    [15:0]  tcp_rx_radr;    // Receive buffer read address in bytes (unused upper bits are set to 0)
wire    [15:0]  tcp_rx_wadr;    // Receive buffer write address in bytes (lower 3 bits are not connected to memory)
wire    [7 :0]  tcp_rx_wenb;    // Receive buffer byte write enable (big endian)
wire    [63:0]  tcp_rx_wdat;    // Receive buffer write data (big endian)
wire            tcp_tx_afull;   // TX fifo almost full
wire    [63:0]  tcp_tx_d;       // Tx data[63:0]
wire    [3 :0]  tcp_tx_b;       // Byte leng

wire    [31: 0] rbcp_addr;
wire            rbcp_we;
wire    [7 : 0] rbcp_wd;
wire            rbcp_re;
wire            rbcp_act;
wire            rbcp_ack;
wire    [7 : 0] rbcp_rd;

wire            clk156;

sitcpxg #(
  .USE_CHIPSCOPE            (DEBUG_SITCPXG & USE_CHIPSCOPE),
  .BASE_IP_ADDR             (BASE_IP_ADDR),
  .MAC_IP_WIDTH             (3),
  .RxBufferSize             ("LongLong")
)sitcpxg_i(
  .RST                      (rst),
  .CLKOUT                   (clk156),
  .CLK40                    (clk40_int),
  .REG_FPGA_VER             (SYN_DATE),
  .REG_FPGA_ID              (32'b0),
  .MAC_SELECT               (0),
  .IP_SELECT                (0),
  .TIM_1US                  (),         // out: 1 us interval
  .TIM_10US                 (),
  .TIM_100US                (),
  .TIM_1MS                  (),         // out: 1 ms interval
  .TIM_10MS                 (),
  .TIM_100MS                (),
  .TIM_1S                   (tim_1s),   // out: 1 s interval
  .TIM_1M                   (),         // out: 1 min interval
  .SiTCP_RESET_OUT          (tcp_rst),
  // UDP
  .RBCP_ADDR                (rbcp_addr),
  .RBCP_WE                  (rbcp_we),
  .RBCP_WD                  (rbcp_wd),
  .RBCP_RE                  (rbcp_re),
  .RBCP_ACT                 (rbcp_act),
  .RBCP_ACK                 (rbcp_ack),
  .RBCP_RD                  (rbcp_rd),
  // TCP
  .USER_SESSION_OPEN_REQ    (1'b0),
  .USER_SESSION_ESTABLISHED (tcp_open),
  .USER_SESSION_CLOSE_REQ   (tcp_close),
  .USER_SESSION_CLOSE_ACK   (tcp_close),
  .USER_TX_D                (tcp_tx_d),
  .USER_TX_B                (tcp_tx_b),
  .USER_TX_AFULL            (tcp_tx_afull),
  .USER_RX_SIZE             (tcp_rx_size),
  .USER_RX_CLR_ENB          (tcp_rx_clr_enb),
  .USER_RX_CLR_REQ          (tcp_rx_clr_req),
  .USER_RX_RADR             (tcp_rx_radr),
  .USER_RX_WADR             (tcp_rx_wadr),
  .USER_RX_WENB             (tcp_rx_wenb),
  .USER_RX_WDAT             (tcp_rx_wdat),
  // PHY
  .GTREFCLK_P               (MGTCLK130_P0),
  .GTREFCLK_N               (MGTCLK130_N0),
  .GT_TXP                   (FMC1_DP_C2M_P0),
  .GT_TXN                   (FMC1_DP_C2M_N0),
  .GT_RXP                   (FMC1_DP_M2C_P0),
  .GT_RXN                   (FMC1_DP_M2C_N0)
);

////////////////////////////////////////////////////////////////////////////////
//  TCP test
wire [1 :0] tcp_mode;                   // 1: Loopback mode; 2: Test mode; Others: Normal mode
wire [7 :0] tcp_test_tx_rate;           // Transmission data rate in units of 100 Mbps
wire [63:0] tcp_test_num_of_data;       // Number of bytes of transmitted data
wire        tcp_test_data_gen;          // Data transmission enable
wire [2 :0] tcp_test_word_len;          // Word length of test data
wire        tcp_test_select_seq;        // Sequence Data select
wire [31:0] tcp_test_seq_pattern;       // sequence data (The default value is 0x60808040)
wire [23:0] tcp_test_blk_size;          // Transmission block size in bytes
wire        tcp_test_ins_error;         // Data error insertion

wire tcp_mode_loopback;
assign tcp_mode_loopback = (tcp_mode == 2'b01)? 1'b1: 1'b0;

wire tcp_mode_test;
assign tcp_mode_test = (tcp_mode == 2'b10)? 1'b1: 1'b0;

TCP_TEST TCP_TEST_i(
  .CLK156M             (clk156),
  .RSTs                (tcp_rst),
  .TX_RATE             (tcp_test_tx_rate),
  .NUM_OF_DATA         (tcp_test_num_of_data),
  .DATA_GEN            (tcp_test_data_gen),
  .LOOPBACK            (tcp_mode_loopback),
  .WORD_LEN            (tcp_test_word_len),
  .SELECT_SEQ          (tcp_test_select_seq),
  .SEQ_PATTERN         (tcp_test_seq_pattern),
  .BLK_SIZE            (tcp_test_blk_size),
  .INS_ERROR           (tcp_test_ins_error),
  .SiTCPXG_ESTABLISHED (tcp_open),
  .SiTCPXG_RX_SIZE     (tcp_rx_size),
  .SiTCPXG_RX_CLR_ENB  (tcp_rx_clr_enb),
  .SiTCPXG_RX_CLR_REQ  (tcp_rx_clr_req),
  .SiTCPXG_RX_RADR     (tcp_rx_radr),
  .SiTCPXG_RX_WADR     (tcp_rx_wadr),
  .SiTCPXG_RX_WENB     (tcp_rx_wenb),
  .SiTCPXG_RX_WDAT     (tcp_rx_wdat),
  .SiTCPXG_TX_AFULL    (tcp_tx_afull),
  .SiTCPXG_TX_D        (tcp_tx_d),
  .SiTCPXG_TX_B        (tcp_tx_b)
);

////////////////////////////////////////////////////////////////////////////////
//  Register controll

wire [I2C_NUM-1: 0] scl_i, sda_i, scl_o, sda_o, scl_oen, sda_oen;

RBCP_REG #(
  .USE_CHIPSCOPE(DEBUG_RBCP_REG & USE_CHIPSCOPE),
  .SYN_DATE     (SYN_DATE),
  .FPGA_VER     (FPGA_VER),
  .I2C_NUM      (I2C_NUM),
  .SPI_NUM      (SPI_NUM),
  .UART_NUM     (UART_NUM)
)RBCP_REG(
  // System
  .CLK          (clk156),     // in : System clock
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
  .VP_IN        (),
  .VN_IN        (),
  .SCL          (scl_i),
  .SCL_OEN      (scl_oen),
  .SCL_O        (scl_o),
  .SDA          (sda_i),
  .SDA_OEN      (sda_oen),
  .SDA_O        (sda_o),
  .SCK          (),
  .MOSI_O       (),
  .MISO_I       (1'b0),
  .UART_RX      (1'b1),
  .UART_TX      (),
  .i_fpga_dna                   (64'b0),
  .o_tcp_mode                   (tcp_mode),
  .o_tcp_test_tx_rate           (tcp_test_tx_rate),
  .o_tcp_test_num_of_data       (tcp_test_num_of_data),
  .o_tcp_test_data_gen          (tcp_test_data_gen),
  .o_tcp_test_word_len          (tcp_test_word_len),
  .o_tcp_test_select_seq        (tcp_test_select_seq),
  .o_tcp_test_seq_pattern       (tcp_test_seq_pattern),
  .o_tcp_test_blk_size          (tcp_test_blk_size),
  .o_tcp_test_ins_error_trigger (tcp_test_ins_error)
);

assign scl_i[0] = FPGA_SCL;
assign FPGA_SCL = scl_oen[0] ? 1'bz: scl_o[0];

assign sda_i[0] = FPGA_SDA;
assign FPGA_SDA = sda_oen[0] ? 1'bz: sda_o[0];

//////////////////////////////////////////////////////////////////////////////
// Debug
reg ledr;
always @(posedge clk156)
  if(tim_1s) ledr <= ~ledr;

assign BLED_B = ledr;
assign GLED_B = ~tcp_open;
assign RLED_B = ~rst;

endmodule
