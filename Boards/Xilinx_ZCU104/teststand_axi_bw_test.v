`timescale 1ps/1ps

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

// AXI4 bandwidth / data tester for the DDR4 path (teststand, controlled from Scripts/ddr4_bw_test.tcl through a VIO).
// mode 0: write [base, base+length) with an address-derived pattern.
// mode 1: read [base, base+length) and verify the pattern.
// base must be 4KB aligned, length a multiple of the burst size (burst_len+1)*64 bytes.
// cycles counts aclk cycles from start until the last B (write) / last checked R beat (read).
module axi_bw_test #
(
    parameter ADDR_W = 34
)
(
    input  wire                aclk,
    input  wire                aresetn,

    input  wire                start,
    input  wire                mode,
    input  wire [ADDR_W:0]     base,
    input  wire [ADDR_W:0]     length,
    input  wire [7:0]          burst_len,
    input  wire [31:0]         seed,

    output reg                 busy,
    output reg                 done,
    output reg  [47:0]         cycles,
    output reg  [31:0]         errors,
    output reg  [ADDR_W:0]     err_addr,
    output reg  [15:0]         resp_errors,

    output wire [ADDR_W-1:0]   m_axi_awaddr,
    output wire [7:0]          m_axi_awlen,
    output wire [2:0]          m_axi_awsize,
    output wire [1:0]          m_axi_awburst,
    output wire                m_axi_awlock,
    output wire [3:0]          m_axi_awcache,
    output wire [2:0]          m_axi_awprot,
    output wire [3:0]          m_axi_awqos,
    output reg                 m_axi_awvalid,
    input  wire                m_axi_awready,
    output wire [511:0]        m_axi_wdata,
    output wire [63:0]         m_axi_wstrb,
    output wire                m_axi_wlast,
    output reg                 m_axi_wvalid,
    input  wire                m_axi_wready,
    input  wire [1:0]          m_axi_bresp,
    input  wire                m_axi_bvalid,
    output wire                m_axi_bready,
    output wire [ADDR_W-1:0]   m_axi_araddr,
    output wire [7:0]          m_axi_arlen,
    output wire [2:0]          m_axi_arsize,
    output wire [1:0]          m_axi_arburst,
    output wire                m_axi_arlock,
    output wire [3:0]          m_axi_arcache,
    output wire [2:0]          m_axi_arprot,
    output wire [3:0]          m_axi_arqos,
    output reg                 m_axi_arvalid,
    input  wire                m_axi_arready,
    input  wire [511:0]        m_axi_rdata,
    input  wire [1:0]          m_axi_rresp,
    input  wire                m_axi_rlast,
    input  wire                m_axi_rvalid,
    output wire                m_axi_rready
);

// Pattern: 64-bit lane j of the 64-byte beat at address A carries
// {lane_word ^ seed, ~lane_word}, lane_word = A/8 + j (unique over 32 GB).
function [511:0] pattern;
    input [ADDR_W:0] a;
    input [31:0]     s;
    integer j;
    reg [31:0] w;
    begin
        for (j = 0; j < 8; j = j + 1) begin
            w = {a[ADDR_W:6], 3'b000} + j;
            pattern[64*j +: 64] = {w ^ s, ~w};
        end
    end
endfunction

reg              start_q;
reg              mode_r;
reg  [ADDR_W:0]  end_addr;
reg  [7:0]       blen;
reg  [31:0]      seed_r;
reg  [ADDR_W:0]  bstep;

reg  [ADDR_W:0]  a_addr;      // next AW/AR address
reg  [ADDR_W:0]  w_addr;      // next W beat address
reg  [7:0]       w_beat;      // beat index inside the current write burst
reg  [31:0]      a_issued;
reg  [31:0]      b_seen;
reg  [ADDR_W:0]  r_addr;      // address of the next R beat

// read check pipeline
reg              c1_v;
reg  [511:0]     c1_data;
reg  [ADDR_W:0]  c1_addr;
reg              c2_v;
reg  [7:0]       c2_bad;
reg  [ADDR_W:0]  c2_addr;
wire [511:0]     c1_exp = pattern(c1_addr, seed_r);

assign m_axi_awaddr  = a_addr[ADDR_W-1:0];
assign m_axi_araddr  = a_addr[ADDR_W-1:0];
assign m_axi_awlen   = blen;
assign m_axi_arlen   = blen;
assign m_axi_awsize  = 3'b110;
assign m_axi_arsize  = 3'b110;
assign m_axi_awburst = 2'b01;
assign m_axi_arburst = 2'b01;
assign m_axi_awlock  = 1'b0;
assign m_axi_arlock  = 1'b0;
assign m_axi_awcache = 4'b0011;
assign m_axi_arcache = 4'b0011;
assign m_axi_awprot  = 3'b000;
assign m_axi_arprot  = 3'b000;
assign m_axi_awqos   = 4'b0000;
assign m_axi_arqos   = 4'b0000;
assign m_axi_wdata   = pattern(w_addr, seed_r);
assign m_axi_wstrb   = {64{1'b1}};
assign m_axi_wlast   = (w_beat == blen);
assign m_axi_bready  = 1'b1;
assign m_axi_rready  = 1'b1;

wire aw_fire = m_axi_awvalid & m_axi_awready;
wire ar_fire = m_axi_arvalid & m_axi_arready;
wire w_fire  = m_axi_wvalid  & m_axi_wready;
wire b_fire  = m_axi_bvalid;
wire r_fire  = m_axi_rvalid;

wire wr_finished = !mode_r && (a_addr >= end_addr) && (b_seen == a_issued) && !m_axi_awvalid && !m_axi_wvalid;
wire rd_finished =  mode_r && (a_addr >= end_addr) && !m_axi_arvalid && (r_addr >= end_addr) && !c1_v && !c2_v;

integer k;
always @(posedge aclk) begin
    if (!aresetn) begin
        start_q       <= 1'b0;
        busy          <= 1'b0;
        done          <= 1'b0;
        cycles        <= 48'd0;
        errors        <= 32'd0;
        err_addr      <= {(ADDR_W+1){1'b0}};
        resp_errors   <= 16'd0;
        m_axi_awvalid <= 1'b0;
        m_axi_arvalid <= 1'b0;
        m_axi_wvalid  <= 1'b0;
        c1_v          <= 1'b0;
        c2_v          <= 1'b0;
        mode_r        <= 1'b0;
        a_addr        <= {(ADDR_W+1){1'b0}};
        end_addr      <= {(ADDR_W+1){1'b0}};
        r_addr        <= {(ADDR_W+1){1'b0}};
        a_issued      <= 32'd0;
        b_seen        <= 32'd0;
    end else begin
        start_q <= start;

        if (start && !start_q && !busy) begin
            busy        <= 1'b1;
            done        <= 1'b0;
            cycles      <= 48'd0;
            errors      <= 32'd0;
            err_addr    <= {(ADDR_W+1){1'b0}};
            resp_errors <= 16'd0;
            mode_r      <= mode;
            blen        <= burst_len;
            bstep       <= ({{(ADDR_W-7){1'b0}}, burst_len} + 1) << 6;
            seed_r      <= seed;
            end_addr    <= base + length;
            a_addr      <= base;
            w_addr      <= base;
            r_addr      <= base;
            w_beat      <= 8'd0;
            a_issued    <= 32'd0;
            b_seen      <= 32'd0;
            m_axi_awvalid <= !mode && (length != 0);
            m_axi_arvalid <=  mode && (length != 0);
            m_axi_wvalid  <= !mode && (length != 0);
        end else if (busy) begin
            cycles <= cycles + 1'b1;

            // address channel (AW or AR)
            if (aw_fire || ar_fire) begin
                a_addr   <= a_addr + bstep;
                a_issued <= a_issued + 1'b1;
                if (a_addr + bstep >= end_addr) begin
                    m_axi_awvalid <= 1'b0;
                    m_axi_arvalid <= 1'b0;
                end
            end

            // write data
            if (w_fire) begin
                w_addr <= w_addr + 7'd64;
                w_beat <= m_axi_wlast ? 8'd0 : w_beat + 1'b1;
                if (w_addr + 7'd64 >= end_addr)
                    m_axi_wvalid <= 1'b0;
            end

            // write responses
            if (b_fire) begin
                b_seen <= b_seen + 1'b1;
                if (m_axi_bresp != 2'b00)
                    resp_errors <= resp_errors + 1'b1;
            end

            // read data: stage 1 capture
            c1_v <= r_fire;
            if (r_fire) begin
                c1_data <= m_axi_rdata;
                c1_addr <= r_addr;
                r_addr  <= r_addr + 7'd64;
                if (m_axi_rresp != 2'b00)
                    resp_errors <= resp_errors + 1'b1;
            end

            // stage 2: per-lane compare
            c2_v    <= c1_v;
            c2_addr <= c1_addr;
            for (k = 0; k < 8; k = k + 1)
                c2_bad[k] <= c1_v && (c1_data[64*k +: 64] != c1_exp[64*k +: 64]);

            // stage 3: count
            if (c2_v && (|c2_bad)) begin
                if (errors == 32'd0)
                    err_addr <= c2_addr;
                errors <= errors + 1'b1;
            end

            if (wr_finished || rd_finished) begin
                busy <= 1'b0;
                done <= 1'b1;
            end
        end
    end
end

endmodule
