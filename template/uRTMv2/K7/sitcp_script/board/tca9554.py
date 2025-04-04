#!/usr/bin/python
# This is tca9554.py file
# author: zhj@ihep.ac.cn
# 2024-02-03 created
import lib
from lib import i2c

# TCA9554/PCA9554 8-bit I2C/SMBus I/O Expander Module

# Input port status register (Read only)
# Default register value is not defined
INPUT_REG = 0

# Output port register (Read/write)
# Default register value = 0xFF
OUTPUT_REG = 1

# Input Polarity Inversion register (Read/write)
# Default register value = 0x00
# If a bit in this register is set (written with 1), the corresponding port pin polarity is inverted.
POLARITY_REG = 2

# Configuration register (Read/write)
# Default register value = 0xFF
# If a bit in this register is cleared to 0, the corresponding port pin is enabled as an output.
CFG_REG = 3

# Interrupt Output (INT)
# An interrupt is generated by any rising or falling edge of any P-port I/O configured as an input.
# Resetting the interrupt circuit is achieved when data on the ports is changed back to the
# original state or when data is read from the Input Port register. Resetting occurs in the read mode at the
# acknowledge (ACK) bit after the rising edge of the SCL signal.

class tca9554(object):
    """Class for communicating with tca9554 using i2c bus."""
    def __init__(self, i2c_addr = 0b0001_1000, base_address = 0x00020000, clk_freq = 125, i2c_freq = 100):
        self.i2c = i2c.i2c(device_address = i2c_addr, base_address = base_address,
                    clk_freq = clk_freq, i2c_freq = i2c_freq)

    def read_port(self):
        return self.i2c.read8(1, INPUT_REG)

    def read_pin(self, pin):
        if (pin & self.read_port()):
            return 1
        else:
            return 0

    def write_port(self, data):
        self.i2c.write8(data&0xFF, 1, OUTPUT_REG)

    def write_pin(self, pin, data):
        pin &= 0xFF
        temp = self.read_port()
        if(data == 0):
            temp &= ~pin
        else:
            temp |= pin
        self.write_port(temp)

    def set_port_pol(self, data):
        self.i2c.write8(data&0xFF, 1, POLARITY_REG)

    def get_port_pol(self):
        return self.i2c.read8(1, POLARITY_REG)

    def set_pin_pol(self, pin, data):
        pin &= 0xFF
        temp = self.get_port_pol()
        if(data == 0):
            temp &= ~pin
        else:
            temp |= pin
        self.set_port_pol(temp)

    def get_pin_pol(self, pin):
        if (pin & self.get_port_pol()):
            return 1
        else:
            return 0

    def set_port_dir(self, data): # 1: Input
        self.i2c.write8(data&0xFF, 1, CFG_REG)

    def get_port_dir(self): # 1: Input
        self.i2c.read8(1, CFG_REG)

    def set_pin_input(self, pin):
        pin &= 0xFF
        temp = self.get_port_dir()
        temp |= pin
        self.set_port_dir(temp)

    def set_pin_output(self, pin):
        pin &= 0xFF
        temp = self.get_port_dir()
        temp &= ~pin
        self.set_port_dir(temp)

    def get_pin_dir(self, pin): # 1: Input
        if (pin & self.get_port_dir()):
            return 1
        else:
            return 0
