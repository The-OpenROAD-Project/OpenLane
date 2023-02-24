module OTTER_mem_dualport (
	MEM_CLK,
	MEM_ADDR1,
	MEM_ADDR2,
	MEM_DIN2,
	MEM_WRITE2,
	MEM_READ1,
	MEM_READ2,
	ERR,
	MEM_DOUT1,
	MEM_DOUT2,
	IO_IN,
	IO_WR
);
	parameter ACTUAL_WIDTH = 14;
	input [31:0] MEM_ADDR1;
	input [31:0] MEM_ADDR2;
	input MEM_CLK;
	input [31:0] MEM_DIN2;
	input MEM_WRITE2;
	input MEM_READ1;
	input MEM_READ2;
	input [31:0] IO_IN;
	output wire ERR;
	output reg [31:0] MEM_DOUT1;
	output reg [31:0] MEM_DOUT2;
	output reg IO_WR;
	wire [ACTUAL_WIDTH - 1:0] memAddr1;
	wire [ACTUAL_WIDTH - 1:0] memAddr2;
	reg memWrite2;
	reg [31:0] memOut2;
	reg [31:0] ioIn_buffer = 0;
	assign memAddr1 = MEM_ADDR1[ACTUAL_WIDTH + 1:2];
	assign memAddr2 = MEM_ADDR2[ACTUAL_WIDTH + 1:2];
	(* rom_style = "{distributed | block}" *) reg [31:0] memory [0:(2 ** ACTUAL_WIDTH) - 1];
	initial $readmemh("otter_memory.mem", memory, 0, (2 ** ACTUAL_WIDTH) - 1);
	always @(posedge MEM_CLK) begin
		if (memWrite2)
			memory[memAddr2] <= MEM_DIN2;
		if (MEM_READ2)
			memOut2 = memory[memAddr2];
		if (MEM_READ1)
			MEM_DOUT1 = memory[memAddr1];
	end
	assign ERR = ((((MEM_ADDR1 >= (2 ** ACTUAL_WIDTH)) || (MEM_ADDR2 >= (2 ** ACTUAL_WIDTH))) || (MEM_ADDR1[1:0] != 2'b00)) || (MEM_ADDR2[1:0] != 2'b00) ? 1 : 0);
	always @(posedge MEM_CLK)
		if (MEM_READ2)
			ioIn_buffer <= IO_IN;
	always @(*) begin
		IO_WR = 0;
		if (MEM_ADDR2 >= 32'h11000000) begin
			if (MEM_WRITE2)
				IO_WR = 1;
			memWrite2 = 0;
			MEM_DOUT2 = ioIn_buffer;
		end
		else begin
			memWrite2 = MEM_WRITE2;
			MEM_DOUT2 = memOut2;
		end
	end
endmodule
module OTTER_mem_byte (
	MEM_CLK,
	MEM_ADDR1,
	MEM_ADDR2,
	MEM_DIN2,
	MEM_WRITE2,
	MEM_READ1,
	MEM_READ2,
	ERR,
	MEM_DOUT1,
	MEM_DOUT2,
	IO_IN,
	IO_WR,
	MEM_SIZE,
	MEM_SIGN
);
	parameter ACTUAL_WIDTH = 14;
	parameter NUM_COL = 4;
	parameter COL_WIDTH = 8;
	input [31:0] MEM_ADDR1;
	input [31:0] MEM_ADDR2;
	input MEM_CLK;
	input [31:0] MEM_DIN2;
	input MEM_WRITE2;
	input MEM_READ1;
	input MEM_READ2;
	input [31:0] IO_IN;
	output wire ERR;
	input [1:0] MEM_SIZE;
	input MEM_SIGN;
	output reg [31:0] MEM_DOUT1;
	output reg [31:0] MEM_DOUT2;
	output reg IO_WR;
	reg saved_mem_sign;
	reg [1:0] saved_mem_size;
	reg [31:0] saved_mem_addr2;
	wire [ACTUAL_WIDTH - 1:0] memAddr1;
	wire [ACTUAL_WIDTH - 1:0] memAddr2;
	reg memWrite2;
	reg [31:0] memOut2;
	reg [31:0] ioIn_buffer = 0;
	reg [NUM_COL - 1:0] weA;
	assign memAddr1 = MEM_ADDR1[ACTUAL_WIDTH + 1:2];
	assign memAddr2 = MEM_ADDR2[ACTUAL_WIDTH + 1:2];
	(* rom_style = "{distributed | block}" *) (* ram_decomp = "power" *) reg [31:0] memory [0:(2 ** ACTUAL_WIDTH) - 1];
	initial $readmemh("otter_memory.mem", memory, 0, (2 ** ACTUAL_WIDTH) - 1);
	always @(*)
		case (MEM_SIZE)
			0: weA = 4'b0001 << MEM_ADDR2[1:0];
			1: weA = 4'b0011 << MEM_ADDR2[1:0];
			2: weA = 4'b1111;
			default: weA = 4'b0000;
		endcase
	integer i;
	integer j;
	always @(posedge MEM_CLK) begin
		if (memWrite2) begin
			j = 0;
			for (i = 0; i < NUM_COL; i = i + 1)
				if (weA[i])
					case (MEM_SIZE)
						0: memory[memAddr2][i * COL_WIDTH+:COL_WIDTH] <= MEM_DIN2[7:0];
						1: begin
							memory[memAddr2][i * COL_WIDTH+:COL_WIDTH] <= MEM_DIN2[j * COL_WIDTH+:COL_WIDTH];
							j = j + 1;
						end
						2: memory[memAddr2][i * COL_WIDTH+:COL_WIDTH] <= MEM_DIN2[i * COL_WIDTH+:COL_WIDTH];
						default: memory[memAddr2][i * COL_WIDTH+:COL_WIDTH] <= MEM_DIN2[i * COL_WIDTH+:COL_WIDTH];
					endcase
		end
		if (MEM_READ2)
			memOut2 <= memory[memAddr2];
		if (MEM_READ1)
			MEM_DOUT1 <= memory[memAddr1];
		saved_mem_size <= MEM_SIZE;
		saved_mem_sign <= MEM_SIGN;
		saved_mem_addr2 <= MEM_ADDR2;
	end
	assign ERR = ((((MEM_ADDR1 >= (2 ** ACTUAL_WIDTH)) || (MEM_ADDR2 >= (2 ** ACTUAL_WIDTH))) || (MEM_ADDR1[1:0] != 2'b00)) || (MEM_ADDR2[1:0] != 2'b00) ? 1 : 0);
	always @(posedge MEM_CLK)
		if (MEM_READ2)
			ioIn_buffer <= IO_IN;
	reg [31:0] memOut2_sliced = 32'b00000000000000000000000000000000;
	always @(*) begin
		memOut2_sliced = 32'b00000000000000000000000000000000;
		case ({saved_mem_sign, saved_mem_size})
			0:
				case (saved_mem_addr2[1:0])
					3: memOut2_sliced = {{24 {memOut2[31]}}, memOut2[31:24]};
					2: memOut2_sliced = {{24 {memOut2[23]}}, memOut2[23:16]};
					1: memOut2_sliced = {{24 {memOut2[15]}}, memOut2[15:8]};
					0: memOut2_sliced = {{24 {memOut2[7]}}, memOut2[7:0]};
				endcase
			1:
				case (saved_mem_addr2[1:0])
					3: memOut2_sliced = {{16 {memOut2[31]}}, memOut2[31:24]};
					2: memOut2_sliced = {{16 {memOut2[31]}}, memOut2[31:16]};
					1: memOut2_sliced = {{16 {memOut2[23]}}, memOut2[23:8]};
					0: memOut2_sliced = {{16 {memOut2[15]}}, memOut2[15:0]};
				endcase
			2:
				case (saved_mem_addr2[1:0])
					1: memOut2_sliced = memOut2[31:8];
					0: memOut2_sliced = memOut2;
				endcase
			4:
				case (saved_mem_addr2[1:0])
					3: memOut2_sliced = {24'd0, memOut2[31:24]};
					2: memOut2_sliced = {24'd0, memOut2[23:16]};
					1: memOut2_sliced = {24'd0, memOut2[15:8]};
					0: memOut2_sliced = {24'd0, memOut2[7:0]};
				endcase
			5:
				case (saved_mem_addr2[1:0])
					3: memOut2_sliced = {16'd0, memOut2};
					2: memOut2_sliced = {16'd0, memOut2[31:16]};
					1: memOut2_sliced = {16'd0, memOut2[23:8]};
					0: memOut2_sliced = {16'd0, memOut2[15:0]};
				endcase
		endcase
	end
	always @(*)
		if (saved_mem_addr2 >= 32'h11000000)
			MEM_DOUT2 = ioIn_buffer;
		else
			MEM_DOUT2 = memOut2_sliced;
	always @(*) begin
		IO_WR = 0;
		if (MEM_ADDR2 >= 32'h11000000) begin
			if (MEM_WRITE2)
				IO_WR = 1;
			memWrite2 = 0;
		end
		else
			memWrite2 = MEM_WRITE2;
	end
endmodule
