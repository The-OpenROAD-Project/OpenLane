module ibex_register_file_fpga (
	clk_i,
	rst_ni,
	test_en_i,
	dummy_instr_id_i,
	raddr_a_i,
	rdata_a_o,
	raddr_b_i,
	rdata_b_o,
	waddr_a_i,
	wdata_a_i,
	we_a_i
);
	parameter [0:0] RV32E = 0;
	parameter [31:0] DataWidth = 32;
	parameter [0:0] DummyInstructions = 0;
	input wire clk_i;
	input wire rst_ni;
	input wire test_en_i;
	input wire dummy_instr_id_i;
	input wire [4:0] raddr_a_i;
	output wire [DataWidth - 1:0] rdata_a_o;
	input wire [4:0] raddr_b_i;
	output wire [DataWidth - 1:0] rdata_b_o;
	input wire [4:0] waddr_a_i;
	input wire [DataWidth - 1:0] wdata_a_i;
	input wire we_a_i;
	localparam signed [31:0] ADDR_WIDTH = (RV32E ? 4 : 5);
	localparam signed [31:0] NUM_WORDS = 2 ** ADDR_WIDTH;
	reg [DataWidth - 1:0] mem [0:NUM_WORDS - 1];
	wire we;
	assign rdata_a_o = (raddr_a_i == {5 {1'sb0}} ? {DataWidth {1'sb0}} : mem[raddr_a_i]);
	assign rdata_b_o = (raddr_b_i == {5 {1'sb0}} ? {DataWidth {1'sb0}} : mem[raddr_b_i]);
	assign we = (waddr_a_i == {5 {1'sb0}} ? 1'b0 : we_a_i);
	always @(posedge clk_i) begin : sync_write
		if (we == 1'b1)
			mem[waddr_a_i] <= wdata_a_i;
	end
	wire unused_rst_ni;
	assign unused_rst_ni = rst_ni;
	wire unused_dummy_instr;
	assign unused_dummy_instr = dummy_instr_id_i;
	wire unused_test_en;
	assign unused_test_en = test_en_i;
endmodule
