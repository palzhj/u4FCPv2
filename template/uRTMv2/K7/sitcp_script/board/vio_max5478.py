#!/usr/bin/python
# This is vio_max5478.py file
# author: zhj@ihep.ac.cn
# 2024-02-02 created
import lib
from lib import i2c
import time
import os

CH_FMC2 = 0x4
CH_FMC3 = 0x8

VREG_A  = 0x11 # FMC2
NVREG_A = 0x21
NVREGxVREG_A = 0x61
VREG_B  = 0x12 # FMC3
NVREG_B = 0x22
NVREGxVREG_B = 0x62

# Vtest = SLOPE * Vset + OFFSET
OFFSET = (-6.6632)
SLOPE  = 0.9805

class vio(object):
    """Class for communicating with max5478 using i2c bus."""
    def __init__(self, i2c_addr = 0b0101_1010, base_address = 0x00020000, clk_freq = 125, i2c_freq = 100):
        self.i2c = i2c.i2c(device_address = i2c_addr, base_address = base_address,
                    clk_freq = clk_freq, i2c_freq = i2c_freq)

    def cal(self, voltage):
        voltage = int((voltage-OFFSET)/SLOPE)
        dac = int(256 * (60.4/((voltage+OFFSET)/600-1)-13.3) / 50)
        if dac < 0:
            dac = 0
        if dac > 0xFF:
            dac = 0xFF
        print("0x%x"%dac)
        return (dac & 0xFF)

    def set(self, voltage = 1200, channel = CH_FMC2|CH_FMC3):
        # voltage: mV
        dac = self.cal(voltage)
        if (channel & CH_FMC2):
            self.i2c.write8(dac, 1, VREG_A)
        if (channel & CH_FMC3):
            self.i2c.write8(dac, 1, VREG_B)

    def set_nonvolatile(self, voltage = 1200, channel = CH_FMC2|CH_FMC3):
        # voltage: mV
        dac = self.cal(voltage)
        if (channel & CH_FMC2):
            self.i2c.write8(dac, 1, NVREG_A)
            time.sleep(0.02) # delay 20ms
            self.i2c.write8(NVREGxVREG_A)
        if (channel & CH_FMC3):
            self.i2c.write8(dac, 1, NVREG_B)
            time.sleep(0.02) # delay 20ms
            self.i2c.write8(NVREGxVREG_B)