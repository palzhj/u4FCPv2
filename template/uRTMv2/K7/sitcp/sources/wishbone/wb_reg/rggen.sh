#!/bin/bash

file_name="reg_table"
rggen -c ./config.yml --plugin rggen-verilog --enable verilog_rtl --enable markdown ./${file_name}.xlsx
