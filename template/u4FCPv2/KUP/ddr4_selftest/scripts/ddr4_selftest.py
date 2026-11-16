#!/usr/bin/env python3
# -*- coding:utf-8 -*-
"""
u4FCP v2 DDR4 self-test host tool.

Talks to the DDR4 self-test firmware (RBCP user device 0x0005) over SiTCP and
starts / monitors / reports the memory test of the two DDR4 SODIMM sockets.

The tool uses the u4FCPv2 driver package when it is installed
    from u4FCPv2.transport.rbcp import Rbcp
and otherwise falls back to a small built-in RBCP implementation, so a plain
Python 3 installation is enough.

Examples
--------
    python3 ddr4_selftest.py status
    python3 ddr4_selftest.py run --ctrl both --pattern 0 --limit-mb 64
    python3 ddr4_selftest.py run --ctrl 1 --pattern 1 --limit-mb 0
    python3 ddr4_selftest.py reset
"""

from __future__ import print_function

import argparse
import socket
import struct
import sys
import time

# ---------------------------------------------------------------------------
# RBCP transport
# ---------------------------------------------------------------------------
try:  # pragma: no cover - depends on the installation
    from u4FCPv2.transport.rbcp import Rbcp  # type: ignore
    _HAVE_DRIVER = True
except Exception:  # pragma: no cover
    _HAVE_DRIVER = False

    class RbcpTimeout(Exception):
        pass

    class Rbcp(object):
        """Minimal SiTCP RBCP client (used when the driver package is absent)."""

        HEADER_VERTYPE = 0xFF
        HEADER_SIZE = 8

        def __init__(self, device_ip="192.168.10.16", udp_port=4660, timeout=3000):
            self._address = (device_ip, udp_port)
            self._packet_id = 0
            self._sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            self._sock.settimeout(timeout / 1000.0)

        def _header(self, is_read, address, length, packet_id):
            command = 0xC0 if is_read else 0x80
            return struct.pack(
                "8B", self.HEADER_VERTYPE, command, packet_id, length,
                (address >> 24) & 0xFF, (address >> 16) & 0xFF,
                (address >> 8) & 0xFF, address & 0xFF)

        def _transaction(self, packet, wait_id):
            self._sock.sendto(packet, self._address)
            for _ in range(8):
                data, _addr = self._sock.recvfrom(1024)
                if len(data) < self.HEADER_SIZE or data[2] != wait_id:
                    continue
                if data[1] & 0x08:
                    raise IOError("RBCP bus error at address 0x%08x" % 0)
                return bytearray(data[self.HEADER_SIZE:])
            raise RbcpTimeout("no RBCP reply")

        def read(self, address, length):
            pid = self._packet_id
            self._packet_id = (self._packet_id + 1) & 0xFF
            return self._transaction(self._header(True, address, length, pid), pid)

        def write(self, address, data):
            data = bytes(bytearray(data))
            pid = self._packet_id
            self._packet_id = (self._packet_id + 1) & 0xFF
            return self._transaction(self._header(False, address, len(data), pid) + data, pid)


# ---------------------------------------------------------------------------
# Register map (RBCP user device 0x0005)
# ---------------------------------------------------------------------------
DEV_BASE = 0x0005_0000
CTRL_BASE = {0: DEV_BASE + 0x00, 1: DEV_BASE + 0x40}

R_CTRL = 0x00
R_STA = 0x01
R_LANE = 0x02
R_LIMIT_L = 0x03
R_LIMIT_H = 0x04
R_ERR_CNT = 0x05
R_ERR_ADDR = 0x09
R_CUR_ADDR = 0x0D
R_EXP_DATA = 0x11
R_RD_DATA = 0x19
R_ID = 0x3F

FW_ID = 0xD4

# housekeeping register file: sys_rst register, bit 1 = DDR4 reset trigger
RBCP_SYS_RST = 0x0000_0005
SYS_RST_DDR = 0x02

STA_CALIB = 1 << 0
STA_BUSY = 1 << 1
STA_PASS = 1 << 2
STA_FAIL = 1 << 3
STA_DONE = 1 << 7

PHASE_NAMES = {0: "idle", 1: "write", 2: "drain", 3: "read", 4: "done"}
PATTERN_NAMES = {0: "address random", 1: "walking one", 2: "walking zero", 3: "checker board"}


class Ddr4Test(object):
    """Register level access to the DDR4 self-test firmware."""

    def __init__(self, ip, port=4660, timeout=3000):
        self.rbcp = Rbcp(device_ip=ip, udp_port=port, timeout=timeout)

    # -- low level ---------------------------------------------------------
    def read(self, ctrl, offset, length=1):
        return bytearray(self.rbcp.read(CTRL_BASE[ctrl] + offset, length))

    def write(self, ctrl, offset, data):
        self.rbcp.write(CTRL_BASE[ctrl] + offset, data)

    # -- helpers -----------------------------------------------------------
    def fw_id(self, ctrl):
        return self.read(ctrl, R_ID)[0]

    def status(self, ctrl):
        sta = self.read(ctrl, R_STA)[0]
        return {
            "sta": sta,
            "calib": bool(sta & STA_CALIB),
            "busy": bool(sta & STA_BUSY),
            "pass": bool(sta & STA_PASS),
            "fail": bool(sta & STA_FAIL),
            "done": bool(sta & STA_DONE),
            "phase": (sta >> 4) & 0x7,
        }

    def read_u32(self, ctrl, offset):
        d = self.read(ctrl, offset, 4)
        return d[0] | (d[1] << 8) | (d[2] << 16) | (d[3] << 24)

    def read_u64(self, ctrl, offset):
        d = self.read(ctrl, offset, 8)
        return int.from_bytes(bytes(d), "little")

    def set_limit_mb(self, ctrl, limit_mb):
        self.write(ctrl, R_LIMIT_L, bytes([limit_mb & 0xFF]))
        self.write(ctrl, R_LIMIT_H, bytes([(limit_mb >> 8) & 0xFF]))

    def start(self, ctrl, pattern):
        self.write(ctrl, R_CTRL, bytes([(pattern << 2) | 0x01]))

    def abort(self, ctrl):
        self.write(ctrl, R_CTRL, bytes([0x02]))


# ---------------------------------------------------------------------------
# Report helpers
# ---------------------------------------------------------------------------
def fmt_mb(value):
    return "%d MB" % value


def print_status(test, ctrls):
    for c in ctrls:
        ident = test.fw_id(c)
        st = test.status(c)
        line = "C%d (0x%08X): " % (c, CTRL_BASE[c])
        if ident != FW_ID:
            line += "no DDR4 self-test firmware (ID=0x%02X)" % ident
        else:
            line += "calibration %s, " % ("OK" if st["calib"] else "NOT DONE")
            line += "phase %s" % PHASE_NAMES.get(st["phase"], "?")
            if st["busy"]:
                line += ", busy"
            if st["done"]:
                line += ", last run %s" % ("PASS" if st["pass"] else "FAIL")
        print(line)


def print_result(test, ctrl, limit_mb):
    st = test.status(ctrl)
    if not st["done"]:
        print("C%d: no completed run" % ctrl)
        return False
    err_cnt = test.read_u32(ctrl, R_ERR_CNT)
    if st["pass"] and err_cnt == 0:
        print("C%d: PASS  (0 errors, %s)" % (ctrl, fmt_mb(limit_mb) if limit_mb else "whole memory"))
        return True
    err_addr = test.read_u32(ctrl, R_ERR_ADDR)
    lane = test.read(ctrl, R_LANE)[0]
    exp = test.read_u64(ctrl, R_EXP_DATA)
    rd = test.read_u64(ctrl, R_RD_DATA)
    print("C%d: FAIL  %d error(s), first error at byte address 0x%08X (lane %d)"
          % (ctrl, err_cnt, err_addr * 8, lane & 0x7))
    print("           expected 0x%016X, read 0x%016X" % (exp, rd))
    return False


# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------
def cmd_status(test, ctrls):
    print_status(test, ctrls)
    return 0


def ddr_reset(test):
    """Pulse the DDR4 reset trigger; both controllers re-run calibration."""
    test.rbcp.write(RBCP_SYS_RST, bytes([SYS_RST_DDR]))


def wait_calib(test, ctrls, timeout):
    t0 = time.time()
    while time.time() - t0 < timeout:
        if all(test.status(c)["calib"] for c in ctrls):
            return True
        time.sleep(0.1)
    return False


def cmd_abort(test, ctrls):
    for c in ctrls:
        test.abort(c)
    time.sleep(0.05)
    print("aborted")
    return 0


def cmd_run(test, ctrls, pattern, limit_mb, timeout, verbose):
    ok = True

    # 1) check presence and calibration
    for c in ctrls:
        if test.fw_id(c) != FW_ID:
            print("C%d: no DDR4 self-test firmware (ID=0x%02X)" % (c, test.fw_id(c)))
            return 2
        if not test.status(c)["calib"]:
            print("C%d: DDR4 calibration not done - waiting up to 5 s" % c)
            if not wait_calib(test, [c], 5.0):
                print("C%d: retrying with a DDR4 reset" % c)
                ddr_reset(test)
                if not wait_calib(test, ctrls, 10.0):
                    print("C%d: calibration still not done; check DIMM / 1.2 V / CLK_IN_PL" % c)
                    return 3

    # 2) configure and start
    for c in ctrls:
        test.set_limit_mb(c, limit_mb)
        test.start(c, pattern)
    print("started: pattern=%d (%s), limit=%s, controllers=%s"
          % (pattern, PATTERN_NAMES[pattern],
             fmt_mb(limit_mb) if limit_mb else "whole memory",
             ",".join("C%d" % c for c in ctrls)))

    # 3) poll
    t0 = time.time()
    last_report = 0.0
    pending = set(ctrls)
    last_progress = {}
    while pending:
        if time.time() - t0 > timeout:
            print("timeout after %d s" % timeout)
            return 4
        for c in list(pending):
            st = test.status(c)
            if st["done"] and not st["busy"]:
                pending.discard(c)
            elif verbose and time.time() - last_report > 1.0:
                cur = test.read_u32(c, R_CUR_ADDR) * 8
                last_progress[c] = cur
                print("C%d: %s (phase %s, %.1f MB)"
                      % (c, "running", PHASE_NAMES.get(st["phase"], "?"), cur / 1e6))
        if verbose and time.time() - last_report > 1.0:
            last_report = time.time()
        time.sleep(0.01)

    # 4) result
    print("finished in %.2f s" % (time.time() - t0))
    for c in ctrls:
        if not print_result(test, c, limit_mb):
            ok = False
    return 0 if ok else 1


def main(argv=None):
    parser = argparse.ArgumentParser(description="u4FCP v2 DDR4 self-test")
    parser.add_argument("--ip", default="192.168.10.16", help="SiTCP IP address (default 192.168.10.16)")
    parser.add_argument("--port", type=int, default=4660, help="RBCP UDP port (default 4660)")
    sub = parser.add_subparsers(dest="command")

    p_status = sub.add_parser("status", help="print calibration / last run status")
    p_status.add_argument("--ctrl", choices=["0", "1", "both"], default="both")

    p_run = sub.add_parser("run", help="run the memory test")
    p_run.add_argument("--ctrl", choices=["0", "1", "both"], default="both")
    p_run.add_argument("--pattern", type=int, choices=[0, 1, 2, 3], default=0)
    p_run.add_argument("--limit-mb", type=int, default=0, help="sweep length in MB, 0 = whole memory")
    p_run.add_argument("--timeout", type=int, default=300, help="poll timeout in seconds")
    p_run.add_argument("-q", "--quiet", action="store_true", help="no progress output")

    p_abort = sub.add_parser("abort", help="abort a running test")
    p_abort.add_argument("--ctrl", choices=["0", "1", "both"], default="both")

    sub.add_parser("reset", help="pulse the DDR4 reset (restart calibration)")

    args = parser.parse_args(argv)
    if args.command is None:
        args.command = "status"
        args.ctrl = "both"

    ctrls = [0, 1] if args.ctrl == "both" else [int(args.ctrl)]
    test = Ddr4Test(args.ip, args.port)

    if args.command == "status":
        return cmd_status(test, ctrls)
    if args.command == "abort":
        return cmd_abort(test, ctrls)
    if args.command == "reset":
        print("pulsing DDR4 reset, waiting for calibration ...")
        ddr_reset(test)
        ok = wait_calib(test, ctrls, 10.0)
        print_status(test, ctrls)
        return 0 if ok else 3
    return cmd_run(test, ctrls, args.pattern, args.limit_mb, args.timeout, not args.quiet)


if __name__ == "__main__":
    sys.exit(main())
