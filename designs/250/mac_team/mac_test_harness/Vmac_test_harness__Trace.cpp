// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vmac_test_harness__Syms.h"


void Vmac_test_harness::traceChgTop0(void* userp, VerilatedVcd* tracep) {
    Vmac_test_harness__Syms* __restrict vlSymsp = static_cast<Vmac_test_harness__Syms*>(userp);
    Vmac_test_harness* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Variables
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    {
        vlTOPp->traceChgSub0(userp, tracep);
    }
}

void Vmac_test_harness::traceChgSub0(void* userp, VerilatedVcd* tracep) {
    Vmac_test_harness__Syms* __restrict vlSymsp = static_cast<Vmac_test_harness__Syms*>(userp);
    Vmac_test_harness* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    vluint32_t* const oldp = tracep->oldp(vlSymsp->__Vm_baseCode + 1);
    if (false && oldp) {}  // Prevent unused
    // Body
    {
        if (VL_UNLIKELY(vlTOPp->__Vm_traceActivity[0U])) {
            tracep->chgWData(oldp+0,(vlTOPp->macTestHarness__DOT__cfg),131);
            tracep->chgIData(oldp+5,(vlTOPp->macTestHarness__DOT__num_tests),32);
            tracep->chgCData(oldp+6,((7U & vlTOPp->macTestHarness__DOT__cfg[0U])),3);
        }
        if (VL_UNLIKELY(vlTOPp->__Vm_traceActivity[1U])) {
            tracep->chgCData(oldp+7,(vlTOPp->macTestHarness__DOT__A0),8);
            tracep->chgCData(oldp+8,(vlTOPp->macTestHarness__DOT__B0),8);
            tracep->chgCData(oldp+9,(vlTOPp->macTestHarness__DOT__A1),8);
            tracep->chgCData(oldp+10,(vlTOPp->macTestHarness__DOT__B1),8);
            tracep->chgCData(oldp+11,(vlTOPp->macTestHarness__DOT__A2),8);
            tracep->chgCData(oldp+12,(vlTOPp->macTestHarness__DOT__B2),8);
            tracep->chgCData(oldp+13,(vlTOPp->macTestHarness__DOT__A3),8);
            tracep->chgCData(oldp+14,(vlTOPp->macTestHarness__DOT__B3),8);
            tracep->chgIData(oldp+15,(vlTOPp->macTestHarness__DOT__out0),32);
            tracep->chgIData(oldp+16,(vlTOPp->macTestHarness__DOT__out1),32);
            tracep->chgIData(oldp+17,(vlTOPp->macTestHarness__DOT__out2),32);
            tracep->chgIData(oldp+18,(vlTOPp->macTestHarness__DOT__out3),32);
            tracep->chgIData(oldp+19,(vlTOPp->macTestHarness__DOT__golden_out0),32);
            tracep->chgIData(oldp+20,(vlTOPp->macTestHarness__DOT__golden_out1),32);
            tracep->chgIData(oldp+21,(vlTOPp->macTestHarness__DOT__golden_out2),32);
            tracep->chgIData(oldp+22,(vlTOPp->macTestHarness__DOT__golden_out3),32);
            tracep->chgIData(oldp+23,(vlTOPp->macTestHarness__DOT__pipelined_golden_out0),32);
            tracep->chgIData(oldp+24,(vlTOPp->macTestHarness__DOT__pipelined_golden_out1),32);
            tracep->chgIData(oldp+25,(vlTOPp->macTestHarness__DOT__pipelined_golden_out2),32);
            tracep->chgIData(oldp+26,(vlTOPp->macTestHarness__DOT__pipelined_golden_out3),32);
            tracep->chgIData(oldp+27,(vlTOPp->macTestHarness__DOT__test),32);
            tracep->chgQData(oldp+28,(vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out0),40);
            tracep->chgQData(oldp+30,(vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out1),40);
            tracep->chgQData(oldp+32,(vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out2),40);
            tracep->chgQData(oldp+34,(vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out3),40);
            tracep->chgSData(oldp+36,(vlTOPp->macTestHarness__DOT__dut__DOT__macmul0__DOT__A0B0),16);
            tracep->chgSData(oldp+37,(vlTOPp->macTestHarness__DOT__dut__DOT__macmul0__DOT__A1B0),16);
            tracep->chgSData(oldp+38,((0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A2) 
                                                  * (IData)(vlTOPp->macTestHarness__DOT__B0)))),16);
            tracep->chgSData(oldp+39,((0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A3) 
                                                  * (IData)(vlTOPp->macTestHarness__DOT__B0)))),16);
            tracep->chgSData(oldp+40,(vlTOPp->macTestHarness__DOT__dut__DOT__macmul1__DOT__A1B1),16);
            tracep->chgSData(oldp+41,(vlTOPp->macTestHarness__DOT__dut__DOT__macmul1__DOT__A0B1),16);
            tracep->chgSData(oldp+42,((0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A2) 
                                                  * (IData)(vlTOPp->macTestHarness__DOT__B1)))),16);
            tracep->chgSData(oldp+43,((0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A3) 
                                                  * (IData)(vlTOPp->macTestHarness__DOT__B1)))),16);
            tracep->chgSData(oldp+44,(vlTOPp->macTestHarness__DOT__dut__DOT__macmul2__DOT__A2B2),16);
            tracep->chgSData(oldp+45,((0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A0) 
                                                  * (IData)(vlTOPp->macTestHarness__DOT__B2)))),16);
            tracep->chgSData(oldp+46,((0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A1) 
                                                  * (IData)(vlTOPp->macTestHarness__DOT__B2)))),16);
            tracep->chgSData(oldp+47,(vlTOPp->macTestHarness__DOT__dut__DOT__macmul2__DOT__A3B2),16);
            tracep->chgSData(oldp+48,(vlTOPp->macTestHarness__DOT__dut__DOT__macmul3__DOT__A3B3),16);
            tracep->chgSData(oldp+49,((0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A0) 
                                                  * (IData)(vlTOPp->macTestHarness__DOT__B3)))),16);
            tracep->chgSData(oldp+50,((0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A1) 
                                                  * (IData)(vlTOPp->macTestHarness__DOT__B3)))),16);
            tracep->chgSData(oldp+51,(vlTOPp->macTestHarness__DOT__dut__DOT__macmul3__DOT__A2B3),16);
            tracep->chgIData(oldp+52,(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out0),32);
            tracep->chgIData(oldp+53,(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out1),32);
            tracep->chgIData(oldp+54,(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out2),32);
            tracep->chgIData(oldp+55,(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out3),32);
            tracep->chgIData(oldp+56,(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out0_reg),32);
            tracep->chgIData(oldp+57,(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out1_reg),32);
            tracep->chgIData(oldp+58,(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out2_reg),32);
            tracep->chgIData(oldp+59,(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out3_reg),32);
            tracep->chgIData(oldp+60,(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out0),32);
            tracep->chgIData(oldp+61,(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out1),32);
            tracep->chgIData(oldp+62,(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out2),32);
            tracep->chgIData(oldp+63,(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out3),32);
        }
        tracep->chgBit(oldp+64,(vlTOPp->clk));
        tracep->chgBit(oldp+65,(vlTOPp->reset));
        tracep->chgBit(oldp+66,(vlTOPp->macTestHarness__DOT__r_reset));
    }
}

void Vmac_test_harness::traceCleanup(void* userp, VerilatedVcd* /*unused*/) {
    Vmac_test_harness__Syms* __restrict vlSymsp = static_cast<Vmac_test_harness__Syms*>(userp);
    Vmac_test_harness* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    {
        vlSymsp->__Vm_activity = false;
        vlTOPp->__Vm_traceActivity[0U] = 0U;
        vlTOPp->__Vm_traceActivity[1U] = 0U;
    }
}
