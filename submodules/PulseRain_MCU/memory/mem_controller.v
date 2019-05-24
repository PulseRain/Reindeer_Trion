/*
###############################################################################
# Copyright (c) 2019, PulseRain Technology LLC 
#
# This program is distributed under a dual license: an open source license, 
# and a commercial license. 
# 
# The open source license under which this program is distributed is the 
# GNU Public License version 3 (GPLv3).
#
# And for those who want to use this program in ways that are incompatible
# with the GPLv3, PulseRain Technology LLC offers commercial license instead.
# Please contact PulseRain Technology LLC (www.pulserain.com) for more detail.
#
###############################################################################
*/

`include "common.vh"
`include "config.vh"

`default_nettype none


module mem_controller #(parameter sim = 0) (

    //=======================================================================
    // clock / reset
    //=======================================================================

        input   wire                                                    clk,
        input   wire                                                    reset_n,
        input   wire                                                    sync_reset,

    //=======================================================================
    // memory interface
    //=======================================================================
        input  wire  [`MEM_ADDR_BITS - 1 : 0]                           mem_addr,
        input  wire  [`XLEN_BYTES - 1 : 0]                              mem_write_en,
        input  wire  [`XLEN - 1 : 0]                                    mem_write_data,
        input  wire                                                     mem_read_en,
        output wire  [`XLEN - 1 : 0]                                    mem_read_data,
        output reg                                                      mem_read_ack
        
);
    //=======================================================================
    // signal
    //=======================================================================
        wire                                              mem_sram0_dram1; 
        wire [15 : 0]                                     dout_high;
        wire [15 : 0]                                     dout_low;
        
        reg [15 : 0]                                      dout_high_d1;
        reg [15 : 0]                                      dout_low_d1;
        
        reg [15 : 0]                                      dout_high_d2;
        reg [15 : 0]                                      dout_low_d2;
        
        reg                                               mem_sram0_dram1_d1;
        reg                                               mem_read_en_d1;
        
        wire                                              sram_read_ack_pre;
        reg                                               sram_read_ack_pre_pre;
        reg                                               sram_read_ack;
        
        reg                                               sram_write_ack_pre;
        
        reg                                               sram_write_ack;
                
        wire                                              dram_ack;
        wire  [`XLEN - 1 : 0]                             dram_mem_read_data;
        
        reg   [`MEM_ADDR_BITS - 1 : 0]                    mem_read_addr_reg;
        
        
                
    //=======================================================================
    // SRAM
    //=======================================================================
        
        generate
            if (sim == 0) begin
               /* single_port_ram #(.ADDR_WIDTH (`SRAM_ADDR_BITS), .DATA_WIDTH (16) ) ram_high_i (
                    .addr (mem_addr [`SRAM_ADDR_BITS - 1 : 0]),
                    .din (mem_write_data [31 : 16]),
                    .write_en (mem_write_en[3 : 2]),
                    .clk (clk),
                    .dout (dout_high));

                single_port_ram #(.ADDR_WIDTH (`SRAM_ADDR_BITS), .DATA_WIDTH (16) ) ram_low_i (
                    .addr (mem_addr[`SRAM_ADDR_BITS - 1 : 0]),
                    .din (mem_write_data [15 : 0]),
                    .write_en (mem_write_en[1 : 0]),
                    .clk (clk),
                    .dout (dout_low));
                 */   
                    
                 single_port_ram_8bit_0 #(.ADDR_WIDTH (`SRAM_ADDR_BITS)) ram_8bit0 (
                    .addr (mem_addr[`SRAM_ADDR_BITS - 1 : 0]),
                    .din (mem_write_data [7 : 0]),
                    .write_en (mem_write_en[0]),
                    .clk (clk),
                    .dout (dout_low [7 : 0]));
                    
                 single_port_ram_8bit_1 #(.ADDR_WIDTH (`SRAM_ADDR_BITS)) ram_8bit1 (
                    .addr (mem_addr[`SRAM_ADDR_BITS - 1 : 0]),
                    .din (mem_write_data [15 : 8]),
                    .write_en (mem_write_en[1]),
                    .clk (clk),
                    .dout (dout_low [15 : 8]));
                    
                 single_port_ram_8bit_2 #(.ADDR_WIDTH (`SRAM_ADDR_BITS)) ram_8bit2 (
                    .addr (mem_addr[`SRAM_ADDR_BITS - 1 : 0]),
                    .din (mem_write_data [23 : 16]),
                    .write_en (mem_write_en[2]),
                    .clk (clk),
                    .dout (dout_high [7 : 0]));
                    
                 single_port_ram_8bit_3 #(.ADDR_WIDTH (`SRAM_ADDR_BITS)) ram_8bit3 (
                    .addr (mem_addr[`SRAM_ADDR_BITS - 1 : 0]),
                    .din (mem_write_data [31 : 24]),
                    .write_en (mem_write_en[3]),
                    .clk (clk),
                    .dout (dout_high [15 : 8]));
                    
            end else begin
            
                
            
            
            

                single_port_ram_sim_high #(.ADDR_WIDTH (`SRAM_ADDR_BITS), .DATA_WIDTH (16) ) ram_high_i (
                    .addr (mem_addr[`SRAM_ADDR_BITS - 1 : 0]),
                    .din (mem_write_data [31 : 16]),
                    .write_en (mem_write_en[3 : 2]),
                    .clk (clk),
                    .dout (dout_high));
                  
                single_port_ram_sim_low #(.ADDR_WIDTH (`SRAM_ADDR_BITS), .DATA_WIDTH (16) ) ram_low_i (
                    .addr (mem_addr[`SRAM_ADDR_BITS - 1 : 0]),
                    .din (mem_write_data [15 : 0]),
                    .write_en (mem_write_en[1 : 0]),
                    .clk (clk),
                    .dout (dout_low));

            end
            
        endgenerate

        assign mem_read_data =  {dout_high, dout_low};
        
        always @(posedge clk, negedge reset_n) begin
            if (!reset_n) begin
                mem_read_ack <= 0;
            end else begin
                mem_read_ack <= mem_read_en;
            end
        
        end
        
          
endmodule

`default_nettype wire
