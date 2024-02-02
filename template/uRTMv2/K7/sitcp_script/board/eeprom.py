#!/usr/bin/python
# This is eeprom.py file
# author: zhj@ihep.ac.cn
# 2024-02-01 created
import lib
from lib import i2c
import time

class eeprom(object):
    """Class for communicating with eeprom CAT24C512 using i2c bus."""
    def __init__(self, i2c_addr = 0b1010_0000, base_address = 0x00020000, clk_freq = 125, i2c_freq = 100):
        self.i2c = i2c.i2c(device_address = i2c_addr, base_address = base_address,
                    clk_freq = clk_freq, i2c_freq = i2c_freq)

    def read(self, addr, length = 1):
        if(length == 1):
            return self.i2c.read8(2, addr)
        else:
            return self.i2c.readBytes(length, 2, addr)

    def write(self, addr, data):
        if isinstance(data, int):
            data = bytes([data])
        if isinstance(data, bytes):
            while(len(data)>128):
                # The CAT24C512 contains 65,536 bytes of data, arranged in 512 pages of 128 bytes each.
                # If the Master transmits more than 128 data bytes, then earlier bytes will be
                # overwritten by later bytes in a ‘wrap−around’ fashion (within the selected page).
                self.i2c.writeBytes(data[:128], 2, addr)
                time.sleep(0.005) # Write Cycle Time: 5ms
                data = data[128:]
                addr += 128
            self.i2c.writeBytes(data, 2, addr)
            time.sleep(0.005) # Write Cycle Time: 5ms
        else:
            print("Data should be int or bytes")
            return