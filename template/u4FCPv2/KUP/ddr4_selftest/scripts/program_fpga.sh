#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# program_fpga.sh
#
# Download the u4FCP v2 DDR4 self-test bit stream to the FPGA over JTAG.
#
#   ./program_fpga.sh [bitfile] [jtag_frequency_hz] [hw_server_url]
#
#   bitfile             default: ../output/top.bit
#   jtag_frequency_hz   default: 10000000 (10 MHz)
#   hw_server_url       default: localhost:3121
#
# Examples:
#   ./program_fpga.sh                          # output/top.bit at 10 MHz
#   ./program_fpga.sh ../output/top.bit 5e6    # 5 MHz
#   ./program_fpga.sh ./top.bit 10000000 192.168.10.50:3121
#
# Set VIVADO to use a specific Vivado installation, e.g.
#   VIVADO=/opt/Xilinx/Vivado/2022.2/bin/vivado ./program_fpga.sh
#-------------------------------------------------------------------------------
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bitfile="${1:-$here/../output/top.bit}"
freq="${2:-10000000}"
hwurl="${3:-localhost:3121}"

# make vivado available if it is not in PATH
if ! command -v "$(basename "${VIVADO:-vivado}")" >/dev/null 2>&1; then
  for s in "${VIVADO_SETTINGS:-}" \
           /opt/Xilinx/Vivado/2022.2/settings64.sh \
           /tools/Xilinx/Vivado/2022.2/settings64.sh \
           /opt/Xilinx/Vivado/2023.1/settings64.sh; do
    if [ -n "$s" ] && [ -f "$s" ]; then
      # shellcheck disable=SC1090
      . "$s" >/dev/null 2>&1
      break
    fi
  done
fi

vivado_bin="${VIVADO:-vivado}"
if ! command -v "$(basename "$vivado_bin")" >/dev/null 2>&1 && [ ! -x "$vivado_bin" ]; then
  echo "ERROR: vivado not found - install Vivado or set VIVADO=/path/to/vivado" >&2
  exit 1
fi

exec "$vivado_bin" -mode batch -nojournal -nolog -notrace \
  -source "$here/program_fpga.tcl" \
  -tclargs "$bitfile" "$freq" "$hwurl"
