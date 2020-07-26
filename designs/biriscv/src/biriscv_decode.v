//-----------------------------------------------------------------
//                         biRISC-V CPU
//                            V0.8.0
//                     Ultra-Embedded.com
//                     Copyright 2019-2020
//
//                   admin@ultra-embedded.com
//
//                     License: Apache 2.0
//-----------------------------------------------------------------
// Copyright 2020 Ultra-Embedded.com
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//-----------------------------------------------------------------

module biriscv_decode
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
     parameter SUPPORT_MULDIV   = 1
    ,parameter EXTRA_DECODE_STAGE = 0
)
//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input           fetch_in_valid_i
    ,input  [ 63:0]  fetch_in_instr_i
    ,input  [  1:0]  fetch_in_pred_branch_i
    ,input           fetch_in_fault_fetch_i
    ,input           fetch_in_fault_page_i
    ,input  [ 31:0]  fetch_in_pc_i
    ,input           fetch_out0_accept_i
    ,input           fetch_out1_accept_i
    ,input           branch_request_i
    ,input  [ 31:0]  branch_pc_i
    ,input  [  1:0]  branch_priv_i

    // Outputs
    ,output          fetch_in_accept_o
    ,output          fetch_out0_valid_o
    ,output [ 31:0]  fetch_out0_instr_o
    ,output [ 31:0]  fetch_out0_pc_o
    ,output          fetch_out0_fault_fetch_o
    ,output          fetch_out0_fault_page_o
    ,output          fetch_out0_instr_exec_o
    ,output          fetch_out0_instr_lsu_o
    ,output          fetch_out0_instr_branch_o
    ,output          fetch_out0_instr_mul_o
    ,output          fetch_out0_instr_div_o
    ,output          fetch_out0_instr_csr_o
    ,output          fetch_out0_instr_rd_valid_o
    ,output          fetch_out0_instr_invalid_o
    ,output          fetch_out1_valid_o
    ,output [ 31:0]  fetch_out1_instr_o
    ,output [ 31:0]  fetch_out1_pc_o
    ,output          fetch_out1_fault_fetch_o
    ,output          fetch_out1_fault_page_o
    ,output          fetch_out1_instr_exec_o
    ,output          fetch_out1_instr_lsu_o
    ,output          fetch_out1_instr_branch_o
    ,output          fetch_out1_instr_mul_o
    ,output          fetch_out1_instr_div_o
    ,output          fetch_out1_instr_csr_o
    ,output          fetch_out1_instr_rd_valid_o
    ,output          fetch_out1_instr_invalid_o
);



wire        enable_muldiv_w     = SUPPORT_MULDIV;

//-----------------------------------------------------------------
// 2 cycle frontend latency
//-----------------------------------------------------------------
generate
if (EXTRA_DECODE_STAGE)
begin
    wire        fetch_in_fault_page_w;
    wire        fetch_in_fault_fetch_w;
    wire [1:0]  fetch_in_pred_branch_w;
    wire [63:0] fetch_in_instr_raw_w;
    wire [63:0] fetch_in_instr_w;
    wire [31:0] fetch_in_pc_w;
    wire        fetch_in_valid_w;

    reg [100:0] fetch_buffer_q;

    always @ (posedge clk_i or posedge rst_i)
    if (rst_i)
        fetch_buffer_q <= 101'b0;
    else if (branch_request_i)
        fetch_buffer_q <= 101'b0;
    else if (!fetch_in_valid_w || fetch_in_accept_o)
        fetch_buffer_q <= {fetch_in_fault_page_i, fetch_in_fault_fetch_i, fetch_in_pred_branch_i, fetch_in_instr_i, fetch_in_pc_i, fetch_in_valid_i};

    assign {fetch_in_fault_page_w, 
            fetch_in_fault_fetch_w, 
            fetch_in_pred_branch_w, 
            fetch_in_instr_raw_w, 
            fetch_in_pc_w, 
            fetch_in_valid_w} = fetch_buffer_q;

    assign fetch_in_instr_w = (fetch_in_fault_page_w | fetch_in_fault_fetch_w) ? 64'b0 : fetch_in_instr_raw_w;

    wire [7:0] info0_in_w;
    wire [9:0] info0_out_w;
    wire [7:0] info1_in_w;
    wire [9:0] info1_out_w;


    biriscv_decoder
    u_dec0
    (
         .valid_i(fetch_in_valid_w)
        ,.fetch_fault_i(fetch_in_fault_fetch_w | fetch_in_fault_page_w)
        ,.enable_muldiv_i(enable_muldiv_w)
        ,.opcode_i(fetch_in_instr_w[31:0])

        ,.invalid_o(info0_in_w[7])
        ,.exec_o(info0_in_w[6])
        ,.lsu_o(info0_in_w[5])
        ,.branch_o(info0_in_w[4])
        ,.mul_o(info0_in_w[3])
        ,.div_o(info0_in_w[2])
        ,.csr_o(info0_in_w[1])
        ,.rd_valid_o(info0_in_w[0])
    );

    biriscv_decoder
    u_dec1
    (
         .valid_i(fetch_in_valid_w)
        ,.fetch_fault_i(fetch_in_fault_fetch_w | fetch_in_fault_page_w)
        ,.enable_muldiv_i(enable_muldiv_w)
        ,.opcode_i(fetch_in_instr_w[63:32])

        ,.invalid_o(info1_in_w[7])
        ,.exec_o(info1_in_w[6])
        ,.lsu_o(info1_in_w[5])
        ,.branch_o(info1_in_w[4])
        ,.mul_o(info1_in_w[3])
        ,.div_o(info1_in_w[2])
        ,.csr_o(info1_in_w[1])
        ,.rd_valid_o(info1_in_w[0])
    );

    fetch_fifo
    #( .OPC_INFO_W(10) )
    u_fifo
    (
         .clk_i(clk_i)
        ,.rst_i(rst_i)

        ,.flush_i(branch_request_i)

        // Input side
        ,.push_i(fetch_in_valid_w)
        ,.pc_in_i(fetch_in_pc_w)
        ,.pred_in_i(fetch_in_pred_branch_w)
        ,.data_in_i(fetch_in_instr_w)
        ,.info0_in_i({info0_in_w, fetch_in_fault_page_w, fetch_in_fault_fetch_w})
        ,.info1_in_i({info1_in_w, fetch_in_fault_page_w, fetch_in_fault_fetch_w})
        ,.accept_o(fetch_in_accept_o)

        // Outputs
        ,.valid0_o(fetch_out0_valid_o)
        ,.pc0_out_o(fetch_out0_pc_o)
        ,.data0_out_o(fetch_out0_instr_o)
        ,.info0_out_o({fetch_out0_instr_invalid_o, fetch_out0_instr_exec_o,
                       fetch_out0_instr_lsu_o,     fetch_out0_instr_branch_o,
                       fetch_out0_instr_mul_o,     fetch_out0_instr_div_o,
                       fetch_out0_instr_csr_o,     fetch_out0_instr_rd_valid_o,
                       fetch_out0_fault_page_o,    fetch_out0_fault_fetch_o})
        ,.pop0_i(fetch_out0_accept_i)

        ,.valid1_o(fetch_out1_valid_o)
        ,.pc1_out_o(fetch_out1_pc_o)
        ,.data1_out_o(fetch_out1_instr_o)
        ,.info1_out_o({fetch_out1_instr_invalid_o, fetch_out1_instr_exec_o,
                       fetch_out1_instr_lsu_o,     fetch_out1_instr_branch_o,
                       fetch_out1_instr_mul_o,     fetch_out1_instr_div_o,
                       fetch_out1_instr_csr_o,     fetch_out1_instr_rd_valid_o,
                       fetch_out1_fault_page_o,    fetch_out1_fault_fetch_o})
        ,.pop1_i(fetch_out1_accept_i)
    );
end
//-----------------------------------------------------------------
// 1 cycle frontend latency
//-----------------------------------------------------------------
else
begin
    fetch_fifo
    #( .OPC_INFO_W(2) )
    u_fifo
    (
         .clk_i(clk_i)
        ,.rst_i(rst_i)

        ,.flush_i(branch_request_i)

        // Input side
        ,.push_i(fetch_in_valid_i)
        ,.pc_in_i(fetch_in_pc_i)
        ,.pred_in_i(fetch_in_pred_branch_i)
        ,.data_in_i((fetch_in_fault_page_i | fetch_in_fault_fetch_i) ? 64'b0 : fetch_in_instr_i)
        ,.info0_in_i({fetch_in_fault_page_i, fetch_in_fault_fetch_i})
        ,.info1_in_i({fetch_in_fault_page_i, fetch_in_fault_fetch_i})
        ,.accept_o(fetch_in_accept_o)

        // Outputs
        ,.valid0_o(fetch_out0_valid_o)
        ,.pc0_out_o(fetch_out0_pc_o)
        ,.data0_out_o(fetch_out0_instr_o)
        ,.info0_out_o({fetch_out0_fault_page_o, fetch_out0_fault_fetch_o})
        ,.pop0_i(fetch_out0_accept_i)

        ,.valid1_o(fetch_out1_valid_o)
        ,.pc1_out_o(fetch_out1_pc_o)
        ,.data1_out_o(fetch_out1_instr_o)
        ,.info1_out_o({fetch_out1_fault_page_o, fetch_out1_fault_fetch_o})
        ,.pop1_i(fetch_out1_accept_i)
    );

    biriscv_decoder
    u_dec0
    (
         .valid_i(fetch_out0_valid_o)
        ,.fetch_fault_i(fetch_out0_fault_fetch_o | fetch_out0_fault_page_o)
        ,.enable_muldiv_i(enable_muldiv_w)
        ,.opcode_i(fetch_out0_instr_o)

        ,.invalid_o(fetch_out0_instr_invalid_o)
        ,.exec_o(fetch_out0_instr_exec_o)
        ,.lsu_o(fetch_out0_instr_lsu_o)
        ,.branch_o(fetch_out0_instr_branch_o)
        ,.mul_o(fetch_out0_instr_mul_o)
        ,.div_o(fetch_out0_instr_div_o)
        ,.csr_o(fetch_out0_instr_csr_o)
        ,.rd_valid_o(fetch_out0_instr_rd_valid_o)
    );

    biriscv_decoder
    u_dec1
    (
         .valid_i(fetch_out1_valid_o)
        ,.fetch_fault_i(fetch_out1_fault_fetch_o | fetch_out1_fault_page_o)
        ,.enable_muldiv_i(enable_muldiv_w)
        ,.opcode_i(fetch_out1_instr_o)

        ,.invalid_o(fetch_out1_instr_invalid_o)
        ,.exec_o(fetch_out1_instr_exec_o)
        ,.lsu_o(fetch_out1_instr_lsu_o)
        ,.branch_o(fetch_out1_instr_branch_o)
        ,.mul_o(fetch_out1_instr_mul_o)
        ,.div_o(fetch_out1_instr_div_o)
        ,.csr_o(fetch_out1_instr_csr_o)
        ,.rd_valid_o(fetch_out1_instr_rd_valid_o)
    );
end
endgenerate

endmodule

module fetch_fifo
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
    parameter WIDTH   = 64,
    parameter DEPTH   = 2,
    parameter ADDR_W  = 1,
    parameter OPC_INFO_W = 10
)
//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
     input                  clk_i
    ,input                  rst_i

    ,input                  flush_i

    // Input side
    ,input                  push_i
    ,input  [31:0]          pc_in_i
    ,input  [1:0]           pred_in_i
    ,input  [WIDTH-1:0]     data_in_i
    ,input [OPC_INFO_W-1:0] info0_in_i
    ,input [OPC_INFO_W-1:0] info1_in_i
    ,output                 accept_o

    // Outputs
    ,output                 valid0_o
    ,output  [31:0]         pc0_out_o
    ,output [(WIDTH/2)-1:0] data0_out_o
    ,output[OPC_INFO_W-1:0] info0_out_o
    ,input                  pop0_i

    ,output                 valid1_o
    ,output  [31:0]         pc1_out_o
    ,output [(WIDTH/2)-1:0] data1_out_o
    ,output[OPC_INFO_W-1:0] info1_out_o
    ,input                  pop1_i
);

//-----------------------------------------------------------------
// Local Params
//-----------------------------------------------------------------
localparam COUNT_W = ADDR_W + 1;

//-----------------------------------------------------------------
// Registers
//-----------------------------------------------------------------
reg [31:0]           pc_q[DEPTH-1:0];
reg                  valid0_q[DEPTH-1:0];
reg                  valid1_q[DEPTH-1:0];
reg [OPC_INFO_W-1:0] info0_q[DEPTH-1:0];
reg [OPC_INFO_W-1:0] info1_q[DEPTH-1:0];
reg [WIDTH-1:0]      ram_q[DEPTH-1:0];
reg [ADDR_W-1:0]     rd_ptr_q;
reg [ADDR_W-1:0]     wr_ptr_q;
reg [COUNT_W-1:0]    count_q;

//-----------------------------------------------------------------
// Sequential
//-----------------------------------------------------------------
wire push_w         = (push_i & accept_o);
wire pop1_w         = (pop0_i & valid0_o);
wire pop2_w         = (pop1_i & valid1_o);
wire pop_complete_w = ((pop1_w && ~valid1_o) || (pop2_w && ~valid0_o) || (pop1_w && pop2_w));

integer i;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
begin
    count_q   <= {(COUNT_W) {1'b0}};
    rd_ptr_q  <= {(ADDR_W) {1'b0}};
    wr_ptr_q  <= {(ADDR_W) {1'b0}};

    for (i = 0; i < DEPTH; i = i + 1) 
    begin
        ram_q[i]         <= {(WIDTH) {1'b0}};
        pc_q[i]          <= 32'b0;
        info0_q[i]       <= {(OPC_INFO_W) {1'b0}};
        info1_q[i]       <= {(OPC_INFO_W) {1'b0}};
        valid0_q[i]      <= 1'b0;
        valid1_q[i]      <= 1'b0;
    end
end
else if (flush_i)
begin
    count_q   <= {(COUNT_W) {1'b0}};
    rd_ptr_q  <= {(ADDR_W) {1'b0}};
    wr_ptr_q  <= {(ADDR_W) {1'b0}};

    for (i = 0; i < DEPTH; i = i + 1) 
    begin
        info0_q[i]       <= {(OPC_INFO_W) {1'b0}};
        info1_q[i]       <= {(OPC_INFO_W) {1'b0}};
        //valid0_q[i]      <= 1'b0; // TODO:...
        //valid1_q[i]      <= 1'b0; // TODO:...
    end
end
else
begin
    // Push
    if (push_w)
    begin
        ram_q[wr_ptr_q]     <= data_in_i;
        pc_q[wr_ptr_q]      <= pc_in_i;
        info0_q[wr_ptr_q]   <= info0_in_i;
        info1_q[wr_ptr_q]   <= info1_in_i;
        valid0_q[wr_ptr_q]  <= 1'b1;
        valid1_q[wr_ptr_q]  <= ~pred_in_i[0];
        wr_ptr_q            <= wr_ptr_q + 1;
    end

    if (pop1_w)
        valid0_q[rd_ptr_q] <= 1'b0;
    if (pop2_w)
        valid1_q[rd_ptr_q] <= 1'b0;

    // Both instructions completed
    if (pop_complete_w)
        rd_ptr_q  <= rd_ptr_q + 1;

    if (push_w & ~pop_complete_w)
        count_q <= count_q + 1;
    else if (~push_w & pop_complete_w)
        count_q <= count_q - 1;
end

//-------------------------------------------------------------------
// Combinatorial
//-------------------------------------------------------------------
/* verilator lint_off WIDTH */
assign valid0_o      = (count_q != 0) & valid0_q[rd_ptr_q];
assign valid1_o      = (count_q != 0) & valid1_q[rd_ptr_q];
assign accept_o      = (count_q != DEPTH);
/* verilator lint_on WIDTH */

assign pc0_out_o     = {pc_q[rd_ptr_q][31:3],3'b000};
assign pc1_out_o     = {pc_q[rd_ptr_q][31:3],3'b100};
assign data0_out_o   = ram_q[rd_ptr_q][(WIDTH/2)-1:0];
assign data1_out_o   = ram_q[rd_ptr_q][WIDTH-1:(WIDTH/2)];

assign info0_out_o   = info0_q[rd_ptr_q];
assign info1_out_o   = info1_q[rd_ptr_q];



endmodule
