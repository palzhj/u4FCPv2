`timescale 1ns / 1ps

module tcp_test_tb;

// Inputs
reg clk;
reg rst;
reg [7 :0]  tx_rate;
reg [63:0]  num_of_data;
reg         data_gen;
reg         loopback;
reg [2 :0]  word_len;
reg         select_seq;
reg [31:0]  seq_pattern;
reg [23:0]  blk_size;
reg         ins_error;

reg         sitcpxg_established;
reg         sitcpxg_rx_clr_enb;
reg [15:0]  sitcpxg_rx_wadr;
reg [7 :0]  sitcpxg_rx_wenb;
reg [63:0]  sitcpxg_rx_wdat;
reg         sitcpxg_tx_afull;

// Outputs
wire [15:0] sitcpxg_rx_size;
wire        sitcpxg_rx_clr_req;
wire [15:0] sitcpxg_rx_radr;
wire [63:0] sitcpxg_tx_d;
wire [3 :0] sitcpxg_tx_b;

parameter clk_freq = 156_250_000;
parameter clk_period = 1_000_000_000/clk_freq;
initial begin
  clk <= 0;
  forever #(clk_period/2) clk <= ~clk;
end

initial begin
  // Initialize Inputs
  rst = 1;
  sitcpxg_established = 0;
  tx_rate = 10;
  num_of_data = 640;
  data_gen = 0;
  loopback = 0;
  word_len = 7;
  select_seq = 0;
  seq_pattern = 64'h6080_8040;
  blk_size = 64;
  ins_error = 0;
  sitcpxg_rx_clr_enb = 1;
  sitcpxg_rx_wadr = 0;
  sitcpxg_rx_wenb = 0;
  sitcpxg_rx_wdat = 0;
  sitcpxg_tx_afull = 0;

  // Wait 100 ns for global reset to finish
  #100;
  rst = 0;
  #500;
  // Add stimulus here
  sitcpxg_established = 1;
  #500;
  data_gen = 1;
  #460;
  @(posedge clk) ins_error = 1'b1;
  @(posedge clk) ins_error = 1'b0;


end

tcp_test u_tcp_test(
    .CLK156M             (clk),
    .RSTs                (rst),
    .TX_RATE             (tx_rate),
    .NUM_OF_DATA         (num_of_data),
    .DATA_GEN            (data_gen),
    .LOOPBACK            (loopback),
    .WORD_LEN            (word_len),
    .SELECT_SEQ          (select_seq),
    .SEQ_PATTERN         (seq_pattern),
    .BLK_SIZE            (blk_size),
    .INS_ERROR           (ins_error),
    .SiTCPXG_ESTABLISHED (sitcpxg_established),
    .SiTCPXG_RX_SIZE     (sitcpxg_rx_size),
    .SiTCPXG_RX_CLR_ENB  (sitcpxg_rx_clr_enb),
    .SiTCPXG_RX_CLR_REQ  (sitcpxg_rx_clr_req),
    .SiTCPXG_RX_RADR     (sitcpxg_rx_radr),
    .SiTCPXG_RX_WADR     (sitcpxg_rx_wadr),
    .SiTCPXG_RX_WENB     (sitcpxg_rx_wenb),
    .SiTCPXG_RX_WDAT     (sitcpxg_rx_wdat),
    .SiTCPXG_TX_AFULL    (sitcpxg_tx_afull),
    .SiTCPXG_TX_D        (sitcpxg_tx_d),
    .SiTCPXG_TX_B        (sitcpxg_tx_b)
);

endmodule
