#!/usr/bin/python
# This is init.py file
# author: zhj@ihep.ac.cn
# 2024-02-11 created

from time import sleep
import sys
import os
current_path = os.path.realpath(__file__)
directory_path = os.path.dirname(current_path)
sys.path.insert(0, directory_path+"/lib")
import rbcp
import sysmon
import spi
import i2c
sys.path.insert(0, directory_path+"/board")
import i2c_switch
import si5345
import adn4604
import eeprom
import vio_max5478
import gpio
import ucd90124

# import interface

INIT_REG    = 1
INIT_SYSMON = 0
INIT_CLK    = 1
INIT_EEPROM = 0
INIT_VIO    = 0
INIT_PMBUS  = 1
INIT_GPIO   = 1

#################################################################
# Register test
def read_info(): # the date of compiling
    temp = reg.read(0, 4)
    # print(temp)
    hour  = hex(temp[0]).lstrip("0x")
    day   = hex(temp[1]).lstrip("0x")
    month = hex(temp[2]).lstrip("0x")
    year  = "20" + hex(temp[3]).lstrip("0x")
    print("Compiling date: ", year, "-", month, "-", day, ",", hour, ":00")
    temp = reg.read(4, 1)
    print("Firmware version: ", temp[0])

if INIT_REG:
    reg = rbcp.Rbcp()
    read_info()
    print("")

#################################################################
# Sysmon test
if INIT_SYSMON:
    sysmon = sysmon.sysmon()

    sysmon.print_status()
    print("")

#################################################################
# I2C clk init
if INIT_CLK:
    i2c_switch = i2c_switch.i2c_switch()
    i2c_switch.enable_clk()
    # i2c_switch.get_status()
    sleep(0.1)

    si5345 = si5345.si5345()
    si5345.load_config()
    print("PLL initialized")

    adn4604 = adn4604.adn4604()
    adn4604.config()
    adn4604.get_tx_status()
    print("Clk switch initialized")
    print("")

#################################################################
# i2c eeprom init
if INIT_EEPROM:
    eeprom = eeprom.eeprom()

    bytes_data = bytes([])
    for i in range(256):
        bytes_data += bytes([i]*256)

    eeprom.write(0, bytes_data)
    print(eeprom.read(0x0, 65536))

#################################################################
# FMC adjustable voltage test
if INIT_VIO:
    output = 1200 # mV
    vio = vio_max5478.vio()
    vio.set_nonvolatile(output) # mV
    print("Set FMC2 and FMC3 output %d mV"%output)

############################################################
# PMBUS test
if INIT_PMBUS:
    pmbus = ucd90124.ucd90124()
    # print(pmbus.read_device_id())
    print("UCD internal temperature: %.2f C"%pmbus.read_device_temperature())
    pmbus.fmc2_power_on()
    pmbus.fmc3_power_on()

    # pmbus.fmc2_power_off()
    # pmbus.fmc3_power_off()

    # pmbus.fmc2_power_3v3aux_on()
    # pmbus.fmc3_power_3v3aux_on()

    # pmbus.fmc2_power_3v3aux_off()
    # pmbus.fmc3_power_3v3aux_off()

    pmbus.print_info()
    print("")
    pmbus.print_status()
    print("")

#################################################################
# GPIO test
if INIT_GPIO:
    gpio = gpio.gpio()
    gpio.gpio_config()

    gpio.led_blue_on()
    gpio.led_red_on()
    gpio.led_green_on()

    # print("Re-program FPGA")
    # gpio.fpga_prog()

    # print("Reset FPGA")
    # gpio.fpga_rst()

    # print("Change JTAG to RTM")
    # gpio.jtag_rtm_en()

    print("Change JTAG to Con")
    gpio.jtag_rtm_dis()

    print("Enable JTAG to FMC2")
    gpio.jtag_fmc2_en()

    print("Enable JTAG to FMC3")
    gpio.jtag_fmc3_en()

    # print("Disable JTAG to FMC2")
    # gpio.jtag_fmc2_dis()

    # print("Disable JTAG to FMC3")
    # gpio.jtag_fmc3_dis()
