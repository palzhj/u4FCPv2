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

SHOW_REG    = 1
SHOW_SYSMON = 1
SHOW_CLK    = 1
SHOW_EEPROM = 0
SHOW_VIO    = 1
SHOW_PMBUS  = 1
SHOW_GPIO   = 1

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

if SHOW_REG:
    reg = rbcp.Rbcp()
    read_info()
    print("")

#################################################################
# I2C clk init
if SHOW_CLK:
    i2c_switch = i2c_switch.i2c_switch()
    i2c_switch.enable_clk()
    sleep(0.1)
    i2c_switch.get_status()
    print("")

    adn4604 = adn4604.adn4604()
    adn4604.get_tx_status()
    print("")

#################################################################
# i2c eeprom init
if SHOW_EEPROM:
    eeprom = eeprom.eeprom()
    print("EEPROM:")
    print(eeprom.read(0x0, 65536))
    print("")

#################################################################
# FMC adjustable voltage test
if SHOW_VIO:
    output = 1200 # mV
    # vio = vio_max5478.vio()
    # vio.set_nonvolatile(output) # mV
    # print("Set FMC2 and FMC3 output %d mV"%output)

#################################################################
# Sysmon test
if SHOW_SYSMON:
    sysmon = sysmon.sysmon()

    sysmon.print_status()
    print("")

############################################################
# PMBUS test
if SHOW_PMBUS:
    pmbus = ucd90124.ucd90124()
    # print(pmbus.read_device_id())
    print("UCD internal temperature: %.2f C"%pmbus.read_device_temperature())
    print("")
    pmbus.print_info()
    print("")
    pmbus.print_status()
    print("")

#################################################################
# GPIO test
if SHOW_GPIO:
    gpio = gpio.gpio()
    gpio.print_status()
    print("")