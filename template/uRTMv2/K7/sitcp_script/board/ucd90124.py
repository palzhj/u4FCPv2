#!/usr/bin/python
# This is tca9554.py file
# author: zhj@ihep.ac.cn
# 2024-02-04 created
import lib
from lib import i2c
import math

############################################################
# UCD Reg
REG_PAGE                = 0x00
REG_OPERATION           = 0x01
REG_VOUT_MODE           = 0x20
REG_STATUS_VOUT         = 0x7A
REG_STATUS_IOUT         = 0x7B
REG_STATUS_TEMPERATURE  = 0x7D
REG_READ_VOUT           = 0x8B
REG_READ_IOUT           = 0x8C
REG_READ_TEMPERATURE_1  = 0x8D
REG_READ_TEMPERATURE_2  = 0x8E
REG_GPIO_SELECT         = 0xFA
REG_GPIO_CONFIG         = 0xFB

############################################################
VOUT_OF             = 0x80 # Over voltage Fault
VOUT_OW             = 0x40 # Over voltage Warning
VOUT_UW             = 0x20 # Under voltage Warning
VOUT_UF             = 0x10 # Under voltage Fault

IOUT_OF             = 0x80 # Over current Fault
IOUT_OLVSF          = 0x40 # Over current and low voltage shutdown fault
IOUT_OW             = 0x20 # Over current Warning
IOUT_UF             = 0x10 # Under current Fault

T_OF                = 0x80 # Over temperature Fault
T_OW                = 0x40 # Over temperature Warning

GPIO_CONFIG_EN      = 0x01
GPIO_CONFIG_OEN     = 0x02
GPIO_CONFIG_HIGH    = 0x04
GPIO_CONFIG_STATUS  = 0x08

############################################################
# User define
CHANNEL_NUM = 12

PAGE_FMC2_PEN   = 0x0
PAGE_FMC3_PEN   = 0x1
PAGE_FMC2_3V3   = 0x2
PAGE_FMC3_3V3   = 0x3
PAGE_FMC2_12V0  = 0x4
PAGE_FMC3_12V0  = 0x5

# Input
FMC2_PRSNT      = 9     # GPI2
FMC2_3V3AUX_FLT = 25    # GPIO18
FMC2_3V3_FLT    = 23    # GPIO16
FMC2_12V0_FLT   = 12    # GPIO14

FMC3_PRSNT      = 8     # GPI1
FMC3_3V3AUX_FLT = 24    # GPIO17
FMC3_3V3_FLT    = 19    # GPIO2
FMC3_12V0_FLT   = 21    # GPIO4

# Output
FMC2_3V3AUX_EN  = 2     # GPIO7
FMC3_3V3AUX_EN  = 0     # GPIO5

FMC2_VADJ_PG    = 4     # GPIO9
FMC3_VADJ_PG    = 5     # GPIO10

FMC2_12V0_PG    = 18    # GPIO1
FMC3_12V0_PG    = 20    # GPIO3

FMC2_3V3_PG     = 22    # GPIO13
FMC3_3V3_PG     = 13    # GPIO15

class Channel:
    def __init__(self, name = 'NONE',ven = 0, ien = 0, ten = 0):
        self.name = name
        self.ven = ven
        self.voltage_cal_scope = 1
        self.voltage_cal_offset = 0
        self.ien = ien
        self.current_cal_scope = 1
        self.current_cal_offset = 0
        self.ten = ten
        self.temperature_cal_scope = 1
        self.temperature_cal_offset = 0

class ucd90124:
    """Class for communicating with tca9554 using i2c bus."""
    def __init__(self, i2c_addr = 0b1101_0000, base_address = 0x00020000, clk_freq = 125, i2c_freq = 100):
        self.i2c = i2c.i2c(device_address = i2c_addr, base_address = base_address,
                    clk_freq = clk_freq, i2c_freq = i2c_freq)
        self.ucd = [Channel() for _ in range(CHANNEL_NUM)]

        self.ucd[0].name = 'FMC2_VADJ'
        self.ucd[0].ven = 1
        self.ucd[0].ien = 1
        self.ucd[0].ten = 1
        self.ucd[0].current_cal_scope = 0.8213
        self.ucd[0].current_cal_offset = 0.0137
        self.ucd[0].temperature_cal_offset = -20

        self.ucd[1].name = 'FMC3_VADJ'
        self.ucd[1].ven = 1
        self.ucd[1].ien = 1
        self.ucd[1].ten = 1
        self.ucd[1].current_cal_scope = 0.8213
        self.ucd[1].current_cal_offset = 0.0137
        self.ucd[1].temperature_cal_offset = -20

        self.ucd[2].name = 'FMC2_3V3'
        self.ucd[2].ien = 1
        self.ucd[2].current_cal_scope = 1.1534
        self.ucd[2].current_cal_offset = -0.20038

        self.ucd[3].name = 'FMC3_3V3'
        self.ucd[3].ien = 1
        self.ucd[3].current_cal_scope = 1.1534
        self.ucd[3].current_cal_offset = -0.20038

        self.ucd[4].name = 'FMC2_12V0'
        self.ucd[4].ien = 1
        self.ucd[4].current_cal_scope = 1.1354
        self.ucd[4].current_cal_offset = -0.1536

        self.ucd[5].name = 'FMC3_12V0'
        self.ucd[5].ien = 1
        self.ucd[5].current_cal_scope = 1.1354
        self.ucd[5].current_cal_offset = -0.1536

        self.ucd[6].name = '12V0'
        self.ucd[6].ven = 1

        self.ucd[7].name = '3V3 '
        self.ucd[7].ven = 1

        self.ucd[8].name = 'MP_3V3'
        self.ucd[8].ven = 1

    def read_device_id(self):
        return self.i2c.readBytes(32, 1, 0xfd)

    def check_page(self, page):
        if (page < 0) | (page >= CHANNEL_NUM):
            print("Invalid channel number")
            return 0
        else:
            return page

    def voltage_conv(self, code, mode):
        if mode > 0xF:
            mode -= 0x20
        #print(mode)
        return code * math.pow( 2, mode )

    def read_voltage(self, page = 0):
        page= self.check_page(page)
        self.i2c.write8(page, 1, REG_PAGE)      # select page
        mode = self.i2c.read8(1, REG_VOUT_MODE)   # Vout_mode
        code = self.i2c.read16(1, REG_READ_VOUT)  # Vout
        return self.voltage_conv(code, mode) * self.ucd[page].voltage_cal_scope + self.ucd[page].voltage_cal_offset

    def get_voltage_status(self, page = 0):
        page= self.check_page(page)
        self.i2c.write8(page, 1, REG_PAGE)      # select page
        return self.i2c.read8(1, REG_STATUS_VOUT)

    def data_conv(self, code):
        # print("0x%x"%code)
        mode = (code>>11) & 0x1F
        if mode > 0xF:
            mode -= 0x20
        # print("0x%x"%mode)

        code &= 0x7FF
        if (code > 0x3FF):
            code -= 0x800
        # print("0x%x"%code)
        return code * math.pow( 2, mode )

    def read_current(self, page = 0):
        page= self.check_page(page)
        self.i2c.write8(page, 1, REG_PAGE)      # select page
        code = self.i2c.read16(1, REG_READ_IOUT)  # Iout
        return self.data_conv(code) * self.ucd[page].current_cal_scope + self.ucd[page].current_cal_offset

    def get_current_status(self, page = 0):
        page= self.check_page(page)
        self.i2c.write8(page, 1, REG_PAGE)      # select page
        return self.i2c.read8(1, REG_STATUS_IOUT)

    def read_temperature(self, page = 0):
        page= self.check_page(page)
        self.i2c.write8(page, 1, REG_PAGE)      # select page
        code = self.i2c.read16(1, REG_READ_TEMPERATURE_2)  # temperature
        return self.data_conv(code) * self.ucd[page].temperature_cal_scope + self.ucd[page].temperature_cal_offset

    def get_temperature_status(self, page = 0):
        page= self.check_page(page)
        self.i2c.write8(page, 1, REG_PAGE)      # select page
        return self.i2c.read8(1, REG_STATUS_TEMPERATURE)

    def read_device_temperature(self):  # UCD internal temperature
        code = self.i2c.read16(1, REG_READ_TEMPERATURE_1)  # temperature
        return self.data_conv(code)

    def print_info(self):
        for i in range(CHANNEL_NUM):
            voltage = '%3.2fV'%self.read_voltage(i) if self.ucd[i].ven else '-'
            current = '%3.2fA'%self.read_current(i) if self.ucd[i].ien else '-'
            temperature = '%3.2fC'%self.read_temperature(i) if self.ucd[i].ten else '-'
            print("CH%d:%s\t%s\t%s\t%s"%(i, self.ucd[i].name, voltage, current, temperature))

    def get_fmc2_present(self):
        self.i2c.write8(FMC2_PRSNT, 1, REG_GPIO_SELECT)
        if GPIO_CONFIG_STATUS & self.i2c.read8(1, REG_GPIO_CONFIG):
            return 0
        else:
            return 1

    def get_fmc3_present(self):
        self.i2c.write8(FMC3_PRSNT, 1, REG_GPIO_SELECT)
        if GPIO_CONFIG_STATUS & self.i2c.read8(1, REG_GPIO_CONFIG):
            return 0
        else:
            return 1

    def fmc2_power_on(self):
        self.i2c.write8(PAGE_FMC2_PEN, 1, REG_PAGE)
        self.i2c.write8(0x80, 1, REG_OPERATION)

    def fmc3_power_on(self):
        self.i2c.write8(PAGE_FMC3_PEN, 1, REG_PAGE)
        self.i2c.write8(0x80, 1, REG_OPERATION)

    def fmc2_power_off(self):
        self.i2c.write8(PAGE_FMC2_PEN, 1, REG_PAGE)
        self.i2c.write8(0x0, 1, REG_OPERATION)

    def fmc3_power_off(self):
        self.i2c.write8(PAGE_FMC3_PEN, 1, REG_PAGE)
        self.i2c.write8(0x0, 1, REG_OPERATION)

    def get_fmc2_power(self):
        self.i2c.write8(PAGE_FMC2_PEN, 1, REG_PAGE)
        if self.i2c.read8(1, REG_OPERATION):
            return 1
        else:
            return 0

    def get_fmc3_power(self):
        self.i2c.write8(PAGE_FMC3_PEN, 1, REG_PAGE)
        if self.i2c.read8(1, REG_OPERATION):
            return 1
        else:
            return 0

    def get_fmc2_3v3aux_hardware_fault(self):
        self.i2c.write8(FMC2_3V3AUX_FLT, 1, REG_GPIO_SELECT)
        if GPIO_CONFIG_STATUS & self.i2c.read8(1, REG_GPIO_CONFIG):
            return 0
        else:
            return 1

    def get_fmc3_3v3aux_hardware_fault(self):
        self.i2c.write8(FMC3_3V3AUX_FLT, 1, REG_GPIO_SELECT)
        if GPIO_CONFIG_STATUS & self.i2c.read8(1, REG_GPIO_CONFIG):
            return 0
        else:
            return 1

    def get_fmc2_3v3_hardware_fault(self):
        self.i2c.write8(FMC2_3V3_FLT, 1, REG_GPIO_SELECT)
        if GPIO_CONFIG_STATUS & self.i2c.read8(1, REG_GPIO_CONFIG):
            return 0
        else:
            return 1

    def get_fmc3_3v3_hardware_fault(self):
        self.i2c.write8(FMC3_3V3_FLT, 1, REG_GPIO_SELECT)
        if GPIO_CONFIG_STATUS & self.i2c.read8(1, REG_GPIO_CONFIG):
            return 0
        else:
            return 1

    # def get_fmc2_3v3_software_fault(self):
    #     self.i2c.write8(FMC2_3V3_PG, 1, REG_GPIO_SELECT)
    #     if GPIO_CONFIG_STATUS & self.i2c.read8(1, REG_GPIO_CONFIG):
    #         return 0
    #     else:
    #         return 1

    def get_fmc2_3v3_software_fault(self):
        if self.get_current_status(PAGE_FMC2_3V3) & IOUT_OF:
            return 1
        else:
            return 0

    def get_fmc2_3v3_software_warning(self):
        if self.get_current_status(PAGE_FMC2_3V3) & IOUT_OW:
            return 1
        else:
            return 0

    # def get_fmc3_3v3_software_fault(self):
    #     self.i2c.write8(FMC3_3V3_PG, 1, REG_GPIO_SELECT)
    #     if GPIO_CONFIG_STATUS & self.i2c.read8(1, REG_GPIO_CONFIG):
    #         return 0
    #     else:
    #         return 1

    def get_fmc3_3v3_software_fault(self):
        if self.get_current_status(PAGE_FMC3_3V3) & IOUT_OF:
            return 1
        else:
            return 0

    def get_fmc3_3v3_software_warning(self):
        if self.get_current_status(PAGE_FMC3_3V3) & IOUT_OW:
            return 1
        else:
            return 0

    def get_fmc2_12v0_hardware_fault(self):
        self.i2c.write8(FMC2_12V0_FLT, 1, REG_GPIO_SELECT)
        if GPIO_CONFIG_STATUS & self.i2c.read8(1, REG_GPIO_CONFIG):
            return 0
        else:
            return 1

    def get_fmc3_12v0_hardware_fault(self):
        self.i2c.write8(FMC3_12V0_FLT, 1, REG_GPIO_SELECT)
        if GPIO_CONFIG_STATUS & self.i2c.read8(1, REG_GPIO_CONFIG):
            return 0
        else:
            return 1

    # def get_fmc2_12v0_software_fault(self):
    #     self.i2c.write8(FMC2_12V0_PG, 1, REG_GPIO_SELECT)
    #     if GPIO_CONFIG_STATUS & self.i2c.read8(1, REG_GPIO_CONFIG):
    #         return 0
    #     else:
    #         return 1

    def get_fmc2_12v0_software_fault(self):
        if self.get_current_status(PAGE_FMC2_12V0) & IOUT_OF:
            return 1
        else:
            return 0

    def get_fmc2_12v0_software_warning(self):
        if self.get_current_status(PAGE_FMC2_12V0) & IOUT_OW:
            return 1
        else:
            return 0

    # def get_fmc3_12v0_software_fault(self):
    #     self.i2c.write8(FMC3_12V0_PG, 1, REG_GPIO_SELECT)
    #     if GPIO_CONFIG_STATUS & self.i2c.read8(1, REG_GPIO_CONFIG):
    #         return 0
    #     else:
    #         return 1

    def get_fmc3_12v0_software_fault(self):
        if self.get_current_status(PAGE_FMC3_12V0) & IOUT_OF:
            return 1
        else:
            return 0

    def get_fmc3_12v0_software_warning(self):
        if self.get_current_status(PAGE_FMC3_12V0) & IOUT_OW:
            return 1
        else:
            return 0

    # def get_fmc2_vadj_software_fault(self):
    #     self.i2c.write8(FMC2_VADJ_PG, 1, REG_GPIO_SELECT)
    #     if GPIO_CONFIG_STATUS & self.i2c.read8(1, REG_GPIO_CONFIG):
    #         return 0
    #     else:
    #         return 1

    def get_fmc2_vadj_software_fault(self):
        if self.get_current_status(PAGE_FMC2_PEN) & IOUT_OF:
            return 1
        else:
            return 0

    def get_fmc2_vadj_software_warning(self):
        if self.get_current_status(PAGE_FMC2_PEN) & IOUT_OW:
            return 1
        else:
            return 0

    # def get_fmc3_vadj_software_fault(self):
    #     self.i2c.write8(FMC3_VADJ_PG, 1, REG_GPIO_SELECT)
    #     if GPIO_CONFIG_STATUS & self.i2c.read8(1, REG_GPIO_CONFIG):
    #         return 0
    #     else:
    #         return 1

    def get_fmc3_vadj_software_fault(self):
        if self.get_current_status(PAGE_FMC3_PEN) & IOUT_OF:
            return 1
        else:
            return 0

    def get_fmc3_vadj_software_warning(self):
        if self.get_current_status(PAGE_FMC3_PEN) & IOUT_OW:
            return 1
        else:
            return 0

    def fmc2_power_3v3aux_on(self):
        self.i2c.write8(FMC2_3V3AUX_EN, 1, REG_GPIO_SELECT)
        self.i2c.write8(GPIO_CONFIG_EN|GPIO_CONFIG_OEN|GPIO_CONFIG_HIGH, 1, REG_GPIO_CONFIG)

    def fmc3_power_3v3aux_on(self):
        self.i2c.write8(FMC3_3V3AUX_EN, 1, REG_GPIO_SELECT)
        self.i2c.write8(GPIO_CONFIG_EN|GPIO_CONFIG_OEN|GPIO_CONFIG_HIGH, 1, REG_GPIO_CONFIG)

    def fmc2_power_3v3aux_off(self):
        self.i2c.write8(FMC2_3V3AUX_EN, 1, REG_GPIO_SELECT)
        self.i2c.write8(GPIO_CONFIG_EN|GPIO_CONFIG_OEN, 1, REG_GPIO_CONFIG)

    def fmc3_power_3v3aux_off(self):
        self.i2c.write8(FMC3_3V3AUX_EN, 1, REG_GPIO_SELECT)
        self.i2c.write8(GPIO_CONFIG_EN|GPIO_CONFIG_OEN, 1, REG_GPIO_CONFIG)

    def get_fmc2_3v3aux(self):
        self.i2c.write8(FMC2_3V3AUX_EN, 1, REG_GPIO_SELECT)
        if GPIO_CONFIG_STATUS & self.i2c.read8(1, REG_GPIO_CONFIG):
            return 1
        else:
            return 0

    def get_fmc3_3v3aux(self):
        self.i2c.write8(FMC3_3V3AUX_EN, 1, REG_GPIO_SELECT)
        if GPIO_CONFIG_STATUS & self.i2c.read8(1, REG_GPIO_CONFIG):
            return 1
        else:
            return 0

    def get_fmc2_temperature_software_fault(self):
        if self.get_temperature_status(PAGE_FMC2_PEN) & T_OF:
            return 1
        else:
            return 0

    def get_fmc2_temperature_software_warning(self):
        if self.get_temperature_status(PAGE_FMC2_PEN) & T_OW:
            return 1
        else:
            return 0

    def get_fmc3_temperature_software_fault(self):
        if self.get_temperature_status(PAGE_FMC3_PEN) & T_OF:
            return 1
        else:
            return 0

    def get_fmc3_temperature_software_warning(self):
        if self.get_temperature_status(PAGE_FMC3_PEN) & T_OW:
            return 1
        else:
            return 0

    def print_status(self):
        fmc2_present = "Y" if self.get_fmc2_present() else "N"
        fmc3_present = "Y" if self.get_fmc3_present() else "N"

        fmc2_power = "On" if self.get_fmc2_power() else "Off"
        fmc3_power = "On" if self.get_fmc3_power() else "Off"

        fmc2_3v3aux = "On" if self.get_fmc2_3v3aux() else "Off"
        fmc3_3v3aux = "On" if self.get_fmc2_3v3aux() else "Off"

        if self.get_fmc2_12v0_software_fault():
            fmc2_12v0_software_status = "F"
        elif self.get_fmc2_12v0_software_warning():
            fmc2_12v0_software_status = "W"
        else:
            fmc2_12v0_software_status = "N"
        if self.get_fmc3_12v0_software_fault():
            fmc3_12v0_software_status = "F"
        elif self.get_fmc3_12v0_software_warning():
            fmc3_12v0_software_status = "W"
        else:
            fmc3_12v0_software_status = "N"

        if self.get_fmc2_3v3_software_fault():
            fmc2_3v3_software_status = "F"
        elif self.get_fmc2_3v3_software_warning():
            fmc2_3v3_software_status = "W"
        else:
            fmc2_3v3_software_status = "N"
        if self.get_fmc3_3v3_software_fault():
            fmc3_3v3_software_status = "F"
        elif self.get_fmc3_3v3_software_warning():
            fmc3_3v3_software_status = "W"
        else:
            fmc3_3v3_software_status = "N"

        if self.get_fmc2_vadj_software_fault():
            fmc2_vadj_software_status = "F"
        elif self.get_fmc2_vadj_software_warning():
            fmc2_vadj_software_status = "W"
        else:
            fmc2_vadj_software_status = "N"
        if self.get_fmc3_vadj_software_fault():
            fmc3_vadj_software_status = "F"
        elif self.get_fmc3_vadj_software_warning():
            fmc3_vadj_software_status = "W"
        else:
            fmc3_vadj_software_status = "N"

        fmc2_12v0_hardware_fault = "F" if self.get_fmc2_12v0_hardware_fault() else "N"
        fmc3_12v0_hardware_fault = "F" if self.get_fmc3_12v0_hardware_fault() else "N"

        fmc2_3v3_hardware_fault = "F" if self.get_fmc2_3v3_hardware_fault() else "N"
        fmc3_3v3_hardware_fault = "F" if self.get_fmc3_3v3_hardware_fault() else "N"

        fmc2_3v3aux_hardware_fault = "F" if self.get_fmc2_3v3aux_hardware_fault() else "N"
        fmc3_3v3aux_hardware_fault = "F" if self.get_fmc3_3v3aux_hardware_fault() else "N"

        if self.get_fmc2_temperature_software_fault():
            fmc2_temperature_status = "F"
        elif self.get_fmc2_temperature_software_warning():
            fmc2_temperature_status = "W"
        else:
            fmc2_temperature_status = "N"
        if self.get_fmc3_temperature_software_fault():
            fmc3_temperature_status = "F"
        elif self.get_fmc3_temperature_software_warning():
            fmc3_temperature_status = "W"
        else:
            fmc3_temperature_status = "N"

        print("    \tPRSNT\tPower\t3V3AUX\tTemp\t----Software Fault----\t----Hardware Fault----")
        print("FMC \t     \t     \t      \t    \t12V0\t3V3\tVADJ\t12V0\t3V3\t3V3AUX")
        print("FMC2\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s"%(fmc2_present, fmc2_power, fmc2_3v3aux,fmc2_temperature_status,
            fmc2_12v0_software_status, fmc2_3v3_software_status, fmc2_vadj_software_status,
            fmc2_12v0_hardware_fault, fmc2_3v3_hardware_fault, fmc2_3v3aux_hardware_fault))
        print("FMC3\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s"%(fmc3_present, fmc3_power, fmc3_3v3aux,fmc3_temperature_status,
            fmc3_12v0_software_status, fmc3_3v3_software_status, fmc3_vadj_software_status,
            fmc3_12v0_hardware_fault, fmc3_3v3_hardware_fault, fmc3_3v3aux_hardware_fault))
