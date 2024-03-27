#!/usr/bin/python
# This is adn4604.py file
# author: zhj@ihep.ac.cn
# 2024-02-01 created
import lib
from lib import i2c
from time import sleep

# User configuration defines for ADN4604 Clock switch output config

# Inputs
ADN4604_IN_0                = 0
ADN4604_IN_1                = 1
ADN4604_IN_3                = 2
ADN4604_IN_4                = 3
ADN4604_IN_AMC2RTM_TCLK     = 4
ADN4604_IN_5                = 5
ADN4604_IN_GCLK             = 6
ADN4604_IN_FPGA_CLK_OUT     = 7
ADN4604_IN_8                = 8
ADN4604_IN_PLL2_OUT         = 9
ADN4604_IN_FMC3_CLK_M2C     = 10
ADN4604_IN_FMC3_CLK_BIDIR   = 11
ADN4604_IN_FMC2_CLK_M2C     = 12
ADN4604_IN_FMC2_CLK_BIDIR   = 13
ADN4604_IN_LEMO_CLK         = 14
ADN4604_IN_AMC2RTM_CLK      = 15

# Output select
ADN4604_CFG_OUT_0 = 0                       # RTM2AMC_OUT
ADN4604_CFG_OUT_1 = ADN4604_IN_PLL2_OUT     # MMCX_OUT
ADN4604_CFG_OUT_2 = ADN4604_IN_PLL2_OUT     # FMC2_OUT
ADN4604_CFG_OUT_3 = 0                       #
ADN4604_CFG_OUT_4 = ADN4604_IN_PLL2_OUT     # FMC3_OUT
ADN4604_CFG_OUT_5 = 0                       #
ADN4604_CFG_OUT_6 = ADN4604_IN_AMC2RTM_CLK  # PPL2_IN
ADN4604_CFG_OUT_7 = 0                       #
ADN4604_CFG_OUT_8 = ADN4604_IN_AMC2RTM_CLK  # FPGA_SW_IN
ADN4604_CFG_OUT_9 = 0                       #
ADN4604_CFG_OUT_10= ADN4604_IN_PLL2_OUT     # MGT115_1
ADN4604_CFG_OUT_11= ADN4604_IN_PLL2_OUT     # MGT116_1
ADN4604_CFG_OUT_12= ADN4604_IN_PLL2_OUT     # MGT117_1
ADN4604_CFG_OUT_13= ADN4604_IN_PLL2_OUT     # MGT118_1
ADN4604_CFG_OUT_14= 0                       #
ADN4604_CFG_OUT_15= 0                       #

# Output enable flags
ADN4604_EN_OUT_0  = 0       # RTM2AMC_OUT
ADN4604_EN_OUT_1  = 1       # MMCX_OUT
ADN4604_EN_OUT_2  = 0       # FMC2_OUT
ADN4604_EN_OUT_3  = 0       #
ADN4604_EN_OUT_4  = 0       # FMC3_OUT
ADN4604_EN_OUT_5  = 0       #
ADN4604_EN_OUT_6  = 1       # PPL2_IN
ADN4604_EN_OUT_7  = 0       #
ADN4604_EN_OUT_8  = 1       # FPGA_SW_IN
ADN4604_EN_OUT_9  = 0       #
ADN4604_EN_OUT_10 = 0       # MGT115_1
ADN4604_EN_OUT_11 = 0       # MGT116_1
ADN4604_EN_OUT_12 = 0       # MGT117_1
ADN4604_EN_OUT_13 = 0       # MGT118_1
ADN4604_EN_OUT_14 = 0       #
ADN4604_EN_OUT_15 = 0       #

# ADN4604 register address
ADN_RESET_REG             = 0x00
ADN_TX_CON_OUT0           = 0x20
ADN_XPT_UPDATE_REG        = 0x80
ADN_XPT_MAP_TABLE_SEL_REG = 0x81
ADN_XPT_BROADCAST         = 0x82
ADN_XPT_MAP0_CON_REG      = 0x90
ADN_XPT_MAP1_CON_REG      = 0x98
ADN_XPT_STATUS_REG        = 0xB0
ADN_TERMINATION_CTL_REG   = 0xF0

# MAP_TABLE_SEL
ADN_XPT_MAP0              = 0x00
ADN_XPT_MAP1              = 0x01

# TX Basic Control Register flags:
# [6] TX CTL SELECT - 0: PE and output level control is derived from common lookup table
#                     1: PE and output level control is derived from per port drive control registers
# [5:4] TX EN[1:0]  - 00: TX disabled, lowest power state
#                     01: TX standby
#                     10: TX squelched
#                     11: TX enabled
# [3] Reserved      - Set to 0
# [2:0] PE[2:0]     - If TX CTL SELECT = 0,
#                       000: Table Entry 0
#                       001: Table Entry 1
#                       010: Table Entry 2
#                       011: Table Entry 3
#                       100: Table Entry 4
#                       101: Table Entry 5
#                       110: Table Entry 6
#                       111: Table Entry 7
#                   - If TX CTL SELECT = 1, PE[2:0] are ignored
TX_DISABLED = 0x00
TX_STANDBY  = 0x10
TX_SQUELCHED= 0x20
TX_ENABLED  = 0x30

# | PE Setting | Main Tap Current (mA) | Delayed Tap Current (mA) | Boost (dB) | Overshoot (%) | DC Swing (mV p-p) |
# | 0 | 16 | 0 | 0.0  | 0    | 800
# | 1 | 16 | 2 | 2.0  | 25   | 800
# | 2 | 16 | 5 | 4.2  | 62.5 | 800
# | 3 | 16 | 8 | 6.0  | 100  | 800
# | 4 | 11 | 8 | 7.8  | 145  | 550
# | 5 | 8  | 8 | 9.5  | 200  | 400
# | 6 | 4  | 6 | 12.0 | 300  | 300
# | 7 | 4  | 6 | 12.0 | 300  | 300
PE_TABLE0  = 0x0
PE_TABLE1  = 0x1
PE_TABLE2  = 0x2
PE_TABLE3  = 0x3
PE_TABLE4  = 0x4
PE_TABLE5  = 0x5
PE_TABLE6  = 0x6
PE_TABLE7  = 0x7

# Termination disable
RXW_TERM = 0x1    # Input[7:0]   (West)  termination control
RXE_TERM = 0x2    # Input[15:8]  (East)  termination control
TXS_TERM = 0x4    # Output[7:0]  (South) termination control
TXN_TERM = 0x8    # Output[15:8] (North) termination control

I2C_DELAY = 0.0

class adn4604(object):
    """Class for communicating with ADN4604 using i2c bus."""
    def __init__(self, i2c_addr = 0b1001_0010, base_address = 0x00020000, clk_freq = 125, i2c_freq = 100):
        self.i2c = i2c.i2c(device_address = i2c_addr, base_address = base_address,
                    clk_freq = clk_freq, i2c_freq = i2c_freq)

    def reset(self): # Software Reset
        self.i2c.write8(0x01, 1, ADN_RESET_REG)
        sleep(I2C_DELAY)

    def update(self): # Activates the current stored configuration
        self.i2c.write8(0x1, 1, ADN_XPT_UPDATE_REG)
        sleep(I2C_DELAY)

    def active_map(self, i = ADN_XPT_MAP0):
        self.i2c.write8(i, 1, ADN_XPT_MAP_TABLE_SEL_REG)
        sleep(I2C_DELAY)

    def xpt_config(self): # Configures the cross-connection map
        map0 = bytes()
        map0 += bytes([(ADN4604_CFG_OUT_1<<4 | ADN4604_CFG_OUT_0) & 0xFF])
        map0 += bytes([(ADN4604_CFG_OUT_3<<4 | ADN4604_CFG_OUT_2) & 0xFF])
        map0 += bytes([(ADN4604_CFG_OUT_5<<4 | ADN4604_CFG_OUT_4) & 0xFF])
        map0 += bytes([(ADN4604_CFG_OUT_7<<4 | ADN4604_CFG_OUT_6) & 0xFF])
        map0 += bytes([(ADN4604_CFG_OUT_9<<4 | ADN4604_CFG_OUT_8) & 0xFF])
        map0 += bytes([(ADN4604_CFG_OUT_11<<4 | ADN4604_CFG_OUT_10) & 0xFF])
        map0 += bytes([(ADN4604_CFG_OUT_13<<4 | ADN4604_CFG_OUT_12) & 0xFF])
        map0 += bytes([(ADN4604_CFG_OUT_15<<4 | ADN4604_CFG_OUT_14) & 0xFF])
        self.i2c.writeBytes(map0, 1, ADN_XPT_MAP0_CON_REG)
        sleep(I2C_DELAY)

        self.active_map(ADN_XPT_MAP0)
        self.update()

    def termination_ctl(self, term_cfg):
        self.i2c.write8(term_cfg, 1, ADN_TERMINATION_CTL_REG)
        sleep(I2C_DELAY)

    def tx_control(self, ch, tx_mode): # Sets the output status
        tx_control_addr = (ch + ADN_TX_CON_OUT0) & 0xFF # TX Basic Control Register offset ix 0x20
        self.i2c.write8(tx_mode, 1, tx_control_addr)
        sleep(I2C_DELAY)

    def config(self):
        self.termination_ctl(0)

        self.xpt_config()

        out_enable_flag = \
            (ADN4604_EN_OUT_0 << 0) | \
            (ADN4604_EN_OUT_1 << 1) | \
            (ADN4604_EN_OUT_2 << 2) | \
            (ADN4604_EN_OUT_3 << 3) | \
            (ADN4604_EN_OUT_4 << 4) | \
            (ADN4604_EN_OUT_5 << 5) | \
            (ADN4604_EN_OUT_6 << 6) | \
            (ADN4604_EN_OUT_7 << 7) | \
            (ADN4604_EN_OUT_8 << 8) | \
            (ADN4604_EN_OUT_9 << 9) | \
            (ADN4604_EN_OUT_10 << 10) | \
            (ADN4604_EN_OUT_11 << 11) | \
            (ADN4604_EN_OUT_12 << 12) | \
            (ADN4604_EN_OUT_13 << 13) | \
            (ADN4604_EN_OUT_14 << 14) | \
            (ADN4604_EN_OUT_15 << 15)
        # print(out_enable_flag)
        for i in range(16):
            if(( out_enable_flag >> i ) & 0x1):
                self.tx_control(i, TX_ENABLED|PE_TABLE5) # Enable desired outputs
            else:
                self.tx_control(i, TX_DISABLED)

    def tx_status(self, ch):
        tx_control_addr = (ch + ADN_TX_CON_OUT0) & 0xFF # TX Basic Control Register offset ix 0x20
        return 1 if TX_ENABLED & self.i2c.read8(1, tx_control_addr) else 0

    def print_ch_sel(self, input):
        return "I"+'{:02d}'.format(input)

    def get_tx_status(self):
        temp = self.i2c.readBytes(8, 1, ADN_XPT_STATUS_REG)
        print("CLK   \tO00 O01 O02 O03 O04 O05 O06 O07 O08 O09 O10 O11 O12 O13 O14 O15")
        print("Switch\t%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s"%(\
            self.print_ch_sel(temp[0]&0xF), self.print_ch_sel((temp[0]>>4)&0xF),
            self.print_ch_sel(temp[1]&0xF), self.print_ch_sel((temp[1]>>4)&0xF),
            self.print_ch_sel(temp[2]&0xF), self.print_ch_sel((temp[2]>>4)&0xF),
            self.print_ch_sel(temp[3]&0xF), self.print_ch_sel((temp[3]>>4)&0xF),
            self.print_ch_sel(temp[4]&0xF), self.print_ch_sel((temp[4]>>4)&0xF),
            self.print_ch_sel(temp[5]&0xF), self.print_ch_sel((temp[5]>>4)&0xF),
            self.print_ch_sel(temp[6]&0xF), self.print_ch_sel((temp[6]>>4)&0xF),
            self.print_ch_sel(temp[7]&0xF), self.print_ch_sel((temp[7]>>4)&0xF)))
        print("OEN  \t%d   %d   %d   %d   %d   %d   %d   %d   %d   %d   %d   %d   %d   %d   %d   %d"%(\
            self.tx_status(0), self.tx_status(1), self.tx_status(2), self.tx_status(3),
            self.tx_status(4), self.tx_status(5), self.tx_status(6), self.tx_status(7),
            self.tx_status(8), self.tx_status(9), self.tx_status(10), self.tx_status(11),
            self.tx_status(12), self.tx_status(13), self.tx_status(14), self.tx_status(15)))
