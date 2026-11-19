# Xilinx Vivado Custom Part Data Files (in CVS format)

Collection of memory configuration files for Xilinx Vivado along with example design for a few boards.

# Xilinx Vivado Custom Part Data Files (in CVS format)
Tested with Vivado version 2019.2, 2022.1 & 2025.2

# DDR4 Memory
- UDIMM  Crutial Ballistix Sport BLS4G4D240FSB  (CT40A512M8RH-075E component) - 4GB
- UDIMM  Crutial Ballistix Sport BLS8G4D240FSB  (CT40A512M8RH-075E component) - 8GB
- UDIMM  Crutial Ballistix Sport BLS16G4D26BFSB (CT40A1G8WE-75H:D  component) - 16GB
- SODIMM Crutial Ballistix Sport BLS4G4S26BFSD  (CT40A512M8WE-75H component)  - 4GB
- SODIMM Micron MTA8ATF1G64HZ (MT40A1G8WE-075E component) - 8GB
- SODIMM Samsung M471A2K43BB1-CPB (K4A8G085WB-BCPB 8Gb component, dual-rank, PC4-2133) - 16GB
- SODIMM Samsung M471A5244CB0-CTD (K4A8G165WC-BCTD 8Gb x16 component, single-rank, PC4-2666) - 4GB
  
# Example design for Ballistix 4GB UDIMM's
- Bittware CVP13
- Xilinx BCU1525
- Xilinx VCU1525
- Xilinx ZCU104

# ZCU104 PL SODIMM test results (Samsung M471A2K43BB1-CPB, 16GB dual-rank)
Tested 2026-11-19 with Vivado 2025.2 (DDR4 IP 2.2) on xczu7ev-ffvc1156-2-e, project from `Boards/Xilinx_ZCU104/create_project_teststand.tcl`.
- DDR4-2133 (tCK 938 ps, 300 MHz reference clock, InputClockPeriod 3335), 64-bit data, no ECC, CA mirror on. Dual-rank SODIMM on -2 speed grade is limited to DDR4-2133 by the DDR4 IP.
- FPGA DQ/DQS/DM IO: 40 Ohm drive, ODT RTT_60, EQ_LEVEL3, pre-emphasis RDRV_240 (AMD recommended setting for any DIMM/SODIMM, all speeds; RTT_40/EQ_LEVEL2 is the component-DRAM setting).
- Timing: WNS +0.442 ns, WHS +0.010 ns (29.2k LUTs, 42.7k FFs incl. the tester).
- Calibration: rank 0 and rank 1 pass all 31 executed stages. Read margin 47-55 taps rank 0, 47-54 taps rank 1 (complex pattern), 56-72 taps both ranks (simple pattern); 38-47 taps complex with the old RTT_40/EQ_LEVEL2 setting.
- Data test (`Scripts/ddr4_bw_test.tcl`; three runs on two builds, identical results): full 16GB write + read-verify, two patterns, 0 data/response errors; JTAG-to-AXI spot reads match. Bandwidth measured with the 512-bit AXI4 tester `Boards/Xilinx_ZCU104/teststand_axi_bw_test.v` on the DDR4 UI clock (266.5 MHz):

| AXI burst length | Write    | Read     |
|------------------|----------|----------|
| 64 / 32 beats    | 14.2 GB/s | 15.0 GB/s |
| 16 beats         | 13.7 GB/s | 15.0 GB/s |
| 8 beats          | 12.0 GB/s | 14.6 GB/s |
| 4 beats          | 9.2 GB/s  | 12.6 GB/s |
| 2 beats          | 6.2 GB/s  | 7.8 GB/s  |
| 1 beat           | 4.0 GB/s  | 3.9 GB/s  |

Theoretical peak at DDR4-2133 x64 is 17.06 GB/s (read reaches 88%).

# ZCU104 PL SODIMM test results (Samsung M471A5244CB0-CTD, 4GB single-rank x16)
Tested 2026-11-19 with Vivado 2025.2 (DDR4 IP 2.2), same teststand with `MEM_PARTNUMBER M471A5244CB0` and `MEM_SPEED 2400` or `2666`.
- 64-bit data, no ECC, four 8Gb x16 components (one bank group bit), DDR4 base address 0x4_0000_0000 (modules up to 4GB), same ODT/EQ settings as above.
- DDR4-2400: part M471A5244CB0-CRC (tCK 833 ps, InputClockPeriod 3332, CL18/CWL12) - the DDR4 IP maximum for a single-rank SODIMM on -2.
- DDR4-2666: part M471A5244CB0-CTD (tCK 750 ps, InputClockPeriod 3334, CL19/CWL14) - needs the MIG speed-limit patch (`Patches/xilinx_mig/time_periods.patch`; in Vivado 2025.2 the same line is line 584 of `data/ip/xilinx/mem_v1_4/csv/time_periods.csv`). This runs the -2 PL above AMD's supported DDR4 rate - use at your own risk.
- Six expected critical warnings from ZCU104_SODIMM.xdc for the second-rank/BG1 pins this module does not use.
- Data test at both speeds: full 4GB write + read-verify, two patterns, 0 data/response errors; JTAG-to-AXI spot reads match (two runs at 2666).

|                                | DDR4-2400           | DDR4-2666           |
|--------------------------------|---------------------|---------------------|
| Timing (WNS / WHS)             | +0.144 / +0.010 ns  | +0.222 / +0.010 ns  |
| Calibration                    | 17 stages pass      | 17 stages pass      |
| Read margin complex / simple   | 39-48 / 48-65 taps  | 34-42 / 42-59 taps  |
| UI clock                       | 300 MHz             | 333 MHz             |
| Write / read, 64 / 32 beats    | 15.4 / 17.8 GB/s    | 17.2 / 19.8 GB/s    |
| Write / read, 16 beats         | 15.4 / 17.5 GB/s    | 17.1 / 19.4 GB/s    |
| Write / read, 8 beats          | 13.6 / 16.6 GB/s    | 15.1 / 18.4 GB/s    |
| Write / read, 4 beats          | 10.6 / 14.7 GB/s    | 11.4 / 16.3 GB/s    |
| Write / read, 2 beats          | 7.1 / 9.1 GB/s      | 7.9 / 10.2 GB/s     |
| Write / read, 1 beat           | 4.6 / 4.6 GB/s      | 5.1 / 5.1 GB/s      |
| Theoretical peak (x64)         | 19.2 GB/s (read 93%) | 21.3 GB/s (read 93%) |

# Repeating the ZCU104 memory test
Build the teststand: `create_project_teststand.tcl` with `USE_BWTEST 1` adds the tester and its VIO behind the AXI SmartConnect at the same DDR4 address as the PS (the script prints it: 0x4_0000_0000 for modules up to 4GB, 0x10_0000_0000 above). The module and speed can be chosen by setting `MEM_PARTNUMBER` / `MEM_SPEED` before sourcing the script. Then run from a shell with the board on JTAG, e.g. for the 16GB module:<br>
```vivado -mode batch -source Scripts/ddr4_bw_test.tcl -tclargs -bit bd_wrapper.bit -ltx bd_wrapper.ltx -target 87210A -size_gb 16 -ui_ns 3.752 -base 0x1000000000```<br>
and for the 4GB module: `-size_gb 4 -ui_ns 3.332 -base 0x400000000` at DDR4-2400, `-ui_ns 3.000` at DDR4-2666.<br>
It prints the calibration result with per-rank margins, the full-size write/read-verify and bandwidth for burst lengths 64..1, then JTAG-to-AXI spot reads. `-ui_ns` is 4 x tCK (3.752 for DDR4-2133, 3.332 for 2400, 3.000 for 2666); `-bit` is optional (omit it to test the design already in the FPGA), `-target` is your JTAG cable serial.

Note: if rank 1 fails DQS gate calibration ("Pattern not found on GT_STATUS, all samples were 0", rank 0 passes), reseat the SODIMM - rank 1 not answering at all was a socket contact problem on our board.

# BCU1525 quad-channel example usage

Clone repo, go to your project directory and source TCL script from Vivado. For example:<br>
```cd ~```<br>
```git clone https://github.com/D953i/Custom_Part_Data_Files.git```

In Vivado TCL console:<br>
```source ../_github/Custom_Part_Data_Files/Boards/Xilinx_BCU1525/create_project.tcl```

# BCU1525 create project by using tcl script
![Vivado_Source_Script](Images/BCU1525_SourceScript.PNG?raw=true "Vivado Source Script Screenshot")

# BCU1525 quad-channel ddr4 example block diagram
![Vivado_Block_Diagram](Images/BCU1525_Quad_DDR4_BlockDiagram.PNG?raw=true "Vivado Block Diagram")

# BCU1525 quad-channel dd4 example memory map 
![Vivado_Memory_Map](Images/BCU1525_Quad_DDR4_MemoryMap.PNG?raw=true "Vivado Memory Map")

# BCU1525 quad-channel ddr4 example calibration
![Vivado_Calibration](Images/BCU1525_Quad_DDR4_Calibration.PNG?raw=true "Vivado Memory Calibration")

# Useful links
- <a href='https://www.micron.com/support/tools-and-utilities/fbga?fbga'>Micron FBGA and Component Marking Decoder</a><br>
- <a href='https://www.xilinx.com/support/answers/68937.html'>UltraScale/UltraScale+ DDR4 IP - Interface Calibration and Hardware Debug Guide</a><br>
- <a href='https://www.xilinx.com/support/answers/68976.html'>UltraScale/UltraScale+ DDR4 IP - User addition of pblock might cause skew violations between RIU_CLK and PLL_CLK pins of BITSLICE_CONTROL</a><br>
