`default_nettype none
module serv_regfile
  (
   input wire 	    i_clk,
   input wire 	    i_rst,
   input wire 	    i_go,
   output reg 	    o_ready,
   input wire 	    i_rd_en,
   input wire [4:0] i_rd_addr,
   input wire 	    i_rd,
   input wire [4:0] i_rs1_addr,
   input wire [4:0] i_rs2_addr,
   output wire 	    o_rs1,
   output wire 	    o_rs2);

   reg 		    t;
   always @(posedge i_clk) begin
     o_ready <= t;
     t <= i_go;
      if (i_rst) begin
	 o_ready <= 1'b0;
	 t <= 1'b0;
      end
   end

   reg rd_r;

   reg [1:0]  rdata;
   reg [4:0] rcnt;
   reg [4:0] wcnt;
   reg 	     rs1;
   reg 	     rs2;
   reg 	     rs1_r;

   wire rs1_en = rcnt[0];
   wire rs1_tmp = (rs1_en ? rdata[0] : rs1);

   wire [1:0] wdata = {i_rd, rd_r};
   always @(posedge i_clk) begin
      rd_r <= i_rd;
      if (i_rd_en)
	wcnt <= wcnt + 5'd1;

      if (i_go)
	rcnt <= 5'd0;
      else
	rcnt <= rcnt + 4'd1;
      if (rs1_en) begin
	 rs1 <= rdata[1];
      end else begin
	 rs2 <= rdata[1];
      end
      rs1_r <= rs1_tmp;
      if (i_rst) begin
	 wcnt <= 5'd0;
      end
   end


   assign o_rs1 = rs1_r;
   assign o_rs2 = (rs1_en ? rs2 : rdata[0]);

   wire [8:0] waddr = {i_rd_addr, wcnt[4:1]};
   wire wr_en = wcnt[0] & i_rd_en & (|i_rd_addr);

   wire [8:0] raddr = {!rs1_en ? i_rs1_addr : i_rs2_addr, rcnt[4:1]};

   reg [1:0]  memory [0:511];

   always @(posedge i_clk) begin
      if (wr_en)
	memory[waddr] <= wdata;
      rdata <= memory[raddr];
   end

`ifdef RISCV_FORMAL
 `define SERV_CLEAR_RAM
`endif

`ifdef SERV_CLEAR_RAM
   integer i;
   initial
     for (i=0;i<512;i=i+1)
       memory[i] = 2'd0;
`endif

endmodule
