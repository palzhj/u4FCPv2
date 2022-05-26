# u4FCP & uRTM v2

## Introduction

MicroTCA.4 Fast Control and Process board (u4FCP) is an FPGA-based [MicroTCA.4](https://www.picmg.org/product/microtca-enhancements-rear-io-precision-timing-specification/) compatible Advanced Mezzanine Card (AMC) targeting generic clock, control and data acquisition in High-Energy Physics(HEP) experiments. 


MicroTCA.4 Rear Transition Module (uRTM) is a rear transition module in the rear of the crate to increase the I/O capability of the u4FCP. The u4FCP and uRTM are connected through fabric connectors in the upper area above the standard µTCA backplane area, defined as Zone 3. The pin assignment is compatible with the [Zone 3 recommendation](https://techlab.desy.de/resources/zone_3_recommendation/index_eng.html) D1.4 for digital applications.


u4FCP & uRTM are conceived to serve a midsized system residing either inside a MicroTCA crate or stand-alone on desktop with high-speed optical links or ethernet to PC.

The I/O capability of u4FCP & uRTM can be further enhanced with four [VITA-57.1 FPGA Mezzanine Cards (FMCs)](https://ohwr.org/projects/fmc-projects/wiki/fmc-standard) through the high-pin-count FMC sockets. 

## Block Diagram

A block diagram of the u4FCP and uRTM is shown below.

<figure>
    <img src="/readme/figures/block_diagram.png"
    	width="800"
        alt="Block Giagram">
    <figcaption>Block diagram of u4FCP & uRTM</figcaption>
</figure>

