

module test_sram_macro_unwrapped(
    input rst_n,
    input clk,
    input cs,
    input we,
    input [7:0] addr,
    input [7:0] write_allow,
    input [63:0] datain,
    output [63:0] dataout
);

reg [63:0] dataout_stored;
reg cs_int;

wire [63:0] dataout_int;

always @(posedge clk) begin
    if(!rst_n) begin
        cs_int <= 1;
        dataout_stored <= 0;
    end else begin
        if(cs)
            dataout_stored <= dataout_int;
        cs_int <= cs;
    end
end

assign dataout = cs_int ? dataout_int : dataout_stored;


wire [63:0] dout1;

sky130_sram_1kbyte_1rw1r_32x256_8 sram0(
    .clk0(clk),
    .csb0(!cs),
    .web0(!we),
    .wmask0(write_allow[3:0]),
    .addr0(addr),
    .din0(datain[31:0]),
    .dout0(dataout_int[31:0]),

    .clk1(0),
    .csb1(1),
    .addr1(0),
    .dout1(dout1[31:0])
);

sky130_sram_1kbyte_1rw1r_32x256_8 sram1(
    .clk0(clk),
    .csb0(!cs),
    .web0(!we),
    .wmask0(write_allow[7:4]),
    .addr0(addr),
    .din0(datain[63:32]),
    .dout0(dataout_int[63:32]),

    .clk1(0),
    .csb1(1),
    .addr1(0),
    .dout1(dout1[63:32])
);


endmodule


module test_sram_macro(
    input rst_n,
    input clk,
    input cs,
    input we,
    input [7:0] addr,
    input [7:0] write_allow,
    input [63:0] datain,
    output [63:0] dataout
);

test_sram_macro_unwrapped submodule (.*);

endmodule