# Clock map and config

Si5345 config files generated by the [ClockBuilder Pro v4.13.0.2](https://www.skyworksinc.com/en/application-pages/clockbuilder-pro-software)

## PLL 0
| Name | CLK_IN0 | CLK_IN1 | CLK_IN2 | CLK_IN3 | OUT0 | OUT1 | OUT2 | OUT3 | OUT4 | OUT5 | OUT6 | OUT7 | OUT8 | OUT9 |
|--| ------- | ------- | ------- | ------- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
| Note| OSC125  | SW OUT6  | NC      | FB      | SW IN9 | REF227_0 | REF226_0 | REF225_0 | REF224_0 | REF130_0 | REF129_0 | REF128_0 | REF127_0 | FB |
|default_0| 125M  | 125M   | -       | FB(125M) | 156.25M | 156.25M | 156.25M | 156.25M | 156.25M | 156.25M | 156.25M | 156.25M | 156.25M | FB(125M) |

## PLL 1
| Name | CLK_IN0 | CLK_IN1 | CLK_IN2 | CLK_IN3 | OUT0 | OUT1 | OUT2 | OUT3 | OUT4 | OUT5 | OUT6 | OUT7 | OUT8 | OUT9 |
|--| ------- | ------- | ------- | ------- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- | ---- |
| Note| OSC125  | SW OUT7 | NC      | FB      | SW IN8 | FPGA_CLK_PL | REF132_0 | REF131_0 | REF231_1 | REF231_0 | REF230_0 | REF229_0 | REF228_0 | FB |
|default_1| 125M  | 125M   | -    | FB(125M) | 125M |          125M | 156.25M | 156.25M | 156.25M | 125M | 156.25M | 156.25M | 156.25M | FB(125M) |