## reg_table

* byte_size
    * 256

|name|offset_address|
|:--|:--|
|[syn_info](#reg_table-syn_info)|0x00|
|[syn_ver](#reg_table-syn_ver)|0x04|

### <div id="reg_table-syn_info"></div>syn_info

* offset_address
    * 0x00
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|hour|[7:0]|rof|default: 0x00|||Synthesis date: Hour, binary-coded decimal expression|
|date|[15:8]|rof|default: 0x00|||Synthesis date: Date|
|month|[23:16]|rof|default: 0x00|||Synthesis date: Month|
|year|[31:24]|rof|default: 0x00|||Synthesis date: Last two figures of A.D.|

### <div id="reg_table-syn_ver"></div>syn_ver

* offset_address
    * 0x04
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|syn_ver|[7:0]|rof|default: 0x00|||Firmware Version|
