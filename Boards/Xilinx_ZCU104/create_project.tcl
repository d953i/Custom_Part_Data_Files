
#Need apply patch to Xilinx MIG before can enable DDR4-2666 speed for DIMM/UDIMM.
set MEM_SPEED 2400

set ProjectName zcu104_ballistix

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

create_project $ProjectName ./$ProjectName -part xczu7ev-ffvc1156-2-e
set_property board_part xilinx.com:zcu104:part0:1.1 [current_project]

create_bd_design "bd"

set_param synth.maxThreads 8
set_param general.maxThreads 12

import_files -norecurse $sourceRoot/Memory/Crutial_Ballistix_Sport/BLS4G4S26BFSD.csv
import_files -norecurse $sourceRoot/Memory/Micron_MTA8ATF1G64HZ/MTA8ATF1G64HZ.csv

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4:2.2 ddr4_0
#apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {clk_300mhz ( Programmable Differential Clock (300MHz) ) } Manual_Source {Auto}}  [get_bd_intf_pins ddr4_0/C0_SYS_CLK]
make_bd_intf_pins_external  [get_bd_intf_pins ddr4_0/C0_DDR4]
make_bd_intf_pins_external  [get_bd_intf_pins ddr4_0/C0_SYS_CLK]
set_property name sodimm_refclk [get_bd_intf_ports C0_SYS_CLK_0]
set_property CONFIG.FREQ_HZ 300000000 [get_bd_intf_ports /sodimm_refclk]
endgroup

if {$MEM_SPEED == 2666} {
startgroup
set_property -dict [list CONFIG.C0.DDR4_TimePeriod {750}] [get_bd_cells ddr4_0]
set_property -dict [list CONFIG.C0.DDR4_CustomParts [lindex [get_files */BLS4G4S26BFSD.csv] 0] CONFIG.C0.DDR4_isCustom {true}] [get_bd_cells ddr4_0]
set_property -dict [list CONFIG.C0.DDR4_MemoryType {SODIMMs} CONFIG.C0.DDR4_MemoryPart {BLS4G4S26BFSD-2666} CONFIG.C0.DDR4_DataWidth {64} CONFIG.C0.DDR4_AxiDataWidth {512} CONFIG.C0.DDR4_AxiAddressWidth {32}] [get_bd_cells ddr4_0]
set_property -dict [list CONFIG.C0.DDR4_InputClockPeriod {3334}] [get_bd_cells ddr4_0]
endgroup
} else {
startgroup
set_property -dict [list CONFIG.C0.DDR4_TimePeriod {833}] [get_bd_cells ddr4_0]
set_property -dict [list CONFIG.C0.DDR4_CustomParts [lindex [get_files */BLS4G4S26BFSD.csv] 0] CONFIG.C0.DDR4_isCustom {true}] [get_bd_cells ddr4_0]
set_property -dict [list CONFIG.C0.DDR4_MemoryType {SODIMMs} CONFIG.C0.DDR4_MemoryPart {BLS4G4S26BFSD-2400} CONFIG.C0.DDR4_DataWidth {64} CONFIG.C0.DDR4_AxiDataWidth {512} CONFIG.C0.DDR4_AxiAddressWidth {32}] [get_bd_cells ddr4_0]
set_property -dict [list CONFIG.C0.DDR4_InputClockPeriod {3332}] [get_bd_cells ddr4_0]
endgroup
}

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.3 zynq_ultra_ps_e_0
apply_bd_automation -rule xilinx.com:bd_rule:zynq_ultra_ps_e -config {apply_board_preset "1" }  [get_bd_cells zynq_ultra_ps_e_0]
endgroup

startgroup
set_property -dict [list CONFIG.PSU__USE__M_AXI_GP0 {1} CONFIG.PSU__USE__M_AXI_GP1 {0} CONFIG.PSU__USE__M_AXI_GP2 {0}] [get_bd_cells zynq_ultra_ps_e_0]
apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {reset ( FPGA Reset ) } Manual_Source {New External Port (ACTIVE_HIGH)}}  [get_bd_pins ddr4_0/sys_rst]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {/ddr4_0/c0_ddr4_ui_clk (333 MHz)} Clk_xbar {Auto} Master {/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD} Slave {/ddr4_0/C0_DDR4_S_AXI} intc_ip {Auto} master_apm {0}}  [get_bd_intf_pins ddr4_0/C0_DDR4_S_AXI]
set_property -dict [list CONFIG.ADDN_UI_CLKOUT1_FREQ_HZ {100}] [get_bd_cells ddr4_0]
endgroup

assign_bd_address
set_property range 4G [get_bd_addr_segs {zynq_ultra_ps_e_0/Data/SEG_ddr4_0_C0_DDR4_ADDRESS_BLOCK}]

add_files -fileset constrs_1 -norecurse $sourceRoot/Boards/Xilinx_ZCU104/ZCU104_SODIMM.xdc
import_files -fileset constrs_1 $sourceRoot/Boards/Xilinx_ZCU104/ZCU104_SODIMM.xdc

make_wrapper -files [get_files ./$ProjectName/$ProjectName.srcs/sources_1/bd/bd/bd.bd] -top
add_files -norecurse ./$ProjectName/$ProjectName.srcs/sources_1/bd/bd/hdl/bd_wrapper.v
update_compile_order -fileset sources_1

