module OTTER_CU_FSM (
	CU_CLK,
	CU_INT,
	CU_prevINT,
	CU_RESET,
	CU_OPCODE,
	CU_FUNC3,
	CU_FUNC12,
	CU_PCWRITE,
	CU_REGWRITE,
	CU_MEMWRITE,
	CU_MEMREAD1,
	CU_MEMREAD2,
	CU_intTaken,
	CU_csrWrite,
	CU_intCLR
);
	input CU_CLK;
	input CU_INT;
	input CU_prevINT;
	input CU_RESET;
	input [6:0] CU_OPCODE;
	input [2:0] CU_FUNC3;
	input [11:0] CU_FUNC12;
	output wire CU_PCWRITE;
	output wire CU_REGWRITE;
	output wire CU_MEMWRITE;
	output wire CU_MEMREAD1;
	output wire CU_MEMREAD2;
	output wire CU_intTaken;
	output wire CU_csrWrite;
	output wire CU_intCLR;
	wire [6:0] OPCODE;
	assign OPCODE = CU_OPCODE;
	reg [1:0] state;
	wire MRET;
	assign MRET = ((CU_OPCODE == 7'b1110011) && (CU_FUNC3 == 3'b000)) && (CU_FUNC12 == 12'h302);
	assign CU_MEMREAD1 = state == 0;
	assign CU_MEMREAD2 = (state == 1) && (CU_OPCODE == 7'b0000011);
	assign CU_MEMWRITE = (state == 1) && (CU_OPCODE == 7'b0100011);
	assign CU_PCWRITE = (((state == 1) && (CU_OPCODE != 7'b0000011)) || ((state == 2) && (CU_OPCODE == 7'b0000011))) || (state == 2'd3);
	assign CU_REGWRITE = (state == 2) || ((state == 1) && ((((CU_OPCODE != 7'b1100011) && (CU_OPCODE != 7'b0000011)) && (CU_OPCODE != 7'b0100011)) && ~MRET));
	initial state = 2'd0;
	always @(posedge CU_CLK)
		if (CU_RESET)
			state <= 2'd0;
		else
			case (state)
				2'd0: state <= 2'd1;
				2'd1:
					if (CU_OPCODE != 7'b0000011) begin
						state <= 2'd0;
						if (CU_INT || CU_prevINT)
							state <= 2'd3;
					end
					else
						state <= 2'd2;
				2'd2: begin
					state <= 2'd0;
					if (CU_INT || CU_prevINT)
						state <= 2'd3;
				end
				2'd3: state <= 2'd0;
				default: state <= 2'd0;
			endcase
	assign CU_intCLR = (((CU_OPCODE == 7'b0000011) && (state == 2'd2)) || ((CU_OPCODE != 7'b0000011) && (state == 2'd1))) || (state == 2'd3);
	assign CU_csrWrite = ((state == 2'd1) && (CU_OPCODE == 7'b1110011)) && (CU_FUNC3 == 3'b001);
	assign CU_intTaken = state == 2'd3;
endmodule
