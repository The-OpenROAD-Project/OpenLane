// UC Berkeley CS250
// Authors: Ryan Thornton (rpthornton@berkeley.edu)
//          Arya Reais-Parsi (aryap@berkeley.edu)


///////// BASIC LUT /////////
// Assumptions:
//  MEM_SIZE is a multiple of CONFIG_WIDTH 

module lut #(
    parameter INPUTS=4, MEM_SIZE=1<<INPUTS, CONFIG_WIDTH=8
) (
    // IO
    input [INPUTS-1:0] addr, 
    output out,

    // Stream Style Configuration
    input config_clk,
    input config_en,
    input [CONFIG_WIDTH-1:0] config_in,
    output [CONFIG_WIDTH-1:0] config_out
);
reg [MEM_SIZE-1:0] mem = 0;
assign out = mem[addr];

// Stream Style Configuration Logic
generate 
    genvar i;
    for (i=1; i<(MEM_SIZE/CONFIG_WIDTH); i=i+1) begin
        always @(posedge config_clk) begin
            if (config_en)
                mem[(i+1)*CONFIG_WIDTH-1:i*CONFIG_WIDTH] <= mem[(i)*CONFIG_WIDTH-1:(i-1)*CONFIG_WIDTH];
        end
    end
    always @(posedge config_clk) begin
        if (config_en) begin
            mem[CONFIG_WIDTH-1:0] <= config_in;
        end
    end
    assign config_out = mem[MEM_SIZE-1:MEM_SIZE-CONFIG_WIDTH];
endgenerate
endmodule

