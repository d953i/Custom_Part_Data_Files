//##############################################################################
//
//  Copyright (c) 2001-2026 divashin@gmail.com
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//###############################################################################

`timescale 1ps/1ps

module pmu_io # 
(
    parameter CLOCK_FREQUENCE = 300000000,
    parameter POWERKILL_DELAY = 300000000
)    
(
    input wire CLOCK,
    input wire RESETN,

    (* X_INTERFACE_IGNORE = "true" *)
    input wire [31:0] PMU_GPO,
    (* X_INTERFACE_IGNORE = "true" *)
    output wire [31:0] PMU_GPI,

    (* X_INTERFACE_MODE = "Master" *)
    (* X_INTERFACE_INFO = "divashin:user:pmu_io:1.0 PMU_IO POWER_INT" *)
    input wire POWER_INT,
    (* X_INTERFACE_INFO = "divashin:user:pmu_io:1.0 PMU_IO KILL_POWER" *)
    output wire KILL_POWER
);

//reg [31:0] kill_counter;
//always @(posedge CLOCK) begin
//    if (!RESETN) begin
//        kill_counter <= 0;
//        KILL_POWER <= 0;
//    end else begin
//        if (PMU_GPO[0]) begin
//            kill_counter <= kill_counter + 1;
//            if (kill_counter >= POWERKILL_DELAY) begin
//                KILL_POWER <= 1;
//            end
//        end
//    end
//end

assign PMU_GPI[0] = POWER_INT;
assign KILL_POWER = PMU_GPO[0];

endmodule                        
