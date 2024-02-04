#!/usr/bin/python
# This is gpio.py file
# author: zhj@ihep.ac.cn
# 2024-02-03 created
import board
from board import tca9554
from time import sleep

RTM_GPIO_ADDR  = 0b0111_1000
FPGA_GPIO_ADDR = 0b0111_1010
FMC_GPIO_ADDR  = 0b0111_1100

GPIO_PIN0 = 0x01
GPIO_PIN1 = 0x02
GPIO_PIN2 = 0x04
GPIO_PIN3 = 0x08
GPIO_PIN4 = 0x10
GPIO_PIN5 = 0x20
GPIO_PIN6 = 0x40
GPIO_PIN7 = 0x80

############################################################
# RTM GPIO
RTM_PIN_BLUE_LED    = GPIO_PIN0
RTM_PIN_RED_LED     = GPIO_PIN1
RTM_PIN_GREEN_LED   = GPIO_PIN2
RTM_PIN_PE          = GPIO_PIN3
RTM_PIN_PMBUS_INT   = GPIO_PIN4
RTM_PIN_CLK_INT     = GPIO_PIN5
RTM_PIN_PG          = GPIO_PIN6
RTM_PIN_HANDLE      = GPIO_PIN7

RTM_GPIO_INPUT_0 = 0  # BLUE_LED, 0: Light
RTM_GPIO_INPUT_1 = 0  # LED_RED
RTM_GPIO_INPUT_2 = 0  # LED GREEN
RTM_GPIO_INPUT_3 = 0  # POWER ENABLE in RTM mode
RTM_GPIO_INPUT_4 = 1  # PMBUS_ALERTb
RTM_GPIO_INPUT_5 = 1  # CLK_INTb
RTM_GPIO_INPUT_6 = 1  # PG
RTM_GPIO_INPUT_7 = 1  # RTM_HANDLE, 1: Open

RTM_GPIO_DEFAULT_0  = 0 # Output default value
RTM_GPIO_DEFAULT_1  = 1
RTM_GPIO_DEFAULT_2  = 1
RTM_GPIO_DEFAULT_3  = 1
RTM_GPIO_DEFAULT_4  = 1
RTM_GPIO_DEFAULT_5  = 1
RTM_GPIO_DEFAULT_6  = 1
RTM_GPIO_DEFAULT_7  = 1

RTM_GPIO_INV_0  = 0 # Input Polarity Inversion
RTM_GPIO_INV_1  = 0
RTM_GPIO_INV_2  = 0
RTM_GPIO_INV_3  = 0
RTM_GPIO_INV_4  = 0
RTM_GPIO_INV_5  = 0
RTM_GPIO_INV_6  = 0
RTM_GPIO_INV_7  = 0

############################################################
# FPGA GPIO
FPGA_PIN_PROG_B         = GPIO_PIN0
FPGA_PIN_INIT_B         = GPIO_PIN1
FPGA_PIN_DONE           = GPIO_PIN2
FPGA_PIN_RST_B          = GPIO_PIN3
FPGA_PIN_JTAG_CON_DIS   = GPIO_PIN4
FPGA_PIN_JTAG_FMC2_DIS  = GPIO_PIN5
FPGA_PIN_JTAG_FMC3_DIS  = GPIO_PIN6
FPGA_PIN_RTM_MODE       = GPIO_PIN7

FPGA_GPIO_INPUT_0 = 0  # PROG_B
FPGA_GPIO_INPUT_1 = 1  # INIT_B
FPGA_GPIO_INPUT_2 = 1  # DONE
FPGA_GPIO_INPUT_3 = 0  # RST_B
FPGA_GPIO_INPUT_4 = 0  # JTAG_CON_DIS
FPGA_GPIO_INPUT_5 = 0  # JTAG_FMC2_DIS
FPGA_GPIO_INPUT_6 = 0  # JTAG_FMC3_DIS
FPGA_GPIO_INPUT_7 = 1  # RTM_MODE

FPGA_GPIO_DEFAULT_0  = 1 # Output default value
FPGA_GPIO_DEFAULT_1  = 1
FPGA_GPIO_DEFAULT_2  = 1
FPGA_GPIO_DEFAULT_3  = 1
FPGA_GPIO_DEFAULT_4  = 0
FPGA_GPIO_DEFAULT_5  = 1
FPGA_GPIO_DEFAULT_6  = 1
FPGA_GPIO_DEFAULT_7  = 1

FPGA_GPIO_INV_0  = 0 # Input Polarity Inversion
FPGA_GPIO_INV_1  = 0
FPGA_GPIO_INV_2  = 0
FPGA_GPIO_INV_3  = 0
FPGA_GPIO_INV_4  = 0
FPGA_GPIO_INV_5  = 0
FPGA_GPIO_INV_6  = 0
FPGA_GPIO_INV_7  = 0

############################################################
# FMC GPIO
FMC_PIN_0       = GPIO_PIN0
FMC_PIN_1       = GPIO_PIN1
FMC_PIN_CLK_DIR2= GPIO_PIN2
FMC_PIN_CLK_DIR3= GPIO_PIN3
FMC_PIN_PRSNT2  = GPIO_PIN4
FMC_PIN_PRSNT3  = GPIO_PIN5
FMC_PIN_PG2     = GPIO_PIN6
FMC_PIN_PG3     = GPIO_PIN7

FMC_GPIO_INPUT_0 = 1  #
FMC_GPIO_INPUT_1 = 1  #
FMC_GPIO_INPUT_2 = 1  # CLK_DIR2
FMC_GPIO_INPUT_3 = 1  # CLK_DIR3
FMC_GPIO_INPUT_4 = 1  # PRSNT2
FMC_GPIO_INPUT_5 = 1  # PRSNT3
FMC_GPIO_INPUT_6 = 1  # PG2
FMC_GPIO_INPUT_7 = 1  # PG3

FMC_GPIO_DEFAULT_0  = 1 # Output default value
FMC_GPIO_DEFAULT_1  = 1
FMC_GPIO_DEFAULT_2  = 1
FMC_GPIO_DEFAULT_3  = 1
FMC_GPIO_DEFAULT_4  = 1
FMC_GPIO_DEFAULT_5  = 1
FMC_GPIO_DEFAULT_6  = 1
FMC_GPIO_DEFAULT_7  = 1

FMC_GPIO_INV_0  = 0 # Input Polarity Inversion
FMC_GPIO_INV_1  = 0
FMC_GPIO_INV_2  = 0
FMC_GPIO_INV_3  = 0
FMC_GPIO_INV_4  = 1 # PRSNT_L2
FMC_GPIO_INV_5  = 1 # PRSNT_L2
FMC_GPIO_INV_6  = 0
FMC_GPIO_INV_7  = 0

# When ‘CLK_DIR’ is connected to ‘3P3V’ via a 10KΩ pull up resistor on the mezzanine module,
# then, CLK[2..3]_BIDIR_P, CLK[2..3]_BIDIR_N two differential pairs that are assigned for clock
# signals, which are driven from the carrier card to the FMC IO mezzanine module,
# and, CLK[0..1]_M2C_P, CLK[0..1]_M2C_N are two differential pairs that are assigned for clock
# signals, which are driven from the FMC IO mezzanine module to the carrier card.

class gpio(object):
    """Class for communicating with gpio using multi-tca9554."""
    def __init__(self):
        self.rtm  = tca9554.tca9554(i2c_addr=RTM_GPIO_ADDR)
        self.fpga = tca9554.tca9554(i2c_addr=FPGA_GPIO_ADDR)
        self.fmc  = tca9554.tca9554(i2c_addr=FMC_GPIO_ADDR)

        rtm_default_flag = \
            (RTM_GPIO_DEFAULT_0 << 0) | (RTM_GPIO_DEFAULT_1 << 1) | \
            (RTM_GPIO_DEFAULT_2 << 2) | (RTM_GPIO_DEFAULT_3 << 3) | \
            (RTM_GPIO_DEFAULT_4 << 4) | (RTM_GPIO_DEFAULT_5 << 5) | \
            (RTM_GPIO_DEFAULT_6 << 6) | (RTM_GPIO_DEFAULT_7 << 7)
        self.rtm.write_port(rtm_default_flag)

        rtm_input_inv_flag = \
            (RTM_GPIO_INV_0 << 0) | (RTM_GPIO_INV_1 << 1) | \
            (RTM_GPIO_INV_2 << 2) | (RTM_GPIO_INV_3 << 3) | \
            (RTM_GPIO_INV_4 << 4) | (RTM_GPIO_INV_5 << 5) | \
            (RTM_GPIO_INV_6 << 6) | (RTM_GPIO_INV_7 << 7)
        self.rtm.set_port_pol(rtm_input_inv_flag)

        rtm_input_enable_flag = \
            (RTM_GPIO_INPUT_0 << 0) | (RTM_GPIO_INPUT_1 << 1) | \
            (RTM_GPIO_INPUT_2 << 2) | (RTM_GPIO_INPUT_3 << 3) | \
            (RTM_GPIO_INPUT_4 << 4) | (RTM_GPIO_INPUT_5 << 5) | \
            (RTM_GPIO_INPUT_6 << 6) | (RTM_GPIO_INPUT_7 << 7)
        self.rtm.set_port_dir(rtm_input_enable_flag)

        fpga_default_flag = \
            (FPGA_GPIO_DEFAULT_0 << 0) | (FPGA_GPIO_DEFAULT_1 << 1) | \
            (FPGA_GPIO_DEFAULT_2 << 2) | (FPGA_GPIO_DEFAULT_3 << 3) | \
            (FPGA_GPIO_DEFAULT_4 << 4) | (FPGA_GPIO_DEFAULT_5 << 5) | \
            (FPGA_GPIO_DEFAULT_6 << 6) | (FPGA_GPIO_DEFAULT_7 << 7)
        self.fpga.write_port(fpga_default_flag)

        fpga_input_inv_flag = \
            (FPGA_GPIO_INV_0 << 0) | (FPGA_GPIO_INV_1 << 1) | \
            (FPGA_GPIO_INV_2 << 2) | (FPGA_GPIO_INV_3 << 3) | \
            (FPGA_GPIO_INV_4 << 4) | (FPGA_GPIO_INV_5 << 5) | \
            (FPGA_GPIO_INV_6 << 6) | (FPGA_GPIO_INV_7 << 7)
        self.fpga.set_port_pol(fpga_input_inv_flag)

        fpga_input_enable_flag = \
            (FPGA_GPIO_INPUT_0 << 0) | (FPGA_GPIO_INPUT_1 << 1) | \
            (FPGA_GPIO_INPUT_2 << 2) | (FPGA_GPIO_INPUT_3 << 3) | \
            (FPGA_GPIO_INPUT_4 << 4) | (FPGA_GPIO_INPUT_5 << 5) | \
            (FPGA_GPIO_INPUT_6 << 6) | (FPGA_GPIO_INPUT_7 << 7)
        self.fpga.set_port_dir(fpga_input_enable_flag)

        fmc_default_flag = \
            (FMC_GPIO_DEFAULT_0 << 0) | (FMC_GPIO_DEFAULT_1 << 1) | \
            (FMC_GPIO_DEFAULT_2 << 2) | (FMC_GPIO_DEFAULT_3 << 3) | \
            (FMC_GPIO_DEFAULT_4 << 4) | (FMC_GPIO_DEFAULT_5 << 5) | \
            (FMC_GPIO_DEFAULT_6 << 6) | (FMC_GPIO_DEFAULT_7 << 7)
        self.fmc.write_port(fmc_default_flag)

        fmc_input_inv_flag = \
            (FMC_GPIO_INV_0 << 0) | (FMC_GPIO_INV_1 << 1) | \
            (FMC_GPIO_INV_2 << 2) | (FMC_GPIO_INV_3 << 3) | \
            (FMC_GPIO_INV_4 << 4) | (FMC_GPIO_INV_5 << 5) | \
            (FMC_GPIO_INV_6 << 6) | (FMC_GPIO_INV_7 << 7)
        self.fmc.set_port_pol(fmc_input_inv_flag)

        fmc_input_enable_flag = \
            (FMC_GPIO_INPUT_0 << 0) | (FMC_GPIO_INPUT_1 << 1) | \
            (FMC_GPIO_INPUT_2 << 2) | (FMC_GPIO_INPUT_3 << 3) | \
            (FMC_GPIO_INPUT_4 << 4) | (FMC_GPIO_INPUT_5 << 5) | \
            (FMC_GPIO_INPUT_6 << 6) | (FMC_GPIO_INPUT_7 << 7)
        self.fmc.set_port_dir(fmc_input_enable_flag)

    ############################################################
    # BLUE LED
    def led_blue_on(self):
        self.rtm.write_pin(RTM_PIN_BLUE_LED, 0)

    def led_blue_off(self):
        self.rtm.write_pin(RTM_PIN_BLUE_LED, 1)

    def set_led_blue(self, data): # 1: off
        self.rtm.write_pin(RTM_PIN_BLUE_LED, data)

    def get_led_blue(self):
        return self.rtm.read_pin(RTM_PIN_BLUE_LED)

    ############################################################
    # RED LED
    def led_red_on(self):
        self.rtm.write_pin(RTM_PIN_RED_LED, 0)

    def led_red_off(self):
        self.rtm.write_pin(RTM_PIN_RED_LED, 1)

    def set_led_red(self, data): # 1: off
        self.rtm.write_pin(RTM_PIN_RED_LED, data)

    def get_led_red(self):
        return self.rtm.read_pin(RTM_PIN_RED_LED)

    ############################################################
    # GREEN LED
    def led_green_on(self):
        self.rtm.write_pin(RTM_PIN_GREEN_LED, 0)

    def led_green_off(self):
        self.rtm.write_pin(RTM_PIN_GREEN_LED, 1)

    def set_led_green(self, data): # 1: off
        self.rtm.write_pin(RTM_PIN_GREEN_LED, data)

    def get_led_green(self):
        return self.rtm.read_pin(RTM_PIN_GREEN_LED)

    ############################################################
    # POWER ON/OFF
    def power_on(self):
        self.rtm.write_pin(RTM_PIN_PE, 1)

    def power_off(self):
        self.rtm.write_pin(RTM_PIN_PE, 0)

    ############################################################
    # PMBUS ALERT B
    def get_pmbus_int(self):
        return self.rtm.read_pin(RTM_PIN_PMBUS_INT)

    ############################################################
    # CLK INT B
    def get_clk_int(self):
        return self.rtm.read_pin(RTM_PIN_CLK_INT)

    ############################################################
    # PG
    def get_pg(self):
        return self.rtm.read_pin(RTM_PIN_PG)

    ############################################################
    # RTM Handle
    def get_handle(self):
        return self.rtm.read_pin(RTM_PIN_HANDLE)

    ############################################################
    # FPGA_PROG_B
    def fpga_prog(self):
        self.fpga.write_pin(FPGA_PIN_PROG_B, 0)
        sleep(1)
        self.fpga.write_pin(FPGA_PIN_PROG_B, 1)

    ############################################################
    # FPGA_PROG_B
    def get_fpga_init(self):
        return self.fpga.read_pin(FPGA_PIN_INIT_B)

    ############################################################
    # FPGA_DONE
    def get_fpga_done(self):
        return self.fpga.read_pin(FPGA_PIN_DONE)

    ############################################################
    # FPGA_RST_B
    def fpga_rst(self):
        self.fpga.write_pin(FPGA_PIN_RST_B, 0)
        sleep(1)
        self.fpga.write_pin(FPGA_PIN_RST_B, 1)

    ############################################################
    # JTAG_CON
    def jtag_rtm_dis(self):
        self.fpga.write_pin(FPGA_PIN_JTAG_CON_DIS, 0)

    def jtag_rtm_en(self):
        self.fpga.write_pin(FPGA_PIN_JTAG_CON_DIS, 1)

    ############################################################
    # JTAG_FMC2
    def jtag_fmc2_dis(self):
        self.fpga.write_pin(FPGA_PIN_JTAG_FMC2_DIS, 1)

    def jtag_fmc2_en(self):
        self.fpga.write_pin(FPGA_PIN_JTAG_FMC2_DIS, 0)

    ############################################################
    # JTAG_FMC3
    def jtag_fmc3_dis(self):
        self.fpga.write_pin(FPGA_PIN_JTAG_FMC3_DIS, 1)

    def jtag_fmc3_en(self):
        self.fpga.write_pin(FPGA_PIN_JTAG_FMC3_DIS, 0)

    ############################################################
    # RTM_MODE
    def get_rtm_mode(self):
        return self.fpga.read_pin(FPGA_PIN_RTM_MODE)

    ############################################################
    # FMC2 CLK DIR
    def get_fmc2_clk_dir(self):
        return self.fmc.read_pin(FMC_PIN_CLK_DIR2)

    ############################################################
    # FMC3 CLK DIR
    def get_fmc3_clk_dir(self):
        return self.fmc.read_pin(FMC_PIN_CLK_DIR3)

    ############################################################
    # FMC2 PRSNT
    def get_fmc2_prsnt(self):
        return self.fmc.read_pin(FMC_PIN_PRSNT2)

    ############################################################
    # FMC3 PRSNT
    def get_fmc3_prsnt(self):
        return self.fmc.read_pin(FMC_PIN_PRSNT3)

    ############################################################
    # FMC2 PG
    def get_fmc2_pg(self):
        return self.fmc.read_pin(FMC_PIN_PG2)

    ############################################################
    # FMC3 PG
    def get_fmc3_pg(self):
        return self.fmc.read_pin(FMC_PIN_PG3)