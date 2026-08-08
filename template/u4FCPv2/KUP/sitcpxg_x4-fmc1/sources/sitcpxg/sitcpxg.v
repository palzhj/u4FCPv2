`timescale 1 ps/1 ps
//------------------------------------------------------------------------------
// File       : sitcpxg.v
// Author     : by zhj@ihep.ac.cn
//------------------------------------------------------------------------------
// Description: This is the verilog design for the Ten GigaEthernet TCP/IP core.
//              The block level wrapper for the core is instantiated and the
//              timer circuitry is created.
//------------------------------------------------------------------------------
module sitcpxg_x4 #(
  parameter         USE_CHIPSCOPE = 0,
  parameter [31: 0] BASE_IP_ADDR0 = 32'hC0A8_0A10,  // 192.168.10.16
  parameter [31: 0] BASE_IP_ADDR1 = 32'hC0A8_0B10,  // 192.168.11.16
  parameter [31: 0] BASE_IP_ADDR2 = 32'hC0A8_0C10,  // 192.168.12.16
  parameter [31: 0] BASE_IP_ADDR3 = 32'hC0A8_0D10,  // 192.168.13.16
  parameter [31: 0] MAC_IP_WIDTH = 3,
  parameter         RxBufferSize = "LongLong"       // Little-endian conversion for rxdata
  // "Byte": 8bit width, "Word": 16bit width, "LongWord": 32bit width, "LongLong": 64bit width
)(
  // System I/F
  input                  RST,            // in : System reset (Sync.)
  input                  CLK40,          // in : independent clock for DRP
  // SiTCP setting
  input    [31: 0]       REG_FPGA_VER,   // in : User logic Version (For example, the synthesized date)
  input    [31: 0]       REG_FPGA_ID,    // in : User logic ID (We recommend using the lower 4 bytes of the MAC address.)
  input    [MAC_IP_WIDTH-1:0] MAC_SELECT,
  input    [MAC_IP_WIDTH-1:0] IP_SELECT,
  output                 TIM_1US,        // out : 1 us interval, Sync to CLKOUT0
  output                 TIM_10US,       // out : 10 us interval, Sync to CLKOUT0
  output                 TIM_100US,      // out : 100 us interval, Sync to CLKOUT0
  output                 TIM_1MS,        // out : 1 ms interval, Sync to CLKOUT0
  output                 TIM_10MS,       // out : 10 ms interval, Sync to CLKOUT0
  output                 TIM_100MS,      // out : 100 ms interval, Sync to CLKOUT0
  output                 TIM_1S,         // out : 1 s interval, Sync to CLKOUT0
  output                 TIM_1M,         // out : 1 m interval, Sync to CLKOUT0
  // User I/F
  output                 CLKOUT0,        // out : 156.25 MHz BUFG clock out
  output                 CLKOUT1,        // out : 156.25 MHz BUFG clock out
  output                 CLKOUT2,        // out : 156.25 MHz BUFG clock out
  output                 CLKOUT3,        // out : 156.25 MHz BUFG clock out
  output                 SiTCP_RESET_OUT0, // out : System reset for user's module
  output                 SiTCP_RESET_OUT1, // out : System reset for user's module
  output                 SiTCP_RESET_OUT2, // out : System reset for user's module
  output                 SiTCP_RESET_OUT3, // out : System reset for user's module
  // RBCP0
  output                 RBCP_ACT0,      // out : Indicates that bus access is active.
  output    [31: 0]      RBCP_ADDR0,     // out : Address[31:0]
  output                 RBCP_WE0,       // out : Write enable
  output    [ 7: 0]      RBCP_WD0,       // out : Data[7:0]
  output                 RBCP_RE0,       // out : Read enable
  input                  RBCP_ACK0,      // in  : Access acknowledge
  input     [ 7: 0]      RBCP_RD0,       // in  : Read data[7:0]
  // RBCP1
  output                 RBCP_ACT1,      // out : Indicates that bus access is active.
  output    [31: 0]      RBCP_ADDR1,     // out : Address[31:0]
  output                 RBCP_WE1,       // out : Write enable
  output    [ 7: 0]      RBCP_WD1,       // out : Data[7:0]
  output                 RBCP_RE1,       // out : Read enable
  input                  RBCP_ACK1,      // in  : Access acknowledge
  input     [ 7: 0]      RBCP_RD1,       // in  : Read data[7:0]
  // RBCP2
  output                 RBCP_ACT2,      // out : Indicates that bus access is active.
  output    [31: 0]      RBCP_ADDR2,     // out : Address[31:0]
  output                 RBCP_WE2,       // out : Write enable
  output    [ 7: 0]      RBCP_WD2,       // out : Data[7:0]
  output                 RBCP_RE2,       // out : Read enable
  input                  RBCP_ACK2,      // in  : Access acknowledge
  input     [ 7: 0]      RBCP_RD2,       // in  : Read data[7:0]
  // RBCP3
  output                 RBCP_ACT3,      // out : Indicates that bus access is active.
  output    [31: 0]      RBCP_ADDR3,     // out : Address[31:0]
  output                 RBCP_WE3,       // out : Write enable
  output    [ 7: 0]      RBCP_WD3,       // out : Data[7:0]
  output                 RBCP_RE3,       // out : Read enable
  input                  RBCP_ACK3,      // in  : Access acknowledge
  input     [ 7: 0]      RBCP_RD3,       // in  : Read data[7:0]
  // TCP0
  input                  USER_SESSION_OPEN_REQ0,    // in : Request for opening the new session
  output                 USER_SESSION_ESTABLISHED0, // out: Establish of a session
  output                 USER_SESSION_CLOSE_REQ0,   // out: Request for closing session.
  input                  USER_SESSION_CLOSE_ACK0,   // in : Acknowledge for USER_SESSION_CLOSE_REQ.
  input     [63: 0]      USER_TX_D0,     // in : Write data
  input     [ 3: 0]      USER_TX_B0,     // in : Byte length of USER_TX_DATA (Set to 0 if not written)
  output                 USER_TX_AFULL0, // out: Request to stop TX
  input     [15: 0]      USER_RX_SIZE0,  // in : Receive buffer size (byte). Caution: Set a value of 4000 or more and (memory size-16) or less
  output                 USER_RX_CLR_ENB0, // out: Receive buffer Clear Enable
  input                  USER_RX_CLR_REQ0, // in : Receive buffer Clear Request
  input     [15: 0]      USER_RX_RADR0,  // in : Receive buffer read address in bytes (unused upper bits are set to 0)
  output    [15: 0]      USER_RX_WADR0,  // out: Receive buffer write address in bytes (lower 3 bits are not connected to memory)
  output    [ 7: 0]      USER_RX_WENB0,  // out: Receive buffer byte write enable (big endian)
  output    [63: 0]      USER_RX_WDAT0,  // out: Receive buffer write data (big endian)
  // TCP1
  input                  USER_SESSION_OPEN_REQ1,    // in : Request for opening the new session
  output                 USER_SESSION_ESTABLISHED1, // out: Establish of a session
  output                 USER_SESSION_CLOSE_REQ1,   // out: Request for closing session.
  input                  USER_SESSION_CLOSE_ACK1,   // in : Acknowledge for USER_SESSION_CLOSE_REQ.
  input     [63: 0]      USER_TX_D1,     // in : Write data
  input     [ 3: 0]      USER_TX_B1,     // in : Byte length of USER_TX_DATA (Set to 0 if not written)
  output                 USER_TX_AFULL1, // out: Request to stop TX
  input     [15: 0]      USER_RX_SIZE1,  // in : Receive buffer size (byte). Caution: Set a value of 4000 or more and (memory size-16) or less
  output                 USER_RX_CLR_ENB1, // out: Receive buffer Clear Enable
  input                  USER_RX_CLR_REQ1, // in : Receive buffer Clear Request
  input     [15: 0]      USER_RX_RADR1,  // in : Receive buffer read address in bytes (unused upper bits are set to 0)
  output    [15: 0]      USER_RX_WADR1,  // out: Receive buffer write address in bytes (lower 3 bits are not connected to memory)
  output    [ 7: 0]      USER_RX_WENB1,  // out: Receive buffer byte write enable (big endian)
  output    [63: 0]      USER_RX_WDAT1,  // out: Receive buffer write data (big endian)
  // TCP2
  input                  USER_SESSION_OPEN_REQ2,    // in : Request for opening the new session
  output                 USER_SESSION_ESTABLISHED2, // out: Establish of a session
  output                 USER_SESSION_CLOSE_REQ2,   // out: Request for closing session.
  input                  USER_SESSION_CLOSE_ACK2,   // in : Acknowledge for USER_SESSION_CLOSE_REQ.
  input     [63: 0]      USER_TX_D2,     // in : Write data
  input     [ 3: 0]      USER_TX_B2,     // in : Byte length of USER_TX_DATA (Set to 0 if not written)
  output                 USER_TX_AFULL2, // out: Request to stop TX
  input     [15: 0]      USER_RX_SIZE2,  // in : Receive buffer size (byte). Caution: Set a value of 4000 or more and (memory size-16) or less
  output                 USER_RX_CLR_ENB2, // out: Receive buffer Clear Enable
  input                  USER_RX_CLR_REQ2, // in : Receive buffer Clear Request
  input     [15: 0]      USER_RX_RADR2,  // in : Receive buffer read address in bytes (unused upper bits are set to 0)
  output    [15: 0]      USER_RX_WADR2,  // out: Receive buffer write address in bytes (lower 3 bits are not connected to memory)
  output    [ 7: 0]      USER_RX_WENB2,  // out: Receive buffer byte write enable (big endian)
  output    [63: 0]      USER_RX_WDAT2,  // out: Receive buffer write data (big endian)
  // TCP3
  input                  USER_SESSION_OPEN_REQ3,    // in : Request for opening the new session
  output                 USER_SESSION_ESTABLISHED3, // out: Establish of a session
  output                 USER_SESSION_CLOSE_REQ3,   // out: Request for closing session.
  input                  USER_SESSION_CLOSE_ACK3,   // in : Acknowledge for USER_SESSION_CLOSE_REQ.
  input     [63: 0]      USER_TX_D3,     // in : Write data
  input     [ 3: 0]      USER_TX_B3,     // in : Byte length of USER_TX_DATA (Set to 0 if not written)
  output                 USER_TX_AFULL3, // out: Request to stop TX
  input     [15: 0]      USER_RX_SIZE3,  // in : Receive buffer size (byte). Caution: Set a value of 4000 or more and (memory size-16) or less
  output                 USER_RX_CLR_ENB3, // out: Receive buffer Clear Enable
  input                  USER_RX_CLR_REQ3, // in : Receive buffer Clear Request
  input     [15: 0]      USER_RX_RADR3,  // in : Receive buffer read address in bytes (unused upper bits are set to 0)
  output    [15: 0]      USER_RX_WADR3,  // out: Receive buffer write address in bytes (lower 3 bits are not connected to memory)
  output    [ 7: 0]      USER_RX_WENB3,  // out: Receive buffer byte write enable (big endian)
  output    [63: 0]      USER_RX_WDAT3,  // out: Receive buffer write data (big endian)
  // GT interface
  input                  GTREFCLK_P,     // in : Differential +ve of reference clock for MGT: very high quality.
  input                  GTREFCLK_N,     // in : Differential -ve of reference clock for MGT: very high quality.
  output    [ 3: 0]      GT_TXP,         // out: Tx signal line
  output    [ 3: 0]      GT_TXN,         // out: Tx signal line
  input     [ 3: 0]      GT_RXP,         // in : Rx signal line
  input     [ 3: 0]      GT_RXN          // in : Rx signal line
);

// XGMII I/F
wire  [ 7: 0] xgmii_rxc_0, xgmii_rxc_1, xgmii_rxc_2, xgmii_rxc_3;
wire  [63: 0] xgmii_rxd_0, xgmii_rxd_1, xgmii_rxd_2, xgmii_rxd_3;
wire  [ 7: 0] xgmii_txc_0, xgmii_txc_1, xgmii_txc_2, xgmii_txc_3;
wire  [63: 0] xgmii_txd_0, xgmii_txd_1, xgmii_txd_2, xgmii_txd_3;
wire          xgmii_clk_0, xgmii_clk_1, xgmii_clk_2, xgmii_clk_3;

wire rst;
// async2sync_reset reset_usrclk(
//   .rst_in       (RST),
//   .clk          (xgmii_clk),
//   .rst_out      (rst)
// );
assign rst = RST;

//------------------------------------------------------------------------------
// Timer circuits (one per channel)
//------------------------------------------------------------------------------
TIMER #(
  .CLK_FREQ (8'd156)
) TIMER_0 (
  // System
  .CLK      (xgmii_clk_0),  // in : System clock
  .RST      (rst),          // in : System reset
  // Interrupts
  .TIM_1US  (TIM_1US),      // out: 1 us interval
  .TIM_10US (TIM_10US),     // out: 10 us interval
  .TIM_100US(TIM_100US),    // out: 100 us interval
  .TIM_1MS  (TIM_1MS),      // out: 1 ms interval
  .TIM_10MS (TIM_10MS),     // out: 10 ms interval
  .TIM_100MS(TIM_100MS),    // out: 100 ms interval
  .TIM_1S   (TIM_1S),       // out: 1 s interval
  .TIM_1M   (TIM_1M)        // out: 1 min interval
);

wire TIM_1US_1, TIM_1US_2, TIM_1US_3;
wire TIM_1MS_1, TIM_1MS_2, TIM_1MS_3;
wire TIM_1S_1, TIM_1S_2, TIM_1S_3;

TIMER #(
  .CLK_FREQ (8'd156)
) TIMER_1 (
  // System
  .CLK      (xgmii_clk_1),  // in : System clock
  .RST      (rst),          // in : System reset
  // Interrupts
  .TIM_1US  (TIM_1US_1),    // out: 1 us interval
  .TIM_10US (),             // out: 10 us interval
  .TIM_100US(),             // out: 100 us interval
  .TIM_1MS  (TIM_1MS_1),    // out: 1 ms interval
  .TIM_10MS (),             // out: 10 ms interval
  .TIM_100MS(),             // out: 100 ms interval
  .TIM_1S   (TIM_1S_1),     // out: 1 s interval
  .TIM_1M   ()              // out: 1 min interval
);

TIMER #(
  .CLK_FREQ (8'd156)
) TIMER_2 (
  // System
  .CLK      (xgmii_clk_2),  // in : System clock
  .RST      (rst),          // in : System reset
  // Interrupts
  .TIM_1US  (TIM_1US_2),    // out: 1 us interval
  .TIM_10US (),             // out: 10 us interval
  .TIM_100US(),             // out: 100 us interval
  .TIM_1MS  (TIM_1MS_2),    // out: 1 ms interval
  .TIM_10MS (),             // out: 10 ms interval
  .TIM_100MS(),             // out: 100 ms interval
  .TIM_1S   (TIM_1S_2),     // out: 1 s interval
  .TIM_1M   ()              // out: 1 min interval
);

TIMER #(
  .CLK_FREQ (8'd156)
) TIMER_3 (
  // System
  .CLK      (xgmii_clk_3),  // in : System clock
  .RST      (rst),          // in : System reset
  // Interrupts
  .TIM_1US  (TIM_1US_3),    // out: 1 us interval
  .TIM_10US (),             // out: 10 us interval
  .TIM_100US(),             // out: 100 us interval
  .TIM_1MS  (TIM_1MS_3),    // out: 1 ms interval
  .TIM_10MS (),             // out: 10 ms interval
  .TIM_100MS(),             // out: 100 ms interval
  .TIM_1S   (TIM_1S_3),     // out: 1 s interval
  .TIM_1M   ()              // out: 1 min interval
);

//------------------------------------------------------------------------------
//  SiTCP library
//------------------------------------------------------------------------------
wire [47: 0] TCP_SERVER_MAC0, TCP_SERVER_MAC1, TCP_SERVER_MAC2, TCP_SERVER_MAC3;
wire [31: 0] TCP_SERVER_ADDR0, TCP_SERVER_ADDR1, TCP_SERVER_ADDR2, TCP_SERVER_ADDR3;
wire [15: 0] TCP_SERVER_PORT0, TCP_SERVER_PORT1, TCP_SERVER_PORT2, TCP_SERVER_PORT3;
wire [ 7: 0] swap_rx_wenb0, swap_rx_wenb1, swap_rx_wenb2, swap_rx_wenb3;
wire [63: 0] swap_rx_wdat0, swap_rx_wdat1, swap_rx_wdat2, swap_rx_wdat3;

//------------------------------------------------------------------------------
// SiTCPXG channel 0
//------------------------------------------------------------------------------
SiTCPXG_XCAUP_128K_V4 SiTCPXG_XC_0 (
  .REG_FPGA_VER            (REG_FPGA_VER),          // in : User logic Version (For example, the synthesized date)
  .REG_FPGA_ID             (REG_FPGA_ID),           // in : User logic ID (We recommend using the lower 4 bytes of the MAC address.)
  // System I/F
  .XGMII_CLOCK             (xgmii_clk_0),           // in : XGMII clock
  .RSTs                    (rst),                   // in : System reset (Sync.)
  .TIM_1US                 (TIM_1US),               // in : 1 us interval pulse
  .TIM_1MS                 (TIM_1MS),               // in : 1 ms interval pulse
  .TIM_1S                  (TIM_1S),                // in : 1 s interval pulse
  // XGMII I/F
  .XGMII_RXC               (xgmii_rxc_0),           // in : Rx control[7:0]
  .XGMII_RXD               (xgmii_rxd_0),           // in : Rx data[63:0]
  .XGMII_TXC               (xgmii_txc_0),           // out: Control bits[7:0]
  .XGMII_TXD               (xgmii_txd_0),           // out: Data[63:0]
  // 93C46 I/F
  .EEPROM_CS               (),                      // out: Chip select
  .EEPROM_SK               (),                      // out: Serial data clock
  .EEPROM_DI               (),                      // out: Serial write data
  .EEPROM_DO               (1'b0),                  // in : Serial read data
  // Configuration parameters
  .FORCE_DEFAULTn          (1'b0),                  // in : Force to set default values
  .MY_MAC_ADDR             (),                      // out: My IP MAC Address[47:0]
  .MY_IP_ADDR              (BASE_IP_ADDR0 + IP_SELECT), // in : My IP address[31:0]
  .IP_ADDR_DEFAULT         (),                      // out: Default value for MY_IP_ADDR[31:0]
  .MY_TCP_PORT             (16'd24),                // in : My TCP port[15:0]
  .TCP_PORT_DEFAULT        (),                      // out: Default value for my TCP MY_TCP_PORT[15:0]
  .MY_RBCP_PORT            (16'd4660),              // in : My UDP RBCP-port[15:0]
  .RBCP_PORT_DEFAULT       (),                      // out: Default value for my UDP RBCP-port#[15:0]
  .TCP_SERVER_MAC_IN       (TCP_SERVER_MAC0),       // in : Client mode, Server MAC address[47:0]
  .TCP_SERVER_MAC_DEFAULT  (TCP_SERVER_MAC0),       // out: Default value for the server's MAC address
  .TCP_SERVER_ADDR_IN      (TCP_SERVER_ADDR0),      // in : Client mode, Server IP address[31:0]
  .TCP_SERVER_ADDR_DEFAULT (TCP_SERVER_ADDR0),      // out: Default value for the server's IP address[31:0]
  .TCP_SERVER_PORT_IN      (TCP_SERVER_PORT0),      // in : Client mode, Server waiting port#[15:0]
  .TCP_SERVER_PORT_DEFAULT (TCP_SERVER_PORT0),      // out: Default value for the server port#[15:0]
  // User I/F
  .SiTCP_RESET_OUT         (SiTCP_RESET_OUT0),      // out: System reset for user's module
  // RBCP
  .RBCP_ACT                (RBCP_ACT0),             // out: Indicates that bus access is active.
  .RBCP_ADDR               (RBCP_ADDR0),            // out: Address[31:0]
  .RBCP_WE                 (RBCP_WE0),              // out: Write enable
  .RBCP_WD                 (RBCP_WD0),              // out: Data[7:0]
  .RBCP_RE                 (RBCP_RE0),              // out: Read enable
  .RBCP_ACK                (RBCP_ACK0),             // in : Access acknowledge
  .RBCP_RD                 (RBCP_RD0),              // in : Read data[7:0]
  // TCP
  .USER_SESSION_OPEN_REQ   (USER_SESSION_OPEN_REQ0), // in : Request for opening the new session
  .USER_SESSION_ESTABLISHED(USER_SESSION_ESTABLISHED0), // out: Establish of a session
  .USER_SESSION_CLOSE_REQ  (USER_SESSION_CLOSE_REQ0), // out: Request for closing session.
  .USER_SESSION_CLOSE_ACK  (USER_SESSION_CLOSE_ACK0), // in : Acknowledge for USER_SESSION_CLOSE_REQ.
  .USER_TX_D               (USER_TX_D0),            // in : Write data
  .USER_TX_B               (USER_TX_B0),            // in : Byte length of USER_TX_DATA (Set to 0 if not written)
  .USER_TX_AFULL           (USER_TX_AFULL0),        // out: Request to stop TX
  .USER_RX_SIZE            (USER_RX_SIZE0),         // in : Receive buffer size (byte). Caution: Set a value of 4000 or more and (memory size-16) or less
  .USER_RX_CLR_ENB         (USER_RX_CLR_ENB0),      // out: Receive buffer Clear Enable
  .USER_RX_CLR_REQ         (USER_RX_CLR_REQ0),      // in : Receive buffer Clear Request
  .USER_RX_RADR            (USER_RX_RADR0),         // in : Receive buffer read address in bytes (unused upper bits are set to 0)
  .USER_RX_WADR            (USER_RX_WADR0),         // out: Receive buffer write address in bytes (lower 3 bits are not connected to memory)
  .USER_RX_WENB            (swap_rx_wenb0),         // out: Receive buffer byte write enable (big endian)
  .USER_RX_WDAT            (swap_rx_wdat0)          // out: Receive buffer write data (big endian)
);

// Little-endian conversion
generate
  if (RxBufferSize == "LongLong") begin
    assign USER_RX_WENB0[ 7:0] = swap_rx_wenb0[ 7:0];
    assign USER_RX_WDAT0[63:0] = swap_rx_wdat0[63:0];
  end else if (RxBufferSize == "LongWord") begin
    assign USER_RX_WENB0[ 3: 0] = swap_rx_wenb0[ 7: 4];
    assign USER_RX_WDAT0[31: 0] = swap_rx_wdat0[63:32];
    assign USER_RX_WENB0[ 7: 4] = swap_rx_wenb0[ 3: 0];
    assign USER_RX_WDAT0[63:32] = swap_rx_wdat0[31: 0];
  end else if (RxBufferSize == "Word") begin
    assign USER_RX_WENB0[ 1: 0] = swap_rx_wenb0[ 7: 6];
    assign USER_RX_WDAT0[15: 0] = swap_rx_wdat0[63:48];
    assign USER_RX_WENB0[ 3: 2] = swap_rx_wenb0[ 5: 4];
    assign USER_RX_WDAT0[31:16] = swap_rx_wdat0[47:32];
    assign USER_RX_WENB0[ 5: 4] = swap_rx_wenb0[ 3: 2];
    assign USER_RX_WDAT0[47:32] = swap_rx_wdat0[31:16];
    assign USER_RX_WENB0[ 7: 6] = swap_rx_wenb0[ 1: 0];
    assign USER_RX_WDAT0[63:48] = swap_rx_wdat0[15: 0];
  end else if (RxBufferSize == "Byte") begin
    assign USER_RX_WENB0[0]      = swap_rx_wenb0[7];
    assign USER_RX_WDAT0[ 7: 0]  = swap_rx_wdat0[63:56];
    assign USER_RX_WENB0[1]      = swap_rx_wenb0[6];
    assign USER_RX_WDAT0[15: 8]  = swap_rx_wdat0[55:48];
    assign USER_RX_WENB0[2]      = swap_rx_wenb0[5];
    assign USER_RX_WDAT0[23:16]  = swap_rx_wdat0[47:40];
    assign USER_RX_WENB0[3]      = swap_rx_wenb0[4];
    assign USER_RX_WDAT0[31:24]  = swap_rx_wdat0[39:32];
    assign USER_RX_WENB0[4]      = swap_rx_wenb0[3];
    assign USER_RX_WDAT0[39:32]  = swap_rx_wdat0[31:24];
    assign USER_RX_WENB0[5]      = swap_rx_wenb0[2];
    assign USER_RX_WDAT0[47:40]  = swap_rx_wdat0[23:16];
    assign USER_RX_WENB0[6]      = swap_rx_wenb0[1];
    assign USER_RX_WDAT0[55:48]  = swap_rx_wdat0[15: 8];
    assign USER_RX_WENB0[7]      = swap_rx_wenb0[0];
    assign USER_RX_WDAT0[63:56]  = swap_rx_wdat0[ 7: 0];
  end
endgenerate

//------------------------------------------------------------------------------
// SiTCPXG channel 1
//------------------------------------------------------------------------------
SiTCPXG_XCAUP_128K_V4 SiTCPXG_XC_1 (
  .REG_FPGA_VER            (REG_FPGA_VER),          // in : User logic Version (For example, the synthesized date)
  .REG_FPGA_ID             (REG_FPGA_ID),           // in : User logic ID (We recommend using the lower 4 bytes of the MAC address.)
  // System I/F
  .XGMII_CLOCK             (xgmii_clk_1),           // in : XGMII clock
  .RSTs                    (rst),                   // in : System reset (Sync.)
  .TIM_1US                 (TIM_1US_1),             // in : 1 us interval pulse
  .TIM_1MS                 (TIM_1MS_1),             // in : 1 ms interval pulse
  .TIM_1S                  (TIM_1S_1),              // in : 1 s interval pulse
  // XGMII I/F
  .XGMII_RXC               (xgmii_rxc_1),           // in : Rx control[7:0]
  .XGMII_RXD               (xgmii_rxd_1),           // in : Rx data[63:0]
  .XGMII_TXC               (xgmii_txc_1),           // out: Control bits[7:0]
  .XGMII_TXD               (xgmii_txd_1),           // out: Data[63:0]
  // 93C46 I/F
  .EEPROM_CS               (),                      // out: Chip select
  .EEPROM_SK               (),                      // out: Serial data clock
  .EEPROM_DI               (),                      // out: Serial write data
  .EEPROM_DO               (1'b0),                  // in : Serial read data
  // Configuration parameters
  .FORCE_DEFAULTn          (1'b0),                  // in : Force to set default values
  .MY_MAC_ADDR             (),                      // out: My IP MAC Address[47:0]
  .MY_IP_ADDR              (BASE_IP_ADDR1 + IP_SELECT), // in : My IP address[31:0]
  .IP_ADDR_DEFAULT         (),                      // out: Default value for MY_IP_ADDR[31:0]
  .MY_TCP_PORT             (16'd24),                // in : My TCP port[15:0]
  .TCP_PORT_DEFAULT        (),                      // out: Default value for my TCP MY_TCP_PORT[15:0]
  .MY_RBCP_PORT            (16'd4660),              // in : My UDP RBCP-port[15:0]
  .RBCP_PORT_DEFAULT       (),                      // out: Default value for my UDP RBCP-port#[15:0]
  .TCP_SERVER_MAC_IN       (TCP_SERVER_MAC1),       // in : Client mode, Server MAC address[47:0]
  .TCP_SERVER_MAC_DEFAULT  (TCP_SERVER_MAC1),       // out: Default value for the server's MAC address
  .TCP_SERVER_ADDR_IN      (TCP_SERVER_ADDR1),      // in : Client mode, Server IP address[31:0]
  .TCP_SERVER_ADDR_DEFAULT (TCP_SERVER_ADDR1),      // out: Default value for the server's IP address[31:0]
  .TCP_SERVER_PORT_IN      (TCP_SERVER_PORT1),      // in : Client mode, Server waiting port#[15:0]
  .TCP_SERVER_PORT_DEFAULT (TCP_SERVER_PORT1),      // out: Default value for the server port#[15:0]
  // User I/F
  .SiTCP_RESET_OUT         (SiTCP_RESET_OUT1),      // out: System reset for user's module
  // RBCP
  .RBCP_ACT                (RBCP_ACT1),             // out: Indicates that bus access is active.
  .RBCP_ADDR               (RBCP_ADDR1),            // out: Address[31:0]
  .RBCP_WE                 (RBCP_WE1),              // out: Write enable
  .RBCP_WD                 (RBCP_WD1),              // out: Data[7:0]
  .RBCP_RE                 (RBCP_RE1),              // out: Read enable
  .RBCP_ACK                (RBCP_ACK1),             // in : Access acknowledge
  .RBCP_RD                 (RBCP_RD1),              // in : Read data[7:0]
  // TCP
  .USER_SESSION_OPEN_REQ   (USER_SESSION_OPEN_REQ1), // in : Request for opening the new session
  .USER_SESSION_ESTABLISHED(USER_SESSION_ESTABLISHED1), // out: Establish of a session
  .USER_SESSION_CLOSE_REQ  (USER_SESSION_CLOSE_REQ1), // out: Request for closing session.
  .USER_SESSION_CLOSE_ACK  (USER_SESSION_CLOSE_ACK1), // in : Acknowledge for USER_SESSION_CLOSE_REQ.
  .USER_TX_D               (USER_TX_D1),            // in : Write data
  .USER_TX_B               (USER_TX_B1),            // in : Byte length of USER_TX_DATA (Set to 0 if not written)
  .USER_TX_AFULL           (USER_TX_AFULL1),        // out: Request to stop TX
  .USER_RX_SIZE            (USER_RX_SIZE1),         // in : Receive buffer size (byte). Caution: Set a value of 4000 or more and (memory size-16) or less
  .USER_RX_CLR_ENB         (USER_RX_CLR_ENB1),      // out: Receive buffer Clear Enable
  .USER_RX_CLR_REQ         (USER_RX_CLR_REQ1),      // in : Receive buffer Clear Request
  .USER_RX_RADR            (USER_RX_RADR1),         // in : Receive buffer read address in bytes (unused upper bits are set to 0)
  .USER_RX_WADR            (USER_RX_WADR1),         // out: Receive buffer write address in bytes (lower 3 bits are not connected to memory)
  .USER_RX_WENB            (swap_rx_wenb1),         // out: Receive buffer byte write enable (big endian)
  .USER_RX_WDAT            (swap_rx_wdat1)          // out: Receive buffer write data (big endian)
);

// Little-endian conversion
generate
  if (RxBufferSize == "LongLong") begin
    assign USER_RX_WENB1[ 7:0] = swap_rx_wenb1[ 7:0];
    assign USER_RX_WDAT1[63:0] = swap_rx_wdat1[63:0];
  end else if (RxBufferSize == "LongWord") begin
    assign USER_RX_WENB1[ 3: 0] = swap_rx_wenb1[ 7: 4];
    assign USER_RX_WDAT1[31: 0] = swap_rx_wdat1[63:32];
    assign USER_RX_WENB1[ 7: 4] = swap_rx_wenb1[ 3: 0];
    assign USER_RX_WDAT1[63:32] = swap_rx_wdat1[31: 0];
  end else if (RxBufferSize == "Word") begin
    assign USER_RX_WENB1[ 1: 0] = swap_rx_wenb1[ 7: 6];
    assign USER_RX_WDAT1[15: 0] = swap_rx_wdat1[63:48];
    assign USER_RX_WENB1[ 3: 2] = swap_rx_wenb1[ 5: 4];
    assign USER_RX_WDAT1[31:16] = swap_rx_wdat1[47:32];
    assign USER_RX_WENB1[ 5: 4] = swap_rx_wenb1[ 3: 2];
    assign USER_RX_WDAT1[47:32] = swap_rx_wdat1[31:16];
    assign USER_RX_WENB1[ 7: 6] = swap_rx_wenb1[ 1: 0];
    assign USER_RX_WDAT1[63:48] = swap_rx_wdat1[15: 0];
  end else if (RxBufferSize == "Byte") begin
    assign USER_RX_WENB1[0]      = swap_rx_wenb1[7];
    assign USER_RX_WDAT1[ 7: 0]  = swap_rx_wdat1[63:56];
    assign USER_RX_WENB1[1]      = swap_rx_wenb1[6];
    assign USER_RX_WDAT1[15: 8]  = swap_rx_wdat1[55:48];
    assign USER_RX_WENB1[2]      = swap_rx_wenb1[5];
    assign USER_RX_WDAT1[23:16]  = swap_rx_wdat1[47:40];
    assign USER_RX_WENB1[3]      = swap_rx_wenb1[4];
    assign USER_RX_WDAT1[31:24]  = swap_rx_wdat1[39:32];
    assign USER_RX_WENB1[4]      = swap_rx_wenb1[3];
    assign USER_RX_WDAT1[39:32]  = swap_rx_wdat1[31:24];
    assign USER_RX_WENB1[5]      = swap_rx_wenb1[2];
    assign USER_RX_WDAT1[47:40]  = swap_rx_wdat1[23:16];
    assign USER_RX_WENB1[6]      = swap_rx_wenb1[1];
    assign USER_RX_WDAT1[55:48]  = swap_rx_wdat1[15: 8];
    assign USER_RX_WENB1[7]      = swap_rx_wenb1[0];
    assign USER_RX_WDAT1[63:56]  = swap_rx_wdat1[ 7: 0];
  end
endgenerate

//------------------------------------------------------------------------------
// SiTCPXG channel 2
//------------------------------------------------------------------------------
SiTCPXG_XCAUP_128K_V4 SiTCPXG_XC_2 (
  .REG_FPGA_VER            (REG_FPGA_VER),          // in : User logic Version (For example, the synthesized date)
  .REG_FPGA_ID             (REG_FPGA_ID),           // in : User logic ID (We recommend using the lower 4 bytes of the MAC address.)
  // System I/F
  .XGMII_CLOCK             (xgmii_clk_2),           // in : XGMII clock
  .RSTs                    (rst),                   // in : System reset (Sync.)
  .TIM_1US                 (TIM_1US_2),             // in : 1 us interval pulse
  .TIM_1MS                 (TIM_1MS_2),             // in : 1 ms interval pulse
  .TIM_1S                  (TIM_1S_2),              // in : 1 s interval pulse
  // XGMII I/F
  .XGMII_RXC               (xgmii_rxc_2),           // in : Rx control[7:0]
  .XGMII_RXD               (xgmii_rxd_2),           // in : Rx data[63:0]
  .XGMII_TXC               (xgmii_txc_2),           // out: Control bits[7:0]
  .XGMII_TXD               (xgmii_txd_2),           // out: Data[63:0]
  // 93C46 I/F
  .EEPROM_CS               (),                      // out: Chip select
  .EEPROM_SK               (),                      // out: Serial data clock
  .EEPROM_DI               (),                      // out: Serial write data
  .EEPROM_DO               (1'b0),                  // in : Serial read data
  // Configuration parameters
  .FORCE_DEFAULTn          (1'b0),                  // in : Force to set default values
  .MY_MAC_ADDR             (),                      // out: My IP MAC Address[47:0]
  .MY_IP_ADDR              (BASE_IP_ADDR2 + IP_SELECT), // in : My IP address[31:0]
  .IP_ADDR_DEFAULT         (),                      // out: Default value for MY_IP_ADDR[31:0]
  .MY_TCP_PORT             (16'd24),                // in : My TCP port[15:0]
  .TCP_PORT_DEFAULT        (),                      // out: Default value for my TCP MY_TCP_PORT[15:0]
  .MY_RBCP_PORT            (16'd4660),              // in : My UDP RBCP-port[15:0]
  .RBCP_PORT_DEFAULT       (),                      // out: Default value for my UDP RBCP-port#[15:0]
  .TCP_SERVER_MAC_IN       (TCP_SERVER_MAC2),       // in : Client mode, Server MAC address[47:0]
  .TCP_SERVER_MAC_DEFAULT  (TCP_SERVER_MAC2),       // out: Default value for the server's MAC address
  .TCP_SERVER_ADDR_IN      (TCP_SERVER_ADDR2),      // in : Client mode, Server IP address[31:0]
  .TCP_SERVER_ADDR_DEFAULT (TCP_SERVER_ADDR2),      // out: Default value for the server's IP address[31:0]
  .TCP_SERVER_PORT_IN      (TCP_SERVER_PORT2),      // in : Client mode, Server waiting port#[15:0]
  .TCP_SERVER_PORT_DEFAULT (TCP_SERVER_PORT2),      // out: Default value for the server port#[15:0]
  // User I/F
  .SiTCP_RESET_OUT         (SiTCP_RESET_OUT2),      // out: System reset for user's module
  // RBCP
  .RBCP_ACT                (RBCP_ACT2),             // out: Indicates that bus access is active.
  .RBCP_ADDR               (RBCP_ADDR2),            // out: Address[31:0]
  .RBCP_WE                 (RBCP_WE2),              // out: Write enable
  .RBCP_WD                 (RBCP_WD2),              // out: Data[7:0]
  .RBCP_RE                 (RBCP_RE2),              // out: Read enable
  .RBCP_ACK                (RBCP_ACK2),             // in : Access acknowledge
  .RBCP_RD                 (RBCP_RD2),              // in : Read data[7:0]
  // TCP
  .USER_SESSION_OPEN_REQ   (USER_SESSION_OPEN_REQ2), // in : Request for opening the new session
  .USER_SESSION_ESTABLISHED(USER_SESSION_ESTABLISHED2), // out: Establish of a session
  .USER_SESSION_CLOSE_REQ  (USER_SESSION_CLOSE_REQ2), // out: Request for closing session.
  .USER_SESSION_CLOSE_ACK  (USER_SESSION_CLOSE_ACK2), // in : Acknowledge for USER_SESSION_CLOSE_REQ.
  .USER_TX_D               (USER_TX_D2),            // in : Write data
  .USER_TX_B               (USER_TX_B2),            // in : Byte length of USER_TX_DATA (Set to 0 if not written)
  .USER_TX_AFULL           (USER_TX_AFULL2),        // out: Request to stop TX
  .USER_RX_SIZE            (USER_RX_SIZE2),         // in : Receive buffer size (byte). Caution: Set a value of 4000 or more and (memory size-16) or less
  .USER_RX_CLR_ENB         (USER_RX_CLR_ENB2),      // out: Receive buffer Clear Enable
  .USER_RX_CLR_REQ         (USER_RX_CLR_REQ2),      // in : Receive buffer Clear Request
  .USER_RX_RADR            (USER_RX_RADR2),         // in : Receive buffer read address in bytes (unused upper bits are set to 0)
  .USER_RX_WADR            (USER_RX_WADR2),         // out: Receive buffer write address in bytes (lower 3 bits are not connected to memory)
  .USER_RX_WENB            (swap_rx_wenb2),         // out: Receive buffer byte write enable (big endian)
  .USER_RX_WDAT            (swap_rx_wdat2)          // out: Receive buffer write data (big endian)
);

// Little-endian conversion
generate
  if (RxBufferSize == "LongLong") begin
    assign USER_RX_WENB2[ 7:0] = swap_rx_wenb2[ 7:0];
    assign USER_RX_WDAT2[63:0] = swap_rx_wdat2[63:0];
  end else if (RxBufferSize == "LongWord") begin
    assign USER_RX_WENB2[ 3: 0] = swap_rx_wenb2[ 7: 4];
    assign USER_RX_WDAT2[31: 0] = swap_rx_wdat2[63:32];
    assign USER_RX_WENB2[ 7: 4] = swap_rx_wenb2[ 3: 0];
    assign USER_RX_WDAT2[63:32] = swap_rx_wdat2[31: 0];
  end else if (RxBufferSize == "Word") begin
    assign USER_RX_WENB2[ 1: 0] = swap_rx_wenb2[ 7: 6];
    assign USER_RX_WDAT2[15: 0] = swap_rx_wdat2[63:48];
    assign USER_RX_WENB2[ 3: 2] = swap_rx_wenb2[ 5: 4];
    assign USER_RX_WDAT2[31:16] = swap_rx_wdat2[47:32];
    assign USER_RX_WENB2[ 5: 4] = swap_rx_wenb2[ 3: 2];
    assign USER_RX_WDAT2[47:32] = swap_rx_wdat2[31:16];
    assign USER_RX_WENB2[ 7: 6] = swap_rx_wenb2[ 1: 0];
    assign USER_RX_WDAT2[63:48] = swap_rx_wdat2[15: 0];
  end else if (RxBufferSize == "Byte") begin
    assign USER_RX_WENB2[0]      = swap_rx_wenb2[7];
    assign USER_RX_WDAT2[ 7: 0]  = swap_rx_wdat2[63:56];
    assign USER_RX_WENB2[1]      = swap_rx_wenb2[6];
    assign USER_RX_WDAT2[15: 8]  = swap_rx_wdat2[55:48];
    assign USER_RX_WENB2[2]      = swap_rx_wenb2[5];
    assign USER_RX_WDAT2[23:16]  = swap_rx_wdat2[47:40];
    assign USER_RX_WENB2[3]      = swap_rx_wenb2[4];
    assign USER_RX_WDAT2[31:24]  = swap_rx_wdat2[39:32];
    assign USER_RX_WENB2[4]      = swap_rx_wenb2[3];
    assign USER_RX_WDAT2[39:32]  = swap_rx_wdat2[31:24];
    assign USER_RX_WENB2[5]      = swap_rx_wenb2[2];
    assign USER_RX_WDAT2[47:40]  = swap_rx_wdat2[23:16];
    assign USER_RX_WENB2[6]      = swap_rx_wenb2[1];
    assign USER_RX_WDAT2[55:48]  = swap_rx_wdat2[15: 8];
    assign USER_RX_WENB2[7]      = swap_rx_wenb2[0];
    assign USER_RX_WDAT2[63:56]  = swap_rx_wdat2[ 7: 0];
  end
endgenerate

//------------------------------------------------------------------------------
// SiTCPXG channel 3
//------------------------------------------------------------------------------
SiTCPXG_XCAUP_128K_V4 SiTCPXG_XC_3 (
  .REG_FPGA_VER            (REG_FPGA_VER),          // in : User logic Version (For example, the synthesized date)
  .REG_FPGA_ID             (REG_FPGA_ID),           // in : User logic ID (We recommend using the lower 4 bytes of the MAC address.)
  // System I/F
  .XGMII_CLOCK             (xgmii_clk_3),           // in : XGMII clock
  .RSTs                    (rst),                   // in : System reset (Sync.)
  .TIM_1US                 (TIM_1US_3),             // in : 1 us interval pulse
  .TIM_1MS                 (TIM_1MS_3),             // in : 1 ms interval pulse
  .TIM_1S                  (TIM_1S_3),              // in : 1 s interval pulse
  // XGMII I/F
  .XGMII_RXC               (xgmii_rxc_3),           // in : Rx control[7:0]
  .XGMII_RXD               (xgmii_rxd_3),           // in : Rx data[63:0]
  .XGMII_TXC               (xgmii_txc_3),           // out: Control bits[7:0]
  .XGMII_TXD               (xgmii_txd_3),           // out: Data[63:0]
  // 93C46 I/F
  .EEPROM_CS               (),                      // out: Chip select
  .EEPROM_SK               (),                      // out: Serial data clock
  .EEPROM_DI               (),                      // out: Serial write data
  .EEPROM_DO               (1'b0),                  // in : Serial read data
  // Configuration parameters
  .FORCE_DEFAULTn          (1'b0),                  // in : Force to set default values
  .MY_MAC_ADDR             (),                      // out: My IP MAC Address[47:0]
  .MY_IP_ADDR              (BASE_IP_ADDR3 + IP_SELECT), // in : My IP address[31:0]
  .IP_ADDR_DEFAULT         (),                      // out: Default value for MY_IP_ADDR[31:0]
  .MY_TCP_PORT             (16'd24),                // in : My TCP port[15:0]
  .TCP_PORT_DEFAULT        (),                      // out: Default value for my TCP MY_TCP_PORT[15:0]
  .MY_RBCP_PORT            (16'd4660),              // in : My UDP RBCP-port[15:0]
  .RBCP_PORT_DEFAULT       (),                      // out: Default value for my UDP RBCP-port#[15:0]
  .TCP_SERVER_MAC_IN       (TCP_SERVER_MAC3),       // in : Client mode, Server MAC address[47:0]
  .TCP_SERVER_MAC_DEFAULT  (TCP_SERVER_MAC3),       // out: Default value for the server's MAC address
  .TCP_SERVER_ADDR_IN      (TCP_SERVER_ADDR3),      // in : Client mode, Server IP address[31:0]
  .TCP_SERVER_ADDR_DEFAULT (TCP_SERVER_ADDR3),      // out: Default value for the server's IP address[31:0]
  .TCP_SERVER_PORT_IN      (TCP_SERVER_PORT3),      // in : Client mode, Server waiting port#[15:0]
  .TCP_SERVER_PORT_DEFAULT (TCP_SERVER_PORT3),      // out: Default value for the server port#[15:0]
  // User I/F
  .SiTCP_RESET_OUT         (SiTCP_RESET_OUT3),      // out: System reset for user's module
  // RBCP
  .RBCP_ACT                (RBCP_ACT3),             // out: Indicates that bus access is active.
  .RBCP_ADDR               (RBCP_ADDR3),            // out: Address[31:0]
  .RBCP_WE                 (RBCP_WE3),              // out: Write enable
  .RBCP_WD                 (RBCP_WD3),              // out: Data[7:0]
  .RBCP_RE                 (RBCP_RE3),              // out: Read enable
  .RBCP_ACK                (RBCP_ACK3),             // in : Access acknowledge
  .RBCP_RD                 (RBCP_RD3),              // in : Read data[7:0]
  // TCP
  .USER_SESSION_OPEN_REQ   (USER_SESSION_OPEN_REQ3), // in : Request for opening the new session
  .USER_SESSION_ESTABLISHED(USER_SESSION_ESTABLISHED3), // out: Establish of a session
  .USER_SESSION_CLOSE_REQ  (USER_SESSION_CLOSE_REQ3), // out: Request for closing session.
  .USER_SESSION_CLOSE_ACK  (USER_SESSION_CLOSE_ACK3), // in : Acknowledge for USER_SESSION_CLOSE_REQ.
  .USER_TX_D               (USER_TX_D3),            // in : Write data
  .USER_TX_B               (USER_TX_B3),            // in : Byte length of USER_TX_DATA (Set to 0 if not written)
  .USER_TX_AFULL           (USER_TX_AFULL3),        // out: Request to stop TX
  .USER_RX_SIZE            (USER_RX_SIZE3),         // in : Receive buffer size (byte). Caution: Set a value of 4000 or more and (memory size-16) or less
  .USER_RX_CLR_ENB         (USER_RX_CLR_ENB3),      // out: Receive buffer Clear Enable
  .USER_RX_CLR_REQ         (USER_RX_CLR_REQ3),      // in : Receive buffer Clear Request
  .USER_RX_RADR            (USER_RX_RADR3),         // in : Receive buffer read address in bytes (unused upper bits are set to 0)
  .USER_RX_WADR            (USER_RX_WADR3),         // out: Receive buffer write address in bytes (lower 3 bits are not connected to memory)
  .USER_RX_WENB            (swap_rx_wenb3),         // out: Receive buffer byte write enable (big endian)
  .USER_RX_WDAT            (swap_rx_wdat3)          // out: Receive buffer write data (big endian)
);

// Little-endian conversion
generate
  if (RxBufferSize == "LongLong") begin
    assign USER_RX_WENB3[ 7:0] = swap_rx_wenb3[ 7:0];
    assign USER_RX_WDAT3[63:0] = swap_rx_wdat3[63:0];
  end else if (RxBufferSize == "LongWord") begin
    assign USER_RX_WENB3[ 3: 0] = swap_rx_wenb3[ 7: 4];
    assign USER_RX_WDAT3[31: 0] = swap_rx_wdat3[63:32];
    assign USER_RX_WENB3[ 7: 4] = swap_rx_wenb3[ 3: 0];
    assign USER_RX_WDAT3[63:32] = swap_rx_wdat3[31: 0];
  end else if (RxBufferSize == "Word") begin
    assign USER_RX_WENB3[ 1: 0] = swap_rx_wenb3[ 7: 6];
    assign USER_RX_WDAT3[15: 0] = swap_rx_wdat3[63:48];
    assign USER_RX_WENB3[ 3: 2] = swap_rx_wenb3[ 5: 4];
    assign USER_RX_WDAT3[31:16] = swap_rx_wdat3[47:32];
    assign USER_RX_WENB3[ 5: 4] = swap_rx_wenb3[ 3: 2];
    assign USER_RX_WDAT3[47:32] = swap_rx_wdat3[31:16];
    assign USER_RX_WENB3[ 7: 6] = swap_rx_wenb3[ 1: 0];
    assign USER_RX_WDAT3[63:48] = swap_rx_wdat3[15: 0];
  end else if (RxBufferSize == "Byte") begin
    assign USER_RX_WENB3[0]      = swap_rx_wenb3[7];
    assign USER_RX_WDAT3[ 7: 0]  = swap_rx_wdat3[63:56];
    assign USER_RX_WENB3[1]      = swap_rx_wenb3[6];
    assign USER_RX_WDAT3[15: 8]  = swap_rx_wdat3[55:48];
    assign USER_RX_WENB3[2]      = swap_rx_wenb3[5];
    assign USER_RX_WDAT3[23:16]  = swap_rx_wdat3[47:40];
    assign USER_RX_WENB3[3]      = swap_rx_wenb3[4];
    assign USER_RX_WDAT3[31:24]  = swap_rx_wdat3[39:32];
    assign USER_RX_WENB3[4]      = swap_rx_wenb3[3];
    assign USER_RX_WDAT3[39:32]  = swap_rx_wdat3[31:24];
    assign USER_RX_WENB3[5]      = swap_rx_wenb3[2];
    assign USER_RX_WDAT3[47:40]  = swap_rx_wdat3[23:16];
    assign USER_RX_WENB3[6]      = swap_rx_wenb3[1];
    assign USER_RX_WDAT3[55:48]  = swap_rx_wdat3[15: 8];
    assign USER_RX_WENB3[7]      = swap_rx_wenb3[0];
    assign USER_RX_WDAT3[63:56]  = swap_rx_wdat3[ 7: 0];
  end
endgenerate

//------------------------------------------------------------------------------
// Clock connections
//------------------------------------------------------------------------------
wire rx_clk_out_0, rx_clk_out_1, rx_clk_out_2, rx_clk_out_3;
wire tx_mii_clk_0, tx_mii_clk_1, tx_mii_clk_2, tx_mii_clk_3;

assign xgmii_clk_0 = tx_mii_clk_0;
assign xgmii_clk_1 = tx_mii_clk_1;
assign xgmii_clk_2 = tx_mii_clk_2;
assign xgmii_clk_3 = tx_mii_clk_3;
// assign xgmii_clk_0 = rx_clk_out_0;
// assign xgmii_clk_1 = rx_clk_out_1;
// assign xgmii_clk_2 = rx_clk_out_2;
// assign xgmii_clk_3 = rx_clk_out_3;

assign CLKOUT0 = xgmii_clk_0;
assign CLKOUT1 = xgmii_clk_1;
assign CLKOUT2 = xgmii_clk_2;
assign CLKOUT3 = xgmii_clk_3;

// RX Status Signals
wire stat_rx_block_lock_0, stat_rx_block_lock_1, stat_rx_block_lock_2, stat_rx_block_lock_3;
wire stat_rx_framing_err_valid_0, stat_rx_framing_err_valid_1, stat_rx_framing_err_valid_2, stat_rx_framing_err_valid_3;
wire stat_rx_framing_err_0, stat_rx_framing_err_1, stat_rx_framing_err_2, stat_rx_framing_err_3;
wire stat_rx_hi_ber_0, stat_rx_hi_ber_1, stat_rx_hi_ber_2, stat_rx_hi_ber_3;
wire stat_rx_valid_ctrl_code_0, stat_rx_valid_ctrl_code_1, stat_rx_valid_ctrl_code_2, stat_rx_valid_ctrl_code_3;
wire stat_rx_bad_code_0, stat_rx_bad_code_1, stat_rx_bad_code_2, stat_rx_bad_code_3;
wire stat_rx_bad_code_valid_0, stat_rx_bad_code_valid_1, stat_rx_bad_code_valid_2, stat_rx_bad_code_valid_3;
wire stat_rx_error_valid_0, stat_rx_error_valid_1, stat_rx_error_valid_2, stat_rx_error_valid_3;
wire [7:0] stat_rx_error_0, stat_rx_error_1, stat_rx_error_2, stat_rx_error_3;
wire stat_rx_fifo_error_0, stat_rx_fifo_error_1, stat_rx_fifo_error_2, stat_rx_fifo_error_3;
wire stat_rx_local_fault_0, stat_rx_local_fault_1, stat_rx_local_fault_2, stat_rx_local_fault_3;
wire stat_rx_status_0, stat_rx_status_1, stat_rx_status_2, stat_rx_status_3;
// TX Status Signals
wire stat_tx_local_fault_0, stat_tx_local_fault_1, stat_tx_local_fault_2, stat_tx_local_fault_3;
// GT Status
wire gtpowergood_out_0, gtpowergood_out_1, gtpowergood_out_2, gtpowergood_out_3;

//------------------------------------------------------------------------------
// 10G Ethernet PCS/PMA (X4)
//------------------------------------------------------------------------------
ten_gig_eth_pcs_pma ten_gig_eth_pcs_pma_x4 (
  .gt_rxp_in_0                  (GT_RXP[0]),
  .gt_rxn_in_0                  (GT_RXN[0]),
  .gt_txp_out_0                 (GT_TXP[0]),
  .gt_txn_out_0                 (GT_TXN[0]),
  .gt_rxp_in_1                  (GT_RXP[1]),
  .gt_rxn_in_1                  (GT_RXN[1]),
  .gt_txp_out_1                 (GT_TXP[1]),
  .gt_txn_out_1                 (GT_TXN[1]),
  .gt_rxp_in_2                  (GT_RXP[2]),
  .gt_rxn_in_2                  (GT_RXN[2]),
  .gt_txp_out_2                 (GT_TXP[2]),
  .gt_txn_out_2                 (GT_TXN[2]),
  .gt_rxp_in_3                  (GT_RXP[3]),
  .gt_rxn_in_3                  (GT_RXN[3]),
  .gt_txp_out_3                 (GT_TXP[3]),
  .gt_txn_out_3                 (GT_TXN[3]),

  // GT0
  .tx_mii_clk_0                 (tx_mii_clk_0),
  .rx_core_clk_0                (xgmii_clk_0),
  .rx_clk_out_0                 (rx_clk_out_0),
  //
  .gt_loopback_in_0             (3'b0),   // For internal loopback gt_loopback_in = 3'b010;
  .rx_reset_0                   (rst),
  .user_rx_reset_0              (),
  .rxrecclkout_0                (),
  // RX User Interface Signals
  .rx_mii_d_0                   (xgmii_rxd_0),
  .rx_mii_c_0                   (xgmii_rxc_0),
  // RX Control Signals
  .ctl_rx_test_pattern_0        (1'b0),
  .ctl_rx_test_pattern_enable_0 (1'b0),
  .ctl_rx_data_pattern_select_0 (1'b0),
  .ctl_rx_prbs31_test_pattern_enable_0 (1'b0),
  // RX Stats Signals
  .stat_rx_block_lock_0         (stat_rx_block_lock_0),
  .stat_rx_framing_err_valid_0  (stat_rx_framing_err_valid_0),
  .stat_rx_framing_err_0        (stat_rx_framing_err_0),
  .stat_rx_hi_ber_0             (stat_rx_hi_ber_0),
  .stat_rx_valid_ctrl_code_0    (stat_rx_valid_ctrl_code_0),
  .stat_rx_bad_code_0           (stat_rx_bad_code_0),
  .stat_rx_bad_code_valid_0     (stat_rx_bad_code_valid_0),
  .stat_rx_error_valid_0        (stat_rx_error_valid_0),
  .stat_rx_error_0              (stat_rx_error_0),
  .stat_rx_fifo_error_0         (stat_rx_fifo_error_0),
  .stat_rx_local_fault_0        (stat_rx_local_fault_0),
  .stat_rx_status_0             (stat_rx_status_0),
  // TX
  .tx_reset_0                   (rst),
  .user_tx_reset_0              (),
  // TX User Interface Signals
  .tx_mii_d_0                   (xgmii_txd_0),
  .tx_mii_c_0                   (xgmii_txc_0),
  // TX Control Signals
  .ctl_tx_test_pattern_0        (1'b0),
  .ctl_tx_test_pattern_enable_0 (1'b0),
  .ctl_tx_test_pattern_select_0 (1'b0),
  .ctl_tx_data_pattern_select_0 (1'b0),
  .ctl_tx_test_pattern_seed_a_0 (58'h0),
  .ctl_tx_test_pattern_seed_b_0 (58'h0),
  .ctl_tx_prbs31_test_pattern_enable_0 (1'b0),
  // TX Stats Signals
  .stat_tx_local_fault_0        (stat_tx_local_fault_0),
  // GT
  .gtwiz_reset_tx_datapath_0    (1'b0),
  .gtwiz_reset_rx_datapath_0    (1'b0),
  .gtpowergood_out_0            (gtpowergood_out_0),
  .txoutclksel_in_0             (3'b101),
  .rxoutclksel_in_0             (3'b101),

  // GT1
  .tx_mii_clk_1                 (tx_mii_clk_1),
  .rx_core_clk_1                (xgmii_clk_1),
  .rx_clk_out_1                 (rx_clk_out_1),
  //
  .gt_loopback_in_1             (3'b0),   // For internal loopback gt_loopback_in = 3'b010;
  .rx_reset_1                   (rst),
  .user_rx_reset_1              (),
  .rxrecclkout_1                (),
  // RX User Interface Signals
  .rx_mii_d_1                   (xgmii_rxd_1),
  .rx_mii_c_1                   (xgmii_rxc_1),
  // RX Control Signals
  .ctl_rx_test_pattern_1        (1'b0),
  .ctl_rx_test_pattern_enable_1 (1'b0),
  .ctl_rx_data_pattern_select_1 (1'b0),
  .ctl_rx_prbs31_test_pattern_enable_1 (1'b0),
  // RX Stats Signals
  .stat_rx_block_lock_1         (stat_rx_block_lock_1),
  .stat_rx_framing_err_valid_1  (stat_rx_framing_err_valid_1),
  .stat_rx_framing_err_1        (stat_rx_framing_err_1),
  .stat_rx_hi_ber_1             (stat_rx_hi_ber_1),
  .stat_rx_valid_ctrl_code_1    (stat_rx_valid_ctrl_code_1),
  .stat_rx_bad_code_1           (stat_rx_bad_code_1),
  .stat_rx_bad_code_valid_1     (stat_rx_bad_code_valid_1),
  .stat_rx_error_valid_1        (stat_rx_error_valid_1),
  .stat_rx_error_1              (stat_rx_error_1),
  .stat_rx_fifo_error_1         (stat_rx_fifo_error_1),
  .stat_rx_local_fault_1        (stat_rx_local_fault_1),
  .stat_rx_status_1             (stat_rx_status_1),
  // TX
  .tx_reset_1                   (rst),
  .user_tx_reset_1              (),
  // TX User Interface Signals
  .tx_mii_d_1                   (xgmii_txd_1),
  .tx_mii_c_1                   (xgmii_txc_1),
  // TX Control Signals
  .ctl_tx_test_pattern_1        (1'b0),
  .ctl_tx_test_pattern_enable_1 (1'b0),
  .ctl_tx_test_pattern_select_1 (1'b0),
  .ctl_tx_data_pattern_select_1 (1'b0),
  .ctl_tx_test_pattern_seed_a_1 (58'h0),
  .ctl_tx_test_pattern_seed_b_1 (58'h0),
  .ctl_tx_prbs31_test_pattern_enable_1 (1'b0),
  // TX Stats Signals
  .stat_tx_local_fault_1        (stat_tx_local_fault_1),
  // GT
  .gtwiz_reset_tx_datapath_1    (1'b0),
  .gtwiz_reset_rx_datapath_1    (1'b0),
  .gtpowergood_out_1            (gtpowergood_out_1),
  .txoutclksel_in_1             (3'b101),
  .rxoutclksel_in_1             (3'b101),

  // GT2
  .tx_mii_clk_2                 (tx_mii_clk_2),
  .rx_core_clk_2                (xgmii_clk_2),
  .rx_clk_out_2                 (rx_clk_out_2),
  //
  .gt_loopback_in_2             (3'b0),   // For internal loopback gt_loopback_in = 3'b010;
  .rx_reset_2                   (rst),
  .user_rx_reset_2              (),
  .rxrecclkout_2                (),
  // RX User Interface Signals
  .rx_mii_d_2                   (xgmii_rxd_2),
  .rx_mii_c_2                   (xgmii_rxc_2),
  // RX Control Signals
  .ctl_rx_test_pattern_2        (1'b0),
  .ctl_rx_test_pattern_enable_2 (1'b0),
  .ctl_rx_data_pattern_select_2 (1'b0),
  .ctl_rx_prbs31_test_pattern_enable_2 (1'b0),
  // RX Stats Signals
  .stat_rx_block_lock_2         (stat_rx_block_lock_2),
  .stat_rx_framing_err_valid_2  (stat_rx_framing_err_valid_2),
  .stat_rx_framing_err_2        (stat_rx_framing_err_2),
  .stat_rx_hi_ber_2             (stat_rx_hi_ber_2),
  .stat_rx_valid_ctrl_code_2    (stat_rx_valid_ctrl_code_2),
  .stat_rx_bad_code_2           (stat_rx_bad_code_2),
  .stat_rx_bad_code_valid_2     (stat_rx_bad_code_valid_2),
  .stat_rx_error_valid_2        (stat_rx_error_valid_2),
  .stat_rx_error_2              (stat_rx_error_2),
  .stat_rx_fifo_error_2         (stat_rx_fifo_error_2),
  .stat_rx_local_fault_2        (stat_rx_local_fault_2),
  .stat_rx_status_2             (stat_rx_status_2),
  // TX
  .tx_reset_2                   (rst),
  .user_tx_reset_2              (),
  // TX User Interface Signals
  .tx_mii_d_2                   (xgmii_txd_2),
  .tx_mii_c_2                   (xgmii_txc_2),
  // TX Control Signals
  .ctl_tx_test_pattern_2        (1'b0),
  .ctl_tx_test_pattern_enable_2 (1'b0),
  .ctl_tx_test_pattern_select_2 (1'b0),
  .ctl_tx_data_pattern_select_2 (1'b0),
  .ctl_tx_test_pattern_seed_a_2 (58'h0),
  .ctl_tx_test_pattern_seed_b_2 (58'h0),
  .ctl_tx_prbs31_test_pattern_enable_2 (1'b0),
  // TX Stats Signals
  .stat_tx_local_fault_2        (stat_tx_local_fault_2),
  // GT
  .gtwiz_reset_tx_datapath_2    (1'b0),
  .gtwiz_reset_rx_datapath_2    (1'b0),
  .gtpowergood_out_2            (gtpowergood_out_2),
  .txoutclksel_in_2             (3'b101),
  .rxoutclksel_in_2             (3'b101),

  // GT3
  .tx_mii_clk_3                 (tx_mii_clk_3),
  .rx_core_clk_3                (xgmii_clk_3),
  .rx_clk_out_3                 (rx_clk_out_3),
  //
  .gt_loopback_in_3             (3'b0),   // For internal loopback gt_loopback_in = 3'b010;
  .rx_reset_3                   (rst),
  .user_rx_reset_3              (),
  .rxrecclkout_3                (),
  // RX User Interface Signals
  .rx_mii_d_3                   (xgmii_rxd_3),
  .rx_mii_c_3                   (xgmii_rxc_3),
  // RX Control Signals
  .ctl_rx_test_pattern_3        (1'b0),
  .ctl_rx_test_pattern_enable_3 (1'b0),
  .ctl_rx_data_pattern_select_3 (1'b0),
  .ctl_rx_prbs31_test_pattern_enable_3 (1'b0),
  // RX Stats Signals
  .stat_rx_block_lock_3         (stat_rx_block_lock_3),
  .stat_rx_framing_err_valid_3  (stat_rx_framing_err_valid_3),
  .stat_rx_framing_err_3        (stat_rx_framing_err_3),
  .stat_rx_hi_ber_3             (stat_rx_hi_ber_3),
  .stat_rx_valid_ctrl_code_3    (stat_rx_valid_ctrl_code_3),
  .stat_rx_bad_code_3           (stat_rx_bad_code_3),
  .stat_rx_bad_code_valid_3     (stat_rx_bad_code_valid_3),
  .stat_rx_error_valid_3        (stat_rx_error_valid_3),
  .stat_rx_error_3              (stat_rx_error_3),
  .stat_rx_fifo_error_3         (stat_rx_fifo_error_3),
  .stat_rx_local_fault_3        (stat_rx_local_fault_3),
  .stat_rx_status_3             (stat_rx_status_3),
  // TX
  .tx_reset_3                   (rst),
  .user_tx_reset_3              (),
  // TX User Interface Signals
  .tx_mii_d_3                   (xgmii_txd_3),
  .tx_mii_c_3                   (xgmii_txc_3),
  // TX Control Signals
  .ctl_tx_test_pattern_3        (1'b0),
  .ctl_tx_test_pattern_enable_3 (1'b0),
  .ctl_tx_test_pattern_select_3 (1'b0),
  .ctl_tx_data_pattern_select_3 (1'b0),
  .ctl_tx_test_pattern_seed_a_3 (58'h0),
  .ctl_tx_test_pattern_seed_b_3 (58'h0),
  .ctl_tx_prbs31_test_pattern_enable_3 (1'b0),
  // TX Stats Signals
  .stat_tx_local_fault_3        (stat_tx_local_fault_3),
  // GT
  .gtwiz_reset_tx_datapath_3    (1'b0),
  .gtwiz_reset_rx_datapath_3    (1'b0),
  .gtpowergood_out_3            (gtpowergood_out_3),
  .txoutclksel_in_3             (3'b101),
  .rxoutclksel_in_3             (3'b101),

  // GT COMMON
  .qpllreset_in_0               (1'b0),
  .gt_refclk_p                  (GTREFCLK_P),
  .gt_refclk_n                  (GTREFCLK_N),
  .gt_refclk_out                (),
  .sys_reset                    (rst),
  .dclk                         (CLK40)
);

//------------------------------------------------------------------------------
// ChipScope debug (optional)
//------------------------------------------------------------------------------
generate
  if (USE_CHIPSCOPE == 1) begin
    wire [255:0] probe0;
    ila256 ila256_0 (
      .clk    (CLKOUT0),
      .probe0 (probe0)
    );
    // RX Status Signals
    assign probe0[7:0]      = stat_rx_error_0;
    assign probe0[8]        = stat_rx_block_lock_0;
    assign probe0[9]        = stat_rx_framing_err_valid_0;
    assign probe0[10]       = stat_rx_framing_err_0;
    assign probe0[11]       = stat_rx_hi_ber_0;
    assign probe0[12]       = stat_rx_valid_ctrl_code_0;
    assign probe0[13]       = stat_rx_bad_code_0;
    assign probe0[14]       = stat_rx_bad_code_valid_0;
    assign probe0[15]       = stat_rx_error_valid_0;
    assign probe0[16]       = stat_rx_fifo_error_0;
    assign probe0[17]       = stat_rx_local_fault_0;
    assign probe0[18]       = stat_rx_status_0;
    // TX Status Signals
    assign probe0[19]       = stat_tx_local_fault_0;
    // GT Status
    assign probe0[20]       = gtpowergood_out_0;
    // Other Status
    assign probe0[21]       = rst;
    assign probe0[22]       = IP_SELECT[0];

    assign probe0[111:23]   = 0;

    // XGMII
    assign probe0[119:112]  = xgmii_txc_0;
    assign probe0[127:120]  = xgmii_rxc_0;
    assign probe0[191:128]  = xgmii_txd_0;
    assign probe0[255:192]  = xgmii_rxd_0;
  end

  if (USE_CHIPSCOPE == 1) begin
    wire [255:0] probe1;
    ila256 ila256_1 (
      .clk    (CLKOUT1),
      .probe0 (probe1)
    );
    // RX Status Signals
    assign probe1[7:0]      = stat_rx_error_1;
    assign probe1[8]        = stat_rx_block_lock_1;
    assign probe1[9]        = stat_rx_framing_err_valid_1;
    assign probe1[10]       = stat_rx_framing_err_1;
    assign probe1[11]       = stat_rx_hi_ber_1;
    assign probe1[12]       = stat_rx_valid_ctrl_code_1;
    assign probe1[13]       = stat_rx_bad_code_1;
    assign probe1[14]       = stat_rx_bad_code_valid_1;
    assign probe1[15]       = stat_rx_error_valid_1;
    assign probe1[16]       = stat_rx_fifo_error_1;
    assign probe1[17]       = stat_rx_local_fault_1;
    assign probe1[18]       = stat_rx_status_1;
    // TX Status Signals
    assign probe1[19]       = stat_tx_local_fault_1;
    // GT Status
    assign probe1[20]       = gtpowergood_out_1;
    // Other Status
    assign probe1[21]       = rst;
    assign probe1[22]       = IP_SELECT[0];

    assign probe1[111:23]   = 0;

    // XGMII
    assign probe1[119:112]  = xgmii_txc_1;
    assign probe1[127:120]  = xgmii_rxc_1;
    assign probe1[191:128]  = xgmii_txd_1;
    assign probe1[255:192]  = xgmii_rxd_1;
  end

  if (USE_CHIPSCOPE == 1) begin
    wire [255:0] probe2;
    ila256 ila256_2 (
      .clk    (CLKOUT2),
      .probe0 (probe2)
    );
    // RX Status Signals
    assign probe2[7:0]      = stat_rx_error_2;
    assign probe2[8]        = stat_rx_block_lock_2;
    assign probe2[9]        = stat_rx_framing_err_valid_2;
    assign probe2[10]       = stat_rx_framing_err_2;
    assign probe2[11]       = stat_rx_hi_ber_2;
    assign probe2[12]       = stat_rx_valid_ctrl_code_2;
    assign probe2[13]       = stat_rx_bad_code_2;
    assign probe2[14]       = stat_rx_bad_code_valid_2;
    assign probe2[15]       = stat_rx_error_valid_2;
    assign probe2[16]       = stat_rx_fifo_error_2;
    assign probe2[17]       = stat_rx_local_fault_2;
    assign probe2[18]       = stat_rx_status_2;
    // TX Status Signals
    assign probe2[19]       = stat_tx_local_fault_2;
    // GT Status
    assign probe2[20]       = gtpowergood_out_2;
    // Other Status
    assign probe2[21]       = rst;
    assign probe2[22]       = IP_SELECT[0];

    assign probe2[111:23]   = 0;

    // XGMII
    assign probe2[119:112]  = xgmii_txc_2;
    assign probe2[127:120]  = xgmii_rxc_2;
    assign probe2[191:128]  = xgmii_txd_2;
    assign probe2[255:192]  = xgmii_rxd_2;
  end

  if (USE_CHIPSCOPE == 1) begin
    wire [255:0] probe3;
    ila256 ila256_3 (
      .clk    (CLKOUT3),
      .probe0 (probe3)
    );
    // RX Status Signals
    assign probe3[7:0]      = stat_rx_error_3;
    assign probe3[8]        = stat_rx_block_lock_3;
    assign probe3[9]        = stat_rx_framing_err_valid_3;
    assign probe3[10]       = stat_rx_framing_err_3;
    assign probe3[11]       = stat_rx_hi_ber_3;
    assign probe3[12]       = stat_rx_valid_ctrl_code_3;
    assign probe3[13]       = stat_rx_bad_code_3;
    assign probe3[14]       = stat_rx_bad_code_valid_3;
    assign probe3[15]       = stat_rx_error_valid_3;
    assign probe3[16]       = stat_rx_fifo_error_3;
    assign probe3[17]       = stat_rx_local_fault_3;
    assign probe3[18]       = stat_rx_status_3;
    // TX Status Signals
    assign probe3[19]       = stat_tx_local_fault_3;
    // GT Status
    assign probe3[20]       = gtpowergood_out_3;
    // Other Status
    assign probe3[21]       = rst;
    assign probe3[22]       = IP_SELECT[0];

    assign probe3[111:23]   = 0;

    // XGMII
    assign probe3[119:112]  = xgmii_txc_3;
    assign probe3[127:120]  = xgmii_rxc_3;
    assign probe3[191:128]  = xgmii_txd_3;
    assign probe3[255:192]  = xgmii_rxd_3;
  end
endgenerate

//------------------------------------------------------------------------------
endmodule
