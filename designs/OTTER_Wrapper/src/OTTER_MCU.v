module OTTER_MCU (
	CLK,
	RESET,
	INTR,
	IOBUS_IN,
	IOBUS_OUT,
	IOBUS_ADDR,
	IOBUS_WR
);
	input CLK;
	input RESET;
	input INTR;
	input [31:0] IOBUS_IN;
	output wire [31:0] IOBUS_OUT;
	output wire [31:0] IOBUS_ADDR;
	output wire IOBUS_WR;
	wire [6:0] opcode;
	wire [31:0] pc;
	wire [31:0] pc_value;
	wire [31:0] next_pc;
	wire [31:0] jalr_pc;
	wire [31:0] branch_pc;
	wire [31:0] jump_pc;
	wire [31:0] int_pc;
	wire [31:0] A;
	wire [31:0] B;
	wire [31:0] I_immed;
	wire [31:0] S_immed;
	wire [31:0] U_immed;
	wire [31:0] aluBin;
	wire [31:0] aluAin;
	wire [31:0] aluResult;
	wire [31:0] rfIn;
	wire [31:0] mem_data;
	wire [31:0] B_immed;
	wire [31:0] J_immed;
	wire [31:0] IR;
	wire memRead1;
	wire memRead2;
	wire pcWrite;
	wire regWrite;
	wire memWrite;
	wire op1_sel;
	wire mem_op;
	wire memRead;
	wire [1:0] opB_sel;
	wire [1:0] rf_sel;
	wire [1:0] wb_sel;
	reg [1:0] pc_sel;
	wire [3:0] alu_fun;
	wire opA_sel;
	reg br_lt;
	reg br_eq;
	reg br_ltu;
	wire wb_enable;
	wire stall_pc;
	wire stall_if;
	wire stall_de;
	reg stall_ex = 0;
	reg stall_mem = 0;
	reg stall_wb = 0;
	reg if_de_invalid = 0;
	reg de_ex_invalid = 0;
	reg ex_mem_invalid = 0;
	reg mem_wb_invalid = 0;
	reg [68:0] de_ex_inst;
	wire [68:0] de_inst;
	reg [68:0] ex_mem_inst;
	reg [68:0] mem_wb_inst;
	initial $monitor("IF: %4h, DE: %4h (%s)\t EX: %4h (%s)\t MEM: %4h (%s)\t WB: %4h (%0s)", pc, de_inst[31-:32], de_inst.opcode.name(), de_ex_inst[31-:32], de_ex_inst.opcode.name(), ex_mem_inst[31-:32], ex_mem_inst.opcode.name(), mem_wb_inst[31-:32], mem_wb_inst.opcode.name());
	reg [31:0] if_de_pc;
	always @(posedge CLK)
		if (!stall_if)
			if_de_pc <= pc;
	assign pcWrite = !stall_pc;
	assign memRead1 = !stall_if;
	assign next_pc = pc + 4;
	assign opcode = IR[6:0];
	ProgCount PC(
		.PC_CLK(CLK),
		.PC_RST(RESET),
		.PC_LD(pcWrite),
		.PC_DIN(pc_value),
		.PC_COUNT(pc)
	);
	Mult4to1 PCdatasrc(
		.In1(next_pc),
		.In2(jalr_pc),
		.In3(branch_pc),
		.In4(jump_pc),
		.Sel(pc_sel),
		.Out(pc_value)
	);
	reg [31:0] de_ex_opA;
	reg [31:0] de_ex_opB;
	reg [31:0] de_ex_rs2;
	reg [31:0] de_ex_I_immed;
	reg [31:0] de_ex_J_immed;
	reg [31:0] de_ex_B_immed;
	wire [6:0] OPCODE;
	assign OPCODE = opcode;
	assign de_inst[61-:5] = IR[19:15];
	assign de_inst[56-:5] = IR[24:20];
	assign de_inst[51-:5] = IR[11:7];
	assign de_inst[68-:7] = OPCODE;
	assign de_inst[43-:4] = alu_fun;
	assign de_inst[36-:2] = wb_sel;
	assign de_inst[31-:32] = if_de_pc;
	assign de_inst[34-:3] = IR[14:12];
	assign de_inst[46] = (((de_inst[61-:5] != 0) && (de_inst[68-:7] != 7'b0110111)) && (de_inst[68-:7] != 7'b0010111)) && (de_inst[68-:7] != 7'b1101111);
	assign de_inst[45] = (de_inst[56-:5] != 0) && (((de_inst[68-:7] == 7'b1100011) || (de_inst[68-:7] == 7'b0100011)) || (de_inst[68-:7] == 7'b0110011));
	assign de_inst[44] = (de_inst[68-:7] != 7'b1100011) && (de_inst[68-:7] != 7'b0100011);
	assign de_inst[37] = (de_inst[68-:7] != 7'b1100011) && (de_inst[68-:7] != 7'b0100011);
	assign de_inst[39] = de_inst[68-:7] == 7'b0100011;
	assign de_inst[38] = de_inst[68-:7] == 7'b0000011;
	OTTER_CU_Decoder CU_DECODER(
		.CU_OPCODE(opcode),
		.CU_FUNC3(IR[14:12]),
		.CU_FUNC7(IR[31:25]),
		.CU_BR_EQ(br_eq),
		.CU_BR_LT(br_lt),
		.CU_BR_LTU(br_ltu),
		.CU_ALU_SRCA(opA_sel),
		.CU_ALU_SRCB(opB_sel),
		.CU_ALU_FUN(alu_fun),
		.CU_RF_WR_SEL(wb_sel)
	);
	Mult4to1 ALUBinput(
		.In1(B),
		.In2(I_immed),
		.In3(S_immed),
		.In4(de_inst[31-:32]),
		.Sel(opB_sel),
		.Out(aluBin)
	);
	Mult2to1 ALUAinput(
		.In1(A),
		.In2(U_immed),
		.Sel(opA_sel),
		.Out(aluAin)
	);
	OTTER_registerFile RF(
		.Read1(de_inst[61-:5]),
		.Read2(de_inst[56-:5]),
		.WriteReg(mem_wb_inst[51-:5]),
		.WriteData(rfIn),
		.RegWrite(wb_enable),
		.Data1(A),
		.Data2(B),
		.clock(CLK)
	);
	assign S_immed = {{20 {IR[31]}}, IR[31:25], IR[11:7]};
	assign I_immed = {{20 {IR[31]}}, IR[31:20]};
	assign U_immed = {IR[31:12], {12 {1'b0}}};
	assign B_immed = {{20 {IR[31]}}, IR[7], IR[30:25], IR[11:8], 1'b0};
	assign J_immed = {{12 {IR[31]}}, IR[19:12], IR[20], IR[30:21], 1'b0};
	always @(posedge CLK)
		if (!stall_de) begin
			de_ex_inst <= de_inst;
			de_ex_opA <= aluAin;
			de_ex_opB <= aluBin;
			de_ex_rs2 <= B;
			de_ex_I_immed <= I_immed;
			de_ex_J_immed <= J_immed;
			de_ex_B_immed <= B_immed;
		end
	wire ld_use_hazard;
	assign ld_use_hazard = (!if_de_invalid && !de_ex_invalid) && (de_ex_inst[38] && (((de_inst[61-:5] == de_ex_inst[51-:5]) && de_inst[46]) || ((de_inst[56-:5] == de_ex_inst[51-:5]) && de_inst[45])));
	assign stall_if = ld_use_hazard;
	assign stall_pc = ld_use_hazard;
	assign stall_de = ld_use_hazard;
	wire branch_taken;
	assign branch_taken = !de_ex_invalid && (pc_sel != 0);
	always @(posedge CLK)
		if (RESET) begin
			if_de_invalid <= 1;
			de_ex_invalid <= 1;
			ex_mem_invalid <= 1;
			mem_wb_invalid <= 1;
		end
		else begin
			if (!stall_if)
				if_de_invalid <= branch_taken;
			if (!stall_de)
				de_ex_invalid <= if_de_invalid | branch_taken;
			else if (!stall_ex)
				de_ex_invalid <= 1;
			if (!stall_ex)
				ex_mem_invalid <= de_ex_invalid;
			if (!stall_mem)
				mem_wb_invalid <= ex_mem_invalid;
		end
	reg [31:0] ex_mem_rs2;
	reg [31:0] rs2_forwarded;
	reg [31:0] ex_mem_aluRes = 0;
	reg [31:0] opA_forwarded;
	reg [31:0] opB_forwarded;
	OTTER_ALU ALU(
		.ALU_fun(de_ex_inst[43-:4]),
		.A(opA_forwarded),
		.B(opB_forwarded),
		.ALUOut(aluResult)
	);
	always @(*) begin
		br_lt = 0;
		br_eq = 0;
		br_ltu = 0;
		if ($signed(opA_forwarded) < $signed(opB_forwarded))
			br_lt = 1;
		if (opA_forwarded == opB_forwarded)
			br_eq = 1;
		if (opA_forwarded < opB_forwarded)
			br_ltu = 1;
	end
	reg brn_cond;
	always @(*)
		case (de_ex_inst[34-:3])
			3'b000: brn_cond = br_eq;
			3'b001: brn_cond = ~br_eq;
			3'b100: brn_cond = br_lt;
			3'b101: brn_cond = ~br_lt;
			3'b110: brn_cond = br_ltu;
			3'b111: brn_cond = ~br_ltu;
			default: brn_cond = 0;
		endcase
	always @(*)
		if (!de_ex_invalid)
			case (de_ex_inst[68-:7])
				7'b1101111: pc_sel = 2'b11;
				7'b1100111: pc_sel = 2'b01;
				7'b1100011: pc_sel = (brn_cond ? 2'b10 : 2'b00);
				default: pc_sel = 2'b00;
			endcase
		else
			pc_sel = 2'b00;
	assign jalr_pc = de_ex_I_immed + opA_forwarded;
	assign branch_pc = de_ex_B_immed + de_ex_inst[31-:32];
	assign jump_pc = de_ex_J_immed + de_ex_inst[31-:32];
	always @(posedge CLK)
		if (!stall_ex) begin
			ex_mem_aluRes <= aluResult;
			ex_mem_inst <= de_ex_inst;
			ex_mem_rs2 <= rs2_forwarded;
		end
	reg [31:0] mem_wb_aluRes;
	wire mem_enable;
	wire mem_Wenable;
	assign mem_Wenable = !ex_mem_invalid && ex_mem_inst[39];
	wire mem_Renable;
	assign mem_Renable = !ex_mem_invalid && ex_mem_inst[38];
	OTTER_mem_byte #(.ACTUAL_WIDTH(14)) memory(
		.MEM_CLK(CLK),
		.MEM_ADDR1(pc),
		.MEM_ADDR2(ex_mem_aluRes),
		.MEM_DIN2(ex_mem_rs2),
		.MEM_WRITE2(mem_Wenable),
		.MEM_READ1(memRead1),
		.MEM_READ2(mem_Renable),
		.MEM_DOUT1(IR),
		.MEM_DOUT2(mem_data),
		.IO_IN(IOBUS_IN),
		.IO_WR(IOBUS_WR),
		.MEM_SIZE(ex_mem_inst[33:32]),
		.MEM_SIGN(ex_mem_inst[34])
	);
	assign IOBUS_ADDR = ex_mem_aluRes;
	assign IOBUS_OUT = ex_mem_rs2;
	always @(posedge CLK)
		if (!stall_mem) begin
			mem_wb_inst <= ex_mem_inst;
			mem_wb_aluRes <= ex_mem_aluRes;
		end
	assign wb_enable = (!stall_wb && !mem_wb_invalid) && mem_wb_inst[37];
	wire csr_reg;
	Mult4to1 regWriteback(
		.In1(mem_wb_inst[31-:32] + 4),
		.In2(csr_reg),
		.In3(mem_data),
		.In4(mem_wb_aluRes),
		.Sel(mem_wb_inst[36-:2]),
		.Out(rfIn)
	);
	reg valid_forward_from_mem;
	reg valid_forward_from_wb;
	always @(*) begin
		valid_forward_from_mem = ex_mem_inst[37] && !ex_mem_invalid;
		valid_forward_from_wb = mem_wb_inst[37] && !mem_wb_invalid;
		opA_forwarded = de_ex_opA;
		opB_forwarded = de_ex_opB;
		rs2_forwarded = de_ex_rs2;
		if ((valid_forward_from_mem && (ex_mem_inst[51-:5] == de_ex_inst[61-:5])) && de_ex_inst[46])
			opA_forwarded = ex_mem_aluRes;
		else if ((valid_forward_from_wb && (mem_wb_inst[51-:5] == de_ex_inst[61-:5])) && de_ex_inst[46])
			opA_forwarded = rfIn;
		if ((valid_forward_from_mem && (ex_mem_inst[51-:5] == de_ex_inst[56-:5])) && de_ex_inst[45]) begin
			if (de_ex_inst[68-:7] != 7'b0100011)
				opB_forwarded = ex_mem_aluRes;
			else
				rs2_forwarded = ex_mem_aluRes;
		end
		else if ((valid_forward_from_wb && (mem_wb_inst[51-:5] == de_ex_inst[56-:5])) && de_ex_inst[45])
			if (de_ex_inst[68-:7] != 7'b0100011)
				opB_forwarded = rfIn;
			else
				rs2_forwarded = rfIn;
	end
endmodule
