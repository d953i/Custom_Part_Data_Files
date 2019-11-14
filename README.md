# Xilinx Vivado Custom Part Data Files (in CVS format)

Collection of memory configuration files for Xilinx Vivado along with example design for a few boards.

# Xilinx Vivado Custom Part Data Files (in CVS format)
Tested with Vivado version 2019.2

# DDR4 Memory
- UDIMM  Crutial Ballistix Sport BLS4G4D240FSB  (CT40A512M8RH-075E component) - 4GB
- UDIMM  Crutial Ballistix Sport BLS8G4D240FSB  (CT40A512M8RH-075E component) - 8GB
- UDIMM  Crutial Ballistix Sport BLS16G4D26BFSB (CT40A1G8WE-75H:D  component) - 16GB
- SODIMM Crutial Ballistix Sport BLS4G4S26BFSD  (CT40A512M8WE-75H component)  - 4GB
- SODIMM Micron MTA8ATF1G64HZ (MT40A1G8WE-075E component) - 8GB
  
# Example design for Ballistix 4GB UDIMM's
- Bittware CVP13
- Xilinx BCU1525
- Xilinx VCU1525
- Xilinx ZCU104

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
