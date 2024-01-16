#!/usr/bin/python           
# This is i2c.py file
# author: zhj@ihep.ac.cn
# 2019-06-18 created
import lib
from lib import rbcp

SYSMON_BASE_ADDR = 0x00010000

class sysmon(object):
    def __init__(self):
        self._rbcp = rbcp.Rbcp()

    def temperature(self):
        readout_bytes = self._rbcp.read(SYSMON_BASE_ADDR+0, 2)
        temp = (readout_bytes[0] << 8) + readout_bytes[1]
        temp = (temp>>6) * 501.3743 / 1024 -273.6777
        return temp

    def vccint(self):
        readout_bytes = self._rbcp.read(SYSMON_BASE_ADDR+(1<<1), 2)
        temp = (readout_bytes[0] << 8) + readout_bytes[1]
        temp = (temp>>6) / 1024 * 3
        return temp

    def vccaux(self):
        readout_bytes = self._rbcp.read(SYSMON_BASE_ADDR+(2<<1), 2)
        temp = (readout_bytes[0] << 8) + readout_bytes[1]
        temp = (temp>>6) / 1024 * 3
        return temp

    def vpvn(self):
        readout_bytes = self._rbcp.read(SYSMON_BASE_ADDR+(3<<1), 2)
        temp = (readout_bytes[0] << 8) + readout_bytes[1]
        temp = (temp>>6) / 1024 * 3
        return temp

    def vrefp(self):
        readout_bytes = self._rbcp.read(SYSMON_BASE_ADDR+(4<<1), 2)
        temp = (readout_bytes[0] << 8) + readout_bytes[1]
        temp = (temp>>6) / 1024 * 3
        return temp

    def vrefn(self):
        readout_bytes = self._rbcp.read(SYSMON_BASE_ADDR+(5<<1), 2)
        temp = (readout_bytes[0] << 8) + readout_bytes[1]
        temp = (temp>>6) / 1024 * 3
        return temp

    def vccbram(self):
        readout_bytes = self._rbcp.read(SYSMON_BASE_ADDR+(6<<1), 2)
        temp = (readout_bytes[0] << 8) + readout_bytes[1]
        temp = (temp>>6) / 1024 * 3
        return temp

    # On power-up or after reset, all minimum registers are set to FFFFh and all maximum registers 
    # are set to 0000h. 
    # Each new measurement generated for an on-chip sensor is compared to the contents of its maximum
    # and minimum registers. If the measured value is greater than the contents of its maximum registers,
    # the measured value is written to the maximum register. Similarly, for the minimum register, 
    # if the measured value is less than the contents of its minimum register, the measured value is
    # written to the minimum register. This check is carried out every time a measurement result is
    # written to the status registers.
    def temperature_max(self):
        readout_bytes = self._rbcp.read(SYSMON_BASE_ADDR+(0x20<<1), 2)
        temp = (readout_bytes[0] << 8) + readout_bytes[1]
        if temp == 0x0:
            return self.temperature()
        temp = (temp>>6) * 501.3743 / 1024 -273.6777
        return temp

    def vccint_max(self):
        readout_bytes = self._rbcp.read(SYSMON_BASE_ADDR+(0x21<<1), 2)
        temp = (readout_bytes[0] << 8) + readout_bytes[1]
        if temp == 0x0:
            return self.vccint()
        temp = (temp>>6) / 1024 * 3
        return temp

    def vccaux_max(self):
        readout_bytes = self._rbcp.read(SYSMON_BASE_ADDR+(0x22<1), 2)
        temp = (readout_bytes[0] << 8) + readout_bytes[1]
        if temp == 0x0:
            return self.vccaux()
        temp = (temp>>6) / 1024 * 3
        return temp

    def vccbram_max(self):
        readout_bytes = self._rbcp.read(SYSMON_BASE_ADDR+(0x23<<1), 2)
        temp = (readout_bytes[0] << 8) + readout_bytes[1]
        if temp == 0x0:
            return self.vccbram()
        temp = (temp>>6) / 1024 * 3
        return temp

    def temperature_min(self):
        readout_bytes = self._rbcp.read(SYSMON_BASE_ADDR+(0x24<<1), 2)
        temp = (readout_bytes[0] << 8) + readout_bytes[1]
        if temp == 0xFFFF:
            return self.temperature()
        temp = (temp>>6) * 501.3743 / 1024 -273.6777
        return temp

    def vccint_min(self):
        readout_bytes = self._rbcp.read(SYSMON_BASE_ADDR+(0x25<<1), 2)
        temp = (readout_bytes[0] << 8) + readout_bytes[1]
        if temp == 0xFFFF:
            return self.vccint()
        temp = (temp>>6) / 1024 * 3
        return temp

    def vccaux_min(self):
        readout_bytes = self._rbcp.read(SYSMON_BASE_ADDR+(0x26<<1), 2)
        temp = (readout_bytes[0] << 8) + readout_bytes[1]
        if temp == 0xFFFF:
            return self.vccaux()
        temp = (temp>>6) / 1024 * 3
        return temp

    def vccbram_min(self):
        readout_bytes = self._rbcp.read(SYSMON_BASE_ADDR+(0x27<<1), 2)
        temp = (readout_bytes[0] << 8) + readout_bytes[1]
        if temp == 0xFFFF:
            return self.vccbram()
        temp = (temp>>6) / 1024 * 3
        return temp
