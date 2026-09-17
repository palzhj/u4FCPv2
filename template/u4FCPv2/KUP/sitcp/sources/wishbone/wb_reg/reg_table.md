## reg_table

* byte_size
    * 256
* bus_width
    * 8

|name|offset_address|
|:--|:--|
|[syn_info](#reg_table-syn_info)|0x00|
|[syn_ver](#reg_table-syn_ver)|0x04|
|[sys_rst](#reg_table-sys_rst)|0x05|
|[mod_rst](#reg_table-mod_rst)|0x06|
|[sys_sta](#reg_table-sys_sta)|0x07|
|[sys_sta_lch](#reg_table-sys_sta_lch)|0x08|
|[mod_sta](#reg_table-mod_sta)|0x09|
|[mod_sta_lch](#reg_table-mod_sta_lch)|0x0a|
|[clk](#reg_table-clk)|0x0b|
|[lv](#reg_table-lv)|0x0c|
|[hv](#reg_table-hv)|0x0d|
|[qsfp](#reg_table-qsfp)|0x0e|

### <div id="reg_table-syn_info"></div>syn_info

* offset_address
    * 0x00
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|hour|[7:0]|rof|default: 0x00|||Synthesis date - hour, BCD (00-23)|
|date|[15:8]|rof|default: 0x00|||Synthesis date - day of month, BCD (01-31)|
|month|[23:16]|rof|default: 0x00|||Synthesis date - month, BCD (01-12)|
|year|[31:24]|rof|default: 0x00|||Synthesis date - two-digit year, BCD (00-99); century implied|

### <div id="reg_table-syn_ver"></div>syn_ver

* offset_address
    * 0x04
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|syn_ver|[7:0]|rof|default: 0x00|||Firmware version (auto update at synthesis)|

### <div id="reg_table-sys_rst"></div>sys_rst

* offset_address
    * 0x05
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|usr_rst|[0]|w1trg|default: 0x0|||Write 1 to generate a reset pulse for the user logic; write 0 has no effect|
|ddr_rst|[1]|w1trg|default: 0x0|||Write 1 to generate a reset pulse for the DDR; write 0 has no effect|

### <div id="reg_table-mod_rst"></div>mod_rst

* offset_address
    * 0x06
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|mod_rst|[0]|w1trg|default: 0x0|||Write 1 to generate a reset pulse for the front-end modules; write 0 has no effect|
|qsfp_rst|[1]|w1trg|default: 0x0|||Write 1 to generate a reset pulse for the QSFP; write 0 has no effect|

### <div id="reg_table-sys_sta"></div>sys_sta

* offset_address
    * 0x07
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|clk_lock|[0]|ro|default: 0x0|||0 = MMCM not locked; 1 = MMCM locked|

### <div id="reg_table-sys_sta_lch"></div>sys_sta_lch

* offset_address
    * 0x08
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|clk_lock|[0]|rotrg|default: 0x0|||Latched copy of sys_sta.clk_lock. Sticky: cleared by reading this register|

### <div id="reg_table-mod_sta"></div>mod_sta

* offset_address
    * 0x09
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|temp_alm|[0]|ro|default: 0x0|||0 = Normal; 1 = Over-temperature alarm|
|lv_alm|[1]|ro|default: 0x0|||0 = Normal; 1 = Low-voltage over-current alarm|
|hv_alm|[2]|ro|default: 0x0|||0 = Normal; 1 = High-voltage over-current alarm|
|qsfp_alm|[3]|ro|default: 0x0|||0 = Normal; 1 = QSFP28 alarm (module fault or critical host status)|
|qsfp_prs|[4]|ro|default: 0x0|||0 = QSFP module absent; 1 = QSFP module present|

### <div id="reg_table-mod_sta_lch"></div>mod_sta_lch

* offset_address
    * 0x0a
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|temp_alm|[0]|rotrg|default: 0x0|||Latched copy of mod_sta.temp_alm. Sticky: cleared by reading this register|
|lv_alm|[1]|rotrg|default: 0x0|||Latched copy of mod_sta.lv_alm. Sticky: cleared by reading this register|
|hv_alm|[2]|rotrg|default: 0x0|||Latched copy of mod_sta.hv_alm. Sticky: cleared by reading this register|
|qsfp_alm|[3]|rotrg|default: 0x0|||Latched copy of mod_sta.qsfp_alm. Sticky: cleared by reading this register|
|qsfp_prs|[4]|rotrg|default: 0x0|||Latched copy of mod_sta.qsfp_prs. Sticky: cleared by reading this register|

### <div id="reg_table-clk"></div>clk

* offset_address
    * 0x0b
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|ext_en|[0]|rw|default: 0x0|||0 = Use on-board/local clock; 1 = Use external clock from AMC|

### <div id="reg_table-lv"></div>lv

* offset_address
    * 0x0c
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|enable|[0]|rw|default: 0x0|||0 = Module power OFF; 1 = Module power ON|
|ot_auto_off|[1]|rw|default: 0x0|||0 = Normal; 1 = Auto power OFF on over-temperature|

### <div id="reg_table-hv"></div>hv

* offset_address
    * 0x0d
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|stop|[0]|rw|default: 0x1|||0 = High voltage ON; 1 = High-voltage emergency shutdown (safe default: 1)|
|oc_auto_off|[1]|rw|default: 0x0|||0 = Normal; 1 = Auto power OFF on over-current|

### <div id="reg_table-qsfp"></div>qsfp

* offset_address
    * 0x0e
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|lpmode|[0]|rw|default: 0x0|||0 = Normal (Full-Power) mode; 1 = Low-Power mode|
