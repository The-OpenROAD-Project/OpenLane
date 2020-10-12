/**
 * UC Berkeley CS150
 * Fall 2014
 * List of ALU operations.
 *
 * This version written by Arya Reais-Parsi (aryap@berkeley.edu), Spring 2018
*/
`ifndef ALUOP
`define ALUOP

`define ALU_ADD		5'd0
`define ALU_SUB     	5'd1
`define ALU_AND     	5'd2
`define ALU_OR      	5'd3
`define ALU_XOR     	5'd4
`define ALU_SLT     	5'd5
`define ALU_SLTU    	5'd6
`define ALU_SLL     	5'd7
`define ALU_SRA     	5'd8
`define ALU_SRL     	5'd9
`define ALU_COPY_B  	5'd10		// TODO(aryap): Is the additional bit justified?
`define ALU_EQ      	5'd11
`define ALU_NE      	5'd12
`define ALU_LT			5'd13
`define ALU_GE			5'd14
`define ALU_LTU		5'd15
`define ALU_GEU		5'd16

`endif //ALUOP
