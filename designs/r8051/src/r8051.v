/////////////////////////////////////////////////////////////////////////////////////
//
//Copyright 2018  Li Xinbing
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.
//
/////////////////////////////////////////////////////////////////////////////////////

//`define TYPE8052
module r8051 (

input  wire        clk,
input  wire        rst,
input  wire        cpu_en,
input  wire        cpu_restart,
	
output reg         rom_en,
output reg  [15:0] rom_addr,
input  wire [7:0]  rom_byte,
input  wire        rom_vld,
	
output wire        ram_rd_en_data,
output wire        ram_rd_en_sfr,
`ifdef TYPE8052
output wire        ram_rd_en_idata,
`endif
output wire        ram_rd_en_xdata,
output wire [15:0] ram_rd_addr,
input  wire [7:0]  ram_rd_byte,
input  wire        ram_rd_vld,
	
output wire        ram_wr_en_data,
output wire        ram_wr_en_sfr,
`ifdef TYPE8052
output wire        ram_wr_en_idata,
`endif
output wire        ram_wr_en_xdata,
output wire [15:0] ram_wr_addr,
output wire [7:0]  ram_wr_byte

);

//`include "instruction.v"
//ARITHMETIC OPERATIONS
//ADD
function add_a_rn(input [7:0] i);  add_a_rn = (i[7:3]==5'b00101); endfunction
function add_a_di(input [7:0] i);  add_a_di=(i==8'b00100101); endfunction
function add_a_ri(input [7:0] i);  add_a_ri=(i[7:1]==7'b0010011); endfunction
function add_a_da(input [7:0] i);  add_a_da = (i==8'b00100100);  endfunction
//ADDC
function addc_a_rn(input [7:0] i); addc_a_rn = (i[7:3]==5'b00111); endfunction
function addc_a_di(input [7:0] i); addc_a_di = (i==8'b00110101); endfunction
function addc_a_ri(input [7:0] i); addc_a_ri = (i[7:1]==7'b0011011); endfunction
function addc_a_da(input [7:0] i); addc_a_da = (i==8'b00110100); endfunction
//SUBB
function subb_a_rn(input [7:0] i); subb_a_rn=(i[7:3]==5'b10011); endfunction
function subb_a_di(input [7:0] i); subb_a_di=(i==8'b10010101); endfunction
function subb_a_ri(input [7:0] i); subb_a_ri=(i[7:1]==7'b1001011); endfunction
function subb_a_da(input [7:0] i); subb_a_da = (i==8'b10010100); endfunction
//INC
function inc_a (input [7:0] i); inc_a = (i==8'b00000100); endfunction
function inc_rn(input [7:0] i); inc_rn = (i[7:3]==5'b00001); endfunction
function inc_di(input [7:0] i); inc_di = (i==8'b00000101); endfunction
function inc_ri(input [7:0] i); inc_ri = (i[7:1]==7'b0000011); endfunction
function inc_dp(input [7:0] i); inc_dp =(i==8'b10100011); endfunction
//DEC
function dec_a(input [7:0] i); dec_a = (i==8'b00010100); endfunction
function dec_rn(input [7:0] i); dec_rn = (i[7:3]==5'b00011); endfunction
function dec_di(input [7:0] i); dec_di = (i==8'b00010101); endfunction
function dec_ri(input [7:0] i); dec_ri = (i[7:1]==7'b0001011); endfunction
//MUL
function mul(input [7:0] i); mul=(i==8'b10100100); endfunction
//DIV
function div(input [7:0] i); div=(i==8'b10000100); endfunction
//DA
function da(input [7:0] i); da = (i==8'b11010100); endfunction

//LOGICAL OPERATIONS
//ANL
function anl_a_rn(input [7:0] i); anl_a_rn = (i[7:3]==5'b01011); endfunction
function anl_a_di(input [7:0] i); anl_a_di = (i==8'b01010101); endfunction
function anl_a_ri(input [7:0] i); anl_a_ri = (i[7:1]==7'b0101011); endfunction
function anl_a_da(input [7:0] i); anl_a_da = (i==8'b01010100); endfunction
function anl_di_a(input [7:0] i); anl_di_a = (i==8'b01010010); endfunction
function anl_di_da(input [7:0] i); anl_di_da = (i==8'b01010011); endfunction
//ORL
function orl_a_rn(input [7:0] i); orl_a_rn = (i[7:3]==5'b01001); endfunction
function orl_a_di(input [7:0] i); orl_a_di = (i==8'b01000101); endfunction
function orl_a_ri(input [7:0] i); orl_a_ri = (i[7:1]==7'b0100011); endfunction
function orl_a_da(input [7:0] i); orl_a_da = (i==8'b01000100); endfunction
function orl_di_a(input [7:0] i); orl_di_a=(i==8'b01000010); endfunction
function orl_di_da(input [7:0] i); orl_di_da=(i==8'b01000011); endfunction
//XRL
function xrl_a_rn(input [7:0] i); xrl_a_rn = (i[7:3]==5'b01101); endfunction
function xrl_a_di(input [7:0] i); xrl_a_di = (i==8'b01100101); endfunction
function xrl_a_ri(input [7:0] i); xrl_a_ri = (i[7:1]==7'b0110011); endfunction
function xrl_a_da(input [7:0] i); xrl_a_da = (i==8'b01100100); endfunction
function xrl_di_a(input [7:0] i); xrl_di_a = (i==8'b01100010); endfunction
function xrl_di_da(input [7:0] i); xrl_di_da = (i==8'b01100011); endfunction
//CLR
function clr_a(input [7:0] i); clr_a = (i==8'b11100100); endfunction
//CPL
function cpl_a(input [7:0] i); cpl_a = (i==8'b11110100); endfunction
//RL
function rl(input [7:0] i); rl = (i==8'b00100011); endfunction
//RLC
function rlc(input [7:0] i); rlc = (i==8'b00110011); endfunction
//RR
function rr(input [7:0] i); rr = (i==8'b00000011); endfunction
//RRC
function rrc(input [7:0] i); rrc = (i==8'b00010011); endfunction
//SWAP
function swap(input [7:0] i); swap = (i==8'b11000100); endfunction

//DATA TRANSFER
//MOV
function mov_a_rn(input [7:0] i); mov_a_rn = (i[7:3]==5'b11101); endfunction
function mov_a_di(input [7:0] i); mov_a_di = (i==8'b11100101); endfunction
function mov_a_ri(input [7:0] i); mov_a_ri = (i[7:1]==7'b1110011); endfunction
function mov_a_da(input [7:0] i); mov_a_da = (i==8'b01110100); endfunction
function mov_rn_a(input [7:0] i); mov_rn_a = (i[7:3]==5'b11111); endfunction
function mov_rn_di(input [7:0] i); mov_rn_di = (i[7:3]==5'b10101); endfunction
function mov_rn_da(input [7:0] i); mov_rn_da = (i[7:3]==5'b01111); endfunction
function mov_di_a(input [7:0] i); mov_di_a = (i==8'b11110101); endfunction
function mov_di_rn(input [7:0] i); mov_di_rn = (i[7:3]==5'b10001); endfunction
function mov_di_di(input [7:0] i); mov_di_di = (i==8'b10000101); endfunction
function mov_di_ri(input [7:0] i); mov_di_ri = (i[7:1]==7'b1000011); endfunction 
function mov_di_da(input [7:0] i); mov_di_da = (i==8'b01110101); endfunction
function mov_ri_a(input [7:0] i);  mov_ri_a = (i[7:1]==7'b1111011); endfunction
function mov_ri_di(input [7:0] i); mov_ri_di = (i[7:1]==7'b1010011); endfunction
function mov_ri_da(input [7:0] i); mov_ri_da=(i[7:1]==7'b0111011); endfunction
function mov_dp_da(input [7:0] i); mov_dp_da=(i==8'b10010000); endfunction
//MOVC
function movc_a_dp(input [7:0] i); movc_a_dp = (i==8'b10010011); endfunction
function movc_a_pc(input [7:0] i); movc_a_pc = (i==8'b10000011); endfunction
//MOVX
function movx_a_ri(input [7:0] i); movx_a_ri = (i[7:1]==7'b1110001); endfunction
function movx_a_dp(input [7:0] i); movx_a_dp = (i==8'b11100000); endfunction
function movx_ri_a(input [7:0] i); movx_ri_a = (i[7:1]==7'b1111001); endfunction
function movx_dp_a(input [7:0] i); movx_dp_a = (i==8'b11110000); endfunction
//PUSH
function push(input [7:0] i); push = (i==8'b11000000); endfunction
//POP
function pop(input [7:0] i); pop = (i==8'b11010000); endfunction
//XCH
function xch_a_rn(input [7:0] i); xch_a_rn = (i[7:3]==5'b11001); endfunction
function xch_a_di(input [7:0] i); xch_a_di = (i==8'b11000101); endfunction
function xch_a_ri(input [7:0] i); xch_a_ri = (i[7:1]==7'b1100011); endfunction
//XCHD
function xchd(input [7:0] i); xchd = (i[7:1]==7'b1101011); endfunction

//BOOLEAN VARIABLE MANIPULATION
//CLR
function clr_c(input [7:0] i); clr_c = (i==8'b11000011); endfunction
function clr_bit(input [7:0] i); clr_bit = (i==8'b11000010); endfunction
//SETB
function setb_c(input [7:0] i); setb_c = (i==8'b11010011); endfunction
function setb_bit(input [7:0] i); setb_bit = (i==8'b11010010); endfunction
//CPL
function cpl_c(input [7:0] i); cpl_c = (i==8'b10110011); endfunction
function cpl_bit(input [7:0] i); cpl_bit=(i==8'b10110010); endfunction
//ANL
function anl_c_bit(input [7:0] i); anl_c_bit = (i==8'b10000010); endfunction
function anl_c_nbit(input [7:0] i); anl_c_nbit = (i==8'b10110000); endfunction
//ORL
function orl_c_bit(input [7:0] i); orl_c_bit = (i==8'b01110010); endfunction
function orl_c_nbit(input [7:0] i); orl_c_nbit = (i==8'b10100000); endfunction
//MOV
function mov_c_bit(input [7:0] i); mov_c_bit = (i==8'b10100010); endfunction
function mov_bit_c(input [7:0] i); mov_bit_c = (i==8'b10010010); endfunction
//JC
function jc(input [7:0] i); jc = (i==8'b01000000); endfunction
//JNC
function jnc(input [7:0] i); jnc =(i==8'b01010000); endfunction
//JB
function jb(input [7:0] i); jb = (i==8'b00100000); endfunction
//JNB
function jnb(input [7:0] i); jnb = (i==8'b00110000); endfunction
//JBC
function jbc(input [7:0] i); jbc = (i==8'b00010000); endfunction

//PROGRAM BRANCHING
//ACALL
function acall(input [7:0] i); acall = (i[4:0]==5'b10001); endfunction
//LCALL
function lcall(input [7:0] i); lcall = (i==8'b00010010); endfunction
//RET
function ret(input [7:0] i); ret = (i==8'b00100010); endfunction
//RETI
function reti(input [7:0] i); reti = (i==8'b00110010); endfunction
//AJMP
function ajmp(input [7:0] i); ajmp = (i[4:0]==5'b00001); endfunction
//LJMP
function ljmp(input [7:0] i); ljmp = (i==8'b00000010); endfunction
//SJMP
function sjmp(input [7:0] i); sjmp = (i==8'b10000000); endfunction
//JMP
function jmp(input [7:0] i); jmp = (i==8'b01110011); endfunction
//JZ
function jz(input [7:0] i); jz = (i==8'b01100000); endfunction
//JNZ
function jnz(input [7:0] i); jnz = (i==8'b01110000); endfunction
//CJNE
function cjne_a_di_rel(input [7:0] i); cjne_a_di_rel = (i==8'b10110101); endfunction
function cjne_a_da_rel(input [7:0] i); cjne_a_da_rel = (i==8'b10110100); endfunction
function cjne_rn_da_rel(input [7:0] i); cjne_rn_da_rel = (i[7:3]==5'b10111); endfunction
function cjne_ri_da_rel(input [7:0] i); cjne_ri_da_rel=(i[7:1]==7'b1011011); endfunction
//DJNZ
function djnz_rn_rel(input [7:0] i); djnz_rn_rel = (i[7:3]==5'b11011); endfunction
function djnz_di_rel(input [7:0] i); djnz_di_rel =(i==8'b11010101); endfunction
//NOP
function nop(input [7:0] i); nop = (i==8'b00000000); endfunction


function [15:0] divide ( input [7:0] a, input [7:0] b);
reg  [7:0]     ans;
reg  [7:0]     rem;
reg  [7:0]     x7;
reg  [7:0]     x6;
reg  [7:0]     x5;
reg  [7:0]     x4;
reg  [7:0]     x3;
reg  [7:0]     x2;
reg  [7:0]     x1;
reg  [7:0]     x0;

reg  [1:0]     y5;
reg  [2:0]     y4; 
reg  [3:0]     y3;
reg  [4:0]     y2;
reg  [5:0]     y1;
reg  [6:0]     y0;
begin

x7 = a;
ans[7] = (|b[7:1])? 1'b0 : x7[7];

x6 = {(~ans[7])&a[7],a[6:0]};
ans[6] = (|b[7:2])? 1'b0 : (x6[7:6]>=b[1:0]);

y5 = ans[6] ? (x6[7:6]-b[1:0]) : x6[7:6];
x5 = { y5, a[5:0] };
ans[5] = (|b[7:3])? 1'b0 : ( x5[7:5]>=b[2:0] );

y4 = ans[5] ? (x5[7:5]-b[2:0]) : x5[7:5];
x4 = { y4, a[4:0]};
ans[4] = (|b[7:4])? 1'b0 : ( x4[7:4]>=b[3:0] );

y3 = ans[4] ? (x4[7:4]-b[3:0]) : x4[7:4];
x3 = {y3, a[3:0]};
ans[3] = (|b[7:5])? 1'b0 : ( x3[7:3]>=b[4:0] );

y2 = ans[3] ? (x3[7:3]-b[4:0]) : x3[7:3];
x2 = {y2,a[2:0]};
ans[2] = (|b[7:6])? 1'b0 : ( x2[7:2]>=b[5:0] );

y1 = ans[2] ? (x2[7:2]-b[5:0]) : x2[7:2];
x1 = {y1,a[1:0]};
ans[1] = (|b[7]) ? 1'b0 : ( x1[7:1]>=b[6:0] );

y0 = ans[1] ? (x1[7:1]-b[6:0]) : x1[7:1];
x0 = {y0,a[0]};
ans[0] = (x0>=b);

rem = ans[0] ? (x0-b) : x0;

divide = {rem,ans};
end

endfunction


/*********************************************************/
//register definition

reg                rd_wait;
reg      [7:0]     cmd1;
reg      [7:0]     cmd2;
reg      [2:0]     cmd_flag;
reg      [15:0]    pc;
reg      [7:0]     acc;
reg                psw_ov;
reg                psw_ac;
reg                psw_c;
reg      [3:0]     psw_other;
reg      [15:0]    dp;
reg      [7:0]     sp;
reg      [7:0]     b;
reg                same_flag;
reg      [7:0]     same_byte;
reg      [7:0]     data1;


/*********************************************************/
//wire definition

wire               work_en;
wire     [7:0]     cmd0;
wire     [7:0]     cmda;
wire     [7:0]     cmdb;
wire     [7:0]     cmdc;
reg                pc_en;
wire     [15:0]    pc_add1;
wire     [15:0]    code_base;
wire     [15:0]    code_rel;
wire     [15:0]    code_addr;
wire               length1;
wire               length2r1;
wire               length2;
wire               length3;
wire               rd_en_data_sfr;
wire               rd_en_data_idata;
wire               rd_en_xdata;
wire               rd_en_data;
wire               rd_en_sfr;
`ifdef TYPE8052
wire               rd_en_idata;
`endif
wire               same_flag_data;
wire               same_flag_sfr;
`ifdef TYPE8052
wire               same_flag_idata;
`endif
wire               same_flag_xdata;
wire               read_internal;
reg      [15:0]    rd_addr;
wire               use_psw_rs;
wire               use_dp;
wire               use_acc;
wire               use_sp;
wire               wait_en;
wire               wr_en_data_sfr;
wire               wr_en_data_idata;
wire               wr_en_xdata;
wire               wr_en_data;
wire               wr_en_sfr;
`ifdef TYPE8052
wire               wr_en_idata;
`endif 
wire               write_internal;
reg      [15:0]    wr_addr;
reg      [7:0]     wr_bit_byte;
reg      [7:0]     wr_byte;
reg      [7:0]     add_a;
reg      [7:0]     add_b;
reg                add_c;
reg                sub_flag;
wire               bit_ac;
wire     [3:0]     low;
wire     [3:0]     high;
wire               bit_c;
wire               bit_high; 
wire               bit_ov; 
wire     [7:0]     add_byte;
wire     [15:0]    mult;
wire     [7:0]     and_out;
wire     [7:0]     or_out; 
wire     [7:0]     xor_out;
wire               wr_acc;
wire               psw_p;
wire     [1:0]     psw_rs;
wire               wr_psw_rs; 
wire     [7:0]     psw;
wire               wr_dp;
wire     [7:0]     sp_sub1;
wire     [7:0]     sp_add1;
wire               wr_sp;
wire     [7:0]     div_ans;
wire     [7:0]     div_rem;
reg      [7:0]     data0;


/*********************************************************/


/*********************************************************/
//work_en

always @ ( posedge clk or posedge rst )
if ( rst )
    rd_wait <= 1'b0;
else if ( cpu_restart )
    rd_wait <= 1'b0;	
`ifdef TYPE8052
else if ( ram_rd_en_data|ram_rd_en_sfr|ram_rd_en_idata|ram_rd_en_xdata )
`else
else if ( ram_rd_en_data|ram_rd_en_sfr|ram_rd_en_xdata ) 
`endif	
    rd_wait <= 1'b1;
else if ( ram_rd_vld )
    rd_wait <= 1'b0;	
else;

reg rom_wait;
always @ ( posedge clk or posedge rst )
if ( rst )
    rom_wait <= 1'b0;
else if ( cpu_restart )
    rom_wait <= 1'b0;	
else if ( rom_en )
	rom_wait <= 1'b1;
else if ( rom_vld )
    rom_wait <= 1'b0;
else;


assign work_en = ( ( rd_wait & ~ram_rd_vld )|( rom_wait & ~rom_vld ) ) ? 1'b0 : cpu_en;

/*********************************************************/

/*********************************************************/
//cmd0/cmd1/cmd2  cmda/cmdb/cmdc

assign cmd0 = rom_byte;

always @ ( posedge clk or posedge rst )
if ( rst )
    cmd1 <= 8'b0;
else if ( work_en )
    cmd1 <= cmd0;
else;

always @ ( posedge clk or posedge rst )
if ( rst )
    cmd2 <= 8'b0;
else if ( work_en )
    cmd2 <= cmdb;
else;

always @ ( posedge clk or posedge rst )
if ( rst )
    cmd_flag <= 3'b1;
else if ( cpu_restart )
    cmd_flag <= 3'b1;
else if ( work_en )
    if ( wait_en )
	    cmd_flag <= {1'b0,cmd_flag[1:0]};
    else if ( length2|length2r1 )
	    cmd_flag <= 3'b101;
	else if ( length3 )
	    cmd_flag <= 3'b100;
	else
        cmd_flag <= { cmd_flag[1:0],1'b1};
else;

assign cmda = cmd_flag[1] ? cmd0 : 8'b0;

assign cmdb = cmd_flag[2] ? cmd1 : 8'b0;

assign cmdc = cmd2;


/*********************************************************/


/*********************************************************/
//rom_en rom_addr

always @*
if ( ~work_en )
    pc_en = 1'b0;
else if ( wait_en|length2r1 )
    pc_en = 1'b0;
else if ( acall(cmdb)|ret(cmda)|ret(cmdb)|reti(cmda)|reti(cmdb) )
    pc_en = 1'b0;
else
    pc_en = 1'b1;

always @ ( posedge clk or posedge rst )
if ( rst )
    pc <= 16'd0;
else if ( cpu_restart )
    pc <= 16'd0;
else if ( work_en )
    if ( pc_en )
        pc <= pc_add1;
	else;
else;

assign pc_add1 = rom_addr + 1'b1;

always @*
if ( ~work_en )
    rom_en = 1'b0;
else if ( wait_en )
    rom_en = 1'b0;
else if ( length2r1 )
    rom_en = movc_a_dp(cmda)|movc_a_pc(cmda);
else if ( acall(cmdb)|ret(cmda)|ret(cmdb)|reti(cmda)|reti(cmdb) )
    rom_en = 1'b0;	
else
    rom_en = 1'b1;

assign code_base = ( movc_a_dp(cmda)|jmp(cmda) ) ? dp : pc;

assign code_rel = ( jc(cmdb)||jnc(cmdb)|jb(cmdc)|jnb(cmdc)|jbc(cmdc)|sjmp(cmdb)|jz(cmdb)|jnz(cmdb)|cjne_a_di_rel(cmdc)|cjne_a_da_rel(cmdc)|cjne_rn_da_rel(cmdc)|cjne_ri_da_rel(cmdc)|djnz_rn_rel(cmdb)|djnz_di_rel(cmdc) ) ? {{8{cmd0[7]}},cmd0} : {{8{acc[7]}},acc};	
	
assign code_addr = code_base + code_rel;	

always @*
if ( acall(cmdc) )
    rom_addr = {pc[15:11],cmd2[7:5],cmd1};
else if ( lcall(cmdc)|ljmp(cmdc) )
    rom_addr = {cmd1,cmd0};	
else if ( ret(cmdc)|reti(cmdc) )
    rom_addr = {data1,data0};
else if ( ajmp(cmdb) )
    rom_addr = {pc[15:11],cmd1[7:5],cmd0};	
else if ( movc_a_dp(cmda)|movc_a_pc(cmda)|(jc(cmdb) & psw_c)|(jnc(cmdb) & ~psw_c)|((jb(cmdc)|jbc(cmdc)) & data0[cmd1[2:0]])|(jnb(cmdc) & ~data0[cmd1[2:0]])|sjmp(cmdb)|jmp(cmda)|(jz(cmdb) & (acc==8'b0))|(jnz(cmdb) & (acc!=8'b0))|(cjne_a_di_rel(cmdc) & (acc!=data0))|(cjne_a_da_rel(cmdc) & (acc!=cmd1))|(cjne_rn_da_rel(cmdc) & (data1!=cmd1))|(cjne_ri_da_rel(cmdc) & (data0!=cmd1))|((djnz_rn_rel(cmdb)||djnz_di_rel(cmdc)) & (data0!=8'h1)) ) 
    rom_addr = code_addr; 
else
    rom_addr = pc;


/*********************************************************/

/*********************************************************/
//command length

assign  length1 = add_a_rn(cmda)|addc_a_rn(cmda)|subb_a_rn(cmda)|inc_a(cmda)|inc_rn(cmda)|inc_dp(cmda)|dec_a(cmda)|dec_rn(cmda)|mul(cmda)|div(cmda)|da(cmda)|anl_a_rn(cmda)|orl_a_rn(cmda)|xrl_a_rn(cmda)|clr_a(cmda)|cpl_a(cmda)|rl(cmda)|rlc(cmda)|rr(cmda)|rrc(cmda)|swap(cmda)|mov_a_rn(cmda)|mov_rn_a(cmda)|mov_ri_a(cmda)|movx_a_dp(cmda)|movx_ri_a(cmda)|movx_dp_a(cmda)|xch_a_rn(cmda)|clr_c(cmda)|setb_c(cmda)|cpl_c(cmda)|jmp(cmda);

assign  length2r1 = add_a_ri(cmda)|addc_a_ri(cmda)|subb_a_ri(cmda)|inc_ri(cmda)|dec_ri(cmda)|anl_a_ri(cmda)|orl_a_ri(cmda)|xrl_a_ri(cmda)|mov_a_ri(cmda)|movc_a_dp(cmda)|movc_a_pc(cmda)|movx_a_ri(cmda)|xch_a_ri(cmda)|xchd(cmda);

assign  length2 = add_a_di(cmda)|add_a_da(cmda)|addc_a_di(cmda)|addc_a_da(cmda)|subb_a_di(cmda)|subb_a_da(cmda)|inc_di(cmda)|dec_di(cmda)|anl_a_di(cmda)|anl_a_da(cmda)|anl_di_a(cmda)|orl_a_di(cmda)|orl_a_da(cmda)|orl_di_a(cmda)|xrl_a_di(cmda)|xrl_a_da(cmda)|xrl_di_a(cmda)|mov_a_di(cmda)|mov_a_da(cmda)|mov_rn_di(cmda)|mov_rn_da(cmda)|mov_di_a(cmda)|mov_di_rn(cmda)|mov_di_ri(cmda)|mov_ri_di(cmda)|mov_ri_da(cmda)|push(cmda)|pop(cmda)|xch_a_di(cmda)|clr_bit(cmda)|setb_bit(cmda)|cpl_bit(cmda)|anl_c_bit(cmda)|anl_c_nbit(cmda)|orl_c_bit(cmda)|orl_c_nbit(cmda)|mov_c_bit(cmda)|mov_bit_c(cmda)|jc(cmda)|jnc(cmda)|ajmp(cmda)|sjmp(cmda)|jz(cmda)|jnz(cmda)|djnz_rn_rel(cmda);

assign  length3 = anl_di_da(cmda)|orl_di_da(cmda)|xrl_di_da(cmda)|mov_di_di(cmda)|mov_di_da(cmda)|mov_dp_da(cmda)|jb(cmda)|jnb(cmda)|jbc(cmda)|acall(cmda)|lcall(cmda)|ret(cmda)|reti(cmda)|ljmp(cmda)|cjne_a_di_rel(cmda)|cjne_a_da_rel(cmda)|cjne_rn_da_rel(cmda)|cjne_ri_da_rel(cmda)|djnz_di_rel(cmda);


/*********************************************************/


/*********************************************************/
//ram_rd_en ram_rd_addr 

assign rd_en_data_sfr = add_a_rn(cmda)|add_a_di(cmdb)|add_a_ri(cmda)|addc_a_rn(cmda)|addc_a_di(cmdb)|addc_a_ri(cmda)|subb_a_rn(cmda)|subb_a_di(cmdb)|subb_a_ri(cmda)|inc_rn(cmda)|inc_di(cmdb)|inc_ri(cmda)|dec_rn(cmda)|dec_di(cmdb)|dec_ri(cmda)|anl_a_rn(cmda)|anl_a_di(cmdb)|anl_a_ri(cmda)|anl_di_a(cmdb)|anl_di_da(cmdb)|orl_a_rn(cmda)|orl_a_di(cmdb)|orl_a_ri(cmda)|orl_di_a(cmdb)|orl_di_da(cmdb)|xrl_a_rn(cmda)|xrl_a_di(cmdb)|xrl_a_ri(cmda)|xrl_di_a(cmdb)|xrl_di_da(cmdb)|mov_a_rn(cmda)|mov_a_di(cmdb)|mov_a_ri(cmda)|mov_rn_di(cmdb)|mov_di_rn(cmda)|mov_di_di(cmdb)|mov_di_ri(cmda)|mov_ri_a(cmda)|mov_ri_di(cmda)|mov_ri_di(cmdb)|mov_ri_da(cmda)|movx_a_ri(cmda)|movx_ri_a(cmda)|push(cmdb)|xch_a_rn(cmda)|xch_a_di(cmdb)|xch_a_ri(cmda)|xchd(cmda)|clr_bit(cmdb)|setb_bit(cmdb)|cpl_bit(cmdb)|anl_c_bit(cmdb)|anl_c_nbit(cmdb)|orl_c_bit(cmdb)|orl_c_nbit(cmdb)|mov_c_bit(cmdb)|mov_bit_c(cmdb)|jb(cmdb)|jnb(cmdb)|jbc(cmdb)|cjne_a_di_rel(cmdb)|cjne_rn_da_rel(cmda)|cjne_ri_da_rel(cmda)|djnz_rn_rel(cmda)|djnz_di_rel(cmdb);

assign rd_en_data_idata = add_a_ri(cmdb)|addc_a_ri(cmdb)|subb_a_ri(cmdb)|inc_ri(cmdb)|dec_ri(cmdb)|anl_a_ri(cmdb)|orl_a_ri(cmdb)|xrl_a_ri(cmdb)|mov_a_ri(cmdb)|mov_di_ri(cmdb)|xch_a_ri(cmdb)|xchd(cmdb)|cjne_ri_da_rel(cmdb)|ret(cmda)|ret(cmdb)|reti(cmda)|reti(cmdb)|pop(cmda);

assign rd_en_xdata = movx_a_ri(cmdb)|movx_a_dp(cmda);

assign rd_en_data = (rd_en_data_sfr|rd_en_data_idata) & ~rd_addr[7];
`ifdef TYPE8052
assign rd_en_sfr = rd_en_data_sfr & rd_addr[7];
assign rd_en_idata = rd_en_data_idata & rd_addr[7];
`else
assign rd_en_sfr = (rd_en_data_sfr|rd_en_data_idata) & rd_addr[7];
`endif
assign same_flag_data = rd_en_data & wr_en_data & (rd_addr[7:0]==wr_addr[7:0]);
assign same_flag_sfr = rd_en_sfr & wr_en_sfr & (rd_addr[7:0]==wr_addr[7:0]);
`ifdef TYPE8052
assign same_flag_idata = rd_en_idata & wr_en_idata & (rd_addr[7:0]==wr_addr[7:0]);
`endif
assign same_flag_xdata = rd_en_xdata & wr_en_xdata & (rd_addr[15:0]==wr_addr[15:0]);
assign read_internal = rd_en_sfr & ( (rd_addr[7:0]==8'he0)|(rd_addr[7:0]==8'hd0)|(rd_addr[7:0]==8'h83)|(rd_addr[7:0]==8'h82)|(rd_addr[7:0]==8'h81)|(rd_addr[7:0]==8'hf0) );
assign ram_rd_en_data = work_en & rd_en_data & ~same_flag_data & ~wait_en;
assign ram_rd_en_sfr = work_en & rd_en_sfr & ~same_flag_sfr & ~read_internal & ~wait_en;
`ifdef TYPE8052
assign ram_rd_en_idata = work_en & rd_en_idata & ~same_flag_idata & ~wait_en;
`endif 
assign ram_rd_en_xdata = work_en & rd_en_xdata & ~same_flag_xdata & ~wait_en;


always @*
if ( add_a_rn(cmda)|addc_a_rn(cmda)|subb_a_rn(cmda)|inc_rn(cmda)|dec_rn(cmda)|anl_a_rn(cmda)|orl_a_rn(cmda)|xrl_a_rn(cmda)|mov_a_rn(cmda)|mov_di_rn(cmda)|xch_a_rn(cmda)|cjne_rn_da_rel(cmda)|djnz_rn_rel(cmda) )
    rd_addr = { psw_rs,cmd0[2:0] };
else if ( add_a_di(cmdb)|addc_a_di(cmdb)|subb_a_di(cmdb)|inc_di(cmdb)|dec_di(cmdb)|anl_a_di(cmdb)|anl_di_a(cmdb)|anl_di_da(cmdb)|orl_a_di(cmdb)|orl_di_a(cmdb)|orl_di_da(cmdb)|xrl_a_di(cmdb)|xrl_di_a(cmdb)|xrl_di_da(cmdb)|mov_a_di(cmdb)|mov_rn_di(cmdb)|mov_di_di(cmdb)|mov_ri_di(cmdb)|push(cmdb)|xch_a_di(cmdb)|cjne_a_di_rel(cmdb)|djnz_di_rel(cmdb) )
    rd_addr = cmd0;
else if ( add_a_ri(cmda)|addc_a_ri(cmda)|subb_a_ri(cmda)|inc_ri(cmda)|dec_ri(cmda)|anl_a_ri(cmda)|orl_a_ri(cmda)|xrl_a_ri(cmda)|mov_a_ri(cmda)|mov_di_ri(cmda)|mov_ri_a(cmda)|mov_ri_di(cmda)|mov_ri_da(cmda)|movx_a_ri(cmda)|movx_ri_a(cmda)|xch_a_ri(cmda)|xchd(cmda)|cjne_ri_da_rel(cmda) )
    rd_addr = { psw_rs,2'b0,cmd0[0] };
else if ( add_a_ri(cmdb)|addc_a_ri(cmdb)|subb_a_ri(cmdb)|inc_ri(cmdb)|dec_ri(cmdb)|anl_a_ri(cmdb)|orl_a_ri(cmdb)|xrl_a_ri(cmdb)|mov_a_ri(cmdb)|mov_di_ri(cmdb)|movx_a_ri(cmdb)|xch_a_ri(cmdb)|xchd(cmdb)|cjne_ri_da_rel(cmdb) )
    rd_addr = data0;
else if ( movx_a_dp(cmda) )
    rd_addr = dp;
else if ( pop(cmda)|ret(cmda)|reti(cmda) )
    rd_addr = sp;
else if ( clr_bit(cmdb)|setb_bit(cmdb)|cpl_bit(cmdb)|anl_c_bit(cmdb)|anl_c_nbit(cmdb)|orl_c_bit(cmdb)|orl_c_nbit(cmdb)|mov_c_bit(cmdb)|mov_bit_c(cmdb)|jb(cmdb)|jnb(cmdb)|jbc(cmdb) )
    rd_addr = cmd0[7] ? {cmd0[7:3],3'b0} : {3'b001,cmd0[7:3]};    
else if ( ret(cmdb)|reti(cmdb) )
    rd_addr = sp_sub1;	
else
    rd_addr = 16'd0;
	
assign ram_rd_addr = rd_addr;	

assign use_psw_rs = add_a_rn(cmda)|add_a_ri(cmda)|addc_a_rn(cmda)|addc_a_ri(cmda)|subb_a_rn(cmda)|subb_a_ri(cmda)|inc_rn(cmda)|inc_ri(cmda)|dec_rn(cmda)|dec_ri(cmda)|anl_a_rn(cmda)|anl_a_ri(cmda)|orl_a_rn(cmda)|orl_a_ri(cmda)|xrl_a_rn(cmda)|xrl_a_ri(cmda)|mov_a_rn(cmda)|mov_a_ri(cmda)|mov_di_rn(cmda)|mov_di_ri(cmda)|mov_ri_a(cmda)|mov_ri_di(cmda)|mov_ri_da(cmda)|movx_a_ri(cmda)|movx_ri_a(cmda)|xch_a_rn(cmda)|xch_a_ri(cmda)|xchd(cmda)|cjne_rn_da_rel(cmda)|cjne_ri_da_rel(cmda)|djnz_rn_rel(cmda);

assign use_dp = movc_a_dp(cmda)|movx_a_dp(cmda)|jmp(cmda);

assign use_acc = movc_a_dp(cmda)|movc_a_pc(cmda)|jmp(cmda);

assign use_sp = pop(cmda)|ret(cmda)|reti(cmda);

assign wait_en = (use_psw_rs&wr_psw_rs)|(use_dp&wr_dp)|(use_acc&wr_acc)|(use_sp&wr_sp);

/*********************************************************/

/*********************************************************/
//ram_wr_en ram_wr_addr  

assign wr_en_data_sfr = inc_rn(cmdb)|inc_di(cmdc)|dec_rn(cmdb)|dec_di(cmdc)|anl_di_a(cmdc)|anl_di_da(cmdc)|orl_di_a(cmdc)|orl_di_da(cmdc)|xrl_di_a(cmdc)|xrl_di_da(cmdc)|mov_rn_a(cmdb)|mov_rn_di(cmdc)|mov_rn_da(cmdb)|mov_di_a(cmdb)|mov_di_rn(cmdb)|mov_di_di(cmdc)|mov_di_ri(cmdc)|mov_di_da(cmdc)|pop(cmdb)|xch_a_rn(cmdb)|xch_a_di(cmdc)|clr_bit(cmdc)|setb_bit(cmdc)|cpl_bit(cmdc)|mov_bit_c(cmdc)|(jbc(cmdc)&data0[cmd1[2:0]])|djnz_rn_rel(cmdb)|djnz_di_rel(cmdc);

assign wr_en_data_idata = inc_ri(cmdc)|dec_ri(cmdc)|mov_ri_a(cmdb)|mov_ri_di(cmdc)|mov_ri_da(cmdb)|xch_a_ri(cmdc)|xchd(cmdc)|acall(cmdb)|acall(cmdc)|lcall(cmdb)|lcall(cmdc)|push(cmdc);

assign wr_en_xdata = movx_ri_a(cmdb)|movx_dp_a(cmdb);

assign wr_en_data = (wr_en_data_sfr|wr_en_data_idata) & ~wr_addr[7];
`ifdef TYPE8052
assign wr_en_sfr = wr_en_data_sfr & wr_addr[7];
assign wr_en_idata = wr_en_data_idata & wr_addr[7];
`else
assign wr_en_sfr = (wr_en_data_sfr|wr_en_data_idata) & wr_addr[7];
`endif
assign write_internal = wr_en_sfr & ( (wr_addr[7:0]==8'he0)|(wr_addr[7:0]==8'hd0)|(wr_addr[7:0]==8'h83)|(wr_addr[7:0]==8'h82)|(wr_addr[7:0]==8'h81)|(wr_addr[7:0]==8'hf0) );
assign ram_wr_en_data = work_en & wr_en_data;
assign ram_wr_en_sfr = work_en & wr_en_sfr & ~write_internal;
`ifdef TYPE8052
assign ram_wr_en_idata = work_en & wr_en_idata;
`endif
assign ram_wr_en_xdata = work_en & wr_en_xdata;

always @*
if ( inc_rn(cmdb)|dec_rn(cmdb)|mov_rn_a(cmdb)|mov_rn_da(cmdb)|xch_a_rn(cmdb)|djnz_rn_rel(cmdb) )
    wr_addr = { psw_rs,cmd1[2:0] };
else if ( inc_di(cmdc)|dec_di(cmdc)|anl_di_a(cmdc)|anl_di_da(cmdc)|orl_di_a(cmdc)|orl_di_da(cmdc)|xrl_di_a(cmdc)|xrl_di_da(cmdc)|mov_di_ri(cmdc)|mov_di_da(cmdc)|xch_a_di(cmdc)|djnz_di_rel(cmdc) )
    wr_addr = cmd1;
else if ( inc_ri(cmdc)|dec_ri(cmdc)|mov_ri_di(cmdc)|xch_a_ri(cmdc)|xchd(cmdc) )
    wr_addr = data1;
else if ( mov_rn_di(cmdc) )
    wr_addr = { psw_rs,cmd2[2:0] };
else if ( mov_di_a(cmdb)|mov_di_rn(cmdb)|mov_di_di(cmdc)|pop(cmdb) )
    wr_addr = cmd0;
else if ( mov_ri_a(cmdb)|mov_ri_da(cmdb)|movx_ri_a(cmdb) )
    wr_addr = data0;
else if ( movx_dp_a(cmdb) )
    wr_addr = dp;
else if ( push(cmdc) )
    wr_addr = sp;
else if ( clr_bit(cmdc)|setb_bit(cmdc)|cpl_bit(cmdc)|mov_bit_c(cmdc)|jbc(cmdc) )
    wr_addr = cmd1[7] ? {cmd1[7:3],3'b0} : {3'b001,cmd1[7:3]};
else if ( acall(cmdb)|acall(cmdc)|lcall(cmdb)|lcall(cmdc) )
    wr_addr = sp_add1;	
else
    wr_addr = 16'd0;

assign ram_wr_addr = wr_addr;	

/*********************************************************/


/*********************************************************/
//ram_wr_byte

always @* begin
wr_bit_byte = data0;
if ( clr_bit(cmdc)|jbc(cmdc) )
    wr_bit_byte[cmd1[2:0]] = 1'b0;
else if ( setb_bit(cmdc) )
    wr_bit_byte[cmd1[2:0]] = 1'b1;
else if ( cpl_bit(cmdc)	)
    wr_bit_byte[cmd1[2:0]] = ~wr_bit_byte[cmd1[2:0]];
else if ( mov_bit_c(cmdc) )	
    wr_bit_byte[cmd1[2:0]] = psw_c;
else;
end

always @*
if ( inc_rn(cmdb)|inc_di(cmdc)|inc_ri(cmdc)|dec_rn(cmdb)|dec_di(cmdc)|dec_ri(cmdc)|djnz_rn_rel(cmdb)|djnz_di_rel(cmdc) )
    wr_byte = add_byte;
else if ( anl_di_a(cmdc)|anl_di_da(cmdc) )
    wr_byte = and_out;
else if ( orl_di_a(cmdc)|orl_di_da(cmdc) )
    wr_byte = or_out;
else if ( xrl_di_a(cmdc)|xrl_di_da(cmdc) )
    wr_byte = xor_out;
else if ( mov_rn_a(cmdb)|mov_di_a(cmdb)|mov_ri_a(cmdb)|movx_ri_a(cmdb)|movx_dp_a(cmdb)|xch_a_rn(cmdb)|xch_a_di(cmdc)|xch_a_ri(cmdc) )
    wr_byte = acc;
else if ( mov_rn_di(cmdc)|mov_di_rn(cmdb)|mov_di_di(cmdc)|mov_di_ri(cmdc)|mov_ri_di(cmdc)|push(cmdc)|pop(cmdb) )
    wr_byte = data0;
else if ( mov_rn_da(cmdb)|mov_di_da(cmdc)|mov_ri_da(cmdb) )
    wr_byte = cmd0;
else if ( xchd(cmdc) )
    wr_byte = {data0[7:4],acc[3:0]};
else if ( clr_bit(cmdc)|setb_bit(cmdc)|cpl_bit(cmdc)|mov_bit_c(cmdc)|jbc(cmdc) )
    wr_byte = wr_bit_byte;
else if ( acall(cmdb) )
    wr_byte = pc[7:0];
else if ( acall(cmdc)|lcall(cmdc) )
    wr_byte = pc[15:8];	
else if ( lcall(cmdb) )
    wr_byte = pc_add1[7:0];
else
    wr_byte = 8'd0;

assign ram_wr_byte = wr_byte;

/*********************************************************/


/*********************************************************/
//acc register

always @*
if ( add_a_rn(cmdb)|add_a_di(cmdc)|add_a_ri(cmdc)|add_a_da(cmdb)|addc_a_rn(cmdb)|addc_a_di(cmdc)|addc_a_ri(cmdc)|addc_a_da(cmdb)|subb_a_rn(cmdb)|subb_a_di(cmdc)|subb_a_ri(cmdc)|subb_a_da(cmdb)|inc_a(cmdb)|dec_a(cmdb) )
    add_a = acc;
else if ( inc_rn(cmdb)|inc_di(cmdc)|inc_ri(cmdc)|dec_rn(cmdb)|dec_di(cmdc)|dec_ri(cmdc)|djnz_rn_rel(cmdb)|djnz_di_rel(cmdc) )
    add_a = data0;
else
    add_a = 8'b0;


always @*
if ( add_a_rn(cmdb)|add_a_di(cmdc)|add_a_ri(cmdc)|addc_a_rn(cmdb)|addc_a_di(cmdc)|addc_a_ri(cmdc)|subb_a_rn(cmdb)|subb_a_di(cmdc)|subb_a_ri(cmdc) )
    add_b = data0;
else if ( add_a_da(cmdb)|addc_a_da(cmdb)|subb_a_da(cmdb) )
    add_b = cmd0;
else if ( inc_a(cmdb)|dec_a(cmdb)|inc_rn(cmdb)|inc_di(cmdc)|inc_ri(cmdc)|dec_rn(cmdb)|dec_di(cmdc)|dec_ri(cmdc)|djnz_rn_rel(cmdb)|djnz_di_rel(cmdc) )
    add_b = 8'b0;
else
    add_b = 8'b0;


always @*
if ( add_a_rn(cmdb)|add_a_di(cmdc)|add_a_ri(cmdc)|add_a_da(cmdb) )
    add_c = 1'b0;
else if ( addc_a_rn(cmdb)|addc_a_di(cmdc)|addc_a_ri(cmdc)|addc_a_da(cmdb)|subb_a_rn(cmdb)|subb_a_di(cmdc)|subb_a_ri(cmdc)|subb_a_da(cmdb) )
    add_c = psw_c;
else if ( inc_a(cmdb)|inc_rn(cmdb)|inc_di(cmdc)|inc_ri(cmdc)|dec_a(cmdb)|dec_rn(cmdb)|dec_di(cmdc)|dec_ri(cmdc)|djnz_rn_rel(cmdb)|djnz_di_rel(cmdc) )
    add_c = 1'b1;	
else
    add_c = 1'b0;	


always @*
if ( add_a_rn(cmdb)|add_a_di(cmdc)|add_a_ri(cmdc)|add_a_da(cmdb)|addc_a_rn(cmdb)|addc_a_di(cmdc)|addc_a_ri(cmdc)|addc_a_da(cmdb)|inc_a(cmdb)|inc_rn(cmdb)|inc_di(cmdc)|inc_ri(cmdc) )
    sub_flag = 1'b0;
else if ( subb_a_rn(cmdb)|subb_a_di(cmdc)|subb_a_ri(cmdc)|subb_a_da(cmdb)|dec_a(cmdb)|dec_rn(cmdb)|dec_di(cmdc)|dec_ri(cmdc)|djnz_rn_rel(cmdb)|djnz_di_rel(cmdc) )
    sub_flag = 1'b1;
else
    sub_flag = 1'b0;


assign {bit_ac,low} = sub_flag ? (add_a[3:0]-add_b[3:0]-add_c) : (add_a[3:0]+add_b[3:0]+add_c);
assign high = sub_flag ? (add_a[6:4]-add_b[6:4]-bit_ac) : (add_a[6:4]+add_b[6:4]+bit_ac);
assign {bit_c,bit_high} = sub_flag ? (add_a[7]-add_b[7]-high[3]) : (add_a[7]+add_b[7]+high[3]);
assign bit_ov = bit_c ^ high[3];
assign add_byte = {bit_high,high[2:0],low};

assign mult = acc * b;
assign {div_rem,div_ans} = divide(acc,b);
assign and_out = ( anl_di_da(cmdc) ? cmd0 : acc ) & ( anl_a_da(cmdb) ? cmd0 : data0 );
assign or_out  = ( orl_di_da(cmdc) ? cmd0 : acc ) | ( orl_a_da(cmdb) ? cmd0 : data0 );
assign xor_out = ( xrl_di_da(cmdc) ? cmd0 : acc ) ^ ( xrl_a_da(cmdb) ? cmd0 : data0 );

wire [3:0] da_low  = ( psw_ac|(acc[3:0]>4'h9) ) ? (acc[3:0]+4'd6) : acc[3:0];
wire [3:0] da_high = ( ( psw_c|(acc[7:4]>4'h9)|((acc[7:4]==4'h9)&(psw_ac|(acc[3:0]>4'h9))) ) ? ( acc[7:4]+4'h6 ) : acc[7:4] ) + ( psw_ac|(acc[3:0]>4'h9) );
	
always @ ( posedge clk or posedge rst )
if ( rst )
    acc <= 8'b0;
else if ( work_en )
    if ( wr_en_sfr & (wr_addr[7:0]==8'he0 ) )
	    acc <= wr_byte;
	else if ( add_a_rn(cmdb)|add_a_di(cmdc)|add_a_ri(cmdc)|add_a_da(cmdb)|addc_a_rn(cmdb)|addc_a_di(cmdc)|addc_a_ri(cmdc)|addc_a_da(cmdb)|subb_a_rn(cmdb)|subb_a_di(cmdc)|subb_a_ri(cmdc)|subb_a_da(cmdb)|inc_a(cmdb)|dec_a(cmdb) )
	    acc <= add_byte;
	else if ( mul(cmdb) )
	    acc <= mult[7:0];
	else if ( div(cmdb) )
	    acc <= div_ans;
	else if ( da(cmdb) )
	    acc <= {da_high,da_low};	
    else if ( anl_a_rn(cmdb)|anl_a_di(cmdc)|anl_a_ri(cmdc)|anl_a_da(cmdb) )
        acc <= and_out;	
	else if ( orl_a_rn(cmdb)|orl_a_di(cmdc)|orl_a_ri(cmdc)|orl_a_da(cmdb) )
	    acc <= or_out;
	else if ( xrl_a_rn(cmdb)|xrl_a_di(cmdc)|xrl_a_ri(cmdc)|xrl_a_da(cmdb) )
	    acc <= xor_out;
	else if ( clr_a(cmdb) )
	    acc <= 8'b0;
	else if ( cpl_a(cmdb) )
	    acc <= ~acc;
	else if ( rl(cmdb) )
	    acc <= {acc[6:0],acc[7]};
	else if ( rlc(cmdb) )
	    acc <= {acc[6:0],psw_c};	
	else if ( rr(cmdb) )
	    acc <= {acc[0],acc[7:1]};	
	else if ( rrc(cmdb) )
	    acc <= {psw_c,acc[7:1]};	
	else if ( swap(cmdb) )
	    acc <= {acc[3:0],acc[7:4]};	
    else if ( mov_a_rn(cmdb)|mov_a_di(cmdc)|mov_a_ri(cmdc)|movx_a_ri(cmdc)|movx_a_dp(cmdb)|xch_a_rn(cmdb)|xch_a_di(cmdc)|xch_a_ri(cmdc) )
        acc <= data0;	
	else if ( mov_a_da(cmdb)|movc_a_dp(cmdb)|movc_a_pc(cmdb) )
	    acc <= cmd0;
	else if ( xchd(cmdc) )
	    acc[3:0] <= data0[3:0];
	else;
else;

assign wr_acc = (wr_en_sfr & (wr_addr[7:0]==8'he0))|add_a_rn(cmdb)|add_a_di(cmdc)|add_a_ri(cmdc)|add_a_da(cmdb)|addc_a_rn(cmdb)|addc_a_di(cmdc)|addc_a_ri(cmdc)|addc_a_da(cmdb)|subb_a_rn(cmdb)|subb_a_di(cmdc)|subb_a_ri(cmdc)|subb_a_da(cmdb)|inc_a(cmdb)|dec_a(cmdb)|mul(cmdb)|div(cmdb)|da(cmdb)|anl_a_rn(cmdb)|anl_a_di(cmdc)|anl_a_ri(cmdc)|anl_a_da(cmdb)|orl_a_rn(cmdb)|orl_a_di(cmdc)|orl_a_ri(cmdc)|orl_a_da(cmdb)|xrl_a_rn(cmdb)|xrl_a_di(cmdc)|xrl_a_ri(cmdc)|xrl_a_da(cmdb)|clr_a(cmdb)|cpl_a(cmdb)|rl(cmdb)|rlc(cmdb)|rr(cmdb)|rrc(cmdb)|swap(cmdb)|mov_a_rn(cmdb)|mov_a_di(cmdc)|mov_a_ri(cmdc)|mov_a_da(cmdb)|movx_a_ri(cmdc)|movx_a_dp(cmdb)|xch_a_rn(cmdb)|xch_a_di(cmdc)|xch_a_ri(cmdc)|xchd(cmdc);

/*********************************************************/


/*********************************************************/
//psw register

assign psw_p = ^acc;

always @ ( posedge clk or posedge rst )
if ( rst )
    psw_ov <= 1'b0;
else if ( work_en )
    if ( wr_en_sfr & (wr_addr[7:0]==8'hd0 ) )
	    psw_ov <= wr_byte[2];
	else if ( add_a_rn(cmdb)|add_a_di(cmdc)|add_a_ri(cmdc)|add_a_da(cmdb)|addc_a_rn(cmdb)|addc_a_di(cmdc)|addc_a_ri(cmdc)|addc_a_da(cmdb)|subb_a_rn(cmdb)|subb_a_di(cmdc)|subb_a_ri(cmdc)|subb_a_da(cmdb) )
	    psw_ov <= bit_ov;
	else if ( mul(cmdb) )
	    psw_ov <= (mult[15:8]!=8'b0);
	else if ( div(cmdb) )
	    psw_ov <= (b==8'b0);
	else;
else;

always @ ( posedge clk or posedge rst )
if ( rst )
    psw_ac <= 1'b0;
else if ( work_en )
    if ( wr_en_sfr & (wr_addr[7:0]==8'hd0 ) )
	    psw_ac <= wr_byte[6];
	else if ( add_a_rn(cmdb)|add_a_di(cmdc)|add_a_ri(cmdc)|add_a_da(cmdb)|addc_a_rn(cmdb)|addc_a_di(cmdc)|addc_a_ri(cmdc)|addc_a_da(cmdb)|subb_a_rn(cmdb)|subb_a_di(cmdc)|subb_a_ri(cmdc)|subb_a_da(cmdb) )
	    psw_ac <= bit_ac;
	else;
else;

always @ ( posedge clk or posedge rst )
if ( rst )
    psw_c <= 1'b0;
else if ( work_en )
    if ( wr_en_sfr & (wr_addr[7:0]==8'hd0 ) )
	    psw_c <= wr_byte[7];
	else if ( add_a_rn(cmdb)|add_a_di(cmdc)|add_a_ri(cmdc)|add_a_da(cmdb)|addc_a_rn(cmdb)|addc_a_di(cmdc)|addc_a_ri(cmdc)|addc_a_da(cmdb)|subb_a_rn(cmdb)|subb_a_di(cmdc)|subb_a_ri(cmdc)|subb_a_da(cmdb) )
	    psw_c <= bit_c;
	else if ( mul(cmdb)|div(cmdb) )
	    psw_c <= 1'b0;
	else if ( da(cmdb) )
	    psw_c <= ( psw_c|(acc[7:4]>4'h9)|((acc[7:4]==4'h9)&(psw_ac|(acc[3:0]>4'h9))) ) ? 1'b1 : psw_c;
	else if ( rlc(cmdb) )
	    psw_c <= acc[7];	
	else if ( rrc(cmdb) )
	    psw_c <= acc[0];	
    else if ( clr_c(cmdb) )
        psw_c <= 1'b0;	
	else if ( setb_c(cmdb) )
        psw_c <= 1'b1;	
	else if ( cpl_c(cmdb) )
        psw_c <= ~psw_c;	
	else if ( anl_c_bit(cmdc) )
        psw_c <= psw_c & data0[cmd1[2:0]];	
	else if ( anl_c_nbit(cmdc) )
        psw_c <= psw_c & ~data0[cmd1[2:0]];
	else if ( orl_c_bit(cmdc) )
        psw_c <= psw_c | data0[cmd1[2:0]];	
	else if ( orl_c_nbit(cmdc) )
        psw_c <= psw_c | ~data0[cmd1[2:0]];	
	else if ( mov_c_bit(cmdc) )
        psw_c <=data0[cmd1[2:0]];
	else if ( cjne_a_di_rel(cmdc) )
        psw_c <= acc<data0;
    else if ( cjne_a_da_rel(cmdc) )
        psw_c <= acc<cmd1;
	else if ( cjne_rn_da_rel(cmdc) )
        psw_c <= data1<cmd1;	
	else if ( cjne_ri_da_rel(cmdc) )
	    psw_c <= data0<cmd1;
	else;
else;

always @ ( posedge clk or posedge rst )
if ( rst )
    psw_other <= 4'b0;
else if ( work_en )
    if ( wr_en_sfr & (wr_addr[7:0]==8'hd0 ) )
	    psw_other <= {wr_byte[5:3],wr_byte[1]};
	else;
else;

assign psw_rs = psw_other[2:1];

assign wr_psw_rs = wr_en_sfr & (wr_addr[7:0]==8'hd0);

assign psw = {psw_c,psw_ac,psw_other[3:1],psw_ov,psw_other[0],psw_p};

/*********************************************************/

/*********************************************************/
//dp  sp registers

always @ ( posedge clk or posedge rst )
if ( rst )
    dp <= 16'b0;
else if ( work_en )
    if  ( wr_en_sfr & (wr_addr[7:0]==8'h82 ) )
	    dp[7:0] <= wr_byte;
	else if  ( wr_en_sfr & (wr_addr[7:0]==8'h83 ) )
	    dp[15:8] <= wr_byte;
	else if ( inc_dp(cmdb) )
	    dp <= dp + 1'b1;
	else if ( mov_dp_da(cmdc) )
	    dp <= {cmd1,cmd0};
	else;
else;

assign wr_dp = (wr_en_sfr & ((wr_addr[7:0]==8'h82)|(wr_addr[7:0]==8'h83)))|inc_dp(cmdb);

always @ ( posedge clk or posedge rst )
if ( rst )
    sp <= 8'b0;
else if ( work_en )
    if ( wr_en_sfr & (wr_addr[7:0]==8'h81) )
	    sp <= wr_byte;
	else if ( push(cmdb)|acall(cmdb)|acall(cmdc)|lcall(cmdb)|lcall(cmdc) )
	    sp <= sp_add1;
    else if ( pop(cmdb)|ret(cmdb)|ret(cmdc)|reti(cmdb)|reti(cmdc) )
        sp <= sp_sub1;	
	else;
else;

assign sp_sub1 = sp - 1'b1;

assign sp_add1 = sp + 1'b1;

assign wr_sp = (wr_en_sfr & (wr_addr[7:0]==8'h81));

always @ ( posedge clk or posedge rst )
if ( rst )
    b <= 8'b0;
else if ( work_en )
    if ( wr_en_sfr & (wr_addr[7:0]==8'hf0) )
	    b <= wr_byte;
	else if ( mul(cmdb) )
	    b <= mult[15:8];
	else if ( div(cmdb) )
	    b <= div_rem;
	else;
else;

/*********************************************************/


/*********************************************************/
//ram output

always @*
if ( same_flag )
    data0 = same_byte;
else if ( same_byte[7] )
    data0 = acc;
else if ( same_byte[6] )
    data0 = psw;
else if ( same_byte[5] )
    data0 = dp[15:8];
else if ( same_byte[4] )
    data0 = dp[7:0];
else if ( same_byte[3] )
    data0 = sp;
else if ( same_byte[2] )
    data0 = b;
else
    data0 = ram_rd_byte;

always @ ( posedge clk or posedge rst )
if ( rst )
    data1 <= 8'b0;
else if ( work_en )
    data1 <= data0;
else;
    
always @ ( posedge clk or posedge rst )
if ( rst )
    same_flag <= 1'b0;
else if ( work_en )
`ifdef TYPE8052
    if ( same_flag_data|same_flag_sfr|same_flag_idata|same_flag_xdata )
`else 
    if ( same_flag_data|same_flag_sfr|same_flag_xdata )
`endif	
	    same_flag <= 1'b1;
	else
	    same_flag <= 1'b0;
else;

always @ ( posedge clk or posedge rst )
if ( rst )
    same_byte <= 8'd0;
else if ( work_en )
`ifdef TYPE8052
    if ( same_flag_data|same_flag_sfr|same_flag_idata|same_flag_xdata )
`else
    if ( same_flag_data|same_flag_sfr|same_flag_xdata )
`endif	
	    same_byte <= wr_byte;
	else if ( rd_en_sfr & (rd_addr[7:0]==8'he0) ) //acc
	    same_byte <= 1'b1<<7;
	else if ( rd_en_sfr & (rd_addr[7:0]==8'hd0) ) //psw
	    same_byte <= 1'b1<<6;
	else if ( rd_en_sfr & (rd_addr[7:0]==8'h83) ) //dph
	    same_byte <= 1'b1<<5;	
	else if ( rd_en_sfr & (rd_addr[7:0]==8'h82) ) //dpl
	    same_byte <= 1'b1<<4;	
	else if ( rd_en_sfr & (rd_addr[7:0]==8'h81) ) //sp
	    same_byte <= 1'b1<<3;
	else if ( rd_en_sfr & (rd_addr[7:0]==8'hf0) ) //b
	    same_byte <= 1'b1<<2;		
	else
	    same_byte <= 8'b0;
else;
	
/*********************************************************/

endmodule


