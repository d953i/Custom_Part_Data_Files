###############################################################################
#
#  Copyright (c) 2001-2026 divashin@gmail.com
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
################################################################################

proc write4B {addr value} {
    create_hw_axi_txn -force w0 [get_hw_axis hw_axi_1] -address [format 0x%016lx $addr] -data [format 0x%08lx $value] -type write -len 4
    run_hw_axi -quiet w0
}

proc write256B {} {
    set base_addr 0x400000000
    for {set i 0} {$i < 64} {incr i} {
        set addr [expr $base_addr + 4 * $i]
        set value 55
        set value [expr $value + [expr $i << 0]]
        set value [expr $value + [expr $i << 8]]
        set value [expr $value + [expr $i << 16]]
        set value [expr $value + [expr $i << 24]]
        puts "write to addr: [format 0x%010lx $addr] value: [format 0x%08lx $value]"
        write4B $addr $value
    }
}

proc read4B {addr} {
    create_hw_axi_txn -force r0 [get_hw_axis hw_axi_1] -address [format 0x%010lx $addr] -type read
    run_hw_axi -quiet r0
    set res [get_property DATA [get_hw_axi_txn r0]]
    puts "read from addr: [format 0x%010lx $addr] value: [format 0x$res]"
}

proc read256B {} {
    set base_addr 0x400000000
    set value 0
    for {set i 0} {$i < 64} {incr i} {
        set addr [expr $base_addr + 4 * $i]
        read4B $addr
    }
}
