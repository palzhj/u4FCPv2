import traceback
import pyvisa
import sys

# def main():

#     power_ch = 0 # all channels
#     if len(sys.argv) == 2:
#         power_ch = eval(sys.argv[1])
#         # print("%d"%power_ch)

#     rm = pyvisa.ResourceManager()
#     # rm.list_resources_info()

#     # E36233A
#     e36200 = rm.open_resource('TCPIP0::192.168.10.19::inst0::INSTR')
#     print(e36200.query("*IDN?"), end="")

#     # CH1
#     if(power_ch == 0) or (power_ch == 1):
#         e36200.write('OUTP 0, (@%d)'%(1))

#     # CH2
#     if(power_ch == 0) or (power_ch == 2):
#         e36200.write('OUTP 0, (@%d)'%(2))

#     # Issues a single beep immediately
#     e36200.write('SYST:BEEP')

#     e36200.close()

# try:
#     main()
# except:
#     traceback.print_exc()


#encoding: utf-8

# sudo vi /etc/udev/rules.d/ft.rules

# add

# SUBSYSTEMS=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", OWNER="iheper", MODE="0666"

# ls -al /dev/ttyUSB*

# import traceback
# import pyvisa

def main():

    rm = pyvisa.ResourceManager()
    # rm.list_resources_info()

    # GPD_4303S
    gpd4303s = rm.open_resource('ASRL/dev/ttyUSB0::INSTR')
    #gpd4303s = rm.open_resource('ASRL/dev/ttyUSB3::INSTR')
    gpd4303s.write("BEEP0")
    gpd4303s.write("BEEP1")

    gpd4303s.write("OUT0")
    print('Power Off')

    gpd4303s.close()

try:
    main()
except:
    traceback.print_exc()
