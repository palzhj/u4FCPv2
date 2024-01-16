#!/bin/bash

file_name="reg_table"
rggen -c ./config.yml --plugin rggen-verilog ./${file_name}.xlsx -o ./tmp
mv ./tmp/${file_name}.md ./
mv ./tmp/${file_name}.v ./