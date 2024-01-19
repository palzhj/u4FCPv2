#!/usr/bin/python
# This is i2c_switch.py file
# author: zhj@ihep.ac.cn
# 2024-01-16 created

from lib import i2c

switch_i2c_addr = 0xE2

GPIO_PIN_0  = 0x01
GPIO_PIN_1  = 0x02
GPIO_PIN_2  = 0x04
GPIO_PIN_3  = 0x08
GPIO_PIN_4  = 0x10
GPIO_PIN_5  = 0x20
GPIO_PIN_6  = 0x40
GPIO_PIN_7  = 0x80

DDR_PIN       = GPIO_PIN_6
FPGA_PIN      = GPIO_PIN_5
FIREFLY1_PIN  = GPIO_PIN_4
FIREFLY0_PIN  = GPIO_PIN_3
CLK_PIN       = GPIO_PIN_2
FMC3_PIN      = GPIO_PIN_1
FMC2_PIN      = GPIO_PIN_0

class i2c_switch(object):
  """Class for communicating with an I2C switch using TCA9548."""
  def __init__(self, base_address = 0x00020000, clk_freq = 125, i2c_freq = 100):
    self.i2c = i2c.i2c(device_address = switch_i2c_addr, base_address = base_address,
                   clk_freq = clk_freq, i2c_freq = i2c_freq)

  def get_status(self):
    temp = self.i2c.read8()
    if(temp&DDR_PIN):
      print("DDR I2C enable")
    if(temp&FPGA_PIN):
      print("FPGA I2C enable")
    if(temp&FIREFLY1_PIN):
      print("FIREFLY1 I2C enable")
    if(temp&FIREFLY0_PIN):
      print("FIREFLY0 I2C enable")
    if(temp&CLK_PIN):
      print("CLK I2C enable")
    if(temp&FMC3_PIN):
      print("FMC3 I2C enable")
    if(temp&FMC2_PIN):
      print("FMC2 I2C enable")

  def ddr_en(self):
    temp = self.i2c.read8()
    self.i2c.write8(temp|DDR_PIN)

  def fpga_en(self):
    temp = self.i2c.read8()
    self.i2c.write8(temp|FPGA_PIN)

  def firefly1_en(self):
    temp = self.i2c.read8()
    self.i2c.write8(temp|FIREFLY1_PIN)

  def firefly0_en(self):
    temp = self.i2c.read8()
    self.i2c.write8(temp|FIREFLY0_PIN)

  def clk_en(self):
    temp = self.i2c.read8()
    self.i2c.write8(temp|CLK_PIN)

  def fmc3_en(self):
    temp = self.i2c.read8()
    self.i2c.write8(temp|FMC3_PIN)

  def fmc2_en(self):
    temp = self.i2c.read8()
    self.i2c.write8(temp|FMC2_PIN)


  def ddr_dis(self):
    temp = self.i2c.read8()
    self.i2c.write8(temp&~DDR_PIN)

  def fpga_en(self):
    temp = self.i2c.read8()
    self.i2c.write8(temp&~FPGA_PIN)

  def firefly1_en(self):
    temp = self.i2c.read8()
    self.i2c.write8(temp&~FIREFLY1_PIN)

  def firefly0_en(self):
    temp = self.i2c.read8()
    self.i2c.write8(temp&~FIREFLY0_PIN)

  def clk_en(self):
    temp = self.i2c.read8()
    self.i2c.write8(temp&~CLK_PIN)

  def fmc3_en(self):
    temp = self.i2c.read8()
    self.i2c.write8(temp&~FMC3_PIN)

  def fmc2_en(self):
    temp = self.i2c.read8()
    self.i2c.write8(temp&~FMC2_PIN)