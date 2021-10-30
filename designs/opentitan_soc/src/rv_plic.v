module rv_plic (
	clk_i,
	rst_ni,
	tl_i,
	tl_o,
	intr_src_i,
	irq_o,
	irq_id_o,
	msip_o
);
	localparam signed [31:0] rv_plic_reg_pkg_NumSrc = 32;
	localparam signed [31:0] SRCW = 6;
	input clk_i;
	input rst_ni;
	localparam signed [31:0] tlul_pkg_TL_AIW = 8;
	localparam signed [31:0] tlul_pkg_TL_AW = 32;
	localparam signed [31:0] tlul_pkg_TL_DW = 32;
	localparam signed [31:0] tlul_pkg_TL_DBW = 4;
	localparam signed [31:0] tlul_pkg_TL_SZW = 2;
	input wire [85:0] tl_i;
	localparam signed [31:0] tlul_pkg_TL_DIW = 1;
	output wire [51:0] tl_o;
	input [31:0] intr_src_i;
	localparam signed [31:0] rv_plic_reg_pkg_NumTarget = 1;
	output [0:0] irq_o;
	output [5:0] irq_id_o;
	output wire [0:0] msip_o;
	wire [171:0] reg2hw;
	wire [69:0] hw2reg;
	localparam signed [31:0] MAX_PRIO = 7;
	localparam signed [31:0] PRIOW = 3;
	wire [31:0] le;
	wire [31:0] ip;
	wire [31:0] ie [0:0];
	wire [0:0] claim_re;
	wire [5:0] claim_id [0:0];
	reg [31:0] claim;
	wire [0:0] complete_we;
	wire [5:0] complete_id [0:0];
	reg [31:0] complete;
	wire [5:0] cc_id;
	wire [95:0] prio;
	wire [2:0] threshold [0:0];
	assign cc_id = irq_id_o;
	always @(*) begin
		claim = {32 {1'sb0}};
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < rv_plic_reg_pkg_NumTarget; i = i + 1)
				if (claim_re[i])
					claim[claim_id[i]] = 1'b1;
		end
	end
	always @(*) begin
		complete = {32 {1'sb0}};
		begin : sv2v_autoblock_2
			reg signed [31:0] i;
			for (i = 0; i < rv_plic_reg_pkg_NumTarget; i = i + 1)
				if (complete_we[i])
					complete[complete_id[i]] = 1'b1;
		end
	end
	assign prio[93+:PRIOW] = reg2hw[139-:3];
	assign prio[90+:PRIOW] = reg2hw[136-:3];
	assign prio[87+:PRIOW] = reg2hw[133-:3];
	assign prio[84+:PRIOW] = reg2hw[130-:3];
	assign prio[81+:PRIOW] = reg2hw[127-:3];
	assign prio[78+:PRIOW] = reg2hw[124-:3];
	assign prio[75+:PRIOW] = reg2hw[121-:3];
	assign prio[72+:PRIOW] = reg2hw[118-:3];
	assign prio[69+:PRIOW] = reg2hw[115-:3];
	assign prio[66+:PRIOW] = reg2hw[112-:3];
	assign prio[63+:PRIOW] = reg2hw[109-:3];
	assign prio[60+:PRIOW] = reg2hw[106-:3];
	assign prio[57+:PRIOW] = reg2hw[103-:3];
	assign prio[54+:PRIOW] = reg2hw[100-:3];
	assign prio[51+:PRIOW] = reg2hw[97-:3];
	assign prio[48+:PRIOW] = reg2hw[94-:3];
	assign prio[45+:PRIOW] = reg2hw[91-:3];
	assign prio[42+:PRIOW] = reg2hw[88-:3];
	assign prio[39+:PRIOW] = reg2hw[85-:3];
	assign prio[36+:PRIOW] = reg2hw[82-:3];
	assign prio[33+:PRIOW] = reg2hw[79-:3];
	assign prio[30+:PRIOW] = reg2hw[76-:3];
	assign prio[27+:PRIOW] = reg2hw[73-:3];
	assign prio[24+:PRIOW] = reg2hw[70-:3];
	assign prio[21+:PRIOW] = reg2hw[67-:3];
	assign prio[18+:PRIOW] = reg2hw[64-:3];
	assign prio[15+:PRIOW] = reg2hw[61-:3];
	assign prio[12+:PRIOW] = reg2hw[58-:3];
	assign prio[9+:PRIOW] = reg2hw[55-:3];
	assign prio[6+:PRIOW] = reg2hw[52-:3];
	assign prio[3+:PRIOW] = reg2hw[49-:3];
	assign prio[0+:PRIOW] = reg2hw[46-:3];
	generate
		genvar s;
		for (s = 0; s < 32; s = s + 1) begin : gen_ie0
			assign ie[0][s] = reg2hw[12 + s];
		end
	endgenerate
	assign threshold[0] = reg2hw[11-:3];
	assign claim_re[0] = reg2hw[1];
	assign claim_id[0] = irq_id_o[0+:SRCW];
	assign complete_we[0] = reg2hw[2];
	assign complete_id[0] = reg2hw[8-:6];
	assign hw2reg[5-:6] = cc_id[0+:SRCW];
	assign msip_o[0] = reg2hw[-0];
	generate
		for (s = 0; s < 32; s = s + 1) begin : gen_ip
			assign hw2reg[6 + (s * 2)] = 1'b1;
			assign hw2reg[6 + ((s * 2) + 1)] = ip[s];
		end
	endgenerate
	generate
		for (s = 0; s < 32; s = s + 1) begin : gen_le
			assign le[s] = reg2hw[140 + s];
		end
	endgenerate
	rv_plic_gateway #(.N_SOURCE(rv_plic_reg_pkg_NumSrc)) u_gateway(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.src_i(intr_src_i),
		.le_i(le),
		.claim_i(claim),
		.complete_i(complete),
		.ip_o(ip)
	);
	generate
		genvar i;
		for (i = 0; i < rv_plic_reg_pkg_NumTarget; i = i + 1) begin : gen_target
			rv_plic_target #(
				.N_SOURCE(rv_plic_reg_pkg_NumSrc),
				.MAX_PRIO(MAX_PRIO)
			) u_target(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.ip_i(ip),
				.ie_i(ie[i]),
				.prio_i(prio),
				.threshold_i(threshold[i]),
				.irq_o(irq_o[i]),
				.irq_id_o(irq_id_o[i * SRCW+:SRCW])
			);
		end
	endgenerate
	rv_plic_reg_top u_reg(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.tl_i(tl_i),
		.tl_o(tl_o),
		.reg2hw(reg2hw),
		.hw2reg(hw2reg),
		.devmode_i(1'b1)
	);
endmodule
