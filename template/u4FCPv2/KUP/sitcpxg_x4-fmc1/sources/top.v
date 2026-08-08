`timescale 1 ps/1 ps
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
  parameter [31: 0] SYN_DATE      = 32'h0,         // the date of compiling
  parameter [ 7: 0] FPGA_VER      = 8'h1,          // the code version
  parameter [31: 0] BASE_IP_ADDR0 = 32'hC0A8_0A10, // 192.168.10.16
  parameter [31: 0] BASE_IP_ADDR1 = 32'hC0A8_0B10, // 192.168.11.16
  parameter [31: 0] BASE_IP_ADDR2 = 32'hC0A8_0C10, // 192.168.12.16
  parameter [31: 0] BASE_IP_ADDR3 = 32'hC0A8_0D10, // 192.168.13.16
  parameter [ 4: 0] PHY_ADDRESS   = 5'b1,
  parameter [ 3: 0] I2C_NUM       = 1,
  parameter [ 3: 0] SPI_NUM       = 1,
  parameter [ 3: 0] UART_NUM      = 1
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
  output  [ 3: 0]   TESTPIN,        // Test Pin
  input   [ 7: 0]   DIPSW,
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
  output            FMC0_CLK_DIR,   // high for output
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
  output            FMC1_CLK_DIR,   // high for output
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
  input             FMC1_DP_M2C_P1,
  input             FMC1_DP_M2C_N1,
  input             FMC1_DP_M2C_P2,
  input             FMC1_DP_M2C_N2,
  input             FMC1_DP_M2C_P3,
  input             FMC1_DP_M2C_N3,
  output            FMC1_DP_C2M_P0,
  output            FMC1_DP_C2M_N0,
  output            FMC1_DP_C2M_P1,
  output            FMC1_DP_C2M_N1,
  output            FMC1_DP_C2M_P2,
  output            FMC1_DP_C2M_N2,
  output            FMC1_DP_C2M_P3,
  output            FMC1_DP_C2M_N3,
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
  .DIFF_TERM ("FALSE")
) IBUFDS_clk200 (
  .O         (clk200_in),
  .I         (CLK_IN_200_P),
  .IB        (CLK_IN_200_N)
);
BUFG BUFG_200 (
  .O         (clk200_int),
  .I         (clk200_in)
);

wire clk40_int, clk100_int, clk125_int, locked;
clk_wiz clk_wiz (
  // Clock in ports
  .clk_in1  (clk200_int),
  // Clock out ports
  .clk_out1 (clk40_int),
  .clk_out2 (clk100_int),
  .clk_out3 (clk125_int),
  // Status and control signals
  .resetn   (RST_B),
  .locked   (locked)
);

OBUFDS OBUFDS_clkout (
  .O  (CLK_OUT_P),  // 1-bit output: Diff_p output (connect directly to top-level port)
  .OB (CLK_OUT_N),  // 1-bit output: Diff_n output (connect directly to top-level port)
  .I  (clk125_int)  // 1-bit input: Buffer input
);

OBUFDS OBUFDS_fmc0_clkout3 (
  .O  (FMC0_CLK_C2M_P3),  // 1-bit output: Diff_p output (connect directly to top-level port)
  .OB (FMC0_CLK_C2M_N3),  // 1-bit output: Diff_n output (connect directly to top-level port)
  .I  (0)                 // 1-bit input: Buffer input
);

OBUFDS OBUFDS_fmc1_clkout3 (
  .O  (FMC1_CLK_C2M_P3),  // 1-bit output: Diff_p output (connect directly to top-level port)
  .OB (FMC1_CLK_C2M_N3),  // 1-bit output: Diff_n output (connect directly to top-level port)
  .I  (0)                 // 1-bit input: Buffer input
);

// An IDELAYCTRL primitive needs to be instantiated for the Fixed Tap Delay mode of the IDELAY.
wire dlyctrl_rdy;
IDELAYCTRL #(
  .SIM_DEVICE ("ULTRASCALE")  // Set the device version for simulation functionality (ULTRASCALE)
)
IDELAYCTRL_inst (
  .RDY    (dlyctrl_rdy),  // 1-bit output: Ready output
  .REFCLK (clk200_int),   // 1-bit input: Reference clock input
  .RST    (~RST_B)        // 1-bit input: Active-High reset input. Asynchronous assert, synchronous deassert to REFCLK.
);

////////////////////////////////////////////////////////////////////////////////
// System clock and reset
wire usrclk, rst;
assign usrclk = clk125_int;

async2sync_reset reset_usrclk (
  .rst_in  (~(locked & dlyctrl_rdy)),
  .clk     (usrclk),
  .rst_out (rst)
);

////////////////////////////////////////////////////////////////////////////////
// SiTCP interface
wire            tim_1s;

wire            tcp_open0, tcp_open1, tcp_open2, tcp_open3;
wire            tcp_rst0, tcp_rst1, tcp_rst2, tcp_rst3;
wire            tcp_close0, tcp_close1, tcp_close2, tcp_close3;

wire    [15: 0] tcp_rx_size0, tcp_rx_size1, tcp_rx_size2, tcp_rx_size3;     // Receive buffer size (byte). Caution: Set a value of 4000 or more and (memory size-16) or less
wire            tcp_rx_clr_enb0, tcp_rx_clr_enb1, tcp_rx_clr_enb2, tcp_rx_clr_enb3; // Receive buffer Clear Enable
wire            tcp_rx_clr_req0, tcp_rx_clr_req1, tcp_rx_clr_req2, tcp_rx_clr_req3; // Receive buffer Clear Request
wire    [15: 0] tcp_rx_radr0, tcp_rx_radr1, tcp_rx_radr2, tcp_rx_radr3;     // Receive buffer read address in bytes (unused upper bits are set to 0)
wire    [15: 0] tcp_rx_wadr0, tcp_rx_wadr1, tcp_rx_wadr2, tcp_rx_wadr3;     // Receive buffer write address in bytes (lower 3 bits are not connected to memory)
wire    [ 7: 0] tcp_rx_wenb0, tcp_rx_wenb1, tcp_rx_wenb2, tcp_rx_wenb3;     // Receive buffer byte write enable (big endian)
wire    [63: 0] tcp_rx_wdat0, tcp_rx_wdat1, tcp_rx_wdat2, tcp_rx_wdat3;     // Receive buffer write data (big endian)
wire            tcp_tx_afull0, tcp_tx_afull1, tcp_tx_afull2, tcp_tx_afull3; // TX fifo almost full
wire    [63: 0] tcp_tx_d0, tcp_tx_d1, tcp_tx_d2, tcp_tx_d3;                 // Tx data[63:0]
wire    [ 3: 0] tcp_tx_b0, tcp_tx_b1, tcp_tx_b2, tcp_tx_b3;                 // Byte length

wire    [31: 0] rbcp_addr0, rbcp_addr1, rbcp_addr2, rbcp_addr3;
wire            rbcp_we0, rbcp_we1, rbcp_we2, rbcp_we3;
wire    [ 7: 0] rbcp_wd0, rbcp_wd1, rbcp_wd2, rbcp_wd3;
wire            rbcp_re0, rbcp_re1, rbcp_re2, rbcp_re3;
wire            rbcp_act0, rbcp_act1, rbcp_act2, rbcp_act3;
wire            rbcp_ack0, rbcp_ack1, rbcp_ack2, rbcp_ack3;
wire    [ 7: 0] rbcp_rd0, rbcp_rd1, rbcp_rd2, rbcp_rd3;

wire            clk156_0, clk156_1, clk156_2, clk156_3;

sitcpxg_x4 #(
  .USE_CHIPSCOPE            (DEBUG_SITCPXG & USE_CHIPSCOPE),
  .BASE_IP_ADDR0            (BASE_IP_ADDR0),
  .BASE_IP_ADDR1            (BASE_IP_ADDR1),
  .BASE_IP_ADDR2            (BASE_IP_ADDR2),
  .BASE_IP_ADDR3            (BASE_IP_ADDR3),
  .MAC_IP_WIDTH             (3),
  .RxBufferSize             ("LongLong")
) sitcpxg_x4_i (
  .RST                      (rst),
  .CLK40                    (clk40_int),
  .REG_FPGA_VER             (SYN_DATE),
  .REG_FPGA_ID              (32'b0),
  .MAC_SELECT               (0),
  .IP_SELECT                (0),
  .TIM_1US                  (),          // out: 1 us interval
  .TIM_10US                 (),
  .TIM_100US                (),
  .TIM_1MS                  (),          // out: 1 ms interval
  .TIM_10MS                 (),
  .TIM_100MS                (),
  .TIM_1S                   (tim_1s),    // out: 1 s interval
  .TIM_1M                   (),          // out: 1 min interval
  .CLKOUT0                  (clk156_0),
  .CLKOUT1                  (clk156_1),
  .CLKOUT2                  (clk156_2),
  .CLKOUT3                  (clk156_3),
  .SiTCP_RESET_OUT0         (tcp_rst0),
  .SiTCP_RESET_OUT1         (tcp_rst1),
  .SiTCP_RESET_OUT2         (tcp_rst2),
  .SiTCP_RESET_OUT3         (tcp_rst3),
  // UDP0
  .RBCP_ADDR0               (rbcp_addr0),
  .RBCP_WE0                 (rbcp_we0),
  .RBCP_WD0                 (rbcp_wd0),
  .RBCP_RE0                 (rbcp_re0),
  .RBCP_ACT0                (rbcp_act0),
  .RBCP_ACK0                (rbcp_ack0),
  .RBCP_RD0                 (rbcp_rd0),
  // UDP1
  .RBCP_ADDR1               (rbcp_addr1),
  .RBCP_WE1                 (rbcp_we1),
  .RBCP_WD1                 (rbcp_wd1),
  .RBCP_RE1                 (rbcp_re1),
  .RBCP_ACT1                (rbcp_act1),
  .RBCP_ACK1                (rbcp_ack1),
  .RBCP_RD1                 (rbcp_rd1),
  // UDP2
  .RBCP_ADDR2               (rbcp_addr2),
  .RBCP_WE2                 (rbcp_we2),
  .RBCP_WD2                 (rbcp_wd2),
  .RBCP_RE2                 (rbcp_re2),
  .RBCP_ACT2                (rbcp_act2),
  .RBCP_ACK2                (rbcp_ack2),
  .RBCP_RD2                 (rbcp_rd2),
  // UDP3
  .RBCP_ADDR3               (rbcp_addr3),
  .RBCP_WE3                 (rbcp_we3),
  .RBCP_WD3                 (rbcp_wd3),
  .RBCP_RE3                 (rbcp_re3),
  .RBCP_ACT3                (rbcp_act3),
  .RBCP_ACK3                (rbcp_ack3),
  .RBCP_RD3                 (rbcp_rd3),
  // TCP0
  .USER_SESSION_OPEN_REQ0     (1'b0),
  .USER_SESSION_ESTABLISHED0  (tcp_open0),
  .USER_SESSION_CLOSE_REQ0    (tcp_close0),
  .USER_SESSION_CLOSE_ACK0    (tcp_close0),
  .USER_TX_D0                 (tcp_tx_d0),
  .USER_TX_B0                 (tcp_tx_b0),
  .USER_TX_AFULL0             (tcp_tx_afull0),
  .USER_RX_SIZE0              (tcp_rx_size0),
  .USER_RX_CLR_ENB0           (tcp_rx_clr_enb0),
  .USER_RX_CLR_REQ0           (tcp_rx_clr_req0),
  .USER_RX_RADR0              (tcp_rx_radr0),
  .USER_RX_WADR0              (tcp_rx_wadr0),
  .USER_RX_WENB0              (tcp_rx_wenb0),
  .USER_RX_WDAT0              (tcp_rx_wdat0),
  // TCP1
  .USER_SESSION_OPEN_REQ1     (1'b0),
  .USER_SESSION_ESTABLISHED1  (tcp_open1),
  .USER_SESSION_CLOSE_REQ1    (tcp_close1),
  .USER_SESSION_CLOSE_ACK1    (tcp_close1),
  .USER_TX_D1                 (tcp_tx_d1),
  .USER_TX_B1                 (tcp_tx_b1),
  .USER_TX_AFULL1             (tcp_tx_afull1),
  .USER_RX_SIZE1              (tcp_rx_size1),
  .USER_RX_CLR_ENB1           (tcp_rx_clr_enb1),
  .USER_RX_CLR_REQ1           (tcp_rx_clr_req1),
  .USER_RX_RADR1              (tcp_rx_radr1),
  .USER_RX_WADR1              (tcp_rx_wadr1),
  .USER_RX_WENB1              (tcp_rx_wenb1),
  .USER_RX_WDAT1              (tcp_rx_wdat1),
  // TCP2
  .USER_SESSION_OPEN_REQ2     (1'b0),
  .USER_SESSION_ESTABLISHED2  (tcp_open2),
  .USER_SESSION_CLOSE_REQ2    (tcp_close2),
  .USER_SESSION_CLOSE_ACK2    (tcp_close2),
  .USER_TX_D2                 (tcp_tx_d2),
  .USER_TX_B2                 (tcp_tx_b2),
  .USER_TX_AFULL2             (tcp_tx_afull2),
  .USER_RX_SIZE2              (tcp_rx_size2),
  .USER_RX_CLR_ENB2           (tcp_rx_clr_enb2),
  .USER_RX_CLR_REQ2           (tcp_rx_clr_req2),
  .USER_RX_RADR2              (tcp_rx_radr2),
  .USER_RX_WADR2              (tcp_rx_wadr2),
  .USER_RX_WENB2              (tcp_rx_wenb2),
  .USER_RX_WDAT2              (tcp_rx_wdat2),
  // TCP3
  .USER_SESSION_OPEN_REQ3     (1'b0),
  .USER_SESSION_ESTABLISHED3  (tcp_open3),
  .USER_SESSION_CLOSE_REQ3    (tcp_close3),
  .USER_SESSION_CLOSE_ACK3    (tcp_close3),
  .USER_TX_D3                 (tcp_tx_d3),
  .USER_TX_B3                 (tcp_tx_b3),
  .USER_TX_AFULL3             (tcp_tx_afull3),
  .USER_RX_SIZE3              (tcp_rx_size3),
  .USER_RX_CLR_ENB3           (tcp_rx_clr_enb3),
  .USER_RX_CLR_REQ3           (tcp_rx_clr_req3),
  .USER_RX_RADR3              (tcp_rx_radr3),
  .USER_RX_WADR3              (tcp_rx_wadr3),
  .USER_RX_WENB3              (tcp_rx_wenb3),
  .USER_RX_WDAT3              (tcp_rx_wdat3),
  // PHY
  .GTREFCLK_P               (MGTCLK130_P0),
  .GTREFCLK_N               (MGTCLK130_N0),
  .GT_TXP                   ({FMC1_DP_C2M_P0, FMC1_DP_C2M_P1, FMC1_DP_C2M_P2, FMC1_DP_C2M_P3}),
  .GT_TXN                   ({FMC1_DP_C2M_N0, FMC1_DP_C2M_N1, FMC1_DP_C2M_N2, FMC1_DP_C2M_N3}),
  .GT_RXP                   ({FMC1_DP_M2C_P0, FMC1_DP_M2C_P1, FMC1_DP_M2C_P2, FMC1_DP_M2C_P3}),
  .GT_RXN                   ({FMC1_DP_M2C_N0, FMC1_DP_M2C_N1, FMC1_DP_M2C_N2, FMC1_DP_M2C_N3})
);

////////////////////////////////////////////////////////////////////////////////
//  TCP test
wire [1 : 0] tcp_mode0, tcp_mode1, tcp_mode2, tcp_mode3;   // 1: Loopback mode; 2: Test mode; Others: Normal mode
wire [7 : 0] tcp_test_tx_rate0, tcp_test_tx_rate1, tcp_test_tx_rate2, tcp_test_tx_rate3;   // Transmission data rate in units of 100 Mbps
wire [63: 0] tcp_test_num_of_data0, tcp_test_num_of_data1, tcp_test_num_of_data2, tcp_test_num_of_data3; // Number of bytes of transmitted data
wire         tcp_test_data_gen0, tcp_test_data_gen1, tcp_test_data_gen2, tcp_test_data_gen3; // Data transmission enable
wire [2 : 0] tcp_test_word_len0, tcp_test_word_len1, tcp_test_word_len2, tcp_test_word_len3; // Word length of test data
wire         tcp_test_select_seq0, tcp_test_select_seq1, tcp_test_select_seq2, tcp_test_select_seq3; // Sequence Data select
wire [31: 0] tcp_test_seq_pattern0, tcp_test_seq_pattern1, tcp_test_seq_pattern2, tcp_test_seq_pattern3; // Sequence data (The default value is 0x60808040)
wire [23: 0] tcp_test_blk_size0, tcp_test_blk_size1, tcp_test_blk_size2, tcp_test_blk_size3; // Transmission block size in bytes
wire         tcp_test_ins_error0, tcp_test_ins_error1, tcp_test_ins_error2, tcp_test_ins_error3; // Data error insertion

wire tcp_mode_loopback0, tcp_mode_loopback1, tcp_mode_loopback2, tcp_mode_loopback3;
assign tcp_mode_loopback0 = (tcp_mode0 == 2'b01) ? 1'b1 : 1'b0;
assign tcp_mode_loopback1 = (tcp_mode1 == 2'b01) ? 1'b1 : 1'b0;
assign tcp_mode_loopback2 = (tcp_mode2 == 2'b01) ? 1'b1 : 1'b0;
assign tcp_mode_loopback3 = (tcp_mode3 == 2'b01) ? 1'b1 : 1'b0;

wire tcp_mode_test0, tcp_mode_test1, tcp_mode_test2, tcp_mode_test3;
assign tcp_mode_test0 = (tcp_mode0 == 2'b10) ? 1'b1 : 1'b0;
assign tcp_mode_test1 = (tcp_mode1 == 2'b10) ? 1'b1 : 1'b0;
assign tcp_mode_test2 = (tcp_mode2 == 2'b10) ? 1'b1 : 1'b0;
assign tcp_mode_test3 = (tcp_mode3 == 2'b10) ? 1'b1 : 1'b0;

TCP_TEST TCP_TEST_0 (
  .CLK156M             (clk156_0),
  .RSTs                (tcp_rst0),
  .TX_RATE             (tcp_test_tx_rate0),
  .NUM_OF_DATA         (tcp_test_num_of_data0),
  .DATA_GEN            (tcp_test_data_gen0),
  .LOOPBACK            (tcp_mode_loopback0),
  .WORD_LEN            (tcp_test_word_len0),
  .SELECT_SEQ          (tcp_test_select_seq0),
  .SEQ_PATTERN         (tcp_test_seq_pattern0),
  .BLK_SIZE            (tcp_test_blk_size0),
  .INS_ERROR           (tcp_test_ins_error0),
  .SiTCPXG_ESTABLISHED (tcp_open0),
  .SiTCPXG_RX_SIZE     (tcp_rx_size0),
  .SiTCPXG_RX_CLR_ENB  (tcp_rx_clr_enb0),
  .SiTCPXG_RX_CLR_REQ  (tcp_rx_clr_req0),
  .SiTCPXG_RX_RADR     (tcp_rx_radr0),
  .SiTCPXG_RX_WADR     (tcp_rx_wadr0),
  .SiTCPXG_RX_WENB     (tcp_rx_wenb0),
  .SiTCPXG_RX_WDAT     (tcp_rx_wdat0),
  .SiTCPXG_TX_AFULL    (tcp_tx_afull0),
  .SiTCPXG_TX_D        (tcp_tx_d0),
  .SiTCPXG_TX_B        (tcp_tx_b0)
);

TCP_TEST TCP_TEST_1 (
  .CLK156M             (clk156_1),
  .RSTs                (tcp_rst1),
  .TX_RATE             (tcp_test_tx_rate1),
  .NUM_OF_DATA         (tcp_test_num_of_data1),
  .DATA_GEN            (tcp_test_data_gen1),
  .LOOPBACK            (tcp_mode_loopback1),
  .WORD_LEN            (tcp_test_word_len1),
  .SELECT_SEQ          (tcp_test_select_seq1),
  .SEQ_PATTERN         (tcp_test_seq_pattern1),
  .BLK_SIZE            (tcp_test_blk_size1),
  .INS_ERROR           (tcp_test_ins_error1),
  .SiTCPXG_ESTABLISHED (tcp_open1),
  .SiTCPXG_RX_SIZE     (tcp_rx_size1),
  .SiTCPXG_RX_CLR_ENB  (tcp_rx_clr_enb1),
  .SiTCPXG_RX_CLR_REQ  (tcp_rx_clr_req1),
  .SiTCPXG_RX_RADR     (tcp_rx_radr1),
  .SiTCPXG_RX_WADR     (tcp_rx_wadr1),
  .SiTCPXG_RX_WENB     (tcp_rx_wenb1),
  .SiTCPXG_RX_WDAT     (tcp_rx_wdat1),
  .SiTCPXG_TX_AFULL    (tcp_tx_afull1),
  .SiTCPXG_TX_D        (tcp_tx_d1),
  .SiTCPXG_TX_B        (tcp_tx_b1)
);

TCP_TEST TCP_TEST_2 (
  .CLK156M             (clk156_2),
  .RSTs                (tcp_rst2),
  .TX_RATE             (tcp_test_tx_rate2),
  .NUM_OF_DATA         (tcp_test_num_of_data2),
  .DATA_GEN            (tcp_test_data_gen2),
  .LOOPBACK            (tcp_mode_loopback2),
  .WORD_LEN            (tcp_test_word_len2),
  .SELECT_SEQ          (tcp_test_select_seq2),
  .SEQ_PATTERN         (tcp_test_seq_pattern2),
  .BLK_SIZE            (tcp_test_blk_size2),
  .INS_ERROR           (tcp_test_ins_error2),
  .SiTCPXG_ESTABLISHED (tcp_open2),
  .SiTCPXG_RX_SIZE     (tcp_rx_size2),
  .SiTCPXG_RX_CLR_ENB  (tcp_rx_clr_enb2),
  .SiTCPXG_RX_CLR_REQ  (tcp_rx_clr_req2),
  .SiTCPXG_RX_RADR     (tcp_rx_radr2),
  .SiTCPXG_RX_WADR     (tcp_rx_wadr2),
  .SiTCPXG_RX_WENB     (tcp_rx_wenb2),
  .SiTCPXG_RX_WDAT     (tcp_rx_wdat2),
  .SiTCPXG_TX_AFULL    (tcp_tx_afull2),
  .SiTCPXG_TX_D        (tcp_tx_d2),
  .SiTCPXG_TX_B        (tcp_tx_b2)
);

TCP_TEST TCP_TEST_3 (
  .CLK156M             (clk156_3),
  .RSTs                (tcp_rst3),
  .TX_RATE             (tcp_test_tx_rate3),
  .NUM_OF_DATA         (tcp_test_num_of_data3),
  .DATA_GEN            (tcp_test_data_gen3),
  .LOOPBACK            (tcp_mode_loopback3),
  .WORD_LEN            (tcp_test_word_len3),
  .SELECT_SEQ          (tcp_test_select_seq3),
  .SEQ_PATTERN         (tcp_test_seq_pattern3),
  .BLK_SIZE            (tcp_test_blk_size3),
  .INS_ERROR           (tcp_test_ins_error3),
  .SiTCPXG_ESTABLISHED (tcp_open3),
  .SiTCPXG_RX_SIZE     (tcp_rx_size3),
  .SiTCPXG_RX_CLR_ENB  (tcp_rx_clr_enb3),
  .SiTCPXG_RX_CLR_REQ  (tcp_rx_clr_req3),
  .SiTCPXG_RX_RADR     (tcp_rx_radr3),
  .SiTCPXG_RX_WADR     (tcp_rx_wadr3),
  .SiTCPXG_RX_WENB     (tcp_rx_wenb3),
  .SiTCPXG_RX_WDAT     (tcp_rx_wdat3),
  .SiTCPXG_TX_AFULL    (tcp_tx_afull3),
  .SiTCPXG_TX_D        (tcp_tx_d3),
  .SiTCPXG_TX_B        (tcp_tx_b3)
);

////////////////////////////////////////////////////////////////////////////////
//  Register control
wire [I2C_NUM-1: 0] scl_i, sda_i, scl_o, sda_o, scl_oen, sda_oen;

RBCP_REG #(
  .USE_CHIPSCOPE               (DEBUG_RBCP_REG & USE_CHIPSCOPE),
  .SYN_DATE                    (SYN_DATE),
  .FPGA_VER                    (FPGA_VER),
  .I2C_NUM                     (I2C_NUM),
  .SPI_NUM                     (SPI_NUM),
  .UART_NUM                    (UART_NUM)
) RBCP_REG_0 (
  // System
  .CLK                         (clk156_0),     // in : System clock
  .RST                         (tcp_rst0),     // in : System reset
  // RBCP I/F
  .RBCP_ACT                    (rbcp_act0),    // in : Active
  .RBCP_ADDR                   (rbcp_addr0),   // in : Address[31:0]
  .RBCP_WE                     (rbcp_we0),     // in : Write enable
  .RBCP_WD                     (rbcp_wd0),     // in : Write data[7:0]
  .RBCP_RE                     (rbcp_re0),     // in : Read enable
  .RBCP_RD                     (rbcp_rd0),     // out: Read data[7:0]
  .RBCP_ACK                    (rbcp_ack0),    // out: Acknowledge
  // User IO
  .VP_IN                       (),
  .VN_IN                       (),
  .SCL                         (scl_i),
  .SCL_OEN                     (scl_oen),
  .SCL_O                       (scl_o),
  .SDA                         (sda_i),
  .SDA_OEN                     (sda_oen),
  .SDA_O                       (sda_o),
  .SCK                         (),
  .MOSI_O                      (),
  .MISO_I                      (1'b0),
  .UART_RX                     (1'b1),
  .UART_TX                     (),
  .i_fpga_dna                  (64'b0),
  .o_tcp_mode                  (tcp_mode0),
  .o_tcp_test_tx_rate          (tcp_test_tx_rate0),
  .o_tcp_test_num_of_data      (tcp_test_num_of_data0),
  .o_tcp_test_data_gen         (tcp_test_data_gen0),
  .o_tcp_test_word_len         (tcp_test_word_len0),
  .o_tcp_test_select_seq       (tcp_test_select_seq0),
  .o_tcp_test_seq_pattern      (tcp_test_seq_pattern0),
  .o_tcp_test_blk_size         (tcp_test_blk_size0),
  .o_tcp_test_ins_error_trigger (tcp_test_ins_error0)
);

assign scl_i[0] = FPGA_SCL;
assign FPGA_SCL = scl_oen[0] ? 1'bz : scl_o[0];

assign sda_i[0] = FPGA_SDA;
assign FPGA_SDA = sda_oen[0] ? 1'bz : sda_o[0];

//////////////////////////////////////////////////////////////////////////////
assign tcp_mode1 = tcp_mode0;
assign tcp_test_tx_rate1 = tcp_test_tx_rate0;
assign tcp_test_num_of_data1 = tcp_test_num_of_data0;
assign tcp_test_data_gen1 = tcp_test_data_gen0;
assign tcp_test_word_len1 = tcp_test_word_len0;
assign tcp_test_select_seq1 = tcp_test_select_seq0;
assign tcp_test_seq_pattern1 = tcp_test_seq_pattern0;
assign tcp_test_blk_size1 = tcp_test_blk_size0;
assign tcp_test_ins_error1 = tcp_test_ins_error0;

assign tcp_mode2 = tcp_mode0;
assign tcp_test_tx_rate2 = tcp_test_tx_rate0;
assign tcp_test_num_of_data2 = tcp_test_num_of_data0;
assign tcp_test_data_gen2 = tcp_test_data_gen0;
assign tcp_test_word_len2 = tcp_test_word_len0;
assign tcp_test_select_seq2 = tcp_test_select_seq0;
assign tcp_test_seq_pattern2 = tcp_test_seq_pattern0;
assign tcp_test_blk_size2 = tcp_test_blk_size0;
assign tcp_test_ins_error2 = tcp_test_ins_error0;

assign tcp_mode3 = tcp_mode0;
assign tcp_test_tx_rate3 = tcp_test_tx_rate0;
assign tcp_test_num_of_data3 = tcp_test_num_of_data0;
assign tcp_test_data_gen3 = tcp_test_data_gen0;
assign tcp_test_word_len3 = tcp_test_word_len0;
assign tcp_test_select_seq3 = tcp_test_select_seq0;
assign tcp_test_seq_pattern3 = tcp_test_seq_pattern0;
assign tcp_test_blk_size3 = tcp_test_blk_size0;
assign tcp_test_ins_error3 = tcp_test_ins_error0;

//////////////////////////////////////////////////////////////////////////////
// Debug
reg ledr;
always @(posedge clk156_0)
  if (tim_1s) ledr <= ~ledr;

assign BLED_B = ledr;
assign GLED_B = ~tcp_open0;
assign RLED_B = ~rst;

endmodule
