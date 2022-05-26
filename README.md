# u4FCP & uRTM v2

## Introduction

MicroTCA.4 Fast Control and Process board (u4FCP) is an FPGA-based [MicroTCA.4](https://www.picmg.org/product/microtca-enhancements-rear-io-precision-timing-specification/) compatible Advanced Mezzanine Card (AMC) targeting generic clock, control and data acquisition in High-Energy Physics(HEP) experiments. 


MicroTCA.4 Rear Transition Module (uRTM) is a rear transition module in the rear of the crate to increase the I/O capability of the u4FCP. The u4FCP and uRTM are connected through fabric connectors in the upper area above the standard µTCA backplane area, defined as Zone 3. The pin assignment is compatible with the [Zone 3 recommendation](https://techlab.desy.de/resources/zone_3_recommendation/index_eng.html) D1.4 for digital applications.


u4FCP & uRTM are conceived to serve a midsized system residing either inside a MicroTCA crate or stand-alone on desktop with high-speed optical links or ethernet to PC.

The I/O capability of u4FCP & uRTM can be further enhanced with four [VITA-57.1 FPGA Mezzanine Cards (FMC)](https://ohwr.org/projects/fmc-projects/wiki/fmc-standard) through the high-pin-count sockets. 

:memo: **Note:** Either of these two boards can be used independently bench-top prototyping.

:warning: **Warning:** The u4FCP and uRTM board can be damaged by electrostatic discharge (ESD). Follow standard ESD prevention measures when handling the board.

## Board Specifications

### Dimensions

#### u4FCP

Height: 180.6 mm 

Length: 148.5 mm

#### uRTM

Height: 182.5 mm 

Length: 148.5 mm

### Environmental Temperature

Operating: 0°C to +45°C 

Storage: -25°C to +60°C

### Humidity

10% to 90% non-condensing

### Operating Voltage

+12 VDC

## System Architecture

A block diagram of the u4FCP and uRTM is shown below. The red lines are high-speed serial links connceted to the [gigabyte transceivers (GTY/GTH/GTX)](https://docs.xilinx.com/r/en-US/ug440-xilinx-power-estimator/Using-the-Transceiver-Sheets-GTP-GTX-GTH-GTY-GTZ) of the FPGA. The blue lines are the general input/outputs connected to the High Performance (HP), High Range (HR) or High Density (HD) banks of the FPGA. 

<figure>
    <img src="/readme/figures/block_diagram.png"
    	width="800"
        alt="Block Giagram">
    <figcaption><em>Block diagram of u4FCP & uRTM</em></figcaption>
</figure>

### Clock Features

Based on cross-point switches and programmable clock multipliers, the clock distribution for u4FCP & uRTM offer a large selection of input clock sources (e.g. the LEMO connectors in the front/rear panel, the AMC clocks, the FMC clocks, or onboard oscillators). The clean clock is used as a reference clock for the gigabyte transceivers. This makes the u4FCP & uRTM give users the possibility of implementing various high speed serial data protocols for custom applications.

<figure>
    <img src="/readme/figures/clock.png"
    	width="800"
        alt="Clock Generation & Distribution">
    <figcaption><em>Clock generation and distribution</em></figcaption>
</figure>

Whether you are using an internal or external clock, the signal must be cleaned to minimise jitter
and ensure stable performance. u4FCP & uRTM use dedicated chip ([Si5345](https://www.skyworksinc.com/en/Products/Timing/High-Performance-Jitter-Attenuators/Si5345B)) for jitter cleaning.

### Configuration

#### JTAG

Users can access to the FPGA through the MicroTCA crate or JTAG header. A configurable logic circuit acts as a bridge selecting the JTAG master source between the JTAG header and AMC/RTM JTAG lines. When an FMC card is attached to u4FCP & uRTM, the circuit automatically adds the attached device to the JTAG chain as determined by its FMC_PRSNT_M2C_B signal. It's recommended to implement a TDI to TDO connection via a device or bypass jumper for the JTAG chain to be completed on the attached FMC card. If not, the circuit can be configured by software to bypass the JTAG chain of FMC.

<figure>
    <img src="/readme/figures/jtag.png"
    	width="600"
        alt="JTAG programming connections">
    <figcaption><em>JTAG programming connections</em></figcaption>
</figure>

#### I2C Bus

I2C bus is used to configure the board and provide environmental monitoring of the physical health. Although each device on board has a unique address, we add a multiplexer to prevent address collisions from attached FMCs, DDR modules or optical transceivers. 

<figure>
    <img src="/readme/figures/i2c.png"
        alt="I2C connections">
    <figcaption><em>I2C connections</em></figcaption>
</figure>

## u4FCP

Built around the Xilinx Kintex UltraScale+ FPGA, u4FCP provides users with a platform with synchronous clock, trigger/control, high volume data memory and high bandwidth data throughput that are required in general experiment. 

<figure>
    <img src="/readme/figures/block_diagram_u4fcp.png"
    	width="400"
        alt="FPGA Block Giagram of u4FCP">
    <figcaption><em>FPGA Block diagram of u4FCP</em></figcaption>
</figure>

An on-board microcontroller, which the host can communicate with either via IPMB Bus of the chassis backplane or through the USB/UART port on the front panel, is responsible for power-on initialization, parameter monitoring, e.g. voltages/currents or temperature, and also hot-plug capability, activation state display, payload power management and communication with the [MicroTCA Carrier Hub (MCH)](https://www.picmg.org/spec-product-category/microtca_mch), etc. The firmware of the microcontroller is developed based on real-time operating system, [FreeRTOS](https://freertos.org), and migrated from [CERN-MMC](https://espace.cern.ch/ph-dep-ESE-BE-uTCAEvaluationProject/MMC_project/default.aspx) to support ARM Cortex-M3. More information can be found [here](https://iopscience.iop.org/article/10.1088/1748-0221/16/03/T03005).

<figure>
    <img src="/readme/figures/backplane.png"
    	width="700"
        alt="Backplane Topology">
    <figcaption><em>A backplane topology for one MicroTCA.4 system</em></figcaption>
</figure>

Thr figure above shows one possible [backplane topology for the MicroTCA.4 system](https://schroff.nvent.com/en-us/products/enc11850-027). The functional definition of the port is project-specific, and depends heavily on the MCH selection. Generally speaking, port 0 is reserved for GbE, port 4\~7 are reserved for PCI-Express. The u4FCP connects the GTHs to port 0\~15 on chassis backplane. Taking advantage of the flexibility of the FPGA, the u4FCP gives
users the possibility of implementing various other high-speed protocols besides PCI-Express. The u4FCP connects the MLVDS transceivers to port 17\~20, which can be used as customized clock, trigger and interlock.

Moreover, u4FCP connects 16 GTHs and 4 GTYs to RTM to further improve scalability.

The u4FCP connects each FMC-HPC connector with 8 GTYs. Limited by the number of available IO pins of the FPGA, only LA[16:0] are connected, which can provide up to 34 single-ended or 17 differential user defined signals, the Vadj can be programmed to support 0.9V\~1.8V. In addition, HB[7:0] are connected to the ADC (10-bit 0.2 MSPS) channels of FPGA.

Finally, u4FCP hosts a [FireFly transceiver](https://www.samtec.com/optics/optical-cable/mid-board/firefly) with 4 fiber channels. 

The following figure shows the gigabyte transceiver connection on u4FCP.

<figure>
    <img src="/readme/figures/GT_Quads.png"
    	width="800"
        alt="GT connection on u4FCP">
    <figcaption><em>56 GTY/GTH transceivers (6 GTY Quads and 8 GTH Quads)

1. FMC HPC connector (8 GTY/GTH transceivers) x2
2. AMC ports (16 GTH transceivers)
3. RTM ports (20 GTY/GTH transceivers)</em></figcaption>
</figure>

:warning: **Warning:** Other than RTM[19:16](GTY 131) and FireFly(GTY132), every GT Quad else is in reverse order for PCIe connection (For instance, [3:0]=>[0:3]).

On-board memories are summarized below:

1. Two up to 16G-Byte DDR4 SODIMM with 72-bit wide data bus
2. 2K-bit I2C Serial EEPROM with EUI-48™ Identity, providing a unique node Ethernet MAC address for mass-production process
3. 512k-bit I2C Serial EEPROM for MMC
4. 512M-bit Quad SPI Flash for storing the FPGA firmware

## uRTM

<figure>
    <img src="/readme/figures/block_diagram_urtm.png"
    	width="400"
        alt="FPGA Block Giagram of uRTM">
    <figcaption><em>FPGA Block diagram of uRTM</em></figcaption>
</figure>


<figure>
    <img src="/readme/figures/GTX_Quads.png"
    	width="400"
        alt="GTX connection on uRTM">
    <figcaption><em>16 GTX transceivers</em></figcaption>
</figure>