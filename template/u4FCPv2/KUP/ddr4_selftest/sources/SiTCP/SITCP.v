`timescale 1 ps/1 ps
//------------------------------------------------------------------------------
// File       : sitcp.v
// Author     : by zhj@ihep.ac.cn
//------------------------------------------------------------------------------
// Description: This is the verilog design for the Ethernet TCP/IP core. The
//              block level wrapper for the core is instantiated and the
//              timer circuitry is created.
//
module SITCP #(
  parameter         USE_CHIPSCOPE = 0,
  parameter [31: 0] BASE_IP_ADDR  = 32'hC0A8_0A10, //192.168.10.16
  parameter [4 : 0] PHY_ADDRESS   = 5'b1,
  parameter [31: 0] MAC_IP_WIDTH  = 3
)(
  input           USRCLK,       // for user tcp/udp port
  input           CLK40,
  input           RST,          // reset for entire core.
  output          CLKOUT,       // 125MHz BUFG clock out
// SiTCP setting
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
// TCP port
  output          TCP_OPEN,
  output          TCP_ERROR,
  output          TCP_RST,
  output          TCP_CLOSE,
  input   [15:0]  TCP_RX_WC,
  output          TCP_RX_WR,
  output  [7 :0]  TCP_RX_DATA,
  output          TCP_TX_FULL,
  input           TCP_TX_WR,
  input   [7 :0]  TCP_TX_DATA,
// UDP port
  output  [31:0]  RBCP_ADDR,
  output          RBCP_WE,
  output  [7 :0]  RBCP_WD,
  output          RBCP_RE,
  output          RBCP_ACT,
  input           RBCP_ACK,
  input   [7 :0]  RBCP_RD,
  // GT physical interface
  output          GT_TXP,
  output          GT_TXN,
  input           GT_RXP,
  input           GT_RXN,
  input           GT_DETECT
);

TIMER #(
  .CLK_FREQ   (8'd125)
)TIMER(
// System
  .CLK        (USRCLK),       // in: System clock
  .RST        (RST),          // in: System reset
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

wire          tcp_open_error;
wire          tcp_tx_ow_error;
assign TCP_ERROR = tcp_open_error | tcp_tx_ow_error;

wire          gmii_tx_clk;
wire          gmii_tx_clk90;
wire          gmii_rx_clk;
// GMII Interface (client MAC <=> PCS)
wire  [7 : 0] gmii_tx_d;     // Transmit data from client MAC.
wire          gmii_tx_en;    // Transmit control signal from client MAC.
wire          gmii_tx_er;    // Transmit control signal from client MAC.
wire  [7 : 0] gmii_rx_d;     // Received Data to client MAC.
wire          gmii_rx_dv;    // Received control signal to client MAC.
wire          gmii_rx_er;    // Received control signal to client MAC.
// Management: MDIO Interface
wire          mdc_sys, mdio_i_sys, mdio_o_sys, mdio_i_sys_oe;
//  SiTCP library
SiTCP_XC7K_32K_BBT_V110 SiTCP_XC7K(
  .CLK                    (USRCLK),                 // in: System clock
  .RST                    (RST),                    // in: System reset
  .TIM_1US                (TIM_1US),                // in: 1 us interval
  .TIM_1MS                (TIM_1MS),                // in: 1 ms interval
  .TIM_1S                 (TIM_1S),                 // in: 1 s interval
  .TIM_1M                 (TIM_1M),                 // in: 1 min interval
// Configuration parameters
  .FORCE_DEFAULTn         (1'b0),                   // in: Load EEPROM values
  .MODE_GMII              (1'b1),                   // in: PHY I/F mode (0:MII, 1:GMII)
  .IP_ADDR_IN             (BASE_IP_ADDR+IP_SELECT), // in: My IP address[31:0]
  .IP_ADDR_DEFAULT        (),                       // out: Default value for my IP address[31:0]
  // .MAC_SELECT             (MAC_SELECT),             // in: User can select MAC Adrress
  // .MY_MAC_ADDR            (),                       // out  : My MAC address[47:0]
  .TCP_MAIN_PORT_IN       (16'd24),                 // in: My TCP main-port #[15:0]
  .TCP_MAIN_PORT_DEFAULT  (),                       // out: Default value for my TCP main-port #[15:0]
  .TCP_SUB_PORT_IN        (16'b0),                  // in: My TCP sub-port #[15:0]
  .TCP_SUB_PORT_DEFAULT   (),                       // out: Default value for my TCP sub-port #[15:0]
  .TCP_SERVER_MAC_IN      (TCP_SERVER_MAC),         // in: Client mode, Server MAC address[47:0]
  .TCP_SERVER_MAC_DEFAULT (TCP_SERVER_MAC),         // out: Default value for the server's MAC address
  .TCP_SERVER_ADDR_IN     (TCP_SERVER_ADDR),        // in: Client mode, Server IP address[31:0]
  .TCP_SERVER_ADDR_DEFAULT(TCP_SERVER_ADDR),        // out: Default value for the server's IP address
  .TCP_SERVER_PORT_IN     (TCP_SERVER_PORT),        // in: Client mode, Server wating port#[15:0]
  .TCP_SERVER_PORT_DEFAULT(TCP_SERVER_PORT),        // out: Default value for the server port #[15:0] RBCP_PORT_IN    , // in: My UDP RBCP-port #[15:0]
  .RBCP_PORT_IN           (16'd4660),               // in: My UDP RBCP-port #[15:0]
  .RBCP_PORT_DEFAULT      (),                       // out: Default value for my UDP RBCP-port #[15:0]
  .PHY_ADDR               (PHY_ADDRESS),            // in: PHY-device MIF address[4:0]
  .MIN_RX_IPG             (4'd12),                   // in: Min. IPG byte[3:0] range of 3 to 15
// EEPROM
  .EEPROM_CS              (),                       // out: Chip select
  .EEPROM_SK              (),                       // out: Serial data clock
  .EEPROM_DI              (),                       // out: Serial write data
  .EEPROM_DO              (1'b0),                   // in : Serial read data
  // user data, intialial values are stored in the EEPROM, 0xFFFF_FC3C-3F
  .USR_REG_X3C            (),                       // out: Stored at 0xFFFF_FF3C
  .USR_REG_X3D            (),                       // out: Stored at 0xFFFF_FF3D
  .USR_REG_X3E            (),                       // out: Stored at 0xFFFF_FF3E
  .USR_REG_X3F            (),                       // out: Stored at 0xFFFF_FF3F
// MII interface
  .GMII_1000M             (1'b1),                   // in: GMII mode (0:MII, 1:GMII)
  .GMII_RSTn              (),                       // out: PHY reset
  // TX
  .GMII_TX_CLK            (gmii_tx_clk),            // in: Tx clock(2.5 or 25MHz or 125MHz)
  .GMII_TX_EN             (gmii_tx_en),             // out: Tx enable
  .GMII_TXD               (gmii_tx_d),              // out: Tx data[7:0]
  .GMII_TX_ER             (gmii_tx_er),             // out: TX error
  // RX
  .GMII_RX_CLK            (gmii_rx_clk),            // in: Rx clock(2.5 or 25MHz or 125MHz)
  .GMII_RX_DV             (gmii_rx_dv),             // in: Rx data valid
  .GMII_RXD               (gmii_rx_d),              // in: Rx data[7:0]
  .GMII_RX_ER             (gmii_rx_er),             // in: Rx error
  .GMII_CRS               (1'b0),                   // in: Carrier sense
  .GMII_COL               (1'b0),                   // in: Collision detected
  // Management IF
  .GMII_MDC               (mdc_sys),                // out: Clock for MDIO
  .GMII_MDIO_IN           (mdio_o_sys),             // in: Data
  .GMII_MDIO_OUT          (mdio_i_sys),             // out: Data, when GMII_MDIO_OE = 0, GMII_MDIO_OUT = 0. must be pullup
  .GMII_MDIO_OE           (mdio_i_sys_oe),          // out: MDIO output enable
// User I/F
  .SiTCP_RST              (TCP_RST),                // out: Reset for SiTCP and related circuits
  // TCP connection control
  .OPEN_REQ               (1'b0),                   // in: Request to connect connection
  .MAIN_OPEN_ACK          (TCP_OPEN),               // out: Acknowledge for open (=Socket busy)
  .SUB_OPEN_ACK           (),                       // out: Acknowledge for the alternative port    .TCP_OPEN_ERROR     (TCP_OPEN_ERROR   ),  // out: TCP client mode / TCP connection error ---- V2.4 -----
  .TCP_OPEN_ERROR         (tcp_open_error),         // out: TCP client mode / TCP connection error ---- V2.4 -----
  .TCP_TX_OW_ERROR        (tcp_tx_ow_error),        // out: TCP TX buffer, over write error ---- V2.4 -----
  .CLOSE_REQ              (TCP_CLOSE),              // out: Connection close
  .CLOSE_ACK              (TCP_CLOSE),              // in: Acknowledge for close
  // FIFO I/F
  .RX_FILL                (TCP_RX_WC[15:0]),        // in: Fill level[15:0]
  .RX_WR                  (TCP_RX_WR),              // out: Write enable
  .RX_DATA                (TCP_RX_DATA[7:0]),       // out: Write data[7:0]
  .TX_FULL                (TCP_TX_FULL),            // out: Almost full flag
  .TX_FILL                (),                       // out: Fill level[15:0]
  .TX_WR                  (TCP_TX_WR),              // in: Write enable
  .TX_DATA                (TCP_TX_DATA[7:0]),       // in: Write data[7:0]
  // RBCP
  .LOC_ACT                (RBCP_ACT),               // out: RBCP active
  .LOC_ADDR               (RBCP_ADDR[31:0]),        // out: Address[31:0]
  .LOC_WD                 (RBCP_WD[7:0]),           // out: Data[7:0]
  .LOC_WE                 (RBCP_WE),                // out: Write enable
  .LOC_RE                 (RBCP_RE),                // out: Read enable
  .LOC_ACK                (RBCP_ACK),               // in: Access acknowledge
  .LOC_RD                 (RBCP_RD[7:0])            // in: Read data[7:0]
);

//---------------------------------------------------------------------------
// Instantiate GT Interface
//---------------------------------------------------------------------------
wire        userclk2;
wire        eth_rst_done;
wire [15:0] status_vector;
gig_ethernet_pcs_pma_support gig_ethernet_pcs_pma_i(
  // Transceiver Interface
  .gtgrefclk              (USRCLK),
  .txp                    (GT_TXP),
  .txn                    (GT_TXN),
  .rxp                    (GT_RXP),
  .rxn                    (GT_RXN),
  .mmcm_locked_out        (),
  .userclk_out            (),         // 62.5 MHz
  .userclk2_out           (userclk2), // 125 MHz
  .rxuserclk_out          (),         // 62.5 MHz
  .rxuserclk2_out         (),         // 62.5 MHz
  .independent_clock_bufg (CLK40),
  .pma_reset_out          (),
  .resetdone              (eth_rst_done),
  // GMII Interface
  .gmii_txd               (gmii_tx_d),
  .gmii_tx_en             (gmii_tx_en),
  .gmii_tx_er             (gmii_tx_er),
  .gmii_rxd               (gmii_rx_d),
  .gmii_rx_dv             (gmii_rx_dv),
  .gmii_rx_er             (gmii_rx_er),
  .gmii_isolate           (),
  // Management: MDIO Interface
  .mdc                    (mdc_out),
  .mdio_i                 (mdio_mosi),
  .mdio_o                 (mdio_miso),
  .mdio_t                 (),
  .phyaddr                (PHY_ADDRESS),
  .configuration_vector   (5'b10000),
  .configuration_valid    (1'b0),
  // General IO's
  .status_vector          (status_vector),
  .reset                  (RST),
  .signal_detect          (GT_DETECT)
  );

assign gmii_tx_clk = userclk2;
assign gmii_rx_clk = userclk2;
assign CLKOUT = userclk2;

wire mdc_init, mdio_i_init, mdio_complete;
mdio_init mdio_init(
  .clk                    (CLKOUT),         // in : system clock (125M)
  .rst                    (~eth_rst_done),  // in : system reset
  .phyaddr                (PHY_ADDRESS),    // in : [4:0] PHY address
  .mdc                    (mdc_init),       // out: clock (1/128 system clock)
  .mdio_out               (mdio_i_init),    // out: connect this to "PCS/PMA + RocketIO" module .mdio?_i()
  .complete               (mdio_complete)   // out: initializing sequence has completed (active H)
);

assign mdc_out = mdio_complete? mdc_sys: mdc_init;
assign mdio_mosi = mdio_complete? (mdio_i_sys_oe ? mdio_i_sys:1'b1): mdio_i_init;
assign mdio_o_sys = mdio_complete? mdio_miso: 1'b1;

generate
if (USE_CHIPSCOPE == 1) begin
  wire [63:0] probe0;
  ila64 ila64 (
      .clk(CLKOUT),
      .probe0(probe0)
  );
  assign probe0[15:0] = status_vector[15:0];

// wire  Link_BASEX      = status_vector[0];
// wire  SIG_DET         = status_vector[1];
// wire  Link_SGMII      = status_vector[7];
// wire  Duplex_mode     = status_vector[12];
// wire  [1 :0]  LINKSpeed;
// assign  LINKSpeed[1:0]  = SEL_SGMII?  status_vector[11:10]: 2'b10;
// 1 1 = Reserved
// 1 0 = 1000 Mb/s; 2500 Mb/s in 2.5G mode
// 0 1 = 100 Mb/s; reserved in 2.5G mode
// 0 0 = 10 Mb/s; reserved in 2.5G mode
// wire  Link_Status     = SEL_SGMII? Link_SGMII: Link_BASEX;
// wire  [1 :0]  SGMII_LINK;
// assign  SGMII_LINK[1:0] = (
//   ((LINKSpeed[1:0]==2'b10)?   2'b00:    2'b00)|
//   ((LINKSpeed[1:0]==2'b01)?   2'b11:    2'b00)|
//   ((LINKSpeed[1:0]==2'b00)?   2'b10:    2'b00)
// );

  assign probe0[16] = eth_rst_done;
  assign probe0[17] = RST;
  assign probe0[18] = TCP_RST;
  assign probe0[19] = IP_SELECT[0];
  assign probe0[20] = mdc_out;
  assign probe0[21] = mdio_mosi;
  assign probe0[22] = mdio_miso;

  assign probe0[31:23] = 0;

  assign probe0[39:32] = gmii_tx_d[7:0];
  assign probe0[40] = gmii_tx_en;
  assign probe0[41] = gmii_tx_er;

  assign probe0[47:42] = 0;

  assign probe0[55:48] = gmii_rx_d[7:0];
  assign probe0[56] = gmii_rx_dv;
  assign probe0[57] = gmii_rx_er;

  assign probe0[63:58] = 0;

end
endgenerate

endmodule // SiTCP
