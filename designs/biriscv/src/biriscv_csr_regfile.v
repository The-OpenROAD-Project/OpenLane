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
module biriscv_csr_regfile
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
     parameter SUPPORT_MTIMECMP    = 1,
     parameter SUPPORT_SUPER       = 0
)
//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
     input           clk_i
    ,input           rst_i

    ,input           ext_intr_i
    ,input           timer_intr_i

    ,input [31:0]    cpu_id_i
    ,input [31:0]    misa_i

    ,input [5:0]     exception_i
    ,input [31:0]    exception_pc_i
    ,input [31:0]    exception_addr_i

    // CSR read port
    ,input           csr_ren_i
    ,input  [11:0]   csr_raddr_i
    ,output [31:0]   csr_rdata_o

    // CSR write port
    ,input  [11:0]   csr_waddr_i
    ,input  [31:0]   csr_wdata_i

    ,output          csr_branch_o
    ,output [31:0]   csr_target_o

    // CSR registers
    ,output [1:0]    priv_o
    ,output [31:0]   status_o
    ,output [31:0]   satp_o

    // Masked interrupt output
    ,output [31:0]   interrupt_o
);

//-----------------------------------------------------------------
// Includes
//-----------------------------------------------------------------
`include "biriscv_defs.v"

//-----------------------------------------------------------------
// Registers / Wires
//-----------------------------------------------------------------
// CSR - Machine
reg [31:0]  csr_mepc_q;
reg [31:0]  csr_mcause_q;
reg [31:0]  csr_sr_q;
reg [31:0]  csr_mtvec_q;
reg [31:0]  csr_mip_q;
reg [31:0]  csr_mie_q;
reg [1:0]   csr_mpriv_q;
reg [31:0]  csr_mcycle_q;
reg [31:0]  csr_mscratch_q;
reg [31:0]  csr_mtval_q;
reg [31:0]  csr_mtimecmp_q;
reg         csr_mtime_ie_q;
reg [31:0]  csr_medeleg_q;
reg [31:0]  csr_mideleg_q;

// CSR - Supervisor
reg [31:0]  csr_sepc_q;
reg [31:0]  csr_stvec_q;
reg [31:0]  csr_scause_q;
reg [31:0]  csr_stval_q;
reg [31:0]  csr_satp_q;
reg [31:0]  csr_sscratch_q;

//-----------------------------------------------------------------
// Masked Interrupts
//-----------------------------------------------------------------
reg [31:0] irq_pending_r;
reg [31:0] irq_masked_r;
reg [1:0]  irq_priv_r;

reg        m_enabled_r;
reg [31:0] m_interrupts_r;
reg        s_enabled_r;
reg [31:0] s_interrupts_r;

always @ *
begin
    if (SUPPORT_SUPER)
    begin
        irq_pending_r   = (csr_mip_q & csr_mie_q);
        m_enabled_r     = (csr_mpriv_q < `PRIV_MACHINE) || (csr_mpriv_q == `PRIV_MACHINE && csr_sr_q[`SR_MIE_R]);
        s_enabled_r     = (csr_mpriv_q < `PRIV_SUPER)   || (csr_mpriv_q == `PRIV_SUPER   && csr_sr_q[`SR_SIE_R]);
        m_interrupts_r  = m_enabled_r    ? (irq_pending_r & ~csr_mideleg_q) : 32'b0;
        s_interrupts_r  = s_enabled_r    ? (irq_pending_r &  csr_mideleg_q) : 32'b0;
        irq_masked_r    = (|m_interrupts_r) ? m_interrupts_r : s_interrupts_r;
        irq_priv_r      = (|m_interrupts_r) ? `PRIV_MACHINE : `PRIV_SUPER;
    end
    else
    begin
        irq_pending_r   = (csr_mip_q & csr_mie_q);
        irq_masked_r    = csr_sr_q[`SR_MIE_R] ? irq_pending_r : 32'b0;
        irq_priv_r      = `PRIV_MACHINE;
    end
end

reg [1:0] irq_priv_q;
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    irq_priv_q <= `PRIV_MACHINE;
else if (|irq_masked_r)
    irq_priv_q <= irq_priv_r;

assign interrupt_o = irq_masked_r;


reg csr_mip_upd_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    csr_mip_upd_q <= 1'b0;
else if ((csr_ren_i && csr_raddr_i == `CSR_MIP) || (csr_ren_i && csr_raddr_i == `CSR_SIP))
    csr_mip_upd_q <= 1'b1;
else if (csr_waddr_i == `CSR_MIP || csr_waddr_i == `CSR_SIP || (|exception_i))
    csr_mip_upd_q <= 1'b0;

wire buffer_mip_w = (csr_ren_i && csr_raddr_i == `CSR_MIP) | (csr_ren_i && csr_raddr_i == `CSR_SIP) | csr_mip_upd_q;

//-----------------------------------------------------------------
// CSR Read Port
//-----------------------------------------------------------------
reg [31:0] rdata_r;
always @ *
begin
    rdata_r = 32'b0;

    case (csr_raddr_i)
    // CSR - Machine
    `CSR_MSCRATCH: rdata_r = csr_mscratch_q & `CSR_MSCRATCH_MASK;
    `CSR_MEPC:     rdata_r = csr_mepc_q & `CSR_MEPC_MASK;
    `CSR_MTVEC:    rdata_r = csr_mtvec_q & `CSR_MTVEC_MASK;
    `CSR_MCAUSE:   rdata_r = csr_mcause_q & `CSR_MCAUSE_MASK;
    `CSR_MTVAL:    rdata_r = csr_mtval_q & `CSR_MTVAL_MASK;
    `CSR_MSTATUS:  rdata_r = csr_sr_q & `CSR_MSTATUS_MASK;
    `CSR_MIP:      rdata_r = csr_mip_q & `CSR_MIP_MASK;
    `CSR_MIE:      rdata_r = csr_mie_q & `CSR_MIE_MASK;
    `CSR_MCYCLE,
    `CSR_MTIME:    rdata_r = csr_mcycle_q;
    `CSR_MHARTID:  rdata_r = cpu_id_i;
    `CSR_MISA:     rdata_r = misa_i;
    `CSR_MEDELEG:  rdata_r = SUPPORT_SUPER ? (csr_medeleg_q & `CSR_MEDELEG_MASK) : 32'b0;
    `CSR_MIDELEG:  rdata_r = SUPPORT_SUPER ? (csr_mideleg_q & `CSR_MIDELEG_MASK) : 32'b0;
    // Non-std behaviour
    `CSR_MTIMECMP: rdata_r = SUPPORT_MTIMECMP ? csr_mtimecmp_q : 32'b0;
    // CSR - Super
    `CSR_SSTATUS:  rdata_r = SUPPORT_SUPER ? (csr_sr_q       & `CSR_SSTATUS_MASK)  : 32'b0;
    `CSR_SIP:      rdata_r = SUPPORT_SUPER ? (csr_mip_q      & `CSR_SIP_MASK)      : 32'b0;
    `CSR_SIE:      rdata_r = SUPPORT_SUPER ? (csr_mie_q      & `CSR_SIE_MASK)      : 32'b0;
    `CSR_SEPC:     rdata_r = SUPPORT_SUPER ? (csr_sepc_q     & `CSR_SEPC_MASK)     : 32'b0;
    `CSR_STVEC:    rdata_r = SUPPORT_SUPER ? (csr_stvec_q    & `CSR_STVEC_MASK)    : 32'b0;
    `CSR_SCAUSE:   rdata_r = SUPPORT_SUPER ? (csr_scause_q   & `CSR_SCAUSE_MASK)   : 32'b0;
    `CSR_STVAL:    rdata_r = SUPPORT_SUPER ? (csr_stval_q    & `CSR_STVAL_MASK)    : 32'b0;
    `CSR_SATP:     rdata_r = SUPPORT_SUPER ? (csr_satp_q     & `CSR_SATP_MASK)     : 32'b0;
    `CSR_SSCRATCH: rdata_r = SUPPORT_SUPER ? (csr_sscratch_q & `CSR_SSCRATCH_MASK) : 32'b0;
    default:       rdata_r = 32'b0;
    endcase
end

assign csr_rdata_o = rdata_r;
assign priv_o      = csr_mpriv_q;
assign status_o    = csr_sr_q;
assign satp_o      = csr_satp_q;

//-----------------------------------------------------------------
// CSR register next state
//-----------------------------------------------------------------
// CSR - Machine
reg [31:0]  csr_mepc_r;
reg [31:0]  csr_mcause_r;
reg [31:0]  csr_mtval_r;
reg [31:0]  csr_sr_r;
reg [31:0]  csr_mtvec_r;
reg [31:0]  csr_mip_r;
reg [31:0]  csr_mie_r;
reg [1:0]   csr_mpriv_r;
reg [31:0]  csr_mcycle_r;
reg [31:0]  csr_mscratch_r;
reg [31:0]  csr_mtimecmp_r;
reg         csr_mtime_ie_r;
reg [31:0]  csr_medeleg_r;
reg [31:0]  csr_mideleg_r;

reg [31:0]  csr_mip_next_q;
reg [31:0]  csr_mip_next_r;

// CSR - Supervisor
reg [31:0]  csr_sepc_r;
reg [31:0]  csr_stvec_r;
reg [31:0]  csr_scause_r;
reg [31:0]  csr_stval_r;
reg [31:0]  csr_satp_r;
reg [31:0]  csr_sscratch_r;

wire is_exception_w = ((exception_i & `EXCEPTION_TYPE_MASK) == `EXCEPTION_EXCEPTION);
wire exception_s_w  = SUPPORT_SUPER ? ((csr_mpriv_q <= `PRIV_SUPER) & is_exception_w & csr_medeleg_q[{1'b0, exception_i[`EXCEPTION_SUBTYPE_R]}]) : 1'b0;

always @ *
begin
    // CSR - Machine
    csr_mip_next_r  = csr_mip_next_q;
    csr_mepc_r      = csr_mepc_q;
    csr_sr_r        = csr_sr_q;
    csr_mcause_r    = csr_mcause_q;
    csr_mtval_r     = csr_mtval_q;
    csr_mtvec_r     = csr_mtvec_q;
    csr_mip_r       = csr_mip_q;
    csr_mie_r       = csr_mie_q;
    csr_mpriv_r     = csr_mpriv_q;
    csr_mscratch_r  = csr_mscratch_q;
    csr_mcycle_r    = csr_mcycle_q + 32'd1;
    csr_mtimecmp_r  = csr_mtimecmp_q;
    csr_mtime_ie_r  = csr_mtime_ie_q;
    csr_medeleg_r   = csr_medeleg_q;
    csr_mideleg_r   = csr_mideleg_q;

    // CSR - Super
    csr_sepc_r      = csr_sepc_q;
    csr_stvec_r     = csr_stvec_q;
    csr_scause_r    = csr_scause_q;
    csr_stval_r     = csr_stval_q;
    csr_satp_r      = csr_satp_q;
    csr_sscratch_r  = csr_sscratch_q;

    // Interrupts
    if ((exception_i & `EXCEPTION_TYPE_MASK) == `EXCEPTION_INTERRUPT)
    begin
        // Machine mode interrupts
        if (irq_priv_q == `PRIV_MACHINE)
        begin
            // Save interrupt / supervisor state
            csr_sr_r[`SR_MPIE_R] = csr_sr_r[`SR_MIE_R];
            csr_sr_r[`SR_MPP_R]  = csr_mpriv_q;

            // Disable interrupts and enter supervisor mode
            csr_sr_r[`SR_MIE_R]  = 1'b0;

            // Raise priviledge to machine level
            csr_mpriv_r          = `PRIV_MACHINE;

            // Record interrupt source PC
            csr_mepc_r           = exception_pc_i;
            csr_mtval_r          = 32'b0;

            // Piority encoded interrupt cause
            if (interrupt_o[`IRQ_M_SOFT])
                csr_mcause_r = `MCAUSE_INTERRUPT + 32'd`IRQ_M_SOFT;
            else if (interrupt_o[`IRQ_M_TIMER])
                csr_mcause_r = `MCAUSE_INTERRUPT + 32'd`IRQ_M_TIMER;
            else if (interrupt_o[`IRQ_M_EXT])
                csr_mcause_r = `MCAUSE_INTERRUPT + 32'd`IRQ_M_EXT;
        end
        // Supervisor mode interrupts
        else
        begin
            // Save interrupt / supervisor state
            csr_sr_r[`SR_SPIE_R] = csr_sr_r[`SR_SIE_R];
            csr_sr_r[`SR_SPP_R]  = (csr_mpriv_q == `PRIV_SUPER);

            // Disable interrupts and enter supervisor mode
            csr_sr_r[`SR_SIE_R]  = 1'b0;

            // Raise priviledge to machine level
            csr_mpriv_r  = `PRIV_SUPER;

            // Record fault source PC
            csr_sepc_r   = exception_pc_i;
            csr_stval_r  = 32'b0;

            // Piority encoded interrupt cause
            if (interrupt_o[`IRQ_S_SOFT])
                csr_scause_r = `MCAUSE_INTERRUPT + 32'd`IRQ_S_SOFT;
            else if (interrupt_o[`IRQ_S_TIMER])
                csr_scause_r = `MCAUSE_INTERRUPT + 32'd`IRQ_S_TIMER;
            else if (interrupt_o[`IRQ_S_EXT])
                csr_scause_r = `MCAUSE_INTERRUPT + 32'd`IRQ_S_EXT;
        end
    end
    // Exception return
    else if (exception_i == `EXCEPTION_ERET)
    begin
        // TODO: Not quite correct - should check which ERET insn
        // MRET (return from machine)
        if (csr_mpriv_q == `PRIV_MACHINE)
        begin
            // Set privilege level to previous MPP
            csr_mpriv_r          = csr_sr_r[`SR_MPP_R];

            // Interrupt enable pop
            csr_sr_r[`SR_MIE_R]  = csr_sr_r[`SR_MPIE_R];
            csr_sr_r[`SR_MPIE_R] = 1'b1;

            // TODO: Set next MPP to user mode??
            csr_sr_r[`SR_MPP_R] = `SR_MPP_U;
        end
        // SRET (return from supervisor)
        else
        begin
            // Set privilege level to previous privilege level
            csr_mpriv_r          = csr_sr_r[`SR_SPP_R] ? `PRIV_SUPER : `PRIV_USER;

            // Interrupt enable pop
            csr_sr_r[`SR_SIE_R]  = csr_sr_r[`SR_SPIE_R];
            csr_sr_r[`SR_SPIE_R] = 1'b1;

            // Set next SPP to user mode
            csr_sr_r[`SR_SPP_R] = 1'b0;
        end
    end
    // Exception - handled in super mode
    else if (is_exception_w && exception_s_w)
    begin
        // Save interrupt / supervisor state
        csr_sr_r[`SR_SPIE_R] = csr_sr_r[`SR_SIE_R];
        csr_sr_r[`SR_SPP_R]  = (csr_mpriv_q == `PRIV_SUPER);

        // Disable interrupts and enter supervisor mode
        csr_sr_r[`SR_SIE_R]  = 1'b0;

        // Raise priviledge to machine level
        csr_mpriv_r  = `PRIV_SUPER;

        // Record fault source PC
        csr_sepc_r   = exception_pc_i;

        // Bad address / PC
        case (exception_i)
        `EXCEPTION_MISALIGNED_FETCH,
        `EXCEPTION_FAULT_FETCH,
        `EXCEPTION_PAGE_FAULT_INST:     csr_stval_r = exception_pc_i;
        `EXCEPTION_ILLEGAL_INSTRUCTION,
        `EXCEPTION_MISALIGNED_LOAD,
        `EXCEPTION_FAULT_LOAD,
        `EXCEPTION_MISALIGNED_STORE,
        `EXCEPTION_FAULT_STORE,
        `EXCEPTION_PAGE_FAULT_LOAD,
        `EXCEPTION_PAGE_FAULT_STORE:    csr_stval_r = exception_addr_i;
        default:                        csr_stval_r = 32'b0;
        endcase

        // Fault cause
        csr_scause_r = {28'b0, exception_i[3:0]};
    end
    // Exception - handled in machine mode
    else if (is_exception_w)
    begin
        // Save interrupt / supervisor state
        csr_sr_r[`SR_MPIE_R] = csr_sr_r[`SR_MIE_R];
        csr_sr_r[`SR_MPP_R]  = csr_mpriv_q;

        // Disable interrupts and enter supervisor mode
        csr_sr_r[`SR_MIE_R]  = 1'b0;

        // Raise priviledge to machine level
        csr_mpriv_r  = `PRIV_MACHINE;

        // Record fault source PC
        csr_mepc_r   = exception_pc_i;

        // Bad address / PC
        case (exception_i)
        `EXCEPTION_MISALIGNED_FETCH,
        `EXCEPTION_FAULT_FETCH,
        `EXCEPTION_PAGE_FAULT_INST:     csr_mtval_r = exception_pc_i;
        `EXCEPTION_ILLEGAL_INSTRUCTION,
        `EXCEPTION_MISALIGNED_LOAD,
        `EXCEPTION_FAULT_LOAD,
        `EXCEPTION_MISALIGNED_STORE,
        `EXCEPTION_FAULT_STORE,
        `EXCEPTION_PAGE_FAULT_LOAD,
        `EXCEPTION_PAGE_FAULT_STORE:    csr_mtval_r = exception_addr_i;
        default:                        csr_mtval_r = 32'b0;
        endcase        

        // Fault cause
        csr_mcause_r = {28'b0, exception_i[3:0]};
    end
    else
    begin
        case (csr_waddr_i)
        // CSR - Machine
        `CSR_MSCRATCH: csr_mscratch_r = csr_wdata_i & `CSR_MSCRATCH_MASK;
        `CSR_MEPC:     csr_mepc_r     = csr_wdata_i & `CSR_MEPC_MASK;
        `CSR_MTVEC:    csr_mtvec_r    = csr_wdata_i & `CSR_MTVEC_MASK;
        `CSR_MCAUSE:   csr_mcause_r   = csr_wdata_i & `CSR_MCAUSE_MASK;
        `CSR_MTVAL:    csr_mtval_r    = csr_wdata_i & `CSR_MTVAL_MASK;
        `CSR_MSTATUS:  csr_sr_r       = csr_wdata_i & `CSR_MSTATUS_MASK;
        `CSR_MIP:      csr_mip_r      = csr_wdata_i & `CSR_MIP_MASK;
        `CSR_MIE:      csr_mie_r      = csr_wdata_i & `CSR_MIE_MASK;
        `CSR_MEDELEG:  csr_medeleg_r  = csr_wdata_i & `CSR_MEDELEG_MASK;
        `CSR_MIDELEG:  csr_mideleg_r  = csr_wdata_i & `CSR_MIDELEG_MASK;
        // Non-std behaviour
        `CSR_MTIMECMP:
        begin
            csr_mtimecmp_r = csr_wdata_i & `CSR_MTIMECMP_MASK;
            csr_mtime_ie_r = 1'b1;
        end
        // CSR - Super
        `CSR_SEPC:     csr_sepc_r     = csr_wdata_i & `CSR_SEPC_MASK;
        `CSR_STVEC:    csr_stvec_r    = csr_wdata_i & `CSR_STVEC_MASK;
        `CSR_SCAUSE:   csr_scause_r   = csr_wdata_i & `CSR_SCAUSE_MASK;
        `CSR_STVAL:    csr_stval_r    = csr_wdata_i & `CSR_STVAL_MASK;
        `CSR_SATP:     csr_satp_r     = csr_wdata_i & `CSR_SATP_MASK;
        `CSR_SSCRATCH: csr_sscratch_r = csr_wdata_i & `CSR_SSCRATCH_MASK;
        `CSR_SSTATUS:  csr_sr_r       = (csr_sr_r & ~`CSR_SSTATUS_MASK) | (csr_wdata_i & `CSR_SSTATUS_MASK);
        `CSR_SIP:      csr_mip_r      = (csr_mip_r & ~`CSR_SIP_MASK) | (csr_wdata_i & `CSR_SIP_MASK);
        `CSR_SIE:      csr_mie_r      = (csr_mie_r & ~`CSR_SIE_MASK) | (csr_wdata_i & `CSR_SIE_MASK);
        default:
            ;
        endcase
    end
 
    // External interrupts
    // NOTE: If the machine level interrupts are delegated to supervisor, route the interrupts there instead..
    if (ext_intr_i   &&  csr_mideleg_q[`SR_IP_MEIP_R]) csr_mip_next_r[`SR_IP_SEIP_R] = 1'b1;
    if (ext_intr_i   && ~csr_mideleg_q[`SR_IP_MEIP_R]) csr_mip_next_r[`SR_IP_MEIP_R] = 1'b1;
    if (timer_intr_i &&  csr_mideleg_q[`SR_IP_MTIP_R]) csr_mip_next_r[`SR_IP_STIP_R] = 1'b1;
    if (timer_intr_i && ~csr_mideleg_q[`SR_IP_MTIP_R]) csr_mip_next_r[`SR_IP_MTIP_R] = 1'b1;

    // Optional: Internal timer compare interrupt
    if (SUPPORT_MTIMECMP && csr_mcycle_q == csr_mtimecmp_q)
    begin
        if (csr_mideleg_q[`SR_IP_MTIP_R])
            csr_mip_next_r[`SR_IP_STIP_R] = csr_mtime_ie_q;
        else
            csr_mip_next_r[`SR_IP_MTIP_R] = csr_mtime_ie_q;
        csr_mtime_ie_r  = 1'b0;
    end

    csr_mip_r = csr_mip_r | csr_mip_next_r;
end

//-----------------------------------------------------------------
// Sequential
//-----------------------------------------------------------------
`ifdef verilator
`define HAS_SIM_CTRL
`endif
`ifdef verilog_sim
`define HAS_SIM_CTRL
`endif

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
begin
    // CSR - Machine
    csr_mepc_q         <= 32'b0;
    csr_sr_q           <= 32'b0;
    csr_mcause_q       <= 32'b0;
    csr_mtval_q        <= 32'b0;
    csr_mtvec_q        <= 32'b0;
    csr_mip_q          <= 32'b0;
    csr_mie_q          <= 32'b0;
    csr_mpriv_q        <= `PRIV_MACHINE;
    csr_mcycle_q       <= 32'b0;
    csr_mscratch_q     <= 32'b0;
    csr_mtimecmp_q     <= 32'b0;
    csr_mtime_ie_q     <= 1'b0;
    csr_medeleg_q      <= 32'b0;
    csr_mideleg_q      <= 32'b0;

    // CSR - Super
    csr_sepc_q         <= 32'b0;
    csr_stvec_q        <= 32'b0;
    csr_scause_q       <= 32'b0;
    csr_stval_q        <= 32'b0;
    csr_satp_q         <= 32'b0;
    csr_sscratch_q     <= 32'b0;

    csr_mip_next_q     <= 32'b0;
end
else
begin
    // CSR - Machine
    csr_mepc_q         <= csr_mepc_r;
    csr_sr_q           <= csr_sr_r;
    csr_mcause_q       <= csr_mcause_r;
    csr_mtval_q        <= csr_mtval_r;
    csr_mtvec_q        <= csr_mtvec_r;
    csr_mip_q          <= csr_mip_r;
    csr_mie_q          <= csr_mie_r;
    csr_mpriv_q        <= SUPPORT_SUPER ? csr_mpriv_r : `PRIV_MACHINE;
    csr_mcycle_q       <= csr_mcycle_r;
    csr_mscratch_q     <= csr_mscratch_r;
    csr_mtimecmp_q     <= SUPPORT_MTIMECMP ? csr_mtimecmp_r : 32'b0;
    csr_mtime_ie_q     <= SUPPORT_MTIMECMP ? csr_mtime_ie_r : 1'b0;
    csr_medeleg_q      <= SUPPORT_SUPER ? (csr_medeleg_r   & `CSR_MEDELEG_MASK) : 32'b0;
    csr_mideleg_q      <= SUPPORT_SUPER ? (csr_mideleg_r   & `CSR_MIDELEG_MASK) : 32'b0;

    // CSR - Super
    csr_sepc_q         <= SUPPORT_SUPER ? (csr_sepc_r     & `CSR_SEPC_MASK)     : 32'b0;
    csr_stvec_q        <= SUPPORT_SUPER ? (csr_stvec_r    & `CSR_STVEC_MASK)    : 32'b0;
    csr_scause_q       <= SUPPORT_SUPER ? (csr_scause_r   & `CSR_SCAUSE_MASK)   : 32'b0;
    csr_stval_q        <= SUPPORT_SUPER ? (csr_stval_r    & `CSR_STVAL_MASK)    : 32'b0;
    csr_satp_q         <= SUPPORT_SUPER ? (csr_satp_r     & `CSR_SATP_MASK)     : 32'b0;
    csr_sscratch_q     <= SUPPORT_SUPER ? (csr_sscratch_r & `CSR_SSCRATCH_MASK) : 32'b0;

    csr_mip_next_q     <= buffer_mip_w ? csr_mip_next_r : 32'b0;

`ifdef HAS_SIM_CTRL
    // CSR SIM_CTRL (or DSCRATCH)
    if ((csr_waddr_i == `CSR_DSCRATCH || csr_waddr_i == `CSR_SIM_CTRL) && ~(|exception_i))
    begin
        case (csr_wdata_i & 32'hFF000000)
        `CSR_SIM_CTRL_EXIT:
        begin
            //exit(csr_wdata_i[7:0]);
            $finish;
            $finish;
        end
        `CSR_SIM_CTRL_PUTC:
        begin
            $write("%c", csr_wdata_i[7:0]);
        end
        endcase
    end
`endif
end

//-----------------------------------------------------------------
// CSR branch
//-----------------------------------------------------------------
reg        branch_r;
reg [31:0] branch_target_r;

always @ *
begin
    branch_r        = 1'b0;
    branch_target_r = 32'b0;

    // Interrupts
    if (exception_i == `EXCEPTION_INTERRUPT)
    begin
        branch_r        = 1'b1;
        branch_target_r = (irq_priv_q == `PRIV_MACHINE) ? csr_mtvec_q : csr_stvec_q;
    end
    // Exception return
    else if (exception_i == `EXCEPTION_ERET)
    begin
        // TODO: Not quite correct - should check which ERET insn
        // MRET (return from machine)
        if (csr_mpriv_q == `PRIV_MACHINE)
        begin    
            branch_r        = 1'b1;
            branch_target_r = csr_mepc_q;
        end
        // SRET (return from supervisor)
        else
        begin
            branch_r        = 1'b1;
            branch_target_r = csr_sepc_q;
        end
    end
    // Exception - handled in super mode
    else if (is_exception_w && exception_s_w)
    begin
        branch_r        = 1'b1;
        branch_target_r = csr_stvec_q;
    end
    // Exception - handled in machine mode
    else if (is_exception_w)
    begin
        branch_r        = 1'b1;
        branch_target_r = csr_mtvec_q;
    end
    // Fence / SATP register writes cause pipeline flushes
    else if (exception_i == `EXCEPTION_FENCE)
    begin
        branch_r        = 1'b1;
        branch_target_r = exception_pc_i + 32'd4;
    end
end

assign csr_branch_o = branch_r;
assign csr_target_o = branch_target_r;

`ifdef verilator
function [31:0] get_mcycle; /*verilator public*/
begin
    get_mcycle = csr_mcycle_q;
end
endfunction
`endif

endmodule
