// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vmac_test_harness__Syms.h"


//======================

void Vmac_test_harness::trace(VerilatedVcdC* tfp, int, int) {
    tfp->spTrace()->addInitCb(&traceInit, __VlSymsp);
    traceRegister(tfp->spTrace());
}

void Vmac_test_harness::traceInit(void* userp, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vmac_test_harness__Syms* __restrict vlSymsp = static_cast<Vmac_test_harness__Syms*>(userp);
    if (!Verilated::calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
                        "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->module(vlSymsp->name());
    tracep->scopeEscape(' ');
    Vmac_test_harness::traceInitTop(vlSymsp, tracep);
    tracep->scopeEscape('.');
}

//======================


void Vmac_test_harness::traceInitTop(void* userp, VerilatedVcd* tracep) {
    Vmac_test_harness__Syms* __restrict vlSymsp = static_cast<Vmac_test_harness__Syms*>(userp);
    Vmac_test_harness* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceInitSub0(userp, tracep);
    }
}

void Vmac_test_harness::traceInitSub0(void* userp, VerilatedVcd* tracep) {
    Vmac_test_harness__Syms* __restrict vlSymsp = static_cast<Vmac_test_harness__Syms*>(userp);
    Vmac_test_harness* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    const int c = vlSymsp->__Vm_baseCode;
    if (false && tracep && c) {}  // Prevent unused
    // Body
    {
        tracep->declBit(c+65,"clk", false,-1);
        tracep->declBit(c+66,"reset", false,-1);
        tracep->declBit(c+65,"macTestHarness clk", false,-1);
        tracep->declBit(c+66,"macTestHarness reset", false,-1);
        tracep->declBit(c+67,"macTestHarness r_reset", false,-1);
        tracep->declBit(c+68,"macTestHarness start", false,-1);
        tracep->declBus(c+8,"macTestHarness A0", false,-1, 7,0);
        tracep->declBus(c+9,"macTestHarness B0", false,-1, 7,0);
        tracep->declBus(c+10,"macTestHarness A1", false,-1, 7,0);
        tracep->declBus(c+11,"macTestHarness B1", false,-1, 7,0);
        tracep->declBus(c+12,"macTestHarness A2", false,-1, 7,0);
        tracep->declBus(c+13,"macTestHarness B2", false,-1, 7,0);
        tracep->declBus(c+14,"macTestHarness A3", false,-1, 7,0);
        tracep->declBus(c+15,"macTestHarness B3", false,-1, 7,0);
        tracep->declArray(c+1,"macTestHarness cfg", false,-1, 130,0);
        tracep->declBus(c+16,"macTestHarness out0", false,-1, 31,0);
        tracep->declBus(c+17,"macTestHarness out1", false,-1, 31,0);
        tracep->declBus(c+18,"macTestHarness out2", false,-1, 31,0);
        tracep->declBus(c+19,"macTestHarness out3", false,-1, 31,0);
        tracep->declBus(c+20,"macTestHarness golden_out0", false,-1, 31,0);
        tracep->declBus(c+21,"macTestHarness golden_out1", false,-1, 31,0);
        tracep->declBus(c+22,"macTestHarness golden_out2", false,-1, 31,0);
        tracep->declBus(c+23,"macTestHarness golden_out3", false,-1, 31,0);
        tracep->declBus(c+24,"macTestHarness pipelined_golden_out0", false,-1, 31,0);
        tracep->declBus(c+25,"macTestHarness pipelined_golden_out1", false,-1, 31,0);
        tracep->declBus(c+26,"macTestHarness pipelined_golden_out2", false,-1, 31,0);
        tracep->declBus(c+27,"macTestHarness pipelined_golden_out3", false,-1, 31,0);
        tracep->declBus(c+28,"macTestHarness test", false,-1, 31,0);
        tracep->declBus(c+6,"macTestHarness num_tests", false,-1, 31,0);
        tracep->declBit(c+65,"macTestHarness dut clk", false,-1);
        tracep->declBit(c+67,"macTestHarness dut rst", false,-1);
        tracep->declBit(c+69,"macTestHarness dut en", false,-1);
        tracep->declBus(c+8,"macTestHarness dut A0", false,-1, 7,0);
        tracep->declBus(c+9,"macTestHarness dut B0", false,-1, 7,0);
        tracep->declBus(c+10,"macTestHarness dut A1", false,-1, 7,0);
        tracep->declBus(c+11,"macTestHarness dut B1", false,-1, 7,0);
        tracep->declBus(c+12,"macTestHarness dut A2", false,-1, 7,0);
        tracep->declBus(c+13,"macTestHarness dut B2", false,-1, 7,0);
        tracep->declBus(c+14,"macTestHarness dut A3", false,-1, 7,0);
        tracep->declBus(c+15,"macTestHarness dut B3", false,-1, 7,0);
        tracep->declArray(c+1,"macTestHarness dut cfg", false,-1, 130,0);
        tracep->declBus(c+16,"macTestHarness dut out0", false,-1, 31,0);
        tracep->declBus(c+17,"macTestHarness dut out1", false,-1, 31,0);
        tracep->declBus(c+18,"macTestHarness dut out2", false,-1, 31,0);
        tracep->declBus(c+19,"macTestHarness dut out3", false,-1, 31,0);
        tracep->declQuad(c+29,"macTestHarness dut mac_mul_out0", false,-1, 39,0);
        tracep->declQuad(c+31,"macTestHarness dut mac_mul_out1", false,-1, 39,0);
        tracep->declQuad(c+33,"macTestHarness dut mac_mul_out2", false,-1, 39,0);
        tracep->declQuad(c+35,"macTestHarness dut mac_mul_out3", false,-1, 39,0);
        tracep->declBit(c+65,"macTestHarness dut macmul0 clk", false,-1);
        tracep->declBit(c+67,"macTestHarness dut macmul0 rst", false,-1);
        tracep->declBit(c+69,"macTestHarness dut macmul0 en", false,-1);
        tracep->declBus(c+9,"macTestHarness dut macmul0 B0", false,-1, 7,0);
        tracep->declBus(c+8,"macTestHarness dut macmul0 A0", false,-1, 7,0);
        tracep->declBus(c+10,"macTestHarness dut macmul0 A1", false,-1, 7,0);
        tracep->declBus(c+12,"macTestHarness dut macmul0 A2", false,-1, 7,0);
        tracep->declBus(c+14,"macTestHarness dut macmul0 A3", false,-1, 7,0);
        tracep->declBus(c+7,"macTestHarness dut macmul0 cfg", false,-1, 2,0);
        tracep->declQuad(c+29,"macTestHarness dut macmul0 C", false,-1, 39,0);
        tracep->declBus(c+37,"macTestHarness dut macmul0 A0B0", false,-1, 15,0);
        tracep->declBus(c+38,"macTestHarness dut macmul0 A1B0", false,-1, 15,0);
        tracep->declBus(c+39,"macTestHarness dut macmul0 A2B0", false,-1, 15,0);
        tracep->declBus(c+40,"macTestHarness dut macmul0 A3B0", false,-1, 15,0);
        tracep->declBus(c+8,"macTestHarness dut macmul0 A0B0_mul_block A", false,-1, 7,0);
        tracep->declBus(c+9,"macTestHarness dut macmul0 A0B0_mul_block B", false,-1, 7,0);
        tracep->declBus(c+37,"macTestHarness dut macmul0 A0B0_mul_block C", false,-1, 15,0);
        tracep->declBus(c+10,"macTestHarness dut macmul0 A1B0_mul_block A", false,-1, 7,0);
        tracep->declBus(c+9,"macTestHarness dut macmul0 A1B0_mul_block B", false,-1, 7,0);
        tracep->declBus(c+38,"macTestHarness dut macmul0 A1B0_mul_block C", false,-1, 15,0);
        tracep->declBus(c+12,"macTestHarness dut macmul0 A2B0_mul_block A", false,-1, 7,0);
        tracep->declBus(c+9,"macTestHarness dut macmul0 A2B0_mul_block B", false,-1, 7,0);
        tracep->declBus(c+39,"macTestHarness dut macmul0 A2B0_mul_block C", false,-1, 15,0);
        tracep->declBus(c+14,"macTestHarness dut macmul0 A3B0_mul_block A", false,-1, 7,0);
        tracep->declBus(c+9,"macTestHarness dut macmul0 A3B0_mul_block B", false,-1, 7,0);
        tracep->declBus(c+40,"macTestHarness dut macmul0 A3B0_mul_block C", false,-1, 15,0);
        tracep->declBit(c+65,"macTestHarness dut macmul1 clk", false,-1);
        tracep->declBit(c+67,"macTestHarness dut macmul1 rst", false,-1);
        tracep->declBit(c+69,"macTestHarness dut macmul1 en", false,-1);
        tracep->declBus(c+11,"macTestHarness dut macmul1 B1", false,-1, 7,0);
        tracep->declBus(c+8,"macTestHarness dut macmul1 A0", false,-1, 7,0);
        tracep->declBus(c+10,"macTestHarness dut macmul1 A1", false,-1, 7,0);
        tracep->declBus(c+12,"macTestHarness dut macmul1 A2", false,-1, 7,0);
        tracep->declBus(c+14,"macTestHarness dut macmul1 A3", false,-1, 7,0);
        tracep->declBus(c+7,"macTestHarness dut macmul1 cfg", false,-1, 2,0);
        tracep->declQuad(c+31,"macTestHarness dut macmul1 C", false,-1, 39,0);
        tracep->declBus(c+41,"macTestHarness dut macmul1 A1B1", false,-1, 15,0);
        tracep->declBus(c+42,"macTestHarness dut macmul1 A0B1", false,-1, 15,0);
        tracep->declBus(c+43,"macTestHarness dut macmul1 A2B1", false,-1, 15,0);
        tracep->declBus(c+44,"macTestHarness dut macmul1 A3B1", false,-1, 15,0);
        tracep->declBus(c+10,"macTestHarness dut macmul1 A1B1_mul_block A", false,-1, 7,0);
        tracep->declBus(c+11,"macTestHarness dut macmul1 A1B1_mul_block B", false,-1, 7,0);
        tracep->declBus(c+41,"macTestHarness dut macmul1 A1B1_mul_block C", false,-1, 15,0);
        tracep->declBus(c+8,"macTestHarness dut macmul1 A0B1_mul_block A", false,-1, 7,0);
        tracep->declBus(c+11,"macTestHarness dut macmul1 A0B1_mul_block B", false,-1, 7,0);
        tracep->declBus(c+42,"macTestHarness dut macmul1 A0B1_mul_block C", false,-1, 15,0);
        tracep->declBus(c+12,"macTestHarness dut macmul1 A2B1_mul_block A", false,-1, 7,0);
        tracep->declBus(c+11,"macTestHarness dut macmul1 A2B1_mul_block B", false,-1, 7,0);
        tracep->declBus(c+43,"macTestHarness dut macmul1 A2B1_mul_block C", false,-1, 15,0);
        tracep->declBus(c+14,"macTestHarness dut macmul1 A3B1_mul_block A", false,-1, 7,0);
        tracep->declBus(c+11,"macTestHarness dut macmul1 A3B1_mul_block B", false,-1, 7,0);
        tracep->declBus(c+44,"macTestHarness dut macmul1 A3B1_mul_block C", false,-1, 15,0);
        tracep->declBit(c+65,"macTestHarness dut macmul2 clk", false,-1);
        tracep->declBit(c+67,"macTestHarness dut macmul2 rst", false,-1);
        tracep->declBit(c+69,"macTestHarness dut macmul2 en", false,-1);
        tracep->declBus(c+13,"macTestHarness dut macmul2 B2", false,-1, 7,0);
        tracep->declBus(c+8,"macTestHarness dut macmul2 A0", false,-1, 7,0);
        tracep->declBus(c+10,"macTestHarness dut macmul2 A1", false,-1, 7,0);
        tracep->declBus(c+12,"macTestHarness dut macmul2 A2", false,-1, 7,0);
        tracep->declBus(c+14,"macTestHarness dut macmul2 A3", false,-1, 7,0);
        tracep->declBus(c+7,"macTestHarness dut macmul2 cfg", false,-1, 2,0);
        tracep->declQuad(c+33,"macTestHarness dut macmul2 C", false,-1, 39,0);
        tracep->declBus(c+45,"macTestHarness dut macmul2 A2B2", false,-1, 15,0);
        tracep->declBus(c+46,"macTestHarness dut macmul2 A0B2", false,-1, 15,0);
        tracep->declBus(c+47,"macTestHarness dut macmul2 A1B2", false,-1, 15,0);
        tracep->declBus(c+48,"macTestHarness dut macmul2 A3B2", false,-1, 15,0);
        tracep->declBus(c+12,"macTestHarness dut macmul2 A2B2_mul_block A", false,-1, 7,0);
        tracep->declBus(c+13,"macTestHarness dut macmul2 A2B2_mul_block B", false,-1, 7,0);
        tracep->declBus(c+45,"macTestHarness dut macmul2 A2B2_mul_block C", false,-1, 15,0);
        tracep->declBus(c+8,"macTestHarness dut macmul2 A0B2_mul_block A", false,-1, 7,0);
        tracep->declBus(c+13,"macTestHarness dut macmul2 A0B2_mul_block B", false,-1, 7,0);
        tracep->declBus(c+46,"macTestHarness dut macmul2 A0B2_mul_block C", false,-1, 15,0);
        tracep->declBus(c+10,"macTestHarness dut macmul2 A1B2_mul_block A", false,-1, 7,0);
        tracep->declBus(c+13,"macTestHarness dut macmul2 A1B2_mul_block B", false,-1, 7,0);
        tracep->declBus(c+47,"macTestHarness dut macmul2 A1B2_mul_block C", false,-1, 15,0);
        tracep->declBus(c+14,"macTestHarness dut macmul2 A3B2_mul_block A", false,-1, 7,0);
        tracep->declBus(c+13,"macTestHarness dut macmul2 A3B2_mul_block B", false,-1, 7,0);
        tracep->declBus(c+48,"macTestHarness dut macmul2 A3B2_mul_block C", false,-1, 15,0);
        tracep->declBit(c+65,"macTestHarness dut macmul3 clk", false,-1);
        tracep->declBit(c+67,"macTestHarness dut macmul3 rst", false,-1);
        tracep->declBit(c+69,"macTestHarness dut macmul3 en", false,-1);
        tracep->declBus(c+15,"macTestHarness dut macmul3 B3", false,-1, 7,0);
        tracep->declBus(c+8,"macTestHarness dut macmul3 A0", false,-1, 7,0);
        tracep->declBus(c+10,"macTestHarness dut macmul3 A1", false,-1, 7,0);
        tracep->declBus(c+12,"macTestHarness dut macmul3 A2", false,-1, 7,0);
        tracep->declBus(c+14,"macTestHarness dut macmul3 A3", false,-1, 7,0);
        tracep->declBus(c+7,"macTestHarness dut macmul3 cfg", false,-1, 2,0);
        tracep->declQuad(c+35,"macTestHarness dut macmul3 C", false,-1, 39,0);
        tracep->declBus(c+49,"macTestHarness dut macmul3 A3B3", false,-1, 15,0);
        tracep->declBus(c+50,"macTestHarness dut macmul3 A0B3", false,-1, 15,0);
        tracep->declBus(c+51,"macTestHarness dut macmul3 A1B3", false,-1, 15,0);
        tracep->declBus(c+52,"macTestHarness dut macmul3 A2B3", false,-1, 15,0);
        tracep->declBus(c+14,"macTestHarness dut macmul3 A3B3_mul_block A", false,-1, 7,0);
        tracep->declBus(c+15,"macTestHarness dut macmul3 A3B3_mul_block B", false,-1, 7,0);
        tracep->declBus(c+49,"macTestHarness dut macmul3 A3B3_mul_block C", false,-1, 15,0);
        tracep->declBus(c+8,"macTestHarness dut macmul3 A0B3_mul_block A", false,-1, 7,0);
        tracep->declBus(c+15,"macTestHarness dut macmul3 A0B3_mul_block B", false,-1, 7,0);
        tracep->declBus(c+50,"macTestHarness dut macmul3 A0B3_mul_block C", false,-1, 15,0);
        tracep->declBus(c+10,"macTestHarness dut macmul3 A1B3_mul_block A", false,-1, 7,0);
        tracep->declBus(c+15,"macTestHarness dut macmul3 A1B3_mul_block B", false,-1, 7,0);
        tracep->declBus(c+51,"macTestHarness dut macmul3 A1B3_mul_block C", false,-1, 15,0);
        tracep->declBus(c+12,"macTestHarness dut macmul3 A2B3_mul_block A", false,-1, 7,0);
        tracep->declBus(c+15,"macTestHarness dut macmul3 A2B3_mul_block B", false,-1, 7,0);
        tracep->declBus(c+52,"macTestHarness dut macmul3 A2B3_mul_block C", false,-1, 15,0);
        tracep->declBit(c+65,"macTestHarness dut macacc clk", false,-1);
        tracep->declBit(c+67,"macTestHarness dut macacc rst", false,-1);
        tracep->declBit(c+69,"macTestHarness dut macacc en", false,-1);
        tracep->declArray(c+1,"macTestHarness dut macacc cfg", false,-1, 130,0);
        tracep->declQuad(c+29,"macTestHarness dut macacc partial0", false,-1, 39,0);
        tracep->declQuad(c+31,"macTestHarness dut macacc partial1", false,-1, 39,0);
        tracep->declQuad(c+33,"macTestHarness dut macacc partial2", false,-1, 39,0);
        tracep->declQuad(c+35,"macTestHarness dut macacc partial3", false,-1, 39,0);
        tracep->declBus(c+16,"macTestHarness dut macacc out0", false,-1, 31,0);
        tracep->declBus(c+17,"macTestHarness dut macacc out1", false,-1, 31,0);
        tracep->declBus(c+18,"macTestHarness dut macacc out2", false,-1, 31,0);
        tracep->declBus(c+19,"macTestHarness dut macacc out3", false,-1, 31,0);
        tracep->declBus(c+53,"macTestHarness dut macacc mult_only_out0", false,-1, 31,0);
        tracep->declBus(c+54,"macTestHarness dut macacc mult_only_out1", false,-1, 31,0);
        tracep->declBus(c+55,"macTestHarness dut macacc mult_only_out2", false,-1, 31,0);
        tracep->declBus(c+56,"macTestHarness dut macacc mult_only_out3", false,-1, 31,0);
        tracep->declBus(c+57,"macTestHarness dut macacc mult_only_out0_reg", false,-1, 31,0);
        tracep->declBus(c+58,"macTestHarness dut macacc mult_only_out1_reg", false,-1, 31,0);
        tracep->declBus(c+59,"macTestHarness dut macacc mult_only_out2_reg", false,-1, 31,0);
        tracep->declBus(c+60,"macTestHarness dut macacc mult_only_out3_reg", false,-1, 31,0);
        tracep->declBus(c+61,"macTestHarness dut macacc acc_out0", false,-1, 31,0);
        tracep->declBus(c+62,"macTestHarness dut macacc acc_out1", false,-1, 31,0);
        tracep->declBus(c+63,"macTestHarness dut macacc acc_out2", false,-1, 31,0);
        tracep->declBus(c+64,"macTestHarness dut macacc acc_out3", false,-1, 31,0);
    }
}

void Vmac_test_harness::traceRegister(VerilatedVcd* tracep) {
    // Body
    {
        tracep->addFullCb(&traceFullTop0, __VlSymsp);
        tracep->addChgCb(&traceChgTop0, __VlSymsp);
        tracep->addCleanupCb(&traceCleanup, __VlSymsp);
    }
}

void Vmac_test_harness::traceFullTop0(void* userp, VerilatedVcd* tracep) {
    Vmac_test_harness__Syms* __restrict vlSymsp = static_cast<Vmac_test_harness__Syms*>(userp);
    Vmac_test_harness* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlTOPp->traceFullSub0(userp, tracep);
    }
}

void Vmac_test_harness::traceFullSub0(void* userp, VerilatedVcd* tracep) {
    Vmac_test_harness__Syms* __restrict vlSymsp = static_cast<Vmac_test_harness__Syms*>(userp);
    Vmac_test_harness* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    vluint32_t* const oldp = tracep->oldp(vlSymsp->__Vm_baseCode);
    if (false && oldp) {}  // Prevent unused
    // Body
    {
        tracep->fullWData(oldp+1,(vlTOPp->macTestHarness__DOT__cfg),131);
        tracep->fullIData(oldp+6,(vlTOPp->macTestHarness__DOT__num_tests),32);
        tracep->fullCData(oldp+7,((7U & vlTOPp->macTestHarness__DOT__cfg[0U])),3);
        tracep->fullCData(oldp+8,(vlTOPp->macTestHarness__DOT__A0),8);
        tracep->fullCData(oldp+9,(vlTOPp->macTestHarness__DOT__B0),8);
        tracep->fullCData(oldp+10,(vlTOPp->macTestHarness__DOT__A1),8);
        tracep->fullCData(oldp+11,(vlTOPp->macTestHarness__DOT__B1),8);
        tracep->fullCData(oldp+12,(vlTOPp->macTestHarness__DOT__A2),8);
        tracep->fullCData(oldp+13,(vlTOPp->macTestHarness__DOT__B2),8);
        tracep->fullCData(oldp+14,(vlTOPp->macTestHarness__DOT__A3),8);
        tracep->fullCData(oldp+15,(vlTOPp->macTestHarness__DOT__B3),8);
        tracep->fullIData(oldp+16,(vlTOPp->macTestHarness__DOT__out0),32);
        tracep->fullIData(oldp+17,(vlTOPp->macTestHarness__DOT__out1),32);
        tracep->fullIData(oldp+18,(vlTOPp->macTestHarness__DOT__out2),32);
        tracep->fullIData(oldp+19,(vlTOPp->macTestHarness__DOT__out3),32);
        tracep->fullIData(oldp+20,(vlTOPp->macTestHarness__DOT__golden_out0),32);
        tracep->fullIData(oldp+21,(vlTOPp->macTestHarness__DOT__golden_out1),32);
        tracep->fullIData(oldp+22,(vlTOPp->macTestHarness__DOT__golden_out2),32);
        tracep->fullIData(oldp+23,(vlTOPp->macTestHarness__DOT__golden_out3),32);
        tracep->fullIData(oldp+24,(vlTOPp->macTestHarness__DOT__pipelined_golden_out0),32);
        tracep->fullIData(oldp+25,(vlTOPp->macTestHarness__DOT__pipelined_golden_out1),32);
        tracep->fullIData(oldp+26,(vlTOPp->macTestHarness__DOT__pipelined_golden_out2),32);
        tracep->fullIData(oldp+27,(vlTOPp->macTestHarness__DOT__pipelined_golden_out3),32);
        tracep->fullIData(oldp+28,(vlTOPp->macTestHarness__DOT__test),32);
        tracep->fullQData(oldp+29,(vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out0),40);
        tracep->fullQData(oldp+31,(vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out1),40);
        tracep->fullQData(oldp+33,(vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out2),40);
        tracep->fullQData(oldp+35,(vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out3),40);
        tracep->fullSData(oldp+37,(vlTOPp->macTestHarness__DOT__dut__DOT__macmul0__DOT__A0B0),16);
        tracep->fullSData(oldp+38,(vlTOPp->macTestHarness__DOT__dut__DOT__macmul0__DOT__A1B0),16);
        tracep->fullSData(oldp+39,((0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A2) 
                                               * (IData)(vlTOPp->macTestHarness__DOT__B0)))),16);
        tracep->fullSData(oldp+40,((0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A3) 
                                               * (IData)(vlTOPp->macTestHarness__DOT__B0)))),16);
        tracep->fullSData(oldp+41,(vlTOPp->macTestHarness__DOT__dut__DOT__macmul1__DOT__A1B1),16);
        tracep->fullSData(oldp+42,(vlTOPp->macTestHarness__DOT__dut__DOT__macmul1__DOT__A0B1),16);
        tracep->fullSData(oldp+43,((0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A2) 
                                               * (IData)(vlTOPp->macTestHarness__DOT__B1)))),16);
        tracep->fullSData(oldp+44,((0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A3) 
                                               * (IData)(vlTOPp->macTestHarness__DOT__B1)))),16);
        tracep->fullSData(oldp+45,(vlTOPp->macTestHarness__DOT__dut__DOT__macmul2__DOT__A2B2),16);
        tracep->fullSData(oldp+46,((0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A0) 
                                               * (IData)(vlTOPp->macTestHarness__DOT__B2)))),16);
        tracep->fullSData(oldp+47,((0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A1) 
                                               * (IData)(vlTOPp->macTestHarness__DOT__B2)))),16);
        tracep->fullSData(oldp+48,(vlTOPp->macTestHarness__DOT__dut__DOT__macmul2__DOT__A3B2),16);
        tracep->fullSData(oldp+49,(vlTOPp->macTestHarness__DOT__dut__DOT__macmul3__DOT__A3B3),16);
        tracep->fullSData(oldp+50,((0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A0) 
                                               * (IData)(vlTOPp->macTestHarness__DOT__B3)))),16);
        tracep->fullSData(oldp+51,((0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A1) 
                                               * (IData)(vlTOPp->macTestHarness__DOT__B3)))),16);
        tracep->fullSData(oldp+52,(vlTOPp->macTestHarness__DOT__dut__DOT__macmul3__DOT__A2B3),16);
        tracep->fullIData(oldp+53,(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out0),32);
        tracep->fullIData(oldp+54,(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out1),32);
        tracep->fullIData(oldp+55,(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out2),32);
        tracep->fullIData(oldp+56,(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out3),32);
        tracep->fullIData(oldp+57,(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out0_reg),32);
        tracep->fullIData(oldp+58,(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out1_reg),32);
        tracep->fullIData(oldp+59,(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out2_reg),32);
        tracep->fullIData(oldp+60,(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out3_reg),32);
        tracep->fullIData(oldp+61,(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out0),32);
        tracep->fullIData(oldp+62,(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out1),32);
        tracep->fullIData(oldp+63,(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out2),32);
        tracep->fullIData(oldp+64,(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out3),32);
        tracep->fullBit(oldp+65,(vlTOPp->clk));
        tracep->fullBit(oldp+66,(vlTOPp->reset));
        tracep->fullBit(oldp+67,(vlTOPp->macTestHarness__DOT__r_reset));
        tracep->fullBit(oldp+68,(0U));
        tracep->fullBit(oldp+69,(1U));
    }
}
