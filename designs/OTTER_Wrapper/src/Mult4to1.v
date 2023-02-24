module Mult6to1 (
	In1,
	In2,
	In3,
	In4,
	In5,
	In6,
	Sel,
	Out
);
	input [31:0] In1;
	input [31:0] In2;
	input [31:0] In3;
	input [31:0] In4;
	input [31:0] In5;
	input [31:0] In6;
	input [3:0] Sel;
	output reg [31:0] Out;
	always @(*)
		case (Sel)
			0: Out <= In1;
			1: Out <= In2;
			2: Out <= In3;
			3: Out <= In4;
			4: Out <= In5;
			5: Out <= In6;
			default: Out <= In1;
		endcase
endmodule
module Mult5to1 (
	In1,
	In2,
	In3,
	In4,
	In5,
	Sel,
	Out
);
	input [31:0] In1;
	input [31:0] In2;
	input [31:0] In3;
	input [31:0] In4;
	input [31:0] In5;
	input [2:0] Sel;
	output reg [31:0] Out;
	always @(*)
		case (Sel)
			0: Out <= In1;
			1: Out <= In2;
			2: Out <= In3;
			3: Out <= In4;
			4: Out <= In5;
			default: Out <= In1;
		endcase
endmodule
module Mult4to1 (
	In1,
	In2,
	In3,
	In4,
	Sel,
	Out
);
	input [31:0] In1;
	input [31:0] In2;
	input [31:0] In3;
	input [31:0] In4;
	input [1:0] Sel;
	output reg [31:0] Out;
	always @(*)
		case (Sel)
			0: Out <= In1;
			1: Out <= In2;
			2: Out <= In3;
			default: Out <= In4;
		endcase
endmodule
module Mult2to1 (
	In1,
	In2,
	Sel,
	Out
);
	input [31:0] In1;
	input [31:0] In2;
	input Sel;
	output reg [31:0] Out;
	always @(*)
		case (Sel)
			0: Out <= In1;
			default: Out <= In2;
		endcase
endmodule
