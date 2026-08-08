# Source folder

The source folder typically includes the following types of files:

1. Verilog files (.v): These files contain the design description written in the Verilog hardware description language. Verilog is a popular HDL used for describing digital systems.

2. VHDL files (.vhdl or .vhd): These files contain the design description written in the VHDL (VHSIC Hardware Description Language). VHDL is another widely used HDL for describing digital systems.

3. IP cores: Vivado allows the integration of pre-designed IP cores into the design. These IP cores are typically provided by Xilinx or third-party vendors and are stored as separate files within the source folder.

**Note that the TCL script will copy the IP files to a temporary directory, and any modifications made to the IP files will require re-running the create_project.tcl script.**
