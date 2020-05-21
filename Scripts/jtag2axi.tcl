
proc write32 {addr value} {
    create_hw_axi_txn -force w0 [get_hw_axis hw_axi_1] -address [format 0x%016lx $addr] -data [format 0x%08lx $value] -type write -len 4
    run_hw_axi -quiet w0
}

proc write256 {} {
    set addr 0x400000000
    set value 0
    for {set i 0} {$i < 64} {incr i} {
        set addr [expr $addr + 4 * $i]
        set value 0
        set value [expr $value + [expr $i << 0]]
        set value [expr $value + [expr $i << 8]]
        set value [expr $value + [expr $i << 16]]
        set value [expr $value + [expr $i << 24]]
        puts "write to addr: [format 0x%010lx $addr] value: [format 0x%08lx $value]"
        write32 $addr $value
    }
}

proc read32 {addr} {
    create_hw_axi_txn -force r0 [get_hw_axis hw_axi_1] -address [format 0x%010lx $addr] -type read
    run_hw_axi -quiet r0
    set d0 [get_property DATA [get_hw_axi_txn r0]]
    puts "read from addr: [format 0x%09lx $addr] value: $d0"
}

proc read256 {} {
    set addr 0x400000000
    set value 0
    for {set i 0} {$i < 64} {incr i} {
        set addr [expr $addr + 4 * $i]
        read32 $addr
    }
}
