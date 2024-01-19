#!/usr/bin/env python
#encoding: utf-8

import traceback
import pyvisa


# def main():

#     rm = pyvisa.ResourceManager()
#     # rm.list_resources_info()

#     # E36233A
#     e36200 = rm.open_resource('TCPIP0::192.168.10.19::inst0::INSTR')
#     print(e36200.query("*IDN?"), end="")

#     # CH1
#     power_ch = 1
#     voltage = eval(e36200.query('MEAS:VOLT? CH%d'%(power_ch)))
#     current = eval(e36200.query('MEAS:CURR? CH%d'%(power_ch)))
#     print('CH%d: volt = %.3f V, curr = %.3f A'%(power_ch, voltage, current))

#     # CH2
#     power_ch = 2
#     voltage = eval(e36200.query('MEAS:VOLT? CH%d'%(power_ch)))
#     current = eval(e36200.query('MEAS:CURR? CH%d'%(power_ch)))
#     print('CH%d: volt = %.3f V, curr = %.3f A'%(power_ch, voltage, current))

#     # Issues a single beep immediately
#     e36200.write('SYST:BEEP')

#     e36200.close()

# try:
#     main()
# except:
#     traceback.print_exc()


# sudo vi /etc/udev/rules.d/ft.rules

# add

# SUBSYSTEMS=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", OWNER="iheper", MODE="0666"

# ls -al /dev/ttyUSB*

# import traceback
# import pyvisa


def main():

    rm = pyvisa.ResourceManager()

    # GPD_4303S
    gpd4303s = rm.open_resource('ASRL/dev/ttyUSB1::INSTR')

    # CH1
    power_ch = 1
    voltage = gpd4303s.query('VOUT%d?'%power_ch)
    current = gpd4303s.query('IOUT%d?'%power_ch)
    print('CH%d:\r\nvolt = %scurr = %s'%(power_ch, voltage, current))

    # CH2
    power_ch = 2
    voltage = gpd4303s.query('VOUT%d?'%power_ch)
    current = gpd4303s.query('IOUT%d?'%power_ch)
    print('CH%d:\r\nvolt = %scurr = %s'%(power_ch, voltage, current))

    gpd4303s.write("BEEP0")
    gpd4303s.write("BEEP1")

    gpd4303s.close()

try:
    main()
except:
    traceback.print_exc()