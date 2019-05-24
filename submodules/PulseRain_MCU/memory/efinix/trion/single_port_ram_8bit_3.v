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

`default_nettype none

module single_port_ram_8bit_3 #(parameter ADDR_WIDTH = 14, BYTE_INDEX = 0) (
            input  wire [ADDR_WIDTH - 1 : 0]         addr,
            input  wire [7 : 0]                      din,
            input  wire                              write_en, 
            input  wire                              clk,
            output wire [7 : 0]         dout
);
    
            reg [ADDR_WIDTH - 1 : 0] addr_reg;
            reg [7:0]   mem [(2**ADDR_WIDTH) - 1 : 0] ;

            assign dout = mem[addr_reg];

            always@(posedge clk) begin
                addr_reg <= addr;   
                
                if(write_en) begin
                    mem[addr] <= din;
                end
            end
            
            initial	begin
                $readmemh("m3.mif", mem);
                
                
            end
endmodule 

`default_nettype wire
