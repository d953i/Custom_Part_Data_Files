
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
