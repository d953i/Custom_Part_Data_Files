
set_property BITSTREAM.CONFIG.PUDC_B Pulldown [current_design]

# PMU IO on FMC LPC of ZCU104
set_property -dict {PACKAGE_PIN F7 IOSTANDARD LVCMOS18} [get_ports PMU_IO_power_int]
set_property -dict {PACKAGE_PIN C9 IOSTANDARD LVCMOS18} [get_ports PMU_IO_kill_power]

set_property -dict {PACKAGE_PIN F11 IOSTANDARD LVCMOS18 PULLTYPE PULLUP} [get_ports FMC_IO_EN]

