`default_nettype none
module serv_csr
  (
   input wire 	    i_clk,
   input wire 	    i_run,
   input wire [4:2] i_cnt,
   input wire [3:2] i_cnt_r,
   input wire 	    i_e_op,
   input wire 	    i_ebreak,
   input wire 	    i_mem_cmd,
   input wire 	    i_mem_misalign,
   //From mpram
   input wire 	    i_rf_csr_out,
   //to mpram
   output wire 	    o_csr_in,
   //Stuff
   input wire 	    i_mtip,
   output wire 	    o_new_irq,
   input wire 	    i_pending_irq,
   input wire 	    i_trap_taken,
   input wire 	    i_mstatus_en,
   input wire 	    i_mie_en,
   input wire 	    i_mcause_en,
   input wire [1:0] i_csr_source,
   input wire 	    i_mret,
   input wire 	    i_d,
   output wire 	    o_q);

`include "serv_params.vh"

   reg 		    mstatus;
   reg 		    mstatus_mie;
   reg 		    mstatus_mpie;
   reg 		    mie_mtie;

   reg 		mcause31;
   reg [3:0] 	mcause3_0;
   wire 	mcause;

   wire 	csr_in;
   wire 	csr_out;

   reg 		timer_irq_r;

   assign csr_in = (i_csr_source == CSR_SOURCE_EXT) ? i_d :
		   (i_csr_source == CSR_SOURCE_SET) ? csr_out | i_d :
		   (i_csr_source == CSR_SOURCE_CLR) ? csr_out & ~i_d :
		   (i_csr_source == CSR_SOURCE_CSR) ? csr_out :
		   1'bx;

   assign csr_out = (i_mstatus_en & i_run & mstatus) |
		    i_rf_csr_out |
		    (i_mcause_en & i_run & mcause);

   assign o_q = csr_out;

   wire 	timer_irq = i_mtip & mstatus_mie & mie_mtie;

   assign mcause = (i_cnt[4:2] == 3'd0) ? mcause3_0[0] : //[3:0]
		   ((i_cnt[4:2] == 3'd7) & i_cnt_r[3]) ? mcause31 //[31]
		   : 1'b0;

   assign o_csr_in = csr_in;

   assign o_new_irq = !timer_irq_r & timer_irq;


   always @(posedge i_clk) begin
      /*
       Note: To save resources mstatus_mpie (mstatus bit 7) is not
       readable or writable from sw
       */
      if (i_mstatus_en & (i_cnt[4:2] == 3'd0) & i_cnt_r[3])
	mstatus_mie <= csr_in;

      if (i_mie_en & (i_cnt[4:2] == 3'd1) & i_cnt_r[3])
	mie_mtie <= csr_in;

      mstatus <= (i_cnt[4:2] == 0) & i_cnt_r[2] & mstatus_mie;

      timer_irq_r <= timer_irq;

      if (i_mret) begin
	 mstatus_mie <= mstatus_mpie;
      end

      if (i_trap_taken) begin
	 mstatus_mpie <= mstatus_mie;
	 mstatus_mie <= 1'b0;
	 mcause31  <= i_pending_irq;
	 mcause3_0 <= i_pending_irq ? 4'd7 :
		      i_e_op ? {!i_ebreak, 3'b011} :
		      i_mem_misalign ? {2'b01, i_mem_cmd, 1'b0} :
		      4'd0;
      end

      if (i_mcause_en & i_run) begin
	 if (i_cnt[4:2] == 3'd0)
	   mcause3_0 <= {csr_in, mcause3_0[3:1]};
	 if ((i_cnt[4:2] == 3'd7) & i_cnt_r[3])
	   mcause31 <= csr_in;
      end
   end

endmodule
