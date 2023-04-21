`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  J. Callenes
// 
// Create Date: 01/05/2019 12:17:57 AM
// Design Name: 
// Module Name: registerFile
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module reg_file (
    input clk_i,

    // Signals for Port 1
    input [4:0]         port1_reg_i,
    output logic [31:0] port1_data_o,
    
    // Signals for Port 2
    input  [4:0]        port2_reg_i,
    output logic [31:0] port2_data_o,
    
    // Signals for Write Port
    input        wr_en_i,
    input [4:0]  wr_reg_i,
    input [31:0] wr_data_i
); 

    logic [31:0] rf [32]; 
    localparam logic [4:0] X0 = '0;

    // Port 1 Logic
    always_comb begin
        if (port1_reg_i == X0) port1_data_o = '0;
        else port1_data_o = rf[port1_reg_i];
    end
    
    // Port 2 Logic
    always_comb begin
        if (port2_reg_i == X0) port2_data_o = '0;
        else port2_data_o = rf[port2_reg_i];
    end

    // Write Port Logic
    always_ff @(negedge clk_i) begin
        if (wr_en_i && (wr_reg_i != X0)) rf[wr_reg_i] <= wr_data_i;
    end
    
 endmodule
