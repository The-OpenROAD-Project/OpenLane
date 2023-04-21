`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer:  Peter Herrmann
// 
// Create Date: 10/06/2022 12:17:57 AM
// Module Name: reg_file
// Description: A 32 x 32-bit register file. Writes are syncronous and negedge 
//              sensitive, but reads are asyncronous from 2 ports. x0 is 
//              read-only and always returns 0.
//
//     reg_file REG_FILE (.clk_i        (),
//                        .read1_i      (),
//                        .read2_i      (),
//                        .wr_reg_i     (),
//                        .wr_data_i    (),
//                        .wr_en_i      (),
//                        .data1_ao     (),
//                        .data2_a0     () );
// Revision:
// Revision 0.01 - File Created 
// 
//////////////////////////////////////////////////////////////////////////////////


module register_file(
    input               clk_i,     // System clock (negedge sensitive!)
    input               rst_ni,    // Resets all values to reset value
    input         [4:0] read1_i,   // Register 1 Number (read)
    input         [4:0] read2_i,   // Register 2 Number (read)
    input         [4:0] wr_reg_i,  // Destination Register Number (write)
    input        [31:0] wr_data_i, // Data to write
    input               wr_en_i,   // Write control
    output logic [31:0] data1_ao,  // Read 1 data output
    output logic [31:0] data2_a0   // Read 2 data output
    );
    
    // Register File Declaration
    
    logic [31:0] RF [31:0]; 
    
    // Read control. Returns 0 if reading from x0.
    
    always_comb begin
        if(read1_i == 0)  data1_ao = 0;
        else              data1_ao = RF[read1_i];
    end
    always_comb begin
        if(read2_i ==0 )  data2_a0 = 0;
        else              data2_a0 = RF[read2_i];
    end
    
    // Write control (ON NEGEDGE). Will not write to x0.
    
    always_ff @ (negedge clk_i) begin
        int i;
        if (~rst_ni) begin
            for (i = 0; i < 32; i++)
                RF[i] <= 'hDEAD_BEEF;
        end else  begin
            if(wr_en_i && wr_reg_i != 0) 
                RF[wr_reg_i] <= wr_data_i;
        end
    end

 endmodule
