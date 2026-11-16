#--------------------------------------------------------------------------------
# program_fpga.tcl
#
# Download a bit file to the u4FCP v2 FPGA (XCKU15P) over JTAG with a
# configurable JTAG clock (default 10 MHz).
#
# Batch usage:
#   vivado -mode batch -nojournal -nolog -source program_fpga.tcl \
#          -tclargs [bitfile] [jtag_frequency_hz] [hw_server_url]
#
#     bitfile             default: ../output/top.bit (relative to this script)
#     jtag_frequency_hz   default: 10000000 (10 MHz)
#     hw_server_url       default: localhost:3121
#
# Examples:
#   vivado -mode batch -nojournal -nolog -source program_fpga.tcl
#   vivado -mode batch -nojournal -nolog -source program_fpga.tcl \
#          -tclargs ../output/top.bit 10000000
#   vivado -mode batch -nojournal -nolog -source program_fpga.tcl \
#          -tclargs ../output/top.bit 5000000 192.168.10.50:3121
#
# Only the FPGA is programmed (volatile, lost at power off). The configuration
# flash is not touched. If a .ltx file with the same base name as the bit file
# exists, its debug probes (ILA in the register file) are loaded as well.
#
# The JTAG clock is set through the hw_target PARAM.FREQUENCY property. Cables
# that do not support a programmable clock report a warning and keep their
# default frequency. 10 MHz is within the range of the Xilinx Platform Cable
# USB II, Digilent HS2/HS3 and most on-board FTDI based JTAG bridges.
#--------------------------------------------------------------------------------

proc die {msg} {
  puts ""
  puts "ERROR: $msg"
  puts ""
  exit 1
}

proc msg {text} {
  puts "  $text"
}

# --- arguments ---------------------------------------------------------------
set script_dir [file dirname [file normalize [info script]]]

if {$argc > 0} {
  set bitfile [file normalize [lindex $argv 0]]
} else {
  set bitfile [file normalize [file join $script_dir .. output top.bit]]
}
if {$argc > 1} {
  set jtag_freq [lindex $argv 1]
} else {
  set jtag_freq 10000000
}
if {$argc > 2} {
  set hw_url [lindex $argv 2]
} else {
  set hw_url "localhost:3121"
}

if {![file exists $bitfile]} {
  die "bit file '$bitfile' not found"
}
if {![string is integer -strict $jtag_freq] || $jtag_freq <= 0} {
  die "invalid JTAG frequency '$jtag_freq' (expected an integer in Hz)"
}

set ltxfile "[file rootname $bitfile].ltx"

puts ""
puts "============================================================"
puts " u4FCP v2 FPGA programming"
puts "============================================================"
msg "bit file    : $bitfile"
msg "JTAG clock  : $jtag_freq Hz"
msg "hw_server   : $hw_url"
if {[file exists $ltxfile]} {
  msg "probes file : $ltxfile"
}
puts ""

# --- connect to the hardware server ------------------------------------------
set t_start [clock milliseconds]

open_hw_manager
if {[catch {connect_hw_server -url $hw_url} err]} {
  # a local server is started by the tool in most installations; if that did
  # not happen, start one explicitly and retry once
  if {[string match "*localhost*" $hw_url] || [string match "*127.0.0.1*" $hw_url]} {
    msg "starting a local hw_server and retrying ..."
    catch {exec hw_server -d &}
    after 3000
    if {[catch {connect_hw_server -url $hw_url} err2]} {
      die "cannot connect to hw_server ($hw_url): $err2\n       is a JTAG cable connected and the driver installed?"
    }
  } else {
    die "cannot connect to hw_server ($hw_url): $err\n       start it on the remote machine with: hw_server -d"
  }
}
msg "connected to [lindex [get_hw_servers] 0]"

catch {refresh_hw_server}

# --- open the JTAG target ----------------------------------------------------
# get_hw_targets raises an error (instead of returning an empty list) when the
# server has no target at all
if {[catch {set targets [get_hw_targets]} err]} {
  set targets {}
}
if {[llength $targets] == 0} {
  die "no JTAG target found.\n       check the USB cable, the power of the board and (on Linux) the\n       cable driver/udev rules (see the Vivado installation guide)"
}
set target [lindex $targets 0]
foreach t $targets {
  if {[string match -nocase "*localhost*" $t]} { set target $t; break }
}
current_hw_target $target
msg "JTAG target : $target"

# set the clock before opening the target; some cables only expose the property
# after the target is open, so retry there
set freq_ok [expr {![catch {set_property PARAM.FREQUENCY $jtag_freq [current_hw_target]}]}]

if {[catch {open_hw_target} err]} {
  die "cannot open the JTAG target: $err"
}

if {!$freq_ok} {
  set freq_ok [expr {![catch {set_property PARAM.FREQUENCY $jtag_freq [current_hw_target]}]}]
}
if {$freq_ok} {
  msg "JTAG clock set to [get_property PARAM.FREQUENCY [current_hw_target]] Hz"
} else {
  puts "  WARNING: this cable does not accept a JTAG frequency setting,"
  puts "           the default frequency is used"
}

# --- find the FPGA -----------------------------------------------------------
if {[catch {set devs [get_hw_devices]} err]} {
  set devs {}
}
if {[llength $devs] == 0} {
  die "no device found on the JTAG target (is the board powered and configured?)"
}

set fpga ""
foreach d $devs {
  if {[string match -nocase "xcku15p*" $d]} { set fpga $d; break }
}
if {$fpga eq ""} {
  foreach d $devs {
    if {[string match -nocase "xcku*" $d]} { set fpga $d; break }
  }
}
if {$fpga eq ""} {
  msg "devices on the target: $devs"
  die "no Kintex UltraScale+ device found on the JTAG chain"
}

current_hw_device $fpga
refresh_hw_device -update_hw_probes false [current_hw_device]
msg "device      : $fpga"
catch {msg "part        : [get_property PART [current_hw_device]]"}
catch {msg "IDCODE      : [get_property IDCODE [current_hw_device]]"}

# --- program -----------------------------------------------------------------
if {[file exists $ltxfile]} {
  catch {set_property PROBES.FILE $ltxfile [current_hw_device]}
}
set_property PROGRAM.FILE $bitfile [current_hw_device]

puts ""
puts "  programming ..."
if {[catch {program_hw_devices [current_hw_device]} err]} {
  die "programming failed: $err"
}

set t_done [clock milliseconds]
puts ""
puts "============================================================"
puts " done - FPGA programmed in [expr {($t_done - $t_start) / 1000.0}] s"
puts "============================================================"
puts ""

# --- clean up ----------------------------------------------------------------
catch {close_hw_target}
catch {disconnect_hw_server}
catch {close_hw_manager}

exit 0
