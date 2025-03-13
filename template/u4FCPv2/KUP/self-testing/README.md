# DDR4 test

1. clock input: PLL1 output 125 MHz to FPGA CLK_IN_PL (AU32)
2. calib_complete not finish -> blue LED lights
3. compare_error no error -> green LED lights
4. sys_rst connects to DIPSW[0]

# IBERT test

| Name | 10G | 16G | 25G | 28G |
| ---- | --- | --- | --- | --- |
| GT   | GTH/GTH | GTH | GTY | GTY |
| Line speed / Gbps | 10.3125 | 16.25 | 25.9375 | 28.125 |
| Note | | | NOT 25.78125 Gbps | |


1. clock input: PLL1 output 125 MHz to FPGA CLK_IN_PL (AU32)
2. ref clock input: 
* GTY: 156.25 MHz to ref0
* GTH: 156.25 MHx to ref0, except for QUAD_231 (125 MHz to ref0, 156.25 MHx to ref1)