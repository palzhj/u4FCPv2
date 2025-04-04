#!/usr/bin/python
# This is test.py file
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
import eeprom
import vio_max5478
import gpio
import ucd90124

# import interface

TEST_REG    = 1
TEST_SYSMON = 0
TEST_I2C    = 0
TEST_CLK    = 1
TEST_EEPROM = 0
TEST_VIO    = 0
TEST_GPIO   = 0
TEST_PMBUS   = 1

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
    sysmon.print_status()
    print("")

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
    print("PLL initialized")

    adn4604 = adn4604.adn4604()
    adn4604.config()
    print("Clk switch initialized")
    adn4604.get_tx_status()
    print("")

#################################################################
# i2c eeprom test
if TEST_EEPROM:
    eeprom = eeprom.eeprom()

    bytes_data = bytes([])
    for i in range(256):
        bytes_data += bytes([i]*256)

    eeprom.write(0, bytes_data)
    print(eeprom.read(0x0, 65536))

#################################################################
# FMC adjustable voltage test
if TEST_VIO:
    vio = vio_max5478.vio()
    vio.set_nonvolatile(1200) # mV

#################################################################
# GPIO test
if TEST_GPIO:
    gpio = gpio.gpio()
    gpio.gpio_config()

    sleep(0.5)
    gpio.led_blue_on()
    sleep(0.5)
    gpio.led_red_on()
    sleep(0.5)
    gpio.led_green_on()
    sleep(0.5)
    gpio.led_blue_off()
    gpio.led_red_off()
    gpio.led_green_off()

    print("PMBUS alert is %d"%gpio.get_pmbus_int())
    print("CLK Int is %d"%gpio.get_clk_int())
    print("PG is %d"%gpio.get_pg())

    if(gpio.get_handle()):
        print("RTM handler is open")
    else:
        print("RTM handler is closed")

    # print("Re-program FPGA")
    # gpio.fpga_prog()

    print("FPGA INIT is %d"%gpio.get_fpga_init())
    print("FPGA DONE is %d"%gpio.get_fpga_done())

    # print("Reset FPGA")
    # gpio.fpga_rst()

    # print("Change JTAG to RTM")
    # gpio.jtag_rtm_en()

    print("Change JTAG to Con")
    gpio.jtag_rtm_dis()

    # print("Enable JTAG to FMC2")
    # gpio.jtag_fmc2_en()

    # print("Enable JTAG to FMC3")
    # gpio.jtag_fmc3_en()

    print("Disable JTAG to FMC2")
    gpio.jtag_fmc2_dis()

    print("Disable JTAG to FMC3")
    gpio.jtag_fmc3_dis()

    print("RTM MODE is %d"%gpio.get_rtm_mode())

    print("FMC2 CLK DIR is %d"%gpio.get_fmc2_clk_dir())
    print("FMC2 PRSNT is %d"%gpio.get_fmc2_prsnt())
    print("FMC2_PG is %d"%gpio.get_fmc2_pg())

    print("FMC3 CLK DIR is %d"%gpio.get_fmc3_clk_dir())
    print("FMC3 PRSNT is %d"%gpio.get_fmc3_prsnt())
    print("FMC3_PG is %d"%gpio.get_fmc3_pg())

############################################################
# PMBUS test
if TEST_PMBUS:
    pmbus = ucd90124.ucd90124()
    # print(pmbus.read_device_id())
    print("UCD internal temperature: %.2f C"%pmbus.read_device_temperature())
    pmbus.fmc2_power_on()
    pmbus.fmc3_power_on()

    # pmbus.fmc2_power_off()
    # pmbus.fmc3_power_off()

    # pmbus.fmc2_power_3v3aux_on()
    # pmbus.fmc3_power_3v3aux_on()

    pmbus.fmc2_power_3v3aux_off()
    pmbus.fmc3_power_3v3aux_off()

    pmbus.print_info()
    pmbus.print_status()