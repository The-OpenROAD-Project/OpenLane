module ibex_controller (
	clk_i,
	rst_ni,
	ctrl_busy_o,
	illegal_insn_i,
	ecall_insn_i,
	mret_insn_i,
	dret_insn_i,
	wfi_insn_i,
	ebrk_insn_i,
	csr_pipe_flush_i,
	instr_valid_i,
	instr_i,
	instr_compressed_i,
	instr_is_compressed_i,
	instr_bp_taken_i,
	instr_fetch_err_i,
	instr_fetch_err_plus2_i,
	pc_id_i,
	instr_valid_clear_o,
	id_in_ready_o,
	controller_run_o,
	instr_req_o,
	pc_set_o,
	pc_set_spec_o,
	pc_mux_o,
	nt_branch_mispredict_o,
	exc_pc_mux_o,
	exc_cause_o,
	lsu_addr_last_i,
	load_err_i,
	store_err_i,
	wb_exception_o,
	branch_set_i,
	branch_set_spec_i,
	branch_not_set_i,
	jump_set_i,
	csr_mstatus_mie_i,
	irq_pending_i,
	irqs_i,
	irq_nm_i,
	nmi_mode_o,
	debug_req_i,
	debug_cause_o,
	debug_csr_save_o,
	debug_mode_o,
	debug_single_step_i,
	debug_ebreakm_i,
	debug_ebreaku_i,
	trigger_match_i,
	csr_save_if_o,
	csr_save_id_o,
	csr_save_wb_o,
	csr_restore_mret_id_o,
	csr_restore_dret_id_o,
	csr_save_cause_o,
	csr_mtval_o,
	priv_mode_i,
	csr_mstatus_tw_i,
	stall_id_i,
	stall_wb_i,
	flush_id_o,
	ready_wb_i,
	perf_jump_o,
	perf_tbranch_o
);
	parameter [0:0] WritebackStage = 0;
	parameter [0:0] BranchPredictor = 0;
	input wire clk_i;
	input wire rst_ni;
	output reg ctrl_busy_o;
	input wire illegal_insn_i;
	input wire ecall_insn_i;
	input wire mret_insn_i;
	input wire dret_insn_i;
	input wire wfi_insn_i;
	input wire ebrk_insn_i;
	input wire csr_pipe_flush_i;
	input wire instr_valid_i;
	input wire [31:0] instr_i;
	input wire [15:0] instr_compressed_i;
	input wire instr_is_compressed_i;
	input wire instr_bp_taken_i;
	input wire instr_fetch_err_i;
	input wire instr_fetch_err_plus2_i;
	input wire [31:0] pc_id_i;
	output wire instr_valid_clear_o;
	output wire id_in_ready_o;
	output reg controller_run_o;
	output reg instr_req_o;
	output reg pc_set_o;
	output reg pc_set_spec_o;
	output reg [2:0] pc_mux_o;
	output reg nt_branch_mispredict_o;
	output reg [1:0] exc_pc_mux_o;
	output reg [5:0] exc_cause_o;
	input wire [31:0] lsu_addr_last_i;
	input wire load_err_i;
	input wire store_err_i;
	output wire wb_exception_o;
	input wire branch_set_i;
	input wire branch_set_spec_i;
	input wire branch_not_set_i;
	input wire jump_set_i;
	input wire csr_mstatus_mie_i;
	input wire irq_pending_i;
	input wire [17:0] irqs_i;
	input wire irq_nm_i;
	output wire nmi_mode_o;
	input wire debug_req_i;
	output reg [2:0] debug_cause_o;
	output reg debug_csr_save_o;
	output wire debug_mode_o;
	input wire debug_single_step_i;
	input wire debug_ebreakm_i;
	input wire debug_ebreaku_i;
	input wire trigger_match_i;
	output reg csr_save_if_o;
	output reg csr_save_id_o;
	output reg csr_save_wb_o;
	output reg csr_restore_mret_id_o;
	output reg csr_restore_dret_id_o;
	output reg csr_save_cause_o;
	output reg [31:0] csr_mtval_o;
	input wire [1:0] priv_mode_i;
	input wire csr_mstatus_tw_i;
	input wire stall_id_i;
	input wire stall_wb_i;
	output wire flush_id_o;
	input wire ready_wb_i;
	output reg perf_jump_o;
	output reg perf_tbranch_o;
	reg [3:0] ctrl_fsm_cs;
	reg [3:0] ctrl_fsm_ns;
	reg nmi_mode_q;
	reg nmi_mode_d;
	reg debug_mode_q;
	reg debug_mode_d;
	reg load_err_q;
	wire load_err_d;
	reg store_err_q;
	wire store_err_d;
	reg exc_req_q;
	wire exc_req_d;
	reg illegal_insn_q;
	wire illegal_insn_d;
	reg instr_fetch_err_prio;
	reg illegal_insn_prio;
	reg ecall_insn_prio;
	reg ebrk_insn_prio;
	reg store_err_prio;
	reg load_err_prio;
	wire stall;
	reg halt_if;
	reg retain_id;
	reg flush_id;
	wire illegal_dret;
	wire illegal_umode;
	wire exc_req_lsu;
	wire special_req;
	wire special_req_pc_change;
	wire special_req_flush_only;
	wire do_single_step_d;
	reg do_single_step_q;
	wire enter_debug_mode_prio_d;
	reg enter_debug_mode_prio_q;
	wire enter_debug_mode;
	wire ebreak_into_debug;
	wire handle_irq;
	wire id_wb_pending;
	reg [3:0] mfip_id;
	wire unused_irq_timer;
	wire ecall_insn;
	wire mret_insn;
	wire dret_insn;
	wire wfi_insn;
	wire ebrk_insn;
	wire csr_pipe_flush;
	wire instr_fetch_err;
	localparam [3:0] DECODE = 5;
	always @(negedge clk_i)
		if ((((ctrl_fsm_cs == DECODE) && instr_valid_i) && !instr_fetch_err_i) && illegal_insn_d)
			$display("%t: Illegal instruction (hart %0x) at PC 0x%h: 0x%h", $time, ibex_core.hart_id_i, ibex_id_stage.pc_id_i, ibex_id_stage.instr_rdata_i);
	assign load_err_d = load_err_i;
	assign store_err_d = store_err_i;
	assign ecall_insn = ecall_insn_i & instr_valid_i;
	assign mret_insn = mret_insn_i & instr_valid_i;
	assign dret_insn = dret_insn_i & instr_valid_i;
	assign wfi_insn = wfi_insn_i & instr_valid_i;
	assign ebrk_insn = ebrk_insn_i & instr_valid_i;
	assign csr_pipe_flush = csr_pipe_flush_i & instr_valid_i;
	assign instr_fetch_err = instr_fetch_err_i & instr_valid_i;
	assign illegal_dret = dret_insn & ~debug_mode_q;
	localparam [1:0] ibex_pkg_PRIV_LVL_M = 2'b11;
	assign illegal_umode = (priv_mode_i != ibex_pkg_PRIV_LVL_M) & (mret_insn | (csr_mstatus_tw_i & wfi_insn));
	localparam [3:0] FLUSH = 6;
	assign illegal_insn_d = ((illegal_insn_i | illegal_dret) | illegal_umode) & (ctrl_fsm_cs != FLUSH);
	assign exc_req_d = (((ecall_insn | ebrk_insn) | illegal_insn_d) | instr_fetch_err) & (ctrl_fsm_cs != FLUSH);
	assign exc_req_lsu = store_err_i | load_err_i;
	assign special_req_flush_only = wfi_insn | csr_pipe_flush;
	assign special_req_pc_change = ((mret_insn | dret_insn) | exc_req_d) | exc_req_lsu;
	assign special_req = special_req_pc_change | special_req_flush_only;
	assign id_wb_pending = instr_valid_i | ~ready_wb_i;
	generate
		if (WritebackStage) begin : g_wb_exceptions
			always @(*) begin
				instr_fetch_err_prio = 0;
				illegal_insn_prio = 0;
				ecall_insn_prio = 0;
				ebrk_insn_prio = 0;
				store_err_prio = 0;
				load_err_prio = 0;
				if (store_err_q)
					store_err_prio = 1'b1;
				else if (load_err_q)
					load_err_prio = 1'b1;
				else if (instr_fetch_err)
					instr_fetch_err_prio = 1'b1;
				else if (illegal_insn_q)
					illegal_insn_prio = 1'b1;
				else if (ecall_insn)
					ecall_insn_prio = 1'b1;
				else if (ebrk_insn)
					ebrk_insn_prio = 1'b1;
			end
			assign wb_exception_o = ((load_err_q | store_err_q) | load_err_i) | store_err_i;
		end
		else begin : g_no_wb_exceptions
			always @(*) begin
				instr_fetch_err_prio = 0;
				illegal_insn_prio = 0;
				ecall_insn_prio = 0;
				ebrk_insn_prio = 0;
				store_err_prio = 0;
				load_err_prio = 0;
				if (instr_fetch_err)
					instr_fetch_err_prio = 1'b1;
				else if (illegal_insn_q)
					illegal_insn_prio = 1'b1;
				else if (ecall_insn)
					ecall_insn_prio = 1'b1;
				else if (ebrk_insn)
					ebrk_insn_prio = 1'b1;
				else if (store_err_q)
					store_err_prio = 1'b1;
				else if (load_err_q)
					load_err_prio = 1'b1;
			end
			assign wb_exception_o = 1'b0;
		end
	endgenerate
	assign do_single_step_d = (instr_valid_i ? ~debug_mode_q & debug_single_step_i : do_single_step_q);
	assign enter_debug_mode_prio_d = (debug_req_i | do_single_step_d) & ~debug_mode_q;
	assign enter_debug_mode = enter_debug_mode_prio_d | (trigger_match_i & ~debug_mode_q);
	localparam [1:0] ibex_pkg_PRIV_LVL_U = 2'b00;
	assign ebreak_into_debug = (priv_mode_i == ibex_pkg_PRIV_LVL_M ? debug_ebreakm_i : (priv_mode_i == ibex_pkg_PRIV_LVL_U ? debug_ebreaku_i : 1'b0));
	assign handle_irq = (~debug_mode_q & ~nmi_mode_q) & (irq_nm_i | (irq_pending_i & csr_mstatus_mie_i));
	always @(*) begin : gen_mfip_id
		if (irqs_i[14])
			mfip_id = 4'd14;
		else if (irqs_i[13])
			mfip_id = 4'd13;
		else if (irqs_i[12])
			mfip_id = 4'd12;
		else if (irqs_i[11])
			mfip_id = 4'd11;
		else if (irqs_i[10])
			mfip_id = 4'd10;
		else if (irqs_i[9])
			mfip_id = 4'd9;
		else if (irqs_i[8])
			mfip_id = 4'd8;
		else if (irqs_i[7])
			mfip_id = 4'd7;
		else if (irqs_i[6])
			mfip_id = 4'd6;
		else if (irqs_i[5])
			mfip_id = 4'd5;
		else if (irqs_i[4])
			mfip_id = 4'd4;
		else if (irqs_i[3])
			mfip_id = 4'd3;
		else if (irqs_i[2])
			mfip_id = 4'd2;
		else if (irqs_i[1])
			mfip_id = 4'd1;
		else
			mfip_id = 4'd0;
	end
	assign unused_irq_timer = irqs_i[16];
	localparam [3:0] BOOT_SET = 1;
	localparam [3:0] DBG_TAKEN_ID = 9;
	localparam [3:0] DBG_TAKEN_IF = 8;
	localparam [3:0] FIRST_FETCH = 4;
	localparam [3:0] IRQ_TAKEN = 7;
	localparam [3:0] RESET = 0;
	localparam [3:0] SLEEP = 3;
	localparam [3:0] WAIT_SLEEP = 2;
	localparam [2:0] ibex_pkg_DBG_CAUSE_EBREAK = 3'h1;
	localparam [2:0] ibex_pkg_DBG_CAUSE_HALTREQ = 3'h3;
	localparam [2:0] ibex_pkg_DBG_CAUSE_STEP = 3'h4;
	localparam [2:0] ibex_pkg_DBG_CAUSE_TRIGGER = 3'h2;
	localparam [5:0] ibex_pkg_EXC_CAUSE_BREAKPOINT = 6'b000011;
	localparam [5:0] ibex_pkg_EXC_CAUSE_ECALL_MMODE = 6'b001011;
	localparam [5:0] ibex_pkg_EXC_CAUSE_ECALL_UMODE = 6'b001000;
	localparam [5:0] ibex_pkg_EXC_CAUSE_ILLEGAL_INSN = 6'b000010;
	localparam [5:0] ibex_pkg_EXC_CAUSE_INSN_ADDR_MISA = 6'b000000;
	localparam [5:0] ibex_pkg_EXC_CAUSE_INSTR_ACCESS_FAULT = 6'b000001;
	localparam [5:0] ibex_pkg_EXC_CAUSE_IRQ_EXTERNAL_M = 6'b101011;
	localparam [5:0] ibex_pkg_EXC_CAUSE_IRQ_NM = 6'b111111;
	localparam [5:0] ibex_pkg_EXC_CAUSE_IRQ_SOFTWARE_M = 6'b100011;
	localparam [5:0] ibex_pkg_EXC_CAUSE_IRQ_TIMER_M = 6'b100111;
	localparam [5:0] ibex_pkg_EXC_CAUSE_LOAD_ACCESS_FAULT = 6'b000101;
	localparam [5:0] ibex_pkg_EXC_CAUSE_STORE_ACCESS_FAULT = 6'b000111;
	localparam [1:0] ibex_pkg_EXC_PC_DBD = 2;
	localparam [1:0] ibex_pkg_EXC_PC_DBG_EXC = 3;
	localparam [1:0] ibex_pkg_EXC_PC_EXC = 0;
	localparam [1:0] ibex_pkg_EXC_PC_IRQ = 1;
	localparam [2:0] ibex_pkg_PC_BOOT = 0;
	localparam [2:0] ibex_pkg_PC_DRET = 4;
	localparam [2:0] ibex_pkg_PC_ERET = 3;
	localparam [2:0] ibex_pkg_PC_EXC = 2;
	localparam [2:0] ibex_pkg_PC_JUMP = 1;
	function automatic [5:0] sv2v_cast_6;
		input reg [5:0] inp;
		sv2v_cast_6 = inp;
	endfunction
	always @(*) begin
		instr_req_o = 1'b1;
		csr_save_if_o = 1'b0;
		csr_save_id_o = 1'b0;
		csr_save_wb_o = 1'b0;
		csr_restore_mret_id_o = 1'b0;
		csr_restore_dret_id_o = 1'b0;
		csr_save_cause_o = 1'b0;
		csr_mtval_o = {32 {1'sb0}};
		pc_mux_o = ibex_pkg_PC_BOOT;
		pc_set_o = 1'b0;
		pc_set_spec_o = 1'b0;
		nt_branch_mispredict_o = 1'b0;
		exc_pc_mux_o = ibex_pkg_EXC_PC_IRQ;
		exc_cause_o = ibex_pkg_EXC_CAUSE_INSN_ADDR_MISA;
		ctrl_fsm_ns = ctrl_fsm_cs;
		ctrl_busy_o = 1'b1;
		halt_if = 1'b0;
		retain_id = 1'b0;
		flush_id = 1'b0;
		debug_csr_save_o = 1'b0;
		debug_cause_o = ibex_pkg_DBG_CAUSE_EBREAK;
		debug_mode_d = debug_mode_q;
		nmi_mode_d = nmi_mode_q;
		perf_tbranch_o = 1'b0;
		perf_jump_o = 1'b0;
		controller_run_o = 1'b0;
		case (ctrl_fsm_cs)
			RESET: begin
				instr_req_o = 1'b0;
				pc_mux_o = ibex_pkg_PC_BOOT;
				pc_set_o = 1'b1;
				pc_set_spec_o = 1'b1;
				ctrl_fsm_ns = BOOT_SET;
			end
			BOOT_SET: begin
				instr_req_o = 1'b1;
				pc_mux_o = ibex_pkg_PC_BOOT;
				pc_set_o = 1'b1;
				pc_set_spec_o = 1'b1;
				ctrl_fsm_ns = FIRST_FETCH;
			end
			WAIT_SLEEP: begin
				ctrl_busy_o = 1'b0;
				instr_req_o = 1'b0;
				halt_if = 1'b1;
				flush_id = 1'b1;
				ctrl_fsm_ns = SLEEP;
			end
			SLEEP: begin
				instr_req_o = 1'b0;
				halt_if = 1'b1;
				flush_id = 1'b1;
				if ((((irq_nm_i || irq_pending_i) || debug_req_i) || debug_mode_q) || debug_single_step_i)
					ctrl_fsm_ns = FIRST_FETCH;
				else
					ctrl_busy_o = 1'b0;
			end
			FIRST_FETCH: begin
				if (id_in_ready_o)
					ctrl_fsm_ns = DECODE;
				if (handle_irq) begin
					ctrl_fsm_ns = IRQ_TAKEN;
					halt_if = 1'b1;
				end
				if (enter_debug_mode) begin
					ctrl_fsm_ns = DBG_TAKEN_IF;
					halt_if = 1'b1;
				end
			end
			DECODE: begin
				controller_run_o = 1'b1;
				pc_mux_o = ibex_pkg_PC_JUMP;
				if (special_req) begin
					retain_id = 1'b1;
					if (ready_wb_i | wb_exception_o)
						ctrl_fsm_ns = FLUSH;
				end
				if (branch_set_i || jump_set_i) begin
					pc_set_o = (BranchPredictor ? ~instr_bp_taken_i : 1'b1);
					perf_tbranch_o = branch_set_i;
					perf_jump_o = jump_set_i;
				end
				if (BranchPredictor)
					if (instr_bp_taken_i & branch_not_set_i)
						nt_branch_mispredict_o = 1'b1;
				if (branch_set_spec_i || jump_set_i)
					pc_set_spec_o = (BranchPredictor ? ~instr_bp_taken_i : 1'b1);
				if ((enter_debug_mode || handle_irq) && (stall || id_wb_pending))
					halt_if = 1'b1;
				if ((!stall && !special_req) && !id_wb_pending)
					if (enter_debug_mode) begin
						ctrl_fsm_ns = DBG_TAKEN_IF;
						halt_if = 1'b1;
					end
					else if (handle_irq) begin
						ctrl_fsm_ns = IRQ_TAKEN;
						halt_if = 1'b1;
					end
			end
			IRQ_TAKEN: begin
				pc_mux_o = ibex_pkg_PC_EXC;
				exc_pc_mux_o = ibex_pkg_EXC_PC_IRQ;
				if (handle_irq) begin
					pc_set_o = 1'b1;
					pc_set_spec_o = 1'b1;
					csr_save_if_o = 1'b1;
					csr_save_cause_o = 1'b1;
					if (irq_nm_i && !nmi_mode_q) begin
						exc_cause_o = ibex_pkg_EXC_CAUSE_IRQ_NM;
						nmi_mode_d = 1'b1;
					end
					else if (irqs_i[14-:15] != 15'b000000000000000)
						exc_cause_o = sv2v_cast_6({2'b11, mfip_id});
					else if (irqs_i[15])
						exc_cause_o = ibex_pkg_EXC_CAUSE_IRQ_EXTERNAL_M;
					else if (irqs_i[17])
						exc_cause_o = ibex_pkg_EXC_CAUSE_IRQ_SOFTWARE_M;
					else
						exc_cause_o = ibex_pkg_EXC_CAUSE_IRQ_TIMER_M;
				end
				ctrl_fsm_ns = DECODE;
			end
			DBG_TAKEN_IF: begin
				pc_mux_o = ibex_pkg_PC_EXC;
				exc_pc_mux_o = ibex_pkg_EXC_PC_DBD;
				flush_id = 1'b1;
				pc_set_o = 1'b1;
				pc_set_spec_o = 1'b1;
				csr_save_if_o = 1'b1;
				debug_csr_save_o = 1'b1;
				csr_save_cause_o = 1'b1;
				if (trigger_match_i)
					debug_cause_o = ibex_pkg_DBG_CAUSE_TRIGGER;
				else if (debug_single_step_i)
					debug_cause_o = ibex_pkg_DBG_CAUSE_STEP;
				else
					debug_cause_o = ibex_pkg_DBG_CAUSE_HALTREQ;
				debug_mode_d = 1'b1;
				ctrl_fsm_ns = DECODE;
			end
			DBG_TAKEN_ID: begin
				flush_id = 1'b1;
				pc_mux_o = ibex_pkg_PC_EXC;
				pc_set_o = 1'b1;
				pc_set_spec_o = 1'b1;
				exc_pc_mux_o = ibex_pkg_EXC_PC_DBD;
				if (ebreak_into_debug && !debug_mode_q) begin
					csr_save_cause_o = 1'b1;
					csr_save_id_o = 1'b1;
					debug_csr_save_o = 1'b1;
					debug_cause_o = ibex_pkg_DBG_CAUSE_EBREAK;
				end
				debug_mode_d = 1'b1;
				ctrl_fsm_ns = DECODE;
			end
			FLUSH: begin
				halt_if = 1'b1;
				flush_id = 1'b1;
				ctrl_fsm_ns = DECODE;
				if ((exc_req_q || store_err_q) || load_err_q) begin
					pc_set_o = 1'b1;
					pc_set_spec_o = 1'b1;
					pc_mux_o = ibex_pkg_PC_EXC;
					exc_pc_mux_o = (debug_mode_q ? ibex_pkg_EXC_PC_DBG_EXC : ibex_pkg_EXC_PC_EXC);
					if (WritebackStage) begin : g_writeback_mepc_save
						csr_save_id_o = ~(store_err_q | load_err_q);
						csr_save_wb_o = store_err_q | load_err_q;
					end
					else begin : g_no_writeback_mepc_save
						csr_save_id_o = 1'b0;
					end
					csr_save_cause_o = 1'b1;
					case (1'b1)
						instr_fetch_err_prio: begin
							exc_cause_o = ibex_pkg_EXC_CAUSE_INSTR_ACCESS_FAULT;
							csr_mtval_o = (instr_fetch_err_plus2_i ? pc_id_i + 32'd2 : pc_id_i);
						end
						illegal_insn_prio: begin
							exc_cause_o = ibex_pkg_EXC_CAUSE_ILLEGAL_INSN;
							csr_mtval_o = (instr_is_compressed_i ? {16'b0000000000000000, instr_compressed_i} : instr_i);
						end
						ecall_insn_prio: exc_cause_o = (priv_mode_i == ibex_pkg_PRIV_LVL_M ? ibex_pkg_EXC_CAUSE_ECALL_MMODE : ibex_pkg_EXC_CAUSE_ECALL_UMODE);
						ebrk_insn_prio:
							if (debug_mode_q | ebreak_into_debug) begin
								pc_set_o = 1'b0;
								pc_set_spec_o = 1'b0;
								csr_save_id_o = 1'b0;
								csr_save_cause_o = 1'b0;
								ctrl_fsm_ns = DBG_TAKEN_ID;
								flush_id = 1'b0;
							end
							else
								exc_cause_o = ibex_pkg_EXC_CAUSE_BREAKPOINT;
						store_err_prio: begin
							exc_cause_o = ibex_pkg_EXC_CAUSE_STORE_ACCESS_FAULT;
							csr_mtval_o = lsu_addr_last_i;
						end
						load_err_prio: begin
							exc_cause_o = ibex_pkg_EXC_CAUSE_LOAD_ACCESS_FAULT;
							csr_mtval_o = lsu_addr_last_i;
						end
						default:
							;
					endcase
				end
				else if (mret_insn) begin
					pc_mux_o = ibex_pkg_PC_ERET;
					pc_set_o = 1'b1;
					pc_set_spec_o = 1'b1;
					csr_restore_mret_id_o = 1'b1;
					if (nmi_mode_q)
						nmi_mode_d = 1'b0;
				end
				else if (dret_insn) begin
					pc_mux_o = ibex_pkg_PC_DRET;
					pc_set_o = 1'b1;
					pc_set_spec_o = 1'b1;
					debug_mode_d = 1'b0;
					csr_restore_dret_id_o = 1'b1;
				end
				else if (wfi_insn)
					ctrl_fsm_ns = WAIT_SLEEP;
				else if (csr_pipe_flush && handle_irq)
					ctrl_fsm_ns = IRQ_TAKEN;
				if (enter_debug_mode_prio_q && !(ebrk_insn_prio && ebreak_into_debug))
					ctrl_fsm_ns = DBG_TAKEN_IF;
			end
			default: begin
				instr_req_o = 1'b0;
				ctrl_fsm_ns = RESET;
			end
		endcase
	end
	assign flush_id_o = flush_id;
	assign debug_mode_o = debug_mode_q;
	assign nmi_mode_o = nmi_mode_q;
	assign stall = stall_id_i | stall_wb_i;
	assign id_in_ready_o = (~stall & ~halt_if) & ~retain_id;
	assign instr_valid_clear_o = ~(stall | retain_id) | flush_id;
	always @(posedge clk_i or negedge rst_ni) begin : update_regs
		if (!rst_ni) begin
			ctrl_fsm_cs <= RESET;
			nmi_mode_q <= 1'b0;
			do_single_step_q <= 1'b0;
			debug_mode_q <= 1'b0;
			enter_debug_mode_prio_q <= 1'b0;
			load_err_q <= 1'b0;
			store_err_q <= 1'b0;
			exc_req_q <= 1'b0;
			illegal_insn_q <= 1'b0;
		end
		else begin
			ctrl_fsm_cs <= ctrl_fsm_ns;
			nmi_mode_q <= nmi_mode_d;
			do_single_step_q <= do_single_step_d;
			debug_mode_q <= debug_mode_d;
			enter_debug_mode_prio_q <= enter_debug_mode_prio_d;
			load_err_q <= load_err_d;
			store_err_q <= store_err_d;
			exc_req_q <= exc_req_d;
			illegal_insn_q <= illegal_insn_d;
		end
	end
	wire fcov_interrupt_taken;
	assign fcov_interrupt_taken = (ctrl_fsm_cs != IRQ_TAKEN) & (ctrl_fsm_ns == IRQ_TAKEN);
	wire unused_fcov_interrupt_taken;
	assign unused_fcov_interrupt_taken = fcov_interrupt_taken;
	wire fcov_debug_entry_if;
	assign fcov_debug_entry_if = (ctrl_fsm_cs != DBG_TAKEN_IF) & (ctrl_fsm_ns == DBG_TAKEN_IF);
	wire unused_fcov_debug_entry_if;
	assign unused_fcov_debug_entry_if = fcov_debug_entry_if;
	wire fcov_debug_entry_id;
	assign fcov_debug_entry_id = (ctrl_fsm_cs != DBG_TAKEN_ID) & (ctrl_fsm_ns == DBG_TAKEN_ID);
	wire unused_fcov_debug_entry_id;
	assign unused_fcov_debug_entry_id = fcov_debug_entry_id;
	wire fcov_pipe_flush;
	assign fcov_pipe_flush = (ctrl_fsm_cs != FLUSH) & (ctrl_fsm_ns == FLUSH);
	wire unused_fcov_pipe_flush;
	assign unused_fcov_pipe_flush = fcov_pipe_flush;
	wire fcov_debug_req;
	assign fcov_debug_req = debug_req_i & ~debug_mode_q;
	wire unused_fcov_debug_req;
	assign unused_fcov_debug_req = fcov_debug_req;
	wire exception_req;
	reg exception_req_pending;
	reg exception_req_accepted;
	wire exception_req_done;
	wire exception_pc_set;
	reg seen_exception_pc_set;
	reg expect_exception_pc_set;
	wire exception_req_needs_pc_set;
	assign exception_req = (special_req | enter_debug_mode) | handle_irq;
	assign exception_req_done = (exception_req_pending & (ctrl_fsm_cs != DECODE)) & (ctrl_fsm_ns == DECODE);
	assign exception_req_needs_pc_set = (enter_debug_mode | handle_irq) | special_req_pc_change;
	assign exception_pc_set = exception_req_pending & (pc_set_o & |{pc_mux_o == ibex_pkg_PC_EXC, pc_mux_o == ibex_pkg_PC_ERET, pc_mux_o == ibex_pkg_PC_DRET});
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			exception_req_pending <= 1'b0;
			exception_req_accepted <= 1'b0;
			expect_exception_pc_set <= 1'b0;
			seen_exception_pc_set <= 1'b0;
		end
		else begin
			exception_req_pending <= (exception_req_pending | exception_req) & ~exception_req_done;
			exception_req_accepted <= (exception_req_accepted & ~exception_req_done) | (exception_req & (ctrl_fsm_ns != DECODE));
			expect_exception_pc_set <= (expect_exception_pc_set | exception_req_needs_pc_set) & ~exception_req_done;
			seen_exception_pc_set <= (seen_exception_pc_set | exception_pc_set) & ~exception_req_done;
		end
endmodule
