//-------------------------------------------
//	FPGA Synthesizable Verilog Netlist
//	Description: FPGA Verilog Testbench for Formal Top-level netlist of Design: K4N4_test_modes
//	Author: Xifan TANG
//	Organization: University of Utah
//	Date: Tue Feb 25 16:44:01 2020
//-------------------------------------------
//----- Time scale -----
`timescale 1ns / 1ps

`include "../src/fpga_defines.v"
`include "./define_simulation.v"
module K4N4_test_modes_top_formal_verification_random_tb;
// ----- Default clock port is added here since benchmark does not contain one -------
	reg [0:0] clk;

// ----- Shared inputs -------
	reg [0:0] a;
	reg [0:0] b;
	reg [0:0] c;

// ----- FPGA fabric outputs -------
	wire [0:0] out_XOR_gfpga;
	wire [0:0] out_XNOR_gfpga;
	wire [0:0] out_AND_gfpga;
	wire [0:0] out_NAND_gfpga;
	wire [0:0] out_OR_gfpga;
	wire [0:0] out_NOR_gfpga;
	wire [0:0] out_XOR_sync_gfpga;
	wire [0:0] out_XNOR_sync_gfpga;
	wire [0:0] out_AND_sync_gfpga;
	wire [0:0] out_NAND_sync_gfpga;
	wire [0:0] out_OR_sync_gfpga;
	wire [0:0] out_NOR_sync_gfpga;

`ifdef AUTOCHECKED_SIMULATION

// ----- Benchmark outputs -------
	wire [0:0] out_XOR_bench;
	wire [0:0] out_XNOR_bench;
	wire [0:0] out_AND_bench;
	wire [0:0] out_NAND_bench;
	wire [0:0] out_OR_bench;
	wire [0:0] out_NOR_bench;
	wire [0:0] out_XOR_sync_bench;
	wire [0:0] out_XNOR_sync_bench;
	wire [0:0] out_AND_sync_bench;
	wire [0:0] out_NAND_sync_bench;
	wire [0:0] out_OR_sync_bench;
	wire [0:0] out_NOR_sync_bench;

// ----- Output vectors checking flags -------
	reg [0:0] out_XOR_flag;
	reg [0:0] out_XNOR_flag;
	reg [0:0] out_AND_flag;
	reg [0:0] out_NAND_flag;
	reg [0:0] out_OR_flag;
	reg [0:0] out_NOR_flag;
	reg [0:0] out_XOR_sync_flag;
	reg [0:0] out_XNOR_sync_flag;
	reg [0:0] out_AND_sync_flag;
	reg [0:0] out_NAND_sync_flag;
	reg [0:0] out_OR_sync_flag;
	reg [0:0] out_NOR_sync_flag;

`endif

// ----- Error counter -------
	integer nb_error= 0;

// ----- FPGA fabric instanciation -------
	K4N4_test_modes_top_formal_verification FPGA_DUT(
		.clk_fm(clk),
		.a_fm(a),
		.b_fm(b),
		.c_fm(c),
		.out_XOR_fm(out_XOR_gfpga),
		.out_XNOR_fm(out_XNOR_gfpga),
		.out_AND_fm(out_AND_gfpga),
		.out_NAND_fm(out_NAND_gfpga),
		.out_OR_fm(out_OR_gfpga),
		.out_NOR_fm(out_NOR_gfpga),
		.out_XOR_sync_fm(out_XOR_sync_gfpga),
		.out_XNOR_sync_fm(out_XNOR_sync_gfpga),
		.out_AND_sync_fm(out_AND_sync_gfpga),
		.out_NAND_sync_fm(out_NAND_sync_gfpga),
		.out_OR_sync_fm(out_OR_sync_gfpga),
		.out_NOR_sync_fm(out_NOR_sync_gfpga)	);
// ----- End FPGA Fabric Instanication -------

`ifdef AUTOCHECKED_SIMULATION
// ----- Reference Benchmark Instanication -------
	K4N4_test_modes REF_DUT(
		clk,
		a,
		b,
		c,
		out_XOR_bench,
		out_XNOR_bench,
		out_AND_bench,
		out_NAND_bench,
		out_OR_bench,
		out_NOR_bench,
		out_XOR_sync_bench,
		out_XNOR_sync_bench,
		out_AND_sync_bench,
		out_NAND_sync_bench,
		out_OR_sync_bench,
		out_NOR_sync_bench	);
// ----- End reference Benchmark Instanication -------

`endif

// ----- Clock Initialization -------
	initial begin
		clk[0] <= 1'b0;
		while(1) begin
			#10.00000028
			clk[0] <= !clk[0];
		end
	end

// ----- Input Initialization -------
	initial begin
		a <= 1'b0;
		b <= 1'b0;
		c <= 1'b0;

		out_XOR_flag[0] <= 1'b0;
		out_XNOR_flag[0] <= 1'b0;
		out_AND_flag[0] <= 1'b0;
		out_NAND_flag[0] <= 1'b0;
		out_OR_flag[0] <= 1'b0;
		out_NOR_flag[0] <= 1'b0;
		out_XOR_sync_flag[0] <= 1'b0;
		out_XNOR_sync_flag[0] <= 1'b0;
		out_AND_sync_flag[0] <= 1'b0;
		out_NAND_sync_flag[0] <= 1'b0;
		out_OR_sync_flag[0] <= 1'b0;
		out_NOR_sync_flag[0] <= 1'b0;
	end

// ----- Input Stimulus -------
	always@(negedge clk[0]) begin
		a <= $random;
		b <= $random;
		c <= $random;
	end

`ifdef AUTOCHECKED_SIMULATION
// ----- Begin checking output vectors -------
// ----- Skip the first falling edge of clock, it is for initialization -------
	reg [0:0] sim_start;

	always@(negedge clk[0]) begin
		if (1'b1 == sim_start[0]) begin
			sim_start[0] <= ~sim_start[0];
		end else begin
			if(!(out_XOR_gfpga === out_XOR_bench) && !(out_XOR_bench === 1'bx)) begin
				out_XOR_flag <= 1'b1;
			end else begin
				out_XOR_flag<= 1'b0;
			end
			if(!(out_XNOR_gfpga === out_XNOR_bench) && !(out_XNOR_bench === 1'bx)) begin
				out_XNOR_flag <= 1'b1;
			end else begin
				out_XNOR_flag<= 1'b0;
			end
			if(!(out_AND_gfpga === out_AND_bench) && !(out_AND_bench === 1'bx)) begin
				out_AND_flag <= 1'b1;
			end else begin
				out_AND_flag<= 1'b0;
			end
			if(!(out_NAND_gfpga === out_NAND_bench) && !(out_NAND_bench === 1'bx)) begin
				out_NAND_flag <= 1'b1;
			end else begin
				out_NAND_flag<= 1'b0;
			end
			if(!(out_OR_gfpga === out_OR_bench) && !(out_OR_bench === 1'bx)) begin
				out_OR_flag <= 1'b1;
			end else begin
				out_OR_flag<= 1'b0;
			end
			if(!(out_NOR_gfpga === out_NOR_bench) && !(out_NOR_bench === 1'bx)) begin
				out_NOR_flag <= 1'b1;
			end else begin
				out_NOR_flag<= 1'b0;
			end
			if(!(out_XOR_sync_gfpga === out_XOR_sync_bench) && !(out_XOR_sync_bench === 1'bx)) begin
				out_XOR_sync_flag <= 1'b1;
			end else begin
				out_XOR_sync_flag<= 1'b0;
			end
			if(!(out_XNOR_sync_gfpga === out_XNOR_sync_bench) && !(out_XNOR_sync_bench === 1'bx)) begin
				out_XNOR_sync_flag <= 1'b1;
			end else begin
				out_XNOR_sync_flag<= 1'b0;
			end
			if(!(out_AND_sync_gfpga === out_AND_sync_bench) && !(out_AND_sync_bench === 1'bx)) begin
				out_AND_sync_flag <= 1'b1;
			end else begin
				out_AND_sync_flag<= 1'b0;
			end
			if(!(out_NAND_sync_gfpga === out_NAND_sync_bench) && !(out_NAND_sync_bench === 1'bx)) begin
				out_NAND_sync_flag <= 1'b1;
			end else begin
				out_NAND_sync_flag<= 1'b0;
			end
			if(!(out_OR_sync_gfpga === out_OR_sync_bench) && !(out_OR_sync_bench === 1'bx)) begin
				out_OR_sync_flag <= 1'b1;
			end else begin
				out_OR_sync_flag<= 1'b0;
			end
			if(!(out_NOR_sync_gfpga === out_NOR_sync_bench) && !(out_NOR_sync_bench === 1'bx)) begin
				out_NOR_sync_flag <= 1'b1;
			end else begin
				out_NOR_sync_flag<= 1'b0;
			end
		end
	end

	always@(posedge out_XOR_flag) begin
		if(out_XOR_flag) begin
			nb_error = nb_error + 1;
			$display("Mismatch on out_XOR_gfpga at time = %t", $realtime);
		end
	end

	always@(posedge out_XNOR_flag) begin
		if(out_XNOR_flag) begin
			nb_error = nb_error + 1;
			$display("Mismatch on out_XNOR_gfpga at time = %t", $realtime);
		end
	end

	always@(posedge out_AND_flag) begin
		if(out_AND_flag) begin
			nb_error = nb_error + 1;
			$display("Mismatch on out_AND_gfpga at time = %t", $realtime);
		end
	end

	always@(posedge out_NAND_flag) begin
		if(out_NAND_flag) begin
			nb_error = nb_error + 1;
			$display("Mismatch on out_NAND_gfpga at time = %t", $realtime);
		end
	end

	always@(posedge out_OR_flag) begin
		if(out_OR_flag) begin
			nb_error = nb_error + 1;
			$display("Mismatch on out_OR_gfpga at time = %t", $realtime);
		end
	end

	always@(posedge out_NOR_flag) begin
		if(out_NOR_flag) begin
			nb_error = nb_error + 1;
			$display("Mismatch on out_NOR_gfpga at time = %t", $realtime);
		end
	end

	always@(posedge out_XOR_sync_flag) begin
		if(out_XOR_sync_flag) begin
			nb_error = nb_error + 1;
			$display("Mismatch on out_XOR_sync_gfpga at time = %t", $realtime);
		end
	end

	always@(posedge out_XNOR_sync_flag) begin
		if(out_XNOR_sync_flag) begin
			nb_error = nb_error + 1;
			$display("Mismatch on out_XNOR_sync_gfpga at time = %t", $realtime);
		end
	end

	always@(posedge out_AND_sync_flag) begin
		if(out_AND_sync_flag) begin
			nb_error = nb_error + 1;
			$display("Mismatch on out_AND_sync_gfpga at time = %t", $realtime);
		end
	end

	always@(posedge out_NAND_sync_flag) begin
		if(out_NAND_sync_flag) begin
			nb_error = nb_error + 1;
			$display("Mismatch on out_NAND_sync_gfpga at time = %t", $realtime);
		end
	end

	always@(posedge out_OR_sync_flag) begin
		if(out_OR_sync_flag) begin
			nb_error = nb_error + 1;
			$display("Mismatch on out_OR_sync_gfpga at time = %t", $realtime);
		end
	end

	always@(posedge out_NOR_sync_flag) begin
		if(out_NOR_sync_flag) begin
			nb_error = nb_error + 1;
			$display("Mismatch on out_NOR_sync_gfpga at time = %t", $realtime);
		end
	end

`endif

`ifdef ICARUS_SIMULATOR
// ----- Begin Icarus requirement -------
	initial begin
		$dumpfile("K4N4_test_modes_formal.vcd");
		$dumpvars(1, K4N4_test_modes_top_formal_verification_random_tb);
	end
`endif
// ----- END Icarus requirement -------

initial begin
	sim_start[0] <= 1'b1;
	$timeformat(-9, 2, "ns", 20);
	$display("Simulation start");
// ----- Can be changed by the user for his/her need -------
	#20000
	if(nb_error == 0) begin
		$display("Simulation Succeed");
	end else begin
		$display("Simulation Failed with %d error(s)", nb_error);
	end
	$finish;
end

endmodule
// ----- END Verilog module for K4N4_test_modes_top_formal_verification_random_tb -----
