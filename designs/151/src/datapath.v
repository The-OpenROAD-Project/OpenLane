// UC Berkeley CS251
// Spring 2018
// Arya Reais-Parsi (aryap@berkeley.edu)

`include "Opcode.vh"
`include "const.vh"

module datapath(
  input             clk, reset,
  //input   [0:0]   hazard_controls,

  input               stall,

  // Stage 1 controls and output to controller.
  input wire [1:0]    s1_pc_sel,
  input wire          s3_csr_we,
  input wire          s1_fwd_s3_rs1,
  input wire          s1_fwd_s3_rs2,
  output wire [4:0]   s1_rs1,
  output wire [4:0]   s1_rs2,
  output wire [4:0]   s1_rd,
  output wire [6:0]   s1_opcode,
  output wire [2:0]   s1_func,

  // Stage 2 controls and output to controller.
  input wire [1:0]    s2_alu_a_sel,
  input wire [2:0]    s2_alu_b_sel,
  input wire [1:0]    s2_adder_a_sel,
  input wire          s2_adder_b_sel,
  input wire          s2_pc_out_sel,
  input wire [1:0]    s2_dmem_we,
  input wire          s2_dmem_re,
  input wire          s2_fwd_s3_rs1,
  input wire          s2_fwd_s3_rs2,
  output wire [4:0]   s2_rs1,
  output wire [4:0]   s2_rs2,
  output wire [4:0]   s2_rd,
  output wire [6:0]   s2_opcode,
  output wire [2:0]   s2_func,

  // Stage 3 controls and output to controller.
  input wire [2:0]    s3_rdata_sel,
  input wire [1:0]    s3_reg_wdata_sel,
  input wire          s3_reg_we,
  input wire          s3_csr_new_data_sel,
  output wire [4:0]   s3_rs1,
  output wire [4:0]   s3_rs2,
  output wire [4:0]   s3_rd,
  output wire [6:0]   s3_opcode,
  output wire [2:0]   s3_func,
  output wire         s3_branch,

  // Memory system connections
  output [31:0]       dcache_addr,
  output [31:0]       icache_addr,
  output reg [3:0]    dcache_we,
  output              dcache_re,
  output reg [31:0]   dcache_din,
  input [31:0]        dcache_dout,
  input [31:0]        icache_dout,
  output wire [31:0]  csr_tohost

);
  //-------------------------------------------------------------------
  // Control status registers (CSR)
  //-------------------------------------------------------------------

  reg [`CPU_DATA_BITS-1:0] csr_tohost_reg;
  assign csr_tohost = csr_tohost_reg;

  //-------------------------------------------------------------------
  // Stage 1
  //-------------------------------------------------------------------

  wire [4:0] rf_raddr0;
  wire [4:0] rf_raddr1;
  wire [4:0] rf_waddr;

  wire [`CPU_DATA_BITS-1:0] rf_rdata0;
  wire [`CPU_DATA_BITS-1:0] rf_rdata1;
  reg [`CPU_DATA_BITS-1:0] rf_wdata;
  // Latch the last s3_result in case we need to forward it.
  reg [`CPU_DATA_BITS-1:0] s2_s3_result_reg;

  RegisterFile #(
    .LOG2_NUM_REGISTERS(5),
    .NUM_REGISTERS(32)
  ) integer_register_file (
    .clk(clk),
    .reset(reset),
    .waddr(rf_waddr),
    .wdata(rf_wdata),
    .write_enable(s3_reg_we),
    .raddr0(rf_raddr0),
    .rdata0(rf_rdata0),
    .raddr1(rf_raddr1),
    .rdata1(rf_rdata1)
  );

  wire [`CPU_ADDR_BITS-1:0] s1_pc;
  wire [`CPU_ADDR_BITS-1:0] override_pc;
  //wire [4:0] s1_rs1, [4:0] s1_rs2, [4:0] s1_rd;
  wire [11:0] s1_imm_i;
  wire [19:0] s1_imm_uj;
  wire [11:0] s1_imm_bs;
  wire s1_add_rshift_type;

  reg [`CPU_ADDR_BITS-1:0] s3_pc_reg;

  assign rf_raddr0 = s1_rs1;
  assign rf_raddr1 = s1_rs2;

  FetchDecodeStage fetch_decode_stage (
    .clk(clk),
    .reset(reset),
    .s1_pc(s1_pc),
    .s1_imem_addr(icache_addr),
    .s3_pc(s3_pc_reg),
    .override_pc(0),    // TODO(aryap): Not sure if this is necessary or where to connect it.
    .s1_pc_sel(s1_pc_sel),
    .s1_inst(icache_dout),
    .s1_rs1(s1_rs1),
    .s1_rs2(s1_rs2),
    .s1_rd(s1_rd),
    .s1_imm_i(s1_imm_i),
    .s1_imm_uj(s1_imm_uj),
    .s1_imm_bs(s1_imm_bs),
    .s1_opcode(s1_opcode),
    .s1_func(s1_func),
    .s1_add_rshift_type(s1_add_rshift_type)
  );

  // TODO(aryap): CSR can be written immediately in the first stage, since the
  // data is available from the register file. But this violates precise
  // exceptions, if we care about that. The alternative is to propagate the
  // rs1 and csr values through the pipeline stages, which is what we do. But
  // if we can get away with it, it will improve performance to do it early.
  // Maybe.

  //-------------------------------------------------------------------
  // Stage 2
  //-------------------------------------------------------------------

  // S1/S2 pipeline registers.
  //
  // The naming convention is to follow the stage receiving the latched
  // values.
  reg [`CPU_DATA_BITS-1:0] s2_csr_data_reg;
  reg [`CPU_DATA_BITS-1:0] s2_rs1_data_reg;
  reg [`CPU_DATA_BITS-1:0] s2_rs2_data_reg;
  reg [11:0] s2_imm_i_reg;
  reg [19:0] s2_imm_uj_reg;
  reg [11:0] s2_imm_bs_reg;
  reg [`CPU_ADDR_BITS-1:0] s2_pc_reg;
  reg [6:0] s2_opcode_reg;
  reg [2:0] s2_func_reg;
  reg s2_add_rshift_type_reg;
  reg [4:0] s2_rs1_reg;
  reg [4:0] s2_rs2_reg;
  reg [4:0] s2_rd_reg;
  reg [1:0] s2_byte_sel_reg;
  reg s2_s1_fwd_s3_rs1_reg;
  reg s2_s1_fwd_s3_rs2_reg;

  // Forwarding registers.
  reg [`CPU_DATA_BITS-1:0] s3_alu_result_reg;

  assign s2_opcode = s2_opcode_reg;
  assign dcache_re = s2_dmem_re;
  assign s2_rs1 = s2_rs1_reg;
  assign s2_rs2 = s2_rs2_reg;
  assign s2_rd = s2_rd_reg;

  always @(posedge clk) begin
    if (!stall) begin
      // Because we only implement one CSR, we will add custom logic here to
      // connect it instead of another register file. But since it is memory, we
      // don't include in the FetchDecodeStage directly. TODO(aryap): Maybe.
      s2_csr_data_reg <=
          s1_imm_i == 12'h51E && s1_rd != 0 ? csr_tohost_reg : 0;
      s2_rs1_data_reg <= rf_rdata0;
      s2_rs2_data_reg <= rf_rdata1;
      s2_imm_i_reg <= s1_imm_i;
      s2_imm_uj_reg <= s1_imm_uj;
      s2_imm_bs_reg <= s1_imm_bs;
      s2_pc_reg <= s1_pc;
      s2_opcode_reg <= s1_opcode;
      s2_func_reg <= s1_func;
      s2_add_rshift_type_reg <= s1_add_rshift_type;
      s2_rs1_reg <= s1_rs1;
      s2_rs2_reg <= s1_rs2;
      s2_rd_reg <= s1_rd;
      s2_s1_fwd_s3_rs1_reg <= s1_fwd_s3_rs1;
      s2_s1_fwd_s3_rs2_reg <= s1_fwd_s3_rs2;
      // Store the last S3 result for forwarding to the instruction currently
      // in S1 (when it gets to S2).
      s2_s3_result_reg <= rf_wdata;
    end
  end

  wire [`CPU_DATA_BITS-1:0] s2_imm_i_out;
  wire s2_branch;
  wire [`CPU_DATA_BITS-1:0] s2_alu_out;
  wire [`CPU_ADDR_BITS-1:0] s2_pc_out;
  wire [`CPU_DATA_BITS-1:0] s2_rs1_data_eff;
  wire [`CPU_DATA_BITS-1:0] s2_rs2_data_eff;
  wire [`CPU_DATA_BITS-1:0] s2_rs2_data_out;

  // TODO(aryap): Put all of the DMEM signal handling in the Execute stage.
  assign s2_rs1_data_eff = s2_fwd_s3_rs1 ? rf_wdata :
                           s2_s1_fwd_s3_rs1_reg ? s2_s3_result_reg : s2_rs1_data_reg;
  assign s2_rs2_data_eff = s2_fwd_s3_rs2 ? rf_wdata :
                           s2_s1_fwd_s3_rs2_reg ? s2_s3_result_reg : s2_rs2_data_reg;

  assign dcache_addr = s2_alu_out;
  assign s2_func = s2_func_reg;

  // Figure out dmem_we byte mask if dmem writes are enabled.
  always @(*) begin
    s2_byte_sel_reg = s2_alu_out[1:0];
    dcache_din = s2_rs2_data_out;
    case (s2_dmem_we)
      `S2_DMEM_WE_BYTE: begin
        dcache_we = 4'b1 << s2_byte_sel_reg;
        dcache_din = s2_rs2_data_out[7:0] << (s2_byte_sel_reg * 8);
      end
      `S2_DMEM_WE_HALF_WORD: begin
        dcache_we = 4'b11 << s2_byte_sel_reg;
        dcache_din = s2_rs2_data_out[15:0] << (s2_byte_sel_reg * 8);
      end
      `S2_DMEM_WE_WORD: begin
        dcache_we = 4'b1111;
      end
      default: begin
        dcache_we = 0;   // `S2_DMEM_WE_OFF
      end
    endcase
  end

  ExecuteStage execute_stage (
    .clk(clk),
    .reset(reset),
    .s2_rs1_data(s2_rs1_data_eff),
    .s2_rs2_data(s2_rs2_data_eff),
    .s2_imm_i(s2_imm_i_reg),
    .s2_imm_uj(s2_imm_uj_reg),
    .s2_imm_bs(s2_imm_bs_reg),
    .s2_pc(s2_pc_reg),
    .s2_opcode(s2_opcode_reg),
    .s2_func(s2_func_reg),
    .s2_add_rshift_type(s2_add_rshift_type_reg),

    .s2_imm_i_out(s2_imm_i_out),
    .s2_alu_out(s2_alu_out),
    .s2_pc_out(s2_pc_out),
    .s2_rs2_data_out(s2_rs2_data_out),

    .s2_branch(s2_branch),

    // Control signals.
    .s2_alu_a_sel(s2_alu_a_sel),
    .s2_alu_b_sel(s2_alu_b_sel),
    .s2_adder_a_sel(s2_adder_a_sel),
    .s2_adder_b_sel(s2_adder_b_sel),
    .s2_pc_out_sel(s2_pc_out_sel)
  );

  //-------------------------------------------------------------------
  // Stage 3
  //-------------------------------------------------------------------

  // S2/S3 pipeline registers.
  reg [6:0] s3_opcode_reg;
  reg [2:0] s3_func_reg;
  reg s3_branch_reg;
  reg [`CPU_DATA_BITS-1:0] s3_rs1_data_reg;
  reg [`CPU_DATA_BITS-1:0] s3_imm_i_reg;
  // NOTE(aryap): This is instead of a general-purpose second write port for
  // registers or any bypassing.
  reg [`CPU_DATA_BITS-1:0] s3_csr_data_reg;   
  reg [4:0] s3_rs1_reg;
  reg [4:0] s3_rs2_reg;
  reg [4:0] s3_rd_reg;
  reg [1:0] s3_byte_sel_reg;
  
  assign s3_opcode = s3_opcode_reg;
  assign s3_func = s3_func_reg;
  assign s3_branch = s3_branch_reg;
  assign s3_rs1 = s3_rs1_reg;
  assign s3_rs2 = s3_rs2_reg;
  assign s3_rd = s3_rd_reg;

  always @(posedge clk) begin
    if (!stall) begin
      s3_opcode_reg <= s2_opcode;
      s3_func_reg <= s2_func;
      s3_branch_reg <= s2_branch;
      s3_alu_result_reg <= s2_alu_out;
      s3_rs1_data_reg <= s2_rs1_data_eff;
      s3_pc_reg <= s2_pc_out;
      s3_rd_reg <= s2_rd_reg;
      s3_imm_i_reg <= s2_imm_i_out;
      s3_csr_data_reg <= s2_csr_data_reg;
      s3_rs1_reg <= s2_rs1_reg;
      s3_rs2_reg <= s2_rs2_reg;
      s3_byte_sel_reg <= s2_alu_out[1:0];
    end
  end

  wire [`CPU_DATA_BITS-1:0] s3_rdata_out;

  WriteBackStage write_back_stage (
    .clk(clk),
    .reset(reset),
    .byte_select(s3_byte_sel_reg),
    .s3_rdata_sel(s3_rdata_sel),
    .s3_rdata(dcache_dout),
    .s3_rdata_out(s3_rdata_out)
  );

  assign rf_waddr = s3_rd_reg;

  always @(*) begin
    case (s3_reg_wdata_sel)
      `S3_REG_WDATA_SEL_S3_RS1: rf_wdata = s3_rs1_data_reg;
      `S3_REG_WDATA_SEL_S3_RESULT: rf_wdata = s3_alu_result_reg;
      `S3_REG_WDATA_SEL_S3_RDATA_OUT: rf_wdata = s3_rdata_out;
      `S3_REG_WDATA_SEL_S3_CSR_DATA: rf_wdata = s3_csr_data_reg;
      default: rf_wdata = s3_alu_result_reg;
    endcase
  end

  // TODO(aryap): Move this with the other immediate generation in
  // ExecuteStage?
  parameter NUM_IMM_RS1_0_BITS = `CPU_DATA_BITS - 5;
  wire [`CPU_DATA_BITS-1:0] s3_imm_rs1 =
    {{NUM_IMM_RS1_0_BITS{1'b0}}, s3_rs1_reg};

  always @(posedge clk) begin
    if (!stall)
      if (s3_csr_we)
        case (s3_csr_new_data_sel)
          `S3_CSR_NEW_DATA_SEL_IMM_RS1: csr_tohost_reg <= s3_imm_rs1;
          // `S3_CSR_NEW_DATA_SEL_RS1_DATA
          default: csr_tohost_reg <= s3_rs1_data_reg; 
        endcase
  end

endmodule

