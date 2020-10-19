// UC Berkeley CS250
// Authors: Ryan Thornton (rpthornton@berkeley.edu)
//          Arya Reais-Parsi (aryap@berkeley.edu)
//
// Based on the description in: Wenyi Feng, Jonathan Greene, and Alan
// Mishchenko. 2018. Improving FPGA Performance with a S44 LUT Structure. In
// Proceedings of the 2018 ACM/SIGDA International Symposium on
// Field-Programmable Gate Arrays (FPGA '18).  Association for Computing
// Machinery, New York, NY, USA, 61–66.
// DOI:https://doi.org/10.1145/3174243.3174272

///////// HARD S44 LUT /////////

module lut_s44 #(
    parameter CONFIG_WIDTH=8
) (
    input [6:0] addr,
    output out,

    // Stream Style Configuration
    input config_clk,
    input config_en,
    input [CONFIG_WIDTH-1:0] config_in,
    output [CONFIG_WIDTH-1:0] config_out
);

wire intermediate;
wire [CONFIG_WIDTH-1:0] config_in2;

lut #(.INPUTS(4)) first_lut (
    .addr(addr[6:3]),
    .out(intermediate),
    .config_clk(config_clk),
    .config_en(config_en),
    .config_in(config_in),
    .config_out(config_in2)
);

lut #(.INPUTS(4)) second_lut (
    .addr({intermediate, addr[2:0]}),
    .out(out),
    .config_clk(config_clk),
    .config_en(config_en),
    .config_in(config_in2),
    .config_out(config_out)
);
endmodule

