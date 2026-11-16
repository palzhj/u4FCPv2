//------------------------------------------------------------------------------
// File       : gig_ethernet_pcs_pma_support.v
// Author     : Xilinx Inc.
//------------------------------------------------------------------------------
// (c) Copyright 2011 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//
//------------------------------------------------------------------------------
// Description: This module holds the support level for the pcs/pma core
//              This can be used as-is in a single core design, or adapted
//              for use with multi-core implementations

`timescale 1 ps/1 ps
(* DowngradeIPIdentifiedWarnings="yes" *)

//------------------------------------------------------------------------------
// The module declaration for the Core Block wrapper.
//------------------------------------------------------------------------------

module gig_ethernet_pcs_pma_support(
  // Transceiver Interface
  //----------------------
  input        gtgrefclk,
  output       txp,                   // Differential +ve of serial transmission from PMA to PMD.
  output       txn,                   // Differential -ve of serial transmission from PMA to PMD.
  input        rxp,                   // Differential +ve for serial reception from PMD to PMA.
  input        rxn,                   // Differential -ve for serial reception from PMD to PMA.
  output       userclk_out,
  output       userclk2_out,
  output       rxuserclk_out,
  output       rxuserclk2_out,
  input        independent_clock_bufg,// Freerun Independent clock,
  output       pma_reset_out,         // transceiver PMA reset signal
  output       mmcm_locked_out,       // MMCM Locked
  output       resetdone,
  // GMII Interface
  //---------------
  input [7:0]  gmii_txd,              // Transmit data from client MAC.
  input        gmii_tx_en,            // Transmit control signal from client MAC.
  input        gmii_tx_er,            // Transmit control signal from client MAC.
  output [7:0] gmii_rxd,              // Received Data to client MAC.
  output       gmii_rx_dv,            // Received control signal to client MAC.
  output       gmii_rx_er,            // Received control signal to client MAC.
  output       gmii_isolate,          // Tristate control to electrically isolate GMII.
  // Management: MDIO Interface
  //---------------------------
  input        mdc,                   // Management Data Clock
  input        mdio_i,                // Management Data In
  output       mdio_o,                // Management Data Out
  output       mdio_t,                // Management Data Tristate
  input [4:0]  phyaddr,
  input [4:0]  configuration_vector,  // Alternative to MDIO interface.
  input        configuration_valid,   // Validation signal for Config vector
  // General IO's
  //-------------
  output [15:0] status_vector,        // Core status.
  input        reset,                 // Asynchronous reset for entire core.
  input        signal_detect          // Input from PMD to indicate presence of optical input.
);

//---------------------------------------------------------------------------
// Internal signals used in this block level wrapper.
//---------------------------------------------------------------------------
// Core <=> Transceiver interconnect
wire         gtrefclk;                // High quality clock
wire         mmcm_reset;              // Reset to MMCM based on resetdone
wire         mmcm_locked;             // Signal indicating that MMCM has locked
wire         pma_reset;               // Reset synchronized to system clock
wire         txoutclk;                // txoutclk from GT transceiver (62.5MHz)
wire         rxoutclk;                // txoutclk from GT transceiver (62.5MHz)
wire         userclk;
wire         userclk2;
wire         rxuserclk;
wire         rxuserclk2;

wire [0 : 0] gtwiz_reset_all_in;
wire [0 : 0] gtwiz_reset_clk_freerun_in;
wire [0 : 0] gtwiz_reset_rx_cdr_stable_out;
wire [0 : 0] gtwiz_reset_rx_datapath_in;
wire [0 : 0] gtwiz_reset_rx_done_out;
wire [0 : 0] gtwiz_reset_rx_pll_and_datapath_in;
wire [0 : 0] gtwiz_reset_tx_datapath_in;
wire [0 : 0] gtwiz_reset_tx_done_out;
wire [0 : 0] gtwiz_reset_tx_pll_and_datapath_in;
wire [0 : 0] gtwiz_userclk_rx_active_in;
wire [0 : 0] gtwiz_userclk_tx_active_in;
wire [0 : 0] gtwiz_userclk_tx_reset_in;
wire [0 : 0] rxpmaresetdone_out;
wire [0 : 0] txresetdone_out;
wire [0 : 0] rxresetdone_out;
wire [0 : 0] rxmcommaalignen_in;
wire [0 : 0] rxpcommaalignen_in;
wire [0 : 0] txelecidle_in;
wire [1 : 0] txpd_in;
wire [1 : 0] rxpd_in;
wire [0 : 0] rxusrclk_in;
wire [0 : 0] rxusrclk2_in;
wire [0 : 0] txusrclk_in;
wire [0 : 0] txusrclk2_in;
wire [15 :0] txctrl0_in;
wire [15 :0] txctrl1_in;
wire [7 : 0] txctrl2_in;
wire [15 :0] rxctrl0_out;
wire [15 :0] rxctrl1_out;
wire [7 : 0] rxctrl2_out;
wire [7 : 0] rxctrl3_out;
wire [1 : 0] rxclkcorcnt_out;
wire [15 :0] gtwiz_userdata_rx_out;
wire [2 : 0] rxbufstatus_out;
wire [1 : 0] txbufstatus_out;
wire [0 : 0] cplllock_out;
wire [0 : 0] rx8b10ben_in;
wire [0 : 0] tx8b10ben_in;
wire [0 : 0] rxcommadeten_in;
wire [0 : 0] gthrxn_in;
wire [0 : 0] gthrxp_in;
wire [0 : 0] gthtxn_out;
wire [0 : 0] gthtxp_out;
wire [2 : 0] loopback_in;
wire [0 : 0] txinhibit_in;
wire [15 :0] gtwiz_userdata_tx_in;
wire [0 : 0] rxoutclk_out;
wire [0 : 0] txoutclk_out;
wire [9 : 0] drpaddr_in;
wire [0 : 0] drpclk_in;
wire [15 :0] drpdi_in;
wire [15 :0] drpdo_out;
wire [0 : 0] drpen_in;
wire [0 : 0] drprdy_out;
wire [0 : 0] drpwe_in;

gig_ethernet_pcs_pma pcs_pma_i(
  // Transceiver Interface
  //----------------------
  .resetdone                            (resetdone),
  .mmcm_reset                           (mmcm_reset),
  .mmcm_locked                          (mmcm_locked),
  .userclk                              (userclk),
  .userclk2                             (userclk2),
  .rxuserclk                            (rxuserclk),
  .rxuserclk2                           (rxuserclk2),
  .independent_clock_bufg               (independent_clock_bufg),
  .pma_reset                            (pma_reset),
  // GMII Interface
  //---------------
  .gmii_txd                             (gmii_txd),
  .gmii_tx_en                           (gmii_tx_en),
  .gmii_tx_er                           (gmii_tx_er),
  .gmii_rxd                             (gmii_rxd),
  .gmii_rx_dv                           (gmii_rx_dv),
  .gmii_rx_er                           (gmii_rx_er),
  .gmii_isolate                         (gmii_isolate),
  // Management: MDIO Interface
  //---------------------------
  .mdc                                  (mdc),
  .mdio_i                               (mdio_i),
  .mdio_o                               (mdio_o),
  .mdio_t                               (mdio_t),
  .phyaddr                              (phyaddr),
  .configuration_vector                 (configuration_vector),
  .configuration_valid                  (configuration_valid),
  // General IO's
  //-------------
  .status_vector                        (status_vector),  // Core status.
  .reset                                (pma_reset),      // Asynchronous reset for entire core.
  .gtwiz_userclk_tx_active_out          (gtwiz_userclk_tx_active_in),
  .gtwiz_userclk_tx_reset_out           (gtwiz_userclk_tx_reset_in),
  .gtwiz_reset_clk_freerun_out          (gtwiz_reset_clk_freerun_in),
  .gtwiz_reset_tx_datapath_out          (gtwiz_reset_tx_datapath_in),
  .gtwiz_reset_rx_datapath_out          (gtwiz_reset_rx_datapath_in),
  .gtwiz_reset_all_out                  (gtwiz_reset_all_in),
  .gtwiz_userclk_rx_active_out          (gtwiz_userclk_rx_active_in),
  .gtwiz_reset_tx_pll_and_datapath_out  (gtwiz_reset_tx_pll_and_datapath_in),
  .gtwiz_reset_rx_pll_and_datapath_out  (gtwiz_reset_rx_pll_and_datapath_in),
  .gtwiz_reset_tx_done_in               (gtwiz_reset_tx_done_out),
  .gtwiz_reset_rx_done_in               (gtwiz_reset_rx_done_out),
  .rxpmaresetdone_in                    (rxpmaresetdone_out),
  .txresetdone_in                       (txresetdone_out),
  .rxresetdone_in                       (rxresetdone_out),
  .rxmcommaalignen_out                  (rxmcommaalignen_in),
  .rxpcommaalignen_out                  (rxpcommaalignen_in),
  .txelecidle_out                       (txelecidle_in),
  .txpd_out                             (txpd_in),
  .rxpd_out                             (rxpd_in),
  .rxusrclk_out                         (rxusrclk_in),
  .rxusrclk2_out                        (rxusrclk2_in),
  .txusrclk_out                         (txusrclk_in),
  .txusrclk2_out                        (txusrclk2_in),
  .txctrl0_out                          (txctrl0_in),
  .txctrl1_out                          (txctrl1_in),
  .txctrl2_out                          (txctrl2_in),
  .gtwiz_userdata_tx_out                (gtwiz_userdata_tx_in),
  .rxctrl0_in                           (rxctrl0_out),
  .rxctrl1_in                           (rxctrl1_out),
  .rxctrl2_in                           (rxctrl2_out),
  .rxctrl3_in                           (rxctrl3_out),
  .rxclkcorcnt_in                       (rxclkcorcnt_out),
  .gtwiz_userdata_rx_in                 (gtwiz_userdata_rx_out),

  .rxbufstatus_in                       (rxbufstatus_out),
  .txbufstatus_in                       (txbufstatus_out),
  .cplllock_in                          (cplllock_out),
  .rx8b10ben_out                        (rx8b10ben_in),
  .tx8b10ben_out                        (tx8b10ben_in),
  .rxcommadeten_out                     (rxcommadeten_in),

  .signal_detect                        (signal_detect)   // Input from PMD to indicate presence of optical input.
);

//----------------------------------------------------------------------------
// Instantiate the clocking module.
//----------------------------------------------------------------------------
BUFG_GT usrclk2_bufg_inst(
  .I     (txoutclk),
  .CE    (1'b1),
  .O     (userclk2)
);

BUFG_GT usrclk_bufg_inst(
  .I     (txoutclk),
  .CE    (1'b1),
  .DIV   (3'b001),
  .O     (userclk)
);
assign mmcm_locked = 1'b1;

wire rxoutclk_buf;
BUFG_GT rxrecclk_bufg_inst(
  .I     (rxoutclk),
  .CE    (1'b1),
  .O     (rxoutclk_buf)
);
assign rxuserclk2 = rxoutclk_buf;
assign rxuserclk  = rxoutclk_buf;

assign userclk_out    = userclk;
assign userclk2_out   = userclk2;
assign rxuserclk_out  = rxuserclk;
assign rxuserclk2_out = rxuserclk2;

//---------------------------------------------------------------------------
// Transceiver PMA reset circuitry
//---------------------------------------------------------------------------
async2sync_reset core_resets_i(
  .rst_in         (reset),
  .clk            (independent_clock_bufg),
  .rst_out        (pma_reset)
);
assign pma_reset_out    = pma_reset;

assign mmcm_locked_out  = mmcm_locked;

assign gthrxn_in[0]     = rxn;
assign gthrxp_in[0]     = rxp;
assign txn              = gthtxn_out[0];
assign txp              = gthtxp_out[0];
assign rxoutclk         = rxoutclk_out;
assign txoutclk         = txoutclk_out;

gig_ethernet_pcs_pma_gt gig_ethernet_pcs_pma_gt_i(
  .cplllock_out                       (cplllock_out),
  .cpllrefclksel_in                   (3'b111),
  .gtgrefclk_in                       (gtgrefclk),
  .dmonitorout_out                    (),
  .drpclk_in                          (independent_clock_bufg),
  .drpaddr_in                         (10'b0),
  .drpdi_in                           (16'b0),
  .drpdo_out                          (),
  .drpen_in                           (1'b0),
  .drprdy_out                         (),
  .drpwe_in                           (1'b0),
  .eyescandataerror_out               (),
  .eyescanreset_in                    (1'b0),
  .eyescantrigger_in                  (1'b0),
  .gthrxn_in                          (gthrxn_in),
  .gthrxp_in                          (gthrxp_in),
  .gthtxn_out                         (gthtxn_out),
  .gthtxp_out                         (gthtxp_out),
  .gtrefclk0_in                       (1'b0),
  .gtrefclk1_in                       (1'b0),
  .gtwiz_reset_all_in                 (gtwiz_reset_all_in),
  .gtwiz_reset_clk_freerun_in         (gtwiz_reset_clk_freerun_in),
  .gtwiz_reset_rx_cdr_stable_out      (gtwiz_reset_rx_cdr_stable_out),
  .gtwiz_reset_rx_datapath_in         (gtwiz_reset_rx_datapath_in),
  .gtwiz_reset_rx_done_out            (gtwiz_reset_rx_done_out),
  .gtwiz_reset_rx_pll_and_datapath_in (gtwiz_reset_rx_pll_and_datapath_in),
  .gtwiz_reset_tx_datapath_in         (gtwiz_reset_tx_datapath_in),
  .gtwiz_reset_tx_done_out            (gtwiz_reset_tx_done_out),
  .gtwiz_reset_tx_pll_and_datapath_in (gtwiz_reset_tx_pll_and_datapath_in),
  .gtwiz_userclk_rx_active_in         (gtwiz_userclk_rx_active_in),
  .gtwiz_userclk_tx_active_in         (gtwiz_userclk_tx_active_in),
  .gtwiz_userclk_tx_reset_in          (gtwiz_userclk_tx_reset_in),
  .gtwiz_userdata_rx_out              (gtwiz_userdata_rx_out),
  .gtwiz_userdata_tx_in               (gtwiz_userdata_tx_in),
  .loopback_in                        (3'b000),
  .pcsrsvdin_in                       (16'h0000),
  .rx8b10ben_in                       (rx8b10ben_in),
  .rxbufstatus_out                    (rxbufstatus_out),
  .rxbyteisaligned_out                (),
  .rxbyterealign_out                  (),
  .rxcdrhold_in                       (1'b0),
  .rxclkcorcnt_out                    (rxclkcorcnt_out),
  .rxbufreset_in                      (1'b0),
  .rxcommadet_out                     (),
  .rxcommadeten_in                    (rxcommadeten_in),
  .rxctrl0_out                        (rxctrl0_out),
  .rxctrl1_out                        (rxctrl1_out),
  .rxctrl2_out                        (rxctrl2_out),
  .rxctrl3_out                        (rxctrl3_out),
  .rxdfelpmreset_in                   (1'b0),
  .rxlpmen_in                         (1'b1),
  .rxmcommaalignen_in                 (rxmcommaalignen_in),
  .rxoutclk_out                       (rxoutclk_out),
  .rxpcommaalignen_in                 (rxpcommaalignen_in),
  .rxpcsreset_in                      (1'b0),
  .rxpd_in                            (rxpd_in),
  .rxpmareset_in                      (1'b0),
  .rxpmaresetdone_out                 (rxpmaresetdone_out),
  .rxpolarity_in                      (1'b0),
  .rxprbscntreset_in                  (1'b0),
  .rxprbserr_out                      (),
  .rxprbssel_in                       (3'b000),
  .rxrate_in                          (3'b000),
  .rxresetdone_out                    (rxresetdone_out),
  .rxusrclk2_in                       (rxusrclk2_in),
  .rxusrclk_in                        (rxusrclk_in),
  .tx8b10ben_in                       (tx8b10ben_in),
  .txbufstatus_out                    (txbufstatus_out),
  .txctrl0_in                         (txctrl0_in),
  .txctrl1_in                         (txctrl1_in),
  .txctrl2_in                         (txctrl2_in),
  .txdiffctrl_in                      (5'b11000),
  .txelecidle_in                      (txelecidle_in),
  .txinhibit_in                       (1'b0),
  .txoutclk_out                       (txoutclk_out),
  .txpcsreset_in                      (1'b0),
  .txpd_in                            (txpd_in),
  .txpmareset_in                      (1'b0),
  .txpmaresetdone_out                 (),
  .txpolarity_in                      (1'b0),
  .txpostcursor_in                    (5'b00000),
  .txprbsforceerr_in                  (1'b0),
  .txprbssel_in                       (3'b000),
  .txprecursor_in                     (5'b00000),
  .txprgdivresetdone_out              (),
  .txresetdone_out                    (txresetdone_out),
  .txusrclk2_in                       (txusrclk2_in),
  .txusrclk_in                        (txusrclk_in)
);

endmodule // gig_ethernet_pcs_pma_support
