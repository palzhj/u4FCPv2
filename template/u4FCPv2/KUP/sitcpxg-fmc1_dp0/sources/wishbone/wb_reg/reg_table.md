## reg_table

* byte_size
    * 256

|name|offset_address|
|:--|:--|
|[syn_info](#reg_table-syn_info)|0x00|
|[syn_ver](#reg_table-syn_ver)|0x04|
|[fpga_dna](#reg_table-fpga_dna)|0x05|
|[tcp_mode](#reg_table-tcp_mode)|0x0d|
|[tcp_test_tx_rate](#reg_table-tcp_test_tx_rate)|0x0e|
|[tcp_test_num_of_data](#reg_table-tcp_test_num_of_data)|0x0f|
|[tcp_test_data_gen](#reg_table-tcp_test_data_gen)|0x17|
|[tcp_test_word_len](#reg_table-tcp_test_word_len)|0x18|
|[tcp_test_select_seq](#reg_table-tcp_test_select_seq)|0x19|
|[tcp_test_seq_pattern](#reg_table-tcp_test_seq_pattern)|0x1a|
|[tcp_test_blk_size](#reg_table-tcp_test_blk_size)|0x1e|
|[tcp_test_ins_error](#reg_table-tcp_test_ins_error)|0x21|

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

### <div id="reg_table-fpga_dna"></div>fpga_dna

* offset_address
    * 0x05
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|fpga_dna|[63:0]|ro||||FPGA DNA ID|

### <div id="reg_table-tcp_mode"></div>tcp_mode

* offset_address
    * 0x0d
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|tcp_mode|[1:0]|rw|default: 0x0|||TCP mode: 2’b01 - Loopback mode, 2’b10 - Test mode, 2’b00 – Normal mode|

### <div id="reg_table-tcp_test_tx_rate"></div>tcp_test_tx_rate

* offset_address
    * 0x0e
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|tcp_test_tx_rate|[7:0]|rw|default: 0x01|||Transmission data rate in units of 100 Mbps for TCP test mode|

### <div id="reg_table-tcp_test_num_of_data"></div>tcp_test_num_of_data

* offset_address
    * 0x0f
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|tcp_test_num_of_data|[63:0]|rw|default: 0x0000000000004000|||Number of bytes to be transmitted for TCP test mode|

### <div id="reg_table-tcp_test_data_gen"></div>tcp_test_data_gen

* offset_address
    * 0x17
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|tcp_test_data_gen|[0]|rw|default: 0x0|||Data transmission enable for TCP test mode|

### <div id="reg_table-tcp_test_word_len"></div>tcp_test_word_len

* offset_address
    * 0x18
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|tcp_test_word_len|[2:0]|rw|default: 0x7|||Word length of test data for one clock cycle for TCP test mode|

### <div id="reg_table-tcp_test_select_seq"></div>tcp_test_select_seq

* offset_address
    * 0x19
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|tcp_test_select_seq|[0]|rw|default: 0x0|||Use the sequence pattern as defined below for TCP test mode|

### <div id="reg_table-tcp_test_seq_pattern"></div>tcp_test_seq_pattern

* offset_address
    * 0x1a
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|tcp_test_seq_pattern|[31:0]|rw|default: 0x60808040|||Sequence pattern, each 4-bit define the number of bytes for one clock cycle|

### <div id="reg_table-tcp_test_blk_size"></div>tcp_test_blk_size

* offset_address
    * 0x1e
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|tcp_test_blk_size|[23:0]|rw|default: 0x000400|||Transmission block size in bytes for TCP test mode|

### <div id="reg_table-tcp_test_ins_error"></div>tcp_test_ins_error

* offset_address
    * 0x21
* type
    * default

|name|bit_assignments|type|initial_value|reference|labels|comment|
|:--|:--|:--|:--|:--|:--|:--|
|tcp_test_ins_error|[0]|w1trg|default: 0x0|||Data error insertion for TCP test mode|
