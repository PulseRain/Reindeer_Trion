/*
###############################################################################
# Copyright (c) 2019, PulseRain Technology LLC 
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
###############################################################################
*/


//=============================================================================
// Top Level for Efinix Trion T20 BGA256 Development Kit
//=============================================================================

`default_nettype none

`include "common.vh"
`include "debug_coprocessor.vh"
`include "config.vh"

module Reindeer_Trion_T20_Dev_Kit (

    //-------------------------------------------------------------------------
    // PLL interface
    //-------------------------------------------------------------------------    
        input   wire                pll_clk,
        input   wire                pll_locked,
        output  wire                pll_reset_n,

    //-------------------------------------------------------------------------
    //  button  
    //-------------------------------------------------------------------------        
        input   wire                rst_button,
        
    //-------------------------------------------------------------------------
    //  LED  
    //-------------------------------------------------------------------------
        output  wire [7 : 0]        led,
        
        
    //-------------------------------------------------------------------------
    //  UART  
    //-------------------------------------------------------------------------
        input   wire                RXD,
        output  reg                 TXD

);

    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //  signals
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

        wire                                        clk;
        wire                                        reset_n;
        
        wire                                        uart_tx_ocd;
        wire                                        uart_tx_cpu;
        
        reg     [1 : 0]                             init_start = 0;
        reg                                         actual_cpu_start;
        reg     [`XLEN - 1 : 0]                     actual_start_addr;

        wire                                        cpu_reset;
        wire                                        cpu_start;
        wire    [`XLEN - 1 : 0]                     cpu_start_addr;
        
        wire                                        ocd_read_enable;
        wire                                        ocd_write_enable;
        
        wire                                        ocd_mem_enable_out;
        wire    [`XLEN - 1 : 0]                     ocd_mem_word_out; 
        
        wire    [`MEM_ADDR_BITS - 1 : 0]            ocd_rw_addr;
        wire    [`XLEN - 1 : 0]                     ocd_write_word;
        
        wire    [`DEBUG_PRAM_ADDR_WIDTH - 3 : 0]    pram_read_addr;
        wire    [`DEBUG_PRAM_ADDR_WIDTH - 3 : 0]    pram_write_addr;
        
        wire    [`NUM_OF_GPIOS - 1 : 0]             gpio_out;
        
        wire                                        processor_paused;
        
        wire                                        debug_uart_tx_sel_ocd1_cpu0;
        
        reg    [2 : 0]                              rxd_sr;
    
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //  port connections
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        assign reset_n = pll_locked;
        assign clk     = pll_clk;
        
        assign pll_reset_n = rst_button;
        

    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // MCU
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
        always @(posedge clk, negedge reset_n) begin
            if (!reset_n) begin
                init_start <= 0;
                actual_cpu_start <= 0;
                actual_start_addr <= 0;
            end else begin
                init_start <= {init_start [0 : 0], 1'b1};
                actual_cpu_start <= cpu_start | ((~init_start [1]) & init_start [0]);
                if (cpu_start) begin
                    actual_start_addr <= cpu_start_addr;
                end else if (!init_start [1]) begin
                    actual_start_addr <= `DEFAULT_START_ADDR;
                end
            end
        end
     
        PulseRain_Reindeer_MCU #(.sim (0)) PulseRain_Reindeer_MCU_i (
            .clk (clk),
            .reset_n ((~cpu_reset) & reset_n),
            .sync_reset (1'b0),

            .ocd_read_enable (ocd_read_enable),
            .ocd_write_enable (ocd_write_enable),
            
            .ocd_rw_addr (ocd_rw_addr),
            .ocd_write_word (ocd_write_word),
            
            .ocd_mem_enable_out (ocd_mem_enable_out),
            .ocd_mem_word_out (ocd_mem_word_out),        
        
            .ocd_reg_read_addr (5'd2),
            .ocd_reg_we (cpu_start),
            .ocd_reg_write_addr (5'd2),
            .ocd_reg_write_data (`DEFAULT_STACK_ADDR),
        
            .RXD (RXD),
            .TXD (uart_tx_cpu),
            
            .GPIO_OUT(gpio_out),
    
            .start (actual_cpu_start),
            .start_address (actual_start_addr),
        
            .processor_paused (processor_paused));

        assign led = gpio_out [31 : 24];
        
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // Hardware Loader
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
        debug_coprocessor_wrapper #(.BAUD_PERIOD (`MCU_MAIN_CLK_RATE / 921600)) hw_loader_i (
                    .clk (clk),
                    .reset_n (reset_n),
                    
                    .RXD (RXD),
                    .TXD (uart_tx_ocd),
                        
                    .pram_read_enable_in (ocd_mem_enable_out),
                    .pram_read_data_in (ocd_mem_word_out),
                    
                    .pram_read_enable_out (ocd_read_enable),
                    .pram_read_addr_out (pram_read_addr),
                    
                    .pram_write_enable_out (ocd_write_enable),
                    .pram_write_addr_out (pram_write_addr),
                    .pram_write_data_out (ocd_write_word),
                    
                    .cpu_reset (cpu_reset),
                    
                    .cpu_start (cpu_start),
                    .cpu_start_addr (cpu_start_addr),        
                    
                    .debug_uart_tx_sel_ocd1_cpu0 (debug_uart_tx_sel_ocd1_cpu0));
                
        assign ocd_rw_addr = ocd_read_enable ? pram_read_addr [`MEM_ADDR_BITS - 1 : 0] : pram_write_addr [`MEM_ADDR_BITS - 1 : 0];        

    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // TXD switch between CPU and OCD (HW Loader) 
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      
        always @(posedge clk, negedge reset_n) begin : uart_proc
            if (!reset_n) begin
                TXD <= 0;
            end else if (!debug_uart_tx_sel_ocd1_cpu0) begin
                TXD <= uart_tx_cpu;
            end else begin
                TXD <= uart_tx_ocd;
            end
        end 

endmodule

`default_nettype wire
