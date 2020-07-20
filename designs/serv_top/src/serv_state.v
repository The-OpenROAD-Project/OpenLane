module serv_state
  (
   input wire 	     i_clk,
   input wire 	     i_rst,
   input wire 	     i_new_irq,
   output wire 	     o_trap_taken,
   output reg 	     o_pending_irq,
   input wire 	     i_dbus_ack,
   input wire 	     i_ibus_ack,
   output wire 	     o_rf_rreq,
   output wire 	     o_rf_wreq,
   input wire 	     i_rf_ready,
   input wire 	     i_take_branch,
   input wire 	     i_branch_op,
   input wire 	     i_mem_op,
   input wire 	     i_shift_op,
   input wire 	     i_slt_op,
   input wire 	     i_e_op,
   input wire [4:0]  i_rs1_addr,
   output wire 	     o_init,
   output wire 	     o_run,
   output wire 	     o_cnt_en,
   output reg [4:0]  o_cnt,
   output reg [3:0]  o_cnt_r,
   output wire 	     o_ctrl_pc_en,
   output reg 	     o_ctrl_jump,
   output wire 	     o_ctrl_trap,
   input wire 	     i_ctrl_misalign,
   output wire 	     o_alu_shamt_en,
   input wire 	     i_alu_sh_done,
   output wire 	     o_dbus_cyc,
   output wire [1:0] o_mem_bytecnt,
   input wire 	     i_mem_misalign,
   output wire 	     o_cnt_done,
   output wire 	     o_bufreg_hold,
   output wire 	     o_csr_imm);

   localparam [1:0]
     IDLE     = 2'd0,
     INIT     = 2'd1,
     RUN      = 2'd2,
     TRAP     = 2'd3;

   reg [1:0]    state;

   reg 	cnt_done;
   reg 	stage_two_req;
   wire cnt_en;
   wire running;

   assign o_cnt_done = cnt_done;

   //Update PC in RUN or TRAP states
   assign o_ctrl_pc_en  = running | (state == TRAP);

   assign o_csr_imm = (o_cnt < 5) ? i_rs1_addr[o_cnt[2:0]] : 1'b0;
   assign o_alu_shamt_en = (o_cnt < 5) & (state == INIT);

   assign o_mem_bytecnt = o_cnt[4:3];

   assign cnt_en = (state != IDLE);
   assign o_cnt_en   = cnt_en;

   assign o_init = (state == INIT);

   assign running = (state == RUN);
   assign o_run = running;

   //slt*, branch/jump, shift, load/store
   wire two_stage_op = i_slt_op | i_mem_op | i_branch_op | i_shift_op;

   reg 	stage_two_pending;

   reg 	irq_sync;
   reg 	misalign_trap_sync;

   assign o_dbus_cyc = (state == IDLE) & stage_two_pending & i_mem_op & !i_mem_misalign;

   wire trap_pending = (o_ctrl_jump & i_ctrl_misalign) | i_mem_misalign;

   //Prepare RF for reads when a new instruction is fetched
   // or when stage one caused an exception (rreq implies a write request too)
   assign o_rf_rreq = i_ibus_ack | (stage_two_req & trap_pending);

   //Prepare RF for writes when everything is ready to enter stage two
   assign o_rf_wreq = ((i_shift_op & i_alu_sh_done & stage_two_pending) | (i_mem_op & i_dbus_ack) | (stage_two_req & (i_slt_op | i_branch_op))) & !trap_pending;

   //Shift operations require bufreg to hold for one cycle between INIT and RUN before shifting
   assign o_bufreg_hold = !cnt_en & (stage_two_req | ~i_shift_op);

   assign o_ctrl_trap = i_e_op | o_pending_irq | misalign_trap_sync;
   assign o_trap_taken = i_ibus_ack & o_ctrl_trap;


   always @(posedge i_clk) begin
      if (cnt_done)
	o_ctrl_jump <= (state == INIT) & i_take_branch;

      if (cnt_en)
	stage_two_pending <= o_init;

      if (i_ibus_ack)
	irq_sync <= 1'b0;
      if (i_new_irq)
	irq_sync <= 1'b1;

      if (i_ibus_ack)
	o_pending_irq <= irq_sync;

      cnt_done <= (o_cnt[4:2] == 3'b111) & o_cnt_r[2];

      //Need a strobe for the first cycle in the IDLE state after INIT
      stage_two_req <= cnt_done & (state == INIT);

      if (stage_two_req)
	misalign_trap_sync <= trap_pending;
      if (i_ibus_ack)
	misalign_trap_sync <= 1'b0;

      case (state)
        IDLE : begin
	   if (stage_two_pending) begin
	      if (o_rf_wreq)
		state <= RUN;
	      if (trap_pending & i_rf_ready)
		state <= TRAP;
	   end else begin
	      if (i_rf_ready)
		if (i_e_op | o_pending_irq)
		  state <= TRAP;
		else if (two_stage_op)
		  state <= INIT;
		else
		  state <= RUN;
           end
	end
        INIT : begin
        end
        RUN : begin
        end
	TRAP : begin
	end
        default : state <= IDLE;
      endcase
      if (cnt_done)
        state <= IDLE;

      o_cnt <= o_cnt + {4'd0,cnt_en};
      if (cnt_en)
	o_cnt_r <= {o_cnt_r[2:0],o_cnt_r[3]};

      if (i_rst) begin
	 state <= IDLE;
	 o_cnt   <= 5'd0;
	 stage_two_pending <= 1'b0;
	 o_ctrl_jump <= 1'b0;
	 o_cnt_r <= 4'b0001;
      end
   end

endmodule
