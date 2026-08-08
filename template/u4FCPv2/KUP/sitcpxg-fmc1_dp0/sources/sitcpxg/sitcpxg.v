`timescale 1 ps/1 ps
//------------------------------------------------------------------------------
// File       : sitcpxg.v
// Author     : by zhj@ihep.ac.cn
//------------------------------------------------------------------------------
// Description: This is the verilog design for the Ten GigaEthernet TCP/IP core.
//              The block level wrapper for the core is instantiated and the
//              timer circuitry is created.
module sitcpxg #(
  parameter         USE_CHIPSCOPE = 0,
  parameter [31: 0] BASE_IP_ADDR  = 32'hC0A8_0A10,  //192.168.10.16
  parameter [31: 0] MAC_IP_WIDTH  = 3,
  parameter         RxBufferSize  = "LongLong" // Little-endian conversion for rxdata
  // "Byte":8bit width ,"Word":16bit width ,"LongWord":32bit width , "LongLong":64bit width
)(
  // System I/F
  input           RST,            // in : System reset (Sync.)
  output          CLKOUT,         // out: 156.25MHz BUFG clock out
  input           CLK40,          // in : indepondent clock for DRP
  // SiTCP setting
  input   [31: 0] REG_FPGA_VER,   // in : User logic Version(For example, the synthesized date)
  input   [31: 0] REG_FPGA_ID,    // in : User logic ID (We recommend using the lower 4 bytes of the MAC address.)
  input   [MAC_IP_WIDTH-1 :0]   MAC_SELECT,
  input   [MAC_IP_WIDTH-1 :0]   IP_SELECT,
  output          TIM_1US,      // out  : 1 us interval
  output          TIM_10US,     // out  : 10 us interval
  output          TIM_100US,    // out  : 100 us interval
  output          TIM_1MS,      // out  : 1 ms interval
  output          TIM_10MS,     // out  : 10 ms interval
  output          TIM_100MS,    // out  : 100 ms interval
  output          TIM_1S,       // out  : 1 s interval
  output          TIM_1M,       // out  : 1 m interval
  // User I/F
  output          SiTCP_RESET_OUT,// out: System reset for user's module
  // RBCP
  output          RBCP_ACT,       // out: Indicates that bus access is active.
  output  [31: 0] RBCP_ADDR,      // out: Address[31:0]
  output          RBCP_WE,        // out: Write enable
  output  [ 7: 0] RBCP_WD,        // out: Data[7:0]
  output          RBCP_RE,        // out: Read enable
  input           RBCP_ACK,       // in : Access acknowledge
  input   [ 7: 0] RBCP_RD,        // in : Read data[7:0]
  // TCP
  input           USER_SESSION_OPEN_REQ,    // in : Request for opening the new session
  output          USER_SESSION_ESTABLISHED, // out: Establish of a session
  output          USER_SESSION_CLOSE_REQ,   // out: Request for closing session.
  input           USER_SESSION_CLOSE_ACK,   // in : Acknowledge for USER_SESSION_CLOSE_REQ.
  input   [63: 0] USER_TX_D,      // in : Write data
  input   [ 3: 0] USER_TX_B,      // in : Byte length of USER_TX_DATA(Set to 0 if not written)
  output          USER_TX_AFULL,  // out: Request to stop TX
  input   [15: 0] USER_RX_SIZE,   // in : Receive buffer size(byte) caution:Set a value of 4000 or more and (memory size-16) or less
  output          USER_RX_CLR_ENB,// out: Receive buffer Clear Enable
  input           USER_RX_CLR_REQ,// in : Receive buffer Clear Request
  input   [15: 0] USER_RX_RADR,   // in : Receive buffer read address in bytes (unused upper bits are set to 0)
  output  [15: 0] USER_RX_WADR,   // out: Receive buffer write address in bytes (lower 3 bits are not connected to memory)
  output  [ 7: 0] USER_RX_WENB,   // out: Receive buffer byte write enable (big endian)
  output  [63: 0] USER_RX_WDAT,   // out: Receive buffer write data (big endian)
  // GT interface
  input           GTREFCLK_P,     // in : Differential +ve of reference clock for MGT: very high quality.
  input           GTREFCLK_N,     // in : Differential -ve of reference clock for MGT: very high quality.
  output          GT_TXP,         // out: Tx signal line
  output          GT_TXN,         //
  input           GT_RXP,         // in : Rx signal line
  input           GT_RXN          //
);

// XGMII I/F
wire  [ 7: 0] xgmii_rxc;
wire  [63: 0] xgmii_rxd;
wire  [ 7: 0] xgmii_txc;
wire  [63: 0] xgmii_txd;
wire          xgmii_clock;

wire rst;
// async2sync_reset reset_usrclk(
//   .rst_in       (RST),
//   .clk          (xgmii_clock),
//   .rst_out      (rst)
// );
assign rst = RST;

TIMER #(
  .CLK_FREQ   (8'd156)
)TIMER(
// System
  .CLK        (xgmii_clock),  // in: System clock
  .RST        (rst),          // in: System reset
// Intrrupts
  .TIM_1US    (TIM_1US),      // out: 1 us interval
  .TIM_10US   (TIM_10US),     // out: 10 us interval
  .TIM_100US  (TIM_100US),    // out: 100 us interval
  .TIM_1MS    (TIM_1MS),      // out: 1 ms interval
  .TIM_10MS   (TIM_10MS),     // out: 10 ms interval
  .TIM_100MS  (TIM_100MS),    // out: 100 ms interval
  .TIM_1S     (TIM_1S),       // out: 1 s interval
  .TIM_1M     (TIM_1M)        // out: 1 min interval
);

//------------------------------------------------------------------------------
//  SiTCP library
wire  [47: 0] TCP_SERVER_MAC;
wire  [31: 0] TCP_SERVER_ADDR;
wire  [15: 0] TCP_SERVER_PORT;
wire  [ 7: 0] swap_rx_wenb;
wire  [63: 0] swap_rx_wdat;

SiTCPXG_XCAUP_128K_V4 SiTCPXG_XC(
  .REG_FPGA_VER             (REG_FPGA_VER),     // in : User logic Version(For example, the synthesized date)
  .REG_FPGA_ID              (REG_FPGA_ID),      // in : User logic ID (We recommend using the lower 4 bytes of the MAC address.)
  // System I/F
  .XGMII_CLOCK              (xgmii_clock),      // in : XGMII clock
  .RSTs                     (rst),              // in : System reset (Sync.)
  .TIM_1US                  (TIM_1US),          // in : 1us interval pulse
  .TIM_1MS                  (TIM_1MS),          // in : 1us interval pulse
  .TIM_1S                   (TIM_1S),           // in : 1s   interval pulse
  // XGMII I/F
  .XGMII_RXC                (xgmii_rxc),        // in : Rx control[7:0]
  .XGMII_RXD                (xgmii_rxd),        // in : Rx data[63:0]
  .XGMII_TXC                (xgmii_txc),        // out: Control bits[7:0]
  .XGMII_TXD                (xgmii_txd),        // out: Data[63:0]
  // 93C46 I/F
  .EEPROM_CS                (),                 // out: Chip select
  .EEPROM_SK                (),                 // out: Serial data clock
  .EEPROM_DI                (),                 // out: Serial write data
  .EEPROM_DO                (1'b0),             // in : Serial read data
  // Configuration parameters
  .FORCE_DEFAULTn           (1'b0),             // in : Force to set default values
  .MY_MAC_ADDR              (),                 // out: My IP MAC Address[47:0]
  .MY_IP_ADDR               (BASE_IP_ADDR+IP_SELECT),  // in : My IP address[31:0]
  .IP_ADDR_DEFAULT          (),                 // out: Default value for MY_IP_ADDR[31:0]
  .MY_TCP_PORT              (16'd24),           // in : My TCP port[15:0]
  .TCP_PORT_DEFAULT         (),                 // out: Default value for my TCP MY_TCP_PORT[15:0]
  .MY_RBCP_PORT             (16'd4660),         // in : My UDP RBCP-port[15:0]
  .RBCP_PORT_DEFAULT        (),                 // out: Default value for my UDP RBCP-port #[15:0]
  .TCP_SERVER_MAC_IN        (TCP_SERVER_MAC),   // in : Client mode, Server MAC address[47:0]
  .TCP_SERVER_MAC_DEFAULT   (TCP_SERVER_MAC),   // out: Default value for the server's MAC address
  .TCP_SERVER_ADDR_IN       (TCP_SERVER_ADDR),  // in : Client mode, Server IP address[31:0]
  .TCP_SERVER_ADDR_DEFAULT  (TCP_SERVER_ADDR),  // out: Default value for the server's IP address[31:0]
  .TCP_SERVER_PORT_IN       (TCP_SERVER_PORT),  // in : Client mode, Server wating port#[15:0]
  .TCP_SERVER_PORT_DEFAULT  (TCP_SERVER_PORT),  // out: Default value for the server port #[15:0]
  // User I/F
  .SiTCP_RESET_OUT          (SiTCP_RESET_OUT),  // out: System reset for user's module
  // RBCP
  .RBCP_ACT                 (RBCP_ACT),         // out: Indicates that bus access is active.
  .RBCP_ADDR                (RBCP_ADDR),        // out: Address[31:0]
  .RBCP_WE                  (RBCP_WE),          // out: Write enable
  .RBCP_WD                  (RBCP_WD),          // out: Data[7:0]
  .RBCP_RE                  (RBCP_RE),          // out: Read enable
  .RBCP_ACK                 (RBCP_ACK),         // in : Access acknowledge
  .RBCP_RD                  (RBCP_RD),          // in : Read data[7:0]
  // TCP
  .USER_SESSION_OPEN_REQ    (USER_SESSION_OPEN_REQ),    // in : Request for opening the new session
  .USER_SESSION_ESTABLISHED (USER_SESSION_ESTABLISHED), // out: Establish of a session
  .USER_SESSION_CLOSE_REQ   (USER_SESSION_CLOSE_REQ),   // out: Request for closing session.
  .USER_SESSION_CLOSE_ACK   (USER_SESSION_CLOSE_ACK),   // in : Acknowledge for USER_SESSION_CLOSE_REQ.
  .USER_TX_D                (USER_TX_D),        // in : Write data
  .USER_TX_B                (USER_TX_B),        // in : Byte length of USER_TX_DATA(Set to 0 if not written)
  .USER_TX_AFULL            (USER_TX_AFULL),    // out: Request to stop TX
  .USER_RX_SIZE             (USER_RX_SIZE),     // in : Receive buffer size(byte). Caution: Set a value of 4000 or more and (memory size-16) or less
  .USER_RX_CLR_ENB          (USER_RX_CLR_ENB),  // out: Receive buffer Clear Enable
  .USER_RX_CLR_REQ          (USER_RX_CLR_REQ),  // in : Receive buffer Clear Request
  .USER_RX_RADR             (USER_RX_RADR),     // in : Receive buffer read address in bytes (unused upper bits are set to 0)
  .USER_RX_WADR             (USER_RX_WADR),     // out: Receive buffer write address in bytes (lower 3 bits are not connected to memory)
  .USER_RX_WENB             (swap_rx_wenb),     // out: Receive buffer byte write enable (big endian)
  .USER_RX_WDAT             (swap_rx_wdat)      // out: Receive buffer write data (big endian)
);

// Little-endian conversion
generate
  if (RxBufferSize == "LongLong") begin
    assign  USER_RX_WENB[ 7:0]  = swap_rx_wenb[ 7:0];
    assign  USER_RX_WDAT[63:0]  = swap_rx_wdat[63:0];
  end
  else if (RxBufferSize == "LongWord") begin
    assign  USER_RX_WENB[ 3: 0] = swap_rx_wenb[ 7: 4];
    assign  USER_RX_WDAT[31: 0] = swap_rx_wdat[63:32];
    assign  USER_RX_WENB[ 7: 4] = swap_rx_wenb[ 3: 0];
    assign  USER_RX_WDAT[63:32] = swap_rx_wdat[31: 0];
  end
  else if (RxBufferSize == "Word") begin
    assign  USER_RX_WENB[ 1: 0] = swap_rx_wenb[ 7: 6];
    assign  USER_RX_WDAT[15: 0] = swap_rx_wdat[63:48];
    assign  USER_RX_WENB[ 3: 2] = swap_rx_wenb[ 5: 4];
    assign  USER_RX_WDAT[31:16] = swap_rx_wdat[47:32];
    assign  USER_RX_WENB[ 5: 4] = swap_rx_wenb[ 3: 2];
    assign  USER_RX_WDAT[47:32] = swap_rx_wdat[31:16];
    assign  USER_RX_WENB[ 7: 6] = swap_rx_wenb[ 1: 0];
    assign  USER_RX_WDAT[63:48] = swap_rx_wdat[15: 0];
  end
  else if (RxBufferSize == "Byte") begin
    assign  USER_RX_WENB[0] = swap_rx_wenb[7];
    assign  USER_RX_WDAT[ 7: 0] = swap_rx_wdat[63:56];
    assign  USER_RX_WENB[1] = swap_rx_wenb[6];
    assign  USER_RX_WDAT[15: 8] = swap_rx_wdat[55:48];
    assign  USER_RX_WENB[2] = swap_rx_wenb[5];
    assign  USER_RX_WDAT[23:16] = swap_rx_wdat[47:40];
    assign  USER_RX_WENB[3] = swap_rx_wenb[4];
    assign  USER_RX_WDAT[31:24] = swap_rx_wdat[39:32];
    assign  USER_RX_WENB[4] = swap_rx_wenb[3];
    assign  USER_RX_WDAT[39:32] = swap_rx_wdat[31:24];
    assign  USER_RX_WENB[5] = swap_rx_wenb[2];
    assign  USER_RX_WDAT[47:40] = swap_rx_wdat[23:16];
    assign  USER_RX_WENB[6] = swap_rx_wenb[1];
    assign  USER_RX_WDAT[55:48] = swap_rx_wdat[15: 8];
    assign  USER_RX_WENB[7] = swap_rx_wenb[0];
    assign  USER_RX_WDAT[63:56] = swap_rx_wdat[ 7: 0];
  end
endgenerate

wire rx_clk_out_0;
wire tx_mii_clk_0;
assign xgmii_clock = tx_mii_clk_0;
// assign xgmii_clock = rx_clk_out_0;
assign CLKOUT = xgmii_clock;

// RX Status Signals
wire stat_rx_block_lock_0;
wire stat_rx_framing_err_valid_0;
wire stat_rx_framing_err_0;
wire stat_rx_hi_ber_0;
wire stat_rx_valid_ctrl_code_0;
wire stat_rx_bad_code_0;
wire stat_rx_bad_code_valid_0;
wire stat_rx_error_valid_0;
wire [7:0] stat_rx_error_0;
wire stat_rx_fifo_error_0;
wire stat_rx_local_fault_0;
wire stat_rx_status_0;
// TX Status Signals
wire stat_tx_local_fault_0;
// GT Status
wire gtpowergood_out_0;

ten_gig_eth_pcs_pma ten_gig_eth_pcs_pma_i(
  .gt_rxp_in_0                  (GT_RXP),
  .gt_rxn_in_0                  (GT_RXN),
  .gt_txp_out_0                 (GT_TXP),
  .gt_txn_out_0                 (GT_TXN),
  .tx_mii_clk_0                 (tx_mii_clk_0),
  .rx_core_clk_0                (xgmii_clock),
  .rx_clk_out_0                 (rx_clk_out_0),
// RX Signals
  .gt_loopback_in_0             (3'b0),   // For internal loopback gt_loopback_in = 3'b010;
  .rx_reset_0                   (rst),
  .user_rx_reset_0              (),
  .rxrecclkout_0                (),
// RX User Interface Signals
  .rx_mii_d_0                   (xgmii_rxd),
  .rx_mii_c_0                   (xgmii_rxc),
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
// TX Signals
  .tx_reset_0                   (rst),
  .user_tx_reset_0              (),
// TX User Interface Signals
  .tx_mii_d_0                   (xgmii_txd),
  .tx_mii_c_0                   (xgmii_txc),
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
  .qpllreset_in_0               (1'b0),
  .gt_refclk_p                  (GTREFCLK_P),
  .gt_refclk_n                  (GTREFCLK_N),
  .gt_refclk_out                (),
  .sys_reset                    (rst),
  .dclk                         (CLK40)
);

generate
if (USE_CHIPSCOPE == 1) begin
  wire [255:0] probe0;
  ila256 ila256 (
      .clk(CLKOUT),
      .probe0(probe0)
  );
  // RX Status Signals
  assign probe0[7:0] = stat_rx_error_0;
  assign probe0[8] = stat_rx_block_lock_0;
  assign probe0[9] = stat_rx_framing_err_valid_0;
  assign probe0[10] = stat_rx_framing_err_0;
  assign probe0[11] = stat_rx_hi_ber_0;
  assign probe0[12] = stat_rx_valid_ctrl_code_0;
  assign probe0[13] = stat_rx_bad_code_0;
  assign probe0[14] = stat_rx_bad_code_valid_0;
  assign probe0[15] = stat_rx_error_valid_0;
  assign probe0[16] = stat_rx_fifo_error_0;
  assign probe0[17] = stat_rx_local_fault_0;
  assign probe0[18] = stat_rx_status_0;
  // TX Status Signals
  assign probe0[19] = stat_tx_local_fault_0;
  // GT Status
  assign probe0[20] = gtpowergood_out_0;
  // Other Status
  assign probe0[21] = rst;
  assign probe0[22] = IP_SELECT[0];

  assign probe0[111:23] = 0;

  // XGMII
  assign probe0[119:112] = xgmii_txc;
  assign probe0[127:120] = xgmii_rxc;
  assign probe0[191:128] = xgmii_txd;
  assign probe0[255:192] = xgmii_rxd;
end
endgenerate

//------------------------------------------------------------------------------
endmodule
