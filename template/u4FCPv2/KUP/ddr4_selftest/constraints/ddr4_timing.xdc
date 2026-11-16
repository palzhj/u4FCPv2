#--------------------------------------------------------------------------------
# u4FCP v2 DDR4 self-test - timing constraints for implementation only
#
# The DDR4 self-test register file runs in the 125 MHz housekeeping clock domain
# (clk_out3_clk_wiz) while the test engines run in the MIG ui_clk domains
# (mmcm_clkout0 for socket A, mmcm_clkout0_1 for socket B).
#
# Every crossing between these domains is asynchronous by design:
#   * control (pattern, limit, start/abort) is passed as toggles and captured by
#     2-FF synchronizers in the ui_clk domain,
#   * status is passed through a request/acknowledge mailbox (data is static
#     while the acknowledge toggle crosses).
# The domains are therefore declared asynchronous. The 64 MHz clock domain is
# included because clk_external_enable crosses into it through a 2-FF
# synchronizer as well.
#
# This file is an implementation only constraint (used_in_synthesis = false)
# because the MIG clocks are not present while the top level is synthesized
# (the MIG IPs are synthesized out of context).
#--------------------------------------------------------------------------------
set_clock_groups -asynchronous \
  -group [get_clocks clk_out3_clk_wiz] \
  -group [get_clocks clk_out1_clk_wiz_64M] \
  -group [get_clocks mmcm_clkout0] \
  -group [get_clocks mmcm_clkout0_1]

