# FMC Power Setup

FMC power is controlled and monitored by UCD90124A. UCD's threshold can be adjusted by software. It can report over current warning and fault to host. In addition, E-fuse is used for over current protection by hardware. The tables below show the default setup. Once the software/hardware fault happened, you need to re-power the board to re-start.

### 3P3VAUX fault
| FMC Spec. | Hardware fault |
|-----------|----------------|
| 0.02 A     | 0.2 A           |

### 12P0V fault
| FMC Spec. | Warning | Software fault | Hardware fault |
|-----------|---------|----------------|----------------|
| 1A        | 1A      | 3A             | 4A             |

### 3P3V fault
| FMC Spec. | Warning | Software fault | Hardware fault |
|-----------|---------|----------------|----------------|
| 3A        | 3A      | 3.5A           | 4A             |

### VADJ fault
| FMC Spec. | Warning | Software fault | Hardware fault |
|-----------|---------|----------------|----------------|
| 4A        | 4A      | 5A             | Fixed 6A       |

## LED indication

* Red LED lights， FMC NOT present or power fault (12P0V, 3P3V, VADJ or 3P3VAUX software/hardware fault)
* Orange LED lights, 12P0V power good
* Green LED lights, 3P3V power good
* Yellow LED lights, VADJ NOT over current