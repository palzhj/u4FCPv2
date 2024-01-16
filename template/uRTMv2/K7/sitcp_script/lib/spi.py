#!/usr/bin/python           
# This is spi.py file
# author: zhj@ihep.ac.cn
# 2021-02-08 created
import lib
from lib import rbcp

SPI_CR_IEN      = 0b10000000 # Interrupt enable bit. 
SPI_CR_EN       = 0b01000000 # Enable bit
SPI_CR_MSTR     = 0b00010000 # Master Mode Select 
SPI_CR_CPOL     = 0b00001000 # Clock Polarity 
SPI_CR_CPHA     = 0b00000100 # Clock Phase 
SPI_CR_RS_DIV0  = 0b00000000 # Clock Rate Select
SPI_CR_RS_DIV1  = 0b00000001 # 
SPI_CR_RS_DIV2  = 0b00000010 # 
SPI_CR_RS_DIV3  = 0b00000011 # 

SPI_SR_IF       = 0b10000000 # Interrupt Flag 
SPI_SR_WCOL     = 0b01000000 # Write Collision
SPI_SR_WFFULL   = 0b00001000 # Write FIFO Full
SPI_SR_WFEMPTY  = 0b00000100 # Write FIFO Empty
SPI_SR_RFFULL   = 0b00000010 # Read FIFO Full
SPI_SR_RFEMPTY  = 0b00000001 # Read FIFO Empty

SPI_ER_ICNT1     = 0b00000000 # IF is set after every completed transfer
SPI_ER_ICNT2     = 0b01000000 # IF is set after every two completed transfers
SPI_ER_ICNT3     = 0b10000000 # IF is set after every three completed transfers
SPI_ER_ICNT4     = 0b11000000 # IF is set after every four completed transfers
SPI_ER_RS_DIV0   = 0b00000000 # Extended SPI Clock Rate Select
SPI_ER_RS_DIV1   = 0b00000001 #
SPI_ER_RS_DIV2   = 0b00000010 #

class SPIError(Exception):
    """
    Error Exception class.
    """
    pass

class spi(object):
    def __init__(self, base_address = 0xA0, clk_freq = 120, spi_freq = 200):
        """Create an instance of the SPI device at the specified address on the
        specified SPI bus number."""
        self._rbcp = rbcp.Rbcp()

        self.CLK_FREQ_MHZ = clk_freq # MHz
        self.I2C_FREQ_KHZ = spi_freq # kHz
        clk_count = int(self.CLK_FREQ_MHZ*1000/self.I2C_FREQ_KHZ - 1)

        self.SPI_CR_ADDR  = base_address
        self.SPI_SR_ADDR  = base_address + 0x1
        self.SPI_DR_ADDR  = base_address + 0x2
        self.SPI_ER_ADDR  = base_address + 0x3
        
        espr = SPI_ER_RS_DIV0
        spr  = SPI_CR_RS_DIV0 
        if clk_count > 2:
            espr = SPI_ER_RS_DIV0
            spr  = SPI_CR_RS_DIV1
        if clk_count > 4:
            espr = SPI_ER_RS_DIV1
            spr  = SPI_CR_RS_DIV0
        if clk_count > 8:
            espr = SPI_ER_RS_DIV0
            spr  = SPI_CR_RS_DIV2
        if clk_count > 16:
            espr = SPI_ER_RS_DIV0
            spr  = SPI_CR_RS_DIV3
        if clk_count > 32:
            espr = SPI_ER_RS_DIV1
            spr  = SPI_CR_RS_DIV1
        if clk_count > 64:
            espr = SPI_ER_RS_DIV1
            spr  = SPI_CR_RS_DIV2
        if clk_count > 128:
            espr = SPI_ER_RS_DIV1
            spr  = SPI_CR_RS_DIV3
        if clk_count > 256:
            espr = SPI_ER_RS_DIV2
            spr  = SPI_CR_RS_DIV0
        if clk_count > 512:
            espr = SPI_ER_RS_DIV2
            spr  = SPI_CR_RS_DIV1
        if clk_count > 1024:
            espr = SPI_ER_RS_DIV2
            spr  = SPI_CR_RS_DIV2
        if clk_count > 2048:
            espr = SPI_ER_RS_DIV2
            spr  = SPI_CR_RS_DIV3

        espr =  bytes([espr])
        if espr != self._rbcp.write(self.SPI_ER_ADDR, espr):
            raise IOError("UDP communication ERROR.")
            return -1
        cr = (SPI_CR_EN | SPI_CR_MSTR | spr) & 0xFF
        self._rbcp.write(self.SPI_CR_ADDR, bytes([cr]))

    # write8
    def write8(self, value):
        """Write an 8-bit value to the specified register."""
        self._rbcp.write(self.SPI_DR_ADDR, bytes([value & 0xFF]))
        while ((self._rbcp.read(self.SPI_SR_ADDR, 1)[0]) & SPI_SR_RFEMPTY): # check empty bit
           pass
        return self._rbcp.read(self.SPI_DR_ADDR, 1)[0]

    def read8(self, value):
        """Read an 8-bit value on the bus."""
        return self.write8(value)

    def write32(self, value, msb = 1):  
        if msb==1:
            temp0 = (value>>24) & 0xFF
            temp1 = (value>>16) & 0xFF
            temp2 = (value>> 8) & 0xFF
            temp3 = (value>> 0) & 0xFF
        else:
            temp0 = (value>> 0) & 0xFF
            temp1 = (value>> 8) & 0xFF
            temp2 = (value>>16) & 0xFF
            temp3 = (value>>24) & 0xFF            
        
        self._rbcp.write(self.SPI_DR_ADDR, bytes([temp0]))
        self._rbcp.write(self.SPI_DR_ADDR, bytes([temp1]))
        self._rbcp.write(self.SPI_DR_ADDR, bytes([temp2]))
        self._rbcp.write(self.SPI_DR_ADDR, bytes([temp3]))
        while ((self._rbcp.read(self.SPI_SR_ADDR, 1)[0]) & SPI_SR_RFFULL) != SPI_SR_RFFULL: # check empty bit
           pass
        temp0 = self._rbcp.read(self.SPI_DR_ADDR, 1)[0]
        temp1 = self._rbcp.read(self.SPI_DR_ADDR, 1)[0]
        temp2 = self._rbcp.read(self.SPI_DR_ADDR, 1)[0]
        temp3 = self._rbcp.read(self.SPI_DR_ADDR, 1)[0]
        if msb ==1:
            return (temp0 << 24)|(temp1 << 16)|(temp2 << 8)|(temp3 << 0)
        else:
            return (temp3 << 24)|(temp2 << 16)|(temp1 << 8)|(temp0 << 0)

    def read32(self, value, msb = 1):
        return self.write32(value, msb)

    def writeBytes(self, data):
        data = rbcp.to_bytes(data)
        temp = bytes()
        for i in range(len(data)//4):
            for j in range(4):
                self._rbcp.write(self.SPI_DR_ADDR, bytes([data[4*i+j]]))
            while ((self._rbcp.read(self.SPI_SR_ADDR, 1)[0]) & SPI_SR_RFFULL) != SPI_SR_RFFULL: # check empty bit
               pass
            for j in range(4):
                temp += self._rbcp.read(self.SPI_DR_ADDR, 1)

        for j in range(len(data)%4):
            self._rbcp.write(self.SPI_DR_ADDR, bytes([data[4*(len(data)//4)+j]]))
            while ((self._rbcp.read(self.SPI_SR_ADDR, 1)[0]) & SPI_SR_RFEMPTY): # check empty bit
                pass
            temp += self._rbcp.read(self.SPI_DR_ADDR, 1)

        # for item in data:
        #     self._rbcp.write(self.SPI_DR_ADDR, item)
        #     while ((self._rbcp.read(self.SPI_SR_ADDR, 1)[0]) & SPI_SR_RFEMPTY): # check empty bit
        #        pass
        #     temp += self._rbcp.read(self.SPI_DR_ADDR, 1)
        return temp

    def readBytes(self, data):
        return self.writeBytes(data)
