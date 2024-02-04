#!/usr/bin/python
# This is tca9554.py file
# author: zhj@ihep.ac.cn
# 2024-02-04 created
import lib
from lib import i2c
import math

CHANNEL_NUM = 12

REG_VOUT_MODE = 0x20
REG_READ_VOUT = 0x8B
REG_READ_IOUT = 0x8C
REG_READ_TEMPERATURE_2 = 0x8E

class Channel:
    def __init__(self, name = 'NONE',ven = 0, ien = 0, ten = 0):
        self.name = name
        self.ven = ven
        self.voltage = 0 # V
        self.ien = ien
        self.current = 0 # A
        self.ten = ten
        self.temperature = 0 # degree

class ucd90124:
    """Class for communicating with tca9554 using i2c bus."""
    def __init__(self, i2c_addr = 0b1101_0000, base_address = 0x00020000, clk_freq = 125, i2c_freq = 100):
        self.i2c = i2c.i2c(device_address = i2c_addr, base_address = base_address,
                    clk_freq = clk_freq, i2c_freq = i2c_freq)
        self.ucd = [Channel() for _ in range(CHANNEL_NUM)]

        self.ucd[0].name = 'FMC2_12V0'
        self.ucd[0].ien = 1

        self.ucd[1].name = 'FMC2_VADJ'
        self.ucd[1].ven = 1
        self.ucd[1].ien = 1
        self.ucd[1].ten = 1

        self.ucd[2].name = 'FMC2_3V3'
        self.ucd[2].ien = 1

        self.ucd[3].name = 'FMC3_12V0'
        self.ucd[3].ien = 1

        self.ucd[4].name = 'FMC3_VADJ'
        self.ucd[4].ven = 1
        self.ucd[4].ien = 1
        self.ucd[4].ten = 1

        self.ucd[5].name = 'FMC3_3V3'
        self.ucd[5].ien = 1

        self.ucd[6].name = '12V0'
        self.ucd[6].ven = 1

        self.ucd[7].name = '3V3 '
        self.ucd[7].ven = 1

        self.ucd[8].name = 'MP_3V3'
        self.ucd[8].ven = 1

    def read_device_id(self):
        return self.i2c.readBytes(32, True, 0xfd)

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
        self.i2c.write8(page, True, 0)      # select page
        mode = self.i2c.read8(True, REG_VOUT_MODE)   # Vout_mode
        code = self.i2c.read16(True, REG_READ_VOUT)  # Vout
        return self.voltage_conv(code, mode)

    def current_conv(self, code):
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
        self.i2c.write8(page, True, 0)      # select page
        code = self.i2c.read16(True, REG_READ_IOUT)  # Iout
        return self.current_conv(code)

    def temperature_conv(self, code):
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

    def read_temperature(self, page = 0):
        page= self.check_page(page)
        self.i2c.write8(page, True, 0)      # select page
        code = self.i2c.read16(True, REG_READ_TEMPERATURE_2)  # temperature
        return self.temperature_conv(code)

    def print_info(self):
        for i in range(CHANNEL_NUM):
            voltage = '%3.2fV'%self.read_voltage(i) if self.ucd[i].ven else '-'
            current = '%3.2fA'%self.read_current(i) if self.ucd[i].ien else '-'
            temperature = '%3.2fC'%self.read_temperature(i) if self.ucd[i].ten else '-'
            print("CH%d:%s\t%s\t%s\t%s"%(i, self.ucd[i].name, voltage, current, temperature))
