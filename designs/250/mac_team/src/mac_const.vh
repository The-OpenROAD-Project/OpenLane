`define MAC_CONF_WIDTH 3  // 1 bit for mac or mul, 2 bits for Single, Dual, or Quad
`define MAC_MIN_WIDTH 8
`define MAC_MULT_WIDTH 2*`MAC_MIN_WIDTH
`define MAC_ACC_WIDTH 2*`MAC_MULT_WIDTH
`define MAC_INT_WIDTH 5*`MAC_MIN_WIDTH // Used for internal MAC wires, widest bitwidth according to Quad config

`define MAC_SINGLE 0
`define MAC_DUAL 1
`define MAC_QUAD 2