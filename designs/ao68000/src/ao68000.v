/* 
 * Copyright 2010, Aleksander Osman, alfik@poczta.fm. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice, this list of
 *     conditions and the following disclaimer.
 *
 *  2. Redistributions in binary form must reproduce the above copyright notice, this list
 *     of conditions and the following disclaimer in the documentation and/or other materials
 *     provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*! \file ao68000.v
 * \brief Main ao68000 IP Core source file.
 */

/***********************************************************************************************************************
 * Definitions of microcode operations - parsed by ao68000_tool to generate the defines in the section below
 **********************************************************************************************************************/
// OPERATIONS START
`define EA_REG_IDLE                                         3'd0
`define EA_REG_IR_2_0                                       3'd1
`define EA_REG_IR_11_9                                      3'd2
`define EA_REG_MOVEM_REG_2_0                                3'd3
`define EA_REG_3b111                                        3'd4
`define EA_REG_3b100                                        3'd5

`define EA_MOD_IDLE                                         4'd0
`define EA_MOD_IR_5_3                                       4'd1
`define EA_MOD_MOVEM_MOD_5_3                                4'd2
`define EA_MOD_IR_8_6                                       4'd3
`define EA_MOD_PREDEC                                       4'd4    // predecrement:    -(An)
`define EA_MOD_3b111                                        4'd5    // extended mod
`define EA_MOD_DN_PREDEC                                    4'd6    // MOD.DN_PREDEC: Dn 3'b000 (ir[3] == 1'b0), -(An) 3'b100 (ir[3] == 1'b1)
`define EA_MOD_DN_AN_EXG                                    4'd7    // MOD.DN_AN_EXG: Dn 3'b000 (ir[7:3] == 5'b01000 or 5'b10001), An 3'b001 (ir[7:3] == 5'b01001)
`define EA_MOD_POSTINC                                      4'd8    // MOD.POSTINC: postincrement (An)+ 3'b011
`define EA_MOD_AN                                           4'd9    // MOD.AN: An 3'b001, saved result is sign-extended
`define EA_MOD_DN                                           4'd10   // MOD.DN: Dn 3'b000
`define EA_MOD_INDIRECTOFFSET                               4'd11   // MOD.INDIRECTOFFSET: (d16, An) 3'b101

`define EA_TYPE_IDLE                                        4'd0
`define EA_TYPE_ALL                                         4'd1    // TYPE.ALL: all
`define EA_TYPE_CONTROL_POSTINC                             4'd2    // TYPE.CONTROL_POSTINC: control or postincrement
`define EA_TYPE_CONTROLALTER_PREDEC                         4'd3    // TYPE.CONTROLALTER_PREDEC: control alter or predecrement
`define EA_TYPE_CONTROL                                     4'd4    // TYPE.CONTROL: control
`define EA_TYPE_DATAALTER                                   4'd5    // TYPE.DATAALTER: data alter
`define EA_TYPE_DN_AN                                       4'd6    // TYPE.DN_AN: Dn, An
`define EA_TYPE_MEMORYALTER                                 4'd7    // TYPE.MEMORYALTER: memory alter
`define EA_TYPE_DATA                                        4'd8    // TYPE.DATA: data

`define OP1_IDLE                                            4'd0
`define OP1_FROM_OP2                                        4'd1    // move from operand2
`define OP1_FROM_ADDRESS                                    4'd2    // move from address
`define OP1_FROM_DATA                                       4'd3    // move from data, sign extend
`define OP1_FROM_IMMEDIATE                                  4'd4    // move immediate, sign extend
`define OP1_FROM_RESULT                                     4'd5    // move from result
`define OP1_MOVEQ                                           4'd6    // move moveq: { 24{ir[7]}, ir[7:0] }
`define OP1_FROM_PC                                         4'd7    // move from PC
`define OP1_LOAD_ZEROS                                      4'd8    // load zeros:  32'b0
`define OP1_LOAD_ONES                                       4'd9    // load ones:   32'hFFFFFFFF
`define OP1_FROM_SR                                         4'd10   // move from SR
`define OP1_FROM_USP                                        4'd11   // move from USP
`define OP1_FROM_AN                                         4'd12   // move from An, 32 bits
`define OP1_FROM_DN                                         4'd13   // move from Dn, sign extend
`define OP1_FROM_IR                                         4'd14   // move from ir[15:0]
`define OP1_FROM_FAULT_ADDRESS                              4'd15   // move from fault_address

`define OP2_IDLE                                            3'd0
`define OP2_FROM_OP1                                        3'd1    // move from operand1
`define OP2_LOAD_1                                          3'd2    // load: 32'b1
`define OP2_LOAD_COUNT                                      3'd3    // load count
`define OP2_ADDQ_SUBQ                                       3'd4    // load addq_subq
`define OP2_MOVE_OFFSET                                     3'd5    // move offset
`define OP2_MOVE_ADDRESS_BUS_INFO                           3'd6    // move address_bus_info
`define OP2_DECR_BY_1                                       3'd7    // decrement by 1

`define ADDRESS_IDLE                                        4'd0
`define ADDRESS_INCR_BY_SIZE                                4'd1    // increment by size
`define ADDRESS_DECR_BY_SIZE                                4'd2    // decrement by size
`define ADDRESS_INCR_BY_2                                   4'd3    // increment by 2
`define ADDRESS_FROM_AN_OUTPUT                              4'd4    // move from An output
`define ADDRESS_FROM_BASE_INDEX_OFFSET                      4'd5    // move from base+index+offset
`define ADDRESS_FROM_IMM_16                                 4'd6    // move from {16{ir1[15]}, ir1[15:0]}
`define ADDRESS_FROM_IMM_32                                 4'd7    // move from {ir1[15:0], ir2[15:0]}
`define ADDRESS_FROM_PC_INDEX_OFFSET                        4'd8    // move from pc+index+offset
`define ADDRESS_FROM_TRAP                                   4'd9    // move trap {22'b0, trap[7:0], 2'b0}

`define SIZE_IDLE                                           4'd0
`define SIZE_BYTE                                           4'd1    // load byte: 3'b001
`define SIZE_WORD                                           4'd2    // load word: 3'b010
`define SIZE_LONG                                           4'd3    // load long: 3'b100
`define SIZE_1                                              4'd4    // SIZE.1: word ( ir[7:6] == 2'b00 ), long ( ir[7:6] == 2'b01 )
`define SIZE_1_PLUS                                         4'd5    // SIZE.1+: word ( ir[7:6] == 2'b10 ), long ( ir[7:6] == 2'b11 )
`define SIZE_2                                              4'd6    // SIZE.2: word ( ir[6] == 1'b0 ), long ( ir[6] == 1'b1 )
`define SIZE_3                                              4'd7    // SIZE.3: byte ( ir[7:6] == 2'b00 ), word ( ir[7:6] == 2'b01 ), long ( ir[7:6] == 2'b10 )
`define SIZE_4                                              4'd8    // SIZE.4: byte ( ir[13:12] == 2'b01 ), word( ir[13:12] == 2'b11 ), long ( ir[13:12] == 2'b10 )
`define SIZE_5                                              4'd9    // SIZE.5: word ( ir[8] == 1'b0 ), long ( ir[8] == 1'b1 )
`define SIZE_6                                              4'd10   // SIZE.6: byte ( ir[5:3] != 3'b000 ), long ( ir[5:3] == 3'b000 )

`define MOVEM_MODREG_IDLE                                   3'd0
`define MOVEM_MODREG_LOAD_0                                 3'd1    // load 6'b0
`define MOVEM_MODREG_LOAD_6b001111                          3'd2    // load 6'b001111
`define MOVEM_MODREG_INCR_BY_1                              3'd3    // increment by 1
`define MOVEM_MODREG_DECR_BY_1                              3'd4    // decrement by 1

`define MOVEM_LOOP_IDLE                                     2'd0
`define MOVEM_LOOP_LOAD_0                                   2'd1    // load 4'b0
`define MOVEM_LOOP_INCR_BY_1                                2'd2    // increment by 1

`define MOVEM_REG_IDLE                                      2'd0
`define MOVEM_REG_FROM_OP1                                  2'd1    // load from operand1[15:0]
`define MOVEM_REG_SHIFT_RIGHT                               2'd2    // shift right

`define IR_IDLE                                             2'd0
`define IR_LOAD_WHEN_PREFETCH_VALID                         2'd1    // load from prefetch_ir[79:64]

`define PC_IDLE                                             3'd0
`define PC_FROM_RESULT                                      3'd1    // move from result
`define PC_INCR_BY_2                                        3'd2    // increment by 2
`define PC_INCR_BY_4                                        3'd3    // increment by 4
`define PC_INCR_BY_SIZE                                     3'd4    // increment by size: 2 (size == 3'b001 || size == 3'b010), 4 (size == 3'b100)
`define PC_FROM_PREFETCH_IR                                 3'd5    // move from prefetch_ir
`define PC_INCR_BY_2_IN_MAIN_LOOP                           3'd6    // increment by 2, in main loop, when valid prefetch and valid instruction

`define TRAP_IDLE                                           4'd0
`define TRAP_ILLEGAL_INSTR                                  4'd1    // move illegal_instr:  8'd4
`define TRAP_DIV_BY_ZERO                                    4'd2    // move divide_by_zero: 8'd5
`define TRAP_CHK                                            4'd3    // move chk:            8'd6
`define TRAP_TRAPV                                          4'd4    // move trapv:          8'd7
`define TRAP_PRIVIL_VIOLAT                                  4'd5    // move priv_viol:      8'd8
`define TRAP_TRACE                                          4'd6    // move trace:          8'd9
`define TRAP_TRAP                                           4'd7    // move trap:           { 3'b0, 1'b1, ir[3:0] }
`define TRAP_FROM_DECODER                                   4'd8    // move from decoder_trap
`define TRAP_FROM_INTERRUPT                                 4'd9    // move from interrupt_trap

`define OFFSET_IDLE                                         2'd0
`define OFFSET_IMM_8                                        2'd1    // { 24{ir1[7]}, ir1[7:0] }
`define OFFSET_IMM_16                                       2'd2    // { 16{ir1[15]}, ir1[15:0] }

`define INDEX_IDLE                                          2'd0
`define INDEX_0                                             2'd1    // 32'b0
`define INDEX_LOAD_EXTENDED                                 2'd2    // load from extended instruction word

`define STOP_FLAG_IDLE                                      2'd0
`define STOP_FLAG_SET                                       2'd1    // set, continue when: trace,interrupt or reset
`define STOP_FLAG_CLEAR                                     2'd2    // clear

`define TRACE_FLAG_IDLE                                     2'd0
`define TRACE_FLAG_COPY_WHEN_NO_STOP                        2'd1    // remember trace bit, move from sr[15]

`define GROUP_0_FLAG_IDLE                                   2'd0
`define GROUP_0_FLAG_SET                                    2'd1    // set, processing group zero exception
`define GROUP_0_FLAG_CLEAR_WHEN_VALID_PREFETCH              2'd2    // clear

`define INSTRUCTION_FLAG_IDLE                               2'd0
`define INSTRUCTION_FLAG_SET                                2'd1    // set, processing instruction
`define INSTRUCTION_FLAG_CLEAR_IN_MAIN_LOOP                 2'd2    // clear, in main loop, when valid prefetch and valid instruction

`define READ_MODIFY_WRITE_FLAG_IDLE                         2'd0
`define READ_MODIFY_WRITE_FLAG_SET                          2'd1    // set, execute a RMW cycle
`define READ_MODIFY_WRITE_FLAG_CLEAR                        2'd2    // clear

`define DO_RESET_FLAG_IDLE                                  2'd0
`define DO_RESET_FLAG_SET                                   2'd1    // set, signal reset
`define DO_RESET_FLAG_CLEAR                                 2'd2    // clear

`define DO_INTERRUPT_FLAG_IDLE                              2'd0
`define DO_INTERRUPT_FLAG_SET_IF_ACTIVE                     2'd1    // set if interrupt active
`define DO_INTERRUPT_FLAG_CLEAR                             2'd2    // clear

`define DO_READ_FLAG_IDLE                                   2'd0
`define DO_READ_FLAG_SET                                    2'd1    // set, perform read operation
`define DO_READ_FLAG_CLEAR                                  2'd2    // clear

`define DO_WRITE_FLAG_IDLE                                  2'd0
`define DO_WRITE_FLAG_SET                                   2'd1    // set, perform write operation
`define DO_WRITE_FLAG_CLEAR                                 2'd2    // clear

`define DO_BLOCKED_FLAG_IDLE                                2'd0
`define DO_BLOCKED_FLAG_SET                                 2'd1    // set, block processor

`define DATA_WRITE_IDLE                                     2'd0
`define DATA_WRITE_FROM_RESULT                              2'd1    // load data write register from result register

`define AN_ADDRESS_IDLE                                     2'd0    // load from ea_reg, user or supervisor
`define AN_ADDRESS_FROM_EXTENDED                            2'd1    // load from extended instruction word: ir1[14:12], user or supervisor
`define AN_ADDRESS_USP                                      2'd2    // load USP address
`define AN_ADDRESS_SSP                                      2'd3    // load SSP address

`define AN_WRITE_ENABLE_IDLE                                1'd0
`define AN_WRITE_ENABLE_SET                                 1'd1    // set write enable on An register

`define AN_INPUT_IDLE                                       2'd0    // load from result
`define AN_INPUT_FROM_ADDRESS                               2'd1    // load from address
`define AN_INPUT_FROM_PREFETCH_IR                           2'd2    // load from prefetch_ir, for reset, for SSP

`define DN_ADDRESS_IDLE                                     1'd0    // load from ea_reg
`define DN_ADDRESS_FROM_EXTENDED                            1'd1    // load from extended instruction word: ir1[14:12]

`define DN_WRITE_ENABLE_IDLE                                1'd0
`define DN_WRITE_ENABLE_SET                                 1'd1    // set write enable on Dn register

`define ALU_IDLE                                            5'd0
`define ALU_SR_SET_INTERRUPT                                5'd1
`define ALU_SR_SET_TRAP                                     5'd2
`define ALU_MOVEP_M2R_1                                     5'd3
`define ALU_MOVEP_M2R_2                                     5'd4
`define ALU_MOVEP_M2R_3                                     5'd5
`define ALU_MOVEP_M2R_4                                     5'd6
`define ALU_MOVEP_R2M_1                                     5'd7
`define ALU_MOVEP_R2M_2                                     5'd8
`define ALU_MOVEP_R2M_3                                     5'd9
`define ALU_MOVEP_R2M_4                                     5'd10
`define ALU_SIGN_EXTEND                                     5'd11
`define ALU_ARITHMETIC_LOGIC                                5'd12
`define ALU_ABCD_SBCD_ADDX_SUBX_prepare                     5'd13
`define ALU_ABCD_SBCD_ADDX_SUBX                             5'd14
`define ALU_ASL_LSL_ROL_ROXL_ASR_LSR_ROR_ROXR_prepare       5'd15
`define ALU_ASL_LSL_ROL_ROXL_ASR_LSR_ROR_ROXR               5'd16
`define ALU_MOVE                                            5'd17
`define ALU_ADDA_SUBA_CMPA_ADDQ_SUBQ                        5'd18
`define ALU_CHK                                             5'd19
`define ALU_MULS_MULU_DIVS_DIVU                             5'd20
`define ALU_BCHG_BCLR_BSET_BTST                             5'd21
`define ALU_TAS                                             5'd22
`define ALU_NEGX_CLR_NEG_NOT_NBCD_SWAP_EXT                  5'd23
`define ALU_SIMPLE_LONG_ADD                                 5'd24
`define ALU_SIMPLE_LONG_SUB                                 5'd25
`define ALU_MOVE_TO_CCR_SR_RTE_RTR_STOP_LOGIC_TO_CCR_SR     5'd26
`define ALU_SIMPLE_MOVE                                     5'd27
`define ALU_LINK_MOVE                                       5'd28

`define BRANCH_IDLE                                         4'd0
`define BRANCH_movem_loop                                   4'd1    // BRANCH(movem_loop == 4'b1000)
`define BRANCH_movem_reg                                    4'd2    // BRANCH(movem_reg[0] == 0)
`define BRANCH_operand2                                     4'd3    // BRANCH(operand2[5:0] == 6'b0)
`define BRANCH_alu_signal                                   4'd4    // BRANCH(alu_signal == 1'b0)
`define BRANCH_alu_mult_div_ready                           4'd5    // BRANCH(alu_mult_div_ready == 1'b1)
`define BRANCH_condition_0                                  4'd6    // BRANCH(condition == 1'b0)
`define BRANCH_condition_1                                  4'd7    // BRANCH(condition == 1'b1)
`define BRANCH_result                                       4'd8    // BRANCH(result[15:0] == 16'hFFFF)
`define BRANCH_V                                            4'd9    // BRANCH(V == 1'b0)
`define BRANCH_movep_16                                     4'd10   // BRANCH(ir[6] == 0)
`define BRANCH_stop_flag_wait_ir_decode                     4'd11   // BRANCH(stop_flag == 1'b1) if no branch: wait for prefetch ir valid and decode instruction
`define BRANCH_ir                                           4'd12   // BRANCH(ir[7:0] != 8'b0)
`define BRANCH_trace_flag_and_interrupt                     4'd13   // BRANCH(trace_flag == 1'b0 && interrupt_mask != 3'b000) if no branch: jump to main loop
`define BRANCH_group_0_flag                                 4'd14   // BRANCH(group_0_flag == 0)
`define BRANCH_procedure                                    4'd15   // call procedure, return from procedure

`define PROCEDURE_IDLE                                      4'd0
`define PROCEDURE_call_load_ea                              4'd1    // load ea
`define PROCEDURE_call_perform_ea_read                      4'd2    // perform_ea_read
`define PROCEDURE_call_perform_ea_write                     4'd3    // perform_ea_write
`define PROCEDURE_call_save_ea                              4'd4    // save ea
`define PROCEDURE_return                                    4'd5    // return from procedure
`define PROCEDURE_wait_finished                             4'd6    // wait for finished signal from bus controler
`define PROCEDURE_wait_prefetch_valid                       4'd7    // wait for prefetch ir valid, 64 bits
`define PROCEDURE_wait_prefetch_valid_32                    4'd8    // wait for prefetch ir valid, 32 bits
`define PROCEDURE_jump_to_main_loop                         4'd9    // jump to main loop
`define PROCEDURE_push_micropc                              4'd10   // save current micro_pc
`define PROCEDURE_call_trap                                 4'd11   // call trap service procedure
`define PROCEDURE_pop_micropc                               4'd12   // pop most recent micro_pc and forget
`define PROCEDURE_interrupt_mask                            4'd13   // if interrupt active continue, else jump to main loop
`define PROCEDURE_call_read                                 4'd14   // load_ea + perform_ea_read
`define PROCEDURE_call_write                                4'd15   // perform_ea_write + save_ea + return
// OPERATIONS END

/***********************************************************************************************************************
 * Automatically generated by ao68000_tool microcode word bit assignments and addresses
 **********************************************************************************************************************/
// MICROCODE - DO NOT EDIT BELOW
`define MICRO_DATA_ea_reg                                                            micro_data[2:0]
`define MICRO_DATA_ea_mod                                                            micro_data[6:3]
`define MICRO_DATA_ea_type                                                           micro_data[10:7]
`define MICRO_DATA_op1                                                               micro_data[14:11]
`define MICRO_DATA_op2                                                               micro_data[17:15]
`define MICRO_DATA_address                                                           micro_data[21:18]
`define MICRO_DATA_size                                                              micro_data[25:22]
`define MICRO_DATA_movem_modreg                                                      micro_data[28:26]
`define MICRO_DATA_movem_loop                                                        micro_data[30:29]
`define MICRO_DATA_movem_reg                                                         micro_data[32:31]
`define MICRO_DATA_ir                                                                micro_data[34:33]
`define MICRO_DATA_pc                                                                micro_data[37:35]
`define MICRO_DATA_trap                                                              micro_data[41:38]
`define MICRO_DATA_offset                                                            micro_data[43:42]
`define MICRO_DATA_index                                                             micro_data[45:44]
`define MICRO_DATA_stop_flag                                                         micro_data[47:46]
`define MICRO_DATA_trace_flag                                                        micro_data[49:48]
`define MICRO_DATA_group_0_flag                                                      micro_data[51:50]
`define MICRO_DATA_instruction_flag                                                  micro_data[53:52]
`define MICRO_DATA_read_modify_write_flag                                            micro_data[55:54]
`define MICRO_DATA_do_reset_flag                                                     micro_data[57:56]
`define MICRO_DATA_do_interrupt_flag                                                 micro_data[59:58]
`define MICRO_DATA_do_read_flag                                                      micro_data[61:60]
`define MICRO_DATA_do_write_flag                                                     micro_data[63:62]
`define MICRO_DATA_do_blocked_flag                                                   micro_data[65:64]
`define MICRO_DATA_data_write                                                        micro_data[67:66]
`define MICRO_DATA_an_address                                                        micro_data[69:68]
`define MICRO_DATA_an_write_enable                                                   micro_data[70:70]
`define MICRO_DATA_an_input                                                          micro_data[72:71]
`define MICRO_DATA_dn_address                                                        micro_data[73:73]
`define MICRO_DATA_dn_write_enable                                                   micro_data[74:74]
`define MICRO_DATA_alu                                                               micro_data[79:75]
`define MICRO_DATA_branch                                                            micro_data[83:80]
`define MICRO_DATA_procedure                                                         micro_data[87:84]

`define MICROPC_MOVE                                                                 9'd232
`define MICROPC_MOVE_USP_to_An                                                       9'd401
`define MICROPC_TAS                                                                  9'd333
`define MICROPC_BSR                                                                  9'd431
`define MICROPC_ADDRESS_BUS_TRAP                                                     9'd3
`define MICROPC_MOVEP_register_to_memory                                             9'd106
`define MICROPC_NEGX_CLR_NEG_NOT_NBCD                                                9'd338
`define MICROPC_RTS                                                                  9'd472
`define MICROPC_MAIN_LOOP                                                            9'd53
`define MICROPC_ADDA_SUBA                                                            9'd269
`define MICROPC_MOVE_TO_CCR_MOVE_TO_SR                                               9'd392
`define MICROPC_MOVE_FROM_SR                                                         9'd389
`define MICROPC_LOAD_EA_d8_PC_Xn                                                     9'd79
`define MICROPC_TRAP_ENTRY                                                           9'd35
`define MICROPC_PERFORM_EA_READ_memory                                               9'd89
`define MICROPC_RESET                                                                9'd486
`define MICROPC_PERFORM_EA_WRITE_Dn                                                  9'd91
`define MICROPC_ASL_LSL_ROL_ROXL_ASR_LSR_ROR_ROXR_all_memory                         9'd226
`define MICROPC_MOVEA                                                                9'd240
`define MICROPC_TST                                                                  9'd345
`define MICROPC_BTST_register                                                        9'd327
`define MICROPC_LOAD_EA_d8_An_Xn                                                     9'd68
`define MICROPC_MULS_MULU_DIVS_DIVU                                                  9'd291
`define MICROPC_MOVEQ                                                                9'd308
`define MICROPC_CMPA                                                                 9'd276
`define MICROPC_EOR                                                                  9'd246
`define MICROPC_LOAD_EA_xxx_W                                                        9'd72
`define MICROPC_DBcc                                                                 9'd375
`define MICROPC_CMPI                                                                 9'd184
`define MICROPC_LOAD_EA_xxx_L                                                        9'd74
`define MICROPC_CMPM                                                                 9'd206
`define MICROPC_MOVE_USP_to_USP                                                      9'd396
`define MICROPC_ADDQ_SUBQ_not_An                                                     9'd349
`define MICROPC_ULNK                                                                 9'd420
`define MICROPC_EXG                                                                  9'd198
`define MICROPC_ADD_to_mem_SUB_to_mem_AND_to_mem_OR_to_mem                           9'd251
`define MICROPC_Bcc_BRA                                                              9'd363
`define MICROPC_PERFORM_EA_READ_An                                                   9'd86
`define MICROPC_LOAD_EA_d16_PC                                                       9'd76
`define MICROPC_NOP                                                                  9'd480
`define MICROPC_MOVEM_register_to_memory_predecrement                                9'd131
`define MICROPC_RTE_RTR                                                              9'd460
`define MICROPC_TRAP                                                                 9'd481
`define MICROPC_ADDQ_SUBQ_An                                                         9'd352
`define MICROPC_MOVEM_register_to_memory_control                                     9'd147
`define MICROPC_BTST_immediate                                                       9'd316
`define MICROPC_MOVEP_memory_to_register                                             9'd98
`define MICROPC_PERFORM_EA_WRITE_An                                                  9'd92
`define MICROPC_CHK                                                                  9'd282
`define MICROPC_Scc                                                                  9'd356
`define MICROPC_JMP                                                                  9'd443
`define MICROPC_PEA                                                                  9'd168
`define MICROPC_SAVE_EA_minus_An                                                     9'd97
`define MICROPC_ANDI_EORI_ORI_ADDI_SUBI                                              9'd174
`define MICROPC_BCHG_BCLR_BSET_immediate                                             9'd311
`define MICROPC_LOAD_EA_An                                                           9'd62
`define MICROPC_PERFORM_EA_READ_imm                                                  9'd87
`define MICROPC_ADD_to_Dn_SUB_to_Dn_AND_to_Dn_OR_to_Dn                               9'd256
`define MICROPC_LEA                                                                  9'd162
`define MICROPC_TRAPV                                                                9'd483
`define MICROPC_LINK                                                                 9'd404
`define MICROPC_ABCD_SBCD_ADDX_SUBX                                                  9'd189
`define MICROPC_BCHG_BCLR_BSET_register                                              9'd322
`define MICROPC_PERFORM_EA_READ_Dn                                                   9'd85
`define MICROPC_LOAD_EA_illegal_command                                              9'd83
`define MICROPC_ORI_to_CCR_ORI_to_SR_ANDI_to_CCR_ANDI_to_SR_EORI_to_CCR_EORI_to_SR   9'd178
`define MICROPC_CMP                                                                  9'd263
`define MICROPC_SWAP_EXT                                                             9'd341
`define MICROPC_STOP                                                                 9'd489
`define MICROPC_PERFORM_EA_WRITE_memory                                              9'd93
`define MICROPC_JSR                                                                  9'd451
`define MICROPC_LOAD_EA_minus_An                                                     9'd63
`define MICROPC_ASL_LSL_ROL_ROXL_ASR_LSR_ROR_ROXR_all_immediate_register             9'd213
`define MICROPC_SAVE_EA_An_plus                                                      9'd95
`define MICROPC_LOAD_EA_d16_An                                                       9'd65
`define MICROPC_LOAD_EA_An_plus                                                      9'd62
`define MICROPC_MOVEM_memory_to_register                                             9'd116
// MICROCODE - DO NOT EDIT ABOVE

/***********************************************************************************************************************
 * ao68000 top level module
 **********************************************************************************************************************/

/*! \brief ao68000 top level module.
 *
 * This module contains only instantiations of sub-modules and wire declarations.
 */
module ao68000 (
    //****************** WISHBONE
    input           CLK_I,              //% \copydoc CLK_I
    input           reset_n,            //% \copydoc reset_n

    output          CYC_O,              //% \copydoc CYC_O
    output  [31:2]  ADR_O,              //% \copydoc ADR_O
    output  [31:0]  DAT_O,              //% \copydoc DAT_O
    input   [31:0]  DAT_I,              //% \copydoc DAT_I
    output  [3:0]   SEL_O,              //% \copydoc SEL_O
    output          STB_O,              //% \copydoc STB_O
    output          WE_O,               //% \copydoc WE_O

    input           ACK_I,              //% \copydoc ACK_I
    input           ERR_I,              //% \copydoc ERR_I
    input           RTY_I,              //% \copydoc RTY_I

    // TAG_TYPE: TGC_O
    output          SGL_O,              //% \copydoc SGL_O
    output          BLK_O,              //% \copydoc BLK_O
    output          RMW_O,              //% \copydoc RMW_O

    // TAG_TYPE: TGA_O
    output [2:0]    CTI_O,              //% \copydoc CTI_O
    output [1:0]    BTE_O,              //% \copydoc BTE_O

    // TAG_TYPE: TGC_O
    output [2:0]    fc_o,               //% \copydoc fc_o
    
    //****************** OTHER
    /* interrupt acknowlege:
     * ACK_I: interrupt vector on DAT_I[7:0]
     * ERR_I: spurious interrupt
     * RTY_I: autovector
     */
    input [2:0]     ipl_i,              //% \copydoc ipl_i
    output          reset_o,            //% \copydoc reset_o
    output          blocked_o           //% \copydoc blocked_o
);

wire [15:0] sr;
wire [2:0]  size;
wire [31:0] address;
wire        address_type;
wire        read_modify_write_flag;
wire [31:0] data_read;
wire [31:0] data_write;
wire [31:0] pc;
wire        prefetch_ir_valid;
wire [79:0] prefetch_ir;
wire        do_reset;
wire        do_read;
wire        do_write;
wire        do_interrupt;
wire        do_blocked;
wire        jmp_address_trap;
wire        jmp_bus_trap;
wire        finished;
wire [7:0]  interrupt_trap;
wire [2:0]  interrupt_mask;
wire        rw_state;
wire [2:0]  fc_state;
wire [7:0]  decoder_trap;
wire [31:0] usp;
wire [31:0] Dn_output;
wire [31:0] An_output;
wire [31:0] result;
wire [3:0]  An_address;
wire [31:0] An_input;
wire [2:0]  Dn_address;
wire [15:0] ir;
wire [8:0]  decoder_micropc;
wire        alu_signal;
wire        alu_mult_div_ready;
wire [8:0]  load_ea;
wire [8:0]  perform_ea_read;
wire [8:0]  perform_ea_write;
wire [8:0]  save_ea;
wire        trace_flag;
wire        group_0_flag;
wire        stop_flag;
wire [8:0]  micro_pc;
wire [31:0] operand1;
wire [31:0] operand2;
wire [4:0]  movem_loop;
wire [15:0] movem_reg;
wire        condition;
wire [87:0] micro_data;
wire [31:0] fault_address_state;
wire [1:0]  pc_change;
wire        prefetch_ir_valid_32;
wire [3:0]  ea_type;
wire [2:0]  ea_mod;
wire [2:0]  ea_reg;
wire [17:0] decoder_alu;
wire [17:0] decoder_alu_reg;

bus_control bus_control_m(
    .CLK_I                  (CLK_I),
    .reset_n                (reset_n),
    .CYC_O                  (CYC_O),
    .ADR_O                  (ADR_O),
    .DAT_O                  (DAT_O),
    .DAT_I                  (DAT_I),
    .SEL_O                  (SEL_O),
    .STB_O                  (STB_O),
    .WE_O                   (WE_O),
    .ACK_I                  (ACK_I),
    .ERR_I                  (ERR_I),
    .RTY_I                  (RTY_I),
    .SGL_O                  (SGL_O),
    .BLK_O                  (BLK_O),
    .RMW_O                  (RMW_O),
    .CTI_O                  (CTI_O),
    .BTE_O                  (BTE_O),
    .fc_o                   (fc_o),
    .ipl_i                  (ipl_i),
    .reset_o                (reset_o),
    .blocked_o              (blocked_o),

    .supervisor_i           (sr[13]),
    .ipm_i                  (sr[10:8]),
    .size_i                 (size),
    .address_i              (address),
    .address_type_i         (address_type),
    .read_modify_write_i    (read_modify_write_flag),
    .data_write_i           (data_write),
    .data_read_o            (data_read),
    .pc_i                   (pc),
    .pc_change_i            (pc_change),
    .prefetch_ir_o          (prefetch_ir),
    .prefetch_ir_valid_32_o (prefetch_ir_valid_32),
    .prefetch_ir_valid_o    (prefetch_ir_valid),
    .prefetch_ir_valid_80_o (),
    .do_reset_i             (do_reset),
    .do_blocked_i           (do_blocked),
    .do_read_i              (do_read),
    .do_write_i             (do_write),
    .do_interrupt_i         (do_interrupt),
    .jmp_address_trap_o     (jmp_address_trap),
    .jmp_bus_trap_o         (jmp_bus_trap),
    .finished_o             (finished),
    .interrupt_trap_o       (interrupt_trap),
    .interrupt_mask_o       (interrupt_mask),
    .rw_state_o             (rw_state),
    .fc_state_o             (fc_state),
    .fault_address_state_o  (fault_address_state)
);

registers registers_m(
    .clock                          (CLK_I),
    .reset_n                        (reset_n),
    .data_read                      (data_read),
    .prefetch_ir                    (prefetch_ir),
    .prefetch_ir_valid              (prefetch_ir_valid),
    .result                         (result),
    .sr                             (sr),
    .rw_state                       (rw_state),
    .fc_state                       (fc_state),
    .fault_address_state            (fault_address_state),
    .interrupt_trap                 (interrupt_trap),
    .interrupt_mask                 (interrupt_mask),
    .decoder_trap                   (decoder_trap),
    .usp                            (usp),
    .Dn_output                      (Dn_output),
    .An_output                      (An_output),

    .pc_change                      (pc_change),

    .ea_reg                         (ea_reg),
    .ea_reg_control                 (`MICRO_DATA_ea_reg),
    .ea_mod                         (ea_mod),
    .ea_mod_control                 (`MICRO_DATA_ea_mod),
    .ea_type                        (ea_type),
    .ea_type_control                (`MICRO_DATA_ea_type),
    .operand1                       (operand1),
    .operand1_control               (`MICRO_DATA_op1),
    .operand2                       (operand2),
    .operand2_control               (`MICRO_DATA_op2),
    .address                        (address),
    .address_type                   (address_type),
    .address_control                (`MICRO_DATA_address),
    .size                           (size),
    .size_control                   (`MICRO_DATA_size),
    .movem_modreg                   (),
    .movem_modreg_control           (`MICRO_DATA_movem_modreg),
    .movem_loop                     (movem_loop),
    .movem_loop_control             (`MICRO_DATA_movem_loop),
    .movem_reg                      (movem_reg),
    .movem_reg_control              (`MICRO_DATA_movem_reg),
    .ir                             (ir),
    .ir_control                     (`MICRO_DATA_ir),
    .pc                             (pc),
    .pc_control                     (`MICRO_DATA_pc),
    .trap                           (),
    .trap_control                   (`MICRO_DATA_trap),
    .offset                         (),
    .offset_control                 (`MICRO_DATA_offset),
    .index                          (),
    .index_control                  (`MICRO_DATA_index),
    .stop_flag                      (stop_flag),
    .stop_flag_control              (`MICRO_DATA_stop_flag),
    .trace_flag                     (trace_flag),
    .trace_flag_control             (`MICRO_DATA_trace_flag),
    .group_0_flag                   (group_0_flag),
    .group_0_flag_control           (`MICRO_DATA_group_0_flag),
    .instruction_flag               (),
    .instruction_flag_control       (`MICRO_DATA_instruction_flag),
    .read_modify_write_flag         (read_modify_write_flag),
    .read_modify_write_flag_control (`MICRO_DATA_read_modify_write_flag),
    .do_reset_flag                  (do_reset),
    .do_reset_flag_control          (`MICRO_DATA_do_reset_flag),
    .do_interrupt_flag              (do_interrupt),
    .do_interrupt_flag_control      (`MICRO_DATA_do_interrupt_flag),
    .do_read_flag                   (do_read),
    .do_read_flag_control           (`MICRO_DATA_do_read_flag),
    .do_write_flag                  (do_write),
    .do_write_flag_control          (`MICRO_DATA_do_write_flag),
    .do_blocked_flag                (do_blocked),
    .do_blocked_flag_control        (`MICRO_DATA_do_blocked_flag),
    .data_write                     (data_write),
    .data_write_control             (`MICRO_DATA_data_write),
    .An_address                     (An_address),
    .An_address_control             (`MICRO_DATA_an_address),
    .An_input                       (An_input),
    .An_input_control               (`MICRO_DATA_an_input),
    .Dn_address                     (Dn_address),
    .Dn_address_control             (`MICRO_DATA_dn_address),
    .decoder_alu                    (decoder_alu),
    .decoder_alu_reg                (decoder_alu_reg)
);

memory_registers memory_registers_m(
    .clock              (CLK_I),
    .reset_n            (reset_n),
    .An_address         (An_address),
    .An_input           (An_input),
    .An_write_enable    (`MICRO_DATA_an_write_enable),
    .An_output          (An_output),
    .usp                (usp),
    .Dn_address         (Dn_address),
    .Dn_input           (result),
    .Dn_write_enable    (`MICRO_DATA_dn_write_enable),
    .Dn_size            (size),
    .Dn_output          (Dn_output),
    .micro_pc           (micro_pc),
    .micro_data         (micro_data)
);

decoder decoder_m(
    .clock              (CLK_I),
    .reset_n            (reset_n),
    .supervisor         (sr[13]),
    .ir                 (prefetch_ir[79:64]),
    .decoder_trap       (decoder_trap),
    .decoder_micropc    (decoder_micropc),
    .decoder_alu        (decoder_alu),
    
    .load_ea            (load_ea),
    .perform_ea_read    (perform_ea_read),
    .perform_ea_write   (perform_ea_write),
    .save_ea            (save_ea),
    
    .ea_type            (ea_type),
    .ea_mod             (ea_mod),
    .ea_reg             (ea_reg)
);

condition condition_m(
    .cond               (ir[11:8]),
    .ccr                (sr[7:0]),
    .condition          (condition)
);

alu alu_m(
    .clock              (CLK_I),
    .reset_n            (reset_n),
    .address            (address),
    .ir                 (ir),
    .size               (size),
    .operand1           (operand1),
    .operand2           (operand2),
    .interrupt_mask     (interrupt_mask),
    .alu_control        (`MICRO_DATA_alu),
    .sr                 (sr),
    .result             (result),
    .alu_signal         (alu_signal),
    .alu_mult_div_ready (alu_mult_div_ready),
    .decoder_alu_reg    (decoder_alu_reg)
);

microcode_branch microcode_branch_m(
    .clock                  (CLK_I),
    .reset_n                (reset_n),
    .movem_loop             (movem_loop),
    .movem_reg              (movem_reg),
    .operand2               (operand2),
    .alu_signal             (alu_signal),
    .alu_mult_div_ready     (alu_mult_div_ready),
    .condition              (condition),
    .result                 (result),
    .overflow               (sr[1]),
    .stop_flag              (stop_flag),
    .ir                     (ir),
    .decoder_trap           (decoder_trap),
    .trace_flag             (trace_flag),
    .group_0_flag           (group_0_flag),
    .interrupt_mask         (interrupt_mask),
    .load_ea                (load_ea),
    .perform_ea_read        (perform_ea_read),
    .perform_ea_write       (perform_ea_write),
    .save_ea                (save_ea),
    .decoder_micropc        (decoder_micropc),
    .prefetch_ir_valid_32   (prefetch_ir_valid_32),
    .prefetch_ir_valid      (prefetch_ir_valid),
    .jmp_address_trap       (jmp_address_trap),
    .jmp_bus_trap           (jmp_bus_trap),
    .finished               (finished),
    .branch_control         (`MICRO_DATA_branch),
    .branch_offset          (`MICRO_DATA_procedure),
    .micro_pc               (micro_pc)
);

endmodule

/***********************************************************************************************************************
 * Bus control
 **********************************************************************************************************************/

/*! \brief Initiate WISHBONE MASTER bus cycles.
 *
 * The bus_control module is the only module that has contact with signals from outside of the IP core.
 * It is responsible for initiating WISHBONE MASTER bus cycles. The cycles can be divided into:
 *  - memory read cycles (supervisor data, supervisor program, user data, user program)
 *  - memory write cycles (supervisor data, user data),
 *  - interrupt acknowledge.
 *
 * Every cycle is supplemented with the following tags:
 *  - standard WISHBONE cycle tags: SGL_O, BLK_O, RMW_O,
 *  - register feedback WISHBONE address tags: CTI_O and BTE_O,
 *  - ao68000 specific cycle tag: fc_o which is equivalent to  MC68000 function codes.
 *
 * The bus_control module is also responsible for registering interrupt inputs and initiating the interrupt acknowledge
 * cycle in response to a microcode request. Microcode requests a interrupt acknowledge at the end of instruction
 * processing, when the interrupt privilege level is higher than the current interrupt privilege mask, as specified
 * in the MC68000 User's Manual.
 *
 * Finally, bus_control controls also two ao68000 specific core outputs:
 *  - blocked output,  high when that the processor is blocked after encountering a double bus error. The only way
 *    to leave this block state is by reseting the ao68000 by the asynchronous reset input signal.
 *  - reset output, high when processing the RESET instruction. Can be used to reset external devices.
 */
module bus_control(
    //******************************************* external
    //****************** WISHBONE
    input CLK_I,
    input reset_n,

    output reg CYC_O,
    output reg [31:2] ADR_O,
    output reg [31:0] DAT_O,
    input [31:0] DAT_I,
    output reg [3:0] SEL_O,
    output reg STB_O,
    output reg WE_O,

    input ACK_I,
    input ERR_I,
    input RTY_I,

    // TAG_TYPE: TGC_O
    output reg SGL_O,
    output reg BLK_O,
    output reg RMW_O,

    // TAG_TYPE: TGA_O
    output reg [2:0] CTI_O,
    output [1:0] BTE_O,

    // TAG_TYPE: TGC_O
    output reg [2:0] fc_o,

    //****************** OTHER
    input [2:0] ipl_i,
    output reg reset_o = 1'b0,
    output reg blocked_o = 1'b0,

    //******************************************* internal
    input supervisor_i,
    input [2:0] ipm_i,
    input [2:0] size_i,
    input [31:0] address_i,
    input address_type_i,
    input read_modify_write_i,
    input [31:0] data_write_i,
    output reg [31:0] data_read_o,

    input [31:0] pc_i,
    input [1:0] pc_change_i,
    output reg [79:0] prefetch_ir_o,
    output reg prefetch_ir_valid_32_o = 1'b0,
    output reg prefetch_ir_valid_o = 1'b0,
    output reg prefetch_ir_valid_80_o = 1'b0,

    input do_reset_i,
    input do_blocked_i,
    input do_read_i,
    input do_write_i,
    input do_interrupt_i,

    output reg jmp_address_trap_o = 1'b0,
    output reg jmp_bus_trap_o = 1'b0,
    // read/write/interrupt
    output reg finished_o,

    output reg [7:0] interrupt_trap_o = 8'b0,
    output reg [2:0] interrupt_mask_o = 3'b0,

    /* mask==0 && trap==0            nothing
     * mask!=0                        interrupt with spurious interrupt
     */

    // write = 0/read = 1
    output reg rw_state_o,
    output reg [2:0] fc_state_o,
    output reg [31:0] fault_address_state_o
);

assign BTE_O = 2'b00;

wire [31:0] pc_i_plus_6;
assign pc_i_plus_6 = pc_i + 32'd6;
wire [31:0] pc_i_plus_4;
assign pc_i_plus_4 = pc_i + 32'd4;

wire [31:0] address_i_plus_4;
assign address_i_plus_4 = address_i + 32'd4;

reg [1:0] saved_pc_change = 2'b00;

parameter [4:0]
    S_INIT      = 5'd0,
    S_RESET     = 5'd1,
    S_BLOCKED   = 5'd2,
    S_INT_1     = 5'd3,
    S_READ_1    = 5'd4,
    S_READ_2    = 5'd5,
    S_READ_3    = 5'd6,
    S_WAIT      = 5'd7,
    S_WRITE_1   = 5'd8,
    S_WRITE_2   = 5'd9,
    S_WRITE_3   = 5'd10,
    S_PC_0      = 5'd11,
    S_PC_1      = 5'd12,
    S_PC_2      = 5'd13,
    S_PC_3      = 5'd14,
    S_PC_4      = 5'd15,
    S_PC_5      = 5'd16,
    S_PC_6      = 5'd17;

parameter [2:0]
    FC_USER_DATA            = 3'd1,
    FC_USER_PROGRAM         = 3'd2,
    FC_SUPERVISOR_DATA      = 3'd5,        // all exception vector entries except reset
    FC_SUPERVISOR_PROGRAM   = 3'd6,        // exception vector for reset
    FC_CPU_SPACE            = 3'd7;        // interrupt acknowlege bus cycle

parameter [2:0]
    CTI_CLASSIC_CYCLE       = 3'd0,
    CTI_CONST_CYCLE         = 3'd1,
    CTI_INCR_CYCLE          = 3'd2,
    CTI_END_OF_BURST        = 3'd7;

parameter [7:0]
    VECTOR_BUS_TRAP         = 8'd2,
    VECTOR_ADDRESS_TRAP     = 8'd3;

reg [4:0] current_state;
reg [7:0] reset_counter;

reg [2:0] last_interrupt_mask;
always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        interrupt_mask_o <= 3'b000;
        last_interrupt_mask <= 3'b000;
    end
    else if(ipl_i > ipm_i && do_interrupt_i == 1'b0) begin
        interrupt_mask_o <= ipl_i;
        last_interrupt_mask <= interrupt_mask_o;
    end
    else if(do_interrupt_i == 1'b1) begin
        interrupt_mask_o <= last_interrupt_mask;
    end
    else begin
        interrupt_mask_o <= 3'b000;
        last_interrupt_mask <= 3'b000;
    end
end

// change pc_i in middle of prefetch operation: undefined

always @(posedge CLK_I or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        current_state <= S_INIT;
        interrupt_trap_o <= 8'd0;
        prefetch_ir_valid_o <= 1'b0;
        prefetch_ir_valid_32_o <= 1'b0;
        prefetch_ir_valid_80_o <= 1'b0;

        jmp_address_trap_o <= 1'b0;
        jmp_bus_trap_o <= 1'b0;
        
        CYC_O <= 1'b0;
        ADR_O <= 30'd0;
        DAT_O <= 32'd0;
        SEL_O <= 4'b0;
        STB_O <= 1'b0;
        WE_O <= 1'b0;
        SGL_O <= 1'b0;
        BLK_O <= 1'b0;
        RMW_O <= 1'b0;
        CTI_O <= 3'd0;
        fc_o <= 3'd0;
        reset_o <= 1'b0;
        blocked_o <= 1'b0;
        data_read_o <= 32'd0;
        finished_o <= 1'b0;
        rw_state_o <= 1'b0;
        fc_state_o <= 3'd0;
        fault_address_state_o <= 32'd0;
        saved_pc_change <= 2'b0;
        reset_counter <= 8'd0;
    end
    else begin
        case(current_state)
            S_INIT: begin
                finished_o <= 1'b0;
                jmp_address_trap_o <= 1'b0;
                jmp_bus_trap_o <= 1'b0;
                reset_o <= 1'b0;
                blocked_o <= 1'b0;

                // block
                if(do_blocked_i == 1'b1) begin
                    blocked_o <= 1'b1;
                    current_state <= S_BLOCKED;
                end
                // reset
                else if(do_reset_i == 1'b1) begin
                    reset_o <= 1'b1;
                    reset_counter <= 8'd124;
                    current_state <= S_RESET;
                end
                // read
                else if(do_read_i == 1'b1) begin
                    WE_O <= 1'b0;
                    if(supervisor_i == 1'b1)    fc_o <= (address_type_i == 1'b0) ? FC_SUPERVISOR_DATA : FC_SUPERVISOR_PROGRAM;
                    else                        fc_o <= (address_type_i == 1'b0) ? FC_USER_DATA : FC_USER_PROGRAM;

                    if(address_i[0] == 1'b1 && (size_i[0] == 1'b0)) begin // WORD or LONG WORD
                        fault_address_state_o <= address_i;
                        rw_state_o <= 1'b1;
                        fc_state_o <= (supervisor_i == 1'b1) ?  ((address_type_i == 1'b0) ? FC_SUPERVISOR_DATA : FC_SUPERVISOR_PROGRAM) :
                                                                ((address_type_i == 1'b0) ? FC_USER_DATA : FC_USER_PROGRAM);
                        interrupt_trap_o <= VECTOR_ADDRESS_TRAP;

                        jmp_address_trap_o <= 1'b1;
                        current_state <= S_WAIT;
                    end
                    else begin
                        CYC_O <= 1'b1;
                        ADR_O <= address_i[31:2];
                        SEL_O <=    (size_i[0] == 1'b1 && address_i[1:0] == 2'b00)? 4'b1000 :
                                    (size_i[0] == 1'b1 && address_i[1:0] == 2'b01)? 4'b0100 :
                                    (size_i[0] == 1'b1 && address_i[1:0] == 2'b10)? 4'b0010 :
                                    (size_i[0] == 1'b1 && address_i[1:0] == 2'b11)? 4'b0001 :
                                    (size_i[1] == 1'b1 && address_i[1] == 2'b0)?    4'b1100 :
                                    (size_i[0] == 1'b0 && address_i[1] == 2'b1)?    4'b0011 :
                                                                                    4'b1111;
                        STB_O <= 1'b1;

                        if(read_modify_write_i == 1'b1) begin
                            SGL_O <= 1'b0;
                            BLK_O <= 1'b0;
                            RMW_O <= 1'b1;
                            CTI_O <= CTI_END_OF_BURST;
                        end
                        else if(address_i[1:0] == 2'b10 && size_i[2] == 1'b1) begin
                            SGL_O <= 1'b0;
                            BLK_O <= 1'b1;
                            RMW_O <= 1'b0;
                            CTI_O <= CTI_INCR_CYCLE;
                        end
                        else begin
                            SGL_O <= 1'b1;
                            BLK_O <= 1'b0;
                            RMW_O <= 1'b0;
                            CTI_O <= CTI_END_OF_BURST;
                        end

                        current_state <= S_READ_1;
                    end
                end
                // write
                else if(do_write_i == 1'b1) begin
                    WE_O <= 1'b1;
                    if(supervisor_i == 1'b1)    fc_o <= FC_SUPERVISOR_DATA;
                    else                        fc_o <= FC_USER_DATA;

                    if(address_i[0] == 1'b1 && size_i[0] == 1'b0) begin // WORD or LONG WORD
                        fault_address_state_o <= address_i;
                        rw_state_o <= 1'b0;
                        fc_state_o <= (supervisor_i == 1'b1) ? FC_SUPERVISOR_DATA : FC_USER_DATA;
                        interrupt_trap_o <= VECTOR_ADDRESS_TRAP;

                        jmp_address_trap_o <= 1'b1;
                        current_state <= S_WAIT;
                    end
                    else begin
                        CYC_O <= 1'b1;
                        ADR_O <= address_i[31:2];
                        STB_O <= 1'b1;

                        if(address_i[1:0] == 2'b10 && size_i[2] == 1'b1) begin
                            DAT_O <= { 16'b0, data_write_i[31:16] };
                            SEL_O <= 4'b0011;
                        end
                        else if(address_i[1:0] == 2'b00 && size_i[2] == 1'b1) begin
                            DAT_O <= data_write_i[31:0];
                            SEL_O <= 4'b1111;
                        end
                        else if(address_i[1:0] == 2'b10 && size_i[1] == 1'b1) begin
                            DAT_O <= { 16'b0, data_write_i[15:0] };
                            SEL_O <= 4'b0011;
                        end
                        else if(address_i[1:0] == 2'b00 && size_i[1] == 1'b1) begin
                            DAT_O <= { data_write_i[15:0], 16'b0 };
                            SEL_O <= 4'b1100;
                        end
                        else if(address_i[1:0] == 2'b11 && size_i[0] == 1'b1) begin
                            DAT_O <= { 24'b0, data_write_i[7:0] };
                            SEL_O <= 4'b0001;
                        end
                        else if(address_i[1:0] == 2'b10 && size_i[0] == 1'b1) begin
                            DAT_O <= { 16'b0, data_write_i[7:0], 8'b0 };
                            SEL_O <= 4'b0010;
                        end
                        else if(address_i[1:0] == 2'b01 && size_i[0] == 1'b1) begin
                            DAT_O <= { 8'b0, data_write_i[7:0], 16'b0 };
                            SEL_O <= 4'b0100;
                        end
                        else if(address_i[1:0] == 2'b00 && size_i[0] == 1'b1) begin
                            DAT_O <= { data_write_i[7:0], 24'b0 };
                            SEL_O <= 4'b1000;
                        end

                        if(read_modify_write_i == 1'b1) begin
                            SGL_O <= 1'b0;
                            BLK_O <= 1'b0;
                            RMW_O <= 1'b1;
                            CTI_O <= CTI_END_OF_BURST;
                        end
                        else if(address_i[1:0] == 2'b10 && size_i[2] == 1'b1) begin
                            SGL_O <= 1'b0;
                            BLK_O <= 1'b1;
                            RMW_O <= 1'b0;
                            CTI_O <= CTI_INCR_CYCLE;
                        end
                        else begin
                            SGL_O <= 1'b1;
                            BLK_O <= 1'b0;
                            RMW_O <= 1'b0;
                            CTI_O <= CTI_END_OF_BURST;
                        end

                        current_state <= S_WRITE_1;
                    end
                end
                // pc
                else if(prefetch_ir_valid_o == 1'b0 || pc_change_i != 2'b00) begin

                    if(prefetch_ir_valid_o == 1'b0 || pc_change_i == 2'b10 || pc_change_i == 2'b11) begin
                        // load 4 words: [79:16] in 2,3 cycles
                        prefetch_ir_valid_32_o <= 1'b0;
                        prefetch_ir_valid_o <= 1'b0;
                        prefetch_ir_valid_80_o <= 1'b0;

                        current_state <= S_PC_0;
                    end
                    else if(prefetch_ir_valid_80_o == 1'b0 && pc_change_i == 2'b01) begin
                        // load 2 words: [31:0] in 1 cycle
                        prefetch_ir_valid_32_o <= 1'b1;
                        prefetch_ir_valid_o <= 1'b0;
                        prefetch_ir_valid_80_o <= 1'b0;

                        prefetch_ir_o <= { prefetch_ir_o[63:0], 16'b0 };
                        current_state <= S_PC_0;
                    end
                    else begin
                        // do not load any words
                        prefetch_ir_valid_32_o <= 1'b1;
                        prefetch_ir_valid_o <= 1'b1;
                        prefetch_ir_valid_80_o <= 1'b0;

                        prefetch_ir_o <= { prefetch_ir_o[63:0], 16'b0 };
                    end


                end
                // interrupt
                else if(do_interrupt_i == 1'b1) begin
                    CYC_O <= 1'b1;
                    ADR_O <= { 27'b111_1111_1111_1111_1111_1111_1111, last_interrupt_mask };
                    SEL_O <= 4'b1111;
                    STB_O <= 1'b1;
                    WE_O <= 1'b0;

                    SGL_O <= 1'b1;
                    BLK_O <= 1'b0;
                    RMW_O <= 1'b0;
                    CTI_O <= CTI_END_OF_BURST;

                    fc_o <= FC_CPU_SPACE;

                    current_state <= S_INT_1;
                end
            end

            S_RESET: begin
                reset_counter <= reset_counter - 8'd1;

                if(reset_counter == 8'd0) begin
                    finished_o <= 1'b1;
                    current_state <= S_WAIT;
                end
            end

            S_BLOCKED: begin
            end

            S_INT_1: begin
                if(ACK_I == 1'b1) begin
                    CYC_O <= 1'b0;
                    STB_O <= 1'b0;

                    interrupt_trap_o <= DAT_I[7:0];

                    finished_o <= 1'b1;
                    current_state <= S_WAIT;
                end
                else if(RTY_I == 1'b1) begin
                    CYC_O <= 1'b0;
                    STB_O <= 1'b0;

                    interrupt_trap_o <= 8'd24 + { 5'b0, interrupt_mask_o };

                    finished_o <= 1'b1;
                    current_state <= S_WAIT;
                end
                else if(ERR_I == 1'b1) begin
                    CYC_O <= 1'b0;
                    STB_O <= 1'b0;

                    interrupt_trap_o <= 8'd24; // spurious interrupt

                    finished_o <= 1'b1;
                    current_state <= S_WAIT;
                end
            end

            S_PC_0: begin
                WE_O <= 1'b0;
                if(supervisor_i == 1'b1)    fc_o <= FC_SUPERVISOR_PROGRAM;
                else                        fc_o <= FC_USER_PROGRAM;

                if(pc_i[0] == 1'b1) begin
                    prefetch_ir_valid_32_o <= 1'b1;
                    prefetch_ir_valid_o <= 1'b1;
                    prefetch_ir_valid_80_o <= 1'b1;

                    fault_address_state_o <= pc_i;
                    rw_state_o <= 1'b1;
                    fc_state_o <= (supervisor_i == 1'b1) ? FC_SUPERVISOR_PROGRAM : FC_USER_PROGRAM;
                    interrupt_trap_o <= VECTOR_ADDRESS_TRAP;

                    jmp_address_trap_o <= 1'b1;
                    current_state <= S_WAIT;
                end
                else begin
                    CYC_O <= 1'b1;
                    
                    if(prefetch_ir_valid_32_o == 1'b0)                      ADR_O <= pc_i[31:2];
                    else                                                    ADR_O <= pc_i_plus_6[31:2];
                    
                    SEL_O <= (prefetch_ir_valid_32_o == 1'b0 && pc_i[1:0] == 2'b10)?    4'b0011 :
                                                                                        4'b1111;
                    STB_O <= 1'b1;

                    if(prefetch_ir_valid_32_o == 1'b0) begin
                        SGL_O <= 1'b0;
                        BLK_O <= 1'b1;
                        RMW_O <= 1'b0;
                        CTI_O <= CTI_INCR_CYCLE;
                    end
                    else begin
                        SGL_O <= 1'b1;
                        BLK_O <= 1'b0;
                        RMW_O <= 1'b0;
                        CTI_O <= CTI_END_OF_BURST;
                    end

                    saved_pc_change <= pc_change_i;
                    prefetch_ir_valid_32_o <= 1'b0;

                    current_state <= S_PC_1;
                end
            end

            S_PC_1: begin
                if(pc_change_i != 2'b00) saved_pc_change <= pc_change_i;

                if(ACK_I == 1'b1) begin
                    if(CTI_O == CTI_INCR_CYCLE) begin
                        //CYC_O <= 1'b1;
                        ADR_O <= pc_i_plus_4[31:2];
                        SEL_O <= 4'b1111;
                        //STB_O <= 1'b1;
                        //WE_O <= 1'b0;

                        if(pc_i[1:0] == 2'b10) begin
                            SGL_O <= 1'b0;
                            BLK_O <= 1'b1;
                            RMW_O <= 1'b0;
                            CTI_O <= CTI_INCR_CYCLE;
                        end
                        else begin
                            SGL_O <= 1'b0;
                            BLK_O <= 1'b1;
                            RMW_O <= 1'b0;
                            CTI_O <= CTI_END_OF_BURST;
                        end

                        //if(supervisor_i == 1'b1)    fc_o <= FC_SUPERVISOR_PROGRAM;
                        //else                        fc_o <= FC_USER_PROGRAM;

                        if(pc_i[1:0] == 2'b10)      prefetch_ir_o <= { DAT_I[15:0], 64'b0 };
                        else                        prefetch_ir_o <= { DAT_I[31:0], 48'b0 };

                        current_state <= S_PC_3;
                    end
                    else begin
                        CYC_O <= 1'b0;
                        STB_O <= 1'b0;

                        if(saved_pc_change == 2'b10 || saved_pc_change == 2'b11 || pc_change_i == 2'b10 || pc_change_i == 2'b11) begin
                            // load 4 words: [79:16] in 2,3 cycles
                            prefetch_ir_valid_32_o <= 1'b0;
                            prefetch_ir_valid_o <= 1'b0;
                            prefetch_ir_valid_80_o <= 1'b0;

                            current_state <= S_PC_0;
                        end
                        else if(saved_pc_change == 2'b01 || pc_change_i == 2'b01) begin
                            // do not load any words
                            prefetch_ir_valid_32_o <= 1'b1;
                            prefetch_ir_valid_o <= 1'b1;
                            prefetch_ir_valid_80_o <= 1'b0;

                            prefetch_ir_o <= { prefetch_ir_o[63:32], DAT_I[31:0], 16'b0 };
                            current_state <= S_INIT;
                        end
                        else begin
                            prefetch_ir_valid_32_o <= 1'b1;
                            prefetch_ir_valid_o <= 1'b1;
                            prefetch_ir_valid_80_o <= 1'b1;

                            prefetch_ir_o <= { prefetch_ir_o[79:32], DAT_I[31:0] };
                            current_state <= S_INIT;
                        end
                    end
                end
                else if(RTY_I == 1'b1) begin
                    CYC_O <= 1'b0;
                    STB_O <= 1'b0;

                    current_state <= S_PC_2;
                end
                else if(ERR_I == 1'b1) begin
                    CYC_O <= 1'b0;
                    STB_O <= 1'b0;

                    fault_address_state_o <= { ADR_O, 2'b00 };
                    rw_state_o <= ~WE_O;
                    fc_state_o <= fc_o;
                    interrupt_trap_o <= VECTOR_BUS_TRAP;

                    jmp_bus_trap_o <= 1'b1;
                    current_state <= S_WAIT;
                end
            end
            S_PC_2: begin
                CYC_O <= 1'b1;
                STB_O <= 1'b1;

                current_state <= S_PC_1;
            end
            S_PC_3: begin
                if(ACK_I == 1'b1) begin
                    if(pc_i[1:0] == 2'b10) begin
                        //CYC_O <= 1'b1;
                        ADR_O <= pc_i_plus_6[31:2];
                        SEL_O <= 4'b1111;
                        //STB_O <= 1'b1;
                        //WE_O <= 1'b0;

                        SGL_O <= 1'b0;
                        BLK_O <= 1'b1;
                        RMW_O <= 1'b0;
                        CTI_O <= CTI_END_OF_BURST;

                        //if(supervisor_i == 1'b1)    fc_o <= FC_SUPERVISOR_PROGRAM;
                        //else                        fc_o <= FC_USER_PROGRAM;

                        prefetch_ir_o <= { prefetch_ir_o[79:64], DAT_I[31:0], 32'b0 };

                        current_state <= S_PC_5;
                    end
                    else begin
                        CYC_O <= 1'b0;
                        STB_O <= 1'b0;

                        prefetch_ir_o <= { prefetch_ir_o[79:48], DAT_I[31:0], 16'b0 };

                        prefetch_ir_valid_32_o <= 1'b1;
                        prefetch_ir_valid_o <= 1'b1;
                        prefetch_ir_valid_80_o <= 1'b0;
                        current_state <= S_INIT;
                    end
                end
                else if(RTY_I == 1'b1) begin
                    CYC_O <= 1'b0;
                    STB_O <= 1'b0;

                    current_state <= S_PC_4;
                end
                else if(ERR_I == 1'b1) begin
                    CYC_O <= 1'b0;
                    STB_O <= 1'b0;

                    fault_address_state_o <= { ADR_O, 2'b00 };
                    rw_state_o <= ~WE_O;
                    fc_state_o <= fc_o;
                    interrupt_trap_o <= VECTOR_BUS_TRAP;

                    jmp_bus_trap_o <= 1'b1;
                    current_state <= S_WAIT;
                end
            end
            S_PC_4: begin
                CYC_O <= 1'b1;
                STB_O <= 1'b1;

                current_state <= S_PC_3;
            end
            S_PC_5: begin
                if(ACK_I == 1'b1) begin
                    CYC_O <= 1'b0;
                    STB_O <= 1'b0;

                    prefetch_ir_o <= { prefetch_ir_o[79:32], DAT_I[31:0] };

                    prefetch_ir_valid_32_o <= 1'b1;
                    prefetch_ir_valid_o <= 1'b1;
                    prefetch_ir_valid_80_o <= 1'b1;
                    current_state <= S_INIT;
                end
                else if(RTY_I == 1'b1) begin
                    CYC_O <= 1'b0;
                    STB_O <= 1'b0;

                    current_state <= S_PC_6;
                end
                else if(ERR_I == 1'b1) begin
                    CYC_O <= 1'b0;
                    STB_O <= 1'b0;

                    fault_address_state_o <= { ADR_O, 2'b00 };
                    rw_state_o <= ~WE_O;
                    fc_state_o <= fc_o;
                    interrupt_trap_o <= VECTOR_BUS_TRAP;

                    jmp_bus_trap_o <= 1'b1;
                    current_state <= S_WAIT;
                end
            end
            S_PC_6: begin
                CYC_O <= 1'b1;
                STB_O <= 1'b1;

                current_state <= S_PC_5;
            end

            //*******************
            S_READ_1: begin
                if(ACK_I == 1'b1) begin
                    if(address_i[1:0] == 2'b10 && size_i[2] == 1'b1) begin
                        //CYC_O <= 1'b1;
                        ADR_O <= address_i_plus_4[31:2];
                        SEL_O <= 4'b1100;
                        //STB_O <= 1'b1;
                        //WE_O <= 1'b0;

                        //SGL_O <= 1'b0;
                        //BLK_O <= 1'b1;
                        //RMW_O <= 1'b0;
                        CTI_O <= CTI_END_OF_BURST;

                        //if(supervisor_i == 1'b1)    fc_o <= (address_type_i == 1'b0) ? FC_SUPERVISOR_DATA : FC_SUPERVISOR_PROGRAM;
                        //else                        fc_o <= (address_type_i == 1'b0) ? FC_USER_DATA : FC_USER_PROGRAM;

                        data_read_o <= { DAT_I[15:0], 16'b0 };

                        current_state <= S_READ_2;
                    end
                    else begin
                        if(read_modify_write_i == 1'b1) begin
                            CYC_O <= 1'b1;
                            STB_O <= 1'b0;
                        end
                        else begin
                            CYC_O <= 1'b0;
                            STB_O <= 1'b0;
                        end

                        if(address_i[1:0] == 2'b00 && size_i[2] == 1'b1)             data_read_o <= DAT_I[31:0];
                        else if(address_i[1:0] == 2'b10 && size_i[1] == 1'b1)        data_read_o <= { {16{DAT_I[15]}}, DAT_I[15:0] };
                        else if(address_i[1:0] == 2'b00 && size_i[1] == 1'b1)        data_read_o <= { {16{DAT_I[31]}}, DAT_I[31:16] };
                        else if(address_i[1:0] == 2'b11 && size_i[0] == 1'b1)        data_read_o <= { {24{DAT_I[7]}}, DAT_I[7:0] };
                        else if(address_i[1:0] == 2'b10 && size_i[0] == 1'b1)        data_read_o <= { {24{DAT_I[15]}}, DAT_I[15:8] };
                        else if(address_i[1:0] == 2'b01 && size_i[0] == 1'b1)        data_read_o <= { {24{DAT_I[23]}}, DAT_I[23:16] };
                        else if(address_i[1:0] == 2'b00 && size_i[0] == 1'b1)        data_read_o <= { {24{DAT_I[31]}}, DAT_I[31:24] };

                        finished_o <= 1'b1;
                        current_state <= S_WAIT;
                    end
                end
                else if(RTY_I == 1'b1) begin
                    CYC_O <= 1'b0;
                    STB_O <= 1'b0;

                    current_state <= S_INIT;
                end
                else if(ERR_I == 1'b1) begin
                    CYC_O <= 1'b0;
                    STB_O <= 1'b0;

                    fault_address_state_o <= { ADR_O, 2'b00 };
                    rw_state_o <= ~WE_O;
                    fc_state_o <= fc_o;
                    interrupt_trap_o <= VECTOR_BUS_TRAP;

                    jmp_bus_trap_o <= 1'b1;
                    current_state <= S_WAIT;
                end
            end
            S_READ_2: begin
                if(ACK_I == 1'b1) begin
                    CYC_O <= 1'b0;
                    STB_O <= 1'b0;

                    data_read_o <= { data_read_o[31:16], DAT_I[31:16] };

                    finished_o <= 1'b1;
                    current_state <= S_WAIT;

                end
                else if(RTY_I == 1'b1) begin
                    CYC_O <= 1'b0;
                    STB_O <= 1'b0;

                    current_state <= S_READ_3;
                end
                else if(ERR_I == 1'b1) begin
                    CYC_O <= 1'b0;
                    STB_O <= 1'b0;

                    fault_address_state_o <= { ADR_O, 2'b00 };
                    rw_state_o <= ~WE_O;
                    fc_state_o <= fc_o;
                    interrupt_trap_o <= VECTOR_BUS_TRAP;

                    jmp_bus_trap_o <= 1'b1;
                    current_state <= S_WAIT;
                end

            end
            S_READ_3: begin
                CYC_O <= 1'b1;
                STB_O <= 1'b1;

                current_state <= S_READ_2;
            end


            S_WAIT: begin
                jmp_address_trap_o <= 1'b0;
                jmp_bus_trap_o <= 1'b0;

                if(do_read_i == 1'b0 && do_write_i == 1'b0 && do_interrupt_i == 1'b0 && do_reset_i == 1'b0) begin
                    finished_o <= 1'b0;
                    current_state <= S_INIT;
                end
            end

            //**********************
            S_WRITE_1: begin
                if(ACK_I == 1'b1) begin
                    if(address_i[1:0] == 2'b10 && size_i[2] == 1'b1) begin
                        //CYC_O <= 1'b1;
                        ADR_O <= address_i_plus_4[31:2];
                        //STB_O <= 1'b1;
                        //WE_O <= 1'b1;

                        DAT_O <= { data_write_i[15:0], 16'b0 };
                        SEL_O <= 4'b1100;

                        //SGL_O <= 1'b0;
                        //BLK_O <= 1'b1;
                        //RMW_O <= 1'b0;
                        CTI_O <= CTI_END_OF_BURST;

                        //if(supervisor_i == 1'b1)    fc_o <= FC_SUPERVISOR_DATA;
                        //else                        fc_o <= FC_USER_DATA;

                        current_state <= S_WRITE_2;
                    end
                    else begin
                        CYC_O <= 1'b0;
                        STB_O <= 1'b0;

                        finished_o <= 1'b1;
                        current_state <= S_WAIT;
                    end
                end
                else if(RTY_I == 1'b1) begin
                    CYC_O <= 1'b0;
                    STB_O <= 1'b0;

                    current_state <= S_INIT;
                end
                else if(ERR_I == 1'b1) begin
                    CYC_O <= 1'b0;
                    STB_O <= 1'b0;

                    fault_address_state_o <= { ADR_O, 2'b00 };
                    rw_state_o <= ~WE_O;
                    fc_state_o <= fc_o;
                    interrupt_trap_o <= VECTOR_BUS_TRAP;

                    jmp_bus_trap_o <= 1'b1;
                    current_state <= S_WAIT;
                end

            end
            S_WRITE_2: begin
                if(ACK_I == 1'b1) begin
                    CYC_O <= 1'b0;
                    STB_O <= 1'b0;

                    finished_o <= 1'b1;
                    current_state <= S_WAIT;

                end
                else if(RTY_I == 1'b1) begin
                    CYC_O <= 1'b0;
                    STB_O <= 1'b0;

                    current_state <= S_WRITE_3;
                end
                else if(ERR_I == 1'b1) begin
                    CYC_O <= 1'b0;
                    STB_O <= 1'b0;

                    fault_address_state_o <= { ADR_O, 2'b00 };
                    rw_state_o <= ~WE_O;
                    fc_state_o <= fc_o;
                    interrupt_trap_o <= VECTOR_BUS_TRAP;

                    jmp_bus_trap_o <= 1'b1;
                    current_state <= S_WAIT;
                end

            end
            S_WRITE_3: begin
                CYC_O <= 1'b1;
                STB_O <= 1'b1;

                current_state <= S_WRITE_2;
            end

        endcase
    end
end

endmodule

/***********************************************************************************************************************
 * Registers
 **********************************************************************************************************************/

/*! \brief Microcode controlled registers.
 *
 * Most of the ao68000 IP core registers are located in this module. At every clock cycle the microcode controls what
 * to save into these registers. Some of the more important registers include:
 *  - operand1, operand2 registers are inputs to the ALU,
 *  - address, size, do_read_flag, do_write_flag, do_interrupt_flag registers tell the bus_control module what kind
 *    of bus cycle to perform,
 *  - pc register stores the current program counter,
 *  - ir register stores the current instruction word,
 *  - ea_mod, ea_type registers store the currently selected addressing mode.
 */
module registers(
    input clock,
    input reset_n,

    input [31:0] data_read,
    input [79:0] prefetch_ir,
    input prefetch_ir_valid,
    input [31:0] result,
    input [15:0] sr,
    input rw_state,
    input [2:0] fc_state,
    input [31:0] fault_address_state,
    input [7:0] interrupt_trap,
    input [2:0] interrupt_mask,
    input [7:0] decoder_trap,

    input [31:0] usp,
    input [31:0] Dn_output,
    input [31:0] An_output,

    output [1:0] pc_change,

    output reg [2:0] ea_reg,
    input [2:0] ea_reg_control,

    output reg [2:0] ea_mod,
    input [3:0] ea_mod_control,

    output reg [3:0] ea_type,
    input [3:0] ea_type_control,

    // for DIVU/DIVS simulation, register must be not zero
    output reg [31:0] operand1 = 32'hFFFFFFFF,
    input [3:0] operand1_control,

    output reg [31:0] operand2 = 32'hFFFFFFFF,
    input [2:0] operand2_control,

    output reg [31:0] address,
    output reg address_type,
    input [3:0] address_control,

    output reg [2:0] size,
    input [3:0] size_control,

    output reg [5:0] movem_modreg,
    input [2:0] movem_modreg_control,

    output reg [4:0] movem_loop,
    input [1:0] movem_loop_control,

    output reg [15:0] movem_reg,
    input [1:0] movem_reg_control,

    output reg [15:0] ir,
    input [1:0] ir_control,

    output reg [31:0] pc,
    input [2:0] pc_control,

    output reg [7:0] trap,
    input [3:0] trap_control,

    output reg [31:0] offset,
    input [1:0] offset_control,

    output reg [31:0] index,
    input [1:0] index_control,


    output reg stop_flag,
    input [1:0] stop_flag_control,

    output reg trace_flag,
    input [1:0] trace_flag_control,

    output reg group_0_flag,
    input [1:0] group_0_flag_control,

    output reg instruction_flag,
    input [1:0] instruction_flag_control,

    output reg read_modify_write_flag,
    input [1:0] read_modify_write_flag_control,

    output reg do_reset_flag,
    input [1:0] do_reset_flag_control,

    output reg do_interrupt_flag,
    input [1:0] do_interrupt_flag_control,

    output reg do_read_flag,
    input [1:0] do_read_flag_control,

    output reg do_write_flag,
    input [1:0] do_write_flag_control,

    output reg do_blocked_flag,
    input [1:0] do_blocked_flag_control,

    output reg [31:0] data_write,
    input [1:0] data_write_control,


    output [3:0] An_address,
    input [1:0] An_address_control,

    output [31:0] An_input,
    input [1:0] An_input_control,

    output [2:0] Dn_address,
    input Dn_address_control,
    
    input [17:0] decoder_alu,
    output reg [17:0] decoder_alu_reg
);

reg [31:0] pc_valid;

wire [31:0] pc_next =
    (pc_control == `PC_FROM_RESULT)?        result :
    (pc_control == `PC_INCR_BY_2)?          pc + 32'd2 :
    (pc_control == `PC_INCR_BY_4)?          pc + 32'd4 :
    (pc_control == `PC_INCR_BY_SIZE)?       (size[2] == 1'b0) ? pc + 32'd2 : pc + 32'd4 :
    (pc_control == `PC_FROM_PREFETCH_IR)?   prefetch_ir[47:16] :
    (pc_control == `PC_INCR_BY_2_IN_MAIN_LOOP && prefetch_ir_valid == 1'b1 && decoder_trap == 8'd0 && stop_flag == 1'b0)?
                                            pc + 32'd2 :
                                            pc;

// pc_change connected
always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        pc <= 32'd0;
        pc_valid <= 32'd0;
    end
    else begin
        pc <= pc_next;
        
        if(pc_next[0] == 1'b0)  pc_valid <= pc_next;
    end
end

assign pc_change =
    (    pc_control == `PC_FROM_RESULT || pc_control == `PC_FROM_PREFETCH_IR
    ) ? 2'b11 :
    (    pc_control == `PC_INCR_BY_4 || (pc_control == `PC_INCR_BY_SIZE && size[2] == 1'b1)
    ) ? 2'b10 :
    (    pc_control == `PC_INCR_BY_2 || (pc_control == `PC_INCR_BY_SIZE && size[2] == 1'b0) ||
        (pc_control == `PC_INCR_BY_2_IN_MAIN_LOOP && prefetch_ir_valid == 1'b1 && decoder_trap == 8'd0 && stop_flag == 1'b0)
    ) ? 2'b01 :
    2'b00;

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        size <= 2'b00;
    end
    else if(size_control != `SIZE_IDLE) begin
        // BYTE
        size[0] <= (size_control == `SIZE_BYTE)
                | ((size_control == `SIZE_3) && (ir[7:6] == 2'b00))
                | ((size_control == `SIZE_4) && (ir[13:12] == 2'b01))
                | ((size_control == `SIZE_6) && (ir[5:3] != 3'b000));
        // WORD
        size[1] <= (size_control == `SIZE_WORD)
                | ((size_control == `SIZE_1) && (ir[7:6] == 2'b00))
                | ((size_control == `SIZE_1_PLUS) && (ir[7:6] == 2'b10))
                | ((size_control == `SIZE_2) && (ir[6] == 1'b0))
                | ((size_control == `SIZE_3) && (ir[7:6] == 2'b01))
                | ((size_control == `SIZE_4) && (ir[13:12] == 2'b11))
                | ((size_control == `SIZE_5) && (ir[8] == 1'b0));
        // LONG
        size[2] <= (size_control == `SIZE_LONG)
                | ((size_control == `SIZE_1) && (ir[7:6] != 2'b00))
                | ((size_control == `SIZE_1_PLUS) && (ir[7:6] != 2'b10))
                | ((size_control == `SIZE_2) && (ir[6] == 1'b1))
                | ((size_control == `SIZE_3) && (ir[7] == 1'b1))
                | ((size_control == `SIZE_4) && (ir[12] == 1'b0))
                | ((size_control == `SIZE_5) && (ir[8] == 1'b1))
                | ((size_control == `SIZE_6) && (ir[5:3] == 3'b000));
    end
end

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0)                                         ea_reg <= 3'b000;
    else if(ea_reg_control == `EA_REG_IR_2_0)                   ea_reg <= ir[2:0];
    else if(ea_reg_control == `EA_REG_IR_11_9)                  ea_reg <= ir[11:9];
    else if(ea_reg_control == `EA_REG_MOVEM_REG_2_0)            ea_reg <= movem_modreg[2:0];
    else if(ea_reg_control == `EA_REG_3b111)                    ea_reg <= 3'b111;
    else if(ea_reg_control == `EA_REG_3b100)                    ea_reg <= 3'b100;
end

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0)                                         ea_mod <= 3'b000;
    else if(ea_mod_control == `EA_MOD_IR_5_3)                   ea_mod <= ir[5:3];
    else if(ea_mod_control == `EA_MOD_MOVEM_MOD_5_3)            ea_mod <= movem_modreg[5:3];
    else if(ea_mod_control == `EA_MOD_IR_8_6)                   ea_mod <= ir[8:6];
    else if(ea_mod_control == `EA_MOD_PREDEC)                   ea_mod <= 3'b100;
    else if(ea_mod_control == `EA_MOD_3b111)                    ea_mod <= 3'b111;
    else if(ea_mod_control == `EA_MOD_DN_PREDEC)                ea_mod <= (ir[3] == 1'b0) ? /* Dn */ 3'b000 : /* -(An) */ 3'b100;
    else if(ea_mod_control == `EA_MOD_DN_AN_EXG)                ea_mod <= (ir[7:3] == 5'b01000 || ir[7:3] == 5'b10001) ? /* Dn */ 3'b000 : /* An */ 3'b001;
    else if(ea_mod_control == `EA_MOD_POSTINC)                  ea_mod <= 3'b011;
    else if(ea_mod_control == `EA_MOD_AN)                       ea_mod <= 3'b001;
    else if(ea_mod_control == `EA_MOD_DN)                       ea_mod <= 3'b000;
    else if(ea_mod_control == `EA_MOD_INDIRECTOFFSET)           ea_mod <= 3'b101;
end

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0)                                         ea_type <= `EA_TYPE_IDLE;
    else if(ea_type_control == `EA_TYPE_ALL)                    ea_type <= `EA_TYPE_ALL;
    else if(ea_type_control == `EA_TYPE_CONTROL_POSTINC)        ea_type <= `EA_TYPE_CONTROL_POSTINC;
    else if(ea_type_control == `EA_TYPE_CONTROLALTER_PREDEC)    ea_type <= `EA_TYPE_CONTROLALTER_PREDEC;
    else if(ea_type_control == `EA_TYPE_CONTROL)                ea_type <= `EA_TYPE_CONTROL;
    else if(ea_type_control == `EA_TYPE_DATAALTER)              ea_type <= `EA_TYPE_DATAALTER;
    else if(ea_type_control == `EA_TYPE_DN_AN)                  ea_type <= `EA_TYPE_DN_AN;
    else if(ea_type_control == `EA_TYPE_MEMORYALTER)            ea_type <= `EA_TYPE_MEMORYALTER;
    else if(ea_type_control == `EA_TYPE_DATA)                   ea_type <= `EA_TYPE_DATA;
end

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0)                                         operand1 <= 32'hFFFFFFFF;
    else if(operand1_control == `OP1_FROM_OP2)                  operand1 <= operand2;
    else if(operand1_control == `OP1_FROM_ADDRESS)              operand1 <= address;
    else if(operand1_control == `OP1_FROM_DATA)                 operand1 <=
                                                                    (size[0] == 1'b1) ? { {24{data_read[7]}}, data_read[7:0] } :
                                                                    (size[1] == 1'b1) ? { {16{data_read[15]}}, data_read[15:0] } :
                                                                    data_read[31:0];
    else if(operand1_control == `OP1_FROM_IMMEDIATE)            operand1 <=
                                                                    (size[0] == 1'b1) ? { {24{prefetch_ir[71]}}, prefetch_ir[71:64] } :
                                                                    (size[1] == 1'b1) ? { {16{prefetch_ir[79]}}, prefetch_ir[79:64] } :
                                                                    prefetch_ir[79:48];
    else if(operand1_control == `OP1_FROM_RESULT)               operand1 <= result;
    else if(operand1_control == `OP1_MOVEQ)                     operand1 <= { {24{ir[7]}}, ir[7:0] };
    else if(operand1_control == `OP1_FROM_PC)                   operand1 <= pc_valid;
    else if(operand1_control == `OP1_LOAD_ZEROS)                operand1 <= 32'b0;
    else if(operand1_control == `OP1_LOAD_ONES)                 operand1 <= 32'hFFFFFFFF;
    else if(operand1_control == `OP1_FROM_SR)                   operand1 <= { 16'b0, sr[15], 1'b0, sr[13], 2'b0, sr[10:8], 3'b0, sr[4:0] };
    else if(operand1_control == `OP1_FROM_USP)                  operand1 <= usp;
    else if(operand1_control == `OP1_FROM_AN)                   operand1 <= 
                                                                    (size[1] == 1'b1) ? { {16{An_output[15]}}, An_output[15:0] } :
                                                                    An_output[31:0];
    else if(operand1_control == `OP1_FROM_DN)                   operand1 <=
                                                                    (size[0] == 1'b1) ? { {24{Dn_output[7]}}, Dn_output[7:0] } :
                                                                    (size[1] == 1'b1) ? { {16{Dn_output[15]}}, Dn_output[15:0] } :
                                                                    Dn_output[31:0];
    else if(operand1_control == `OP1_FROM_IR)                   operand1 <= { 16'b0, ir[15:0] };
    else if(operand1_control == `OP1_FROM_FAULT_ADDRESS)        operand1 <= fault_address_state;
end

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0)                                         operand2 <= 32'hFFFFFFFF;
    else if(operand2_control == `OP2_FROM_OP1)                  operand2 <= operand1;
    else if(operand2_control == `OP2_LOAD_1)                    operand2 <= 32'd1;
    else if(operand2_control == `OP2_LOAD_COUNT)                operand2 <=
                                                                    (ir[5] == 1'b0) ? ( (ir[11:9] == 3'b000) ? 32'b1000 : { 29'b0, ir[11:9] } ) :
                                                                    { 26'b0, operand2[5:0] };
    else if(operand2_control == `OP2_ADDQ_SUBQ)                 operand2 <= (ir[11:9] == 3'b000) ? 32'b1000 : { 29'b0, ir[11:9] };
    else if(operand2_control == `OP2_MOVE_OFFSET)               operand2 <= (ir[7:0] == 8'b0) ? operand2[31:0] : { {24{ir[7]}}, ir[7:0] };
    else if(operand2_control == `OP2_MOVE_ADDRESS_BUS_INFO)     operand2 <= { 16'b0, 11'b0, rw_state, instruction_flag, fc_state};
    else if(operand2_control == `OP2_DECR_BY_1)                 operand2 <= operand2 - 32'b1;
end

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0)                                         address <= 32'b0;
    else if(address_control == `ADDRESS_INCR_BY_SIZE)           address <= ((size[0]) && ea_reg == 3'b111) ? address + 32'd2 : address + {29'd0,size};
    else if(address_control == `ADDRESS_DECR_BY_SIZE)           address <= ((size[0]) && ea_reg == 3'b111) ? address - 32'd2 : address - {29'd0,size};
    else if(address_control == `ADDRESS_INCR_BY_2)              address <= address + 32'd2;
    else if(address_control == `ADDRESS_FROM_AN_OUTPUT)         address <= An_output;
    else if(address_control == `ADDRESS_FROM_BASE_INDEX_OFFSET) address <= address + index + offset;
    else if(address_control == `ADDRESS_FROM_IMM_16)            address <= { {16{prefetch_ir[79]}}, prefetch_ir[79:64] };
    else if(address_control == `ADDRESS_FROM_IMM_32)            address <= prefetch_ir[79:48];
    else if(address_control == `ADDRESS_FROM_PC_INDEX_OFFSET)   address <= pc_valid + index + offset;
    else if(address_control == `ADDRESS_FROM_TRAP)              address <= {22'b0, trap[7:0], 2'b0};
end

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0)                                         address_type <= 1'b0;
    else if(address_control == `ADDRESS_FROM_PC_INDEX_OFFSET)   address_type <= 1'b1;
    else if(address_control != `ADDRESS_IDLE)                   address_type <= 1'b0;
end

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0)                                         movem_modreg <= 6'b0;
    else if(movem_modreg_control == `MOVEM_MODREG_LOAD_0)       movem_modreg <= 6'b0;
    else if(movem_modreg_control == `MOVEM_MODREG_LOAD_6b001111)movem_modreg <= 6'b001111;
    else if(movem_modreg_control == `MOVEM_MODREG_INCR_BY_1)    movem_modreg <= movem_modreg + 6'd1;
    else if(movem_modreg_control == `MOVEM_MODREG_DECR_BY_1)    movem_modreg <= movem_modreg - 6'd1;
end

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0)                                         movem_loop <= 5'b0;
    else if(movem_loop_control == `MOVEM_LOOP_LOAD_0)           movem_loop <= 5'b0;
    else if(movem_loop_control == `MOVEM_LOOP_INCR_BY_1)        movem_loop <= movem_loop + 5'd1;
end

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0)                                         movem_reg <= 16'b0;
    else if(movem_reg_control == `MOVEM_REG_FROM_OP1)           movem_reg <= operand1[15:0];
    else if(movem_reg_control == `MOVEM_REG_SHIFT_RIGHT)        movem_reg <= { 1'b0, movem_reg[15:1] };
end

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0)                                         ir <= 16'b0;
    else if(ir_control == `IR_LOAD_WHEN_PREFETCH_VALID && prefetch_ir_valid == 1'b1 && stop_flag == 1'b0)
                                                                ir <= prefetch_ir[79:64];
end

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0)                                         decoder_alu_reg <= 18'b0;
    else if(ir_control == `IR_LOAD_WHEN_PREFETCH_VALID && prefetch_ir_valid == 1'b1 && stop_flag == 1'b0)
                                                                decoder_alu_reg <= decoder_alu;
end

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0)                                         trap <= 8'd0;
    else if(trap_control == `TRAP_ILLEGAL_INSTR)                trap <= 8'd4;
    else if(trap_control == `TRAP_DIV_BY_ZERO)                  trap <= 8'd5;
    else if(trap_control == `TRAP_CHK)                          trap <= 8'd6;
    else if(trap_control == `TRAP_TRAPV)                        trap <= 8'd7;
    else if(trap_control == `TRAP_PRIVIL_VIOLAT)                trap <= 8'd8;
    else if(trap_control == `TRAP_TRACE)                        trap <= 8'd9;
    else if(trap_control == `TRAP_TRAP)                         trap <= { 4'b0010, ir[3:0] };
    else if(trap_control == `TRAP_FROM_DECODER)                 trap <= decoder_trap;
    else if(trap_control == `TRAP_FROM_INTERRUPT)               trap <= interrupt_trap;
end

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0)                                         offset <= 32'd0;
    else if(offset_control == `OFFSET_IMM_8)                    offset <= { {24{prefetch_ir[71]}}, prefetch_ir[71:64] };
    else if(offset_control == `OFFSET_IMM_16)                   offset <= { {16{prefetch_ir[79]}}, prefetch_ir[79:64] };
end

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0)                                         index <= 32'd0;
    else if(index_control == `INDEX_0)                          index <= 32'd0;
    else if(index_control == `INDEX_LOAD_EXTENDED)              index <=
                                                                    (prefetch_ir[79] == 1'b0) ?
                                                                    (     (prefetch_ir[75] == 1'b0)  ?
                                                                            { {16{Dn_output[15]}}, Dn_output[15:0] } : Dn_output[31:0]
                                                                    ) :
                                                                    (     (prefetch_ir[75] == 1'b0) ?
                                                                            { {16{An_output[15]}}, An_output[15:0] } : An_output[31:0]
                                                                    );
end

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0)                                         stop_flag <= 1'b0;
    else if(stop_flag_control == `STOP_FLAG_SET)                stop_flag <= 1'b1;
    else if(stop_flag_control == `STOP_FLAG_CLEAR)              stop_flag <= 1'b0;
end

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0)                                         trace_flag <= 1'b0;
    else if(trace_flag_control == `TRACE_FLAG_COPY_WHEN_NO_STOP && prefetch_ir_valid == 1'b1 && decoder_trap == 8'd0 && stop_flag == 1'b0)
                                                                trace_flag <= sr[15];
end

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0)                                         group_0_flag <= 1'b0;
    else if(group_0_flag_control == `GROUP_0_FLAG_SET)          group_0_flag <= 1'b1;
    else if(group_0_flag_control == `GROUP_0_FLAG_CLEAR_WHEN_VALID_PREFETCH && prefetch_ir_valid == 1'b1 && stop_flag == 1'b0)
                                                                group_0_flag <= 1'b0;
end

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0)                                         instruction_flag <= 1'b0;
    else if(instruction_flag_control == `INSTRUCTION_FLAG_SET)  instruction_flag <= 1'b1;
    else if(instruction_flag_control == `INSTRUCTION_FLAG_CLEAR_IN_MAIN_LOOP && prefetch_ir_valid == 1'b1 && decoder_trap == 8'd0 && stop_flag == 1'b0)
                                                                instruction_flag <= 1'b0;
end

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0)                                                         read_modify_write_flag <= 1'b0;
    else if(read_modify_write_flag_control == `READ_MODIFY_WRITE_FLAG_SET)      read_modify_write_flag <= 1'b1;
    else if(read_modify_write_flag_control == `READ_MODIFY_WRITE_FLAG_CLEAR)    read_modify_write_flag <= 1'b0;
end

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0)                                         do_reset_flag <= 1'b0;
    else if(do_reset_flag_control == `DO_RESET_FLAG_SET)        do_reset_flag <= 1'b1;
    else if(do_reset_flag_control == `DO_RESET_FLAG_CLEAR)      do_reset_flag <= 1'b0;
end

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0)                                                         do_interrupt_flag <= 1'b0;
    else if(do_interrupt_flag_control == `DO_INTERRUPT_FLAG_SET_IF_ACTIVE)      do_interrupt_flag <= (interrupt_mask != 3'b000) ? 1'b1 : 1'b0;
    else if(do_interrupt_flag_control == `DO_INTERRUPT_FLAG_CLEAR)              do_interrupt_flag <= 1'b0;
end

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0)                                         do_read_flag <= 1'b0;
    else if(do_read_flag_control == `DO_READ_FLAG_SET)          do_read_flag <= 1'b1;
    else if(do_read_flag_control == `DO_READ_FLAG_CLEAR)        do_read_flag <= 1'b0;
end

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0)                                         do_write_flag <= 1'b0;
    else if(do_write_flag_control == `DO_WRITE_FLAG_SET)        do_write_flag <= 1'b1;
    else if(do_write_flag_control == `DO_WRITE_FLAG_CLEAR)      do_write_flag <= 1'b0;
end

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0)                                         do_blocked_flag <= 1'b0;
    else if(do_blocked_flag_control == `DO_BLOCKED_FLAG_SET)    do_blocked_flag <= 1'b1;
end

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0)                                         data_write <= 32'd0;
    else if(data_write_control == `DATA_WRITE_FROM_RESULT)      data_write <= result;
end

assign An_address =
    (An_address_control == `AN_ADDRESS_FROM_EXTENDED) ? { sr[13], prefetch_ir[78:76] } :
    (An_address_control == `AN_ADDRESS_USP) ?           4'b0111 :
    (An_address_control == `AN_ADDRESS_SSP) ?           4'b1111 :
    { sr[13], ea_reg };

assign An_input =
    (An_input_control == `AN_INPUT_FROM_ADDRESS) ?      address :
    (An_input_control == `AN_INPUT_FROM_PREFETCH_IR) ?  prefetch_ir[79:48] :
    result;

assign Dn_address = (Dn_address_control == `DN_ADDRESS_FROM_EXTENDED) ? prefetch_ir[78:76] : ea_reg;

endmodule

/***********************************************************************************************************************
 * Memory registers
 **********************************************************************************************************************/

/*! \brief Contains the microcode ROM and D0-D7, A0-A7 registers.
 *
 * The memory_registers module contains:
 *  - data and address registers (D0-D7, A0-A7) implemented as an on-chip RAM.
 *  - the microcode implemented as an on-chip ROM.
 *
 * Currently this module contains <em>altsyncram</em> instantiations
 * from Altera Megafunction/LPM library.
 */
module memory_registers(
    input clock,
    input reset_n,

    // 0000,0001,0010,0011,0100,0101,0110: A0-A6, 0111: USP, 1111: SSP
    input [3:0] An_address,
    input [31:0] An_input,
    input An_write_enable,
    output [31:0] An_output,

    output reg [31:0] usp,

    input [2:0] Dn_address,
    input [31:0] Dn_input,
    input Dn_write_enable,
    // 001: byte, 010: word, 100: long
    input [2:0] Dn_size,
    output [31:0] Dn_output,

    input [8:0] micro_pc,
    output [87:0] micro_data
);

wire An_ram_write_enable    = (An_address == 4'b0111) ? 1'b0 : An_write_enable;

wire [31:0] An_ram_output;
assign An_output            = (An_address == 4'b0111) ? usp : An_ram_output;

wire [3:0] dn_byteena       = (Dn_size[0] == 1'b1) ? 4'b0001 :
                              (Dn_size[1] == 1'b1) ? 4'b0011 :
                              (Dn_size[2] == 1'b1) ? 4'b1111 :
                              4'b0000;

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0)                                 usp <= 32'd0;
    else if(An_address == 4'b0111 && An_write_enable)   usp <= An_input;
end

// Register set An implemented as RAM.
altsyncram an_ram_inst(
    .clock0     (clock),

    .address_a  (An_address[2:0]),    
    .byteena_a  (4'b1111),
    .wren_a     (An_ram_write_enable),
    .data_a     (An_input),
    .q_a        (An_ram_output)
);
defparam 
    an_ram_inst.operation_mode      = "SINGLE_PORT",
    an_ram_inst.width_a             = 32,
    an_ram_inst.widthad_a           = 3,
    an_ram_inst.width_byteena_a     = 4;

// Register set Dn implemented as RAM.
altsyncram dn_ram_inst(
    .clock0     (clock),

    .address_a  (Dn_address),    
    .byteena_a  (dn_byteena),
    .wren_a     (Dn_write_enable),
    .data_a     (Dn_input),
    .q_a        (Dn_output)
);
defparam 
    dn_ram_inst.operation_mode      = "SINGLE_PORT",
    dn_ram_inst.width_a             = 32,
    dn_ram_inst.widthad_a           = 3,
    dn_ram_inst.width_byteena_a     = 4;

// Microcode ROM
altsyncram micro_rom_inst(
    .clock0     (clock),

    .address_a  (micro_pc),
    .q_a        (micro_data)
);
defparam
    micro_rom_inst.operation_mode   = "ROM",
    micro_rom_inst.width_a          = 88,
    micro_rom_inst.widthad_a        = 9,
    micro_rom_inst.init_file        = "ao68000_microcode.mif";

endmodule

/***********************************************************************************************************************
 * Instruction decoder
 **********************************************************************************************************************/

/*! \brief Decode instruction and addressing mode.
 *
 * The decoder is an instruction and addressing mode decoder. For instructions it takes as input the ir register
 * from the registers module. The output of the decoder, in this case, is a microcode address of the first microcode
 * word that performs the instruction.
 *
 * In case of addressing mode decoding, the output is the address of the first microcode word that performs the operand
 * loading or saving. This address is obtained from the currently selected addressing mode saved in the ea_mod
 * and ea_type registers in the registers module.
 */
module decoder(
    input           clock,
    input           reset_n,

    input           supervisor,
    input [15:0]    ir,

    // zero: no trap
    output [7:0]    decoder_trap,
    output [8:0]    decoder_micropc,
    output [17:0]   decoder_alu,
    
    output [8:0]    save_ea,
    output [8:0]    perform_ea_write,
    output [8:0]    perform_ea_read,
    output [8:0]    load_ea,
    
    input [3:0]     ea_type,
    input [2:0]     ea_mod,
    input [2:0]     ea_reg
);

parameter [7:0]
    NO_TRAP                             = 8'd0,
    ILLEGAL_INSTRUCTION_TRAP            = 8'd4,
    PRIVILEGE_VIOLATION_TRAP            = 8'd8,
    ILLEGAL_1010_INSTRUCTION_TRAP       = 8'd10,
    ILLEGAL_1111_INSTRUCTION_TRAP       = 8'd11;

parameter [8:0]
    UNUSED_MICROPC                      = 9'd0;

assign { decoder_trap, decoder_micropc } =
    (reset_n == 1'b0) ? { NO_TRAP, UNUSED_MICROPC } :

    // Privilege violation and illegal instruction

    // ANDI to SR,EORI to SR,ORI to SR,RESET,STOP,RTE,MOVE TO SR,MOVE USP TO USP,MOVE USP TO An privileged instructions
    ( ( ir[15:0] == 16'b0000_0010_01_111_100 ||
          ir[15:0] == 16'b0000_1010_01_111_100 ||
          ir[15:0] == 16'b0000_0000_01_111_100 ||
          ir[15:0] == 16'b0100_1110_0111_0000 ||
          ir[15:0] == 16'b0100_1110_0111_0010 ||
          ir[15:0] == 16'b0100_1110_0111_0011 ||
         (ir[15:6] == 10'b0100_0110_11 && ir[5:3] != 3'b001 && ir[5:0] != 6'b111_101 && ir[5:0] != 6'b111_110 && ir[5:0] != 6'b111_111) ||
          ir[15:3] == 13'b0100_1110_0110_0 ||
          ir[15:3] == 13'b0100_1110_0110_1 ) && supervisor == 1'b0 ) ? { PRIVILEGE_VIOLATION_TRAP, UNUSED_MICROPC } :
    // ILLEGAL, illegal instruction
    ( ir[15:0] == 16'b0100_1010_11_111100 ) ? { ILLEGAL_INSTRUCTION_TRAP, UNUSED_MICROPC } :
    // 1010 illegal instruction
    ( ir[15:12] == 4'b1010 ) ? { ILLEGAL_1010_INSTRUCTION_TRAP, UNUSED_MICROPC } :
    // 1111 illegal instruction
    ( ir[15:12] == 4'b1111 ) ? { ILLEGAL_1111_INSTRUCTION_TRAP, UNUSED_MICROPC } :

    // instruction decoding

    // ANDI,EORI,ORI,ADDI,SUBI
    ( ir[15:12] == 4'b0000 && ir[11:9] != 3'b100 && ir[11:9] != 3'b110 && ir[11:9] != 3'b111 && ir[8] == 1'b0 &&
        (ir[7:6] == 2'b00 || ir[7:6] == 2'b01 || ir[7:6] == 2'b10) && ir[5:3] != 3'b001 &&
        (ir[5:3] != 3'b111 || (ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001)) &&
        ir[15:0] != 16'b0000_000_0_00_111100 && ir[15:0] != 16'b0000_000_0_01_111100 &&
        ir[15:0] != 16'b0000_001_0_00_111100 && ir[15:0] != 16'b0000_001_0_01_111100 &&
        ir[15:0] != 16'b0000_101_0_00_111100 && ir[15:0] != 16'b0000_101_0_01_111100 ) ? { NO_TRAP, `MICROPC_ANDI_EORI_ORI_ADDI_SUBI } :
    // ORI to CCR,ORI to SR,ANDI to CCR,ANDI to SR,EORI to CCR,EORI to SR
    ( ir[15:0] == 16'b0000_000_0_00_111100 || ir[15:0] == 16'b0000_000_0_01_111100 ||
        ir[15:0] == 16'b0000_001_0_00_111100 || ir[15:0] == 16'b0000_001_0_01_111100 ||
        ir[15:0] == 16'b0000_101_0_00_111100 || ir[15:0] == 16'b0000_101_0_01_111100 ) ?
        { NO_TRAP, `MICROPC_ORI_to_CCR_ORI_to_SR_ANDI_to_CCR_ANDI_to_SR_EORI_to_CCR_EORI_to_SR } :
    // BTST register
    ( ir[15:12] == 4'b0000 && ir[8:6] == 3'b100 && ir[5:3] != 3'b001 &&
        (ir[5:3] != 3'b111 ||
            (ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001 || ir[5:0] == 6'b111_010 || ir[5:0] == 6'b111_011 || ir[5:0] == 6'b111_100))
    ) ? { NO_TRAP, `MICROPC_BTST_register } :
    // MOVEP memory to register
    ( ir[15:12] == 4'b0000 && ir[8] == 1'b1 && ir[5:3] == 3'b001 && ( ir[7:6] == 2'b00 || ir[7:6] == 2'b01 ) ) ?
        { NO_TRAP, `MICROPC_MOVEP_memory_to_register } :
    // MOVEP register to memory
    ( ir[15:12] == 4'b0000 && ir[8] == 1'b1 && ir[5:3] == 3'b001 && ( ir[7:6] == 2'b10 || ir[7:6] == 2'b11 ) ) ?
        { NO_TRAP, `MICROPC_MOVEP_register_to_memory } :
    // BCHG,BCLR,BSET register
    ( ir[15:12] == 4'b0000 && ir[8] == 1'b1 && ir[5:3] != 3'b001 && ir[8:6] != 3'b100 &&
        (ir[5:3] != 3'b111 || (ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001))
    ) ?  { NO_TRAP, `MICROPC_BCHG_BCLR_BSET_register } :
    // BTST immediate
    ( ir[15:12] == 4'b0000 && ir[11:8] == 4'b1000 && ir[7:6] == 2'b00 && ir[5:3] != 3'b001 &&
        (ir[5:3] != 3'b111 ||
            (ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001 || ir[5:0] == 6'b111_010 || ir[5:0] == 6'b111_011))
    ) ? { NO_TRAP, `MICROPC_BTST_immediate } :
    // BCHG,BCLR,BSET immediate
    ( ir[15:12] == 4'b0000 && ir[11:8] == 4'b1000 && ir[7:6] != 2'b00 && ir[5:3] != 3'b001 &&
        (ir[5:3] != 3'b111 || (ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001))
    ) ? { NO_TRAP, `MICROPC_BCHG_BCLR_BSET_immediate } :
    // CMPI
    ( ir[15:12] == 4'b0000 && ir[8] == 1'b0 && ir[11:9] == 3'b110 && ir[7:6] != 2'b11 && ir[5:3] != 3'b001 &&
        (ir[5:3] != 3'b111 || (ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001))
    ) ? { NO_TRAP, `MICROPC_CMPI } :
    // MOVE
    ( ir[15:14] == 2'b00 && ir[13:12] != 2'b00 && ir[8:6] != 3'b001 &&
        (ir[8:6] != 3'b111 || (ir[11:6] == 6'b000_111 || ir[11:6] == 6'b001_111)) &&
        (ir[13:12] != 2'b01 || ir[5:3] != 3'b001) &&
        (ir[5:3] != 3'b111 ||
            (ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001 || ir[5:0] == 6'b111_010 || ir[5:0] == 6'b111_011 || ir[5:0] == 6'b111_100))
    ) ? { NO_TRAP, `MICROPC_MOVE } :
    // MOVEA
    ( ir[15:14] == 2'b00 && (ir[13:12] == 2'b11 || ir[13:12] == 2'b10) && ir[8:6] == 3'b001 &&
        (ir[5:3] != 3'b111 ||
            (ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001 || ir[5:0] == 6'b111_010 || ir[5:0] == 6'b111_011 || ir[5:0] == 6'b111_100))
    ) ? { NO_TRAP, `MICROPC_MOVEA } :
    // NEGX,CLR,NEG,NOT,NBCD
    (    ir[15:12] == 4'b0100 && ir[5:3] != 3'b001 && (ir[5:3] != 3'b111 || ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001) &&
            (    (ir[11:8] == 4'b0000 && ir[7:6] != 2'b11) || (ir[11:8] == 4'b0010 && ir[7:6] != 2'b11) || 
                (ir[11:8] == 4'b0100 && ir[7:6] != 2'b11) || (ir[11:8] == 4'b0110 && ir[7:6] != 2'b11) ||
                (ir[11:6] == 6'b1000_00)
            )
    ) ? { NO_TRAP, `MICROPC_NEGX_CLR_NEG_NOT_NBCD } :
    // MOVE FROM SR
    ( ir[15:6] == 10'b0100_0000_11 && ir[5:3] != 3'b001 && (ir[5:3] != 3'b111 || ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001)
    ) ? { NO_TRAP, `MICROPC_MOVE_FROM_SR } :
    // CHK
    ( ir[15:12] == 4'b0100 && ir[8:6] == 3'b110 && ir[5:3] != 3'b001 &&
        (ir[5:3] != 3'b111 ||
            (ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001 || ir[5:0] == 6'b111_010 || ir[5:0] == 6'b111_011 || ir[5:0] == 6'b111_100))
    ) ? { NO_TRAP, `MICROPC_CHK } :
    // LEA
    ( ir[15:12] == 4'b0100 && ir[8:6] == 3'b111  && (ir[5:3] == 3'b010 || ir[5:3] == 3'b101 || ir[5:3] == 3'b110 || ir[5:3] == 3'b111) &&
        (ir[5:3] != 3'b111 ||
            (ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001 || ir[5:0] == 6'b111_010 || ir[5:0] == 6'b111_011))
    ) ? { NO_TRAP, `MICROPC_LEA } :
    // MOVE TO CCR, MOVE TO SR
    ( (ir[15:6] == 10'b0100_0100_11 || ir[15:6] == 10'b0100_0110_11) && ir[5:3] != 3'b001 &&
        (ir[5:3] != 3'b111 ||
            (ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001 || ir[5:0] == 6'b111_010 || ir[5:0] == 6'b111_011 || ir[5:0] == 6'b111_100))
    ) ? { NO_TRAP, `MICROPC_MOVE_TO_CCR_MOVE_TO_SR } :
    // SWAP,EXT
    ( ir[15:12] == 4'b0100 && (ir[11:3] == 9'b1000_01_000 || (ir[11:7] == 5'b1000_1 && ir[5:3] == 3'b000) ) ) ? { NO_TRAP, `MICROPC_SWAP_EXT } :
    // PEA
    ( ir[15:6] == 10'b0100_1000_01 && ir[5:3] != 3'b000 && (ir[5:3] == 3'b010 || ir[5:3] == 3'b101 || ir[5:3] == 3'b110 || ir[5:3] == 3'b111) &&
        (ir[5:3] != 3'b111 ||
            (ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001 || ir[5:0] == 6'b111_010 || ir[5:0] == 6'b111_011))
    ) ? { NO_TRAP, `MICROPC_PEA } :
    // MOVEM register to memory, predecrement
    ( ir[15:7] == 9'b0100_1000_1 && ir[5:3] == 3'b100 ) ? { NO_TRAP, `MICROPC_MOVEM_register_to_memory_predecrement } :
    // MOVEM register to memory, control
    ( ir[15:7] == 9'b0100_1000_1 && (ir[5:3] == 3'b010 || ir[5:3] == 3'b101 || ir[5:3] == 3'b110 || ir[5:3] == 3'b111) &&
        (ir[5:3] != 3'b111 || ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001)
    ) ? { NO_TRAP, `MICROPC_MOVEM_register_to_memory_control } :
    // TST
    ( ir[15:8] == 8'b0100_1010 && ir[7:6] != 2'b11 && ir[5:3] != 3'b001 &&
        (ir[5:3] != 3'b111 || (ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001))
    ) ? { NO_TRAP, `MICROPC_TST } :
    // TAS
    ( ir[15:6] == 10'b0100_1010_11 && ir[5:3] != 3'b001 &&
        (ir[5:3] != 3'b111 || (ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001))
    ) ? { NO_TRAP, `MICROPC_TAS } :
    // MOVEM memory to register
    ( ir[15:7] == 9'b0100_1100_1 && (ir[5:3] == 3'b010 || ir[5:3] == 3'b011 || ir[5:3] == 3'b101 || ir[5:3] == 3'b110 || ir[5:3] == 3'b111) &&
        (ir[5:3] != 3'b111 ||
            (ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001 || ir[5:0] == 6'b111_010 || ir[5:0] == 6'b111_011))
    ) ? { NO_TRAP, `MICROPC_MOVEM_memory_to_register } :
    // TRAP
    ( ir[15:4] == 12'b0100_1110_0100 ) ? { NO_TRAP, `MICROPC_TRAP } :
    // LINK
    ( ir[15:3] == 13'b0100_1110_0101_0 ) ? { NO_TRAP, `MICROPC_LINK } :
    // UNLK
    ( ir[15:3] == 13'b0100_1110_0101_1 ) ? { NO_TRAP, `MICROPC_ULNK } :
    // MOVE USP to USP
    ( ir[15:3] == 13'b0100_1110_0110_0 ) ? { NO_TRAP, `MICROPC_MOVE_USP_to_USP } :
    // MOVE USP to An
    ( ir[15:3] == 13'b0100_1110_0110_1 ) ? { NO_TRAP, `MICROPC_MOVE_USP_to_An } :
    // RESET
    ( ir[15:0] == 16'b0100_1110_0111_0000 ) ? { NO_TRAP, `MICROPC_RESET } :
    // NOP
    ( ir[15:0] == 16'b0100_1110_0111_0001 ) ? { NO_TRAP, `MICROPC_NOP } :
    // STOP
    ( ir[15:0] == 16'b0100_1110_0111_0010 ) ? { NO_TRAP, `MICROPC_STOP } :
    // RTE,RTR
    ( ir[15:0] == 16'b0100_1110_0111_0011 || ir[15:0] == 16'b0100_1110_0111_0111 ) ? { NO_TRAP, `MICROPC_RTE_RTR } :
    // RTS
    ( ir[15:0] == 16'b0100_1110_0111_0101 ) ? { NO_TRAP, `MICROPC_RTS } :
    // TRAPV
    ( ir[15:0] == 16'b0100_1110_0111_0110 ) ? { NO_TRAP, `MICROPC_TRAPV } :
    // JSR
    ( ir[15:6] == 10'b0100_1110_10 && (ir[5:3] == 3'b010 || ir[5:3] == 3'b101 || ir[5:3] == 3'b110 || ir[5:3] == 3'b111) &&
        (ir[5:3] != 3'b111 ||
            (ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001 || ir[5:0] == 6'b111_010 || ir[5:0] == 6'b111_011))
    ) ? { NO_TRAP, `MICROPC_JSR } :
    // JMP
    ( ir[15:6] == 10'b0100_1110_11 && (ir[5:3] == 3'b010 || ir[5:3] == 3'b101 || ir[5:3] == 3'b110 || ir[5:3] == 3'b111) &&
        (ir[5:3] != 3'b111 ||
            (ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001 || ir[5:0] == 6'b111_010 || ir[5:0] == 6'b111_011))
    ) ? { NO_TRAP, `MICROPC_JMP } :
    // ADDQ,SUBQ not An
    ( ir[15:12] == 4'b0101 && ir[7:6] != 2'b11 && ir[5:3] != 3'b001 &&
        (ir[5:3] != 3'b111 || (ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001))
    ) ? { NO_TRAP, `MICROPC_ADDQ_SUBQ_not_An } :
    // ADDQ,SUBQ An
    ( ir[15:12] == 4'b0101 && ir[7:6] != 2'b11 && ir[7:6] != 2'b00 && ir[5:3] == 3'b001 ) ? { NO_TRAP, `MICROPC_ADDQ_SUBQ_An } :
    // Scc
    ( ir[15:12] == 4'b0101 && ir[7:6] == 2'b11 && ir[5:3] != 3'b001 &&
        (ir[5:3] != 3'b111 || (ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001))
    ) ? { NO_TRAP, `MICROPC_Scc } :
    // DBcc
    ( ir[15:12] == 4'b0101 && ir[7:6] == 2'b11 && ir[5:3] == 3'b001 ) ? { NO_TRAP, `MICROPC_DBcc } :
    // BSR
    ( ir[15:12] == 4'b0110 && ir[11:8] == 4'b0001 ) ? { NO_TRAP, `MICROPC_BSR } :
    // Bcc,BRA
    ( ir[15:12] == 4'b0110 && ir[11:8] != 4'b0001 ) ? { NO_TRAP, `MICROPC_Bcc_BRA } :
    // MOVEQ
    ( ir[15:12] == 4'b0111 && ir[8] == 1'b0 ) ? { NO_TRAP, `MICROPC_MOVEQ } :
    // CMP
    ( (ir[15:12] == 4'b1011) && (ir[8:6] == 3'b000 || ir[8:6] == 3'b001 || ir[8:6] == 3'b010) &&
        (ir[8:6] != 3'b000 || ir[5:3] != 3'b001) &&
        (ir[5:3] != 3'b111 ||
            (ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001 || ir[5:0] == 6'b111_010 || ir[5:0] == 6'b111_011 || ir[5:0] == 6'b111_100))
    ) ? { NO_TRAP, `MICROPC_CMP } :
    // CMPA
    ( (ir[15:12] == 4'b1011) && (ir[8:6] == 3'b011 || ir[8:6] == 3'b111) &&
        (ir[5:3] != 3'b111 ||
            (ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001 || ir[5:0] == 6'b111_010 || ir[5:0] == 6'b111_011 || ir[5:0] == 6'b111_100))
    ) ? { NO_TRAP, `MICROPC_CMPA } :
    // CMPM
    ( ir[15:12] == 4'b1011 && (ir[8:6] == 3'b100 || ir[8:6] == 3'b101 || ir[8:6] == 3'b110) && ir[5:3] == 3'b001) ? { NO_TRAP, `MICROPC_CMPM } :
    // EOR
    ( ir[15:12] == 4'b1011 && (ir[8:6] == 3'b100 || ir[8:6] == 3'b101 || ir[8:6] == 3'b110) && ir[5:3] != 3'b001 &&
        (ir[5:3] != 3'b111 || (ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001))
    ) ? { NO_TRAP, `MICROPC_EOR } :
    // ADD to mem,SUB to mem,AND to mem,OR to mem
    (     (ir[15:12] == 4'b1101 || ir[15:12] == 4'b1001 || ir[15:12] == 4'b1100 || ir[15:12] == 4'b1000) &&
        (ir[8:4] == 5'b10001 || ir[8:4] == 5'b10010 || ir[8:4] == 5'b10011 ||
         ir[8:4] == 5'b10101 || ir[8:4] == 5'b10110 || ir[8:4] == 5'b10111 ||
         ir[8:4] == 5'b11001 || ir[8:4] == 5'b11010 || ir[8:4] == 5'b11011) &&
        (ir[5:3] != 3'b111 || (ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001))
    ) ? { NO_TRAP, `MICROPC_ADD_to_mem_SUB_to_mem_AND_to_mem_OR_to_mem } :
    // ADD to Dn,SUB to Dn,AND to Dn,OR to Dn
    (     (ir[15:12] == 4'b1101 || ir[15:12] == 4'b1001 || ir[15:12] == 4'b1100 || ir[15:12] == 4'b1000) &&
        (ir[8:6] == 3'b000 || ir[8:6] == 3'b001 || ir[8:6] == 3'b010) &&
        (ir[12] != 1'b1 || ir[8:6] != 3'b000 || ir[5:3] != 3'b001) && (ir[12] == 1'b1 || ir[5:3] != 3'b001) &&
        (ir[5:3] != 3'b111 ||
            (ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001 || ir[5:0] == 6'b111_010 || ir[5:0] == 6'b111_011 || ir[5:0] == 6'b111_100))
    ) ? { NO_TRAP, `MICROPC_ADD_to_Dn_SUB_to_Dn_AND_to_Dn_OR_to_Dn } :
    // ADDA,SUBA
    ( (ir[15:12] == 4'b1101 || ir[15:12] == 4'b1001) && (ir[8:6] == 3'b011 || ir[8:6] == 3'b111) &&
        (ir[5:3] != 3'b111 ||
            (ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001 || ir[5:0] == 6'b111_010 || ir[5:0] == 6'b111_011 || ir[5:0] == 6'b111_100))
    ) ? { NO_TRAP, `MICROPC_ADDA_SUBA } :
    // ABCD,SBCD,ADDX,SUBX
    (     ((ir[15:12] == 4'b1100 || ir[15:12] == 4'b1000) && ir[8:4] == 5'b10000) ||
        ((ir[15:12] == 4'b1101 || ir[15:12] == 4'b1001) && (ir[8:4] == 5'b10000 || ir[8:4] == 5'b10100 || ir[8:4] == 5'b11000) ) ) ?
        { NO_TRAP, `MICROPC_ABCD_SBCD_ADDX_SUBX } :
    // EXG
    ( ir[15:12] == 4'b1100 && (ir[8:3] == 6'b101000 || ir[8:3] == 6'b101001 || ir[8:3] == 6'b110001) ) ? { NO_TRAP, `MICROPC_EXG } :
    // MULS,MULU,DIVS,DIVU
    ( (ir[15:12] == 4'b1100 || ir[15:12] == 4'b1000) && ir[7:6] == 2'b11 && ir[5:3] != 3'b001 &&
        (ir[5:3] != 3'b111 ||
            (ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001 || ir[5:0] == 6'b111_010 || ir[5:0] == 6'b111_011 || ir[5:0] == 6'b111_100))
    ) ? { NO_TRAP, `MICROPC_MULS_MULU_DIVS_DIVU } :
    // ASL,LSL,ROL,ROXL,ASR,LSR,ROR,ROXR all memory
    ( ir[15:12] == 4'b1110 && ir[11] == 1'b0 && ir[7:6] == 2'b11 && ir[5:3] != 3'b000 && ir[5:3] != 3'b001 &&
        (ir[5:3] != 3'b111 || (ir[5:0] == 6'b111_000 || ir[5:0] == 6'b111_001))
    ) ?  { NO_TRAP, `MICROPC_ASL_LSL_ROL_ROXL_ASR_LSR_ROR_ROXR_all_memory } :
    // ASL,LSL,ROL,ROXL,ASR,LSR,ROR,ROXR all immediate/register
    ( ir[15:12] == 4'b1110 && (ir[7:6] == 2'b00 || ir[7:6] == 2'b01 || ir[7:6] == 2'b10) ) ?
        { NO_TRAP, `MICROPC_ASL_LSL_ROL_ROXL_ASR_LSR_ROR_ROXR_all_immediate_register } :

    // else

    { ILLEGAL_INSTRUCTION_TRAP, UNUSED_MICROPC }
;

// load ea
assign load_ea =
    (
        (ea_type == `EA_TYPE_ALL && (ea_mod == 3'b000 || ea_mod == 3'b001 || (ea_mod == 3'b111 && ea_reg == 3'b100))) ||
        (ea_type == `EA_TYPE_DATAALTER && ea_mod == 3'b000) ||
        (ea_type == `EA_TYPE_DN_AN && (ea_mod == 3'b000 || ea_mod == 3'b001)) ||
        (ea_type == `EA_TYPE_DATA && (ea_mod == 3'b000 || (ea_mod == 3'b111 && ea_reg == 3'b100)))
    ) ? 9'd0 // no ea needed
    :
    (ea_mod == 3'b010 && (
        ea_type == `EA_TYPE_ALL || ea_type == `EA_TYPE_CONTROL_POSTINC || ea_type == `EA_TYPE_CONTROLALTER_PREDEC ||
        ea_type == `EA_TYPE_CONTROL || ea_type == `EA_TYPE_DATAALTER || ea_type == `EA_TYPE_MEMORYALTER ||
        ea_type == `EA_TYPE_DATA
    )) ? `MICROPC_LOAD_EA_An // (An)
    :
    (ea_mod == 3'b011 && (
        ea_type == `EA_TYPE_ALL || ea_type == `EA_TYPE_CONTROL_POSTINC || ea_type == `EA_TYPE_MEMORYALTER ||
        ea_type == `EA_TYPE_DATAALTER || ea_type == `EA_TYPE_DATA
    )) ? `MICROPC_LOAD_EA_An_plus // (An)+
    :
    (ea_mod == 3'b100 && (
        ea_type == `EA_TYPE_ALL || ea_type == `EA_TYPE_CONTROLALTER_PREDEC || ea_type == `EA_TYPE_DATAALTER ||
        ea_type == `EA_TYPE_MEMORYALTER ||    ea_type == `EA_TYPE_DATA
    )) ? `MICROPC_LOAD_EA_minus_An // -(An)
    :
    (ea_mod == 3'b101 && (
        ea_type == `EA_TYPE_ALL || ea_type == `EA_TYPE_CONTROL_POSTINC || ea_type == `EA_TYPE_CONTROLALTER_PREDEC ||
        ea_type == `EA_TYPE_CONTROL ||    ea_type == `EA_TYPE_DATAALTER || ea_type == `EA_TYPE_MEMORYALTER || ea_type == `EA_TYPE_DATA
    )) ? `MICROPC_LOAD_EA_d16_An // (d16, An)
    :
    (ea_mod == 3'b110 && (
        ea_type == `EA_TYPE_ALL || ea_type == `EA_TYPE_CONTROL_POSTINC || ea_type == `EA_TYPE_CONTROLALTER_PREDEC ||
        ea_type == `EA_TYPE_CONTROL || ea_type == `EA_TYPE_DATAALTER || ea_type == `EA_TYPE_MEMORYALTER || ea_type == `EA_TYPE_DATA
    )) ? `MICROPC_LOAD_EA_d8_An_Xn // (d8, An, Xn)
    :
    (ea_mod == 3'b111 && ea_reg == 3'b000 && (
        ea_type == `EA_TYPE_ALL || ea_type == `EA_TYPE_CONTROL_POSTINC || ea_type == `EA_TYPE_CONTROLALTER_PREDEC ||
        ea_type == `EA_TYPE_CONTROL ||    ea_type == `EA_TYPE_DATAALTER || ea_type == `EA_TYPE_MEMORYALTER || ea_type == `EA_TYPE_DATA
    )) ? `MICROPC_LOAD_EA_xxx_W // (xxx).W
    :
    (ea_mod == 3'b111 && ea_reg == 3'b001 && (
        ea_type == `EA_TYPE_ALL || ea_type == `EA_TYPE_CONTROL_POSTINC || ea_type == `EA_TYPE_CONTROLALTER_PREDEC ||
        ea_type == `EA_TYPE_CONTROL || ea_type == `EA_TYPE_DATAALTER || ea_type == `EA_TYPE_MEMORYALTER || ea_type == `EA_TYPE_DATA
    )) ? `MICROPC_LOAD_EA_xxx_L // (xxx).L
    :
    (ea_mod == 3'b111 && ea_reg == 3'b010 && (
        ea_type == `EA_TYPE_ALL || ea_type == `EA_TYPE_CONTROL_POSTINC || ea_type == `EA_TYPE_CONTROL || ea_type == `EA_TYPE_DATA
    )) ? `MICROPC_LOAD_EA_d16_PC // (d16, PC)
    :
    (ea_mod == 3'b111 && ea_reg == 3'b011 && (
        ea_type == `EA_TYPE_ALL || ea_type == `EA_TYPE_CONTROL_POSTINC || ea_type == `EA_TYPE_CONTROL || ea_type == `EA_TYPE_DATA
    )) ? `MICROPC_LOAD_EA_d8_PC_Xn // (d8, PC, Xn)
    :
    `MICROPC_LOAD_EA_illegal_command // illegal command
;

// perform ea read
assign perform_ea_read =
    ( ea_mod == 3'b000 && (ea_type == `EA_TYPE_ALL || ea_type == `EA_TYPE_DATAALTER || ea_type == `EA_TYPE_DN_AN ||
      ea_type == `EA_TYPE_DATA) ) ?
        `MICROPC_PERFORM_EA_READ_Dn :
    ( ea_mod == 3'b001 && (ea_type == `EA_TYPE_ALL || ea_type == `EA_TYPE_DN_AN) ) ? `MICROPC_PERFORM_EA_READ_An :
    ( ea_mod == 3'b111 && ea_reg == 3'b100 && (ea_type == `EA_TYPE_ALL || ea_type == `EA_TYPE_DATA) ) ?
        `MICROPC_PERFORM_EA_READ_imm :
    `MICROPC_PERFORM_EA_READ_memory
;

// perform ea write
assign perform_ea_write =
    ( ea_mod == 3'b000 && (ea_type == `EA_TYPE_ALL || ea_type == `EA_TYPE_DATAALTER || ea_type == `EA_TYPE_DN_AN ||
      ea_type == `EA_TYPE_DATA) ) ?
        `MICROPC_PERFORM_EA_WRITE_Dn :
    ( ea_mod == 3'b001 && (ea_type == `EA_TYPE_ALL || ea_type == `EA_TYPE_DN_AN) ) ? `MICROPC_PERFORM_EA_WRITE_An :
    `MICROPC_PERFORM_EA_WRITE_memory
;

// save ea
assign save_ea =
    (ea_mod == 3'b011 && (
        ea_type == `EA_TYPE_ALL || ea_type == `EA_TYPE_CONTROL_POSTINC || ea_type == `EA_TYPE_MEMORYALTER ||
        ea_type == `EA_TYPE_DATAALTER || ea_type == `EA_TYPE_DATA
    )) ? `MICROPC_SAVE_EA_An_plus // (An)+
    :
    (ea_mod == 3'b100 && (
        ea_type == `EA_TYPE_ALL || ea_type == `EA_TYPE_CONTROLALTER_PREDEC || ea_type == `EA_TYPE_DATAALTER ||
        ea_type == `EA_TYPE_MEMORYALTER || ea_type == `EA_TYPE_DATA
    )) ? `MICROPC_SAVE_EA_minus_An // -(An)
    :
    9'd0 // no ea needed
;

// ALU decoding optimization
// Thanks to Frederic Requin
// not used: 7, 13, 17
assign decoder_alu[0]  = ((ir[15:12] == 4'b0000 && ir[11:9] == 3'b000) // OR
                       || (ir[15:12] == 4'b1000));
assign decoder_alu[1]  = ((ir[15:12] == 4'b0000 && ir[11:9] == 3'b001) // AND
                       || (ir[15:12] == 4'b1100));
assign decoder_alu[2]  = ((ir[15:12] == 4'b0000 && ir[11:9] == 3'b101) // EOR
                       || (ir[15:12] == 4'b1011 && (ir[8:7] == 2'b10 || ir[8:6] == 3'b110) && ir[5:3] != 3'b001));
assign decoder_alu[3]  = ((ir[15:12] == 4'b0000 && ir[11:9] == 3'b011) // ADD
                       || (ir[15:12] == 4'b1101)
                       || (ir[15:12] == 4'b0101 && ir[8] == 1'b0));
assign decoder_alu[4]  = ((ir[15:12] == 4'b0000 && ir[11:9] == 3'b010) // SUB
                       || (ir[15:12] == 4'b1001)
                       || (ir[15:12] == 4'b0101 && ir[8] == 1'b1));
assign decoder_alu[5]  = ((ir[15:12] == 4'b0000 && ir[11:9] == 3'b110) // CMP
                       || (ir[15:12] == 4'b1011 && (ir[8:7] == 2'b10 || ir[8:6] == 3'b110) && ir[5:3] == 3'b001)
                       || (ir[15:12] == 4'b1011 && (ir[8:7] == 2'b00 || ir[8:6] == 3'b010)));
assign decoder_alu[6]  = ((ir[15:12] == 4'b1101)                       // ADDA,ADDQ
                       || (ir[15:12] == 4'b0101 && ir[8] == 1'b0));
assign decoder_alu[7]  = ((ir[15:12] == 4'b1001)                       // SUBA,CMPA,SUBQ
                       || (ir[15:12] == 4'b1011)
                       || (ir[15:12] == 4'b0101 && ir[8] == 1'b1));
assign decoder_alu[8]  = (((ir[7:6] == 2'b11 && ir[10:9] == 2'b00)     // ASL
                       ||  (ir[7:6] != 2'b11 && ir[4:3] == 2'b00)) && ir[8] == 1'b1);
assign decoder_alu[9]  = (((ir[7:6] == 2'b11 && ir[10:9] == 2'b01)     // LSL
                       ||  (ir[7:6] != 2'b11 && ir[4:3] == 2'b01)) && ir[8] == 1'b1);
assign decoder_alu[10] = (((ir[7:6] == 2'b11 && ir[10:9] == 2'b11)     // ROL
                       ||  (ir[7:6] != 2'b11 && ir[4:3] == 2'b11)) && ir[8] == 1'b1);
assign decoder_alu[11] = (((ir[7:6] == 2'b11 && ir[10:9] == 2'b10)     // ROXL
                       ||  (ir[7:6] != 2'b11 && ir[4:3] == 2'b10)) && ir[8] == 1'b1);
assign decoder_alu[12] = (((ir[7:6] == 2'b11 && ir[10:9] == 2'b00)     // ASR
                       ||  (ir[7:6] != 2'b11 && ir[4:3] == 2'b00)) && ir[8] == 1'b0);
assign decoder_alu[13] = (((ir[7:6] == 2'b11 && ir[10:9] == 2'b01)     // LSR
                       ||  (ir[7:6] != 2'b11 && ir[4:3] == 2'b01)) && ir[8] == 1'b0);
assign decoder_alu[14] = (((ir[7:6] == 2'b11 && ir[10:9] == 2'b11)     // ROR
                       ||  (ir[7:6] != 2'b11 && ir[4:3] == 2'b11)) && ir[8] == 1'b0);
assign decoder_alu[15] = (((ir[7:6] == 2'b11 && ir[10:9] == 2'b10)     // ROXR
                       ||  (ir[7:6] != 2'b11 && ir[4:3] == 2'b10)) && ir[8] == 1'b0);
assign decoder_alu[16] = ((ir[15:8] == 8'b0100_0110)                   // SR operations
                       || (ir[15:0] == 16'b0100_1110_0111_0011)
                       || (ir[15:0] == 16'b0100_1110_0111_0010)
                       || (ir[15:0] == 16'b0000_000_0_01_111100)
                       || (ir[15:0] == 16'b0000_001_0_01_111100)
                       || (ir[15:0] == 16'b0000_101_0_01_111100));
assign decoder_alu[17] = ((ir[15:8] == 8'b0100_0100)                   // CCR operations
                       || (ir[15:0] == 16'b0100_1110_0111_0111)
                       || (ir[15:0] == 16'b0000_000_0_00_111100)
                       || (ir[15:0] == 16'b0000_001_0_00_111100)
                       || (ir[15:0] == 16'b0000_101_0_00_111100));

endmodule

/***********************************************************************************************************************
 * Condition
 **********************************************************************************************************************/

/*! \brief Condition tests.
 *
 * The condition module implements the condition tests of the MC68000. Its inputs are the condition codes
 * and the currently selected test. The output is binary: the test is true or false. The output of the condition module
 * is an input to the microcode_branch module, that decides which microcode word to execute next.
 */
module condition(
    input [3:0] cond,
    input [7:0] ccr,
    output condition
);

wire C,V,Z,N;
assign C = ccr[0];
assign V = ccr[1];
assign Z = ccr[2];
assign N = ccr[3];

assign condition =  (cond == 4'b0000) ? 1'b1 :                              // true
                    (cond == 4'b0001) ? 1'b0 :                              // false
                    (cond == 4'b0010) ? ~C & ~Z    :                        // high
                    (cond == 4'b0011) ? C | Z :                             // low or same
                    (cond == 4'b0100) ? ~C :                                // carry clear
                    (cond == 4'b0101) ? C :                                 // carry set
                    (cond == 4'b0110) ? ~Z :                                // not equal
                    (cond == 4'b0111) ? Z :                                 // equal
                    (cond == 4'b1000) ? ~V :                                // overflow clear
                    (cond == 4'b1001) ? V :                                 // overflow set
                    (cond == 4'b1010) ? ~N :                                // plus
                    (cond == 4'b1011) ? N :                                 // minus
                    (cond == 4'b1100) ? (N & V) | (~N & ~V) :               // greater or equal
                    (cond == 4'b1101) ? (N & ~V) | (~N & V)    :            // less than
                    (cond == 4'b1110) ? (N & V & ~Z) | (~N & ~V & ~Z) :     // greater than
                    (cond == 4'b1111) ? (Z) | (N & ~V) | (~N & V) :         // less or equal
                    1'b0;
endmodule

/***********************************************************************************************************************
 * ALU
 **********************************************************************************************************************/

/*! \brief Arithmetic and Logic Unit.
 *
 * The alu module is responsible for performing all of the arithmetic and logic operations of the ao68000 processor.
 * It operates on two 32-bit registers: operand1 and operand2 from the registers module. The output is saved into
 * a result 32-bit register. This register is located in the alu module.
 * 
 * The alu module also contains the status register (SR) with the condition code register. The microcode decides what
 * operation the alu performs.
 */
module alu(
    input clock,
    input reset_n,

    // only zero bit
    input [31:0] address,
    // only ir[11:9] and ir[6]
    input [15:0] ir,
    // byte 2'b00, word 2'b01, long 2'b10
    input [2:0] size,

    input [31:0] operand1,
    input [31:0] operand2,

    input [2:0] interrupt_mask,
    input [4:0] alu_control,

    output reg [15:0] sr,
    output reg [31:0] result,
    
    output reg alu_signal,
    output alu_mult_div_ready,
    input [17:0] decoder_alu_reg
);

//****************************************************** Altera-specific multiplication and division modules START
/* Multiplication and division modules.
 *
 * Currently this module contains:
 * - <em>lpm_mult</em> instantiation from Altera Megafunction/LPM library,
 * - a sequential state machine for division written by Frederic Requin
 */

wire        mult_div_sign = ir[8];

// 18-2 - division calculation, 1 - waiting for result read, 0 - idle
reg  [4:0]  div_count;
reg [16:0]  quotient;
reg [31:0]  dividend, divider;

// Compute the difference with borrow
wire [32:0] div_diff = (dividend - divider);

// Overflow flag: when (quotient >= 65536) or (signed division and (quotient >= 32768 or quotient < -32768))
wire        div_overflow =
    (quotient[16] == 1'b1 ||
        (mult_div_sign == 1'b1 && (
            ((operand1[31] ^ operand2[15]) == 1'b0 && quotient[15] == 1'b1) ||
            ((operand1[31] ^ operand2[15]) == 1'b1 && quotient[15:0] > 16'd32768) )));

wire [15:0] div_quotient = 
    // positive quotient
    (((operand1[31] ^ operand2[15]) & mult_div_sign) == 1'b0)? quotient[15:0] :
    // negative quotient
    -quotient[15:0];

wire [15:0] div_remainder =
    // positive remainder
    ((operand1[31] & mult_div_sign) == 1'b0)? dividend[15:0] :
    // negative remainder
    -dividend[15:0];

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        div_count <= 5'd0;
    end
    // Cycle #0 : load the registers
    else if(alu_control == `ALU_MULS_MULU_DIVS_DIVU && ir[15:12] == 4'b1000 && div_count == 5'd0) begin
        // 17 cycles to finish + wait state
        div_count   <= 5'd18;
        // Clear the quotient
        quotient    <= 17'd0;
    
        // Unsigned divide or positive numerator
        if ((!mult_div_sign) || (!operand1[31]))    dividend <= operand1;
        // Negative numerator
        else                                        dividend <= -operand1;
        
        // Unsigned divide or positive denominator
        if ((!mult_div_sign) || (!operand2[15]))    divider <= {operand2[15:0],16'd0};
        // Negative denominator
        else                                        divider <= {-operand2[15:0],16'd0};
    end
    // Cycles #1-17 : division calculation
    else if(div_count > 5'd1) begin
        // Check difference's sign
        if (!div_diff[32]) begin
          // Difference is positive : shift a one
          dividend <= div_diff[31:0];
          quotient <= {quotient[15:0], 1'b1};
        end
        else begin
          // Difference is negative : shift a zero
          quotient <= {quotient[15:0], 1'b0};
        end
        // Shift right divider
        divider <= {1'b0, divider[31:1]};
        // Count one bit
        div_count <= div_count - 5'd1;
    end
    // result read
    else if(alu_control == `ALU_MULS_MULU_DIVS_DIVU && ir[15:12] == 4'b1000 && div_count == 5'd1) begin
        // goto idle
        div_count <= div_count - 5'd1;
    end
end

// MULS/MULU: 16-bit operand1[15:0] signed/unsigned * operand2[15:0] signed/unsigned = 32-bit result signed/unsigned
// Optimization by Frederic Requin
wire [33:0] mult_result;

lpm_mult muls(
    .clock  (clock),
    .dataa  ({operand1[15] & mult_div_sign, operand1[15:0]}),
    .datab  ({operand2[15] & mult_div_sign, operand2[15:0]}),
    .result (mult_result)
);
defparam
    muls.lpm_widtha = 17,
    muls.lpm_widthb = 17,
    muls.lpm_widthp = 34,
    muls.lpm_representation = "SIGNED",
    muls.lpm_pipeline = 1;

// multiplication ready in one cycle, division ready when div_count in waiting or idle state
assign alu_mult_div_ready = (div_count == 5'd1 || div_count == 5'd0);

//****************************************************** Altera-specific multiplication and division modules END

wire [5:0]  result_ABCD_13_8a   = {1'b0, operand1[3:0]} + {1'b0, operand2[3:0]} + {4'b0, sr[4]};
wire [5:0]  result_ABCD_19_14   = {1'b0, operand1[7:4]} + {1'b0, operand2[7:4]};
wire [8:0]  result_ABCD_31_23   = operand1[7:0] + operand2[7:0] + {7'b0, sr[4]};
wire [5:0]  result_ABCD_13_8b   = (result_ABCD_13_8a > 6'd9) ? (result_ABCD_13_8a + 6'd6) : result_ABCD_13_8a;

wire [5:0]  result_SBCD_13_8a   = 6'd32 + {2'b0, operand1[3:0]} - {2'b0, operand2[3:0]} - {5'b0, sr[4]};
wire [5:0]  result_SBCD_19_14   = 6'd32 + {2'b0, operand1[7:4]} - {2'b0, operand2[7:4]};
wire [8:0]  result_SBCD_31_23   = operand1[7:0] - operand2[7:0] - {7'b0, sr[4]};
wire [5:0]  result_SBCD_13_8b   = (result_SBCD_13_8a < 6'd32) ? (result_SBCD_13_8a - 6'd6) : result_SBCD_13_8a;

wire [5:0]  result_ABCD2_19_14a = (result[13:8] > 6'h1F) ? (result[19:14] + 6'd2) :
                                  (result[13:8] > 6'h0F) ? (result[19:14] + 6'd1) :
                                  result[19:14];
wire [5:0]  result_ABCD2_19_14b = (result_ABCD2_19_14a > 6'd9) ? (result_ABCD2_19_14a + 6'd6) : result_ABCD2_19_14a;
wire [3:0]  result_ABCD2_7_4    = result_ABCD2_19_14b[3:0];
wire [3:0]  result_ABCD2_3_0    = result[11:8];
wire [31:0] result_ABCD2        = {result[31:20], result_ABCD2_19_14b, result[13:8], result_ABCD2_7_4, result_ABCD2_3_0};


wire [5:0]  result_SBCD2_19_14a = (result[13:8] < 6'd16) ? (result[19:14] - 6'd2) :
                                  (result[13:8] < 6'd32) ? (result[19:14] - 6'd1) :
                                  result[19:14];
wire [5:0]  result_SBCD2_19_14b = (result_SBCD2_19_14a < 6'd32 && result[31] == 1'b1) ? (result_SBCD2_19_14a - 6'd6) : result_SBCD2_19_14a;
wire [3:0]  result_SBCD2_7_4    = result_SBCD2_19_14b[3:0];
wire [3:0]  result_SBCD2_3_0    = result[11:8];
wire [31:0] result_SBCD2        = {result[31:20], result_SBCD2_19_14b, result[13:8], result_SBCD2_7_4, result_SBCD2_3_0};

wire [15:0] result_CHK          = operand1[15:0] - operand2[15:0];

wire        result_BITS8_val    = ~(operand1[ operand2[2:0] ]);
wire        result_BITS8_bit    = (ir[7:6] == 2'b01) ? result_BITS8_val : (ir[7:6] == 2'b10) ? 1'b0 : 1'b1;
wire [31:0] result_BITS8        = { operand1[31:8],
                                    (operand2[2:0] == 3'd7)? result_BITS8_bit : operand1[7],
                                    (operand2[2:0] == 3'd6)? result_BITS8_bit : operand1[6],
                                    (operand2[2:0] == 3'd5)? result_BITS8_bit : operand1[5],
                                    (operand2[2:0] == 3'd4)? result_BITS8_bit : operand1[4],
                                    (operand2[2:0] == 3'd3)? result_BITS8_bit : operand1[3],
                                    (operand2[2:0] == 3'd2)? result_BITS8_bit : operand1[2],
                                    (operand2[2:0] == 3'd1)? result_BITS8_bit : operand1[1],
                                    (operand2[2:0] == 3'd0)? result_BITS8_bit : operand1[0] };

wire        result_BITS32_val   = ~(operand1[ operand2[4:0] ]);
wire        result_BITS32_bit   = (ir[7:6] == 2'b01) ? result_BITS32_val : (ir[7:6] == 2'b10) ? 1'b0 : 1'b1;
wire [31:0] result_BITS32       = { (operand2[4:0] == 5'd31)? result_BITS32_bit : operand1[31],
                                    (operand2[4:0] == 5'd30)? result_BITS32_bit : operand1[30],
                                    (operand2[4:0] == 5'd29)? result_BITS32_bit : operand1[29],
                                    (operand2[4:0] == 5'd28)? result_BITS32_bit : operand1[28],
                                    (operand2[4:0] == 5'd27)? result_BITS32_bit : operand1[27],
                                    (operand2[4:0] == 5'd26)? result_BITS32_bit : operand1[26],
                                    (operand2[4:0] == 5'd25)? result_BITS32_bit : operand1[25],
                                    (operand2[4:0] == 5'd24)? result_BITS32_bit : operand1[24],
                                    (operand2[4:0] == 5'd23)? result_BITS32_bit : operand1[23],
                                    (operand2[4:0] == 5'd22)? result_BITS32_bit : operand1[22],
                                    (operand2[4:0] == 5'd21)? result_BITS32_bit : operand1[21],
                                    (operand2[4:0] == 5'd20)? result_BITS32_bit : operand1[20],
                                    (operand2[4:0] == 5'd19)? result_BITS32_bit : operand1[19],
                                    (operand2[4:0] == 5'd18)? result_BITS32_bit : operand1[18],
                                    (operand2[4:0] == 5'd17)? result_BITS32_bit : operand1[17],
                                    (operand2[4:0] == 5'd16)? result_BITS32_bit : operand1[16],
                                    (operand2[4:0] == 5'd15)? result_BITS32_bit : operand1[15],
                                    (operand2[4:0] == 5'd14)? result_BITS32_bit : operand1[14],
                                    (operand2[4:0] == 5'd13)? result_BITS32_bit : operand1[13],
                                    (operand2[4:0] == 5'd12)? result_BITS32_bit : operand1[12],
                                    (operand2[4:0] == 5'd11)? result_BITS32_bit : operand1[11],
                                    (operand2[4:0] == 5'd10)? result_BITS32_bit : operand1[10],
                                    (operand2[4:0] == 5'd9 )? result_BITS32_bit : operand1[9 ],
                                    (operand2[4:0] == 5'd8 )? result_BITS32_bit : operand1[8 ],
                                    (operand2[4:0] == 5'd7 )? result_BITS32_bit : operand1[7 ],
                                    (operand2[4:0] == 5'd6 )? result_BITS32_bit : operand1[6 ],
                                    (operand2[4:0] == 5'd5 )? result_BITS32_bit : operand1[5 ],
                                    (operand2[4:0] == 5'd4 )? result_BITS32_bit : operand1[4 ],
                                    (operand2[4:0] == 5'd3 )? result_BITS32_bit : operand1[3 ],
                                    (operand2[4:0] == 5'd2 )? result_BITS32_bit : operand1[2 ],
                                    (operand2[4:0] == 5'd1 )? result_BITS32_bit : operand1[1 ],
                                    (operand2[4:0] == 5'd0 )? result_BITS32_bit : operand1[0 ] };

wire [4:0]  result_NBCD_3_0a    = 5'd25 - operand1[3:0];
wire [4:0]  result_NBCD_7_4a    = (operand1[3:0] > 4'd9) ? (5'd24 - operand1[7:4]) : (5'd25 - operand1[7:4]);

wire [3:0]  result_NBCD_3_0b    =   (sr[4] == 1'b0 && result_NBCD_3_0a[3:0] == 4'd9 && result_NBCD_7_4a[3:0] == 4'd9)?      4'd0 :
                                    (sr[4] == 1'b0 && (result_NBCD_3_0a[3:0] == 4'd9 || result_NBCD_3_0a[3:0] == 4'd15))?   4'd0 :
                                    (sr[4] == 1'b0)?                                                                        result_NBCD_3_0a[3:0] + 4'd1 :
                                                                                                                            result_NBCD_3_0a[3:0];
wire [3:0]  result_NBCD_7_4b    =   (sr[4] == 1'b0 && result_NBCD_3_0a[3:0] == 4'd9 && result_NBCD_7_4a[3:0] == 4'd9)?      4'd0 :
                                    (sr[4] == 1'b0 && (result_NBCD_3_0a[3:0] == 4'd9 || result_NBCD_3_0a[3:0] == 4'd15))?   result_NBCD_7_4a[3:0] + 4'd1 :
                                                                                                                            result_NBCD_7_4a[3:0];
                                                                                                                
wire [31:0] result_blocking =
    // OR,OR to mem,OR to Dn
    (alu_control == `ALU_ARITHMETIC_LOGIC && decoder_alu_reg[0])?                               operand1[31:0] | operand2[31:0] :
    // AND,AND to mem,AND to Dn
    (alu_control == `ALU_ARITHMETIC_LOGIC && decoder_alu_reg[1])?                               operand1[31:0] & operand2[31:0] :
    // EORI,EOR
    (alu_control == `ALU_ARITHMETIC_LOGIC && decoder_alu_reg[2])?                               operand1[31:0] ^ operand2[31:0] :
    // ADD,ADD to mem,ADD to Dn,ADDQ
    (alu_control == `ALU_ARITHMETIC_LOGIC && decoder_alu_reg[3])?                               operand1[31:0] + operand2[31:0] :
    // SUBI,CMPI,CMPM,SUB to mem,SUB to Dn,CMP,SUBQ
    (alu_control == `ALU_ARITHMETIC_LOGIC && (decoder_alu_reg[4] | decoder_alu_reg[5]))?        operand1[31:0] - operand2[31:0] :
    // ABCD
    (alu_control == `ALU_ABCD_SBCD_ADDX_SUBX_prepare && ir[14:12] == 3'b100)?                   { result_ABCD_31_23, result[22:20], result_ABCD_19_14, result_ABCD_13_8b, result[7:0] } :
    // SBCD
    (alu_control == `ALU_ABCD_SBCD_ADDX_SUBX_prepare && ir[14:12] == 3'b000)?                   { result_SBCD_31_23, result[22:20], result_SBCD_19_14, result_SBCD_13_8b, result[7:0] } :
    // ABCD2
    (alu_control == `ALU_ABCD_SBCD_ADDX_SUBX && ir[14:12] == 3'b100)?                           result_ABCD2 :
    // SBCD2
    (alu_control == `ALU_ABCD_SBCD_ADDX_SUBX && ir[14:12] == 3'b000)?                           result_SBCD2 :
    // ADDX
    (alu_control == `ALU_ABCD_SBCD_ADDX_SUBX && ir[14:12] == 3'b101)?                           operand1[31:0] + operand2[31:0] + sr[4] :
    // SUBX
    (alu_control == `ALU_ABCD_SBCD_ADDX_SUBX && ir[14:12] == 3'b001)?                           operand1[31:0] - operand2[31:0] - sr[4] :
    // shift/rotate prepare
    (alu_control == `ALU_ASL_LSL_ROL_ROXL_ASR_LSR_ROR_ROXR_prepare)?                            operand1[31:0] :
    // ASL / LSL / ROL / ROXL
    (alu_control == `ALU_ASL_LSL_ROL_ROXL_ASR_LSR_ROR_ROXR && 
        (decoder_alu_reg[8] | decoder_alu_reg[9] | decoder_alu_reg[10] | decoder_alu_reg[11]))? {operand1[30:0], lbit} :
    // ASR / LSR / ROR / ROXR
    (alu_control == `ALU_ASL_LSL_ROL_ROXL_ASR_LSR_ROR_ROXR)?                                    {rbit, operand1[31:17], (size[1]) ? rbit : operand1[16], operand1[15:9],
                                                                                                 (size[0]) ? rbit : operand1[8], operand1[7:1] } :
    // MOVE
    (alu_control == `ALU_MOVE)?                                                                 operand1 :
    // ADDA,ADDQ
    (alu_control == `ALU_ADDA_SUBA_CMPA_ADDQ_SUBQ && decoder_alu_reg[6])?                       operand1[31:0] + operand2[31:0] :
    // SUBA,CMPA,SUBQ
    (alu_control == `ALU_ADDA_SUBA_CMPA_ADDQ_SUBQ)?                                             operand1[31:0] - operand2[31:0] :
    // CHK
    (alu_control == `ALU_CHK)?                                                                  { result[31:16], result_CHK } :
    // NEGX / CLR / NEG / NOT
    (alu_control == `ALU_NEGX_CLR_NEG_NOT_NBCD_SWAP_EXT &&
     ((ir[11:8] == 4'b0000) || (ir[11:8] == 4'b0010) || (ir[11:8] == 4'b0100) || (ir[11:8] == 4'b0110)))? 
                                                                                                32'b0 - (operand1[31:0] & {32{ir[10] | ~ir[9]}}) - ((sr[4] & ~ir[10] & ~ir[9]) | (ir[10] & ir[9])) :
    // NBCD
    (alu_control == `ALU_NEGX_CLR_NEG_NOT_NBCD_SWAP_EXT && ir[11:6] == 6'b1000_00)?             { result[31:8], result_NBCD_7_4b, result_NBCD_3_0b } :
    // SWAP
    (alu_control == `ALU_NEGX_CLR_NEG_NOT_NBCD_SWAP_EXT && ir[11:6] == 6'b1000_01)?             { operand1[15:0], operand1[31:16] } :
    // EXT byte to word
    (alu_control == `ALU_NEGX_CLR_NEG_NOT_NBCD_SWAP_EXT && ir[11:6] == 6'b1000_10)?             { result[31:16], {8{operand1[7]}}, operand1[7:0] } :
    // EXT word to long
    (alu_control == `ALU_NEGX_CLR_NEG_NOT_NBCD_SWAP_EXT && ir[11:6] == 6'b1000_11)?             { {16{operand1[15]}}, operand1[15:0] } :
    // else
                                                                                                result[31:0];
 
// ALU internal defines
`define Sm ((size[0] == 1'b1) ? operand2[7] :                   (size[1] == 1'b1) ? operand2[15] :                      operand2[31])

`define Dm ((size[0] == 1'b1) ? operand1[7] :                   (size[1] == 1'b1) ? operand1[15] :                      operand1[31])

`define Rm ((size[0] == 1'b1) ? result_blocking[7] :            (size[1] == 1'b1) ? result_blocking[15] :               result_blocking[31])

`define Z  ((size[0] == 1'b1) ? (result_blocking[7:0] == 8'b0) :(size[1] == 1'b1) ? (result_blocking[15:0] == 16'b0) :  (result_blocking[31:0] == 32'b0))

// ALU operations

reg [2:0] interrupt_mask_copy;
reg was_interrupt;

// Bit being shifted left
wire lbit = (`Dm & decoder_alu_reg[10]) | (sr[4] & decoder_alu_reg[11]);
// Bit being shifted right
wire rbit = (`Dm & decoder_alu_reg[12]) | (operand1[0] & decoder_alu_reg[14]) | (sr[4] & decoder_alu_reg[15]);

   
always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        sr                  <= { 1'b0, 1'b0, 1'b1, 2'b0, 3'b111, 8'b0 };
        result              <= 32'd0;
        alu_signal          <= 1'b0;
        interrupt_mask_copy <= 3'b0;
        was_interrupt       <= 1'b0;
    end
    else begin
        case(alu_control)
            `ALU_SR_SET_INTERRUPT: begin
                interrupt_mask_copy <= interrupt_mask[2:0];
                was_interrupt <= 1'b1;
            end

            `ALU_SR_SET_TRAP: begin
                if(was_interrupt == 1'b1) begin
                    sr <= { 1'b0, sr[14], 1'b1, sr[12:11], interrupt_mask_copy[2:0], sr[7:0] };
                end
                else begin
                    sr <= { 1'b0, sr[14], 1'b1, sr[12:0] };
                end
                was_interrupt <= 1'b0;
            end

            `ALU_MOVEP_M2R_1: begin
                if(ir[6] == 1'b1)   result[31:24] <= operand1[7:0];
                else                result[15:8] <= operand1[7:0];
                //CCR: no change
            end
            `ALU_MOVEP_M2R_2: begin
                if(ir[6] == 1'b1)   result[23:16] <= operand1[7:0];
                else                result[7:0] <= operand1[7:0];
                //CCR: no change
            end
            `ALU_MOVEP_M2R_3: begin
                if(ir[6] == 1'b1)   result[15:8] <= operand1[7:0];
                //CCR: no change
            end
            `ALU_MOVEP_M2R_4: begin
                if(ir[6] == 1'b1)   result[7:0] <= operand1[7:0];
                //CCR: no change
            end
            

            `ALU_MOVEP_R2M_1: begin
                if(ir[6] == 1'b1)   result[7:0] <= operand1[31:24];
                else                result[7:0] <= operand1[15:8];
                // CCR: no change
            end
            `ALU_MOVEP_R2M_2: begin
                if(ir[6] == 1'b1)   result[7:0] <= operand1[23:16];
                else                result[7:0] <= operand1[7:0];
                // CCR: no change
            end
            `ALU_MOVEP_R2M_3: begin
                result[7:0] <= operand1[15:8];
                // CCR: no change
            end
            `ALU_MOVEP_R2M_4: begin
                result[7:0] <= operand1[7:0];
                // CCR: no change
            end

            `ALU_SIGN_EXTEND: begin
                // move operand1 with sign-extension to result
                if(size[1] == 1'b1) begin
                    result <= { {16{operand1[15]}}, operand1[15:0] };
                end
                else begin
                    result <= operand1;
                end
                // CCR: no change
            end

            `ALU_ARITHMETIC_LOGIC: begin
                
                result <= result_blocking;

                // Z
                sr[2] <= `Z;
                // N
                sr[3] <= `Rm;

                // CMPI,CMPM,CMP
                if(decoder_alu_reg[5]) begin
                    // C,V
                    sr[0] <= (`Sm & ~`Dm) | (`Rm & ~`Dm) | (`Sm & `Rm);
                    sr[1] <= (~`Sm & `Dm & ~`Rm) | (`Sm & ~`Dm & `Rm);
                    // X not affected
                end
                // ADDI,ADD to mem,ADD to Dn,ADDQ
                else if(decoder_alu_reg[3]) begin
                    // C,X,V
                    sr[0] <= (`Sm & `Dm) | (~`Rm & `Dm) | (`Sm & ~`Rm);
                    sr[4] <= (`Sm & `Dm) | (~`Rm & `Dm) | (`Sm & ~`Rm); //=ccr[0];
                    sr[1] <= (`Sm & `Dm & ~`Rm) | (~`Sm & ~`Dm & `Rm);
                end
                // SUBI,SUB to mem,SUB to Dn,SUBQ
                else if(decoder_alu_reg[4]) begin
                    // C,X,V
                    sr[0] <= (`Sm & ~`Dm) | (`Rm & ~`Dm) | (`Sm & `Rm);
                    sr[4] <= (`Sm & ~`Dm) | (`Rm & ~`Dm) | (`Sm & `Rm); //=ccr[0];
                    sr[1] <= (~`Sm & `Dm & ~`Rm) | (`Sm & ~`Dm & `Rm);
                end
                // ANDI,EORI,ORI,EOR,OR to mem,AND to mem,OR to Dn,AND to Dn
                else begin
                    // C,V
                    sr[0] <= 1'b0;
                    sr[1] <= 1'b0;
                    // X not affected
                end
            end
            
            `ALU_ABCD_SBCD_ADDX_SUBX_prepare: begin
                result <= result_blocking;
            end
            
            `ALU_ABCD_SBCD_ADDX_SUBX: begin
                // ABCD
                if( ir[14:12] == 3'b100) begin
                    result <= result_ABCD2;

                    // C
                    sr[0] <= (result_ABCD2[19:14] > 6'd9) ? 1'b1 : 1'b0;
                    // X = C
                    sr[4] <= (result_ABCD2[19:14] > 6'd9) ? 1'b1 : 1'b0;
                    
                    // V
                    sr[1] <= (result_ABCD2[30] == 1'b0 && result_ABCD2[7] == 1'b1) ? 1'b1 : 1'b0;
                end
                // SBCD
                else if( ir[14:12] == 3'b000 ) begin
                    result <= result_SBCD2;

                    // C
                    sr[0] <= (result_SBCD2[19:14] < 6'd32) ? 1'b1 : 1'b0;
                    // X = C
                    sr[4] <= (result_SBCD2[19:14] < 6'd32) ? 1'b1 : 1'b0;
                    
                    // V
                    sr[1] <= (result_SBCD2[30] == 1'b1 && result_SBCD2[7] == 1'b0) ? 1'b1 : 1'b0;
                end
                // ADDX
                else if( ir[14:12] == 3'b101 ) begin
                    result <= result_blocking;
                    
                    // C,X,V
                    sr[0] <= (`Sm & `Dm) | (~`Rm & `Dm) | (`Sm & ~`Rm);
                    sr[4] <= (`Sm & `Dm) | (~`Rm & `Dm) | (`Sm & ~`Rm); //=ccr[0];
                    sr[1] <= (`Sm & `Dm & ~`Rm) | (~`Sm & ~`Dm & `Rm);
                end
                // SUBX
                else if( ir[14:12] == 3'b001 ) begin
                    result[31:0] <= result_blocking;
                    
                    // C,X,V
                    sr[0] <= (`Sm & ~`Dm) | (`Rm & ~`Dm) | (`Sm & `Rm);
                    sr[4] <= (`Sm & ~`Dm) | (`Rm & ~`Dm) | (`Sm & `Rm); //=ccr[0];
                    sr[1] <= (~`Sm & `Dm & ~`Rm) | (`Sm & ~`Dm & `Rm);
                end
                
                // Z
                sr[2] <= sr[2] & `Z;
                // N
                sr[3] <= `Rm;
            end
            
            `ALU_ASL_LSL_ROL_ROXL_ASR_LSR_ROR_ROXR_prepare: begin
                // 32-bit load even for 8-bit and 16-bit operations
                // The extra bits will be anyway discarded during register / memory write
                result[31:0] <= result_blocking;
                
                // V cleared
                sr[1] <= 1'b0;
                // C for ROXL,ROXR: set to X
                if(decoder_alu_reg[11] | decoder_alu_reg[15]) begin
                    sr[0] <= sr[4];
                end
                else begin
                    // C cleared
                    sr[0] <= 1'b0;
                end

                // N set
                sr[3] <= `Rm;
                // Z set
                sr[2] <= `Z;
            end 
            
            `ALU_ASL_LSL_ROL_ROXL_ASR_LSR_ROR_ROXR: begin
                // ASL / LSL / ROL / ROXL
                if (decoder_alu_reg[8] | decoder_alu_reg[9] | decoder_alu_reg[10] | decoder_alu_reg[11]) begin
                    result[31:0] <= result_blocking;

                    sr[0] <= `Dm; // C for ASL / LSL / ROL / ROXL
                    if (decoder_alu_reg[8])
                        sr[1] <= (sr[1] == 1'b0)? (`Rm != `Dm) : 1'b1; // V for ASL
                    else
                        sr[1] <= 1'b0; // V for LSL / ROL / ROXL
                   
                    if (!decoder_alu_reg[10]) sr[4] <= `Dm; // X for ASL / LSL / ROXL
                end
                // ASR / LSR / ROR / ROXR
                else begin
                    result[31:0] <= result_blocking;
                    sr[0] <= operand1[0]; // C for ASR / LSR / ROR / ROXR
                    sr[1] <= 1'b0;        // V for ASR / LSR / ROR / ROXR
                    if (!decoder_alu_reg[14]) sr[4] <= operand1[0]; // X for ASR / LSR / ROXR
                end

                // N set
                sr[3] <= `Rm;
                // Z set
                sr[2] <= `Z;
            end
    
    
            `ALU_MOVE: begin
                result <= result_blocking;

                // X not affected
                // C cleared
                sr[0] <= 1'b0;
                // V cleared
                sr[1] <= 1'b0;

                // N set
                sr[3] <= `Rm;
                // Z set
                sr[2] <= `Z;
            end
    
            `ALU_ADDA_SUBA_CMPA_ADDQ_SUBQ: begin
                // ADDA: 1101
                // CMPA: 1011
                // SUBA: 1001
                // ADDQ,SUBQ: 0101 xxx0,1
                // operation requires that operand2 was sign extended
                
                result[31:0] <= result_blocking;
                
                // for CMPA
                if( ir[15:12] == 4'b1011 ) begin
                    // Z
                    sr[2] <= `Z;
                    // N
                    sr[3] <= `Rm;

                    // C,V
                    sr[0] <= (`Sm & ~`Dm) | (`Rm & ~`Dm) | (`Sm & `Rm);
                    sr[1] <= (~`Sm & `Dm & ~`Rm) | (`Sm & ~`Dm & `Rm);
                    // X not affected
                end
                // for ADDA,SUBA,ADDQ,SUBQ: ccr not affected
            end

            `ALU_CHK: begin
                result <= result_blocking;
                
                // undocumented behavior: Z flag, see 68knotes.txt
                //sr[2] <= (operand1[15:0] == 16'b0) ? 1'b1 : 1'b0;
                // undocumented behavior: C,V flags, see 68knotes.txt
                //sr[0] <= 1'b0;
                //sr[1] <= 1'b0;
                
                // C,X,V
                //    sr[0] <= (`Sm & ~`Dm) | (`Rm & ~`Dm) | (`Sm & `Rm);
                //    sr[4] <= (`Sm & ~`Dm) | (`Rm & ~`Dm) | (`Sm & `Rm); //=ccr[0];
                //    sr[1] <= (~`Sm & `Dm & ~`Rm) | (`Sm & ~`Dm & `Rm);
                // +: 0-1,    0-0=0, 1-1=0
                // -: 0-0=1,  1-0,   1-1=1
                // operand1 - operand2 > 0
                if( operand1[15:0] != operand2[15:0] && ((~`Dm & `Sm) | (~`Dm & ~`Sm & ~`Rm) | (`Dm & `Sm & ~`Rm)) == 1'b1 ) begin
                    // clear N
                    sr[3] <= 1'b0;
                    alu_signal <= 1'b1;
                end
                // operand1 < 0
                else if( operand1[15] == 1'b1 ) begin
                    // set N
                    sr[3] <= 1'b1;
                    alu_signal <= 1'b1;
                end
                // no trap
                else begin
                    // N undefined: not affected
                    alu_signal <= 1'b0;
                end

                // X not affected
            end
            
            `ALU_MULS_MULU_DIVS_DIVU: begin

                // division by 0
                if(ir[15:12] == 4'b1000 && operand2[15:0] == 16'b0) begin
                    // X not affected
                    // C cleared
                    sr[0] <= 1'b0;
                    // V,Z,N undefined: cleared
                    sr[1] <= 1'b0;
                    sr[2] <= 1'b0;
                    sr[3] <= 1'b0;

                    // set trap
                    alu_signal <= 1'b1;
                end
                // division in idle state
                else if(ir[15:12] == 4'b1000 && div_count == 5'd0) begin
                    alu_signal <= 1'b0;
                end
                // division overflow: divu, divs
                else if(ir[15:12] == 4'b1000 && div_overflow == 1'b1) begin
                    // X not affected
                    // C cleared
                    sr[0] <= 1'b0;
                    // V set
                    sr[1] <= 1'b1;
                    // Z,N undefined: cleared and set
                    sr[2] <= 1'b0;
                    sr[3] <= 1'b1;

                    // set trap
                    alu_signal <= 1'b1;
                end
                // division
                else if( ir[15:12] == 4'b1000 ) begin
                    result[31:0] <= {div_remainder, div_quotient};
                    
                    // X not affected
                    // C cleared
                    sr[0] <= 1'b0;
                    // V cleared
                    sr[1] <= 1'b0;
                    // Z
                    sr[2] <= (div_quotient == 16'b0);
                    // N
                    sr[3] <= (div_quotient[15] == 1'b1);

                    // set trap
                    alu_signal <= 1'b0;
                end
                // multiplication
                else if( ir[15:12] == 4'b1100 ) begin
                    result[31:0] <= mult_result[31:0];

                    // X not affected
                    // C cleared
                    sr[0] <= 1'b0;
                    // V cleared
                    sr[1] <= 1'b0;
                    // Z
                    sr[2] <= (mult_result[31:0] == 32'b0);
                    // N
                    sr[3] <= (mult_result[31] == 1'b1);

                    // set trap
                    alu_signal <= 1'b0;
                end
            end

            `ALU_BCHG_BCLR_BSET_BTST: begin // 97 LE
                // byte
                if( ir[5:3] != 3'b000 ) begin
                    sr[2] <= result_BITS8_val;
                    result <= result_BITS8;
                end
                // long
                else if( ir[5:3] == 3'b000 ) begin
                    sr[2] <= result_BITS32_val;
                    result <= result_BITS32;
                end

                // C,V,N,X not affected
            end
            
            `ALU_TAS: begin
                result[7:0] <= { 1'b1, operand1[6:0] };

                // X not affected
                // C cleared
                sr[0] <= 1'b0;
                // V cleared
                sr[1] <= 1'b0;

                // N set
                sr[3] <= (operand1[7] == 1'b1);
                // Z set
                sr[2] <= (operand1[7:0] == 8'b0);
            end


            `ALU_NEGX_CLR_NEG_NOT_NBCD_SWAP_EXT: begin
                // NEGX / CLR / NEG / NOT
                // Optimization thanks to Frederic Requin
                if ((ir[11:8] == 4'b0000) || (ir[11:8] == 4'b0010) || (ir[11:8] == 4'b0100) || (ir[11:8] == 4'b0110))
                    result <= result_blocking;
                // NBCD
                else if( ir[11:6] == 6'b1000_00 ) begin
                    result <= result_blocking;
                    
                    //V undefined: unchanged
                    //Z
                    sr[2] <= sr[2] & `Z;
                    //C,X
                    sr[0] <= (operand1[7:0] == 8'd0 && sr[4] == 1'b0) ? 1'b0 : 1'b1;
                    sr[4] <= (operand1[7:0] == 8'd0 && sr[4] == 1'b0) ? 1'b0 : 1'b1; //=C
                end
                // SWAP
                else if( ir[11:6] == 6'b1000_01 ) result <= result_blocking;
                // EXT byte to word
                else if( ir[11:6] == 6'b1000_10 ) result <= result_blocking;
                // EXT word to long
                else if( ir[11:6] == 6'b1000_11 ) result <= result_blocking;

                // N set if negative else clear
                sr[3] <= `Rm;

                // CLR,NOT,SWAP,EXT
                if( ir[11:8] == 4'b0010 || ir[11:8] == 4'b0110 || ir[11:6] == 6'b1000_01 || ir[11:7] == 5'b1000_1 ) begin
                    // X not affected
                    // C,V cleared
                    sr[0] <= 1'b0;
                    sr[1] <= 1'b0;
                    // Z set
                    sr[2] <= `Z;
                end
                // NEGX
                else if( ir[11:8] == 4'b0000 ) begin
                    // C set if borrow
                    sr[0] <= `Dm | `Rm;
                    // X=C
                    sr[4] <= `Dm | `Rm;
                    // V set if overflow
                    sr[1] <= `Dm & `Rm;
                    // Z cleared if nonzero else unchanged
                    sr[2] <= sr[2] & `Z;
                end
                // NEG
                else if( ir[11:8] == 4'b0100 ) begin
                    // C clear if zero else set
                    sr[0] <= `Dm | `Rm;
                    // X=C
                    sr[4] <= `Dm | `Rm;
                    // V set if overflow
                    sr[1] <= `Dm & `Rm;
                    // Z set if zero else clear
                    sr[2] <= `Z;
                end
            end


            `ALU_SIMPLE_LONG_ADD: begin
                result <= operand1[31:0] + operand2[31:0];

                // CCR not affected
            end

            `ALU_SIMPLE_LONG_SUB: begin
                result <= operand1[31:0] - operand2[31:0];

                // CCR not affected
            end

            `ALU_MOVE_TO_CCR_SR_RTE_RTR_STOP_LOGIC_TO_CCR_SR: begin

                // MOVE TO SR,RTE,STOP,ORI to SR,ANDI to SR,EORI to SR
                if(decoder_alu_reg[16]) sr <= { operand1[15], 1'b0, operand1[13], 2'b0, operand1[10:8], 3'b0, operand1[4:0] };
                // MOVE TO CCR,RTR,ORI to CCR,ANDI to CCR,EORI to CCR
                else                    sr <= { sr[15:8], 3'b0, operand1[4:0] };
            end

            `ALU_SIMPLE_MOVE: begin
                result <= operand1;
                
                // CCR not affected
            end
            
            `ALU_LINK_MOVE: begin
                if(ir[3:0] == 3'b111) begin
                    result <= operand1 - 32'd4;
                end
                else begin
                    result <= operand1;
                end
                
                // CCR not affected
            end

        endcase
    end
end

endmodule

/***********************************************************************************************************************
 * Microcode branch
 **********************************************************************************************************************/

/*! \brief Select the next microcode word to execute.
 *
 * The microcode_branch module is responsible for selecting the next microcode word to execute. This decision is based
 * on the value of the current microcode word, the value of the interrupt privilege level, the state of the current
 * bus cycle and other internal signals.
 *
 * The microcode_branch module implements a simple stack for the microcode addresses. This makes it possible to call
 * subroutines inside the microcode.
 */
module microcode_branch(
    input clock,
    input reset_n,

    input [4:0]     movem_loop,
    input [15:0]    movem_reg,
    input [31:0]    operand2,
    input           alu_signal,
    input           alu_mult_div_ready,
    input           condition,
    input [31:0]    result,
    input           overflow,
    input           stop_flag,
    input [15:0]    ir,
    input [7:0]     decoder_trap,
    input           trace_flag,
    input           group_0_flag,
    input [2:0]     interrupt_mask,

    input [8:0]     load_ea,
    input [8:0]     perform_ea_read,
    input [8:0]     perform_ea_write,
    input [8:0]     save_ea,
    input [8:0]     decoder_micropc,

    input           prefetch_ir_valid_32,
    input           prefetch_ir_valid,
    input           jmp_address_trap,
    input           jmp_bus_trap,
    input           finished,

    input [3:0]     branch_control,
    input [3:0]     branch_offset,
    output [8:0]    micro_pc
);

reg [8:0] micro_pc_0 = 9'd0;
reg [8:0] micro_pc_1;
reg [8:0] micro_pc_2;
reg [8:0] micro_pc_3;

assign micro_pc =
    (reset_n == 1'b0) ? 9'd0 :
    (jmp_address_trap == 1'b1 || jmp_bus_trap == 1'b1) ? `MICROPC_ADDRESS_BUS_TRAP :
    (   (branch_control == `BRANCH_movem_loop               && movem_loop == 5'b10000) ||
        (branch_control == `BRANCH_movem_reg                && movem_reg[0] == 0) ||
        (branch_control == `BRANCH_operand2                 && operand2[5:0] == 6'b0) ||
        (branch_control == `BRANCH_alu_signal               && alu_signal == 1'b0) ||
        (branch_control == `BRANCH_alu_mult_div_ready       && alu_mult_div_ready == 1'b1) ||
        (branch_control == `BRANCH_condition_0              && condition == 1'b0) ||
        (branch_control == `BRANCH_condition_1              && condition == 1'b1) ||
        (branch_control == `BRANCH_result                   && result[15:0] == 16'hFFFF) ||
        (branch_control == `BRANCH_V                        && overflow == 1'b0) ||
        (branch_control == `BRANCH_movep_16                 && ir[6] == 1'b0) ||
        (branch_control == `BRANCH_stop_flag_wait_ir_decode && stop_flag == 1'b1) ||
        (branch_control == `BRANCH_ir                       && ir[7:0] != 8'b0) ||
        (branch_control == `BRANCH_trace_flag_and_interrupt && trace_flag == 1'b0 && interrupt_mask != 3'b000) ||
        (branch_control == `BRANCH_group_0_flag             && group_0_flag == 1'b0)
    ) ? micro_pc_0 + { 5'd0, branch_offset } :
    (branch_control == `BRANCH_stop_flag_wait_ir_decode && prefetch_ir_valid == 1'b1 && decoder_trap == 8'd0) ?         decoder_micropc :
    (branch_control == `BRANCH_trace_flag_and_interrupt && trace_flag == 1'b0 && interrupt_mask == 3'b000) ?            `MICROPC_MAIN_LOOP :
    (branch_control == `BRANCH_procedure && branch_offset == `PROCEDURE_jump_to_main_loop) ?                            `MICROPC_MAIN_LOOP :
    (branch_control == `BRANCH_procedure && branch_offset == `PROCEDURE_call_load_ea && load_ea != 9'd0) ?              load_ea :
    (branch_control == `BRANCH_procedure && branch_offset == `PROCEDURE_call_perform_ea_read) ?                         perform_ea_read :
    (branch_control == `BRANCH_procedure && branch_offset == `PROCEDURE_call_perform_ea_write) ?                        perform_ea_write :
    (branch_control == `BRANCH_procedure && branch_offset == `PROCEDURE_call_save_ea && save_ea != 9'd0) ?              save_ea :

    (branch_control == `BRANCH_procedure && branch_offset == `PROCEDURE_call_read && load_ea != 9'd0) ?                 load_ea :
    (branch_control == `BRANCH_procedure && branch_offset == `PROCEDURE_call_read && load_ea == 9'd0) ?                 perform_ea_read :

    (branch_control == `BRANCH_procedure && branch_offset == `PROCEDURE_call_write) ?                                   perform_ea_write :

    (branch_control == `BRANCH_procedure && branch_offset == `PROCEDURE_call_trap) ?                                    `MICROPC_TRAP_ENTRY :
    (branch_control == `BRANCH_procedure && branch_offset == `PROCEDURE_return) ?                                       micro_pc_1 :
    (branch_control == `BRANCH_procedure && branch_offset == `PROCEDURE_interrupt_mask && interrupt_mask == 3'b000) ?   `MICROPC_MAIN_LOOP :
    (    (branch_control == `BRANCH_procedure && branch_offset == `PROCEDURE_wait_finished && finished == 1'b0) ||
        (branch_control == `BRANCH_procedure && branch_offset == `PROCEDURE_wait_prefetch_valid && prefetch_ir_valid == 1'b0) ||
        (branch_control == `BRANCH_procedure && branch_offset == `PROCEDURE_wait_prefetch_valid_32 && prefetch_ir_valid_32 == 1'b0) ||
        (branch_control == `BRANCH_stop_flag_wait_ir_decode && prefetch_ir_valid == 1'b0)
    ) ? micro_pc_0 :
    micro_pc_0 + 9'd1
;

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0) micro_pc_0 <= 9'd0;
    else                micro_pc_0 <= micro_pc;
end

always @(posedge clock or negedge reset_n) begin
    if(reset_n == 1'b0) begin
        micro_pc_1 <= 9'd0;
        micro_pc_2 <= 9'd0;
        micro_pc_3 <= 9'd0;
    end
    else if(branch_control == `BRANCH_stop_flag_wait_ir_decode && prefetch_ir_valid == 1'b1 && decoder_trap == 8'd0)
    begin
        micro_pc_1 <= micro_pc_0 + { 5'd0, branch_offset };
        micro_pc_2 <= micro_pc_1;
        micro_pc_3 <= micro_pc_2;
    end
    else if(branch_control == `BRANCH_procedure) begin
        if(branch_offset == `PROCEDURE_call_read && load_ea != 9'd0) begin
            micro_pc_1 <= perform_ea_read;
            micro_pc_2 <= micro_pc_0 + 9'd1;
            micro_pc_3 <= micro_pc_1;
        end
        else if(branch_offset == `PROCEDURE_call_read && load_ea == 9'd0) begin
            micro_pc_1 <= micro_pc_0 + 9'd1;
            micro_pc_2 <= micro_pc_1;
            micro_pc_3 <= micro_pc_2;
        end
        else if(branch_offset == `PROCEDURE_call_write && save_ea != 9'd0) begin
            micro_pc_1 <= save_ea;
            micro_pc_2 <= micro_pc_1;
            micro_pc_3 <= micro_pc_2;
        end
        else if((branch_offset == `PROCEDURE_call_load_ea && load_ea != 9'd0) ||
                (branch_offset == `PROCEDURE_call_perform_ea_read) ||
                (branch_offset == `PROCEDURE_call_perform_ea_write) ||
                (branch_offset == `PROCEDURE_call_save_ea && save_ea != 9'd0) ||
                (branch_offset == `PROCEDURE_call_trap) )
        begin
            micro_pc_1 <= micro_pc_0 + 9'd1;
            micro_pc_2 <= micro_pc_1;
            micro_pc_3 <= micro_pc_2;
        end
        else if(branch_offset == `PROCEDURE_return) begin
            micro_pc_1 <= micro_pc_2;
            micro_pc_2 <= micro_pc_3;
            micro_pc_3 <= 9'd0;
        end
        else if(branch_offset == `PROCEDURE_push_micropc) begin
            micro_pc_1 <= micro_pc_0;
            micro_pc_2 <= micro_pc_1;
            micro_pc_3 <= micro_pc_2;
        end
        else if(branch_offset == `PROCEDURE_pop_micropc) begin
            micro_pc_1 <= micro_pc_2;
            micro_pc_2 <= micro_pc_3;
            micro_pc_3 <= 9'd0;
        end
    end
end

endmodule