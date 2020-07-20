`default_nettype none
module serv_mpram
  (
   input wire 	    i_clk,
   input wire 	    i_rst,
   input wire       i_run,
   //Trap interface
   input wire 	    i_trap,
   input wire 	    i_mret,
   input wire 	    i_mepc,
   input wire 	    i_mtval,
   output wire 	    o_csr_pc,
   //CSR interface
   input wire 	    i_csr_en,
   input wire [1:0] i_csr_addr,
   input wire 	    i_csr,
   output wire 	    o_csr,
   //RD write port
   input wire 	    i_rd_wen,
   input wire [4:0] i_rd_waddr,
   input wire 	    i_rd,

   input wire 	    i_wreq,
   input wire 	    i_rreq,
   output reg 	    o_rgnt,
   //RS1 read port
   input wire [4:0] i_rs1_raddr,
   output wire 	    o_rs1,
   //RS2 read port
   input wire [4:0] i_rs2_raddr,
   output wire 	    o_rs2);

`include "serv_params.vh"

   /*
    ********** Write side ***********
    */

   reg [4:0] 	     wcnt;
   reg 		     wgo;

   wire [3:0] 	     wslot = wcnt[4:1];
   wire 	     wport = wcnt[0];

   wire 	     wdata0 = i_trap ? i_mtval : i_rd;
   wire 	     wdata1 = i_trap ? i_mepc : i_csr;
   reg 		     wdata0_r;
   reg 		     wdata1_r;
   reg 		     wdata1_2r;
   wire [1:0] 	     wdata = !wport ?
		     {wdata0  , wdata0_r} :
		     {wdata1_r, wdata1_2r};

   //port 0 rd mtval
   //port 1 csr mepc
   //mepc  100010
   //mtval 100011
   //csr   1000xx
   //rd    0xxxxx
   wire [5:0] wreg0 = i_trap ? {4'b1000,CSR_MTVAL} : {1'b0,i_rd_waddr};
   wire [5:0] wreg1 = i_trap ? {4'b1000,CSR_MEPC}  : {4'b1000,i_csr_addr};
   wire [5:0] wreg  = wport ? wreg1 : wreg0;
   wire [9:0] waddr = {wreg, wslot};

   wire       wen = wgo & (i_trap | (wport ? i_csr_en : i_rd_wen & run_r));

   reg 	      wreq_r;
   reg 	      run_r;

   always @(posedge i_clk) begin
      wreq_r    <= i_wreq | o_rgnt;
      wdata0_r  <= wdata0;
      wdata1_r  <= wdata1;
      wdata1_2r <= wdata1_r;
      run_r <= i_run;


      if (wgo)
	wcnt <= wcnt+5'd1;

      if (wreq_r)
	 wgo <= 1'b1;
      if (wcnt == 5'b11111)
	wgo <= 1'b0;

      if (i_rst) begin
	 wcnt <= 5'd0;
      end
   end

   /*
    ********** Read side ***********
    */

   //0 : RS1
   //1 : RS2 / CSR

   reg [4:0]  rcnt;
   wire [3:0] rslot = rcnt[4:1];
   wire       rport = rcnt[0];

   wire [5:0] rreg0 = {1'b0, i_rs1_raddr};
   wire [5:0] rreg1 =
	      i_trap   ? {4'b1000, CSR_MTVEC} :
	      i_mret   ? {4'b1000, CSR_MEPC} :
	      i_csr_en ? {4'b1000, i_csr_addr} :
	      {1'b0,i_rs2_raddr};
   wire [5:0] rreg = rport ? rreg1 : rreg0;
   wire [9:0] raddr = {rreg, rslot};

   reg [1:0]  rdata;
   reg [1:0]  rdata0;
   reg 	      rdata1;

   assign o_rs1 = !rport ? rdata0[0] : rdata0[1];
   assign o_rs2 = rport ? rdata1 : rdata[0];

   assign o_csr = o_rs2 & i_csr_en;
   assign o_csr_pc = o_rs2;


   reg 	      rreq_r;

   always @(posedge i_clk) begin
      rcnt <= rcnt+5'd1;
      if (i_rreq)
	 rcnt <= 5'd0;

      rreq_r <= i_rreq;
      o_rgnt <= rreq_r;

      if (rport)
	rdata0 <= rdata;
      if (!rport)
	rdata1 <= rdata[1];

      if (i_rst) begin
	 o_rgnt <= 1'b0;
	 rreq_r <= 1'b0;
      end
   end


   reg [1:0]  memory [0:575];

   always @(posedge i_clk) begin
      if (wen)
`ifdef RISCV_FORMAL
	if (!i_rst)
`endif
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
