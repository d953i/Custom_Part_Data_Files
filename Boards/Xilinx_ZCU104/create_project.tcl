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

#MEM_SPEED / MEM_PARTNUMBER can be set before sourcing this script to override the defaults below.
#The override applies to one run: both are cleared at the end, so a later run in the same Vivado session
#(this script or create_project_teststand.tcl) starts from its own defaults again.
#MEM_SPEED unset: the module's default speed (2400, or 2133 for the PC4-2133 modules).
#Need apply patch to Xilinx MIG before can enable DDR4-2666 speed for DIMM/UDIMM.
if {![info exists MEM_SPEED]} { set MEM_SPEED 0 }
#Default: the SODIMM of AMD's ZCU104 board preset, Micron MTA8ATF51264HZ-2G1 (4GB single-rank x8,
#DDR4-2133, part from Vivado's built-in DDR4 list; no CSV needed).
if {![info exists MEM_PARTNUMBER]} { set MEM_PARTNUMBER MTA8ATF51264HZ }
#set MEM_PARTNUMBER BLS4G4S26BFSD
#set MEM_PARTNUMBER MTA8ATF1G64HZ
#Dual-rank SODIMM (M471A2K43BB1) is limited to DDR4-2133 on xczu7ev-2; MEM_SPEED is forced.
#set MEM_PARTNUMBER M471A2K43BB1
#set MEM_PARTNUMBER M471A5244CB0

if {$MEM_PARTNUMBER == "BLS4G4S26BFSD"} {
    set ProjectName zcu104_ballistix
} else {
    set ProjectName zcu104_[string tolower $MEM_PARTNUMBER]
}

if {$MEM_SPEED == 2666} {
   append ProjectName $MEM_SPEED
}

set ProjectFolder ./$ProjectName

#Remove unnecessary files.
set file_list [glob -nocomplain webtalk*.*]
foreach name $file_list {
    file delete $name
}

#Delete old project if folder already exists.
if {[file exists .Xil]} { 
    file delete -force .Xil
}

#Delete old project if folder already exists.
if {[file exists "$ProjectFolder"]} { 
    file delete -force $ProjectFolder
}

set scriptPath [file dirname [file normalize [info script]]]
set sourceRoot [join [lrange [file split [file dirname [info script]]] 0 end-2] "/"]
#puts stdout [join [lrange [file split [file dirname [info script]]] 0 end-2] "/"]
#return -code 1

if {[lsearch -exact {2023.2 2025.2} [version -short]] < 0} {
    return -code error [format "This script is for Vivado version 2023.2 or 2025.2!"]
}

create_project $ProjectName ./$ProjectName -part xczu7ev-ffvc1156-2-e
set_property board_part xilinx.com:zcu104:part0:1.1 [current_project]

create_bd_design "bd"

set_param synth.maxThreads 8
set_param general.maxThreads 12

set MEM_SPEED_STR 2400
set MEM_ADDR_WIDTH 32
set MEM_CUSTOM 1
if {$MEM_PARTNUMBER == "MTA8ATF51264HZ"} {
    #AMD ZCU104 board preset SODIMM; Vivado lists it only as -2G1 (DDR4-2133).
    set MEM_CUSTOM 0
    if {$MEM_SPEED != 0 && $MEM_SPEED != 2133} {
        puts "WARNING: $MEM_PARTNUMBER-2G1 is the DDR4-2133 board preset part; MEM_SPEED $MEM_SPEED -> 2133"
    }
    set MEM_SPEED 2133
    set MEM_SPEED_STR 2G1
} elseif {$MEM_PARTNUMBER == "BLS4G4S26BFSD"} {
    import_files -norecurse $sourceRoot/Memory/Crutial_Ballistix_Sport/BLS4G4S26BFSD.csv
    if {$MEM_SPEED == "2666"} {
        set MEM_SPEED_STR 2666
    } else {
        set MEM_SPEED 2400
        set MEM_SPEED_STR 2400
    }
} elseif {$MEM_PARTNUMBER == "MTA8ATF1G64HZ"} {
    import_files -norecurse $sourceRoot/Memory/Micron_MTA8ATF1G64HZ/MTA8ATF1G64HZ.csv
    set MEM_ADDR_WIDTH 33
    if {$MEM_SPEED == "2666"} {
        set MEM_SPEED_STR 2G6
    } else {
        set MEM_SPEED 2400
        set MEM_SPEED_STR 2G3
    }
} elseif {$MEM_PARTNUMBER == "M471A2K43BB1"} {
    #Samsung 16GB dual-rank SODIMM, PC4-2133P (8Gb x8 K4A8G085WB components, 2 ranks).
    import_files -norecurse $sourceRoot/Memory/Samsung_M471A2K43BB1/M471A2K43BB1.csv
    set MEM_ADDR_WIDTH 34
    if {$MEM_SPEED != 0 && $MEM_SPEED != 2133} {
        puts "WARNING: $MEM_PARTNUMBER is a dual-rank PC4-2133 module; MEM_SPEED $MEM_SPEED -> 2133"
    }
    set MEM_SPEED 2133
    set MEM_SPEED_STR CPB
} elseif {$MEM_PARTNUMBER == "M471A5244CB0"} {
    #Samsung 4GB single-rank SODIMM, PC4-2666V (8Gb x16 K4A8G165WC components, 1 rank).
    import_files -norecurse $sourceRoot/Memory/Samsung_M471A5244CB0/M471A5244CB0.csv
    if {$MEM_SPEED == "2666"} {
        set MEM_SPEED_STR CTD
    } elseif {$MEM_SPEED == "2133"} {
        set MEM_SPEED_STR CPB
    } else {
        set MEM_SPEED 2400
        set MEM_SPEED_STR CRC
    }
} else {
    return -code error "Unknown MEM_PARTNUMBER $MEM_PARTNUMBER (MTA8ATF51264HZ, BLS4G4S26BFSD, MTA8ATF1G64HZ, M471A2K43BB1 or M471A5244CB0)"
}

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4:2.2 ddr4_0
#apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {clk_300mhz ( Programmable Differential Clock (300MHz) ) } Manual_Source {Auto}}  [get_bd_intf_pins ddr4_0/C0_SYS_CLK]
make_bd_intf_pins_external  [get_bd_intf_pins ddr4_0/C0_DDR4]
make_bd_intf_pins_external  [get_bd_intf_pins ddr4_0/C0_SYS_CLK]
set_property name sodimm_refclk [get_bd_intf_ports C0_SYS_CLK_0]
set_property CONFIG.FREQ_HZ 300000000 [get_bd_intf_ports /sodimm_refclk]
endgroup

set SODIMM [format %s-%s $MEM_PARTNUMBER $MEM_SPEED_STR]
#Memory clock period (ps) and matching 300MHz sodimm_refclk period accepted by the DDR4 IP.
if {$MEM_SPEED == 2666} {
    set MEM_TCK 750
    set MEM_REFCLK 3334
} elseif {$MEM_SPEED == 2133} {
    set MEM_TCK 938
    set MEM_REFCLK 3335
} else {
    set MEM_TCK 833
    set MEM_REFCLK 3332
}
startgroup
set_property -dict [list CONFIG.C0.DDR4_TimePeriod $MEM_TCK] [get_bd_cells ddr4_0]
if {$MEM_CUSTOM} {
    set_property -dict [list CONFIG.C0.DDR4_CustomParts [lindex [get_files */$MEM_PARTNUMBER.csv] 0] CONFIG.C0.DDR4_isCustom {true}] [get_bd_cells ddr4_0]
}
set_property -dict [list CONFIG.C0.DDR4_MemoryType {SODIMMs} CONFIG.C0.DDR4_MemoryPart ${SODIMM} CONFIG.C0.DDR4_DataWidth {64} CONFIG.C0.DDR4_AxiDataWidth {512} CONFIG.C0.DDR4_AxiAddressWidth ${MEM_ADDR_WIDTH}] [get_bd_cells ddr4_0]
set_property -dict [list CONFIG.C0.DDR4_InputClockPeriod $MEM_REFCLK] [get_bd_cells ddr4_0]
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.5 zynq_ultra_ps_e_0
apply_bd_automation -rule xilinx.com:bd_rule:zynq_ultra_ps_e -config {apply_board_preset "1" }  [get_bd_cells zynq_ultra_ps_e_0]
endgroup

startgroup
set_property -dict [list CONFIG.PSU__USE__M_AXI_GP0 {1} CONFIG.PSU__USE__M_AXI_GP1 {0} CONFIG.PSU__USE__M_AXI_GP2 {0}] [get_bd_cells zynq_ultra_ps_e_0]
apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {reset ( FPGA Reset ) } Manual_Source {New External Port (ACTIVE_HIGH)}}  [get_bd_pins ddr4_0/sys_rst]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {/ddr4_0/c0_ddr4_ui_clk (333 MHz)} Clk_xbar {Auto} Master {/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD} Slave {/ddr4_0/C0_DDR4_S_AXI} intc_ip {Auto} master_apm {0}}  [get_bd_intf_pins ddr4_0/C0_DDR4_S_AXI]
set_property -dict [list CONFIG.ADDN_UI_CLKOUT1_FREQ_HZ {100}] [get_bd_cells ddr4_0]
endgroup

assign_bd_address
set_property range [expr {1 << ($MEM_ADDR_WIDTH - 30)}]G [get_bd_addr_segs {zynq_ultra_ps_e_0/Data/SEG_ddr4_0_C0_DDR4_ADDRESS_BLOCK}]
#DDR4 base as seen by the PS: 0x4_0000_0000 for modules up to 4GB, 0x10_0000_0000 above.
puts "DDR4 base address: [get_property OFFSET [get_bd_addr_segs {zynq_ultra_ps_e_0/Data/SEG_ddr4_0_C0_DDR4_ADDRESS_BLOCK}]]"

add_files -fileset constrs_1 -norecurse $sourceRoot/Boards/Xilinx_ZCU104/ZCU104_SODIMM.xdc
import_files -fileset constrs_1 $sourceRoot/Boards/Xilinx_ZCU104/ZCU104_SODIMM.xdc

make_wrapper -files [get_files ./$ProjectName/$ProjectName.srcs/sources_1/bd/bd/bd.bd] -top
add_files -norecurse ./$ProjectName/$ProjectName.srcs/sources_1/bd/bd/hdl/bd_wrapper.v
update_compile_order -fileset sources_1

#One-run overrides (MEM_SPEED may also have been forced above, e.g. 2133 for the dual-rank module).
unset -nocomplain MEM_SPEED MEM_PARTNUMBER

