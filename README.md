# u4FCP & uRTM v2

## Overview
The **MicroTCA.4 Fast Control and Process board (u4FCP)** is an FPGA-based [MicroTCA.4](https://www.picmg.org/product/microtca-enhancements-rear-io-precision-timing-specification/) compliant Advanced Mezzanine Card (AMC) designed for clock distribution, control, and data acquisition in High-Energy Physics (HEP) experiments.

### Key Features

* **Modular Architecture**: Paired with the **MicroTCA.4 Rear Transition Module (uRTM)** to expand I/O capabilities
* **High-Speed Connectivity**:
  - Four VITA-57.1 FMC (high-pin-count) sockets for I/O expansion
  - Zone 3 fabric connectors (compatible with [DESY Zone 3 recommendation D1.4](https://techlab.desy.de/resources/zone_3_recommendation/index_eng.html))
* **Flexible Deployment**:
  - Can operate within a MicroTCA crate
  - Supports stand-alone desktop operation via optical links or Ethernet

### Important Notes

:memo: **Note:** Both boards can be used independently for bench-top prototyping.

:warning: **Warning:** These boards are sensitive to electrostatic discharge (ESD). Always follow proper ESD precautions when handling.

## Board Specifications

### Dimensions

3D models of the boards are available in the [u4FCPv2 repository](https://github.com/palzhj/u4FCPv2/tree/main/outline).

| Board | Length | Height |
| ----- | ------ | ------ |
| u4FCP | 180.6 mm | 148.5 mm |
| uRTM  | 182.5 mm | 148.5 mm |

### Environmental Temperature

* Operating: 0°C to +45°C
* Storage: -25°C to +60°C

### Humidity

* 10% to 90% non-condensing

### Operating Voltage

* +12 VDC

## System Architecture

<figure>
    <img src="/readme/photo.jpg"
    	width="800"
        alt="Board Pictures">
    <figcaption><em>Photo of u4FCP v2 & uRTM v2.2</em></figcaption>
</figure>

<figure>
    <img src="/readme/block_diagram.png"
    	width="800"
        alt="Block Giagram">
    <figcaption><em>Block diagram of u4FCP & uRTM</em></figcaption>
</figure>

The block diagram below illustrates the u4FCP and uRTM architecture. Key connections are color-coded:
- **Red lines**: High-speed serial links using [FPGA gigabit transceivers (GTY/GTH/GTX)](https://docs.xilinx.com/r/en-US/ug440-xilinx-power-estimator/Using-the-Transceiver-Sheets-GTP-GTX-GTH-GTY-GTZ)
- **Blue lines**: General I/O connections to FPGA banks (HP/HR/HD)

### FMC connection

Although the FMC standard defines LA, HA, HB and DP differential ports, only parts of them are connected to FPGA due to limited IO resources.
The table below summarizes the connections of FMC

<table cellspacing="0" border="0">
    <colgroup></colgroup>
    <colgroup></colgroup>
    <colgroup></colgroup>
    <colgroup span="2"></colgroup>
    <colgroup></colgroup>
    <colgroup></colgroup>
    <colgroup></colgroup>
    <colgroup></colgroup>
    <tr>
        <td rowspan=3 align="center" valign=middle>FMC</td>
        <td colspan=8 align="center" valign=middle>HPC</td>
        </tr>
    <tr>
        <td colspan=3 align="center" valign=middle>LPC</td>
        <td align="left" valign=middle><br></td>
        <td align="left" valign=middle><br></td>
        <td align="left" valign=middle><br></td>
        <td align="left" valign=middle><br></td>
        <td align="left" valign=middle><br></td>
    </tr>
    <tr>
        <td align="left" valign=middle>LA[16:0]</td>
        <td align="left" valign=middle>LA[33:17]</td>
        <td align="left" valign=middle>DP[0]</td>
        <td align="left" valign=middle>DP[9:1]</td>
        <td align="left" valign=middle>HA[16:0]</td>
        <td align="left" valign=middle>HA[23:17]</td>
        <td align="left" valign=middle>HB[16:0]</td>
        <td align="left" valign=middle>HB[21:17]</td>
    </tr>
    <tr>
        <td align="left" valign=middle>FMC0</td>
        <td align="left" valign=middle>HP bank (1.0V~1.8V)</td>
        <td align="left" valign=middle>-</td>
        <td align="left" valign=middle>1 GTY</td>
        <td align="left" valign=middle>7 GTY</td>
        <td align="left" valign=middle>-</td>
        <td align="left" valign=middle>-</td>
        <td align="left" valign=middle>HD bank (3.3V), 8 ADC Channels</td>
        <td align="left" valign=middle>-</td>
    </tr>
    <tr>
        <td align="left" valign=middle>FMC1</td>
        <td align="left" valign=middle>HP bank (1.0V~1.8V)</td>
        <td align="left" valign=middle>-</td>
        <td align="left" valign=middle>1 GTY</td>
        <td align="left" valign=middle>7 GTY</td>
        <td align="left" valign=middle>-</td>
        <td align="left" valign=middle>-</td>
        <td align="left" valign=middle>HD bank (3.3V), 8 ADC Channels</td>
        <td align="left" valign=middle>-</td>
    </tr>
    <tr>
        <td align="left" valign=middle>FMC2</td>
        <td align="left" valign=middle>HR bank (1.2V~3.3V)</td>
        <td align="left" valign=middle>HR bank (1.2V~3.3V)</td>
        <td align="left" valign=middle>1 GTH</td>
        <td align="left" valign=middle>7 GTH</td>
        <td align="left" valign=middle>-</td>
        <td align="left" valign=middle>-</td>
        <td align="left" valign=middle>HR bank (2.5V), 5 ADC Channels</td>
        <td align="left" valign=middle>-</td>
    </tr>
    <tr>
        <td align="left" valign=middle>FMC3</td>
        <td align="left" valign=middle>HR bank (1.2V~3.3V)</td>
        <td align="left" valign=middle>HR bank (1.2V~3.3V)</td>
        <td align="left" valign=middle>1 GTH</td>
        <td align="left" valign=middle>7 GTH</td>
        <td align="left" valign=middle>HR bank (1.2V~3.3V)</td>
        <td align="left" valign=middle>HR bank (1.2V~3.3V)</td>
        <td align="left" valign=middle>HR bank (2.5V), 5 ADC Channels</td>
        <td align="left" valign=middle>-</td>
    </tr>
</table>

### Clock Features

The clock system provides flexible input options including:
- Front/rear panel LEMO connectors
- AMC/FMC clocks
- Onboard oscillators

Using cross-point switches and programmable clock multipliers, the cleaned reference clock (via [Si5345 jitter attenuator](https://www.skyworksinc.com/en/Products/Timing/High-Performance-Jitter-Attenuators/Si5345B)) ensures stable operation of gigabit transceivers. This enables support for multiple high-speed serial protocols in custom applications.

<figure>
    <img src="/readme/clock.png"
    	width="800"
        alt="Clock Generation & Distribution">
    <figcaption><em>Clock generation and distribution</em></figcaption>
</figure>

### Configuration

#### JTAG

The FPGA can be accessed either through the MicroTCA crate or JTAG header. A configurable bridge circuit selects between these JTAG sources. When an FMC card is detected (via FMC_PRSNT_M2C_B signal), it's automatically incorporated into the JTAG chain.

:memo: **Note:** It's recommended to implement a TDI to TDO connection via a device or bypass jumper for the JTAG chain to be completed on the attached FMC card. If not, the circuit can be configured by software to bypass the JTAG chain of FMC.

<figure>
    <img src="/readme/jtag.png"
    	width="600"
        alt="JTAG programming connections">
    <figcaption><em>JTAG programming connections</em></figcaption>
</figure>

#### I2C Bus

I2C bus is used to configure the board and provide environmental monitoring of the physical health. Although each device on board has a unique address, we add a multiplexer to prevent address collisions from attached FMCs, DDR modules or optical transceivers.

<figure>
    <img src="/readme/i2c.png"
        alt="I2C connections">
    <figcaption><em>I2C connections</em></figcaption>
</figure>

## u4FCP

Built around the Xilinx Kintex UltraScale+ FPGA, u4FCP provides users with a platform with synchronous clock, trigger/control, high volume data memory and high bandwidth data throughput that are required in general experiment.

<figure>
    <img src="/readme/block_diagram_u4fcp.png"
    	width="400"
        alt="FPGA Block Giagram of u4FCP">
    <figcaption><em>FPGA Block diagram of u4FCP</em></figcaption>
</figure>

An on-board microcontroller handles system management functions including:
- Power-on initialization
- Environmental monitoring (voltages, currents, temperature)
- Hot-plug capability
- Status indication
- Power management
- MCH communication (via [IPMB](https://www.picmg.org/spec-product-category/microtca_mch))

The microcontroller supports dual communication interfaces:
1. Chassis IPMB bus
2. Front panel USB/UART

Running [FreeRTOS](https://freertos.org) on an ARM Cortex-M3, the firmware is derived from [OpenMMC](https://github.com/lnls-dig/openMMC). See the [project repository](https://github.com/palzhj/openMMC_u4FCP) for implementation details.

<figure>
    <img src="/readme/backplane.png"
    	width="700"
        alt="Backplane Topology">
    <figcaption><em>A backplane topology for one MicroTCA.4 system</em></figcaption>
</figure>

The figure above shows one possible [backplane topology for the MicroTCA.4 system](https://schroff.nvent.com/en-us/products/enc11850-027). The functional definition of the port is project-specific, and depends heavily on the MCH selection. Generally speaking, port 0 is reserved for GbE, port 4\~7 are reserved for PCI-Express. The u4FCP connects the GTHs to port 0\~15 on chassis backplane. Taking advantage of the flexibility of the FPGA, the u4FCP gives
users the possibility of implementing various other high-speed protocols besides PCI-Express. The u4FCP connects the MLVDS transceivers to port 17\~20, which can be used as customized clock, trigger and interlock.

Moreover, u4FCP connects 16 GTHs and 4 GTYs to RTM to further improve scalability.

The u4FCP connects each FMC-HPC connector with 8 GTYs. Limited by the number of available IO pins of the FPGA, only LA[16:0] are connected, which can provide up to 34 single-ended or 17 differential user defined signals, the Vadj can be programmed to support 1.0V\~1.8V. In addition, HB[7:0] are connected to the ADC (10-bit 0.2 MSPS) channels of FPGA.

Finally, u4FCP hosts a [FireFly transceiver](https://www.samtec.com/optics/optical-cable/mid-board/firefly) with 4 fiber channels.

The following figure shows the gigabyte transceiver connection on u4FCP.

<figure>
    <img src="/readme/GT_Quads.png"
    	width="800"
        alt="GT connection on u4FCP">
    <figcaption><em>Connections for 56 GTY/GTH transceivers (6 GTY quads and 8 GTH quads)

1. FMC HPC connector (8 GTY) x2
2. AMC ports (16 GTH)
3. RTM ports (4 GTY to K7 and 16 GTH to FMC HPC)
4. FireFly (4 GTY)
</em></figcaption>
</figure>

:warning: **Warning:** Other than RTM[19:16] (GTY131) and FireFly (GTY132), every other GT Quad is in reverse order for PCIe connection (For instance, [3:0]=>[0:3]).

On-board memories are summarized below:

1. Two up to 16G-Byte DDR4 SODIMM with 72-bit data bus, supports ECC
2. 512K-bit I2C Serial EEPROM for MMC
3. 1G-bit Quad SPI Flash (MT25QU01GBBB8E12-0AAT) for storing the FPGA firmware

## uRTM

To increase scalability, we design the uRTM with a cost-effective and still powerful FPGA (Xilinx Kintex-7) supporting 16 gigabit transceivers (GTX).

<figure>
    <img src="/readme/block_diagram_urtm.png"
    	width="400"
        alt="FPGA Block Giagram of uRTM">
    <figcaption><em>FPGA Block diagram of uRTM</em></figcaption>
</figure>

2 GTX quads connect to FireFly, 1 GTX quad to MMCX connectors, and the last quad to RTM[19:16] to communicate with the u4FCP.

<figure>
    <img src="/readme/GTX_Quads.png"
    	width="200"
        alt="GTX connection on uRTM">
    <figcaption><em>Connections for 16 GTX transceivers</em></figcaption>
</figure>

The same as u4FCP, uRTM have two FMC sockets, but there are the differences:

:memo: **Note:** The RTM[15:0] are connected to DP[7:0] of two FMCs directly.

Benefit from the large number of available IO pins on FPGA, both FMCs have LA[33:0] and HB[5:0], the FMC3 has additional HA[23:0], which is far more than the connections on u4FCP.
HB[5:0] are connected to the ADC (Dual 12-bit 1 MSPS) channels of FPGA.
Vadj can be programmed to support 1.2V~3.3V.

uRTM hosts a Gigabit Ethernet through RGMII interface, which may help for rapid prototyping in single-board mode.

On-board memories are summarized below:

1. Two up to 8G-Byte DDR3L SODIMM with 64-bit data bus
2. 512K-bit I2C Serial EEPROM for MMC
3. 256M-bit Quad SPI Flash (S25FL256SAGBHIA10) for storing the FPGA firmware
