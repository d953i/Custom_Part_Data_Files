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

# DDR4 calibration, data and bandwidth test for a teststand built with USE_BWTEST 1
# (axi_bw_test + vio_bw on the DDR4 UI clock, see Boards/Xilinx_ZCU104/create_project_teststand.tcl).
#
# vivado -mode batch -source ddr4_bw_test.tcl -tclargs -ltx <file.ltx> [options]
#   -ltx <file>      probes file of the design (required)
#   -bit <file>      program this bitstream first (default: use what is in the FPGA)
#   -target <serial> JTAG cable serial, e.g. 87210A (required if more than one cable is connected)
#   -size_gb <n>     memory size to test (default 16)
#   -ui_ns <ns>      DDR4 UI clock period = 4 x tCK (default 3.752 for DDR4-2133;
#                    3.332 for DDR4-2400, 3.000 for DDR4-2666)
#   -base <addr>     DDR4 base address in the tester/JTAG-to-AXI space (default 0x1000000000)

array set opt {-ltx "" -bit "" -target "" -size_gb 16 -ui_ns 3.752 -base 0x1000000000}
foreach {k v} $argv {
    if {![info exists opt($k)]} { error "unknown option $k" }
    set opt($k) $v
}
if {$opt(-ltx) eq ""} { error "-ltx <probes file> is required" }
set ui_ns $opt(-ui_ns)
set DDR   $opt(-base)
set GB    [expr {1 << 30}]

open_hw_manager
connect_hw_server -url localhost:3121
set tgt [get_hw_targets */xilinx_tcf/*/$opt(-target)*]
if {[llength $tgt] != 1} {
    error "need exactly one JTAG target, found: [get_hw_targets] (use -target <serial>)"
}
open_hw_target $tgt
set dev [lindex [get_hw_devices xc*] 0]
current_hw_device $dev
puts "HW target $tgt device [get_property PART $dev] idcode [get_property IDCODE_HEX $dev]"
set_property PROBES.FILE $opt(-ltx) $dev
set_property FULL_PROBES.FILE $opt(-ltx) $dev
if {$opt(-bit) ne ""} {
    set_property PROGRAM.FILE $opt(-bit) $dev
    program_hw_devices $dev
    after 5000
}
refresh_hw_device $dev

# ---------------- calibration ----------------
set migs [get_hw_migs -of_objects $dev]
set calfail [expr {[llength $migs] == 0}]
foreach m $migs {
    refresh_hw_mig $m
    puts "CAL $m: [get_property CAL_ERROR_MSG $m]"
    if {[get_property CALIBRATION_FAIL.STATUS $m] eq "TRUE"} {
        set calfail 1
        puts "CAL FAIL rank [get_property CALIBRATION_FAIL.RANK $m] stage [get_property CALIBRATION_FAIL.STAGE $m]"
    }
    set npass 0
    array unset mg
    foreach p [list_property $m] {
        if {[string match CAL_STATUS.RANK* $p]} {
            set v [get_property $p $m]
            if {$v eq "PASS"} { incr npass } elseif {$v ne "SKIP"} { puts "CAL $p = $v" }
        } elseif {[regexp {^MARGIN_(\w+?)\.(?:\w+\.)?RANK(\d+)\.BYTE\d+\.(?:NIBBLE\d+\.)?(?:LEFT|RIGHT)$} $p -> kind rank]} {
            set v [get_property $p $m]
            if {$v eq "" || ![string is integer $v]} continue
            set key "rank$rank $kind"
            if {![info exists mg($key)]} { set mg($key) [list $v $v] }
            lassign $mg($key) lo hi
            set mg($key) [list [expr {min($lo, $v)}] [expr {max($hi, $v)}]]
        }
    }
    puts "CAL stages passed (all ranks): $npass"
    foreach key [lsort [array names mg]] { puts "CAL margin $key: [lindex $mg($key) 0]..[lindex $mg($key) 1] taps" }
}
if {$calfail} {
    puts "CAL FAILED - skipping traffic tests"
    close_hw_target
    disconnect_hw_server
    return
}

# ---------------- VIO-controlled bandwidth tester ----------------
set vio [lindex [get_hw_vios -of_objects $dev -filter {CELL_NAME =~ *vio_bw*}] 0]
if {$vio eq ""} { error "vio_bw not found - build the teststand with USE_BWTEST 1" }
set probes [get_hw_probes -of_objects $vio]
proc vp {pat} {
    upvar probes probes
    foreach p $probes { if {[string match $pat $p]} { return $p } }
    error "probe $pat not found"
}
set p_start [vp *probe_out0*]
set p_mode  [vp *probe_out1*]
set p_base  [vp *probe_out2*]
set p_len   [vp *probe_out3*]
set p_blen  [vp *probe_out4*]
set p_seed  [vp *probe_out5*]
set p_busy  [vp *busy*]
set p_done  [vp *done*]
set p_cyc   [vp *cycles*]
set p_err   [vp *bwtest_errors*]
set p_eaddr [vp *err_addr*]
set p_resp  [vp *resp_errors*]
foreach p [list $p_start $p_mode $p_base $p_len $p_blen $p_seed $p_busy $p_done $p_cyc $p_err $p_eaddr $p_resp] {
    catch {set_property OUTPUT_VALUE_RADIX HEX $p}
    catch {set_property INPUT_VALUE_RADIX HEX $p}
}

# VIO values are hex strings of the full probe width; Tcl format needs ll for > 32 bits.
proc setp {p v} {
    set w [get_property WIDTH $p]
    set_property OUTPUT_VALUE [format %0*llX [expr {($w + 3) / 4}] $v] $p
}
proc getp {p} { return [expr 0x[get_property INPUT_VALUE $p]] }

proc bwrun {mode base len blen seed} {
    global vio p_start p_mode p_base p_len p_blen p_seed p_busy p_done p_cyc p_err p_eaddr p_resp ui_ns
    setp $p_start 0; setp $p_mode $mode; setp $p_base $base; setp $p_len $len; setp $p_blen $blen; setp $p_seed $seed
    commit_hw_vio $vio
    setp $p_start 1; commit_hw_vio $vio
    setp $p_start 0; commit_hw_vio $vio
    set t0 [clock milliseconds]
    while 1 {
        refresh_hw_vio $vio
        if {[getp $p_done] && ![getp $p_busy]} break
        if {[clock milliseconds] - $t0 > 120000} { puts "BW TIMEOUT busy=[getp $p_busy]"; break }
        after 50
    }
    set cyc [getp $p_cyc]; set err [getp $p_err]; set resp [getp $p_resp]
    set gbps [expr {$cyc > 0 ? double($len) / ($cyc * $ui_ns) : 0}]
    puts [format "BW %-5s base=0x%09llX len=%6.3f GB burst=%3d beats  cycles=%d  %6.3f GB/s  errors=%d first_err=0x%09llX resp_err=%d" \
        [expr {$mode ? "READ" : "WRITE"}] $base [expr {$len / double(1 << 30)}] [expr {$blen + 1}] $cyc $gbps $err [getp $p_eaddr] $resp]
    return [list $gbps $err $resp]
}

set total_err 0

# Full-size data test, two seeds (64-beat bursts).
foreach seed {0x5A3C96E1 0xA5C3691E} {
    bwrun 0 $DDR [expr {$opt(-size_gb) * $GB}] 63 $seed
    set r [bwrun 1 $DDR [expr {$opt(-size_gb) * $GB}] 63 $seed]
    incr total_err [expr {[lindex $r 1] + [lindex $r 2]}]
}

# Bandwidth vs burst length on 1 GB.
foreach blen {63 31 15 7 3 1 0} {
    bwrun 0 $DDR $GB $blen 0x13579BDF
    set r [bwrun 1 $DDR $GB $blen 0x13579BDF]
    incr total_err [expr {[lindex $r 1] + [lindex $r 2]}]
}

# Cross-check through JTAG-to-AXI (if present) against the last pattern (seed 0x13579BDF).
set axi [lindex [get_hw_axis -quiet] 0]
if {$axi ne ""} {
    reset_hw_axi $axi
    foreach a {0x0 0x40 0x1234500 0x3FFFFFC0} {
        create_hw_axi_txn -force rd $axi -address [format %016llX [expr {$DDR + $a}]] -type read -len 2
        run_hw_axi -quiet rd
        set d [get_property DATA [get_hw_axi_txns rd]]
        # pattern word = absolute address / 8 (the tester sees the same address as JTAG-to-AXI)
        set w [expr {(($DDR + $a) >> 3) & 0xFFFFFFFF}]
        set exp [format %08X%08X%08X%08X [expr {(($w + 1) ^ 0x13579BDF) & 0xFFFFFFFF}] [expr {~($w + 1) & 0xFFFFFFFF}] [expr {($w ^ 0x13579BDF) & 0xFFFFFFFF}] [expr {~$w & 0xFFFFFFFF}]]
        set ok [string equal -nocase $d $exp]
        if {!$ok} { incr total_err }
        puts "JTAG2AXI +0x[format %09llX $a] data=$d expect=$exp [expr {$ok ? "OK" : "MISMATCH"}]"
    }
}

puts "TOTAL errors: $total_err ([expr {$total_err ? "FAIL" : "PASS"}])"
close_hw_target
disconnect_hw_server
