#!/usr/bin/python
# This is si5345.py file
# author: zhj@ihep.ac.cn
# 2024-01-19 created
import lib
from lib import i2c
import time

class si5345(object):
    """Class for communicating with si5345 using i2c bus."""
    def __init__(self, i2c_addr = 0b1101_0100, base_address = 0x00020000, clk_freq = 125, i2c_freq = 100):
        self.i2c = i2c.i2c(device_address = i2c_addr, base_address = base_address,
                    clk_freq = clk_freq, i2c_freq = i2c_freq)

    def load_config(self, file_name = "../../CLK/default_registers.txt"):
        file = open(file_name, 'r')
        page_old = 0xFF
        for line in file:
            line = line.lstrip(' \t')
            if(line[0]=='#'):
                if line.find("msec") != -1:
                    time.sleep(0.3) # delay 300ms
                    print("Clk confog delay 300ms")
            elif(line[0]=='0'):
                # print(line)
                result = line.split(',')
                temp = int(result[0], 16)
                page = (temp >> 8) & 0xFF
                addr = temp & 0xFF
                val = int(result[1], 16)
                # print("%x,%x"%(addr,val))
                if (page_old != page):
                    self.i2c.write8(page, 1, 0x1)
                self.i2c.write8(val, 1, addr)
                page_old = page
        file.close()