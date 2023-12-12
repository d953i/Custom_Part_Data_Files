###############################################################################
#
#  Copyright (c) 2001-2023 divashin@gmail.com
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License along
#  with this program; if not, write to the Free Software Foundation, Inc.,
#  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
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
