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

#Need apply patch to Xilinx MIG before can enable DDR4-2666 speed for DIMM/UDIMM.
set MEM_SPEED 2400
set MEM_PARTNUMBER MTA8ATF1G64HZ
#set MEM_PARTNUMBER BLS4G4S26BFSD
set USE_JTAG2AXI 1
set USE_PMU 1
set POWER_BUTTON 1

set ProjectName ZCU104_TESTSTAND

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

set_property  ip_repo_paths $sourceRoot/Interfaces [current_project]

set MEM_SPEED_STR 2400
set MEM_ADDR_WIDTH 32
if {$::MEM_PARTNUMBER == "BLS4G4S26BFSD"} {
    import_files -norecurse $sourceRoot/Memory/Crutial_Ballistix_Sport/BLS4G4S26BFSD.csv
    if {$MEM_SPEED == "2666"} {
        set MEM_SPEED_STR 2666
    } elseif {$MEM_SPEED == "2400"} {
        set MEM_SPEED_STR 2400
    }
}

if {$::MEM_PARTNUMBER == "MTA8ATF1G64HZ"} {
    import_files -norecurse $sourceRoot/Memory/Micron_MTA8ATF1G64HZ/MTA8ATF1G64HZ.csv
    set MEM_ADDR_WIDTH 33
    if {$MEM_SPEED == "2666"} {
        set MEM_SPEED_STR 2G6
    } elseif {$MEM_SPEED == "2400"} {
        set MEM_SPEED_STR 2G3
    }
}

update_ip_catalog
update_compile_order -fileset sources_1

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4:2.2 ddr4_pl
#apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {clk_300mhz ( Programmable Differential Clock (300MHz) ) } Manual_Source {Auto}}  [get_bd_intf_pins ddr4_pl/C0_SYS_CLK]
make_bd_intf_pins_external  [get_bd_intf_pins ddr4_pl/C0_DDR4]
make_bd_intf_pins_external  [get_bd_intf_pins ddr4_pl/C0_SYS_CLK]
set_property name sodimm_refclk [get_bd_intf_ports C0_SYS_CLK_0]
set_property CONFIG.FREQ_HZ 300000000 [get_bd_intf_ports /sodimm_refclk]
endgroup

set SODIMM [format %s-%s $MEM_PARTNUMBER $MEM_SPEED_STR]
if {$MEM_SPEED == 2666} {
    set_property -dict [list CONFIG.C0.DDR4_TimePeriod {750}] [get_bd_cells ddr4_pl]
    set_property -dict [list CONFIG.C0.DDR4_CustomParts [lindex [get_files */$MEM_PARTNUMBER.csv] 0] CONFIG.C0.DDR4_isCustom {true}] [get_bd_cells ddr4_pl]
    set_property -dict [list CONFIG.C0.DDR4_MemoryType {SODIMMs} CONFIG.C0.DDR4_MemoryPart ${SODIMM} CONFIG.C0.DDR4_DataWidth {64} CONFIG.C0.DDR4_AxiDataWidth {512} CONFIG.C0.DDR4_AxiAddressWidth ${MEM_ADDR_WIDTH}] [get_bd_cells ddr4_pl]
    set_property -dict [list CONFIG.C0.DDR4_InputClockPeriod {3334}] [get_bd_cells ddr4_pl]
} else {
    set_property -dict [list CONFIG.C0.DDR4_TimePeriod {833}] [get_bd_cells ddr4_pl]
    set_property -dict [list CONFIG.C0.DDR4_CustomParts [lindex [get_files */$MEM_PARTNUMBER.csv] 0] CONFIG.C0.DDR4_isCustom {true}] [get_bd_cells ddr4_pl]
    set_property -dict [list CONFIG.C0.DDR4_MemoryType {SODIMMs} CONFIG.C0.DDR4_MemoryPart ${SODIMM} CONFIG.C0.DDR4_DataWidth {64} CONFIG.C0.DDR4_AxiDataWidth {512} CONFIG.C0.DDR4_AxiAddressWidth ${MEM_ADDR_WIDTH}] [get_bd_cells ddr4_pl]
    set_property -dict [list CONFIG.C0.DDR4_InputClockPeriod {3332}] [get_bd_cells ddr4_pl]
}

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.5 zynq_ultra_ps_e_0
apply_bd_automation -rule xilinx.com:bd_rule:zynq_ultra_ps_e -config {apply_board_preset "1" }  [get_bd_cells zynq_ultra_ps_e_0]
endgroup

startgroup
set_property -dict [list CONFIG.PSU__USE__M_AXI_GP0 {1} CONFIG.PSU__USE__M_AXI_GP1 {0} CONFIG.PSU__USE__M_AXI_GP2 {0}] [get_bd_cells zynq_ultra_ps_e_0]
apply_bd_automation -rule xilinx.com:bd_rule:board -config { Board_Interface {reset ( FPGA Reset ) } Manual_Source {New External Port (ACTIVE_HIGH)}}  [get_bd_pins ddr4_pl/sys_rst]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {/ddr4_pl/c0_ddr4_ui_clk (333 MHz)} Clk_xbar {Auto} Master {/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD} Slave {/ddr4_pl/C0_DDR4_S_AXI} intc_ip {Auto} master_apm {0}}  [get_bd_intf_pins ddr4_pl/C0_DDR4_S_AXI]
set_property -dict [list CONFIG.ADDN_UI_CLKOUT1_FREQ_HZ {100}] [get_bd_cells ddr4_pl]
endgroup

set_property -dict [list CONFIG.PSU__I2C0__PERIPHERAL__ENABLE {1} CONFIG.PSU__I2C0__PERIPHERAL__IO {MIO 10 .. 11}] [get_bd_cells zynq_ultra_ps_e_0]

#HDMI TX
#if {$HDMI == 1}
#{
#    create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 ibufds_gt_odiv2
#    set_property -dict [list CONFIG.C_BUF_TYPE {BUFG_GT}] [get_bd_cells ibufds_gt_odiv2]
#
#    create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 ibufds_gt
#    set_property -dict [list CONFIG.C_BUF_TYPE {IBUFDSGTE}] [get_bd_cells ibufds_gt]
#
#    create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 const_vcc
#}

if {$USE_JTAG2AXI == 1} {

    set DATA_WIDTH [get_property CONFIG.C0.DDR4_DataWidth [get_bd_cells ddr4_pl]]
    #set ADDR_WIDTH [get_property CONFIG.C0.DDR4_AxiAddressWidth [get_bd_cells ddr4_pl]]

    create_bd_cell -type ip -vlnv xilinx.com:ip:jtag_axi:1.2 jtag2axi
    set_property -dict [list CONFIG.M_AXI_DATA_WIDTH $DATA_WIDTH CONFIG.M_AXI_ADDR_WIDTH {64}] [get_bd_cells jtag2axi]

    set N_MI [get_property CONFIG.NUM_SI [get_bd_cells axi_smc]]
    set_property -dict [list CONFIG.NUM_SI [expr {$N_MI + 1}]] [get_bd_cells axi_smc]

    connect_bd_net [get_bd_pins ddr4_pl/c0_ddr4_ui_clk] [get_bd_pins jtag2axi/aclk]
    connect_bd_net [get_bd_pins rst_ddr4_pl_300M/peripheral_aresetn] [get_bd_pins jtag2axi/aresetn]
    connect_bd_intf_net [get_bd_intf_pins jtag2axi/M_AXI] [get_bd_intf_pins axi_smc/S01_AXI]
}

if {$USE_PMU == 1} {
    
    set_property -dict [list CONFIG.PSU__PMU__PERIPHERAL__ENABLE {1} CONFIG.PSU__PMU__GPI1__ENABLE {0} \
			     CONFIG.PSU__PMU__GPI2__ENABLE {0} CONFIG.PSU__PMU__GPI3__ENABLE {0} \
                             CONFIG.PSU__PMU__GPI4__ENABLE {0} CONFIG.PSU__PMU__GPI5__ENABLE {0} \
                             CONFIG.PSU__PMU__GPO0__ENABLE {0} CONFIG.PSU__PMU__GPO1__ENABLE {0} \
                             CONFIG.PSU__PMU__GPO2__ENABLE {0} CONFIG.PSU__PMU__GPO3__ENABLE {0} \
                             CONFIG.PSU__PMU__GPO4__ENABLE {0} CONFIG.PSU__PMU__GPO5__ENABLE {0}] [get_bd_cells zynq_ultra_ps_e_0]
    
    if {$POWER_BUTTON == 1} {

        add_files -norecurse $sourceRoot/Boards/Xilinx_ZCU104/teststand_pmu_io.v

        set_property -dict [list CONFIG.PSU__PMU__GPI0__ENABLE {0} CONFIG.PSU__PMU__GPO2__ENABLE {0}] [get_bd_cells zynq_ultra_ps_e_0]
        set_property -dict [list CONFIG.PSU__PMU__EMIO_GPI__ENABLE {1} CONFIG.PSU__PMU__EMIO_GPO__ENABLE {1}] [get_bd_cells zynq_ultra_ps_e_0]
            
        create_bd_cell -type module -reference pmu_io PMU_IO
        connect_bd_net [get_bd_pins ddr4_pl/c0_ddr4_ui_clk] [get_bd_pins PMU_IO/CLOCK]
        connect_bd_net [get_bd_pins rst_ddr4_pl_300M/peripheral_aresetn] [get_bd_pins PMU_IO/RESETN]

        connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pmu_pl_gpo] [get_bd_pins PMU_IO/PMU_GPO]
        connect_bd_net [get_bd_pins PMU_IO/PMU_GPI] [get_bd_pins zynq_ultra_ps_e_0/pl_pmu_gpi]
   
        make_bd_intf_pins_external  [get_bd_intf_pins PMU_IO/PMU_IO]
        set_property name PMU_IO [get_bd_intf_ports PMU_IO_0]

        create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 CONSTANT_FMC
        make_bd_pins_external  [get_bd_pins CONSTANT_FMC/dout]
        set_property name FMC_IO_EN [get_bd_ports dout_0]
    }
}

#Set MicroSD clock to 50MHz
set_property -dict [list CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__FREQMHZ {50}] [get_bd_cells zynq_ultra_ps_e_0]


assign_bd_address
set_property range 8G [get_bd_addr_segs {zynq_ultra_ps_e_0/Data/SEG_ddr4_pl_C0_DDR4_ADDRESS_BLOCK}]

add_files -fileset constrs_1 -norecurse $sourceRoot/Boards/Xilinx_ZCU104/ZCU104_SODIMM.xdc
import_files -fileset constrs_1 $sourceRoot/Boards/Xilinx_ZCU104/ZCU104_SODIMM.xdc

add_files -fileset constrs_1 -norecurse $sourceRoot/Boards/Xilinx_ZCU104/ZCU104_TESTSTAND.xdc
import_files -fileset constrs_1 $sourceRoot/Boards/Xilinx_ZCU104/ZCU104_TESTSTAND.xdc


make_wrapper -files [get_files ./$ProjectName/$ProjectName.srcs/sources_1/bd/bd/bd.bd] -top
add_files -norecurse ./$ProjectName/$ProjectName.srcs/sources_1/bd/bd/hdl/bd_wrapper.v
update_compile_order -fileset sources_1

