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

module biriscv_mmu
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
     parameter MEM_CACHE_ADDR_MIN = 0
    ,parameter MEM_CACHE_ADDR_MAX = 32'hffffffff
    ,parameter SUPPORT_MMU      = 1
)
//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input  [  1:0]  priv_d_i
    ,input           sum_i
    ,input           mxr_i
    ,input           flush_i
    ,input  [ 31:0]  satp_i
    ,input           fetch_in_rd_i
    ,input           fetch_in_flush_i
    ,input           fetch_in_invalidate_i
    ,input  [ 31:0]  fetch_in_pc_i
    ,input  [  1:0]  fetch_in_priv_i
    ,input           fetch_out_accept_i
    ,input           fetch_out_valid_i
    ,input           fetch_out_error_i
    ,input  [ 63:0]  fetch_out_inst_i
    ,input  [ 31:0]  lsu_in_addr_i
    ,input  [ 31:0]  lsu_in_data_wr_i
    ,input           lsu_in_rd_i
    ,input  [  3:0]  lsu_in_wr_i
    ,input           lsu_in_cacheable_i
    ,input  [ 10:0]  lsu_in_req_tag_i
    ,input           lsu_in_invalidate_i
    ,input           lsu_in_writeback_i
    ,input           lsu_in_flush_i
    ,input  [ 31:0]  lsu_out_data_rd_i
    ,input           lsu_out_accept_i
    ,input           lsu_out_ack_i
    ,input           lsu_out_error_i
    ,input  [ 10:0]  lsu_out_resp_tag_i

    // Outputs
    ,output          fetch_in_accept_o
    ,output          fetch_in_valid_o
    ,output          fetch_in_error_o
    ,output [ 63:0]  fetch_in_inst_o
    ,output          fetch_out_rd_o
    ,output          fetch_out_flush_o
    ,output          fetch_out_invalidate_o
    ,output [ 31:0]  fetch_out_pc_o
    ,output          fetch_in_fault_o
    ,output [ 31:0]  lsu_in_data_rd_o
    ,output          lsu_in_accept_o
    ,output          lsu_in_ack_o
    ,output          lsu_in_error_o
    ,output [ 10:0]  lsu_in_resp_tag_o
    ,output [ 31:0]  lsu_out_addr_o
    ,output [ 31:0]  lsu_out_data_wr_o
    ,output          lsu_out_rd_o
    ,output [  3:0]  lsu_out_wr_o
    ,output          lsu_out_cacheable_o
    ,output [ 10:0]  lsu_out_req_tag_o
    ,output          lsu_out_invalidate_o
    ,output          lsu_out_writeback_o
    ,output          lsu_out_flush_o
    ,output          lsu_in_load_fault_o
    ,output          lsu_in_store_fault_o
);



//-----------------------------------------------------------------
// Includes
//-----------------------------------------------------------------
`include "biriscv_defs.v"

//-----------------------------------------------------------------
// Local defs
//-----------------------------------------------------------------
localparam  STATE_W            = 2;
localparam  STATE_IDLE         = 0;
localparam  STATE_LEVEL_FIRST  = 1;
localparam  STATE_LEVEL_SECOND = 2;
localparam  STATE_UPDATE       = 3;

//-----------------------------------------------------------------
// Basic MMU support
//-----------------------------------------------------------------
generate
if (SUPPORT_MMU)
begin

    //-----------------------------------------------------------------
    // Registers
    //-----------------------------------------------------------------
    reg [STATE_W-1:0] state_q;
    wire              idle_w = (state_q == STATE_IDLE);

    // Magic combo used only by MMU
    wire        resp_mmu_w   = (lsu_out_resp_tag_i[9:7] == 3'b111);
    wire        resp_valid_w = resp_mmu_w & lsu_out_ack_i;
    wire        resp_error_w = resp_mmu_w & lsu_out_error_i;
    wire [31:0] resp_data_w  = lsu_out_data_rd_i;

    wire        cpu_accept_w;

    //-----------------------------------------------------------------
    // Load / Store
    //-----------------------------------------------------------------
    reg       load_q;
    reg [3:0] store_q;

    always @ (posedge clk_i or posedge rst_i)
    if (rst_i)
        load_q <= 1'b0;
    else if (lsu_in_rd_i)
        load_q <= ~lsu_in_accept_o;

    always @ (posedge clk_i or posedge rst_i)
    if (rst_i)
        store_q <= 4'b0;
    else if (|lsu_in_wr_i)
        store_q <= lsu_in_accept_o ? 4'b0 : lsu_in_wr_i;

    wire       load_w  = lsu_in_rd_i | load_q;
    wire [3:0] store_w = lsu_in_wr_i | store_q;

    reg [31:0] lsu_in_addr_q;

    always @ (posedge clk_i or posedge rst_i)
    if (rst_i)
        lsu_in_addr_q <= 32'b0;
    else if (load_w || (|store_w))
        lsu_in_addr_q <= lsu_in_addr_i;

    wire [31:0] lsu_addr_w = (load_w || (|store_w)) ? lsu_in_addr_i : lsu_in_addr_q;

    //-----------------------------------------------------------------
    // Page table walker
    //-----------------------------------------------------------------
    wire        itlb_hit_w;
    wire        dtlb_hit_w;

    reg         dtlb_req_q;

    // Global enable
    wire        vm_enable_w = satp_i[`SATP_MODE_R];
    wire [31:0] ptbr_w      = {satp_i[`SATP_PPN_R], 12'b0};

    wire        ifetch_vm_w = (fetch_in_priv_i != `PRIV_MACHINE);
    wire        dfetch_vm_w = (priv_d_i != `PRIV_MACHINE);

    wire        supervisor_i_w = (fetch_in_priv_i == `PRIV_SUPER);
    wire        supervisor_d_w = (priv_d_i == `PRIV_SUPER);

    wire        vm_i_enable_w = (ifetch_vm_w);
    wire        vm_d_enable_w = (vm_enable_w & dfetch_vm_w);

    // TLB entry does not match request address
    wire        itlb_miss_w = fetch_in_rd_i & vm_i_enable_w & ~itlb_hit_w;
    wire        dtlb_miss_w = (load_w || (|store_w)) & vm_d_enable_w & ~dtlb_hit_w;

    // Data miss is higher priority than instruction...
    wire [31:0] request_addr_w = idle_w ? 
                                (dtlb_miss_w ? lsu_addr_w : fetch_in_pc_i) :
                                 dtlb_req_q ? lsu_addr_w : fetch_in_pc_i;

    reg [31:0]  pte_addr_q;
    reg [31:0]  pte_entry_q;
    reg [31:0]  virt_addr_q;

    wire [31:0] pte_ppn_w   = {`PAGE_PFN_SHIFT'b0, resp_data_w[31:`PAGE_PFN_SHIFT]};
    wire [9:0]  pte_flags_w = resp_data_w[9:0];

    always @ (posedge clk_i or posedge rst_i)
    if (rst_i)
    begin
        pte_addr_q  <= 32'b0;
        pte_entry_q <= 32'b0;
        virt_addr_q <= 32'b0;
        dtlb_req_q  <= 1'b0;
        state_q     <= STATE_IDLE;
    end
    else
    begin
        // TLB miss, walk page table
        if (state_q == STATE_IDLE && (itlb_miss_w || dtlb_miss_w))
        begin
            pte_addr_q  <= ptbr_w + {20'b0, request_addr_w[31:22], 2'b0};
            virt_addr_q <= request_addr_w;
            dtlb_req_q  <= dtlb_miss_w;

            state_q     <= STATE_LEVEL_FIRST;
        end
        // First level (4MB superpage)
        else if (state_q == STATE_LEVEL_FIRST && resp_valid_w)
        begin
            // Error or page not present
            if (resp_error_w || !resp_data_w[`PAGE_PRESENT])
            begin
                pte_entry_q <= 32'b0;
                state_q     <= STATE_UPDATE;
            end
            // Valid entry, but another level to fetch
            else if (!(resp_data_w[`PAGE_READ] || resp_data_w[`PAGE_WRITE] || resp_data_w[`PAGE_EXEC]))
            begin
                pte_addr_q  <= {resp_data_w[29:10], 12'b0} + {20'b0, request_addr_w[21:12], 2'b0};
                state_q     <= STATE_LEVEL_SECOND;
            end
            // Valid entry, actual valid PTE
            else
            begin
                pte_entry_q <= ((pte_ppn_w | {22'b0, request_addr_w[21:12]}) << `MMU_PGSHIFT) | {22'b0, pte_flags_w};
                state_q     <= STATE_UPDATE;
            end
        end
        // Second level (4KB page)
        else if (state_q == STATE_LEVEL_SECOND && resp_valid_w)
        begin
            // Valid entry, final level
            if (resp_data_w[`PAGE_PRESENT])
            begin
                pte_entry_q <= (pte_ppn_w << `MMU_PGSHIFT) | {22'b0, pte_flags_w};
                state_q     <= STATE_UPDATE;
            end
            // Page fault
            else
            begin
                pte_entry_q <= 32'b0;
                state_q     <= STATE_UPDATE;
            end
        end
        else if (state_q == STATE_UPDATE)
        begin
            state_q    <= STATE_IDLE;
        end
    end

    //-----------------------------------------------------------------
    // IMMU TLB
    //-----------------------------------------------------------------
    reg         itlb_valid_q;
    reg [31:12] itlb_va_addr_q;
    reg [31:0]  itlb_entry_q;

    always @ (posedge clk_i or posedge rst_i)
    if (rst_i)
        itlb_valid_q <= 1'b0;
    else if (flush_i)
        itlb_valid_q <= 1'b0;
    else if (state_q == STATE_UPDATE && !dtlb_req_q)
        itlb_valid_q <= (itlb_va_addr_q == fetch_in_pc_i[31:12]); // Fetch TLB still matches incoming request
    else if (state_q != STATE_IDLE && !dtlb_req_q)
        itlb_valid_q <= 1'b0;

    always @ (posedge clk_i or posedge rst_i)
    if (rst_i)
    begin
        itlb_va_addr_q <= 20'b0;
        itlb_entry_q   <= 32'b0;
    end
    else if (state_q == STATE_UPDATE && !dtlb_req_q)
    begin
        itlb_va_addr_q <= virt_addr_q[31:12];
        itlb_entry_q   <= pte_entry_q;
    end

    // TLB address matched (even on page fault)
    assign itlb_hit_w   = fetch_in_rd_i & itlb_valid_q & (itlb_va_addr_q == fetch_in_pc_i[31:12]);

    reg pc_fault_r;
    always @ *
    begin
        pc_fault_r = 1'b0;

        if (vm_i_enable_w && itlb_hit_w)
        begin
            // Supervisor mode
            if (supervisor_i_w)
            begin
                // User page, supervisor cannot execute
                if (itlb_entry_q[`PAGE_USER])
                    pc_fault_r = 1'b1;
                // Check exec permissions
                else
                    pc_fault_r = ~itlb_entry_q[`PAGE_EXEC];
            end
            // User mode
            else
                pc_fault_r = (~itlb_entry_q[`PAGE_EXEC]) | (~itlb_entry_q[`PAGE_USER]);
        end
    end

    reg pc_fault_q;

    always @ (posedge clk_i or posedge rst_i)
    if (rst_i)
        pc_fault_q <= 1'b0;
    else
        pc_fault_q <= pc_fault_r;

    assign fetch_out_rd_o         = (~vm_i_enable_w & fetch_in_rd_i) || (itlb_hit_w & ~pc_fault_r);
    assign fetch_out_pc_o         = vm_i_enable_w ? {itlb_entry_q[31:12], fetch_in_pc_i[11:0]} : fetch_in_pc_i;
    assign fetch_out_flush_o      = fetch_in_flush_i;
    assign fetch_out_invalidate_o = fetch_in_invalidate_i; // TODO: ...

    assign fetch_in_accept_o      = (~vm_i_enable_w & fetch_out_accept_i) | (vm_i_enable_w & itlb_hit_w & fetch_out_accept_i) | pc_fault_r;
    assign fetch_in_valid_o       = fetch_out_valid_i | pc_fault_q;
    assign fetch_in_error_o       = fetch_out_valid_i & fetch_out_error_i;
    assign fetch_in_fault_o       = pc_fault_q;
    assign fetch_in_inst_o        = fetch_out_inst_i;

    //-----------------------------------------------------------------
    // DMMU TLB
    //-----------------------------------------------------------------
    reg         dtlb_valid_q;
    reg [31:12] dtlb_va_addr_q;
    reg [31:0]  dtlb_entry_q;

    always @ (posedge clk_i or posedge rst_i)
    if (rst_i)
        dtlb_valid_q <= 1'b0;
    else if (flush_i)
        dtlb_valid_q <= 1'b0;
    else if (state_q == STATE_UPDATE && dtlb_req_q)
        dtlb_valid_q <= 1'b1;

    always @ (posedge clk_i or posedge rst_i)
    if (rst_i)
    begin
        dtlb_va_addr_q <= 20'b0;
        dtlb_entry_q   <= 32'b0;
    end
    else if (state_q == STATE_UPDATE && dtlb_req_q)
    begin
        dtlb_va_addr_q <= virt_addr_q[31:12];
        dtlb_entry_q   <= pte_entry_q;
    end

    // TLB address matched (even on page fault)
    assign dtlb_hit_w   = dtlb_valid_q & (dtlb_va_addr_q == lsu_addr_w[31:12]);

    reg load_fault_r;
    always @ *
    begin
        load_fault_r = 1'b0;

        if (vm_d_enable_w && load_w && dtlb_hit_w)
        begin
            // Supervisor mode
            if (supervisor_d_w)
            begin
                // User page, supervisor user mode not enabled
                if (dtlb_entry_q[`PAGE_USER] && !sum_i)
                    load_fault_r = 1'b1;
                // Check exec permissions
                else
                    load_fault_r = ~(dtlb_entry_q[`PAGE_READ] | (mxr_i & dtlb_entry_q[`PAGE_EXEC]));
            end
            // User mode
            else
                load_fault_r = (~dtlb_entry_q[`PAGE_READ]) | (~dtlb_entry_q[`PAGE_USER]);
        end
    end

    reg store_fault_r;
    always @ *
    begin
        store_fault_r = 1'b0;

        if (vm_d_enable_w && (|store_w) && dtlb_hit_w)
        begin
            // Supervisor mode
            if (supervisor_d_w)
            begin
                // User page, supervisor user mode not enabled
                if (dtlb_entry_q[`PAGE_USER] && !sum_i)
                    store_fault_r = 1'b1;
                // Check exec permissions
                else
                    store_fault_r = (~dtlb_entry_q[`PAGE_READ]) | (~dtlb_entry_q[`PAGE_WRITE]);
            end
            // User mode
            else
                store_fault_r = (~dtlb_entry_q[`PAGE_READ]) | (~dtlb_entry_q[`PAGE_WRITE]) | (~dtlb_entry_q[`PAGE_USER]);
        end
    end

    reg store_fault_q;
    reg load_fault_q;

    always @ (posedge clk_i or posedge rst_i)
    if (rst_i)
        store_fault_q <= 1'b0;
    else
        store_fault_q <= store_fault_r;

    always @ (posedge clk_i or posedge rst_i)
    if (rst_i)
        load_fault_q <= 1'b0;
    else
        load_fault_q <= load_fault_r;   

    wire        lsu_out_rd_w         = vm_d_enable_w ? (load_w  & dtlb_hit_w & ~load_fault_r)       : lsu_in_rd_i;
    wire [3:0]  lsu_out_wr_w         = vm_d_enable_w ? (store_w & {4{dtlb_hit_w & ~store_fault_r}}) : lsu_in_wr_i;
    wire [31:0] lsu_out_addr_w       = vm_d_enable_w ? {dtlb_entry_q[31:12], lsu_addr_w[11:0]}      : lsu_addr_w;
    wire [31:0] lsu_out_data_wr_w    = lsu_in_data_wr_i;

    wire        lsu_out_invalidate_w = lsu_in_invalidate_i;
    wire        lsu_out_writeback_w  = lsu_in_writeback_i;

    reg         lsu_out_cacheable_r;
    always @ *
    begin
/* verilator lint_off UNSIGNED */
/* verilator lint_off CMPCONST */
        if (lsu_in_invalidate_i || lsu_in_writeback_i || lsu_in_flush_i)
            lsu_out_cacheable_r = 1'b1;
        else
            lsu_out_cacheable_r = (lsu_out_addr_w >= MEM_CACHE_ADDR_MIN && lsu_out_addr_w <= MEM_CACHE_ADDR_MAX);
/* verilator lint_on CMPCONST */
/* verilator lint_on UNSIGNED */
    end

    wire [10:0] lsu_out_req_tag_w    = lsu_in_req_tag_i;
    wire        lsu_out_flush_w      = lsu_in_flush_i;

    assign lsu_in_ack_o         = (lsu_out_ack_i & ~resp_mmu_w) | store_fault_q | load_fault_q;
    assign lsu_in_resp_tag_o    = lsu_out_resp_tag_i;
    assign lsu_in_error_o       = (lsu_out_error_i & ~resp_mmu_w) | store_fault_q | load_fault_q;
    assign lsu_in_data_rd_o     = lsu_out_data_rd_i;
    assign lsu_in_store_fault_o = store_fault_q;
    assign lsu_in_load_fault_o  = load_fault_q;

    assign lsu_in_accept_o      = (~vm_d_enable_w & cpu_accept_w) | (vm_d_enable_w & dtlb_hit_w & cpu_accept_w) | store_fault_r | load_fault_r;

    //-----------------------------------------------------------------
    // PTE Fetch Port
    //-----------------------------------------------------------------
    reg mem_req_q;
    wire mmu_accept_w;

    always @ (posedge clk_i or posedge rst_i)
    if (rst_i)
        mem_req_q <= 1'b0;
    else if (state_q == STATE_IDLE && (itlb_miss_w || dtlb_miss_w))
        mem_req_q <= 1'b1;
    else if (state_q == STATE_LEVEL_FIRST && resp_valid_w && !resp_error_w && resp_data_w[`PAGE_PRESENT] && (!(resp_data_w[`PAGE_READ] || resp_data_w[`PAGE_WRITE] || resp_data_w[`PAGE_EXEC])))
        mem_req_q <= 1'b1;    
    else if (mmu_accept_w)
        mem_req_q <= 1'b0;

    //-----------------------------------------------------------------
    // Request Muxing
    //-----------------------------------------------------------------
    reg  read_hold_q;
    reg  src_mmu_q;
    wire src_mmu_w = read_hold_q ? src_mmu_q : mem_req_q;

    always @ (posedge clk_i or posedge rst_i)
    if (rst_i)
    begin
        read_hold_q  <= 1'b0;
        src_mmu_q    <= 1'b0;
    end
    else if ((lsu_out_rd_o || (|lsu_out_wr_o)) && !lsu_out_accept_i)
    begin
        read_hold_q  <= 1'b1;
        src_mmu_q    <= src_mmu_w;
    end
    else if (lsu_out_accept_i)
        read_hold_q  <= 1'b0;

    assign mmu_accept_w         = src_mmu_w  & lsu_out_accept_i;
    assign cpu_accept_w         = ~src_mmu_w & lsu_out_accept_i;

    assign lsu_out_rd_o         = src_mmu_w ? mem_req_q  : lsu_out_rd_w;
    assign lsu_out_wr_o         = src_mmu_w ? 4'b0       : lsu_out_wr_w;
    assign lsu_out_addr_o       = src_mmu_w ? pte_addr_q : lsu_out_addr_w;
    assign lsu_out_data_wr_o    = lsu_out_data_wr_w;

    assign lsu_out_invalidate_o = src_mmu_w ? 1'b0 : lsu_out_invalidate_w;
    assign lsu_out_writeback_o  = src_mmu_w ? 1'b0 : lsu_out_writeback_w;
    assign lsu_out_cacheable_o  = src_mmu_w ? 1'b1 : lsu_out_cacheable_r;
    assign lsu_out_req_tag_o    = src_mmu_w ? {1'b0, 3'b111, 7'b0} : lsu_out_req_tag_w;
    assign lsu_out_flush_o      = src_mmu_w ? 1'b0 : lsu_out_flush_w;

end
//-----------------------------------------------------------------
// No MMU support
//-----------------------------------------------------------------
else
begin
    assign fetch_out_rd_o         = fetch_in_rd_i;
    assign fetch_out_pc_o         = fetch_in_pc_i;
    assign fetch_out_flush_o      = fetch_in_flush_i;
    assign fetch_out_invalidate_o = fetch_in_invalidate_i;
    assign fetch_in_accept_o      = fetch_out_accept_i;
    assign fetch_in_valid_o       = fetch_out_valid_i;
    assign fetch_in_error_o       = fetch_out_error_i;
    assign fetch_in_fault_o       = 1'b0;
    assign fetch_in_inst_o        = fetch_out_inst_i;

    assign lsu_out_rd_o           = lsu_in_rd_i;
    assign lsu_out_wr_o           = lsu_in_wr_i;
    assign lsu_out_addr_o         = lsu_in_addr_i;
    assign lsu_out_data_wr_o      = lsu_in_data_wr_i;
    assign lsu_out_invalidate_o   = lsu_in_invalidate_i;
    assign lsu_out_writeback_o    = lsu_in_writeback_i;
    assign lsu_out_cacheable_o    = lsu_in_cacheable_i;
    assign lsu_out_req_tag_o      = lsu_in_req_tag_i;
    assign lsu_out_flush_o        = lsu_in_flush_i;
    
    assign lsu_in_ack_o           = lsu_out_ack_i;
    assign lsu_in_resp_tag_o      = lsu_out_resp_tag_i;
    assign lsu_in_error_o         = lsu_out_error_i;
    assign lsu_in_data_rd_o       = lsu_out_data_rd_i;
    assign lsu_in_store_fault_o   = 1'b0;
    assign lsu_in_load_fault_o    = 1'b0;

    assign lsu_in_accept_o        = lsu_out_accept_i;
end
endgenerate

endmodule
