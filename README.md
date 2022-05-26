# u4FCP & uRTM v2

## Introduction

MicroTCA.4 Fast Control and Process board (u4FCP) is an FPGA-based [MicroTCA.4](https://www.picmg.org/product/microtca-enhancements-rear-io-precision-timing-specification/) compatible Advanced Mezzanine Card (AMC) targeting generic clock, control and data acquisition in High-Energy Physics(HEP) experiments. 


MicroTCA.4 Rear Transition Module (uRTM) is a rear transition module in the rear of the crate to increase the I/O capability of the u4FCP. The u4FCP and uRTM are connected through fabric connectors in the upper area above the standard µTCA backplane area, defined as Zone 3. The pin assignment is compatible with the [Zone 3 recommendation](https://techlab.desy.de/resources/zone_3_recommendation/index_eng.html) D1.4 for digital applications.


u4FCP & uRTM are conceived to serve a midsized system residing either inside a MicroTCA crate or stand-alone on desktop with high-speed optical links or ethernet to PC.

The I/O capability of u4FCP & uRTM can be further enhanced with four [VITA-57.1 FPGA Mezzanine Cards (FMC)](https://ohwr.org/projects/fmc-projects/wiki/fmc-standard) through the high-pin-count sockets. 

## Block Diagram

A block diagram of the u4FCP and uRTM is shown below. The red lines are high-speed serial links connceted to the [gigabyte transceivers (GTY/GTH/GTX)](https://docs.xilinx.com/r/en-US/ug440-xilinx-power-estimator/Using-the-Transceiver-Sheets-GTP-GTX-GTH-GTY-GTZ) of the FPGA. The blue lines are the general input/outputs connected to the High Performance(HP), High Range(HR) or High Density(HD) banks of the FPGA. 

<figure>
    <img src="/readme/figures/block_diagram.png"
    	width="800"
        alt="Block Giagram">
    <figcaption><center>Block diagram of u4FCP & uRTM</center></figcaption>
</figure>

### Clock Features

Based on cross-point switches and programmable clock multipliers, the clock distribution for u4FCP & uRTM offer a large selection of input clock sources (e.g. the LEMO connectors in the front/rear panel, the AMC clocks, the FMC clocks, or onboard oscillators). This makes the u4FCP & uRTM give users the possibility of implementing various high speed serial data protocols for custom applications.

<figure>
    <img src="/readme/figures/clock.png"
    	width="800"
        alt="Clock Generation & Distribution">
    <figcaption><center>Clock generation and distribution in u4FCP & uRTM</center></figcaption>
</figure>

Whether you are using an internal or external clock, the signal must be cleaned to minimise jitter
and ensure stable performance. u4FCP & uRTM use dedicated chip ([Si5345](https://www.skyworksinc.com/en/Products/Timing/High-Performance-Jitter-Attenuators/Si5345B)) for jitter cleaning.

### Configuration

Users can access to the FPGA through the MicroTCA crate or JTAG header. A configurable logic circuit acts as a bridge selecting the JTAG master source between the JTAG header and AMC/RTM JTAG lines. When an FMC card is attached to u4FCP & uRTM, the circuit automatically adds the attached device to the JTAG chain as determined by its FMC_PRSNT_M2C_B signal. It's recommended to implement a TDI to TDO connection via a device or bypass jumper for the JTAG chain to be completed on the attached FMC card. If not, the circuit can be configured by software to bypass the JTAG chain of FMC.

<figure>
    <img src="/readme/figures/jtag.png"
    	width="600"
        alt=" JTAG programming connections">
    <figcaption><center>JTAG programming connections in u4FCP & uRTM</center></figcaption>
</figure>
