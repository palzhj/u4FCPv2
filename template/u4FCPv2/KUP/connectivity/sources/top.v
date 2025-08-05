`timescale 1ps/1ps
/*******************************************************************************
* System      : u4FCP GbE readout                                           *
* Version     : v 1.1 2024/02/12                                               *
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
  output            MMCX_TEST_P,
  output            MMCX_TEST_N,
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
  output            FMC0_LA_P0,
  input             FMC0_LA_N0,
  output            FMC0_LA_P1,
  input             FMC0_LA_N1,
  output            FMC0_LA_P2,
  input             FMC0_LA_N2,
  output            FMC0_LA_P3,
  input             FMC0_LA_N3,
  output            FMC0_LA_P4,
  input             FMC0_LA_N4,
  output            FMC0_LA_P5,
  input             FMC0_LA_N5,
  output            FMC0_LA_P6,
  input             FMC0_LA_N6,
  output            FMC0_LA_P7,
  input             FMC0_LA_N7,
  output            FMC0_LA_P8,
  input             FMC0_LA_N8,
  output            FMC0_LA_P9,
  input             FMC0_LA_N9,
  output            FMC0_LA_P10,
  input             FMC0_LA_N10,
  output            FMC0_LA_P11,
  input             FMC0_LA_N11,
  output            FMC0_LA_P12,
  input             FMC0_LA_N12,
  output            FMC0_LA_P13,
  input             FMC0_LA_N13,
  output            FMC0_LA_P14,
  input             FMC0_LA_N14,
  output            FMC0_LA_P15,
  input             FMC0_LA_N15,
  output            FMC0_LA_P16,
  input             FMC0_LA_N16,

  output            FMC0_HB_P0,
  input             FMC0_HB_N0,
  output            FMC0_HB_P1,
  input             FMC0_HB_N1,
  output            FMC0_HB_P2,
  input             FMC0_HB_N2,
  output            FMC0_HB_P3,
  input             FMC0_HB_N3,
  output            FMC0_HB_P4,
  input             FMC0_HB_N4,
  output            FMC0_HB_P5,
  input             FMC0_HB_N5,
  output            FMC0_HB_P6,
  input             FMC0_HB_N6,
  output            FMC0_HB_P7,
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
  output            FMC1_LA_P0,
  input             FMC1_LA_N0,
  output            FMC1_LA_P1,
  input             FMC1_LA_N1,
  output            FMC1_LA_P2,
  input             FMC1_LA_N2,
  output            FMC1_LA_P3,
  input             FMC1_LA_N3,
  output            FMC1_LA_P4,
  input             FMC1_LA_N4,
  output            FMC1_LA_P5,
  input             FMC1_LA_N5,
  output            FMC1_LA_P6,
  input             FMC1_LA_N6,
  output            FMC1_LA_P7,
  input             FMC1_LA_N7,
  output            FMC1_LA_P8,
  input             FMC1_LA_N8,
  output            FMC1_LA_P9,
  input             FMC1_LA_N9,
  output            FMC1_LA_P10,
  input             FMC1_LA_N10,
  output            FMC1_LA_P11,
  input             FMC1_LA_N11,
  output            FMC1_LA_P12,
  input             FMC1_LA_N12,
  output            FMC1_LA_P13,
  input             FMC1_LA_N13,
  output            FMC1_LA_P14,
  input             FMC1_LA_N14,
  output            FMC1_LA_P15,
  input             FMC1_LA_N15,
  output            FMC1_LA_P16,
  input             FMC1_LA_N16,

  output            FMC1_HB_P0,
  input             FMC1_HB_N0,
  output            FMC1_HB_P1,
  input             FMC1_HB_N1,
  output            FMC1_HB_P2,
  input             FMC1_HB_N2,
  output            FMC1_HB_P3,
  input             FMC1_HB_N3,
  output            FMC1_HB_P4,
  input             FMC1_HB_N4,
  output            FMC1_HB_P5,
  input             FMC1_HB_N5,
  output            FMC1_HB_P6,
  input             FMC1_HB_N6,
  output            FMC1_HB_P7,
  input             FMC1_HB_N7,

  // input             FMC1_DP_M2C_P0,
  // input             FMC1_DP_M2C_N0,
  // input             FMC1_DP_M2C_P1,
  // input             FMC1_DP_M2C_N1,
  // input             FMC1_DP_M2C_P2,
  // input             FMC1_DP_M2C_N2,
  // input             FMC1_DP_M2C_P3,
  // input             FMC1_DP_M2C_N3,
  // output            FMC1_DP_C2M_P0,
  // output            FMC1_DP_C2M_N0,
  // output            FMC1_DP_C2M_P1,
  // output            FMC1_DP_C2M_N1,
  // output            FMC1_DP_C2M_P2,
  // output            FMC1_DP_C2M_N2,
  // output            FMC1_DP_C2M_P3,
  // output            FMC1_DP_C2M_N3,
  // input             MGTCLK130_P0,
  // input             MGTCLK130_N0,
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
  input             FIREFLY_MODSEL,   // pulled low when I2C are used
  input             FIREFLY_MODPRSL,  // low to indicate present
  input             FIREFLY_INTL,     // low to indicate a fault condition
  input             FIREFLY_RESETL,   // pulled low for more than 200 us when reset

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
  output            AMC_TX_P0,
  output            AMC_TX_N0,
  // output            AMC_TX_P1,
  // output            AMC_TX_N1,
  // output            AMC_TX_P2,
  // output            AMC_TX_N2,
  // output            AMC_TX_P3,
  // output            AMC_TX_N3,
  input             AMC_RX_P0,
  input             AMC_RX_N0,
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

  output            AMC_TX17,
  output            AMC_TX18,
  output            AMC_TX19,
  output            AMC_TX20,
  output            AMC_TX_DE17,
  output            AMC_TX_DE18,
  output            AMC_TX_DE19,
  output            AMC_TX_DE20,
  input             AMC_RX17,
  input             AMC_RX18,
  input             AMC_RX19,
  input             AMC_RX20,
  output            AMC_RX_DE17,
  output            AMC_RX_DE18,
  output            AMC_RX_DE19,
  output            AMC_RX_DE20,

// RTM
  input             RTM_PS_B,
  output            RTM_IO0,
  input             RTM_IO1,
  output            RTM_IO2,
  input             RTM_IO3,

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

localparam DEBUG_SITCP    = 0;
localparam DEBUG_RBCP_REG = 0;

////////////////////////////////////////////////////////////////////////////////
//  Clock local
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

OBUFDS OBUFDS_clkout (
  .O            (CLK_OUT_P),    // 1-bit output: Diff_p output (connect directly to top-level port)
  .OB           (CLK_OUT_N),    // 1-bit output: Diff_n output (connect directly to top-level port)
  .I            (clk125_int)    // 1-bit input: Buffer input
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
  .USE_CHIPSCOPE(DEBUG_SITCP & USE_CHIPSCOPE),
  .BASE_IP_ADDR (BASE_IP_ADDR),
  .PHY_ADDRESS  (PHY_ADDRESS),
  .MAC_IP_WIDTH (4)
)sitcp(
  .RST          (rst),
  .USRCLK       (clk125_int),
  .CLK40        (clk40_int),
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
  .GT_TXP       (AMC_TX_P0),
  .GT_TXN       (AMC_TX_N0),
  .GT_RXP       (AMC_RX_P0),
  .GT_RXN       (AMC_RX_N0),
  .GT_DETECT    (1'b1)
);

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
  .USE_CHIPSCOPE(DEBUG_RBCP_REG & USE_CHIPSCOPE),
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

assign FMC0_LA_P0 = temp;
assign FMC0_LA_P1 = temp;
assign FMC0_LA_P2 = temp;
assign FMC0_LA_P3 = temp;
assign FMC0_LA_P4 = temp;
assign FMC0_LA_P5 = temp;
assign FMC0_LA_P6 = temp;
assign FMC0_LA_P7 = temp;
assign FMC0_LA_P8 = temp;
assign FMC0_LA_P9 = temp;
assign FMC0_LA_P10 = temp;
assign FMC0_LA_P11 = temp;
assign FMC0_LA_P12 = temp;
assign FMC0_LA_P13 = temp;
assign FMC0_LA_P14 = temp;
assign FMC0_LA_P15 = temp;
assign FMC0_LA_P16 = temp;

assign FMC1_LA_P0 = temp;
assign FMC1_LA_P1 = temp;
assign FMC1_LA_P2 = temp;
assign FMC1_LA_P3 = temp;
assign FMC1_LA_P4 = temp;
assign FMC1_LA_P5 = temp;
assign FMC1_LA_P6 = temp;
assign FMC1_LA_P7 = temp;
assign FMC1_LA_P8 = temp;
assign FMC1_LA_P9 = temp;
assign FMC1_LA_P10 = temp;
assign FMC1_LA_P11 = temp;
assign FMC1_LA_P12 = temp;
assign FMC1_LA_P13 = temp;
assign FMC1_LA_P14 = temp;
assign FMC1_LA_P15 = temp;
assign FMC1_LA_P16 = temp;

assign FMC0_HB_P0 = temp;
assign FMC0_HB_P1 = temp;
assign FMC0_HB_P2 = temp;
assign FMC0_HB_P3 = temp;
assign FMC0_HB_P4 = temp;
assign FMC0_HB_P5 = temp;
assign FMC0_HB_P6 = temp;
assign FMC0_HB_P7 = temp;

assign FMC1_HB_P0 = temp;
assign FMC1_HB_P1 = temp;
assign FMC1_HB_P2 = temp;
assign FMC1_HB_P3 = temp;
assign FMC1_HB_P4 = temp;
assign FMC1_HB_P5 = temp;
assign FMC1_HB_P6 = temp;
assign FMC1_HB_P7 = temp;

assign FMC0_CLK_DIR = 1'b1;
assign FMC1_CLK_DIR = 1'b1;

IBUFDS #(
  .DIFF_TERM("FALSE")
)ibuf_fmc0_clk_m2c_1(
  .I  (FMC0_CLK_M2C_P1),
  .IB (FMC0_CLK_M2C_N1),
  .O  (fmc0_clk_m2c_1)
);

IBUFDS #(
  .DIFF_TERM("FALSE")
)ibuf_fmc0_clk_m2c_3(
  .I  (FMC0_CLK_M2C_P3),
  .IB (FMC0_CLK_M2C_N3),
  .O  (fmc0_clk_m2c_3)
);

OBUFDS OBUFDS_fmc0_clk_c2m (
  .O  (FMC0_CLK_C2M_P3),     // Diff_p output (connect directly to top-level port)
  .OB (FMC0_CLK_C2M_N3),   // Diff_n output (connect directly to top-level port)
  .I  (clk40_int)      // Buffer input
);

IBUFDS #(
  .DIFF_TERM("FALSE")
)ibuf_fmc1_clk_m2c_1(
  .I  (FMC1_CLK_M2C_P1),
  .IB (FMC1_CLK_M2C_N1),
  .O  (fmc1_clk_m2c_1)
);

IBUFDS #(
  .DIFF_TERM("FALSE")
)ibuf_fmc1_clk_m2c_3(
  .I  (FMC1_CLK_M2C_P3),
  .IB (FMC1_CLK_M2C_N3),
  .O  (fmc1_clk_m2c_3)
);

OBUFDS OBUFDS_fmc1_clk_c2m (
  .O  (FMC1_CLK_C2M_P3),     // Diff_p output (connect directly to top-level port)
  .OB (FMC1_CLK_C2M_N3),   // Diff_n output (connect directly to top-level port)
  .I  (clk40_int)      // Buffer input
);

///////////////////////////////////////////////////////////////////////////////
// AMC test
assign AMC_TX_DE17 = 1'b1;
assign AMC_RX_DE17 = 1'b0;
assign AMC_TX_DE18 = 1'b1;
assign AMC_RX_DE18 = 1'b0;
assign AMC_TX_DE19 = 1'b1;
assign AMC_RX_DE19 = 1'b0;
assign AMC_TX_DE20 = 1'b1;
assign AMC_RX_DE20 = 1'b0;

assign AMC_TX17 = temp;
assign AMC_TX18 = temp;
assign AMC_TX19 = temp;
assign AMC_TX20 = temp;

//////////////////////////////////////////////////////////////////////////////
// RTM test
assign RTM_IO0 = temp;
assign RTM_IO2 = temp;

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
assign TP24 = temp;

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
// FMC 0
assign probe0[0] = FMC0_LA_N0;
assign probe0[1] = FMC0_LA_N1;
assign probe0[2] = FMC0_LA_N2;
assign probe0[3] = FMC0_LA_N3;
assign probe0[4] = FMC0_LA_N4;
assign probe0[5] = FMC0_LA_N5;
assign probe0[6] = FMC0_LA_N6;
assign probe0[7] = FMC0_LA_N7;
assign probe0[8] = FMC0_LA_N8;
assign probe0[9] = FMC0_LA_N9;
assign probe0[10] = FMC0_LA_N10;
assign probe0[11] = FMC0_LA_N11;
assign probe0[12] = FMC0_LA_N12;
assign probe0[13] = FMC0_LA_N13;
assign probe0[14] = FMC0_LA_N14;
assign probe0[15] = FMC0_LA_N15;
assign probe0[16] = FMC0_LA_N16;

assign probe0[17] = FMC0_HB_N0;
assign probe0[18] = FMC0_HB_N1;
assign probe0[19] = FMC0_HB_N2;
assign probe0[20] = FMC0_HB_N3;
assign probe0[21] = FMC0_HB_N4;
assign probe0[22] = FMC0_HB_N5;
assign probe0[23] = FMC0_HB_N6;
assign probe0[24] = FMC0_HB_N7;

assign probe0[25] = FMC0_PRSNT_B;
assign probe0[26] = FMC0_CLK_DIR;

assign probe0[27] = fmc0_clk_m2c_1;
assign probe0[28] = fmc0_clk_m2c_3;

assign probe0[31:29] = 0;

// FMC1
assign probe0[32+0] = FMC1_LA_N0;
assign probe0[32+1] = FMC1_LA_N1;
assign probe0[32+2] = FMC1_LA_N2;
assign probe0[32+3] = FMC1_LA_N3;
assign probe0[32+4] = FMC1_LA_N4;
assign probe0[32+5] = FMC1_LA_N5;
assign probe0[32+6] = FMC1_LA_N6;
assign probe0[32+7] = FMC1_LA_N7;
assign probe0[32+8] = FMC1_LA_N8;
assign probe0[32+9] = FMC1_LA_N9;
assign probe0[32+10] = FMC1_LA_N10;
assign probe0[32+11] = FMC1_LA_N11;
assign probe0[32+12] = FMC1_LA_N12;
assign probe0[32+13] = FMC1_LA_N13;
assign probe0[32+14] = FMC1_LA_N14;
assign probe0[32+15] = FMC1_LA_N15;
assign probe0[32+16] = FMC1_LA_N16;

assign probe0[32+17] = FMC1_HB_N0;
assign probe0[32+18] = FMC1_HB_N1;
assign probe0[32+19] = FMC1_HB_N2;
assign probe0[32+20] = FMC1_HB_N3;
assign probe0[32+21] = FMC1_HB_N4;
assign probe0[32+22] = FMC1_HB_N5;
assign probe0[32+23] = FMC1_HB_N6;
assign probe0[32+24] = FMC1_HB_N7;

assign probe0[32+25] = FMC1_PRSNT_B;
assign probe0[32+26] = FMC1_CLK_DIR;

assign probe0[32+27] = fmc1_clk_m2c_1;
assign probe0[32+28] = fmc1_clk_m2c_3;

assign probe0[63:61] = 0;

// Test
wire [63:0] probe1;
ila64 ila64_1 (
  .clk(clk125_int),
  .probe0(probe1)
);

assign probe1[7:0] = DIPSW[7:0];
assign probe1[8] = RST_B;
assign probe1[9] = lemo_in;
assign probe1[10] = FIREFLY_MODSEL;   // pulled low when I2C are used
assign probe1[11] = FIREFLY_MODPRSL;  // low to indicate present
assign probe1[12] = FIREFLY_INTL;     // low to indicate a fault condition
assign probe1[13] = FIREFLY_RESETL;   // pulled low for more than 200 us when reset
assign probe1[14] = AMC_MODE;
assign probe1[15] = AMC_RX17;
assign probe1[16] = AMC_RX18;
assign probe1[17] = AMC_RX19;
assign probe1[18] = AMC_RX20;
assign probe1[19] = RTM_PS_B;
assign probe1[20] = RTM_IO1;
assign probe1[21] = RTM_IO3;

assign probe1[63:22] = 0;

endmodule
