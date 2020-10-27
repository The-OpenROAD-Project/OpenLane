`include "mac_const.vh"

module mac_mul_block_2 (
  input clk,
  input rst,
  input en,
  input [`MAC_MIN_WIDTH-1:0] B2,
  input [`MAC_MIN_WIDTH-1:0] A0,     // Used for cross-multiply when chaining   
  input [`MAC_MIN_WIDTH-1:0] A1,     // Will solidify signals names later
  input [`MAC_MIN_WIDTH-1:0] A2,
  input [`MAC_MIN_WIDTH-1:0] A3,
  input [`MAC_CONF_WIDTH - 1:0] cfg, // Single, Dual or Quad

  output reg [`MAC_INT_WIDTH-1:0] C  // Non-pipelined
);

wire [`MAC_MULT_WIDTH-1:0] A2B2;
wire [`MAC_MULT_WIDTH-1:0] A0B2;
wire [`MAC_MULT_WIDTH-1:0] A1B2;
wire [`MAC_MULT_WIDTH-1:0] A3B2;

// Multiplication output
always @(*) begin
  case (cfg[1:0])
    `MAC_SINGLE:  C = A2B2;  
    `MAC_DUAL:    C = A2B2 + {A3B2, {`MAC_MIN_WIDTH{1'b0}}};
    `MAC_QUAD:    C = A0B2 + {A1B2, {`MAC_MIN_WIDTH{1'b0}}} + {A2B2, {2*`MAC_MIN_WIDTH{1'b0}}} + {A3B2, {3*`MAC_MIN_WIDTH{1'b0}}};
    default:      C = 0;
  endcase
end

// The multiply unit used for all configurations
multiply A2B2_mul_block
(
  .A(A2), 
  .B(B2), 
  .C(A2B2)
);

// The secondary mul unit used for dual configs
multiply A0B2_mul_block 
(
  .A(A0), 
  .B(B2), 
  .C(A0B2)
);

// The third and fourth mul unit used for quad configs
multiply A1B2_mul_block
(
  .A(A1), 
  .B(B2), 
  .C(A1B2)
);
multiply A3B2_mul_block
(
  .A(A3), 
  .B(B2), 
  .C(A3B2)
);

endmodule
