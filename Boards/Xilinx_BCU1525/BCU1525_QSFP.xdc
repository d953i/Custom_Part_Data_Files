
# BCU1525 QSFP I2C connected thru I2C Mux with address 0x74. Mux HiSide (3.3V):
# - Channel0: QSFP0 I2C                                        
# - Channel1: QSFP1 I2C
# - Channel2: USER Si750 Clock I2C
# - Channel3: SYSMon I2C
set_property -dict {PACKAGE_PIN BF19 IOSTANDARD LVCMOS12 } [get_ports I2C_FPGA_SDA_RESET] 
set_property -dict {PACKAGE_PIN BF20 IOSTANDARD LVCMOS12 } [get_ports I2C_FPGA_SCL_LS] 
set_property -dict {PACKAGE_PIN BF17 IOSTANDARD LVCMOS12 } [get_ports I2C_FPGA_SDA_LS]

# BCU1525 QSFP clocks
# FS[1:0] = 01 -> CLK1A/1B: 156.25 MHz 1.8V LVDS
# FS[1:0] = 1X -> CLK1A/1B: 161.1328125 MHz 1.8V LVDS
set_property -dict {PACKAGE_PIN AU19 IOSTANDARD LVCMOS12 } [get_ports USER_SI570_CLOCK_N]
set_property -dict {PACKAGE_PIN AV19 IOSTANDARD LVCMOS12 } [get_ports USER_SI570_CLOCK_N]
set_property -dict {PACKAGE_PIN M11 IOSTANDARD LVCMOS12 } [get_ports MGT_SI570_CLOCK0_C_P]
set_property -dict {PACKAGE_PIN M10 IOSTANDARD LVCMOS12 } [get_ports MGT_SI570_CLOCK0_C_N]
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS12 } [get_ports MGT_SI570_CLOCK1_C_P]
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS12 } [get_ports MGT_SI570_CLOCK1_C_N]
# 
set_property -dict {PACKAGE_PIN K11 IOSTANDARD LVCMOS12 } [get_ports QSFP0_CLOCK_P]
set_property -dict {PACKAGE_PIN K10 IOSTANDARD LVCMOS12 } [get_ports QSFP0_CLOCK_N]
set_property -dict {PACKAGE_PIN P11 IOSTANDARD LVCMOS12 } [get_ports QSFP1_CLOCK_P]
set_property -dict {PACKAGE_PIN P10 IOSTANDARD LVCMOS12 } [get_ports QSFP1_CLOCK_N]

# BCU1525 QSFP0
set_property -dict {PACKAGE_PIN AT22 IOSTANDARD LVCMOS12 } [get_ports QSFP0_REFCLK_RESET]
set_property -dict {PACKAGE_PIN BE16 IOSTANDARD LVCMOS12 } [get_ports QSFP0_MODSKLL]
set_property -dict {PACKAGE_PIN BE17 IOSTANDARD LVCMOS12 } [get_ports QSFP0_RESETL]
set_property -dict {PACKAGE_PIN BE20 IOSTANDARD LVCMOS12 } [get_ports QSFP0_MODPRSL]
set_property -dict {PACKAGE_PIN BE21 IOSTANDARD LVCMOS12 } [get_ports QSFP0_INTL]
set_property -dict {PACKAGE_PIN BD18 IOSTANDARD LVCMOS12 } [get_ports QSFP0_LPMODE]
set_property -dict {PACKAGE_PIN AT20 IOSTANDARD LVCMOS12 } [get_ports QSFP0_FS0]
set_property -dict {PACKAGE_PIN AU22 IOSTANDARD LVCMOS12 } [get_ports QSFP0_FS1]
set_property -dict {PACKAGE_PIN N9 IOSTANDARD LVCMOS12 } [get_ports QSFP0_TX1_P]
set_property -dict {PACKAGE_PIN N8 IOSTANDARD LVCMOS12 } [get_ports QSFP0_TX1_N]
set_property -dict {PACKAGE_PIN N4 IOSTANDARD LVCMOS12 } [get_ports QSFP0_RX1_P]
set_property -dict {PACKAGE_PIN N3 IOSTANDARD LVCMOS12 } [get_ports QSFP0_RX1_N]
set_property -dict {PACKAGE_PIN M7 IOSTANDARD LVCMOS12 } [get_ports QSFP0_TX2_P]
set_property -dict {PACKAGE_PIN M6 IOSTANDARD LVCMOS12 } [get_ports QSFP0_TX2_N]
set_property -dict {PACKAGE_PIN M2 IOSTANDARD LVCMOS12 } [get_ports QSFP0_RX2_P]
set_property -dict {PACKAGE_PIN M1 IOSTANDARD LVCMOS12 } [get_ports QSFP0_RX2_N]
set_property -dict {PACKAGE_PIN L9 IOSTANDARD LVCMOS12 } [get_ports QSFP0_TX3_P]
set_property -dict {PACKAGE_PIN L8 IOSTANDARD LVCMOS12 } [get_ports QSFP0_TX3_N]
set_property -dict {PACKAGE_PIN L4 IOSTANDARD LVCMOS12 } [get_ports QSFP0_RX3_P]
set_property -dict {PACKAGE_PIN L3 IOSTANDARD LVCMOS12 } [get_ports QSFP0_RX3_N]
set_property -dict {PACKAGE_PIN K7 IOSTANDARD LVCMOS12 } [get_ports QSFP0_TX4_P]
set_property -dict {PACKAGE_PIN K6 IOSTANDARD LVCMOS12 } [get_ports QSFP0_TX4_N]
set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS12 } [get_ports QSFP0_RX4_P]
set_property -dict {PACKAGE_PIN K1 IOSTANDARD LVCMOS12 } [get_ports QSFP0_RX4_N]



# BCU1525 QSFP1 Bank231
set_property -dict {PACKAGE_PIN AU20 IOSTANDARD LVCMOS12 } [get_ports QSFP1_REFCLK_RESET]
set_property -dict {PACKAGE_PIN AY20 IOSTANDARD LVCMOS12 } [get_ports QSFP1_MODSKLL]
set_property -dict {PACKAGE_PIN BC18 IOSTANDARD LVCMOS12 } [get_ports QSFP1_RESETL]
set_property -dict {PACKAGE_PIN BC19 IOSTANDARD LVCMOS12 } [get_ports QSFP1_MODPRSL]
set_property -dict {PACKAGE_PIN AV21 IOSTANDARD LVCMOS12 } [get_ports QSFP1_INTL]
set_property -dict {PACKAGE_PIN AV22 IOSTANDARD LVCMOS12 } [get_ports QSFP1_LPMODE]
set_property -dict {PACKAGE_PIN AR21 IOSTANDARD LVCMOS12 } [get_ports QSFP1_FS0]
set_property -dict {PACKAGE_PIN AR22 IOSTANDARD LVCMOS12 } [get_ports QSFP1_FS1]
set_property -dict {PACKAGE_PIN U9 IOSTANDARD LVCMOS12 } [get_ports QSFP1_TX1_P]
set_property -dict {PACKAGE_PIN U8 IOSTANDARD LVCMOS12 } [get_ports QSFP1_TX1_N]
set_property -dict {PACKAGE_PIN U4 IOSTANDARD LVCMOS12 } [get_ports QSFP1_RX1_P]
set_property -dict {PACKAGE_PIN U3 IOSTANDARD LVCMOS12 } [get_ports QSFP1_RX1_N]
set_property -dict {PACKAGE_PIN T7 IOSTANDARD LVCMOS12 } [get_ports QSFP1_TX2_P]
set_property -dict {PACKAGE_PIN T6 IOSTANDARD LVCMOS12 } [get_ports QSFP1_TX2_N]
set_property -dict {PACKAGE_PIN T2 IOSTANDARD LVCMOS12 } [get_ports QSFP1_RX2_P]
set_property -dict {PACKAGE_PIN T1 IOSTANDARD LVCMOS12 } [get_ports QSFP1_RX2_N]
set_property -dict {PACKAGE_PIN R9 IOSTANDARD LVCMOS12 } [get_ports QSFP1_TX3_P]
set_property -dict {PACKAGE_PIN R8 IOSTANDARD LVCMOS12 } [get_ports QSFP1_TX3_N]
set_property -dict {PACKAGE_PIN R4 IOSTANDARD LVCMOS12 } [get_ports QSFP1_RX3_P]
set_property -dict {PACKAGE_PIN R3 IOSTANDARD LVCMOS12 } [get_ports QSFP1_RX3_N]
set_property -dict {PACKAGE_PIN P7 IOSTANDARD LVCMOS12 } [get_ports QSFP1_TX4_P]
set_property -dict {PACKAGE_PIN P6 IOSTANDARD LVCMOS12 } [get_ports QSFP1_TX4_N]
set_property -dict {PACKAGE_PIN P2 IOSTANDARD LVCMOS12 } [get_ports QSFP1_RX4_P]
set_property -dict {PACKAGE_PIN P1 IOSTANDARD LVCMOS12 } [get_ports QSFP1_RX4_N]







