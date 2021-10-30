module rv_plic_target (
	clk_i,
	rst_ni,
	ip_i,
	ie_i,
	prio_i,
	threshold_i,
	irq_o,
	irq_id_o
);
	parameter signed [31:0] N_SOURCE = 32;
	parameter signed [31:0] MAX_PRIO = 7;
	localparam signed [31:0] SrcWidth = $clog2(N_SOURCE + 1);
	localparam signed [31:0] PrioWidth = $clog2(MAX_PRIO + 1);
	input clk_i;
	input rst_ni;
	input [N_SOURCE - 1:0] ip_i;
	input [N_SOURCE - 1:0] ie_i;
	input [(0 >= (N_SOURCE - 1) ? ((2 - N_SOURCE) * PrioWidth) + (((N_SOURCE - 1) * PrioWidth) - 1) : (N_SOURCE * PrioWidth) - 1):(0 >= (N_SOURCE - 1) ? (N_SOURCE - 1) * PrioWidth : 0)] prio_i;
	input [PrioWidth - 1:0] threshold_i;
	output wire irq_o;
	output wire [SrcWidth - 1:0] irq_id_o;
	localparam signed [31:0] NumLevels = $clog2(N_SOURCE);
	wire [(2 ** (NumLevels + 1)) - 2:0] is_tree;
	wire [(((2 ** (NumLevels + 1)) - 2) >= 0 ? (((2 ** (NumLevels + 1)) - 1) * SrcWidth) - 1 : ((3 - (2 ** (NumLevels + 1))) * SrcWidth) + ((((2 ** (NumLevels + 1)) - 2) * SrcWidth) - 1)):(((2 ** (NumLevels + 1)) - 2) >= 0 ? 0 : ((2 ** (NumLevels + 1)) - 2) * SrcWidth)] id_tree;
	wire [(((2 ** (NumLevels + 1)) - 2) >= 0 ? (((2 ** (NumLevels + 1)) - 1) * PrioWidth) - 1 : ((3 - (2 ** (NumLevels + 1))) * PrioWidth) + ((((2 ** (NumLevels + 1)) - 2) * PrioWidth) - 1)):(((2 ** (NumLevels + 1)) - 2) >= 0 ? 0 : ((2 ** (NumLevels + 1)) - 2) * PrioWidth)] max_tree;
	generate
		genvar level;
		for (level = 0; level < (NumLevels + 1); level = level + 1) begin : gen_tree
			localparam signed [31:0] Base0 = (2 ** level) - 1;
			localparam signed [31:0] Base1 = (2 ** (level + 1)) - 1;
			genvar offset;
			for (offset = 0; offset < (2 ** level); offset = offset + 1) begin : gen_level
				localparam signed [31:0] Pa = Base0 + offset;
				localparam signed [31:0] C0 = Base1 + (2 * offset);
				localparam signed [31:0] C1 = (Base1 + (2 * offset)) + 1;
				if (level == NumLevels) begin : gen_leafs
					if (offset < N_SOURCE) begin : gen_assign
						assign is_tree[Pa] = ip_i[offset] & ie_i[offset];
						assign id_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? Pa : ((2 ** (NumLevels + 1)) - 2) - Pa) * SrcWidth+:SrcWidth] = offset;
						assign max_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? Pa : ((2 ** (NumLevels + 1)) - 2) - Pa) * PrioWidth+:PrioWidth] = prio_i[(0 >= (N_SOURCE - 1) ? offset : (N_SOURCE - 1) - offset) * PrioWidth+:PrioWidth];
					end
					else begin : gen_tie_off
						assign is_tree[Pa] = 1'b0;
						assign id_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? Pa : ((2 ** (NumLevels + 1)) - 2) - Pa) * SrcWidth+:SrcWidth] = {SrcWidth {1'sb0}};
						assign max_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? Pa : ((2 ** (NumLevels + 1)) - 2) - Pa) * PrioWidth+:PrioWidth] = {PrioWidth {1'sb0}};
					end
				end
				else begin : gen_nodes
					wire sel;
					assign sel = (~is_tree[C0] & is_tree[C1]) | ((is_tree[C0] & is_tree[C1]) & (max_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? C1 : ((2 ** (NumLevels + 1)) - 2) - C1) * PrioWidth+:PrioWidth] > max_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? C0 : ((2 ** (NumLevels + 1)) - 2) - C0) * PrioWidth+:PrioWidth]));
					assign is_tree[Pa] = (sel & is_tree[C1]) | (~sel & is_tree[C0]);
					assign id_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? Pa : ((2 ** (NumLevels + 1)) - 2) - Pa) * SrcWidth+:SrcWidth] = ({SrcWidth {sel}} & id_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? C1 : ((2 ** (NumLevels + 1)) - 2) - C1) * SrcWidth+:SrcWidth]) | ({SrcWidth {~sel}} & id_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? C0 : ((2 ** (NumLevels + 1)) - 2) - C0) * SrcWidth+:SrcWidth]);
					assign max_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? Pa : ((2 ** (NumLevels + 1)) - 2) - Pa) * PrioWidth+:PrioWidth] = ({PrioWidth {sel}} & max_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? C1 : ((2 ** (NumLevels + 1)) - 2) - C1) * PrioWidth+:PrioWidth]) | ({PrioWidth {~sel}} & max_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? C0 : ((2 ** (NumLevels + 1)) - 2) - C0) * PrioWidth+:PrioWidth]);
				end
			end
		end
	endgenerate
	wire irq_d;
	reg irq_q;
	wire [SrcWidth - 1:0] irq_id_d;
	reg [SrcWidth - 1:0] irq_id_q;
	assign irq_d = (max_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? 0 : (2 ** (NumLevels + 1)) - 2) * PrioWidth+:PrioWidth] > threshold_i ? is_tree[0] : 1'b0);
	assign irq_id_d = (is_tree[0] ? id_tree[(((2 ** (NumLevels + 1)) - 2) >= 0 ? 0 : (2 ** (NumLevels + 1)) - 2) * SrcWidth+:SrcWidth] : {SrcWidth {1'sb0}});
	always @(posedge clk_i or negedge rst_ni) begin : gen_regs
		if (!rst_ni) begin
			irq_q <= 1'b0;
			irq_id_q <= {SrcWidth {1'sb0}};
		end
		else begin
			irq_q <= irq_d;
			irq_id_q <= irq_id_d;
		end
	end
	assign irq_o = irq_q;
	assign irq_id_o = irq_id_q;
endmodule
