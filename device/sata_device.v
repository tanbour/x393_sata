/*******************************************************************************
 * Module: sata_device
 * Date: 2015-07-11  
 * Author: Alexey     
 * Description: sata device emul top level
 *
 * Copyright (c) 2015 Elphel, Inc.
 * sata_device.v is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * sata_device.v file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/> .
 *
 * Additional permission under GNU GPL version 3 section 7:
 * If you modify this Program, or any covered work, by linking or combining it
 * with independent modules provided by the FPGA vendor only (this permission
 * does not extend to any 3-rd party modules, "soft cores" or macros) under
 * different license terms solely for the purpose of generating binary "bitstream"
 * files and/or simulating the code, the copyright holders of this Program give
 * you the right to distribute the covered work without those independent modules
 * as long as the source code for them is available from the FPGA vendor free of
 * charge, and there is no dependence on any encrypted modules for simulating of
 * the combined code. This permission applies to you if the distributed code
 * contains all the components and scripts required to completely simulate it
 * with at least one of the Free Software programs.
 *******************************************************************************/
//`include "sata_phy_dev.v"
module sata_device(
    input   wire    rst,
    input   wire    RXN,
    input   wire    RXP,
    output  wire    TXN,
    output  wire    TXP,
    input   wire    EXTCLK_P,
    input   wire    EXTCLK_N
);
//`ifdef SIMULATION
    reg [639:0] DEV_TITLE; // to show human-readable state in the GTKWave
//    reg  [31:0] DEV_DATA;
    integer DEV_DATA;
//`endif

wire            phy_ready;

wire    [31:0]  phy2dev_data;
wire    [3:0]   phy2dev_charisk;
wire    [3:0]   phy2dev_err;
wire            clk;
wire            dev_rst;

reg     [31:0]  dev2phy_data    = 32'hB5B5957C; // SYNCP
reg     [3:0]   dev2phy_isk     = 4'h1;

sata_phy_dev phy(
    // pll reset
    .extrst             (rst),
    // top-level ifaces
    // ref clk from an external source, shall be connected to pads
    .extclk_p           (EXTCLK_P),
    .extclk_n           (EXTCLK_N),
    // sata link data pins
    .txp_out            (TXP),
    .txn_out            (TXN),
    .rxp_in             (RXP),
    .rxn_in             (RXN),

    .clk                (clk),
    .rst                (dev_rst),

    .phy_ready          (phy_ready),

    .ll_data_out        (phy2dev_data),
    .ll_charisk_out     (phy2dev_charisk),
    .ll_err_out         (phy2dev_err),

    .ll_data_in         (dev2phy_data),
    .ll_charisk_in      (dev2phy_isk)
);

localparam [31:0] PRIM_SYNCP    = {3'd5, 5'd21, 3'd5, 5'd21, 3'd4, 5'd21, 3'd3, 5'd28};
localparam [31:0] PRIM_ALIGNP   = {3'd3, 5'd27, 3'd2, 5'd10, 3'd2, 5'd10, 3'd5, 5'd28};
localparam [31:0] PRIM_XRDYP    = {3'd2, 5'd23, 3'd2, 5'd23, 3'd5, 5'd21, 3'd3, 5'd28};
localparam [31:0] PRIM_SOFP     = {3'd1, 5'd23, 3'd1, 5'd23, 3'd5, 5'd21, 3'd3, 5'd28};
localparam [31:0] PRIM_HOLDAP   = {3'd4, 5'd21, 3'd4, 5'd21, 3'd5, 5'd10, 3'd3, 5'd28};
localparam [31:0] PRIM_HOLDP    = {3'd6, 5'd21, 3'd6, 5'd21, 3'd5, 5'd10, 3'd3, 5'd28};
localparam [31:0] PRIM_EOFP     = {3'd6, 5'd21, 3'd6, 5'd21, 3'd5, 5'd21, 3'd3, 5'd28};
localparam [31:0] PRIM_WTRMP    = {3'd2, 5'd24, 3'd2, 5'd24, 3'd5, 5'd21, 3'd3, 5'd28};
localparam [31:0] PRIM_RRDYP    = {3'd2, 5'd10, 3'd2, 5'd10, 3'd4, 5'd21, 3'd3, 5'd28};
localparam [31:0] PRIM_IPP      = {3'd2, 5'd21, 3'd2, 5'd21, 3'd5, 5'd21, 3'd3, 5'd28};
localparam [31:0] PRIM_DMATP    = {3'd1, 5'd22, 3'd1, 5'd22, 3'd5, 5'd21, 3'd3, 5'd28};
localparam [31:0] PRIM_OKP      = {3'd1, 5'd21, 3'd1, 5'd21, 3'd5, 5'd21, 3'd3, 5'd28};
localparam [31:0] PRIM_ERRP     = {3'd2, 5'd22, 3'd2, 5'd22, 3'd5, 5'd21, 3'd3, 5'd28};

initial begin
    $display("LIST OF PRIMITIVES:");
    $display("SYNC  = %x", PRIM_SYNCP );
    $display("ALIGN = %x", PRIM_ALIGNP);
    $display("XRDY  = %x", PRIM_XRDYP );
    $display("SOF   = %x", PRIM_SOFP  );
    $display("HOLDA = %x", PRIM_HOLDAP);
    $display("HOLD  = %x", PRIM_HOLDP );
    $display("EOF   = %x", PRIM_EOFP  );
    $display("WTRM  = %x", PRIM_WTRMP );
    $display("RRDY  = %x", PRIM_RRDYP );
    $display("IP    = %x", PRIM_IPP   );
    $display("DMAT  = %x", PRIM_DMATP );
    $display("OK    = %x", PRIM_OKP   );
    $display("ERR   = %x", PRIM_ERRP  );
end



integer transmit_lock = 0;
integer receive_lock = 0;
integer suppress_receive = 0;

reg [31:0] receive_data [2047:0];
reg [31:0] receive_data_pause [2047:0];
reg [31:0] receive_wait_fifo;
reg [31:0] receive_crc;
integer    receive_id = 0;
integer    receive_status = 0;

/*
 * Monitor incoming primitives every clock cycle
 * if there is a data transfer request, start a receive sequence
 */
initial forever @ (posedge clk) begin
    if (~transmit_lock) begin
    // transmitting sequence is not started
        if (~receive_lock) begin
        // if for the current xrdy stream we haven't aready started a receiving sequence 
            if (~suppress_receive) begin
            // if we do not intentionally ignore host's transmissions
                if (linkGetPrim(0) == "XRDY") begin
                    linkMonitorFIS(receive_id, 2049, receive_status);
                    receive_id = receive_id + 1;
                end
            end
        end
    end
end

function [31:0] scrambleFunc; //SuppressThisWarning VEditor: VDT bug? it is used
    input [31:0] context;
    reg [31:0] next;
    reg [15:0] now;
    begin
        now = context[15:0];

        next[31] = now[12] ^ now[10] ^ now[7] ^ now[3] ^ now[1] ^ now[0];
        next[30] = now[15] ^ now[14] ^ now[12] ^ now[11] ^ now[9] ^ now[6] ^ now[3] ^ now[2] ^ now[0];
        next[29] = now[15] ^ now[13] ^ now[12] ^ now[11] ^ now[10] ^ now[8] ^ now[5] ^ now[3] ^ now[2] ^ now[1];
        next[28] = now[14] ^ now[12] ^ now[11] ^ now[10] ^ now[9] ^ now[7] ^ now[4] ^ now[2] ^ now[1] ^ now[0];
        next[27] = now[15] ^ now[14] ^ now[13] ^ now[12] ^ now[11] ^ now[10] ^ now[9] ^ now[8] ^ now[6] ^ now[1] ^ now[0];
        next[26] = now[15] ^ now[13] ^ now[11] ^ now[10] ^ now[9] ^ now[8] ^ now[7] ^ now[5] ^ now[3] ^ now[0];
        next[25] = now[15] ^ now[10] ^ now[9] ^ now[8] ^ now[7] ^ now[6] ^ now[4] ^ now[3] ^ now[2];
        next[24] = now[14] ^ now[9] ^ now[8] ^ now[7] ^ now[6] ^ now[5] ^ now[3] ^ now[2] ^ now[1];
        next[23] = now[13] ^ now[8] ^ now[7] ^ now[6] ^ now[5] ^ now[4] ^ now[2] ^ now[1] ^ now[0];
        next[22] = now[15] ^ now[14] ^ now[7] ^ now[6] ^ now[5] ^ now[4] ^ now[1] ^ now[0];
        next[21] = now[15] ^ now[13] ^ now[12] ^ now[6] ^ now[5] ^ now[4] ^ now[0];
        next[20] = now[15] ^ now[11] ^ now[5] ^ now[4];
        next[19] = now[14] ^ now[10] ^ now[4] ^ now[3];
        next[18] = now[13] ^ now[9] ^ now[3] ^ now[2];
        next[17] = now[12] ^ now[8] ^ now[2] ^ now[1];
        next[16] = now[11] ^ now[7] ^ now[1] ^ now[0];

        next[15] = now[15] ^ now[14] ^ now[12] ^ now[10] ^ now[6] ^ now[3] ^ now[0];
        next[14] = now[15] ^ now[13] ^ now[12] ^ now[11] ^ now[9] ^ now[5] ^ now[3] ^ now[2];
        next[13] = now[14] ^ now[12] ^ now[11] ^ now[10] ^ now[8] ^ now[4] ^ now[2] ^ now[1];
        next[12] = now[13] ^ now[11] ^ now[10] ^ now[9] ^ now[7] ^ now[3] ^ now[1] ^ now[0];
        next[11] = now[15] ^ now[14] ^ now[10] ^ now[9] ^ now[8] ^ now[6] ^ now[3] ^ now[2] ^ now[0];
        next[10] = now[15] ^ now[13] ^ now[12] ^ now[9] ^ now[8] ^ now[7] ^ now[5] ^ now[3] ^ now[2] ^ now[1];
        next[9] = now[14] ^ now[12] ^ now[11] ^ now[8] ^ now[7] ^ now[6] ^ now[4] ^ now[2] ^ now[1] ^ now[0];
        next[8] = now[15] ^ now[14] ^ now[13] ^ now[12] ^ now[11] ^ now[10] ^ now[7] ^ now[6] ^ now[5] ^ now[1] ^ now[0];
        next[7] = now[15] ^ now[13] ^ now[11] ^ now[10] ^ now[9] ^ now[6] ^ now[5] ^ now[4] ^ now[3] ^ now[0];
        next[6] = now[15] ^ now[10] ^ now[9] ^ now[8] ^ now[5] ^ now[4] ^ now[2];
        next[5] = now[14] ^ now[9] ^ now[8] ^ now[7] ^ now[4] ^ now[3] ^ now[1];
        next[4] = now[13] ^ now[8] ^ now[7] ^ now[6] ^ now[3] ^ now[2] ^ now[0];
        next[3] = now[15] ^ now[14] ^ now[7] ^ now[6] ^ now[5] ^ now[3] ^ now[2] ^ now[1];
        next[2] = now[14] ^ now[13] ^ now[6] ^ now[5] ^ now[4] ^ now[2] ^ now[1] ^ now[0];
        next[1] = now[15] ^ now[14] ^ now[13] ^ now[5] ^ now[4] ^ now[1] ^ now[0];
        next[0] = now[15] ^ now[13] ^ now[4] ^ now[0];

        scrambleFunc = next;
    end
endfunction

function [31:0] calculateCRC;  //SuppressThisWarning VEditor VDT bug, it is used
    input [31:0] seed;
    input [31:0] data;
    reg [31:0] crc_bit;
    reg [31:0] new_bit;
    begin
        crc_bit = seed ^ data;

        new_bit[31] = crc_bit[31] ^ crc_bit[30] ^ crc_bit[29] ^ crc_bit[28] ^ crc_bit[27] ^ crc_bit[25] ^ crc_bit[24] ^
                      crc_bit[23] ^ crc_bit[15] ^ crc_bit[11] ^ crc_bit[9]  ^ crc_bit[8]  ^ crc_bit[5];
        new_bit[30] = crc_bit[30] ^ crc_bit[29] ^ crc_bit[28] ^ crc_bit[27] ^ crc_bit[26] ^ crc_bit[24] ^ crc_bit[23] ^
                      crc_bit[22] ^ crc_bit[14] ^ crc_bit[10] ^ crc_bit[8]  ^ crc_bit[7]  ^ crc_bit[4];
        new_bit[29] = crc_bit[31] ^ crc_bit[29] ^ crc_bit[28] ^ crc_bit[27] ^ crc_bit[26] ^ crc_bit[25] ^ crc_bit[23] ^
                      crc_bit[22] ^ crc_bit[21] ^ crc_bit[13] ^ crc_bit[9]  ^ crc_bit[7]  ^ crc_bit[6]  ^ crc_bit[3];
        new_bit[28] = crc_bit[30] ^ crc_bit[28] ^ crc_bit[27] ^ crc_bit[26] ^ crc_bit[25] ^ crc_bit[24] ^ crc_bit[22] ^
                      crc_bit[21] ^ crc_bit[20] ^ crc_bit[12] ^ crc_bit[8]  ^ crc_bit[6]  ^ crc_bit[5]  ^ crc_bit[2];
        new_bit[27] = crc_bit[29] ^ crc_bit[27] ^ crc_bit[26] ^ crc_bit[25] ^ crc_bit[24] ^ crc_bit[23] ^ crc_bit[21] ^
                      crc_bit[20] ^ crc_bit[19] ^ crc_bit[11] ^ crc_bit[7]  ^ crc_bit[5]  ^ crc_bit[4]  ^ crc_bit[1];
        new_bit[26] = crc_bit[31] ^ crc_bit[28] ^ crc_bit[26] ^ crc_bit[25] ^ crc_bit[24] ^ crc_bit[23] ^ crc_bit[22] ^
                      crc_bit[20] ^ crc_bit[19] ^ crc_bit[18] ^ crc_bit[10] ^ crc_bit[6]  ^ crc_bit[4]  ^ crc_bit[3]  ^
                      crc_bit[0];
        new_bit[25] = crc_bit[31] ^ crc_bit[29] ^ crc_bit[28] ^ crc_bit[22] ^ crc_bit[21] ^ crc_bit[19] ^ crc_bit[18] ^
                      crc_bit[17] ^ crc_bit[15] ^ crc_bit[11] ^ crc_bit[8]  ^ crc_bit[3]  ^ crc_bit[2];
        new_bit[24] = crc_bit[30] ^ crc_bit[28] ^ crc_bit[27] ^ crc_bit[21] ^ crc_bit[20] ^ crc_bit[18] ^ crc_bit[17] ^
                      crc_bit[16] ^ crc_bit[14] ^ crc_bit[10] ^ crc_bit[7]  ^ crc_bit[2]  ^ crc_bit[1];
        new_bit[23] = crc_bit[31] ^ crc_bit[29] ^ crc_bit[27] ^ crc_bit[26] ^ crc_bit[20] ^ crc_bit[19] ^ crc_bit[17] ^
                      crc_bit[16] ^ crc_bit[15] ^ crc_bit[13] ^ crc_bit[9]  ^ crc_bit[6]  ^ crc_bit[1]  ^ crc_bit[0];
        new_bit[22] = crc_bit[31] ^ crc_bit[29] ^ crc_bit[27] ^ crc_bit[26] ^ crc_bit[24] ^ crc_bit[23] ^ crc_bit[19] ^
                      crc_bit[18] ^ crc_bit[16] ^ crc_bit[14] ^ crc_bit[12] ^ crc_bit[11] ^ crc_bit[9]  ^ crc_bit[0];
        new_bit[21] = crc_bit[31] ^ crc_bit[29] ^ crc_bit[27] ^ crc_bit[26] ^ crc_bit[24] ^ crc_bit[22] ^ crc_bit[18] ^
                      crc_bit[17] ^ crc_bit[13] ^ crc_bit[10] ^ crc_bit[9]  ^ crc_bit[5];
        new_bit[20] = crc_bit[30] ^ crc_bit[28] ^ crc_bit[26] ^ crc_bit[25] ^ crc_bit[23] ^ crc_bit[21] ^ crc_bit[17] ^
                      crc_bit[16] ^ crc_bit[12] ^ crc_bit[9]  ^ crc_bit[8]  ^ crc_bit[4];
        new_bit[19] = crc_bit[29] ^ crc_bit[27] ^ crc_bit[25] ^ crc_bit[24] ^ crc_bit[22] ^ crc_bit[20] ^ crc_bit[16] ^
                      crc_bit[15] ^ crc_bit[11] ^ crc_bit[8]  ^ crc_bit[7]  ^ crc_bit[3];
        new_bit[18] = crc_bit[31] ^ crc_bit[28] ^ crc_bit[26] ^ crc_bit[24] ^ crc_bit[23] ^ crc_bit[21] ^ crc_bit[19] ^
                      crc_bit[15] ^ crc_bit[14] ^ crc_bit[10] ^ crc_bit[7]  ^ crc_bit[6]  ^ crc_bit[2];
        new_bit[17] = crc_bit[31] ^ crc_bit[30] ^ crc_bit[27] ^ crc_bit[25] ^ crc_bit[23] ^ crc_bit[22] ^ crc_bit[20] ^
                      crc_bit[18] ^ crc_bit[14] ^ crc_bit[13] ^ crc_bit[9]  ^ crc_bit[6]  ^ crc_bit[5]  ^ crc_bit[1];
        new_bit[16] = crc_bit[30] ^ crc_bit[29] ^ crc_bit[26] ^ crc_bit[24] ^ crc_bit[22] ^ crc_bit[21] ^ crc_bit[19] ^
                      crc_bit[17] ^ crc_bit[13] ^ crc_bit[12] ^ crc_bit[8]  ^ crc_bit[5]  ^ crc_bit[4]  ^ crc_bit[0];
        new_bit[15] = crc_bit[30] ^ crc_bit[27] ^ crc_bit[24] ^ crc_bit[21] ^ crc_bit[20] ^ crc_bit[18] ^ crc_bit[16] ^
                      crc_bit[15] ^ crc_bit[12] ^ crc_bit[9]  ^ crc_bit[8]  ^ crc_bit[7]  ^ crc_bit[5]  ^ crc_bit[4]  ^
                      crc_bit[3];
        new_bit[14] = crc_bit[29] ^ crc_bit[26] ^ crc_bit[23] ^ crc_bit[20] ^ crc_bit[19] ^ crc_bit[17] ^ crc_bit[15] ^
                      crc_bit[14] ^ crc_bit[11] ^ crc_bit[8]  ^ crc_bit[7]  ^ crc_bit[6]  ^ crc_bit[4]  ^ crc_bit[3]  ^
                      crc_bit[2];
        new_bit[13] = crc_bit[31] ^ crc_bit[28] ^ crc_bit[25] ^ crc_bit[22] ^ crc_bit[19] ^ crc_bit[18] ^ crc_bit[16] ^
                      crc_bit[14] ^ crc_bit[13] ^ crc_bit[10] ^ crc_bit[7]  ^ crc_bit[6]  ^ crc_bit[5]  ^ crc_bit[3]  ^
                      crc_bit[2]  ^ crc_bit[1];
        new_bit[12] = crc_bit[31] ^ crc_bit[30] ^ crc_bit[27] ^ crc_bit[24] ^ crc_bit[21] ^ crc_bit[18] ^ crc_bit[17] ^
                      crc_bit[15] ^ crc_bit[13] ^ crc_bit[12] ^ crc_bit[9]  ^ crc_bit[6]  ^ crc_bit[5]  ^ crc_bit[4]  ^
                      crc_bit[2]  ^ crc_bit[1]  ^ crc_bit[0];
        new_bit[11] = crc_bit[31] ^ crc_bit[28] ^ crc_bit[27] ^ crc_bit[26] ^ crc_bit[25] ^ crc_bit[24] ^ crc_bit[20] ^
                      crc_bit[17] ^ crc_bit[16] ^ crc_bit[15] ^ crc_bit[14] ^ crc_bit[12] ^ crc_bit[9]  ^ crc_bit[4]  ^
                      crc_bit[3]  ^ crc_bit[1]  ^ crc_bit[0];
        new_bit[10] = crc_bit[31] ^ crc_bit[29] ^ crc_bit[28] ^ crc_bit[26] ^ crc_bit[19] ^ crc_bit[16] ^ crc_bit[14] ^
                      crc_bit[13] ^ crc_bit[9]  ^ crc_bit[5]  ^ crc_bit[3]  ^ crc_bit[2]  ^ crc_bit[0];
        new_bit[9]  = crc_bit[29] ^ crc_bit[24] ^ crc_bit[23] ^ crc_bit[18] ^ crc_bit[13] ^ crc_bit[12] ^ crc_bit[11] ^
                      crc_bit[9]  ^ crc_bit[5]  ^ crc_bit[4]  ^ crc_bit[2]  ^ crc_bit[1];
        new_bit[8]  = crc_bit[31] ^ crc_bit[28] ^ crc_bit[23] ^ crc_bit[22] ^ crc_bit[17] ^ crc_bit[12] ^ crc_bit[11] ^
                      crc_bit[10] ^ crc_bit[8]  ^ crc_bit[4]  ^ crc_bit[3]  ^ crc_bit[1]  ^ crc_bit[0];
        new_bit[7]  = crc_bit[29] ^ crc_bit[28] ^ crc_bit[25] ^ crc_bit[24] ^ crc_bit[23] ^ crc_bit[22] ^ crc_bit[21] ^
                      crc_bit[16] ^ crc_bit[15] ^ crc_bit[10] ^ crc_bit[8]  ^ crc_bit[7]  ^ crc_bit[5]  ^ crc_bit[3]  ^
                      crc_bit[2]  ^ crc_bit[0];
        new_bit[6]  = crc_bit[30] ^ crc_bit[29] ^ crc_bit[25] ^ crc_bit[22] ^ crc_bit[21] ^ crc_bit[20] ^ crc_bit[14] ^
                      crc_bit[11] ^ crc_bit[8]  ^ crc_bit[7]  ^ crc_bit[6]  ^ crc_bit[5]  ^ crc_bit[4]  ^ crc_bit[2]  ^
                      crc_bit[1];
        new_bit[5]  = crc_bit[29] ^ crc_bit[28] ^ crc_bit[24] ^ crc_bit[21] ^ crc_bit[20] ^ crc_bit[19] ^ crc_bit[13] ^
                      crc_bit[10] ^ crc_bit[7]  ^ crc_bit[6]  ^ crc_bit[5]  ^ crc_bit[4]  ^ crc_bit[3]  ^ crc_bit[1]  ^
                      crc_bit[0];
        new_bit[4]  = crc_bit[31] ^ crc_bit[30] ^ crc_bit[29] ^ crc_bit[25] ^ crc_bit[24] ^ crc_bit[20] ^ crc_bit[19] ^
                      crc_bit[18] ^ crc_bit[15] ^ crc_bit[12] ^ crc_bit[11] ^ crc_bit[8]  ^ crc_bit[6]  ^ crc_bit[4]  ^
                      crc_bit[3]  ^ crc_bit[2]  ^ crc_bit[0];
        new_bit[3]  = crc_bit[31] ^ crc_bit[27] ^ crc_bit[25] ^ crc_bit[19] ^ crc_bit[18] ^ crc_bit[17] ^ crc_bit[15] ^
                      crc_bit[14] ^ crc_bit[10] ^ crc_bit[9]  ^ crc_bit[8]  ^ crc_bit[7]  ^ crc_bit[3]  ^ crc_bit[2]  ^
                      crc_bit[1];
        new_bit[2]  = crc_bit[31] ^ crc_bit[30] ^ crc_bit[26] ^ crc_bit[24] ^ crc_bit[18] ^ crc_bit[17] ^ crc_bit[16] ^
                      crc_bit[14] ^ crc_bit[13] ^ crc_bit[9]  ^ crc_bit[8]  ^ crc_bit[7]  ^ crc_bit[6]  ^ crc_bit[2]  ^
                      crc_bit[1]  ^ crc_bit[0];
        new_bit[1]  = crc_bit[28] ^ crc_bit[27] ^ crc_bit[24] ^ crc_bit[17] ^ crc_bit[16] ^ crc_bit[13] ^ crc_bit[12] ^
                      crc_bit[11] ^ crc_bit[9]  ^ crc_bit[7]  ^ crc_bit[6]  ^ crc_bit[1]  ^ crc_bit[0];
        new_bit[0]  = crc_bit[31] ^ crc_bit[30] ^ crc_bit[29] ^ crc_bit[28] ^ crc_bit[26] ^ crc_bit[25] ^ crc_bit[24] ^
                      crc_bit[16] ^ crc_bit[12] ^ crc_bit[10] ^ crc_bit[9]  ^ crc_bit[6]  ^ crc_bit[0];

        calculateCRC = new_bit;
    end
endfunction

// stub TODO
function tranCheckFIS; //SuppressThisWarning VEditor: VDT bug - the function is used in conditional expression
    input count;
    begin
//        $display("[Device] TRANSPORT: Says the FIS is valid");
        DEV_TITLE = "Says the FIS is valid";
        $display("[Device] TRANSPORT: %s @%t", DEV_TITLE, $time);
        
        tranCheckFIS = 0; // always tell LL the FIS os OK
    end
endfunction

// TODO align every 256 dwords!
/*
 * Receives data from a host. ~Link Receive FSM
 * Correct execution, as it shall be w/o errors from a device side.
 *
 * Received data is stored in receive_data memory. 
 * Data is received by a dword // TODO make support for uneven words (16bit each) count
 *
 * Each data bundle has corresponding "pause" register, stored in a memory 'receive_data_pause'
 * It represents a time (in clock cycles), for which the device shall send HOLD primitives after
 * current data bundle reception. If after HOLD request data is still coming, consequetive 'pause's are summed up.
 * Could be used to test timeout watchdogs of the host.
 *
 * receive_wait_fifo shows how many clock cycles receiver shall spent before it allows the host to transmit data
 *
 * Parameters:
 * id - reception id, shown in logs
 * dmat_index - after this count of received data dwords DMAT primitive would be sent to the line 
 * status - returns 0 when the host acknowledges the transaction with OK code, 
 *                  1 when                                       with ERR code
 *          if it's 1, there are 3 options:
 *          a) Generated CRC is invalid
 *          b) Scrambler messed up
 *          c) There is an error in the host
 */
task linkMonitorFIS;
    input integer id;
    input integer dmat_index;
    output integer status;
    reg [112:0] rprim;
    integer pause;
    integer rcv_stop;
    integer rcv_ignore;
    integer cnt;
    reg [31:0] scrambler_value;
    reg [31:0] crc;
    begin
        pause = receive_wait_fifo;
        status = 0;
        rcv_ignore = 0;
        rcv_stop = 0;
        crc = 32'h52325032;// crc seed
        scrambler_value = {16'hf0f6, 16'h0000}; // scrambler seed
        cnt = 0;
    // current rprim = XRDY
        rprim = "XRDY";
        DEV_TITLE = "Detected incoming transmission";
        $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
        DEV_TITLE = "Waiting to empty input buffer";
        DEV_DATA =   pause;
//        $display("[Device] LINK:      Waiting %h cycles to empty input buffer", pause);
        $display("[Device] LINK:      %s, pause = %d @%t", DEV_TITLE, DEV_DATA, $time);
        while (pause > 0) begin
    // L_RcvWaitFifo
            if (~phy_ready) begin
                DEV_TITLE = "Unexpected line disconnect #1";
                $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
                $finish;
            end
            if (rprim != "XRDY") begin
//                $display("[Device] LINK:      Reception terminated by the host, reception id = %d", id);
                DEV_TITLE = "Reception terminated by the host #1";
                DEV_DATA =  id;
                $display("[Device] LINK:      %s, reception id = %d @%t", DEV_TITLE, DEV_DATA, $time);
                $finish;
            end
            @ (posedge clk)
                rprim = linkGetPrim(0);
        end
    // L_RcvChkRdy
        if (~phy_ready) begin
//            $display("[Device] LINK:      Unexpected line disconnect");
            DEV_TITLE = "Unexpected line disconnect #2";
            $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
            $finish;
        end
        if (rprim != "XRDY") begin
//            $display("[Device] LINK:      Reception terminated by the host, reception id = %d", id);
            DEV_TITLE = "Reception terminated by the host #2";
            DEV_DATA =  id;
            $display("[Device] LINK:      %s, reception id = %d @%t", DEV_TITLE, DEV_DATA, $time);
            $finish;
        end
        linkSendPrim("RRDY");
//        $display("[Device] LINK:      Starting the reception");
        DEV_TITLE = "Starting the reception";
        $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
        
        @ (posedge clk)
            rprim = linkGetPrim(0);
        while (rprim != "SOF") begin
            if (~phy_ready) begin
//                $display("[Device] LINK:      Unexpected line disconnect");
                DEV_TITLE = "Unexpected line disconnect #3";
                $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
                $finish;
            end
            if (rprim != "XRDY") begin
//                $display("[Device] LINK:      Reception terminated by the host, reception id = %d", id);
                DEV_TITLE = "Reception terminated by the host #3";
                DEV_DATA =  id;
                $display("[Device] LINK:      %s, reception id = %d @%t", DEV_TITLE, DEV_DATA, $time);
                $finish;
            end
            @ (posedge clk)
                rprim = linkGetPrim(0);
        end
    // L_RcvData
        if (~phy_ready) begin
//            $display("[Device] LINK:      Unexpected line disconnect");
            DEV_TITLE = "Unexpected line disconnect #4";
            $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
            $finish;
        end
//        $display("[Device] LINK:      Detected Start of FIS");
        DEV_TITLE = "Detected Start of FIS";
        $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
        linkSendPrim("IP");
        @ (posedge clk)
            rprim = linkGetPrim(0);
        pause = 0;
        while (rcv_stop == 0) begin
            if (~phy_ready) begin
//                $display("[Device] LINK:      Unexpected line disconnect");
                DEV_TITLE = "Unexpected line disconnect #5";
                $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
                $finish;
            end
            if (rprim == "SYNC") begin
//                $display("[Device] LINK:      Reception terminated by the host, reception id = %d", id);
                DEV_TITLE = "Reception terminated by the host #4";
                DEV_DATA =  id;
                $display("[Device] LINK:      %s, reception id = %d @%t", DEV_TITLE, DEV_DATA, $time);
                $finish;
            end
            if (rprim == "SCRAP") begin
//                $display("[Device] LINK:      Bad primitives from the host, is data = %h, data = %h, reception id = %d", linkIsData(0), linkGetData(0), id);
                DEV_TITLE = "Bad primitives from the host #1";
                DEV_DATA =  id;
                $display("[Device] LINK:      %s, is data = %h, data = %h, reception id = %d @%t", DEV_TITLE, linkIsData(0), linkGetData(0), DEV_DATA, $time);
                $finish;
            end
            if (rprim == "EOF") begin
//                $display("[Device] LINK:      Detected End of FIS");
                DEV_TITLE = "Detected End of FIS";
                $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
                
                rcv_stop = 1;
            end
            else
            if (pause > 0) begin
                pause = pause - 1;
                linkSendPrim("HOLD");
                if (rprim == "HOLDA") begin
//                    $display("[Device] LINK:      The pause is acknowledged by the host, chilling out");
                    DEV_TITLE = "The pause is acknowledged by the host, chilling out";
                    $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
                    rcv_ignore = 1;
                end
                else begin
//                    $display("[Device] LINK:      Asked for a pause");
                    DEV_TITLE = "Asked for a pause";
                    $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
                    rcv_ignore = 0;
                end
            end
            else
            if (rprim == "HOLD") begin
//                $display("[Device] LINK:      the host asked for a pause, acknowledging");
                DEV_TITLE = "the host asked for a pause, acknowledging";
                $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
                linkSendPrim("HOLDA");
                rcv_ignore = 1;
            end
            else begin
                linkSendPrim("IP");
                rcv_ignore = 0;
            end
            if (rprim == "WTRM") begin
//                $display("[Device] LINK:      Host invalidated the reception, reception id = %d", id);
                DEV_TITLE = "Host invalidated the reception";
                DEV_DATA =  id;
                $display("[Device] LINK:      %s, reception id = %d @%t", DEV_TITLE, DEV_DATA, $time);
                rcv_stop = 2;
            end
            if ((rcv_stop == 0) && (rcv_ignore == 0)) begin
                if (cnt > 2048) begin
//                    $display("[Device] LINK:      Wrong data dwords count received, reception id = %d", id);
                    DEV_TITLE = "Wrong data dwords count received";
                    DEV_DATA =  id;
                    $display("[Device] LINK:      %s, reception id = %d @%t", DEV_TITLE, DEV_DATA, $time);
                    $finish;
                end
                if (cnt >= dmat_index) begin
                    linkSendPrim("DMAT");
                end
//                scrambler_value = scrambleFunc(scrambler_value[31:16]);
                scrambler_value = scrambleFunc({16'b0,scrambler_value[31:16]});
                receive_data[cnt] = linkGetData(0) ^ scrambler_value;
//                $display("[Device] LINK:      Got data = %h", receive_data[cnt]);
                DEV_TITLE = "Got data";
                DEV_DATA =  receive_data[cnt];
                $display("[Device] LINK:      %s = %d @%t", DEV_TITLE, DEV_DATA, $time);
                
                pause = pause + receive_data_pause[cnt];
                crc = calculateCRC(crc, receive_data[cnt]); // running crc. shall be 0 
                cnt = cnt + 1;
                if (cnt <= 2048)
                    pause = pause + receive_data_pause[cnt];
            end
            @ (posedge clk)
                rprim = linkGetPrim(0);
        end
        if (cnt < 2) begin
//            $display("[Device] LINK:      Incorrect number of received words");
            DEV_TITLE = "Incorrect number of received words";
            $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
            $finish;
        end
//        $display("[Device] LINK:      Running CRC after all data was received = %h", crc);
        DEV_TITLE = "Running CRC after all data was received";
        DEV_DATA =  crc;
        $display("[Device] LINK:      %s = %h @%t", DEV_TITLE, DEV_DATA, $time);
        
        if (crc != 32'h88c21025) begin // running disparity when data crc matches actual received crc
//            $display("[Device] LINK:      Running CRC check failed");
            DEV_TITLE = "Running CRC check failed";
            $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
            rcv_stop = 2;
        end 
        else begin
//            $display("[Device] LINK:      Running CRC OK");
            DEV_TITLE = "Running CRC OK";
            $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);            
        end
        if (rcv_stop == 1) begin // ordinary path
        // L_RcvEOF
            if (~phy_ready) begin
//                $display("[Device] LINK:      Unexpected line disconnect");
                DEV_TITLE = "Unexpected line disconnect #6";
                $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
                
                $finish;
            end
            if (rprim == "SYNC") begin
//                $display("[Device] LINK:      Reception terminated by the host, reception id = %d", id);
                DEV_TITLE = "Reception terminated by the host #5";
                DEV_DATA =  id;
                $display("[Device] LINK:      %s, reception id = %d @%t", DEV_TITLE, DEV_DATA, $time);
                
                $finish;
            end
            if ((rprim == "SCRAP") || (rprim == "DATA")) begin
//                $display("[Device] LINK:      Bad primitives from the host, is data = %h, data = %h, reception id = %d", linkIsData(0), linkGetData(0), id);
                DEV_TITLE = "Bad primitives from the host #2";
                DEV_DATA =  id;
                $display("[Device] LINK:      %s, is data = %h, data = %h, reception id = %d @%t", DEV_TITLE, linkIsData(0), linkGetData(0), DEV_DATA, $time);
                $finish;
            end
            @ (posedge clk)
                rprim = linkGetPrim(0);
        // L_GoodCRC
            if (~phy_ready) begin
//                $display("[Device] LINK:      Unexpected line disconnect");
                DEV_TITLE = "Unexpected line disconnect #7";
                $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
                $finish;
            end
            if (rprim == "SYNC") begin
//                $display("[Device] LINK:      Reception terminated by the host, reception id = %d", id);
                DEV_TITLE = "Reception terminated by the host #6";
                DEV_DATA =  id;
                $display("[Device] LINK:      %s, reception id = %d @%t", DEV_TITLE, DEV_DATA, $time);
                $finish;
            end
            if ((rprim == "SCRAP") || (rprim == "DATA")) begin
//                $display("[Device] LINK:      Bad primitives from the host, is data = %h, data = %h, reception id = %d", linkIsData(0), linkGetData(0), id);
                DEV_TITLE = "Bad primitives from the host #3";
                DEV_DATA =  id;
                $display("[Device] LINK:      %s, is data = %h, data = %h, reception id = %d @%t", DEV_TITLE, linkIsData(0), linkGetData(0), DEV_DATA, $time);
                $finish;
            end
            if (tranCheckFIS(cnt - 1)) begin
                rcv_stop = 2;
            end
        end
        if (rcv_stop == 2) begin
    // L_BadEnd
            status = 1;
            linkSendPrim("ERR");
//            $display("[Device] LINK:      Found an error");
            DEV_TITLE = "Found an error";
            $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
            
        end
        else begin
    // L_GoodEnd
            status = 0;
            linkSendPrim("OK");
        end
        @ (posedge clk)
            rprim = linkGetPrim(0);
        while (rprim != "SYNC") begin
            if (~phy_ready) begin
//                $display("[Device] LINK:      Unexpected line disconnect");
                DEV_TITLE = "Unexpected line disconnect #8";
                $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
                $finish;
            end
            if ((rprim == "SCRAP") || (rprim == "DATA")) begin
//                $display("[Device] LINK:      Bad primitives from the host, is data = %h, data = %h, reception id = %d", linkIsData(0), linkGetData(0), id);
                DEV_TITLE = "Bad primitives from the host #4";
                DEV_DATA =  id;
                $display("[Device] LINK:      %s, is data = %h, data = %h, reception id = %d @%t", DEV_TITLE, linkIsData(0), linkGetData(0), DEV_DATA, $time);
                $finish;
            end
            @ (posedge clk)
                rprim = linkGetPrim(0);
        end
    // L_IDLE
        linkSendPrim("SYNC");
        if (status == 1) begin
//            $display("[Device] LINK:      Reception done, errors detected, reception id = %d", id);
            DEV_TITLE = "Reception done, errors detected";
            DEV_DATA =  id;
            $display("[Device] LINK:      %s, reception id = %d @%t", DEV_TITLE, DEV_DATA, $time);
            
        end
        else
        if (status == 0) begin
//            $display("[Device] LINK:      Reception done OK, reception id = %d", id);
            DEV_TITLE = "Reception done OK";
            DEV_DATA =  id;
            $display("[Device] LINK:      %s, reception id = %d @%t", DEV_TITLE, DEV_DATA, $time);
        end
    end
endtask



reg [31:0] transmit_data [2047:0];
reg [31:0] transmit_data_pause [2047:0];
reg [31:0] transmit_crc; // never assigned
/*
 * Transmits data to a host. ~Link Transmit FSM
 * Correct execution, as it shall be w/o errors from a device side. (except timeouts and data consistency, see below)
 *
 * Data to transmit is stored in transmit_data memory. 
 * Data is transmitted by dwords // TODO make support for uneven words (16bit each) count
 * 
 * It is possible to send incorrect CRC by setting up an input transmit_custom_crc into 1 and desired crc value to transmit_crc
 *
 * Each data bundle has corresponding "pause" register, stored in a memory 'transmit_data_pause'
 * It represents a time (in clock cycles), for which the device shall "wait" for a new portion of data
 * Could be used to test timeout watchdogs of the host.
 *
 * Parameters:
 * id - transmission id, shown in logs
 * size - how much data to transmit in a FIS
 * transmit_custom_crc - see upper
 * status - returns 0 when the host acknowledges the transaction with OK code, 
 *                  1 when                                       with ERR code
 *          if it's 1, there are 3 options:
 *          a) Generated CRC is invalid
 *          b) Scrambler messed up
 *          c) There is an error in the host
 */
task linkTransmitFIS;
    input integer id;
    input integer size; // dwords count
    input integer transmit_custom_crc;
    output integer status;
    integer pause;
    integer cnt;
    integer crc;
    reg [112:0] rprim;
    reg [31:0] scrambler_value;
    begin
        crc = 32'h52325032;// crc seed
        scrambler_value = {16'hf0f6, 16'h0000}; // scrambler seed
    // tell everyone we need a bus to transmit data
        transmit_lock = 1;
    // DL_SendChkRdy
        linkSendPrim("XRDY");
//        $display("[Device] LINK:      Started outcoming transmission");
        DEV_TITLE = "Started outcoming transmission";
        $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
        
        rprim = linkGetPrim(0);
//        $display("[Device] LINK:      Waiting for acknowledgement");
        DEV_TITLE = "Waiting for acknowledgement";
        $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
        while (rprim != "RRDY") begin
            if (~phy_ready) begin
//                $display("[Device] LINK:      Unexpected line disconnect");
                DEV_TITLE = "Unexpected line disconnect #9";
                $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
                $finish;
            end
            @ (posedge clk)
                rprim = linkGetPrim(0);
        end
    // L_SendSOF
        linkSendPrim("SOF");
//        $display("[Device] LINK:      Sending Start of FIS");
        DEV_TITLE = "Sending Start of FIS";
        $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
        @ (posedge clk)
            rprim = linkGetPrim(0);
        if (~phy_ready) begin
//            $display("[Device] LINK:      Unexpected line disconnect");
            DEV_TITLE = "Unexpected line disconnect #10";
            $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
            $finish;
        end
        if (rprim == "SYNC") begin
//            $display("[Device] LINK:      Transmission terminated by the host, transmission id = %d", id);
            DEV_TITLE = "Transmission terminated by the host #1";
            DEV_DATA =  id;
            $display("[Device] LINK:      %s, transmission id = %d @%t", DEV_TITLE, DEV_DATA, $time);
            $finish;
        end
        if ((rprim == "SCRAP") || (rprim == "DATA")) begin
//            $display("[Device] LINK:      Bad primitives from the host, is data = %h, data = %h, transmission id = %d", linkIsData(0), linkGetData(0), id);
            DEV_TITLE = "Bad primitives from the host #5";
            DEV_DATA =  id;
            $display("[Device] LINK:      %s, is data = %h, data = %h, reception id = %d @%t", DEV_TITLE, linkIsData(0), linkGetData(0), DEV_DATA, $time);
            $finish;
        end
    // L_SendData + L_RcvrHold + L_SendHold
        cnt = 0;
        pause = transmit_data_pause[0];
        while (cnt < size) begin
//            scrambler_value = scrambleFunc(scrambler_value[31:16]);
            scrambler_value = scrambleFunc({16'b0,scrambler_value[31:16]});
//            $display("[Device] LINK:      Scrambler = %h", scrambler_value);
            linkSendData(transmit_data[cnt] ^ scrambler_value);
            crc = calculateCRC(crc, transmit_data[cnt]);
//            $display("[Device] LINK:      Sent data = %h", transmit_data[cnt]);
            DEV_TITLE = "Sent data";
            DEV_DATA =  transmit_data[cnt];
            $display("[Device] LINK:      %s = %h @%t", DEV_TITLE, DEV_DATA, $time);
            @ (posedge clk)
                rprim = linkGetPrim(0);
            if (rprim == "SYNC") begin
//                $display("[Device] LINK:      Transmission terminated by the host, transmission id = %d", id);
                DEV_TITLE = "Transmission terminated by the host #2";
                DEV_DATA =  id;
                $display("[Device] LINK:      %s, transmission id = %d @%t", DEV_TITLE, DEV_DATA, $time);
                $finish;
            end
            if ((rprim == "SCRAP") || (rprim == "DATA")) begin
//                $display("[Device] LINK:      Bad primitives from the host, is data = %h, data = %h, transmission id = %d", linkIsData(0), linkGetData(0), id);
                DEV_TITLE = "Bad primitives from the host #6";
                DEV_DATA =  id;
                $display("[Device] LINK:      %s, is data = %h, data = %h, reception id = %d @%t", DEV_TITLE, linkIsData(0), linkGetData(0), DEV_DATA, $time);
                $finish;
            end
            else
            if (rprim == "DMAT") begin
//                $display("[Device] LINK:      Transmission terminated by the host via DMAT, transmission id = %d", id);
                DEV_TITLE = "Transmission terminated by the hostvia DMAT";
                DEV_DATA =  id;
                $display("[Device] LINK:      %s, transmission id = %d @%t", DEV_TITLE, DEV_DATA, $time);
                $finish;
            end
            else
            if (pause > 0) begin
//                $display("[Device] LINK:      Transmission is paused");
                DEV_TITLE = "Transmission is paused";
                $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
                linkSendPrim("HOLD");
                pause = pause - 1;
            end
            else
            if (rprim == "HOLD") begin
//                $display("[Device] LINK:      The host asked for a pause, acknowledging");
                DEV_TITLE = "The host asked for a pause, acknowledging transmission paused";
                $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
                linkSendPrim("HOLDA");
            end
            else begin 
                cnt = cnt + 1;
                if (cnt < size) 
                    pause = transmit_data_pause[cnt];
            end
        end
    // L_SendCRC
//        scrambler_value = scrambleFunc(scrambler_value[31:16]);
        scrambler_value = scrambleFunc({16'b0,scrambler_value[31:16]});
        if (transmit_custom_crc != 0) begin
            crc = transmit_crc;
        end
            linkSendData(crc ^ scrambler_value);
//        $display("[Device] LINK:      Sent crc = %h", crc);
        DEV_TITLE = "Sent crc";
        DEV_DATA =  crc;
        $display("[Device] LINK:      %s = %h @%t", DEV_TITLE, DEV_DATA, $time);
        
        @ (posedge clk)
            rprim = linkGetPrim(0);
        if (~phy_ready) begin
//            $display("[Device] LINK:      Unexpected line disconnect");
            DEV_TITLE = "Unexpected line disconnect #11";
            $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
            $finish;
        end
        if (rprim == "SYNC") begin
//            $display("[Device] LINK:      Transmission terminated by the host, transmission id = %d", id);
            DEV_TITLE = "Transmission terminated by the host #3";
            DEV_DATA =  id;
            $display("[Device] LINK:      %s, transmission id = %d @%t", DEV_TITLE, DEV_DATA, $time);
            $finish;
        end
        if ((rprim == "SCRAP") || (rprim == "DATA")) begin
//            $display("[Device] LINK:      Bad primitives from the host, is data = %h, data = %h, transmission id = %d", linkIsData(0), linkGetData(0), id);
            DEV_TITLE = "Bad primitives from the host #7";
            DEV_DATA =  id;
            $display("[Device] LINK:      %s, is data = %h, data = %h, reception id = %d @%t", DEV_TITLE, linkIsData(0), linkGetData(0), DEV_DATA, $time);
            $finish;
        end
    // L_SendEOF
        linkSendPrim("EOF");
//        $display("[Device] LINK:      Sent End of FIS");
        DEV_TITLE = "Sent End of FIS";
        $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
        @ (posedge clk)
            rprim = linkGetPrim(0);
        if (~phy_ready) begin
//            $display("[Device] LINK:      Unexpected line disconnect");
            DEV_TITLE = "Unexpected line disconnect #12";
            $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
            $finish;
        end
        if (rprim == "SYNC") begin
//            $display("[Device] LINK:      Transmission terminated by the host, transmission id = %d", id);
            DEV_TITLE = "Transmission terminated by the host #4";
            DEV_DATA =  id;
            $display("[Device] LINK:      %s, transmission id = %d @%t", DEV_TITLE, DEV_DATA, $time);
            $finish;
        end
        if ((rprim == "SCRAP") || (rprim == "DATA")) begin
//            $display("[Device] LINK:      Bad primitives from the host, is data = %h, data = %h, transmission id = %d", linkIsData(0), linkGetData(0), id);
            DEV_TITLE = "Bad primitives from the host #8";
            DEV_DATA =  id;
            $display("[Device] LINK:      %s, is data = %h, data = %h, reception id = %d @%t", DEV_TITLE, linkIsData(0), linkGetData(0), DEV_DATA, $time);
            $finish;
        end
    // L_Wait
        linkSendPrim("WTRM");
//        $display("[Device] LINK:      Waiting for a response from the host");
        DEV_TITLE = "Waiting for a response from the host";
        $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
        @ (posedge clk)
            rprim = linkGetPrim(0);
        status = 0;
        while ((rprim != "OK") && (status == 0)) begin
            if (~phy_ready) begin
                //$display("[Device] LINK:      Unexpected line disconnect");
                DEV_TITLE = "Unexpected line disconnect #13";
                $display("[Device] LINK:      %s @%t", DEV_TITLE, $time);
                $finish;
            end
            if (rprim == "SYNC") begin
//                $display("[Device] LINK:      Transmission terminated by the host, transmission id = %d", id);
                DEV_TITLE = "Transmission terminated by the host #5";
                DEV_DATA =  id;
                $display("[Device] LINK:      %s, transmission id = %d @%t", DEV_TITLE, DEV_DATA, $time);
                $finish;
            end
            if ((rprim == "SCRAP") || (rprim == "DATA")) begin
//                $display("[Device] LINK:      Bad primitives from the host, is data = %h, data = %h, transmission id = %d", linkIsData(0), linkGetData(0), id);
                DEV_TITLE = "Bad primitives from the host #9";
                DEV_DATA =  id;
                $display("[Device] LINK:      %s, is data = %h, data = %h, reception id = %d @%t", DEV_TITLE, linkIsData(0), linkGetData(0), DEV_DATA, $time);
                $finish;
            end
            if (rprim == "ERR") begin
//                $display("[Device] LINK:      Host invalidated the transmission, transmission id = %d", id);
                DEV_TITLE = "Host invalidated the transmission";
                DEV_DATA =  id;
                $display("[Device] LINK:      %s, transmission id = %d @%t", DEV_TITLE, DEV_DATA, $time);
                status = 1;
            end
            @ (posedge clk)
                rprim = linkGetPrim(0);
        end
        if (status == 0)
//            $display("[Device] LINK:      Transmission done OK, id = %d", id);
            DEV_TITLE = "Transmission done OK";
            DEV_DATA =  id;
            $display("[Device] LINK:      %s, id = %d @%t", DEV_TITLE, DEV_DATA, $time);
            
        if (status == 1)
//            $display("[Device] LINK:      Transmission done with ERRORs, id = %d", id);
            DEV_TITLE = "Transmission done with ERRORS";
            DEV_DATA =  id;
            $display("[Device] LINK:      %s, id = %d @%t", DEV_TITLE, DEV_DATA, $time);
    // L_IDLE
        linkSendPrim("SYNC");
        @ (posedge clk);
    end
endtask

// checks, if it is data coming from the host
function [0:0] linkIsData;
    input dummy;
    begin
        if (|phy2dev_charisk) 
            linkIsData = 1;
        else
            linkIsData = 0;
    end
endfunction

// obvious
function [31:0] linkGetData;
// TODO non-even word count
    input dummy;
    begin
        linkGetData = phy2dev_data;
    end
endfunction
/*
 * Returns current primitive at the outputs of phy level
 * Return value is a string containing its name!
 */
function [112:0] linkGetPrim;
    input integer dummy;
    reg [112:0] type;
    begin
        if (~|phy2dev_charisk) begin
            type = "DATA";
        end
        else
        if (phy2dev_charisk == 4'h1) begin
            case (phy2dev_data)
                PRIM_SYNCP: 
                    type    = "SYNC";
                PRIM_ALIGNP:
                    type    = "ALIGN";
                PRIM_XRDYP:
                    type    = "XRDY";
                PRIM_SOFP:
                    type    = "SOF";
                PRIM_HOLDAP:
                    type    = "HOLDA";
                PRIM_HOLDP:
                    type    = "HOLD";
                PRIM_EOFP:
                    type    = "EOF";
                PRIM_WTRMP:
                    type    = "WTRM";
                PRIM_RRDYP:
                    type    = "RRDY";
                PRIM_IPP:
                    type    = "IP";
                PRIM_DMATP:
                    type    = "DMAT";
                PRIM_OKP:
                    type    = "OK";
                PRIM_ERRP:
                    type    = "ERR";
                default:
                    type    = "SCRAP";
            endcase
        end
        else begin
            type = "SCRAP";
        end
        linkGetPrim = type;
    end
endfunction

/*
 * Sets some data to phy inputs
 * input is a data dword
 */
task linkSendData;
    input [31:0] data;
    begin
        dev2phy_data    <= data;
        dev2phy_isk     <= 4'h0;
    end
endtask

/*
 * Set a desired primitive to phy inputs
 * input is a string containing its name!
 */
task linkSendPrim;
    input [112:0] type;
    begin
        case (type)
            "SYNC": 
            begin
                dev2phy_data    <= PRIM_SYNCP;
                dev2phy_isk     <= 4'h1;
            end
            "ALIGN":
            begin
                dev2phy_data    <= PRIM_ALIGNP;
                dev2phy_isk     <= 4'h1;
            end
            "XRDY":
            begin
                dev2phy_data    <= PRIM_XRDYP;
                dev2phy_isk     <= 4'h1;
            end
            "SOF":
            begin
                dev2phy_data    <= PRIM_SOFP;
                dev2phy_isk     <= 4'h1;
            end
            "HOLDA":
            begin
                dev2phy_data    <= PRIM_HOLDAP;
                dev2phy_isk     <= 4'h1;
            end
            "HOLD":
            begin
                dev2phy_data    <= PRIM_HOLDP;
                dev2phy_isk     <= 4'h1;
            end
            "EOF":
            begin
                dev2phy_data    <= PRIM_EOFP;
                dev2phy_isk     <= 4'h1;
            end
            "WTRM":
            begin
                dev2phy_data    <= PRIM_WTRMP;
                dev2phy_isk     <= 4'h1;
            end
            "RRDY":
            begin
                dev2phy_data    <= PRIM_RRDYP;
                dev2phy_isk     <= 4'h1;
            end
            "IP":
            begin
                dev2phy_data    <= PRIM_IPP;
                dev2phy_isk     <= 4'h1;
            end
            "DMAT":
            begin
                dev2phy_data    <= PRIM_DMATP;
                dev2phy_isk     <= 4'h1;
            end
            "OK":
            begin
                dev2phy_data    <= PRIM_OKP;
                dev2phy_isk     <= 4'h1;
            end
            "ERR":
            begin
                dev2phy_data    <= PRIM_ERRP;
                dev2phy_isk     <= 4'h1;
            end
            default:
            begin
                dev2phy_data    <= PRIM_SYNCP;
                dev2phy_isk     <= 4'h1;
            end
        endcase
    end
endtask

endmodule
