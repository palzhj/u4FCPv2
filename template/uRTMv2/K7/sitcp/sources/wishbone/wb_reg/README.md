# RgGen

 In the process of FPGA development, a large number of registers need to be managed and maintained, especially when synchronizing with software updates, which can become cumbersome and time-consuming. Here I would like to introduce an excellent [GitHub project](https://github.com/rggen/rggen) that can automatically generate source code (HDL code, UVM register model, C header files, and Wiki documents) related to configuring and status registers based on human-readable register mapping specifications (configuration files or EXCEL), making project management and synchronization more convenient.

 # Usage

 Ref: [https://github.com/rggen/rggen/wiki/Register-Map-Specifications](https://github.com/rggen/rggen/wiki/Register-Map-Specifications)

1. Modify the reg_table.xlsx to add more registers
2. Run `rggen.sh` to generate reg_table.v and reg_table.md
