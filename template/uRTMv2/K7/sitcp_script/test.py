#!/usr/bin/python
# This is server.py file
# author: zhj@ihep.ac.cn
# 2019-06-18 created

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

# import interface

TEST_REG = 1
TEST_SYSMON = 0
TEST_I2C = 0
TEST_CLK = 1

# def shift_led():
#     reg.write(LED_ADDR,'\x80')
#     for i in range(8):
#         b = reg.read(LED_ADDR, 1)
#         b[0] = b[0] >> 1
#         if b[0] == 0:
#             b[0] = 0x80
#         reg.write(LED_ADDR , b)
#         sleep(0.5)

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

#################################################################
# register test
if TEST_REG:
    reg = rbcp.Rbcp()
    read_info()
    # shift_led()

#################################################################
# sysmon test
if TEST_SYSMON:
    sysmon = sysmon.sysmon()
    print("temperature(min,val,max)/degree:",sysmon.temperature_min(), sysmon.temperature(), sysmon.temperature_max())
    print("vccint(min,val,max)/V:",sysmon.vccint_min(), sysmon.vccint(), sysmon.vccint_max())
    print("vccaux(min,val,max)/V:",sysmon.vccaux_min(), sysmon.vccaux(), sysmon.vccaux_max())
    print("vp-vn/V:",sysmon.vpvn())
    print("vrefp/V:",sysmon.vrefp())
    print("vrefn/V:",sysmon.vrefn())
    print("vccbram(min,val,max)/V:",sysmon.vccbram_min(), sysmon.vccbram(), sysmon.vccbram_max())

#################################################################
# i2c test
if TEST_I2C:
    U18_ADDR = 0x78
    i2c_u18 = i2c.i2c(U18_ADDR)
    print("0x%x"%i2c_u18.read8(1, 0))
    print("0x%x"%i2c_u18.read8(1, 1))
    print("0x%x"%i2c_u18.read8(1, 2))
    print("0x%x"%i2c_u18.read8(1, 3))

    U17_ADDR = 0x7A
    i2c_u17 = i2c.i2c(U17_ADDR)
    print("0x%x"%i2c_u17.read8(1, 0))
    print("0x%x"%i2c_u17.read8(1, 1))
    print("0x%x"%i2c_u17.read8(1, 2))
    print("0x%x"%i2c_u17.read8(1, 3))

    U19_ADDR = 0x7C
    i2c_u19 = i2c.i2c(U19_ADDR)
    print("0x%x"%i2c_u19.read8(1, 0))
    print("0x%x"%i2c_u19.read8(1, 1))
    print("0x%x"%i2c_u19.read8(1, 2))
    print("0x%x"%i2c_u19.read8(1, 3))

#################################################################
# i2c clk test
if TEST_CLK:
    i2c_switch = i2c_switch.i2c_switch()
    i2c_switch.enable_clk()
    i2c_switch.get_status()

    si5345 = si5345.si5345()
    si5345.load_config()

    adn4604 = adn4604.adn4604()
    adn4604.config()
    # adn4604.get_output_status()