
#Need apply patch to Xilinx MIG before can enable DDR4-2666 speed for DIMM/UDIMM.
set MEM_SPEED 2400

set ProjectName cvp13_ballistix

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

create_project $ProjectName $ProjectFolder -part xcvu13p-figd2104-2-e

create_bd_design "bd"

set_param synth.maxThreads 8
set_param general.maxThreads 12

import_files -norecurse $sourceRoot/Memory/Crutial_Ballistix_Sport/BLS4G4D240FSB.csv
import_files -fileset constrs_1 -norecurse $sourceRoot/Boards/Bittware_CVP13/CVP13_DIMM0.xdc
import_files -fileset constrs_1 -norecurse $sourceRoot/Boards/Bittware_CVP13/CVP13_DIMM1.xdc

#Uncomment to create local copy of files.
#add_files -fileset constrs_1 -norecurse $sourceRoot/Boards/Bittware_CVP13/CVP13_DIMM0.xdc
#add_files -fileset constrs_1 -norecurse $sourceRoot/Boards/Bittware_CVP13/CVP13_DIMM1.xdc


startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xdma:4.1 xdma_0
endgroup

startgroup
make_bd_intf_pins_external  [get_bd_intf_pins xdma_0/pcie_mgt]
set_property name pci_express_x1 [get_bd_intf_ports pcie_mgt_0]
make_bd_pins_external  [get_bd_pins xdma_0/sys_rst_n]
set_property name pcie_perstn [get_bd_ports sys_rst_n_0]
endgroup

startgroup
set_property -dict [list CONFIG.mode_selection {Basic}] [get_bd_cells xdma_0]
set_property -dict [list CONFIG.xdma_pcie_64bit_en {true} CONFIG.pf0_msix_cap_table_bir {BAR_1:0} CONFIG.pf0_msix_cap_pba_bir {BAR_1:0}] [get_bd_cells xdma_0]
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf_0
endgroup

startgroup
set_property -dict [list CONFIG.C_BUF_TYPE {IBUFDSGTE}] [get_bd_cells util_ds_buf_0]
#set_property -dict [list CONFIG.DIFF_CLK_IN_BOARD_INTERFACE {pcie_refclk}] [get_bd_cells util_ds_buf_0]
make_bd_intf_pins_external [get_bd_intf_pins util_ds_buf_0/CLK_IN_D]
set_property name pcie_refclk [get_bd_intf_ports CLK_IN_D_0]
connect_bd_net [get_bd_pins util_ds_buf_0/IBUF_DS_ODIV2] [get_bd_pins xdma_0/sys_clk]
connect_bd_net [get_bd_pins util_ds_buf_0/IBUF_OUT] [get_bd_pins xdma_0/sys_clk_gt]
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4:2.2 ddr4_0
create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4:2.2 ddr4_1

make_bd_intf_pins_external  [get_bd_intf_pins ddr4_0/C0_DDR4]
make_bd_intf_pins_external  [get_bd_intf_pins ddr4_1/C0_DDR4]

set_property name C1_DDR4_0 [get_bd_intf_ports C0_DDR4_1]
endgroup

if {$MEM_SPEED == 2666} {
    startgroup
    set_property -dict [list CONFIG.C0.DDR4_TimePeriod {750} CONFIG.C0.DDR4_InputClockPeriod {9996} CONFIG.C0.DDR4_CLKOUT0_DIVIDE {5}] [get_bd_cells ddr4_0]
    set_property -dict [list CONFIG.C0.DDR4_TimePeriod {750} CONFIG.C0.DDR4_InputClockPeriod {9996} CONFIG.C0.DDR4_CLKOUT0_DIVIDE {5}] [get_bd_cells ddr4_1]

    set_property -dict [list CONFIG.C0.DDR4_CustomParts [lindex [get_files */BLS4G4D240FSB.csv] 0] CONFIG.C0.DDR4_isCustom {true}] [get_bd_cells ddr4_0]
    set_property -dict [list CONFIG.C0.DDR4_CustomParts [lindex [get_files */BLS4G4D240FSB.csv] 0] CONFIG.C0.DDR4_isCustom {true}] [get_bd_cells ddr4_1]

    set_property -dict [list CONFIG.C0.DDR4_MemoryType {UDIMMs} CONFIG.C0.DDR4_MemoryPart {BLS4G4D240FSB-2666} CONFIG.C0.DDR4_DataWidth {64}] [get_bd_cells ddr4_0]
    set_property -dict [list CONFIG.C0.DDR4_MemoryType {UDIMMs} CONFIG.C0.DDR4_MemoryPart {BLS4G4D240FSB-2666} CONFIG.C0.DDR4_DataWidth {64}] [get_bd_cells ddr4_1]
    endgroup
} else {
    startgroup
    set_property -dict [list CONFIG.C0.DDR4_TimePeriod {833} CONFIG.C0.DDR4_InputClockPeriod {9996} CONFIG.C0.DDR4_CLKOUT0_DIVIDE {5}] [get_bd_cells ddr4_0]
    set_property -dict [list CONFIG.C0.DDR4_TimePeriod {833} CONFIG.C0.DDR4_InputClockPeriod {9996} CONFIG.C0.DDR4_CLKOUT0_DIVIDE {5}] [get_bd_cells ddr4_1]

    set_property -dict [list CONFIG.C0.DDR4_CustomParts [lindex [get_files */BLS4G4D240FSB.csv] 0] CONFIG.C0.DDR4_isCustom {true}] [get_bd_cells ddr4_0]
    set_property -dict [list CONFIG.C0.DDR4_CustomParts [lindex [get_files */BLS4G4D240FSB.csv] 0] CONFIG.C0.DDR4_isCustom {true}] [get_bd_cells ddr4_1]

    set_property -dict [list CONFIG.C0.DDR4_MemoryType {UDIMMs} CONFIG.C0.DDR4_MemoryPart {BLS4G4D240FSB-2400} CONFIG.C0.DDR4_DataWidth {64}] [get_bd_cells ddr4_0]
    set_property -dict [list CONFIG.C0.DDR4_MemoryType {UDIMMs} CONFIG.C0.DDR4_MemoryPart {BLS4G4D240FSB-2400} CONFIG.C0.DDR4_DataWidth {64}] [get_bd_cells ddr4_1]
    endgroup
}

startgroup
set_property -dict [list CONFIG.ADDN_UI_CLKOUT1_FREQ_HZ {100}] [get_bd_cells ddr4_0]
set_property -dict [list CONFIG.ADDN_UI_CLKOUT1_FREQ_HZ {100}] [get_bd_cells ddr4_1]
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0
set_property -dict [list CONFIG.C_SIZE {1} CONFIG.C_OPERATION {not} CONFIG.LOGO_FILE {data/sym_notgate.png}] [get_bd_cells util_vector_logic_0]
connect_bd_net [get_bd_ports pcie_perstn] [get_bd_pins util_vector_logic_0/Op1]
connect_bd_net [get_bd_pins util_vector_logic_0/Res] [get_bd_pins ddr4_0/sys_rst]
connect_bd_net [get_bd_pins util_vector_logic_0/Res] [get_bd_pins ddr4_1/sys_rst]
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc
endgroup

startgroup
set_property -dict [list CONFIG.NUM_MI {2} CONFIG.NUM_SI {1} CONFIG.NUM_CLKS {3}] [get_bd_cells axi_smc]
connect_bd_intf_net [get_bd_intf_pins xdma_0/M_AXI] [get_bd_intf_pins axi_smc/S00_AXI]
connect_bd_net [get_bd_pins xdma_0/axi_aclk] [get_bd_pins axi_smc/aclk]
connect_bd_net [get_bd_pins xdma_0/axi_aresetn] [get_bd_pins axi_smc/aresetn]
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 ddr4_c0_reset
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 ddr4_c1_reset
endgroup

startgroup
set_property -dict [list CONFIG.C_AUX_RESET_HIGH.VALUE_SRC USER] [get_bd_cells ddr4_c0_reset]
set_property -dict [list CONFIG.C_AUX_RESET_HIGH {0}] [get_bd_cells ddr4_c0_reset]

set_property -dict [list CONFIG.C_AUX_RESET_HIGH.VALUE_SRC USER] [get_bd_cells ddr4_c1_reset]
set_property -dict [list CONFIG.C_AUX_RESET_HIGH {0}] [get_bd_cells ddr4_c1_reset]

connect_bd_net [get_bd_pins ddr4_0/c0_ddr4_ui_clk] [get_bd_pins ddr4_c0_reset/slowest_sync_clk]
connect_bd_net [get_bd_pins ddr4_0/c0_ddr4_ui_clk_sync_rst] [get_bd_pins ddr4_c0_reset/ext_reset_in]
connect_bd_net [get_bd_pins ddr4_c0_reset/peripheral_aresetn] [get_bd_pins ddr4_0/c0_ddr4_aresetn]

connect_bd_net [get_bd_pins ddr4_1/c0_ddr4_ui_clk] [get_bd_pins ddr4_c1_reset/slowest_sync_clk]
connect_bd_net [get_bd_pins ddr4_1/c0_ddr4_ui_clk_sync_rst] [get_bd_pins ddr4_c1_reset/ext_reset_in]
connect_bd_net [get_bd_pins ddr4_c1_reset/peripheral_aresetn] [get_bd_pins ddr4_1/c0_ddr4_aresetn]
endgroup

startgroup
connect_bd_net [get_bd_pins ddr4_0/c0_ddr4_ui_clk] [get_bd_pins axi_smc/aclk1]
connect_bd_net [get_bd_pins ddr4_1/c0_ddr4_ui_clk] [get_bd_pins axi_smc/aclk2]
connect_bd_intf_net [get_bd_intf_pins axi_smc/M00_AXI] [get_bd_intf_pins ddr4_0/C0_DDR4_S_AXI]
connect_bd_intf_net [get_bd_intf_pins axi_smc/M01_AXI] [get_bd_intf_pins ddr4_1/C0_DDR4_S_AXI]

make_bd_intf_pins_external  [get_bd_intf_pins ddr4_0/C0_SYS_CLK]
make_bd_intf_pins_external  [get_bd_intf_pins ddr4_1/C0_SYS_CLK]

set_property name dimm0_refclk [get_bd_intf_ports C0_SYS_CLK_0]
set_property name dimm1_refclk [get_bd_intf_ports C0_SYS_CLK_1]

set_property CONFIG.FREQ_HZ 100000000 [get_bd_intf_ports /dimm0_refclk]
set_property CONFIG.FREQ_HZ 100000000 [get_bd_intf_ports /dimm1_refclk]
endgroup


assign_bd_address

make_wrapper -files [get_files ./$ProjectName/$ProjectName.srcs/sources_1/bd/bd/bd.bd] -top
add_files -norecurse ./$ProjectName/$ProjectName.srcs/sources_1/bd/bd/hdl/bd_wrapper.v

