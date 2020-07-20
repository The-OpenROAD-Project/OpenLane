//*********************************************************
// IEEE STD 1364-2001 Verilog file: cmul7p8.v
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
module cmul7p8 // ------> Interface
(input signed [4:0] x, // System input
output signed [4:0] y0, y1, y2, y3);
// The 4 system outputs y=7*x/8
// --------------------------------------------------------
assign y0 = 7 * x / 8;
assign y1 = x / 8 * 7;
assign y2 = x/2 + x/4 + x/8;
assign y3 = x - x/8;
endmodule

