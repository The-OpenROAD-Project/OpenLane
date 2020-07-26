////////////////////////////////////////////////////////////////////////////////
//
//  XGATE Coprocessor - XGATE RISC Processor Core
//
//  Author: Bob Hayes
//          rehayes@opencores.org
//
//  Downloaded from: http://www.opencores.org/projects/xgate.....
//
////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2009, Robert Hayes
//
// This source file is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Supplemental terms.
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Neither the name of the <organization> nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY Robert Hayes ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL Robert Hayes BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
////////////////////////////////////////////////////////////////////////////////
// 45678901234567890123456789012345678901234567890123456789012345678901234567890

module xgate_risc #(parameter MAX_CHANNEL = 127)    // Max XGATE Interrupt Channel Number
 (
  output reg [15:0] xgr1,
  output reg [15:0] xgr2,
  output reg [15:0] xgr3,
  output reg [15:0] xgr4,
  output reg [15:0] xgr5,
  output reg [15:0] xgr6,
  output reg [15:0] xgr7,
  output     [15:0] xgate_address,
  output     [15:0] write_mem_data,   // Data for Memory write
  output            mem_access,       //
  output            write_mem_strb_l, // Strobe for writing low data byte
  output            write_mem_strb_h, // Strobe for writing high data bye
  output reg                 zero_flag,
  output reg                 negative_flag,
  output reg                 carry_flag,
  output reg                 overflow_flag,
  output reg          [ 6:0] xgchid,
  output reg         [127:1] xgif_status,   // XGATE Interrupt Flag
  output                     xg_sw_irq,     // Xgate Software interrupt
  output              [ 7:0] host_semap,    // Semaphore status for host
  output reg                 debug_active,  // Latch to control debug mode in the RISC state machine
  output                     debug_ack,     // Clear debug register
  output                     single_step,   // Pulse to trigger a single instruction execution in debug mode


  input      [15:0] read_mem_data,
  input      [15:0] perif_data,
  input             risc_clk,
  input             async_rst_b,
  input             mem_req_ack,    // Memory Bus available - data good
  input             ss_mem_ack,     // WISHBONE Bus has granted single step memory access
  input             xge,            // XGATE Module Enable
  input             debug_mode_i,   // Force RISC core into debug mode
  input             xgdbg_set,      // Enter XGATE Debug Mode, pulse
  input             xgdbg_clear,    // Leave XGATE Debug Mode
  input             xgss,           // XGATE Single Step
  input      [15:1] xgvbr,          // XGATE vector Base Address Register
  input      [ 6:0] int_req,        // Encoded interrupt request
  input             xgie,           // XGATE Interrupt Enable
  input             brk_irq_ena,    // Enable BRK instruction to generate interrupt
  input             write_xgchid,   // Write Strobe for XGCHID register
  input             write_xgsem,    // Write Strobe for XGSEM register
  input             write_xgccr,    // Write Strobe for XGATE Condition Code Register
  input      [ 1:0] write_xgpc,     // Write Strobe for XGATE Program Counter
  input      [ 1:0] write_xgr7,     // Write Strobe for XGATE Data Register R7
  input      [ 1:0] write_xgr6,     // Write Strobe for XGATE Data Register R6
  input      [ 1:0] write_xgr5,     // Write Strobe for XGATE Data Register R5
  input      [ 1:0] write_xgr4,     // Write Strobe for XGATE Data Register R4
  input      [ 1:0] write_xgr3,     // Write Strobe for XGATE Data Register R3
  input      [ 1:0] write_xgr2,     // Write Strobe for XGATE Data Register R2
  input      [ 1:0] write_xgr1,     // Write Strobe for XGATE Data Register R1
  input             xgsweif_c,      // Clear Software Flag
  input             clear_xgif_7,   // Strobe for decode to clear interrupt flag bank 7
  input             clear_xgif_6,   // Strobe for decode to clear interrupt flag bank 6
  input             clear_xgif_5,   // Strobe for decode to clear interrupt flag bank 5
  input             clear_xgif_4,   // Strobe for decode to clear interrupt flag bank 4
  input             clear_xgif_3,   // Strobe for decode to clear interrupt flag bank 3
  input             clear_xgif_2,   // Strobe for decode to clear interrupt flag bank 2
  input             clear_xgif_1,   // Strobe for decode to clear interrupt flag bank 1
  input             clear_xgif_0,   // Strobe for decode to clear interrupt flag bank 0
  input      [15:0] clear_xgif_data // Data for decode to clear interrupt flag
);

  integer j;     // Loop counters for decode of XGATE Interrupt Register
  integer k;     // Loop counter for Bit Field Insert decode
  integer bfi, bfii;   // Loop counter for Bit Field Insert function

  // State machine sequence
  localparam [3:0]      //synopsys enum state_info
       IDLE    = 4'b0000,      // waiting for interrupt
       CONT    = 4'b0001,      // Instruction processing state, first state
       S_STALL = 4'b0010,      // Simple Stall while updating PC after change of flow
       W_STORE = 4'b1101,      // Stall while doing memory word write access
       W_LOAD  = 4'b0011,      // Stall while doing memory word read access
       B_LOAD  = 4'b0100,      // Stall while doing memory byte read access
       BREAK   = 4'b0101,      // Stop in this state after BRK instruction
       BREAK_2 = 4'b0110,      // Advance PC after Single Step command
       LD_INST = 4'b0111,      // Load Instruction in Debug mode
       DEBUG   = 4'b1000,      // Stop in this state while waiting for debug commands
       BOOT_1  = 4'b1001,      //
       BOOT_2  = 4'b1010,      //
       BOOT_3  = 4'b1011,      //
       CHG_CHID = 4'b1100;


  // Semaphore states
  localparam [1:0] NO_LOCK   = 2'b00,
                   RISC_LOCK = 2'b10,
                   HOST_LOCK = 2'b11;


  reg  [ 3:0] cpu_state;         // State register for instruction processing
  reg  [ 3:0] next_cpu_state;    // Pseudo Register,
  wire        stm_auto_advance;  // State Machine increment without wait state holdoff
  reg         load_next_inst;    // Pseudo Register,
  reg  [15:0] program_counter;   // Program Counter register
  wire [15:0] pc_sum;            // Program Counter Adder
  reg  [15:0] pc_incr_mux;       // Pseudo Register, mux to select the Program Counter Increment value
  reg  [15:0] next_pc;           // Pseudo Register
  wire [15:0] jump_offset;       // Address offset to be added to pc on conditional branch instruction
  wire [15:0] bra_offset;        // Address offset to be added to pc on branch always instruction
  wire        pc_carry;          // Carry out bit from pc adder
  wire        pc_overflow;       // Next pc is out-of-range
  wire        pc_underflow;      // Next pc is out-of-range
  wire        pc_error;          // Next pc calculation error
  reg  [15:0] alu_result;        // Pseudo Register,
  reg  [15:0] op_code;           // Register for instruction being executed
  reg         ena_rd_low_byte;   // Pseudo Register,
  reg         ena_rd_high_byte;  // Pseudo Register,

  reg         data_access;    // Pseudo Register, RAM access in proccess
  reg         data_write;     // Pseudo Register, RAM access is write operation
  reg         data_word_op;   // Pseudo Register, RAM access operation is 16 bits(word)
  reg  [15:0] data_address;   // Pseudo Register, Address for RAM data read or write
  reg  [15:0] load_data;      // Data captured from WISHBONE Master bus for Load instructions

  reg  [ 6:0] set_irq_flag;   // Pseudo Register, pulse for setting irq output register

  reg         next_zero;      // Pseudo Register,
  reg         next_negative;  // Pseudo Register,
  reg         next_carry;     // Pseudo Register,
  reg         next_overflow;  // Pseudo Register,

  reg         op_code_error;  // Pseudo Register,
  reg         software_error; // OP Code error, Address Error, BRK Error
  wire        addr_error;     // Decode Addressing error

  reg         set_semaph;     // Pseudo Register,
  reg         clear_semaph;   // Pseudo Register,
  reg  [ 2:0] semaph_risc;    // Pseudo Register,
  reg  [ 7:0] semap_risc_bit; // Pseudo Register,
  wire [ 7:0] risc_semap;     // Semaphore status bit for RISC
  wire        semaph_stat;    // Return Status of Semaphore bit

  reg  [15:0] rd_data;        // Pseudo Register,
  reg  [15:0] rs1_data;       // Pseudo Register,
  reg  [15:0] rs2_data;       // Pseudo Register,

  wire [ 2:0] wrt_reg_sel;
  reg         sel_rd_field;   // Pseudo Register,
  reg         wrt_sel_xgr1;   // Pseudo Register,
  reg         wrt_sel_xgr2;   // Pseudo Register,
  reg         wrt_sel_xgr3;   // Pseudo Register,
  reg         wrt_sel_xgr4;   // Pseudo Register,
  reg         wrt_sel_xgr5;   // Pseudo Register,
  reg         wrt_sel_xgr6;   // Pseudo Register,
  reg         wrt_sel_xgr7;   // Pseudo Register,

  reg [127:1] xgif_d;

  reg  [15:0] shift_in;
  wire [15:0] shift_out;
  wire        shift_rollover;
  reg         shift_left;
  reg  [ 4:0] shift_ammount;
  reg  [15:0] shift_filler;
  reg  [15:0] bf_mux_mask;   // Mask for controlling mux's in Bit Field Insert Instructions

  wire        start_thread;  // Signal to pop RISC core out of IDLE State

  wire        cpu_is_idle;   // Processor is in the IDLE state
  wire        perif_wrt_ena; // Enable for Salve writes to CPU registers

  reg         xgss_edge;     // Flop for edge detection
  reg         brk_set_dbg;   // Pulse to set debug_active from instruction decoder
  reg         cmd_change_pc; // Debug write to PC register
  reg         debug_edge;    // Reg for edge detection

  reg         cmd_dbg;

  reg  [ 1:0] chid_sm_ns;    // Pseudo Register for State Machine next state logic,
  reg  [ 1:0] chid_sm;       //
  wire        chid_goto_idle; //

  // Debug states for change CHID
  localparam [1:0] CHID_IDLE = 2'b00,
                   CHID_TEST = 2'b10,
                   CHID_WAIT = 2'b11;


  assign jump_offset  = {{6{op_code[8]}}, op_code[8:0], 1'b0};
  assign bra_offset   = {{5{op_code[9]}}, op_code[9:0], 1'b0};
  assign pc_overflow  = pc_carry & !pc_incr_mux[15];
  assign pc_underflow = !pc_carry & pc_incr_mux[15];
  assign pc_error     = (pc_overflow || pc_underflow) & (cpu_state != BOOT_2);

  assign {pc_carry, pc_sum} = program_counter + pc_incr_mux;

  assign xgate_address = data_access ? data_address : program_counter;

  //assign mem_access = data_access || load_next_inst || start_thread;
  assign mem_access = data_access || load_next_inst || (cpu_state == CONT) ||
                     (cpu_state == BREAK_2)  || start_thread;

  // Generate an address for an op code fetch from an odd address or a word Load/Store from/to an odd address.
  assign addr_error = xgate_address[0] && (load_next_inst || (data_access && data_word_op));

  assign write_mem_strb_l = data_access && data_write && (data_word_op || !data_address[0]);
  assign write_mem_strb_h = data_access && data_write && (data_word_op ||  data_address[0]);
  assign write_mem_data   = (write_mem_strb_l || write_mem_strb_h) ? rd_data : 16'b0;

  assign start_thread = xge && (|int_req) && !debug_active;

  assign cpu_is_idle = (cpu_state == IDLE);
  assign perif_wrt_ena = (cpu_is_idle && ~xge) || debug_active;

  // Decode register select for RD and RS
  always @*
      case (op_code[10:8]) // synopsys parallel_case
        3'b001 : rd_data = xgr1;
        3'b010 : rd_data = xgr2;
        3'b011 : rd_data = xgr3;
        3'b100 : rd_data = xgr4;
        3'b101 : rd_data = xgr5;
        3'b110 : rd_data = xgr6;
        3'b111 : rd_data = xgr7;
        default : rd_data = 16'h0;  // XGR0 is always Zero
      endcase

  assign wrt_reg_sel = (cpu_state == BOOT_3) ? 3'b001 :
                       (sel_rd_field ? op_code[10:8] : op_code[4:2]);

  // Decode register write select for eather RD or RI/RS2
  always @*
    begin
      wrt_sel_xgr1 = (wrt_reg_sel == 3'b001) && mem_req_ack;
      wrt_sel_xgr2 = (wrt_reg_sel == 3'b010) && mem_req_ack;
      wrt_sel_xgr3 = (wrt_reg_sel == 3'b011) && mem_req_ack;
      wrt_sel_xgr4 = (wrt_reg_sel == 3'b100) && mem_req_ack;
      wrt_sel_xgr5 = (wrt_reg_sel == 3'b101) && mem_req_ack;
      wrt_sel_xgr6 = (wrt_reg_sel == 3'b110) && mem_req_ack;
      wrt_sel_xgr7 = (wrt_reg_sel == 3'b111) && mem_req_ack;
    end

  // Decode register select for RS1 and RB
  always @*
    case (op_code[7:5])  // synopsys parallel_case
      3'b001 : rs1_data = xgr1;
      3'b010 : rs1_data = xgr2;
      3'b011 : rs1_data = xgr3;
      3'b100 : rs1_data = xgr4;
      3'b101 : rs1_data = xgr5;
      3'b110 : rs1_data = xgr6;
      3'b111 : rs1_data = xgr7;
      default : rs1_data = 16'h0;  // XGR0 is always Zero
    endcase

  // Decode register select for RS2 and RI
  always @*
    case (op_code[4:2])  // synopsys parallel_case
      3'b001 : rs2_data = xgr1;
      3'b010 : rs2_data = xgr2;
      3'b011 : rs2_data = xgr3;
      3'b100 : rs2_data = xgr4;
      3'b101 : rs2_data = xgr5;
      3'b110 : rs2_data = xgr6;
      3'b111 : rs2_data = xgr7;
      default : rs2_data = 16'h0;  // XGR0 is always Zero
    endcase

  // Decode mux select mask for Bit Field Insert Instructions
  always @*
    begin
      k = 0;
      while (k < 16)
        begin
          bf_mux_mask[k] = 1'b0;
          if ((k >= rs2_data[3:0]) && (k <= rs2_data[3:0] + rs2_data[7:4]))
            bf_mux_mask[k] = 1'b1;
          k = k + 1;
        end
    end

  //  Software Error Interrupt Latch
  always @(posedge risc_clk or negedge async_rst_b)
    if ( !async_rst_b )
      software_error <= 1'b0;
    else
      software_error <= addr_error || op_code_error || pc_error ||
                        (brk_set_dbg && brk_irq_ena) || (software_error && !xgsweif_c);

  assign xg_sw_irq = software_error && xgie;

  //  Latch the need to go to debug state set by xgdb
  always @(posedge risc_clk or negedge async_rst_b)
    if ( !async_rst_b )
      begin
        cmd_dbg  <= 1'b0;
      end
    else
      begin
        cmd_dbg  <= !((cpu_state == LD_INST) || (cpu_state == DEBUG)) &&
               (cmd_dbg || (xgdbg_set && mem_req_ack && (next_cpu_state == CONT)));
      end

  //  Latch the debug state, set by eather xgdb or BRK instructions
  always @(posedge risc_clk or negedge async_rst_b)
    if ( !async_rst_b )
      begin
        debug_active  <= 1'b0;
        debug_edge    <= 0;
      end
    else
      begin
        debug_active  <= !xgdbg_clear && (cmd_dbg || pc_error ||
                         brk_set_dbg || op_code_error || debug_active);
        debug_edge    <= debug_active;
      end

  assign debug_ack = debug_active && !debug_edge; // Posedge of debug_active

  //  Convert xgss (Single Step Pulse) to a one risc_clk wide pulse
  always @(posedge risc_clk or negedge async_rst_b)
    if ( !async_rst_b )
      xgss_edge  <= 1'b0;
    else
      xgss_edge  <= xgss;

  assign single_step = (xgss && !xgss_edge) || (!debug_active && debug_edge);

  assign stm_auto_advance = (chid_sm != CHID_IDLE);

  //  CPU State Register
  always @(posedge risc_clk or negedge async_rst_b)
    if ( !async_rst_b )
      cpu_state  <= IDLE;
    else
      cpu_state  <= (mem_req_ack || stm_auto_advance || ~xge) ? next_cpu_state : cpu_state;

  //  CPU Instruction Register
  always @(posedge risc_clk or negedge async_rst_b)
    if ( !async_rst_b )
      op_code  <= 16'h0000;
    else
      op_code  <= (load_next_inst && mem_req_ack) ? read_mem_data : op_code;

  //  Active Channel Latch
  always @(posedge risc_clk or negedge async_rst_b)
    if ( !async_rst_b )
      xgchid  <= 7'b0;
    else
      xgchid  <= (write_xgchid && debug_active) ? perif_data[6:0] : (cpu_is_idle ? int_req : xgchid);

  //  Channel Change Debug state machine register
  always @(posedge risc_clk or negedge async_rst_b)
    if ( !async_rst_b )
      chid_sm  <= CHID_IDLE;
    else
      chid_sm  <= chid_sm_ns;

  //  Channel Change Debug next state
  always @*
    case (chid_sm)  // synopsys parallel_case
      CHID_IDLE:
        if ( write_xgchid && debug_active )
          chid_sm_ns  = CHID_TEST;
        else
          chid_sm_ns  = CHID_IDLE;
      CHID_TEST:
        if ( !((cpu_state == IDLE) || (cpu_state == CHG_CHID)) && (|xgchid) )
          chid_sm_ns  = CHID_IDLE;
        else
          chid_sm_ns  = CHID_WAIT;
      CHID_WAIT:
        if ( (cpu_state == IDLE) || (cpu_state == CHG_CHID) )
          chid_sm_ns  = CHID_IDLE;
        else
          chid_sm_ns  = CHID_WAIT;
      default : chid_sm_ns  = CHID_IDLE;
    endcase

  assign chid_goto_idle = (chid_sm == CHID_WAIT);

  //  CPU Read Data Buffer Register
  always @(posedge risc_clk or negedge async_rst_b)
    if ( !async_rst_b )
      load_data  <= 16'h0000;
    else
      load_data  <= (data_access && !data_write && mem_req_ack) ? read_mem_data : load_data;

  //  Program Counter Register
  always @(posedge risc_clk or negedge async_rst_b)
    if ( !async_rst_b )
      program_counter  <= 16'h0000;
    else
      program_counter  <= (|write_xgpc && perif_wrt_ena) ?
      {(write_xgpc[1] ? perif_data[15:8]: program_counter[15:8]),
       (write_xgpc[0] ? perif_data[ 7:0]: program_counter[ 7:0])} :
      (mem_req_ack ? next_pc : program_counter);

  //  Debug Change Program Counter Register
  always @(posedge risc_clk or negedge async_rst_b)
    if ( !async_rst_b )
      cmd_change_pc  <= 1'b0;
    else
      cmd_change_pc  <= (|write_xgpc && perif_wrt_ena) || (cmd_change_pc && !mem_req_ack);

  //  ALU Flag Bits
  always @(posedge risc_clk or negedge async_rst_b)
    if ( !async_rst_b )
      begin
        carry_flag    <= 1'b0;
        overflow_flag <= 1'b0;
        zero_flag     <= 1'b0;
        negative_flag <= 1'b0;
      end
    else
      begin
        carry_flag    <= (write_xgccr && perif_wrt_ena) ? perif_data[0] : (mem_req_ack ? next_carry : carry_flag);
        overflow_flag <= (write_xgccr && perif_wrt_ena) ? perif_data[1] : (mem_req_ack ? next_overflow : overflow_flag);
        zero_flag     <= (write_xgccr && perif_wrt_ena) ? perif_data[2] : (mem_req_ack ? next_zero : zero_flag);
        negative_flag <= (write_xgccr && perif_wrt_ena) ? perif_data[3] : (mem_req_ack ? next_negative : negative_flag);
      end

  //  Interrupt Flag next value
  always @*
    begin
      xgif_d = 0;
      j = 1;
      while (j <= MAX_CHANNEL)  // while loop sets irq bit and maintains previously set bits
        begin
         xgif_d[j]  = xgif_status[j] || (set_irq_flag == j);
         j = j + 1;
        end
      if (clear_xgif_0)
        xgif_d[15: 1]  = ~clear_xgif_data[15:1] & xgif_status[15:1];
      if (clear_xgif_1)
        xgif_d[31:16]  = ~clear_xgif_data & xgif_status[31:16];
      if (clear_xgif_2)
        xgif_d[47:32]  = ~clear_xgif_data & xgif_status[47:32];
      if (clear_xgif_3)
        xgif_d[63:48]  = ~clear_xgif_data & xgif_status[63:48];
      if (clear_xgif_4)
        xgif_d[79:64]  = ~clear_xgif_data & xgif_status[79:64];
      if (clear_xgif_5)
        xgif_d[95:80]  = ~clear_xgif_data & xgif_status[95:80];
      if (clear_xgif_6)
        xgif_d[111:96]  = ~clear_xgif_data & xgif_status[111:96];
      if (clear_xgif_7)
        xgif_d[127:112] = ~clear_xgif_data & xgif_status[127:112];
    end

  //  Interrupt Flag Registers
  always @(posedge risc_clk or negedge async_rst_b)
    if ( !async_rst_b )
      xgif_status  <= 0;
    else
      xgif_status  <= xgif_d;


  //  RISC Data Registers
  always @(posedge risc_clk or negedge async_rst_b)
    if ( !async_rst_b )
      begin
        xgr1 <= 16'b0;
        xgr2 <= 16'b0;
        xgr3 <= 16'b0;
        xgr4 <= 16'b0;
        xgr5 <= 16'b0;
        xgr6 <= 16'b0;
        xgr7 <= 16'b0;
      end
    else
      begin
        xgr1 <= (|write_xgr1 && perif_wrt_ena) ?
                {(write_xgr1[1] ? perif_data[15:8]: xgr1[15:8]),
                 (write_xgr1[0] ? perif_data[ 7:0]: xgr1[ 7:0])} :
                {((wrt_sel_xgr1 && ena_rd_high_byte) ? alu_result[15:8] : xgr1[15:8]),
                 ((wrt_sel_xgr1 && ena_rd_low_byte)  ? alu_result[ 7:0] : xgr1[ 7:0])};
        xgr2 <= (|write_xgr2 && perif_wrt_ena) ?
                {(write_xgr2[1] ? perif_data[15:8]: xgr2[15:8]),
                 (write_xgr2[0] ? perif_data[ 7:0]: xgr2[ 7:0])} :
                {((wrt_sel_xgr2 && ena_rd_high_byte) ? alu_result[15:8] : xgr2[15:8]),
                 ((wrt_sel_xgr2 && ena_rd_low_byte)  ? alu_result[ 7:0] : xgr2[ 7:0])};
        xgr3 <= (|write_xgr3 && perif_wrt_ena) ?
                {(write_xgr3[1] ? perif_data[15:8]: xgr3[15:8]),
                 (write_xgr3[0] ? perif_data[ 7:0]: xgr3[ 7:0])} :
                {((wrt_sel_xgr3 && ena_rd_high_byte) ? alu_result[15:8] : xgr3[15:8]),
                 ((wrt_sel_xgr3 && ena_rd_low_byte)  ? alu_result[ 7:0] : xgr3[ 7:0])};
        xgr4 <= (|write_xgr4 && perif_wrt_ena) ?
                {(write_xgr4[1] ? perif_data[15:8]: xgr4[15:8]),
                 (write_xgr4[0] ? perif_data[ 7:0]: xgr4[ 7:0])} :
                {((wrt_sel_xgr4 && ena_rd_high_byte) ? alu_result[15:8] : xgr4[15:8]),
                 ((wrt_sel_xgr4 && ena_rd_low_byte)  ? alu_result[ 7:0] : xgr4[ 7:0])};
        xgr5 <= (|write_xgr5 && perif_wrt_ena) ?
                {(write_xgr5[1] ? perif_data[15:8]: xgr5[15:8]),
                 (write_xgr5[0] ? perif_data[ 7:0]: xgr5[ 7:0])} :
                {((wrt_sel_xgr5 && ena_rd_high_byte) ? alu_result[15:8] : xgr5[15:8]),
                 ((wrt_sel_xgr5 && ena_rd_low_byte)  ? alu_result[ 7:0] : xgr5[ 7:0])};
        xgr6 <= (|write_xgr6 && perif_wrt_ena) ?
                {(write_xgr6[1] ? perif_data[15:8]: xgr6[15:8]),
                 (write_xgr6[0] ? perif_data[ 7:0]: xgr6[ 7:0])} :
                {((wrt_sel_xgr6 && ena_rd_high_byte) ? alu_result[15:8] : xgr6[15:8]),
                 ((wrt_sel_xgr6 && ena_rd_low_byte)  ? alu_result[ 7:0] : xgr6[ 7:0])};
        xgr7 <= (|write_xgr7 && perif_wrt_ena) ?
                {(write_xgr7[1] ? perif_data[15:8]: xgr7[15:8]),
                 (write_xgr7[0] ? perif_data[ 7:0]: xgr7[ 7:0])} :
                {((wrt_sel_xgr7 && ena_rd_high_byte) ? alu_result[15:8] : xgr7[15:8]),
                 ((wrt_sel_xgr7 && ena_rd_low_byte)  ? alu_result[ 7:0] : xgr7[ 7:0])};
      end

  // V - Vector fetch: always an aligned word read, lasts for at least one RISC core cycle
  // P - Program word fetch: always an aligned word read, lasts for at least one RISC core cycle
  // r - 8-bit data read: lasts for at least one RISC core cycle
  // R - 16-bit data read: lasts for at least one RISC core cycle
  // w - 8-bit data write: lasts for at least one RISC core cycle
  // W - 16-bit data write: lasts for at least one RISC core cycle
  // A - Alignment cycle: no read or write, lasts for zero or one RISC core cycles
  // f - Free cycle: no read or write, lasts for one RISC core cycles
  // Special Cases
  // PP/P - Branch: PP if branch taken, P if not taken

  always @*
    begin
      ena_rd_low_byte  = 1'b0;
      ena_rd_high_byte = 1'b0;

      next_cpu_state = (debug_active || cmd_dbg) ? LD_INST : CONT;
      load_next_inst = 1'b1;
      pc_incr_mux    = cmd_dbg ? 16'h0000: 16'h0002;  // Verilog Instruction order dependent
      next_pc        = pc_sum;    // ""

      next_zero      = zero_flag;
      next_negative  = negative_flag;
      next_carry     = carry_flag;
      next_overflow  = overflow_flag;

      brk_set_dbg    = 1'b0;
      op_code_error  = 1'b0;

      alu_result     = 16'h0000;
      sel_rd_field   = 1'b1;

      data_access    = 1'b0;
      data_word_op   = 1'b0;
      data_write     = 1'b0;
      data_address   = 16'h0000;

      shift_left     = 1'b0;
      shift_ammount  = 5'b0_0000;
      shift_filler   = 16'h0000;
      shift_in       = rd_data;

      set_irq_flag   = 7'b0;

      set_semaph     = 1'b0;
      clear_semaph   = 1'b0;
      semaph_risc    = 3'b0;

  casez ({cpu_state, op_code})

      {IDLE, 16'b????????????????} :
         begin
           next_cpu_state   = start_thread ? BOOT_1 : IDLE;
           pc_incr_mux      = 16'h0000;
           next_pc          = pc_sum;
           load_next_inst   = 1'b0;
         end

      {CHG_CHID, 16'b????????????????} :
         begin
           if (!xge)
             next_cpu_state = IDLE;
           else if (ss_mem_ack || !debug_active)
             next_cpu_state = BOOT_1;
           else
             next_cpu_state = CHG_CHID;

           pc_incr_mux      = 16'h0000;
           next_pc          = pc_sum;
           load_next_inst   = 1'b0;
         end

      // Output RAM address for Program Counter
      {BOOT_1, 16'b????????????????} :
         begin
           next_cpu_state   = BOOT_2;
           pc_incr_mux      = 16'h0000;
           next_pc          = pc_sum;
           load_next_inst   = 1'b0;
           data_access      = 1'b1;
           data_word_op     = 1'b1;
           data_address     = {xgvbr, 1'b0} + {7'b0, xgchid, 2'b0};
         end

      // Load PC value from data buffer register
      // Output RAM address for initial variable pointer
      {BOOT_2, 16'b????????????????} :
         begin
           next_cpu_state   = BOOT_3;
           next_pc          = load_data;
           load_next_inst   = 1'b0;
           data_access      = 1'b1;
           data_word_op     = 1'b1;
           data_address     = {xgvbr, 1'b0} + {7'b0, xgchid, 2'b0} + 2;
         end

      // Load R1 with initial variable pointer from data buffer register
      // Load first instruction to op_code register
      // Increment Program Counter
      {BOOT_3, 16'b????????????????} :
         begin
           next_cpu_state   = CONT;
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
           alu_result       = load_data;
         end

      {BREAK, 16'b????????????????} :
         begin
           if (!xge)
                   next_cpu_state = IDLE;
           else if (ss_mem_ack || !debug_active)
                   next_cpu_state = BREAK_2;
           else if (chid_goto_idle)
                   next_cpu_state = CHG_CHID;
           else
                   next_cpu_state = BREAK;
           load_next_inst = 1'b0;
           pc_incr_mux    = 16'h0000;
           next_pc        = pc_sum;
         end

      {BREAK_2, 16'b????????????????} :
         begin
           next_cpu_state = LD_INST;
           load_next_inst = 1'b0;
         end

      {LD_INST, 16'b????????????????} :
         begin
           next_cpu_state = DEBUG;
           pc_incr_mux    = 16'h0000;
           next_pc        = pc_sum;
         end

      {DEBUG, 16'b????????????????} :
         begin
           if (!xge)
                   next_cpu_state = IDLE;
           else if (ss_mem_ack || !debug_active)
                   next_cpu_state = CONT;
           else if (cmd_change_pc)
                   next_cpu_state = LD_INST;
           else if (chid_goto_idle)
                   next_cpu_state = CHG_CHID;
           else
                   next_cpu_state = DEBUG;

           load_next_inst = cmd_change_pc;
           pc_incr_mux    = 16'h0000;
           next_pc        = pc_sum;
         end

      // Pause here for program counter change of flow or memory write access
      //  Load next instruction and increment PC
      // Default next_cpu_state is CONT
      {S_STALL, 16'b????????????????} :
         begin
         end

      // Pause here for memory read word access
      //  Load next instruction and increment PC
      {W_LOAD, 16'b????????????????} :
         begin
           alu_result       = load_data;
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
         end

      // Pause here for memory read byte access
      //  Load next instruction and increment PC
      {B_LOAD, 16'b????????????????} :
         begin
           alu_result       = {8'h00, load_data[15:8]};
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
         end

      // -----------------------------------------------------------------------
      // Instruction Group -- Return to Scheduler and Others
      // -----------------------------------------------------------------------

      // Instruction = BRK, Op Code =  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
      // Cycles - PAff
      {CONT, 16'b0000000000000000} :
         begin
           next_cpu_state   = BREAK;
           pc_incr_mux      = 16'hfffe;  // equals -2
           next_pc          = pc_sum;
           load_next_inst   = 1'b0;
           brk_set_dbg      = 1'b1;
         end

      // Instruction = NOP, Op Code =  0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0
      {CONT, 16'b0000000100000000} :
         begin
         end

      // Instruction = RTS, Op Code =  0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0
      // Cycles - PA
      {CONT, 16'b0000001000000000} :
         begin
           next_cpu_state   = IDLE;
           pc_incr_mux      = 16'h0000;
           next_pc          = pc_sum;
           load_next_inst   = 1'b0;
         end

      // Instruction = SIF, Op Code =  0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0
      // Sets the Interrupt Flag of the current channel (XGCHID) will be set.
      // Cycles - PA
      {CONT, 16'b0000001100000000} :
         begin
           set_irq_flag = xgchid;
         end

      // -----------------------------------------------------------------------
      // Instruction Group -- Semaphore Instructions
      // -----------------------------------------------------------------------

      // Instruction = CSEM IMM3, Op Code =  0 0 0 0 0 IMM3 1 1 1 1 0 0 0 0
      // Unlocks a semaphore that was locked by the RISC core.
      // Cycles - PA
      {CONT, 16'b00000???11110000} :
         begin
           clear_semaph = 1'b1;
           semaph_risc  = op_code[10:8];
         end

      // Instruction = CSEM RS, Op Code =  0 0 0 0 0 RS 1 1 1 1 0 0 0 1
      // Unlocks a semaphore that was locked by the RISC core.
      // In monadic address mode, bits RS[2:0] select the semaphore to be cleared.
      // Cycles - PA
      {CONT, 16'b00000???11110001} :
         begin
           clear_semaph = 1'b1;
           semaph_risc  = rd_data[2:0];
         end

      // Instruction = SSEM IMM3, Op Code =  0 0 0 0 0 IMM3 1 1 1 1 0 0 1 0
      // Attempts to set a semaphore. The state of the semaphore will be stored in the Carry-Flag:
      // 1 = Semaphore is locked by the RISC core
      // 0 = Semaphore is locked by the S12X_CPU
      // Cycles - PA
      {CONT, 16'b00000???11110010} :
         begin
           set_semaph  = 1'b1;
           semaph_risc = op_code[10:8];

           next_carry  = semaph_stat;
         end

      // Instruction = SSEM RS, Op Code =  0 0 0 0 0 RS 1 1 1 1 0 0 1 1
      // Attempts to set a semaphore. The state of the semaphore will be stored in the Carry-Flag:
      // 1 = Semaphore is locked by the RISC core
      // 0 = Semaphore is locked by the S12X_CPU
      // In monadic address mode, bits RS[2:0] select the semaphore to be set.
      // Cycles - PA
      {CONT, 16'b00000???11110011} :
         begin
           set_semaph  = 1'b1;
           semaph_risc = rd_data[2:0];

           next_carry  = semaph_stat;
         end

      // -----------------------------------------------------------------------
      // Instruction Group -- Single Register Instructions
      // -----------------------------------------------------------------------

      // Instruction = SEX RD, Op Code =  0 0 0 0 0 RD 1 1 1 1 0 1 0 0
      // SEX - Sign Extend Byte to Word
      // Cycles - P
      {CONT, 16'b00000???11110100} :
         begin
           ena_rd_high_byte = 1'b1;

           alu_result    = {{8{rd_data[7]}}, rd_data[7:0]};
           next_zero     = !(|alu_result);
           next_negative = alu_result[15];
           next_overflow = 1'b0;
         end

      // Instruction = PAR RD, Op Code =  0 0 0 0 0 RD 1 1 1 1 0 1 0 1
      // PAR - Calculate Parity
      // Set Carry Flag on odd number of bits
      // Cycles - P
      {CONT, 16'b00000???11110101} :
         begin
           next_zero     = !(|rd_data);
           next_negative = 1'b0;
           next_carry    = ^rd_data;
           next_overflow = 1'b0;
         end

      // Instruction = JAL RD, Op Code =  0 0 0 0 0 RD 1 1 1 1 0 1 1 0
      // Jump And Link
      // PC + $0002 => RD; RD => PC
      // Jumps to the address stored in RD and saves the return address in RD.
      // Cycles - PP
      {CONT, 16'b00000???11110110} :
         begin
           next_cpu_state   = S_STALL;
           load_next_inst   = 1'b0;
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
           alu_result       = program_counter;
           next_pc          = rd_data;
         end

      // Instruction = SIF RS, Op Code =  0 0 0 0 0 RS 1 1 1 1 0 1 1 1
      // Sets the Interrupt Flag associated with the channel id number
      // contained in RS[6:0] is set. The content of RS[15:7] is ignored
      // Cycles - P
      {CONT, 16'b00000???11110111} :
         set_irq_flag = rd_data[6:0];

      // -----------------------------------------------------------------------
      // Instruction Group -- Special Move instructions
      // -----------------------------------------------------------------------

      // Instruction = TFR RD,CCR, Op Code =  0 0 0 0 0 RD 1 1 1 1 1 0 0 0
      // Transfer from and to Special Registers
      // TFR RD,CCR: CCR => RD[3:0], 0 => RD[15:4]
      // Cycles - P
      {CONT, 16'b00000???11111000} :
         begin
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
           alu_result       = {12'b0, negative_flag, zero_flag, overflow_flag, carry_flag};
         end

      // Instruction = TFR CCR,RS, Op Code =  0 0 0 0 0 RS 1 1 1 1 1 0 0 1
      // Transfer from and to Special Registers
      // TFR CCR,RD: RD[3:0] => CCR
      // Cycles - P
      {CONT, 16'b00000???11111001} :
         begin
           next_negative = rd_data[3];
           next_zero     = rd_data[2];
           next_overflow = rd_data[1];
           next_carry    = rd_data[0];
         end

      // Instruction = TFR RD,PC, Op Code =  0 0 0 0 0 RD 1 1 1 1 1 0 1 0
      // Transfer from and to Special Registers
      // TFR RD,PC: PC+4 => RD
      // Cycles - P
      {CONT, 16'b00000???11111010} :
         begin
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
           alu_result       = next_pc;
         end

      // -----------------------------------------------------------------------
      // Instruction Group -- Shift instructions Dyadic
      // -----------------------------------------------------------------------

      // Instruction = BFFO RD, RS, Op Code =  0 0 0 0 1 RD RS 1 0 0 0 0
      // BFFO - Bit Field Find First One
      // FirstOne (RS) => RD
      // Cycles - P
      {CONT, 16'b00001??????10000} :
         begin
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;

           casez (rs1_data)  // synopsys parallel_case
             16'b1???_????_????_???? : alu_result = 16'h000f;
             16'b01??_????_????_???? : alu_result = 16'h000e;
             16'b001?_????_????_???? : alu_result = 16'h000d;
             16'b0001_????_????_???? : alu_result = 16'h000c;
             16'b0000_1???_????_???? : alu_result = 16'h000b;
             16'b0000_01??_????_???? : alu_result = 16'h000a;
             16'b0000_001?_????_???? : alu_result = 16'h0009;
             16'b0000_0001_????_???? : alu_result = 16'h0008;
             16'b0000_0000_1???_???? : alu_result = 16'h0007;
             16'b0000_0000_01??_???? : alu_result = 16'h0006;
             16'b0000_0000_001?_???? : alu_result = 16'h0005;
             16'b0000_0000_0001_???? : alu_result = 16'h0004;
             16'b0000_0000_0000_1??? : alu_result = 16'h0003;
             16'b0000_0000_0000_01?? : alu_result = 16'h0002;
             16'b0000_0000_0000_001? : alu_result = 16'h0001;
             16'b0000_0000_0000_0001 : alu_result = 16'h0000;
           endcase
           next_zero     = !(|alu_result);
           next_negative = 1'b0;
           next_carry    = !(|rs1_data);
           next_overflow = 1'b0;
         end

      // Instruction = ASR RD, RS, Op Code =  0 0 0 0 1 RD RS 1 0 0 0 1
      // ASR - Arithmetic Shift Right
      // n = RS
      // Cycles - P
      {CONT, 16'b00001??????10001} :
         begin
           shift_ammount  = {|rs1_data[15:4], rs1_data[3:0]};
           shift_filler   = {16{rd_data[15]}};

           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
           alu_result       = shift_out;
           next_zero        = !(|alu_result);
           next_negative    = alu_result[15];
           next_carry       = |rs1_data ? shift_rollover : carry_flag;
           next_overflow    = rd_data[15] ^ alu_result[15];  // Table and text disagree
         end

      // Instruction = CSL RD, RS, Op Code =  0 0 0 0 1 RD RS 1 0 0 1 0
      // CSL - Logical Shift Left with Carry
      // n = RS
      // Cycles - P
      {CONT, 16'b00001??????10010} :
         begin
           shift_left     = 1'b1;
           shift_ammount  = {|rs1_data[15:4], rs1_data[3:0]};
           shift_filler   = {16{carry_flag}};

           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
           alu_result       = shift_out;
           next_zero        = !(|alu_result);
           next_negative    = alu_result[15];
           next_carry       = |rs1_data ? shift_rollover : carry_flag;
           next_overflow    = rd_data[15] ^ alu_result[15];
         end

      // Instruction = CSR RD, RS, Op Code =  0 0 0 0 1 RD RS 1 0 0 1 1
      // Logical Shift Right with Carry
      // n = RS
      // Cycles - P
      {CONT, 16'b00001??????10011} :
         begin
           shift_ammount  = {|rs1_data[15:4], rs1_data[3:0]};
           shift_filler   = {16{carry_flag}};

           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
           alu_result       = shift_out;
           next_zero        = !(|alu_result);
           next_negative    = alu_result[15];
           next_carry       = |rs1_data ? shift_rollover : carry_flag;
           next_overflow    = rd_data[15] ^ alu_result[15];
         end

      // Instruction = LSL RD, RS, Op Code =  0 0 0 0 1 RD RS 1 0 1 0 0
      // Logical Shift Left
      // n = RS
      // Cycles - P
      {CONT, 16'b00001??????10100} :
         begin
           shift_left     = 1'b1;
           shift_ammount  = {|rs1_data[15:4], rs1_data[3:0]};
           shift_filler   = 16'h0000;

           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
           alu_result       = shift_out;
           next_zero        = !(|alu_result);
           next_negative    = alu_result[15];
           next_carry       = |rs1_data ? shift_rollover : carry_flag;
           next_overflow    = rd_data[15] ^ alu_result[15];
         end

      // Instruction = LSR RD, RS, Op Code =  0 0 0 0 1 RD RS 1 0 1 0 1
      // Logical Shift Right
      // n = RS
      // Cycles - P
      {CONT, 16'b00001??????10101} :
         begin
           shift_ammount  = {|rs1_data[15:4], rs1_data[3:0]};
           shift_filler   = 16'h0000;

           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
           alu_result       = shift_out;
           next_zero        = !(|alu_result);
           next_negative    = alu_result[15];
           next_carry       = |rs1_data ? shift_rollover : carry_flag;
           next_overflow    = rd_data[15] ^ alu_result[15];
         end

      // Instruction = ROL RD, RS, Op Code =  0 0 0 0 1 RD RS 1 0 1 1 0
      // Rotate Left
      // n = RS
      // Cycles - P
      {CONT, 16'b00001??????10110} :
         begin
           shift_left     = 1'b1;
           shift_ammount  = {1'b0, rs1_data[3:0]};
           shift_filler   = rd_data;

           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
           alu_result       = shift_out;
           next_zero        = !(|alu_result);
           next_negative    = alu_result[15];
           next_overflow    = 1'b0;
         end

      // Instruction = ROR RD, RS, Op Code =  0 0 0 0 1 RD RS 1 0 1 1 1
      // Rotate Right
      // n = RS
      // Cycles - P
      {CONT, 16'b00001??????10111} :
         begin
           shift_ammount  = {1'b0, rs1_data[3:0]};
           shift_filler   = rd_data;

           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
           alu_result       = shift_out;
           next_zero        = !(|alu_result);
           next_negative    = alu_result[15];
           next_overflow    = 1'b0;
         end

      // -----------------------------------------------------------------------
      // Instruction Group -- Shift instructions immediate
      // -----------------------------------------------------------------------

      // Instruction = ASR RD, #IMM4, Op Code =  0 0 0 0 1 RD IMM4 1 0 0 1
      // ASR - Arithmetic Shift Right
      // n = IMM4
      // Cycles - P
      {CONT, 16'b00001???????1001} :
         begin
           shift_ammount  = {!(|op_code[7:4]), op_code[7:4]};
           shift_filler   = {16{rd_data[15]}};

           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
           alu_result       = shift_out;
           next_zero        = !(|alu_result);
           next_negative    = alu_result[15];
           next_carry       = shift_rollover;
           next_overflow    = rd_data[15] ^ alu_result[15];  // Table and text disagree
         end

      // Instruction = CSL RD, #IMM4, Op Code =  0 0 0 0 1 RD IMM4 1 0 1 0
      // CSL - Logical Shift Left with Carry
      // n = IMM4
      // Cycles - P
      {CONT, 16'b00001???????1010} :
         begin
           shift_left     = 1'b1;
           shift_ammount  = {!(|op_code[7:4]), op_code[7:4]};
           shift_filler   = {16{carry_flag}};

           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
           alu_result       = shift_out;
           next_zero        = !(|alu_result);
           next_negative    = alu_result[15];
           next_carry       = shift_rollover;
           next_overflow    = rd_data[15] ^ alu_result[15];
         end

      // Instruction = CSR RD, #IMM4, Op Code =  0 0 0 0 1 RD IMM4 1 0 1 1
      // CSR - Logical Shift Right with Carry
      // n = IMM4
      // Cycles - P
      {CONT, 16'b00001???????1011} :
         begin
           shift_ammount  = {!(|op_code[7:4]), op_code[7:4]};
           shift_filler   = {16{carry_flag}};

           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
           alu_result       = shift_out;
           next_zero        = !(|alu_result);
           next_negative    = alu_result[15];
           next_carry       = shift_rollover;
           next_overflow    = rd_data[15] ^ alu_result[15];
         end

      // Instruction = LSL RD, #IMM4, Op Code =  0 0 0 0 1 RD IMM4 1 1 0 0
      // LSL - Logical Shift Left
      // n = IMM4
      // Cycles - P
      {CONT, 16'b00001???????1100} :
         begin
           shift_left     = 1'b1;
           shift_ammount  = {!(|op_code[7:4]), op_code[7:4]};
           shift_filler   = 16'h0000;

           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
           alu_result       = shift_out;
           next_zero        = !(|alu_result);
           next_negative    = alu_result[15];
           next_carry       = shift_rollover;
           next_overflow    = rd_data[15] ^ alu_result[15];
         end

      // Instruction = LSR RD, #IMM4, Op Code =  0 0 0 0 1 RD IMM4 1 1 0 1
      // LSR - Logical Shift Right
      // n = IMM4
      // Cycles - P
      {CONT, 16'b00001???????1101} :
         begin
           shift_ammount  = {!(|op_code[7:4]), op_code[7:4]};
           shift_filler   = 16'h0000;

           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
           alu_result       = shift_out;
           next_zero        = !(|alu_result);
           next_negative    = alu_result[15];
           next_carry       = shift_rollover;
           next_overflow    = rd_data[15] ^ alu_result[15];
         end

      // Instruction = ROL RD, #IMM4, Op Code =  0 0 0 0 1 RD IMM4 1 1 1 0
      // ROL - Rotate Left
      // n = IMM4
      // Cycles - P
      {CONT, 16'b00001???????1110} :
         begin
           shift_left     = 1'b1;
           shift_ammount  = {1'b0, op_code[7:4]};
           shift_filler   = rd_data;

           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
           alu_result       = shift_out;
           next_zero        = !(|alu_result);
           next_negative    = alu_result[15];
           next_overflow    = 1'b0;
         end

      // Instruction = ROR RD, #IMM4, Op Code =  0 0 0 0 1 RD IMM4 1 1 1 1
      // ROR - Rotate Right
      // n = IMM4
      // Cycles - P
      {CONT, 16'b00001???????1111} :
         begin
           shift_ammount  = {1'b0, op_code[7:4]};
           shift_filler   = rd_data;

           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
           alu_result       = shift_out;
           next_zero        = !(|alu_result);
           next_negative    = alu_result[15];
           next_overflow    = 1'b0;
         end

      // -----------------------------------------------------------------------
      // Instruction Group -- Logical Triadic
      // -----------------------------------------------------------------------

      // Instruction = AND RD, RS1, RS2, Op Code =  0 0 0 1 0 RD RS1 RS2 0 0
      // AND - Logical AND
      // RS1 & RS2 => RD
      // Cycles - P
      {CONT, 16'b00010?????????00} :
         begin
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;

           alu_result    = rs1_data & rs2_data;
           next_zero     = !(|alu_result);
           next_negative = alu_result[15];
           next_overflow = 1'b0;
         end

      // Instruction = OR RD, RS1, RS2, Op Code =  0 0 0 1 0 RD RS1 RS2 1 0
      // OR - Logical OR
      // RS1 | RS2 => RD
      // Cycles - P
      {CONT, 16'b00010?????????10} :
         begin
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;

           alu_result    = rs1_data | rs2_data;
           next_zero     = !(|alu_result);
           next_negative = alu_result[15];
           next_overflow = 1'b0;
          end

      // Instruction = XNOR RD, RS1, RS2, Op Code =  0 0 0 1 0 RD RS1 RS2 1 1
      // XNOR - Logical Exclusive NOR
      // ~(RS1 ^ RS2) => RD
      // Cycles - P
      {CONT, 16'b00010?????????11} :
         begin
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;

           alu_result    = ~(rs1_data ^ rs2_data);
           next_zero     = !(|alu_result);
           next_negative = alu_result[15];
           next_overflow = 1'b0;
         end

      // -----------------------------------------------------------------------
      // Instruction Group -- Arithmetic Triadic
      // -----------------------------------------------------------------------

      // Instruction = SUB RD, RS1, RS2, Op Code =  0 0 0 1 1 RD RS1 RS2 0 0
      // SUB - Subtract without Carry
      // RS1 - RS2 => RD
      // Cycles - P
      {CONT, 16'b00011?????????00} :
         begin
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;

           {next_carry, alu_result}    = rs1_data - rs2_data;
           next_zero     = !(|alu_result);
           next_negative = alu_result[15];
           next_overflow = (rs1_data[15] && !rs2_data[15] && !alu_result[15]) || (!rs1_data[15] && rs2_data[15] && alu_result[15]);
         end

      // Instruction = SBC RD, RS1, RS2, Op Code =  0 0 0 1 1 RD RS1 RS2 0 1
      // SBC - Subtract with Carry
      // RS1 - RS2 - C => RD
      // Cycles - P
      {CONT, 16'b00011?????????01} :
         begin
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;

           {next_carry, alu_result}    = rs1_data - rs2_data - {15'b0, carry_flag};
           next_zero     = !(|alu_result) && zero_flag;
           next_negative = alu_result[15];
           next_overflow = (rs1_data[15] && !rs2_data[15] && !alu_result[15]) || (!rs1_data[15] && rs2_data[15] && alu_result[15]);
         end

      // Instruction = ADD RD, RS1, RS2, Op Code =  0 0 0 1 1 RD RS1 RS2 1 0
      // ADD - ADD without carry
      // RS1 + RS2 => RD
      // Cycles - P
      {CONT, 16'b00011?????????10} :
         begin
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;

           {next_carry, alu_result}    = rs1_data + rs2_data;
           next_zero     = !(|alu_result);
           next_negative = alu_result[15];
           next_overflow = (rs1_data[15] && rs2_data[15] && !alu_result[15]) || (!rs1_data[15] && !rs2_data[15] && alu_result[15]);
         end

      // Instruction = ADC RD, RS1, RS2, Op Code =  0 0 0 1 1 RD RS1 RS2 1 1
      // ADC - add with carry
      // RS1 + RS2 + C => RD
      // Cycles - P
      {CONT, 16'b00011?????????11} :
         begin
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;

           {next_carry, alu_result}    = rs1_data + rs2_data + {15'b0, carry_flag};
           next_zero     = !(|alu_result) && zero_flag;
           next_negative = alu_result[15];
           next_overflow = (rs1_data[15] && rs2_data[15] && !alu_result[15]) || (!rs1_data[15] && !rs2_data[15] && alu_result[15]);
         end

      // -----------------------------------------------------------------------
      // Instruction Group -- Branches
      // -----------------------------------------------------------------------

      // Instruction = BCC REL9, Op Code =  0 0 1 0 0 0 0 REL9
      // Branch if Carry Cleared
      // If C = 0, then PC + $0002 + (REL9 << 1) => PC
      // Cycles - PP/P
      {CONT, 16'b0010000?????????} :
         if (!carry_flag)
           begin
             next_cpu_state = S_STALL;
             load_next_inst = 1'b0;
             pc_incr_mux    = jump_offset;
             next_pc        = pc_sum;  // There is a race condition when the default declaration is used
           end

      // Instruction = BCS REL9, Op Code =  0 0 1 0 0 0 1 REL9
      // Branch if Carry Set
      // If C = 1, then PC + $0002 + (REL9 << 1) => PC
      // Cycles - PP/P
      {CONT, 16'b0010001?????????} :
         if (carry_flag)
           begin
             next_cpu_state = S_STALL;
             load_next_inst = 1'b0;
             pc_incr_mux    = jump_offset;
             next_pc        = pc_sum;
           end

      // Instruction = BNE REL9, Op Code =  0 0 1 0 0 1 0 REL9
      // Branch if Not Equal
      // If Z = 0, then PC + $0002 + (REL9 << 1) => PC
      // Cycles - PP/P
      {CONT, 16'b0010010?????????} :
         if (!zero_flag)
           begin
             next_cpu_state = S_STALL;
             load_next_inst = 1'b0;
             pc_incr_mux    = jump_offset;
             next_pc        = pc_sum;
           end

      // Instruction = BEQ REL9, Op Code =  0 0 1 0 0 1 1 REL9
      // Branch if Equal
      // If Z = 1, then PC + $0002 + (REL9 << 1) => PC
      // Cycles - PP/P
      {CONT, 16'b0010011?????????} :
         if (zero_flag)
           begin
             next_cpu_state = S_STALL;
             load_next_inst = 1'b0;
             pc_incr_mux    = jump_offset;
             next_pc        = pc_sum;
           end

      // Instruction = BPL REL9, Op Code =  0 0 1 0 1 0 0 REL9
      // Branch if Plus
      // If N = 0, then PC + $0002 + (REL9 << 1) => PC
      // Cycles - PP/P
      {CONT, 16'b0010100?????????} :
         if (!negative_flag)
           begin
             next_cpu_state = S_STALL;
             load_next_inst = 1'b0;
             pc_incr_mux    = jump_offset;
             next_pc        = pc_sum;
           end

      // Instruction = BMI REL9, Op Code =  0 0 1 0 1 0 1 REL9
      // Branch if Minus
      // If N = 1, then PC + $0002 + (REL9 << 1) => PC
      // Cycles - PP/P
      {CONT, 16'b0010101?????????} :
         if (negative_flag)
           begin
             next_cpu_state = S_STALL;
             load_next_inst = 1'b0;
             pc_incr_mux    = jump_offset;
             next_pc        = pc_sum;
           end

      // Instruction = BVC REL9, Op Code =  0 0 1 0 1 1 0 REL9
      // Branch if Overflow Cleared
      // If V = 0, then PC + $0002 + (REL9 << 1) => PC
      // Cycles - PP/P
      {CONT, 16'b0010110?????????} :
         if (!overflow_flag)
           begin
             next_cpu_state = S_STALL;
             load_next_inst = 1'b0;
             pc_incr_mux    = jump_offset;
             next_pc        = pc_sum;
           end

      // Instruction = BVS REL9, Op Code =  0 0 1 0 1 1 1 REL9
      // Branch if Overflow Set
      // If V = 1, then PC + $0002 + (REL9 << 1) => PC
      // Cycles - PP/P
      {CONT, 16'b0010111?????????} :
         if (overflow_flag)
           begin
             next_cpu_state = S_STALL;
             load_next_inst = 1'b0;
             pc_incr_mux    = jump_offset;
             next_pc        = pc_sum;
           end

      // Instruction = BHI REL9, Op Code =  0 0 1 1 0 0 0 REL9
      // Branch if Higher
      // If C | Z = 0, then PC + $0002 + (REL9 << 1) => PC
      // Cycles - PP/P
      {CONT, 16'b0011000?????????} :
         if (!(carry_flag || zero_flag))
           begin
             next_cpu_state = S_STALL;
             load_next_inst = 1'b0;
             pc_incr_mux    = jump_offset;
             next_pc        = pc_sum;
           end

      // Instruction = BLS REL9, Op Code =  0 0 1 1 0 0 1 REL9
      // Branch if Lower or Same
      // If C | Z = 1, then PC + $0002 + (REL9 << 1) => PC
      // Cycles - PP/P
      {CONT, 16'b0011001?????????} :
         if (carry_flag || zero_flag)
           begin
             next_cpu_state = S_STALL;
             load_next_inst = 1'b0;
             pc_incr_mux    = jump_offset;
             next_pc        = pc_sum;
           end

      // Instruction = BGE REL9, Op Code =  0 0 1 1 0 1 0 REL9
      // Branch if Greater than or Equal to Zero
      // If N ^ V = 0, then PC + $0002 + (REL9 << 1) => PC
      // Cycles - PP/P
      {CONT, 16'b0011010?????????} :
         if (!(negative_flag ^ overflow_flag))
           begin
             next_cpu_state = S_STALL;
             load_next_inst = 1'b0;
             pc_incr_mux    = jump_offset;
             next_pc        = pc_sum;
           end

      // Instruction = BLT REL9, Op Code =  0 0 1 1 0 1 1 REL9
      // Branch if Lower than Zero
      // If N ^ V = 1, then PC + $0002 + (REL9 << 1) => PC
      // Cycles - PP/P
      {CONT, 16'b0011011?????????} :
         if (negative_flag ^ overflow_flag)
           begin
             next_cpu_state = S_STALL;
             load_next_inst = 1'b0;
             pc_incr_mux    = jump_offset;
             next_pc        = pc_sum;
           end

      // Instruction = BGT REL9, Op Code =  0 0 1 1 1 0 0 REL9
      // Branch if Greater than Zero
      // If Z | (N ^ V) = 0, then PC + $0002 + (REL9 << 1) => PC
      // Cycles - PP/P
      {CONT, 16'b0011100?????????} :
         if (!(zero_flag || (negative_flag ^ overflow_flag)))
           begin
             next_cpu_state = S_STALL;
             load_next_inst = 1'b0;
             pc_incr_mux    = jump_offset;
             next_pc        = pc_sum;
           end

      // Instruction = BLE REL9, Op Code =  0 0 1 1 1 0 1 REL9
      // Branch if Less or Equal to Zero
      // If Z | (N ^ V) = 1, then PC + $0002 + (REL9 << 1) => PC
      // Cycles - PP/P
      {CONT, 16'b0011101?????????} :
         if (zero_flag || (negative_flag ^ overflow_flag))
           begin
             next_cpu_state = S_STALL;
             load_next_inst = 1'b0;
             pc_incr_mux    = jump_offset;
             next_pc        = pc_sum;
           end

      // Instruction = BRA REL10, Op Code =  0 0 1 1 1 1 REL10
      // Branch Always, signed offset
      // PC + $0002 + (REL10 << 1) => PC
      // Cycles - PP
      {CONT, 16'b001111??????????} :
         begin
           next_cpu_state = S_STALL;
           load_next_inst = 1'b0;
           pc_incr_mux    = bra_offset;
           next_pc        = pc_sum;
         end


      // -----------------------------------------------------------------------
      // Instruction Group -- Load and Store Instructions
      // -----------------------------------------------------------------------

      // Instruction = LDB RD, (RB, #OFFS5), Op Code =  0 1 0 0 0 RD RB OFFS5
      // Load Byte from Memory, unsigned offset
      // M[RB, #OFFS5] => RD.L; $00 => RD.H
      // RB field == RS1 field
      // Cycles - Pr
      {CONT, 16'b01000???????????} :
         begin
           next_cpu_state = B_LOAD;
           load_next_inst = 1'b0;
           pc_incr_mux    = 16'h0000;
           next_pc        = pc_sum;
           data_access    = 1'b1;
           data_address   = rs1_data + {11'b0, op_code[4:0]};
         end

      // Instruction = LDW RD, (RB, #OFFS5), Op Code =  0 1 0 0 1 RD RB OFFS5
      // Load Word from Memory, unsigned offset
      // M[RB, #OFFS5] => RD
      // RB field == RS1 field
      // Cycles - PR
      {CONT, 16'b01001???????????} :
         begin
           next_cpu_state = W_LOAD;
           load_next_inst = 1'b0;
           pc_incr_mux    = 16'h0000;
           next_pc        = pc_sum;
           data_access    = 1'b1;
           data_address   = rs1_data + {11'b0, op_code[4:0]};
           data_word_op   = 1'b1;
         end

      // Instruction = STB RS, (RB, #OFFS5), Op Code =  0 1 0 1 0 RS RB OFFS5
      // Store Byte to Memory, unsigned offset
      // RS.L => M[RB, #OFFS5]
      // RS field == RD fieild, RB field == RS1 field
      // Cycles - Pw
      {CONT, 16'b01010???????????} :
         begin
           next_cpu_state = S_STALL;
           load_next_inst = 1'b0;
           pc_incr_mux    = 16'h0000;
           next_pc        = pc_sum;
           data_access    = 1'b1;
           data_write     = 1'b1;
           data_address   = rs1_data + {11'b0, op_code[4:0]};
         end

      // Instruction = STW RS, (RB, #OFFS5), Op Code =  0 1 0 1 1 RS RB OFFS5
      // Store Word to Memory, unsigned offset
      // RS => M[RB, #OFFS5]
      // RS field == RD fieild, RB field == RS1 field
      // Cycles - PW
      {CONT, 16'b01011???????????} :
         begin
           next_cpu_state = S_STALL;
           load_next_inst = 1'b0;
           pc_incr_mux    = 16'h0000;
           next_pc        = pc_sum;
           data_access    = 1'b1;
           data_write     = 1'b1;
           data_address   = rs1_data + {11'b0, op_code[4:0]};
           data_word_op   = 1'b1;
         end

      // Instruction = LDB RD, (RB, RI), Op Code =  0 1 1 0 0 RD RB RI 0 0
      // Load Byte from Memory
      // M[RB, RI] => RD.L; $00 => RD.H
      // RB field == RS1 field, RI field == RS2 field
      // Cycles - Pr
      {CONT, 16'b01100?????????00} :
         begin
           next_cpu_state = B_LOAD;
           load_next_inst = 1'b0;
           pc_incr_mux    = 16'h0000;
           next_pc        = pc_sum;
           data_access    = 1'b1;
           data_address   = rs1_data + rs2_data;
         end

      // Instruction = LDW RD, (RB, RI), Op Code =  0 1 1 0 1 RD RB RI 0 0
      // Load Word from Memory
      // M[RB, RI] => RD
      // RB field == RS1 field, RI field == RS2 field
      // Cycles - PR
      {CONT, 16'b01101?????????00} :
         begin
           next_cpu_state = W_LOAD;
           load_next_inst = 1'b0;
           pc_incr_mux    = 16'h0000;
           next_pc        = pc_sum;
           data_access    = 1'b1;
           data_address   = rs1_data + rs2_data;
           data_word_op   = 1'b1;
         end

      // Instruction = STB RS, (RB, RI), Op Code =  0 1 1 1 0 RS RB RI 0 0
      // RS.L => M[RB, RI]
      // Store Byte to Memory
      // RS field == RD fieild, RB field == RS1 field, RI field == RS2 field
      // Cycles - Pw
      {CONT, 16'b01110?????????00} :
         begin
           next_cpu_state = S_STALL;
           load_next_inst = 1'b0;
           pc_incr_mux    = 16'h0000;
           next_pc        = pc_sum;
           data_access    = 1'b1;
           data_write     = 1'b1;
           data_address   = rs1_data + rs2_data;
         end

      // Instruction = STW RS, (RB, RI), Op Code =  0 1 1 1 1 RS RB RI 0 0
      // Store Word to Memory
      // RS => M[RB, RI]
      // RS field == RD fieild, RB field == RS1 field, RI field == RS2 field
      // Cycles - PW
      {CONT, 16'b01111?????????00} :
         begin
           next_cpu_state = S_STALL;
           load_next_inst = 1'b0;
           pc_incr_mux    = 16'h0000;
           next_pc        = pc_sum;
           data_access    = 1'b1;
           data_write     = 1'b1;
           data_address   = rs1_data + rs2_data;
           data_word_op   = 1'b1;
         end

      // Instruction = LDB RD, (RB, RI+), Op Code =  0 1 1 0 0 RD RB RI 0 1
      // Load Byte from Memory
      // M[RB, RI] => RD.L; $00 => RD.H; RI+1 => RI
      //  If the same general purpose register is used as index (RI) and destination register (RD),
      //  the content of the register will not be incremented after the data move: M[RB, RI] => RD.L; $00 => RD.H
      // RB field == RS1 field, RI field == RS2 field
      // Cycles - Pr
      {CONT, 16'b01100?????????01} :
         begin
           next_cpu_state   = B_LOAD;
           load_next_inst   = 1'b0;
           pc_incr_mux      = 16'h0000;
           next_pc          = pc_sum;
           data_access      = 1'b1;
           data_address     = rs1_data + rs2_data;
           alu_result       = rs2_data + 16'h0001;
           sel_rd_field     = 1'b0;
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
         end

      // Instruction = LDW RD, (RB, RI+), Op Code =  0 1 1 0 1 RD RB RI 0 1
      // Load Word from Memory
      // M[RB, RI] => RD; RI+2 => RI
      //  If the same general purpose register is used as index (RI) and destination register (RD),
      //  the content of the register will not be incremented after the data move: M[RB, RI] => RD
      // RB field == RS1 field, RI field == RS2 field
      // Cycles - PR
      {CONT, 16'b01101?????????01} :
         begin
           next_cpu_state   = W_LOAD;
           load_next_inst   = 1'b0;
           pc_incr_mux      = 16'h0000;
           next_pc          = pc_sum;
           data_access      = 1'b1;
           data_address     = rs1_data + rs2_data;
           data_word_op     = 1'b1;
           alu_result       = rs2_data + 16'h0002;
           sel_rd_field     = 1'b0;
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
         end

      // Instruction = STB RS, (RB, RI+), Op Code =  0 1 1 1 0 RS RB RI 0 1
      // Store Byte to Memory
      // RS.L => M[RB, RI]; RI+1 => RI
      // RS field == RD fieild, RB field == RS1 field, RI field == RS2 field
      // Cycles - Pw
      {CONT, 16'b01110?????????01} :
         begin
           next_cpu_state   = S_STALL;
           load_next_inst   = 1'b0;
           pc_incr_mux      = 16'h0000;
           next_pc          = pc_sum;
           data_access      = 1'b1;
           data_write       = 1'b1;
           data_address     = rs1_data + rs2_data;
           alu_result       = rs2_data + 16'h0001;
           sel_rd_field     = 1'b0;
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
         end

      // Instruction = STW RS, (RB, RI+), Op Code =  0 1 1 1 1 RS RB RI 0 1
      // Store Word to Memory
      // RS => M[RB, RI]; RI+2 => RI
      // RS field == RD fieild, RB field == RS1 field, RI field == RS2 field
      // Cycles - PW
      {CONT, 16'b01111?????????01} :
         begin
           next_cpu_state   = S_STALL;
           load_next_inst   = 1'b0;
           pc_incr_mux      = 16'h0000;
           next_pc          = pc_sum;
           data_access      = 1'b1;
           data_write       = 1'b1;
           data_word_op     = 1'b1;
           data_address     = rs1_data + rs2_data;
           alu_result       = rs2_data + 16'h0002;
           sel_rd_field     = 1'b0;
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
         end

      // Instruction = LDB RD, (RB, -RI), Op Code =  0 1 1 0 0 RD RB RI 1 0
      // Load Byte from Memory
      // RI-1 => RI; M[RS, RI]  => RD.L; $00 => RD.H
      // RB field == RS1 field, RI field == RS2 field
      // Cycles - Pr
      {CONT, 16'b01100?????????10} :
         begin
           next_cpu_state   = B_LOAD;
           load_next_inst   = 1'b0;
           pc_incr_mux      = 16'h0000;
           next_pc          = pc_sum;
           data_access      = 1'b1;
           alu_result       = rs2_data + 16'hffff;
           data_address     = rs1_data + alu_result;
           sel_rd_field     = 1'b0;
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
         end

      // Instruction = LDW RD, (RB, -RI), Op Code =  0 1 1 0 1 RD RB RI 1 0
      // Load Word from Memory
      // RI-2 => RI; M[RS, RI] => RD
      // RB field == RS1 field, RI field == RS2 field
      // Cycles - PR
      {CONT, 16'b01101?????????10} :
         begin
           next_cpu_state   = W_LOAD;
           load_next_inst   = 1'b0;
           pc_incr_mux      = 16'h0000;
           next_pc          = pc_sum;
           data_access      = 1'b1;
           alu_result       = rs2_data + 16'hfffe;
           data_address     = rs1_data + alu_result;
           data_word_op     = 1'b1;
           sel_rd_field     = 1'b0;
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
         end

      // Instruction = STB RS, (RB, -RI), Op Code =  0 1 1 1 0 RS RB RI 1 0
      // Store Byte to Memory
      // RI-1 => RI; RS.L => M[RB, RI]
      //  If the same general purpose register is used as index (RI) and source register (RS),
      //  the unmodified content of the source register is written to the memory: RS.L => M[RB, RS-1]; RS-1 => RS
      // RS field == RD fieild, RB field == RS1 field, RI field == RS2 field
      // Cycles - Pw
      {CONT, 16'b01110?????????10} :
         begin
           next_cpu_state   = S_STALL;
           load_next_inst   = 1'b0;
           pc_incr_mux      = 16'h0000;
           next_pc          = pc_sum;
           data_access      = 1'b1;
           data_write       = 1'b1;
           alu_result       = rs2_data + 16'hffff;
           data_address     = rs1_data + alu_result;
           sel_rd_field     = 1'b0;
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
         end

      // Instruction = STW RS, (RB, -RI), Op Code =  0 1 1 1 1 RS RB RI 1 0
      // Store Word to Memory
      // RI-2 => RI; RS => M[RB, RI]
      //  If the same general purpose register is used as index (RI) and source register (RS),
      //  the unmodified content of the source register is written to the memory: RS => M[RB, RS-2]; RS-2 => RS
      // RS field == RD fieild, RB field == RS1 field, RI field == RS2 field
      // Cycles - PW
      {CONT, 16'b01111?????????10} :
         begin
           next_cpu_state   = S_STALL;
           load_next_inst   = 1'b0;
           pc_incr_mux      = 16'h0000;
           next_pc          = pc_sum;
           data_access      = 1'b1;
           data_write       = 1'b1;
           data_word_op     = 1'b1;
           alu_result       = rs2_data + 16'hfffe;
           data_address     = rs1_data + alu_result;
           sel_rd_field     = 1'b0;
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
         end

      // -----------------------------------------------------------------------
      // Instruction Group -- Bit Field Instructions
      // -----------------------------------------------------------------------

      // Instruction = BFEXT RD, RS1, RS2, Op Code =  0 1 1 0 0 RD RS1 RS2 1 1
      // BFEXT - Bit Field Extract
      // RS1[(o+w):o] => RD[w:0]; 0 => RD[15:(w+1)]
      // Cycles - P
      {CONT, 16'b01100?????????11} :
         begin
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
           shift_ammount  = {1'b0, rs2_data[3:0]};
           for (bfi = 0; bfi <= 15; bfi = bfi + 1)
             shift_in[bfi] = bf_mux_mask[bfi] ? rs1_data[bfi] : 1'b0;

           alu_result    = shift_out;
           next_zero     = !(|alu_result);
           next_negative = alu_result[15];
           next_overflow = 1'b0;
         end

      // Instruction = BFINS RD, RS1, RS2, Op Code =  0 1 1 0 1 RD RS1 RS2 1 1
      // BFINS - Bit Field Insert
      // RS1[w:0] => RD[(w+o):o
      // Cycles - P
      {CONT, 16'b01101?????????11} :
         begin
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
           shift_left     = 1'b1;
           shift_ammount  = {1'b0, rs2_data[3:0]};
           shift_in       = rs1_data;

           for (bfi = 0; bfi <= 15; bfi = bfi + 1)
             alu_result[bfi] = bf_mux_mask[bfi] ? shift_out[bfi] : rd_data[bfi];
           next_zero     = !(|alu_result);
           next_negative = alu_result[15];
           next_overflow = 1'b0;
         end

      // Instruction = BFINSI RD, RS1, RS2, Op Code =  0 1 1 1 0 RD RS1 RS2 1 1
      // BFINSI - Bit Field Insert and Invert
      // !RS1[w:0] => RD[w+o:o]
      // Cycles - P
      {CONT, 16'b01110?????????11} :
         begin
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
           shift_left     = 1'b1;
           shift_ammount  = {1'b0, rs2_data[3:0]};
           shift_in       = rs1_data;

           for (bfi = 0; bfi <= 15; bfi = bfi + 1)
             alu_result[bfi] = bf_mux_mask[bfi] ? !shift_out[bfi] : rd_data[bfi];
           next_zero     = !(|alu_result);
           next_negative = alu_result[15];
           next_overflow = 1'b0;
         end

      // Instruction = BFINSX RD, RS1, RS2, Op Code =  0 1 1 1 1 RD RS1 RS2 1 1
      // BFINSX - Bit Field Insert and XNOR
      // !(RS1[w:0] ^ RD[w+o:o]) => RD[w+o:o]
      // Cycles - P
      {CONT, 16'b01111?????????11} :
         begin
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;
           shift_left     = 1'b1;
           shift_ammount  = {1'b0, rs2_data[3:0]};
           shift_in       = rs1_data;

           for (bfii = 0; bfii <= 15; bfii = bfii + 1)
             alu_result[bfii] = bf_mux_mask[bfii] ? !(shift_out[bfii] ^ rd_data[bfii]) : rd_data[bfii];
           next_zero     = !(|alu_result);
           next_negative = alu_result[15];
           next_overflow = 1'b0;
        end

      // -----------------------------------------------------------------------
      // Instruction Group -- Logic Immediate Instructions
      // -----------------------------------------------------------------------

      // Instruction = ANDL RD, #IMM8, Op Code =  1 0 0 0 0 RD IMM8
      // AND - Logical AND
      // RD.L & IMM8 => RD.L
      // Cycles - P
      {CONT, 16'b10000???????????} :
         begin
           ena_rd_low_byte = 1'b1;

           alu_result    = rd_data & {8'b0, op_code[7:0]};
           next_zero     = !(|alu_result[7:0]);
           next_negative = alu_result[7];
           next_overflow = 1'b0;
         end

      // Instruction = ANDH RD, #IMM8, Op Code =  1 0 0 0 1 RD IMM8
      // AND - Logical AND
      // RD.H & IMM8 => RD.H
      // Cycles - P
      {CONT, 16'b10001???????????} :
         begin
           ena_rd_high_byte = 1'b1;

           alu_result    = rd_data & {op_code[7:0], 8'b0};
           next_zero     = !(|alu_result[15:8]);
           next_negative = alu_result[15];
           next_overflow = 1'b0;
         end

      // Instruction = BITL RD, #IMM8, Op Code =  1 0 0 1 0 RD IMM8
      // RD.L & IMM8 => NONE
      {CONT, 16'b10010???????????} :
         begin

           next_zero     = !(|(rd_data[7:0] & op_code[7:0]));
           next_negative = rd_data[7] && op_code[7];
           next_overflow = 1'b0;
         end

      // Instruction = BITH RD, #IMM8, Op Code =  1 0 0 1 1 RD IMM8
      // RD.H & IMM8 => NONE
      {CONT, 16'b10011???????????} :
         begin

           next_zero     = !(|(rd_data[15:8] & op_code[7:0]));
           next_negative = rd_data[15] && op_code[7];
           next_overflow = 1'b0;
         end

      // Instruction = ORL RD, #IMM8, Op Code =  1 0 1 0 0 RD IMM8
      // OR - Logical OR
      // RD.L | IMM8 => RD.L
      {CONT, 16'b10100???????????} :
         begin
           ena_rd_low_byte = 1'b1;

           alu_result    = rd_data | {8'b0, op_code[7:0]};
           next_zero     = !(|alu_result[7:0]);
           next_negative = alu_result[7];
           next_overflow = 1'b0;
         end

      // Instruction = ORH RD, #IMM8, Op Code =  1 0 1 0 1 RD IMM8
      // OR - Logical OR
      // RD.H | IMM8 => RD.H
      {CONT, 16'b10101???????????} :
         begin
           ena_rd_high_byte = 1'b1;

           alu_result    = rd_data | {op_code[7:0], 8'b0};
           next_zero     = !(|alu_result[15:8]);
           next_negative = alu_result[15];
           next_overflow = 1'b0;
         end

      // Instruction = XNORL RD, #IMM8, Op Code =  1 0 1 1 0 RD IMM8
      // XNOR - Logical Exclusive NOR
      // ~(RD.L ^ IMM8) => RD.L
      {CONT, 16'b10110???????????} :
         begin
           ena_rd_low_byte = 1'b1;

           alu_result    = ~(rd_data ^ {8'b0, op_code[7:0]});
           next_zero     = !(|alu_result[7:0]);
           next_negative = alu_result[7];
           next_overflow = 1'b0;
         end

      // Instruction = XNORH RD, #IMM8, Op Code =  1 0 1 1 1 RD IMM8
      // XNOR - Logical Exclusive NOR
      // ~(RD.H ^ IMM8) => RD.H
      {CONT, 16'b10111???????????} :
         begin
           ena_rd_high_byte = 1'b1;

           alu_result    = ~(rd_data ^ {op_code[7:0], 8'b0});
           next_zero     = !(|alu_result[15:8]);
           next_negative = alu_result[15];
           next_overflow = 1'b0;
         end

      // -----------------------------------------------------------------------
      // Instruction Group -- Arithmetic Immediate Instructions
      // -----------------------------------------------------------------------

      // Instruction = SUBL RD, #IMM8, Op Code =  1 1 0 0 0 RD IMM8
      // SUB - Subtract without Carry
      // RD - $00:IMM8 => RD
      // Cycles - P
      {CONT, 16'b11000???????????} :
         begin
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;

           alu_result    = rd_data - {8'b0, op_code[7:0]};
           next_zero     = !(|alu_result);
           next_negative = alu_result[15];
           next_carry    = (!rd_data[7] && op_code[7]) || (!rd_data[7] && alu_result[7]) || (op_code[7] && alu_result[7]);
           next_overflow = (rd_data[7] && !op_code[7] && !alu_result[7]) || (!rd_data[7] && op_code[7] && alu_result[7]);
         end

      // Instruction = SUBH RD, #IMM8, Op Code =  1 1 0 0 1 RD IMM8
      // SUB - Subtract without Carry
      // RD - IMM8:$00 => RD
      // Cycles - P
      {CONT, 16'b11001???????????} :
         begin
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;

           {next_carry, alu_result} = rd_data - {op_code[7:0], 8'b0};
           next_zero     = !(|alu_result);
           next_negative = alu_result[15];
           next_overflow = (rd_data[15] && !op_code[7] && !alu_result[15]) || (!rd_data[15] && op_code[7] && alu_result[15]);
         end

      // Instruction = CMPL RS, #IMM8, Op Code =  1 1 0 1 0 RS IMM8
      // RS.L - IMM8 => NONE, only condition code flags get updated
      // RS field == RD field
      // Cycles - P
      {CONT, 16'b11010???????????} :
         begin

           alu_result    = {8'b0, rd_data[7:0] - op_code[7:0]};
           next_zero     = !(|alu_result[7:0]);
           next_negative = alu_result[7];
           next_carry    = (!rd_data[7] && op_code[7]) || (!rd_data[7] && alu_result[7]) || (op_code[7] && alu_result[7]);
           next_overflow = (rd_data[7] && !op_code[7] && !alu_result[7]) || (!rd_data[7] && op_code[7] && alu_result[7]);
         end

      // Instruction = CPCH RS, #IMM8, Op Code =  1 1 0 1 1 RS IMM8
      // RS.H - IMM8 - C => NONE, only condition code flags get updated
      // RS field == RD field
      // Cycles - P
      {CONT, 16'b11011???????????} :
         begin

           alu_result    = {rd_data[15:8], 8'b0} - {op_code[7:0], 8'b0} - {7'b0, carry_flag, 8'b0};
           next_zero     = !(|alu_result[15:8]) && zero_flag;
           next_negative = alu_result[15];
           next_carry    = (!rd_data[15] && op_code[7]) || (!rd_data[15] && alu_result[15]) || (op_code[7] && alu_result[15]);
           next_overflow = (rd_data[15] && !op_code[7] && !alu_result[15]) || (!rd_data[15] && op_code[7] && alu_result[15]);
         end

      // Instruction = ADDL RD, #IMM8, Op Code =  1 1 1 0 0 RD IMM8
      // ADD - ADD without carry
      // RD + $00:IMM8 => RD
      // Cycles - P
      {CONT, 16'b11100???????????} :
         begin
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;

           alu_result    = rd_data + {8'b0, op_code[7:0]};
           next_zero     = !(|alu_result);
           next_negative = alu_result[15];
           next_carry    = (rd_data[7] && op_code[7]) || (rd_data[7] && !alu_result[7]) || (op_code[7] && !alu_result[7]);
           next_overflow = (!rd_data[7] && !op_code[7] && alu_result[7]) || (rd_data[7] && op_code[7] && !alu_result[7]);
         end

      // Instruction = ADDH RD, #IMM8, Op Code =  1 1 1 0 1 RD IMM8
      // ADD - ADD without carry
      // RD + IMM8:$00 => RD
      // Cycles - P
      {CONT, 16'b11101???????????} :
         begin
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;

           {next_carry, alu_result} = rd_data + {op_code[7:0], 8'b0};
           next_zero     = !(|alu_result);
           next_negative = alu_result[15];
           next_overflow = (rd_data[15] && op_code[7] && !alu_result[15]) || (!rd_data[15] && !op_code[7] && alu_result[15]);
         end

      // Instruction = LDL RD, #IMM8, Op Code =  1 1 1 1 0 RD IMM8
      // IMM8 => RD.L; $00 => RD.H, High Byte is cleared
      // Cycles - P
      {CONT, 16'b11110???????????} :
         begin
           ena_rd_low_byte  = 1'b1;
           ena_rd_high_byte = 1'b1;

           alu_result    = {8'b0, op_code[7:0]};
         end

      // Instruction = LDH RD, #IMM8, Op Code =  1 1 1 1 1 RD IMM8
      // IMM8 => RD.H, Low Byte is unchanged
      // Cycles - P
      {CONT, 16'b11111???????????} :
         begin
           ena_rd_high_byte = 1'b1;

           alu_result    = {op_code[7:0], 8'b0};
         end
      default :
        begin
          // synopsys translate_off
          $display("\nOP Code Error\n");
          // synopsys translate_on
          next_cpu_state   = DEBUG;
          pc_incr_mux      = 16'h0000;
          next_pc          = pc_sum;
          load_next_inst   = 1'b0;
          op_code_error    = 1'b1;
        end
    endcase

    end  // always

  xgate_barrel_shift barrel_shift(
    // outputs
    .shift_out( shift_out ),
    .shift_rollover( shift_rollover ),
    // inputs
    .shift_left( shift_left ),
    .shift_ammount( shift_ammount ),
    .shift_in( shift_in ),
    .shift_filler( shift_filler )
  );

  // Three to Eight line decoder
  always @*
    case (semaph_risc)  // synopsys parallel_case
      3'h0 : semap_risc_bit = 8'b0000_0001;
      3'h1 : semap_risc_bit = 8'b0000_0010;
      3'h2 : semap_risc_bit = 8'b0000_0100;
      3'h3 : semap_risc_bit = 8'b0000_1000;
      3'h4 : semap_risc_bit = 8'b0001_0000;
      3'h5 : semap_risc_bit = 8'b0010_0000;
      3'h6 : semap_risc_bit = 8'b0100_0000;
      3'h7 : semap_risc_bit = 8'b1000_0000;
    endcase

  assign semaph_stat = |risc_semap;

  // Semaphore Bits
  genvar sem_gen_count;
  generate
    for (sem_gen_count = 0; sem_gen_count < 8; sem_gen_count = sem_gen_count + 1)
      begin:semaphore_
        semaphore_bit sbit(
          // outputs
          .host_status( host_semap[sem_gen_count] ),
          .risc_status( risc_semap[sem_gen_count] ),
          // inputs
          .risc_clk( risc_clk ),
          .async_rst_b( async_rst_b ),
          .risc_bit_sel( semap_risc_bit[sem_gen_count] ),
          .csem( clear_semaph ),
          .ssem( set_semaph ),
          .host_wrt( write_xgsem ),
          .host_bit_mask( perif_data[sem_gen_count+8] ),
          .host_bit( perif_data[sem_gen_count] )
        );
      end
  endgenerate

  endmodule  // xgate_inst_decode

// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------

module xgate_barrel_shift (
  output reg [15:0] shift_out,
  output reg        shift_rollover,

  input             shift_left,
  input      [ 4:0] shift_ammount,
  input      [15:0] shift_in,
  input      [15:0] shift_filler
  );

  always @*
    casez ({shift_left, shift_ammount})  // synopsys parallel_case
     // Start Right Shifts
      6'b0_0_0000 :
        begin
          shift_out      = shift_in;
          shift_rollover = 1'b0;
        end
      6'b0_0_0001 :
        begin
          shift_out      = {shift_filler[ 0], shift_in[15: 1]};
          shift_rollover =  shift_in[ 0];
        end
      6'b0_0_0010 :
        begin
          shift_out      = {shift_filler[ 1:0], shift_in[15: 2]};
          shift_rollover =  shift_in[ 1];
        end
      6'b0_0_0011 :
        begin
          shift_out      = {shift_filler[ 2:0], shift_in[15: 3]};
          shift_rollover =  shift_in[ 2];
        end
      6'b0_0_0100 :
        begin
          shift_out      = {shift_filler[ 3:0], shift_in[15: 4]};
          shift_rollover =  shift_in[ 3];
        end
      6'b0_0_0101 :
        begin
          shift_out      = {shift_filler[ 4:0], shift_in[15: 5]};
          shift_rollover =  shift_in[ 4];
        end
      6'b0_0_0110 :
        begin
          shift_out      = {shift_filler[ 5:0], shift_in[15: 6]};
          shift_rollover =  shift_in[ 5];
        end
      6'b0_0_0111 :
        begin
          shift_out      = {shift_filler[ 6:0], shift_in[15: 7]};
          shift_rollover =  shift_in[ 6];
        end
      6'b0_0_1000 :
        begin
          shift_out      = {shift_filler[ 7:0], shift_in[15: 8]};
          shift_rollover =  shift_in[ 7];
        end
      6'b0_0_1001 :
        begin
          shift_out      = {shift_filler[ 8:0], shift_in[15: 9]};
          shift_rollover =  shift_in[ 8];
        end
      6'b0_0_1010 :
        begin
          shift_out      = {shift_filler[ 9:0], shift_in[15:10]};
          shift_rollover =  shift_in[ 9];
        end
      6'b0_0_1011 :
        begin
          shift_out      = {shift_filler[10:0], shift_in[15:11]};
          shift_rollover =  shift_in[10];
        end
      6'b0_0_1100 :
        begin
          shift_out      = {shift_filler[11:0], shift_in[15:12]};
          shift_rollover =  shift_in[11];
        end
      6'b0_0_1101 :
        begin
          shift_out      = {shift_filler[12:0], shift_in[15:13]};
          shift_rollover =  shift_in[12];
        end
      6'b0_0_1110 :
        begin
          shift_out      = {shift_filler[13:0], shift_in[15:14]};
          shift_rollover =  shift_in[13];
        end
      6'b0_0_1111 :
        begin
          shift_out      = {shift_filler[14:0], shift_in[15]};
          shift_rollover =  shift_in[14];
        end
      6'b0_1_???? :
        begin
          shift_out      = shift_filler[15:0];
          shift_rollover = shift_in[15];
        end

     // Start Left Shifts

      6'b1_0_0000 :
        begin
          shift_out      =  shift_in;
          shift_rollover  = 1'b0;
        end
      6'b1_0_0001 :
        begin
          shift_out      = {shift_in[14:0], shift_filler[15]};
          shift_rollover =  shift_in[15];
        end
      6'b1_0_0010 :
        begin
          shift_out      = {shift_in[13:0], shift_filler[15:14]};
          shift_rollover =  shift_in[14];
        end
      6'b1_0_0011 :
        begin
          shift_out      = {shift_in[12:0], shift_filler[15:13]};
          shift_rollover =  shift_in[13];
        end
      6'b1_0_0100 :
        begin
          shift_out      = {shift_in[11:0], shift_filler[15:12]};
          shift_rollover =  shift_in[12];
        end
      6'b1_0_0101 :
        begin
          shift_out      = {shift_in[10:0], shift_filler[15:11]};
          shift_rollover =  shift_in[11];
        end
      6'b1_0_0110 :
        begin
          shift_out      = {shift_in[ 9:0], shift_filler[15:10]};
          shift_rollover =  shift_in[10];
        end
      6'b1_0_0111 :
        begin
          shift_out      = {shift_in[ 8:0], shift_filler[15: 9]};
          shift_rollover =  shift_in[ 9];
        end
      6'b1_0_1000 :
        begin
          shift_out      = {shift_in[ 7:0], shift_filler[15: 8]};
          shift_rollover =  shift_in[ 8];
        end
      6'b1_0_1001 :
        begin
          shift_out      = {shift_in[ 6:0], shift_filler[15: 7]};
          shift_rollover =  shift_in[ 7];
        end
      6'b1_0_1010 :
        begin
          shift_out      = {shift_in[ 5:0], shift_filler[15: 6]};
          shift_rollover =  shift_in[ 6];
        end
      6'b1_0_1011 :
        begin
          shift_out      = {shift_in[ 4:0], shift_filler[15: 5]};
          shift_rollover =  shift_in[ 5];
        end
      6'b1_0_1100 :
        begin
          shift_out      = {shift_in[ 3:0], shift_filler[15 :4]};
          shift_rollover =  shift_in[ 4];
        end
      6'b1_0_1101 :
        begin
          shift_out      = {shift_in[ 2:0], shift_filler[15: 3]};
          shift_rollover =  shift_in[ 3];
        end
      6'b1_0_1110 :
        begin
          shift_out      = {shift_in[ 1:0], shift_filler[15: 2]};
          shift_rollover =  shift_in[ 2];
        end
      6'b1_0_1111 :
        begin
          shift_out      = {shift_in[ 0], shift_filler[15: 1]};
          shift_rollover =  shift_in[ 1];
        end
      6'b1_1_???? :
        begin
          shift_out      = shift_filler[15: 0];
          shift_rollover = shift_in[ 0];
        end
      default :
        begin
          shift_out      =  shift_in;
          shift_rollover  = 1'b0;
        end
    endcase


endmodule  // xgate_barrel_shift

// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------

module semaphore_bit #(parameter NO_LOCK   = 2'b00,
                       parameter RISC_LOCK = 2'b10,
                       parameter HOST_LOCK = 2'b11)
  (
  output      host_status,   // Return status for Host processor
  output      risc_status,   // Return Status for RISC processor

  input       risc_clk,      // Semaphore register clock
  input       async_rst_b,   // Async reset signal
  input       risc_bit_sel,  // Bit selected by RISC
  input       csem,          // RISC Clear Semaphore Bit
  input       ssem,          // RISC Set Semaphore Bit
  input       host_wrt,      // Host write to the Semaphore Register
  input       host_bit_mask, // Host mask bit written to the Semaphore bit
  input       host_bit       // Host bit written to the Semaphore bit
  );

  reg [1:0] next_semap_state;
  reg [1:0] semap_state;

  assign host_status = semap_state == HOST_LOCK;
  assign risc_status = ssem && risc_bit_sel && ((semap_state == RISC_LOCK) || (next_semap_state == RISC_LOCK));

  always @(posedge risc_clk or negedge async_rst_b)
    if (!async_rst_b)
      semap_state <= NO_LOCK;
    else
      semap_state <= next_semap_state;

  always @*
      case(semap_state)
        NO_LOCK:
          begin
            if (host_wrt && host_bit_mask && host_bit)
              next_semap_state = HOST_LOCK;
            else if (ssem && risc_bit_sel)
              next_semap_state = RISC_LOCK;
            else
              next_semap_state = NO_LOCK;
          end
        RISC_LOCK:
          begin
            if (csem && risc_bit_sel)
              next_semap_state = NO_LOCK;
            else
              next_semap_state = RISC_LOCK;
           end
        HOST_LOCK:
          begin
            if (host_wrt && host_bit_mask && !host_bit)
              next_semap_state = NO_LOCK;
            else
              next_semap_state = HOST_LOCK;
           end
        default:
          next_semap_state = NO_LOCK;
      endcase

endmodule  // semaphore_bit

