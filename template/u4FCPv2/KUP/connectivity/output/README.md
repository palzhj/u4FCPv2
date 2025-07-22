# Output folder

This folder serves as the output directory for various files, including bit, ltx, msc, and prm files. 

- bit files, short for "binary files," are generated during the process of programming or configuring a field-programmable gate array (FPGA). These files contain the binary data that defines the configuration of the device.

- ltx files are associated with the integrated logic analyzer for vivado online debugging. It contains test vectors or patterns used for testing and validating firmware during development. 

- mcs files, refer to the Memory Configuration File,  are created by Vivado after the generation of the bitstream. It includes the necessary information to configure the FPGA device, such as the configuration data, device-specific settings, and any additional programming instructions. To program the flash memory using the MCS file, the file is typically loaded onto the flash memory using a flash programming tool or utility provided by the vivado hardware manager. This tool reads the MCS file and writes the configuration data into the flash memory, making it ready for automatic configuration during subsequent power cycles.

- prm files, refer to the Parameter File used for configuring the flash memory, contain information such as the memory organization, timing parameters, erase and program algorithms, and other configuration-specific details for the flash memory device. It provides the necessary instructions and settings for Vivado to correctly program and interact with the flash memory during the configuration process. When programming an FPGA device with Vivado and using a flash memory for configuration storage, a PRM (Parameter) file is used to specify the configuration settings for the flash memory device.

