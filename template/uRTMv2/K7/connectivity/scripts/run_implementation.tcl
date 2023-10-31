# This file is part of the altiroc_emulator project (https://gitlab.cern.ch/fschreud/altiroc-emulator).
# Copyright (C) 2001-2021 CERN for the benefit of the ATLAS collaboration.
# Authors:
#               Frans Schreuder
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

reset_runs [get_runs]
set now [clock format [clock seconds] -format %Y%m%d%H]
set_property generic [format "SYN_DATE=32'h%s" $now] [current_fileset]
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_runs [get_runs impl_1]
file copy -force ../Projects/top/top.runs/impl_1/top.bit ../output/top.bit
file copy -force ../Projects/top/top.runs/impl_1/top.ltx ../output/top.ltx
write_cfgmem -format mcs -size 32 -interface SPIx4 -loadbit {up 0x00000000 "../output/top.bit"} -force -file "../output/top.mcs"

# reset_runs [get_runs]
# set_property generic "DATARATE=640 packetlength=16" [current_fileset]
# launch_runs impl_1 -to_step write_bitstream -jobs 8
# wait_on_runs [get_runs impl_1]
# file copy -force ../Projects/altiroc_emu_top/altiroc_emu_top.runs/impl_1/altiroc_emulator.bit ../output/altiroc_emulator_640Mb_16byte.bit
# file copy -force ../Projects/altiroc_emu_top/altiroc_emu_top.runs/impl_1/altiroc_emulator.ltx ../output/altiroc_emulator_640Mb_16byte.ltx
# write_cfgmem  -format mcs -size 1 -interface SPIx4 -loadbit {up 0x00000000 "../output/altiroc_emulator_640Mb_16byte.bit"} -force -file "../output/altiroc_emulator_640Mb_16byte.mcs"

# reset_runs [get_runs]
# set_property generic "DATARATE=1280 packetlength=16" [current_fileset]
# launch_runs impl_1 -to_step write_bitstream -jobs 8
# wait_on_runs [get_runs impl_1]
# file copy -force ../Projects/altiroc_emu_top/altiroc_emu_top.runs/impl_1/altiroc_emulator.bit ../output/altiroc_emulator_1280Mb_16byte.bit
# file copy -force ../Projects/altiroc_emu_top/altiroc_emu_top.runs/impl_1/altiroc_emulator.ltx ../output/altiroc_emulator_1280Mb_16byte.ltx
# write_cfgmem  -format mcs -size 1 -interface SPIx4 -loadbit {up 0x00000000 "../output/altiroc_emulator_1280Mb_16byte.bit"} -force -file "../output/altiroc_emulator_1280Mb_16byte.mcs"
