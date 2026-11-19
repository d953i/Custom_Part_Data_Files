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

set_property BITSTREAM.CONFIG.PUDC_B Pulldown [current_design]

# PMU IO on FMC LPC of ZCU104
set_property -dict {PACKAGE_PIN F7 IOSTANDARD LVCMOS18} [get_ports PMU_IO_power_int]
set_property -dict {PACKAGE_PIN C9 IOSTANDARD LVCMOS18} [get_ports PMU_IO_kill_power]

set_property -dict {PACKAGE_PIN F11 IOSTANDARD LVCMOS18 PULLTYPE PULLUP} [get_ports FMC_IO_EN]

