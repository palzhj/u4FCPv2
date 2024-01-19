import traceback
import pyvisa
import sys

# def main():

#     volt_out = 11.0
#     current_limit = 2.0

#     power_ch = 0 # all channels
#     if len(sys.argv) == 2:
#         power_ch = eval(sys.argv[1])

#     rm = pyvisa.ResourceManager()
#     # rm.list_resources_info()

#     # E36233A
#     e36200 = rm.open_resource('TCPIP0::192.168.10.19::inst0::INSTR')
#     print(e36200.query("*IDN?"), end="")

#     # CH1
#     if (power_ch == 0) or (power_ch == 1):
# 	    e36200.write('VOLT %.3f, (@%d)'%(volt_out, 1))
# 	    e36200.write('CURR %.3f, (@%d)'%(current_limit, 1))
# 	    print('CH%d: volt_set = %.3f, curr_limit = %.3f'%(1, volt_out, current_limit))
# 	    e36200.write('OUTP 1, (@%d)'%(1))

#     # CH2
#     if (power_ch == 0) or (power_ch == 2):
# 	    e36200.write('VOLT %.3f, (@%d)'%(volt_out, 2))
# 	    e36200.write('CURR %.3f, (@%d)'%(current_limit, 2))
# 	    print('CH%d: volt_set = %.3f, curr_limit = %.3f'%(2, volt_out, current_limit))
# 	    e36200.write('OUTP 1, (@%d)'%(2))

#     # Issues a single beep immediately
#     e36200.write('SYST:BEEP')

#     e36200.close()

# try:
#     main()
# except:
#     traceback.print_exc()


#!/usr/bin/env python
#encoding: utf-8

# sudo vi /etc/udev/rules.d/ft.rules

# add

# SUBSYSTEMS=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", OWNER="iheper", MODE="0666"

# ls -al /dev/ttyUSB*

# import traceback
# import pyvisa

def main():

    volt_out = 11.0
    current_limit = 2.0

    rm = pyvisa.ResourceManager()
    # rm.list_resources_info()

    # GPD_4303S
    gpd4303s = rm.open_resource('ASRL/dev/ttyUSB0::INSTR')
    print(gpd4303s.query("*IDN?"), end="")
    gpd4303s.write("BEEP0")
    gpd4303s.write("BEEP1")

    # Off CH3 and CH4
    # power_ch = 3
    # gpd4303s.write('VSET%d:%.3f'%(power_ch, 0))
    # gpd4303s.write('ISET%d:%.3f'%(power_ch, 0.1))
    # power_ch = 4
    # gpd4303s.write('VSET%d:%.3f'%(power_ch, 0))
    # gpd4303s.write('ISET%d:%.3f'%(power_ch, 0.1))

    # CH1 and CH2
    power_ch = 1
    gpd4303s.write('VSET%d:%.3f'%(power_ch, volt_out))
    gpd4303s.write('ISET%d:%.3f'%(power_ch, current_limit))
    print('CH%d: volt_set = %.3f, curr_limit = %.3f'%(power_ch, volt_out, current_limit))
    power_ch = 2
    gpd4303s.write('VSET%d:%.3f'%(power_ch, volt_out))
    gpd4303s.write('ISET%d:%.3f'%(power_ch, current_limit))
    print('CH%d: volt_set = %.3f, curr_limit = %.3f'%(power_ch, volt_out, current_limit))

    gpd4303s.write("OUT1")
    gpd4303s.close()

try:
    main()
except:
    traceback.print_exc()
