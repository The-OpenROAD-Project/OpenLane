// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vmac_test_harness.h for the primary calling header

#include "Vmac_test_harness.h"
#include "Vmac_test_harness__Syms.h"

//==========

void Vmac_test_harness::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vmac_test_harness::eval\n"); );
    Vmac_test_harness__Syms* __restrict vlSymsp = this->__VlSymsp;  // Setup global symbol table
    Vmac_test_harness* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
#ifdef VL_DEBUG
    // Debug assertions
    _eval_debug_assertions();
#endif  // VL_DEBUG
    // Initialize
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) _eval_initial_loop(vlSymsp);
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    do {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Clock loop\n"););
        vlSymsp->__Vm_activity = true;
        _eval(vlSymsp);
        if (VL_UNLIKELY(++__VclockLoop > 100)) {
            // About to fail, so enable debug to see what's not settling.
            // Note you must run make with OPT=-DVL_DEBUG for debug prints.
            int __Vsaved_debug = Verilated::debug();
            Verilated::debug(1);
            __Vchange = _change_request(vlSymsp);
            Verilated::debug(__Vsaved_debug);
            VL_FATAL_MT("/home/arya/src/openlane/designs/250/mac_team/test/mac_test_harness.v", 4, "",
                "Verilated model didn't converge\n"
                "- See DIDNOTCONVERGE in the Verilator manual");
        } else {
            __Vchange = _change_request(vlSymsp);
        }
    } while (VL_UNLIKELY(__Vchange));
}

void Vmac_test_harness::_eval_initial_loop(Vmac_test_harness__Syms* __restrict vlSymsp) {
    vlSymsp->__Vm_didInit = true;
    _eval_initial(vlSymsp);
    vlSymsp->__Vm_activity = true;
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    do {
        _eval_settle(vlSymsp);
        _eval(vlSymsp);
        if (VL_UNLIKELY(++__VclockLoop > 100)) {
            // About to fail, so enable debug to see what's not settling.
            // Note you must run make with OPT=-DVL_DEBUG for debug prints.
            int __Vsaved_debug = Verilated::debug();
            Verilated::debug(1);
            __Vchange = _change_request(vlSymsp);
            Verilated::debug(__Vsaved_debug);
            VL_FATAL_MT("/home/arya/src/openlane/designs/250/mac_team/test/mac_test_harness.v", 4, "",
                "Verilated model didn't DC converge\n"
                "- See DIDNOTCONVERGE in the Verilator manual");
        } else {
            __Vchange = _change_request(vlSymsp);
        }
    } while (VL_UNLIKELY(__Vchange));
}

VL_INLINE_OPT void Vmac_test_harness::_sequent__TOP__1(Vmac_test_harness__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmac_test_harness::_sequent__TOP__1\n"); );
    Vmac_test_harness* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->macTestHarness__DOT__r_reset = vlTOPp->reset;
}

VL_INLINE_OPT void Vmac_test_harness::_sequent__TOP__2(Vmac_test_harness__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmac_test_harness::_sequent__TOP__2\n"); );
    Vmac_test_harness* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Variables
    IData/*31:0*/ __Vdly__macTestHarness__DOT__golden_out0;
    IData/*31:0*/ __Vdly__macTestHarness__DOT__golden_out1;
    IData/*31:0*/ __Vdly__macTestHarness__DOT__golden_out2;
    IData/*31:0*/ __Vdly__macTestHarness__DOT__golden_out3;
    IData/*31:0*/ __Vdly__macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out1;
    IData/*31:0*/ __Vdly__macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out3;
    IData/*31:0*/ __Vdly__macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out0;
    IData/*31:0*/ __Vdly__macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out2;
    WData/*127:0*/ __Vtemp3[4];
    WData/*127:0*/ __Vtemp5[4];
    WData/*127:0*/ __Vtemp6[4];
    WData/*127:0*/ __Vtemp8[4];
    WData/*127:0*/ __Vtemp10[4];
    WData/*127:0*/ __Vtemp11[4];
    WData/*127:0*/ __Vtemp13[4];
    WData/*127:0*/ __Vtemp15[4];
    WData/*127:0*/ __Vtemp16[4];
    WData/*127:0*/ __Vtemp17[4];
    WData/*127:0*/ __Vtemp18[4];
    WData/*127:0*/ __Vtemp19[4];
    WData/*127:0*/ __Vtemp21[4];
    WData/*127:0*/ __Vtemp22[4];
    WData/*127:0*/ __Vtemp23[4];
    WData/*127:0*/ __Vtemp24[4];
    WData/*127:0*/ __Vtemp25[4];
    WData/*127:0*/ __Vtemp27[4];
    WData/*127:0*/ __Vtemp28[4];
    WData/*127:0*/ __Vtemp29[4];
    WData/*127:0*/ __Vtemp30[4];
    WData/*127:0*/ __Vtemp31[4];
    WData/*127:0*/ __Vtemp33[4];
    WData/*127:0*/ __Vtemp34[4];
    WData/*127:0*/ __Vtemp35[4];
    WData/*127:0*/ __Vtemp36[4];
    WData/*127:0*/ __Vtemp37[4];
    WData/*127:0*/ __Vtemp38[4];
    WData/*127:0*/ __Vtemp39[4];
    WData/*127:0*/ __Vtemp40[4];
    WData/*127:0*/ __Vtemp41[4];
    WData/*127:0*/ __Vtemp42[4];
    WData/*127:0*/ __Vtemp43[4];
    WData/*127:0*/ __Vtemp44[4];
    WData/*127:0*/ __Vtemp45[4];
    WData/*127:0*/ __Vtemp46[4];
    WData/*127:0*/ __Vtemp47[4];
    WData/*127:0*/ __Vtemp48[4];
    WData/*127:0*/ __Vtemp49[4];
    WData/*127:0*/ __Vtemp50[4];
    WData/*127:0*/ __Vtemp51[4];
    WData/*127:0*/ __Vtemp52[4];
    WData/*127:0*/ __Vtemp53[4];
    WData/*127:0*/ __Vtemp54[4];
    WData/*127:0*/ __Vtemp55[4];
    WData/*127:0*/ __Vtemp56[4];
    WData/*127:0*/ __Vtemp57[4];
    WData/*127:0*/ __Vtemp58[4];
    WData/*127:0*/ __Vtemp59[4];
    WData/*127:0*/ __Vtemp60[4];
    WData/*127:0*/ __Vtemp61[4];
    WData/*127:0*/ __Vtemp62[4];
    WData/*127:0*/ __Vtemp63[4];
    WData/*127:0*/ __Vtemp64[4];
    WData/*127:0*/ __Vtemp65[4];
    WData/*127:0*/ __Vtemp66[4];
    WData/*127:0*/ __Vtemp67[4];
    WData/*127:0*/ __Vtemp68[4];
    WData/*127:0*/ __Vtemp69[4];
    WData/*127:0*/ __Vtemp70[4];
    WData/*127:0*/ __Vtemp71[4];
    WData/*127:0*/ __Vtemp72[4];
    WData/*127:0*/ __Vtemp73[4];
    WData/*127:0*/ __Vtemp74[4];
    WData/*127:0*/ __Vtemp75[4];
    WData/*127:0*/ __Vtemp76[4];
    WData/*127:0*/ __Vtemp77[4];
    WData/*127:0*/ __Vtemp78[4];
    WData/*127:0*/ __Vtemp79[4];
    WData/*127:0*/ __Vtemp80[4];
    WData/*127:0*/ __Vtemp81[4];
    WData/*127:0*/ __Vtemp82[4];
    WData/*127:0*/ __Vtemp83[4];
    WData/*127:0*/ __Vtemp84[4];
    WData/*127:0*/ __Vtemp85[4];
    WData/*127:0*/ __Vtemp86[4];
    // Body
    __Vdly__macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out2 
        = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out2;
    __Vdly__macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out0 
        = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out0;
    __Vdly__macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out3 
        = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out3;
    __Vdly__macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out1 
        = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out1;
    __Vdly__macTestHarness__DOT__golden_out3 = vlTOPp->macTestHarness__DOT__golden_out3;
    __Vdly__macTestHarness__DOT__golden_out2 = vlTOPp->macTestHarness__DOT__golden_out2;
    __Vdly__macTestHarness__DOT__golden_out1 = vlTOPp->macTestHarness__DOT__golden_out1;
    __Vdly__macTestHarness__DOT__golden_out0 = vlTOPp->macTestHarness__DOT__golden_out0;
    if ((1U & (~ (IData)(vlTOPp->reset)))) {
        if (VL_UNLIKELY((vlTOPp->macTestHarness__DOT__test 
                         > vlTOPp->macTestHarness__DOT__num_tests))) {
            VL_WRITEF("PASSED: %0# tests\n",32,vlTOPp->macTestHarness__DOT__num_tests);
            VL_WRITEF("With cfg: %3b\n",3,(7U & vlTOPp->macTestHarness__DOT__cfg[0U]));
            VL_WRITEF("Initial 0: %0#, Initial 1: %0#, Initial 2: %0#, Initial 3: %0#\n",
                      32,((vlTOPp->macTestHarness__DOT__cfg[1U] 
                           << 0x1dU) | (vlTOPp->macTestHarness__DOT__cfg[0U] 
                                        >> 3U)),29,
                      (0x1fffffffU & ((vlTOPp->macTestHarness__DOT__cfg[2U] 
                                       << 0x1dU) | 
                                      (vlTOPp->macTestHarness__DOT__cfg[1U] 
                                       >> 3U))),29,
                      (0x1fffffffU & ((vlTOPp->macTestHarness__DOT__cfg[3U] 
                                       << 0x1dU) | 
                                      (vlTOPp->macTestHarness__DOT__cfg[2U] 
                                       >> 3U))),29,
                      (0x1fffffffU & ((vlTOPp->macTestHarness__DOT__cfg[4U] 
                                       << 0x1dU) | 
                                      (vlTOPp->macTestHarness__DOT__cfg[3U] 
                                       >> 3U))));
            VL_FINISH_MT("/home/arya/src/openlane/designs/250/mac_team/test/mac_test_harness.v", 186, "");
        } else {
            vlTOPp->macTestHarness__DOT__test = ((IData)(1U) 
                                                 + vlTOPp->macTestHarness__DOT__test);
        }
    }
    if ((1U & (~ (IData)(vlTOPp->reset)))) {
        vlTOPp->macTestHarness__DOT__A0 = (0xffU & 
                                           VL_RANDOM_I(8));
        vlTOPp->macTestHarness__DOT__A1 = (0xffU & 
                                           VL_RANDOM_I(8));
        vlTOPp->macTestHarness__DOT__A2 = (0xffU & 
                                           VL_RANDOM_I(8));
        vlTOPp->macTestHarness__DOT__A3 = (0xffU & 
                                           VL_RANDOM_I(8));
        vlTOPp->macTestHarness__DOT__B0 = (0xffU & 
                                           VL_RANDOM_I(8));
        vlTOPp->macTestHarness__DOT__B1 = (0xffU & 
                                           VL_RANDOM_I(8));
        vlTOPp->macTestHarness__DOT__B2 = (0xffU & 
                                           VL_RANDOM_I(8));
        vlTOPp->macTestHarness__DOT__B3 = (0xffU & 
                                           VL_RANDOM_I(8));
        if (VL_UNLIKELY(((((vlTOPp->macTestHarness__DOT__out0 
                            != vlTOPp->macTestHarness__DOT__pipelined_golden_out0) 
                           | (vlTOPp->macTestHarness__DOT__out1 
                              != vlTOPp->macTestHarness__DOT__pipelined_golden_out1)) 
                          | (vlTOPp->macTestHarness__DOT__out2 
                             != vlTOPp->macTestHarness__DOT__pipelined_golden_out2)) 
                         | (vlTOPp->macTestHarness__DOT__out3 
                            != vlTOPp->macTestHarness__DOT__pipelined_golden_out3)))) {
            VL_WRITEF("FAILED: On test %0# of %0#\n",
                      32,vlTOPp->macTestHarness__DOT__test,
                      32,vlTOPp->macTestHarness__DOT__num_tests);
            VL_WRITEF("With cfg: %3b\n",3,(7U & vlTOPp->macTestHarness__DOT__cfg[0U]));
            VL_WRITEF("Initial 0: %0#, Initial 1: %0#, Initial 2: %0#, Initial 3: %0#\n",
                      32,((vlTOPp->macTestHarness__DOT__cfg[1U] 
                           << 0x1dU) | (vlTOPp->macTestHarness__DOT__cfg[0U] 
                                        >> 3U)),29,
                      (0x1fffffffU & ((vlTOPp->macTestHarness__DOT__cfg[2U] 
                                       << 0x1dU) | 
                                      (vlTOPp->macTestHarness__DOT__cfg[1U] 
                                       >> 3U))),29,
                      (0x1fffffffU & ((vlTOPp->macTestHarness__DOT__cfg[3U] 
                                       << 0x1dU) | 
                                      (vlTOPp->macTestHarness__DOT__cfg[2U] 
                                       >> 3U))),29,
                      (0x1fffffffU & ((vlTOPp->macTestHarness__DOT__cfg[4U] 
                                       << 0x1dU) | 
                                      (vlTOPp->macTestHarness__DOT__cfg[3U] 
                                       >> 3U))));
            VL_WRITEF("out0: Got %0#, Expected %0#\n",
                      32,vlTOPp->macTestHarness__DOT__out0,
                      32,vlTOPp->macTestHarness__DOT__pipelined_golden_out0);
            VL_WRITEF("out1: Got %0#, Expected %0#\n",
                      32,vlTOPp->macTestHarness__DOT__out1,
                      32,vlTOPp->macTestHarness__DOT__pipelined_golden_out1);
            VL_WRITEF("out2: Got %0#, Expected %0#\n",
                      32,vlTOPp->macTestHarness__DOT__out2,
                      32,vlTOPp->macTestHarness__DOT__pipelined_golden_out2);
            VL_WRITEF("out3: Got %0#, Expected %0#\n",
                      32,vlTOPp->macTestHarness__DOT__out3,
                      32,vlTOPp->macTestHarness__DOT__pipelined_golden_out3);
            VL_FINISH_MT("/home/arya/src/openlane/designs/250/mac_team/test/mac_test_harness.v", 169, "");
        }
    }
    vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out3_reg 
        = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out3;
    vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out2_reg 
        = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out2;
    vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out0_reg 
        = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out0;
    vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out1_reg 
        = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out1;
    if ((1U == (3U & vlTOPp->macTestHarness__DOT__cfg[0U]))) {
        __Vdly__macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out1 
            = (IData)((((((QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out1)) 
                          << 0x20U) | (QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out0))) 
                        + (((QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out1)) 
                            << 0x20U) | (QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out0)))) 
                       >> 0x20U));
        __Vdly__macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out3 
            = (IData)((((((QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out3)) 
                          << 0x20U) | (QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out2))) 
                        + (((QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out3)) 
                            << 0x20U) | (QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out2)))) 
                       >> 0x20U));
        __Vdly__macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out0 
            = (vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out0 
               + vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out0);
        __Vdly__macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out2 
            = (vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out2 
               + vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out2);
    } else {
        if ((2U == (3U & vlTOPp->macTestHarness__DOT__cfg[0U]))) {
            __Vtemp3[0U] = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out0;
            __Vtemp3[1U] = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out1;
            __Vtemp3[2U] = (IData)((((QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out3)) 
                                     << 0x20U) | (QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out2))));
            __Vtemp3[3U] = (IData)(((((QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out3)) 
                                      << 0x20U) | (QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out2))) 
                                    >> 0x20U));
            __Vtemp5[0U] = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out0;
            __Vtemp5[1U] = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out1;
            __Vtemp5[2U] = (IData)((((QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out3)) 
                                     << 0x20U) | (QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out2))));
            __Vtemp5[3U] = (IData)(((((QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out3)) 
                                      << 0x20U) | (QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out2))) 
                                    >> 0x20U));
            VL_ADD_W(4, __Vtemp6, __Vtemp3, __Vtemp5);
            __Vdly__macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out3 
                = __Vtemp6[3U];
            __Vtemp8[0U] = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out0;
            __Vtemp8[1U] = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out1;
            __Vtemp8[2U] = (IData)((((QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out3)) 
                                     << 0x20U) | (QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out2))));
            __Vtemp8[3U] = (IData)(((((QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out3)) 
                                      << 0x20U) | (QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out2))) 
                                    >> 0x20U));
            __Vtemp10[0U] = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out0;
            __Vtemp10[1U] = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out1;
            __Vtemp10[2U] = (IData)((((QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out3)) 
                                      << 0x20U) | (QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out2))));
            __Vtemp10[3U] = (IData)(((((QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out3)) 
                                       << 0x20U) | (QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out2))) 
                                     >> 0x20U));
            VL_ADD_W(4, __Vtemp11, __Vtemp8, __Vtemp10);
            __Vdly__macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out2 
                = __Vtemp11[2U];
            __Vtemp13[0U] = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out0;
            __Vtemp13[1U] = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out1;
            __Vtemp13[2U] = (IData)((((QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out3)) 
                                      << 0x20U) | (QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out2))));
            __Vtemp13[3U] = (IData)(((((QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out3)) 
                                       << 0x20U) | (QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out2))) 
                                     >> 0x20U));
            __Vtemp15[0U] = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out0;
            __Vtemp15[1U] = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out1;
            __Vtemp15[2U] = (IData)((((QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out3)) 
                                      << 0x20U) | (QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out2))));
            __Vtemp15[3U] = (IData)(((((QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out3)) 
                                       << 0x20U) | (QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out2))) 
                                     >> 0x20U));
            VL_ADD_W(4, __Vtemp16, __Vtemp13, __Vtemp15);
            __Vdly__macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out1 
                = __Vtemp16[1U];
            __Vdly__macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out0 
                = (vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out0 
                   + vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out0);
        } else {
            __Vdly__macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out0 
                = (vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out0 
                   + vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out0);
            __Vdly__macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out1 
                = (vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out1 
                   + vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out1);
            __Vdly__macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out2 
                = (vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out2 
                   + vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out2);
            __Vdly__macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out3 
                = (vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out3 
                   + vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out3);
        }
    }
    if (vlTOPp->reset) {
        __Vdly__macTestHarness__DOT__golden_out0 = 
            ((vlTOPp->macTestHarness__DOT__cfg[1U] 
              << 0x1dU) | (vlTOPp->macTestHarness__DOT__cfg[0U] 
                           >> 3U));
        __Vdly__macTestHarness__DOT__golden_out1 = 
            (0x1fffffffU & ((vlTOPp->macTestHarness__DOT__cfg[2U] 
                             << 0x1dU) | (vlTOPp->macTestHarness__DOT__cfg[1U] 
                                          >> 3U)));
        __Vdly__macTestHarness__DOT__golden_out2 = 
            (0x1fffffffU & ((vlTOPp->macTestHarness__DOT__cfg[3U] 
                             << 0x1dU) | (vlTOPp->macTestHarness__DOT__cfg[2U] 
                                          >> 3U)));
        __Vdly__macTestHarness__DOT__golden_out3 = 
            (0x1fffffffU & ((vlTOPp->macTestHarness__DOT__cfg[4U] 
                             << 0x1dU) | (vlTOPp->macTestHarness__DOT__cfg[3U] 
                                          >> 3U)));
    } else {
        if ((0U == (3U & vlTOPp->macTestHarness__DOT__cfg[0U]))) {
            if ((4U & vlTOPp->macTestHarness__DOT__cfg[0U])) {
                __Vdly__macTestHarness__DOT__golden_out0 
                    = (((IData)(vlTOPp->macTestHarness__DOT__A0) 
                        * (IData)(vlTOPp->macTestHarness__DOT__B0)) 
                       + vlTOPp->macTestHarness__DOT__golden_out0);
                __Vdly__macTestHarness__DOT__golden_out1 
                    = (((IData)(vlTOPp->macTestHarness__DOT__A1) 
                        * (IData)(vlTOPp->macTestHarness__DOT__B1)) 
                       + vlTOPp->macTestHarness__DOT__golden_out1);
                __Vdly__macTestHarness__DOT__golden_out2 
                    = (((IData)(vlTOPp->macTestHarness__DOT__A2) 
                        * (IData)(vlTOPp->macTestHarness__DOT__B2)) 
                       + vlTOPp->macTestHarness__DOT__golden_out2);
                __Vdly__macTestHarness__DOT__golden_out3 
                    = (((IData)(vlTOPp->macTestHarness__DOT__A3) 
                        * (IData)(vlTOPp->macTestHarness__DOT__B3)) 
                       + vlTOPp->macTestHarness__DOT__golden_out3);
            } else {
                __Vdly__macTestHarness__DOT__golden_out0 
                    = ((IData)(vlTOPp->macTestHarness__DOT__A0) 
                       * (IData)(vlTOPp->macTestHarness__DOT__B0));
                __Vdly__macTestHarness__DOT__golden_out1 
                    = ((IData)(vlTOPp->macTestHarness__DOT__A1) 
                       * (IData)(vlTOPp->macTestHarness__DOT__B1));
                __Vdly__macTestHarness__DOT__golden_out2 
                    = ((IData)(vlTOPp->macTestHarness__DOT__A2) 
                       * (IData)(vlTOPp->macTestHarness__DOT__B2));
                __Vdly__macTestHarness__DOT__golden_out3 
                    = ((IData)(vlTOPp->macTestHarness__DOT__A3) 
                       * (IData)(vlTOPp->macTestHarness__DOT__B3));
            }
        } else {
            if ((1U == (3U & vlTOPp->macTestHarness__DOT__cfg[0U]))) {
                if ((4U & vlTOPp->macTestHarness__DOT__cfg[0U])) {
                    __Vdly__macTestHarness__DOT__golden_out1 
                        = (IData)(((((QData)((IData)(
                                                     (((IData)(vlTOPp->macTestHarness__DOT__A1) 
                                                       << 8U) 
                                                      | (IData)(vlTOPp->macTestHarness__DOT__A0)))) 
                                     * (QData)((IData)(
                                                       (((IData)(vlTOPp->macTestHarness__DOT__B1) 
                                                         << 8U) 
                                                        | (IData)(vlTOPp->macTestHarness__DOT__B0))))) 
                                    + (((QData)((IData)(vlTOPp->macTestHarness__DOT__golden_out1)) 
                                        << 0x20U) | (QData)((IData)(vlTOPp->macTestHarness__DOT__golden_out0)))) 
                                   >> 0x20U));
                    __Vdly__macTestHarness__DOT__golden_out3 
                        = (IData)(((((QData)((IData)(
                                                     (((IData)(vlTOPp->macTestHarness__DOT__A3) 
                                                       << 8U) 
                                                      | (IData)(vlTOPp->macTestHarness__DOT__A2)))) 
                                     * (QData)((IData)(
                                                       (((IData)(vlTOPp->macTestHarness__DOT__B3) 
                                                         << 8U) 
                                                        | (IData)(vlTOPp->macTestHarness__DOT__B2))))) 
                                    + (((QData)((IData)(vlTOPp->macTestHarness__DOT__golden_out3)) 
                                        << 0x20U) | (QData)((IData)(vlTOPp->macTestHarness__DOT__golden_out2)))) 
                                   >> 0x20U));
                    __Vdly__macTestHarness__DOT__golden_out0 
                        = ((IData)(((QData)((IData)(
                                                    (((IData)(vlTOPp->macTestHarness__DOT__A1) 
                                                      << 8U) 
                                                     | (IData)(vlTOPp->macTestHarness__DOT__A0)))) 
                                    * (QData)((IData)(
                                                      (((IData)(vlTOPp->macTestHarness__DOT__B1) 
                                                        << 8U) 
                                                       | (IData)(vlTOPp->macTestHarness__DOT__B0)))))) 
                           + vlTOPp->macTestHarness__DOT__golden_out0);
                    __Vdly__macTestHarness__DOT__golden_out2 
                        = ((IData)(((QData)((IData)(
                                                    (((IData)(vlTOPp->macTestHarness__DOT__A3) 
                                                      << 8U) 
                                                     | (IData)(vlTOPp->macTestHarness__DOT__A2)))) 
                                    * (QData)((IData)(
                                                      (((IData)(vlTOPp->macTestHarness__DOT__B3) 
                                                        << 8U) 
                                                       | (IData)(vlTOPp->macTestHarness__DOT__B2)))))) 
                           + vlTOPp->macTestHarness__DOT__golden_out2);
                } else {
                    __Vdly__macTestHarness__DOT__golden_out1 
                        = (IData)((((QData)((IData)(
                                                    (((IData)(vlTOPp->macTestHarness__DOT__A1) 
                                                      << 8U) 
                                                     | (IData)(vlTOPp->macTestHarness__DOT__A0)))) 
                                    * (QData)((IData)(
                                                      (((IData)(vlTOPp->macTestHarness__DOT__B1) 
                                                        << 8U) 
                                                       | (IData)(vlTOPp->macTestHarness__DOT__B0))))) 
                                   >> 0x20U));
                    __Vdly__macTestHarness__DOT__golden_out0 
                        = (IData)(((QData)((IData)(
                                                   (((IData)(vlTOPp->macTestHarness__DOT__A1) 
                                                     << 8U) 
                                                    | (IData)(vlTOPp->macTestHarness__DOT__A0)))) 
                                   * (QData)((IData)(
                                                     (((IData)(vlTOPp->macTestHarness__DOT__B1) 
                                                       << 8U) 
                                                      | (IData)(vlTOPp->macTestHarness__DOT__B0))))));
                    __Vdly__macTestHarness__DOT__golden_out3 
                        = (IData)((((QData)((IData)(
                                                    (((IData)(vlTOPp->macTestHarness__DOT__A3) 
                                                      << 8U) 
                                                     | (IData)(vlTOPp->macTestHarness__DOT__A2)))) 
                                    * (QData)((IData)(
                                                      (((IData)(vlTOPp->macTestHarness__DOT__B3) 
                                                        << 8U) 
                                                       | (IData)(vlTOPp->macTestHarness__DOT__B2))))) 
                                   >> 0x20U));
                    __Vdly__macTestHarness__DOT__golden_out2 
                        = (IData)(((QData)((IData)(
                                                   (((IData)(vlTOPp->macTestHarness__DOT__A3) 
                                                     << 8U) 
                                                    | (IData)(vlTOPp->macTestHarness__DOT__A2)))) 
                                   * (QData)((IData)(
                                                     (((IData)(vlTOPp->macTestHarness__DOT__B3) 
                                                       << 8U) 
                                                      | (IData)(vlTOPp->macTestHarness__DOT__B2))))));
                }
            } else {
                if ((2U == (3U & vlTOPp->macTestHarness__DOT__cfg[0U]))) {
                    if ((4U & vlTOPp->macTestHarness__DOT__cfg[0U])) {
                        VL_EXTEND_WI(128,32, __Vtemp17, 
                                     (((IData)(vlTOPp->macTestHarness__DOT__A3) 
                                       << 0x18U) | 
                                      (((IData)(vlTOPp->macTestHarness__DOT__A2) 
                                        << 0x10U) | 
                                       (((IData)(vlTOPp->macTestHarness__DOT__A1) 
                                         << 8U) | (IData)(vlTOPp->macTestHarness__DOT__A0)))));
                        VL_EXTEND_WI(128,32, __Vtemp18, 
                                     (((IData)(vlTOPp->macTestHarness__DOT__B3) 
                                       << 0x18U) | 
                                      (((IData)(vlTOPp->macTestHarness__DOT__B2) 
                                        << 0x10U) | 
                                       (((IData)(vlTOPp->macTestHarness__DOT__B1) 
                                         << 8U) | (IData)(vlTOPp->macTestHarness__DOT__B0)))));
                        VL_MUL_W(4, __Vtemp19, __Vtemp17, __Vtemp18);
                        __Vtemp21[0U] = vlTOPp->macTestHarness__DOT__golden_out0;
                        __Vtemp21[1U] = vlTOPp->macTestHarness__DOT__golden_out1;
                        __Vtemp21[2U] = (IData)((((QData)((IData)(vlTOPp->macTestHarness__DOT__golden_out3)) 
                                                  << 0x20U) 
                                                 | (QData)((IData)(vlTOPp->macTestHarness__DOT__golden_out2))));
                        __Vtemp21[3U] = (IData)(((((QData)((IData)(vlTOPp->macTestHarness__DOT__golden_out3)) 
                                                   << 0x20U) 
                                                  | (QData)((IData)(vlTOPp->macTestHarness__DOT__golden_out2))) 
                                                 >> 0x20U));
                        VL_ADD_W(4, __Vtemp22, __Vtemp19, __Vtemp21);
                        __Vdly__macTestHarness__DOT__golden_out3 
                            = __Vtemp22[3U];
                        VL_EXTEND_WI(128,32, __Vtemp23, 
                                     (((IData)(vlTOPp->macTestHarness__DOT__A3) 
                                       << 0x18U) | 
                                      (((IData)(vlTOPp->macTestHarness__DOT__A2) 
                                        << 0x10U) | 
                                       (((IData)(vlTOPp->macTestHarness__DOT__A1) 
                                         << 8U) | (IData)(vlTOPp->macTestHarness__DOT__A0)))));
                        VL_EXTEND_WI(128,32, __Vtemp24, 
                                     (((IData)(vlTOPp->macTestHarness__DOT__B3) 
                                       << 0x18U) | 
                                      (((IData)(vlTOPp->macTestHarness__DOT__B2) 
                                        << 0x10U) | 
                                       (((IData)(vlTOPp->macTestHarness__DOT__B1) 
                                         << 8U) | (IData)(vlTOPp->macTestHarness__DOT__B0)))));
                        VL_MUL_W(4, __Vtemp25, __Vtemp23, __Vtemp24);
                        __Vtemp27[0U] = vlTOPp->macTestHarness__DOT__golden_out0;
                        __Vtemp27[1U] = vlTOPp->macTestHarness__DOT__golden_out1;
                        __Vtemp27[2U] = (IData)((((QData)((IData)(vlTOPp->macTestHarness__DOT__golden_out3)) 
                                                  << 0x20U) 
                                                 | (QData)((IData)(vlTOPp->macTestHarness__DOT__golden_out2))));
                        __Vtemp27[3U] = (IData)(((((QData)((IData)(vlTOPp->macTestHarness__DOT__golden_out3)) 
                                                   << 0x20U) 
                                                  | (QData)((IData)(vlTOPp->macTestHarness__DOT__golden_out2))) 
                                                 >> 0x20U));
                        VL_ADD_W(4, __Vtemp28, __Vtemp25, __Vtemp27);
                        __Vdly__macTestHarness__DOT__golden_out2 
                            = __Vtemp28[2U];
                        VL_EXTEND_WI(128,32, __Vtemp29, 
                                     (((IData)(vlTOPp->macTestHarness__DOT__A3) 
                                       << 0x18U) | 
                                      (((IData)(vlTOPp->macTestHarness__DOT__A2) 
                                        << 0x10U) | 
                                       (((IData)(vlTOPp->macTestHarness__DOT__A1) 
                                         << 8U) | (IData)(vlTOPp->macTestHarness__DOT__A0)))));
                        VL_EXTEND_WI(128,32, __Vtemp30, 
                                     (((IData)(vlTOPp->macTestHarness__DOT__B3) 
                                       << 0x18U) | 
                                      (((IData)(vlTOPp->macTestHarness__DOT__B2) 
                                        << 0x10U) | 
                                       (((IData)(vlTOPp->macTestHarness__DOT__B1) 
                                         << 8U) | (IData)(vlTOPp->macTestHarness__DOT__B0)))));
                        VL_MUL_W(4, __Vtemp31, __Vtemp29, __Vtemp30);
                        __Vtemp33[0U] = vlTOPp->macTestHarness__DOT__golden_out0;
                        __Vtemp33[1U] = vlTOPp->macTestHarness__DOT__golden_out1;
                        __Vtemp33[2U] = (IData)((((QData)((IData)(vlTOPp->macTestHarness__DOT__golden_out3)) 
                                                  << 0x20U) 
                                                 | (QData)((IData)(vlTOPp->macTestHarness__DOT__golden_out2))));
                        __Vtemp33[3U] = (IData)(((((QData)((IData)(vlTOPp->macTestHarness__DOT__golden_out3)) 
                                                   << 0x20U) 
                                                  | (QData)((IData)(vlTOPp->macTestHarness__DOT__golden_out2))) 
                                                 >> 0x20U));
                        VL_ADD_W(4, __Vtemp34, __Vtemp31, __Vtemp33);
                        __Vdly__macTestHarness__DOT__golden_out1 
                            = __Vtemp34[1U];
                        VL_EXTEND_WI(128,32, __Vtemp35, 
                                     (((IData)(vlTOPp->macTestHarness__DOT__A3) 
                                       << 0x18U) | 
                                      (((IData)(vlTOPp->macTestHarness__DOT__A2) 
                                        << 0x10U) | 
                                       (((IData)(vlTOPp->macTestHarness__DOT__A1) 
                                         << 8U) | (IData)(vlTOPp->macTestHarness__DOT__A0)))));
                        VL_EXTEND_WI(128,32, __Vtemp36, 
                                     (((IData)(vlTOPp->macTestHarness__DOT__B3) 
                                       << 0x18U) | 
                                      (((IData)(vlTOPp->macTestHarness__DOT__B2) 
                                        << 0x10U) | 
                                       (((IData)(vlTOPp->macTestHarness__DOT__B1) 
                                         << 8U) | (IData)(vlTOPp->macTestHarness__DOT__B0)))));
                        VL_MUL_W(4, __Vtemp37, __Vtemp35, __Vtemp36);
                        __Vdly__macTestHarness__DOT__golden_out0 
                            = (__Vtemp37[0U] + vlTOPp->macTestHarness__DOT__golden_out0);
                    } else {
                        VL_EXTEND_WI(128,32, __Vtemp38, 
                                     (((IData)(vlTOPp->macTestHarness__DOT__A3) 
                                       << 0x18U) | 
                                      (((IData)(vlTOPp->macTestHarness__DOT__A2) 
                                        << 0x10U) | 
                                       (((IData)(vlTOPp->macTestHarness__DOT__A1) 
                                         << 8U) | (IData)(vlTOPp->macTestHarness__DOT__A0)))));
                        VL_EXTEND_WI(128,32, __Vtemp39, 
                                     (((IData)(vlTOPp->macTestHarness__DOT__B3) 
                                       << 0x18U) | 
                                      (((IData)(vlTOPp->macTestHarness__DOT__B2) 
                                        << 0x10U) | 
                                       (((IData)(vlTOPp->macTestHarness__DOT__B1) 
                                         << 8U) | (IData)(vlTOPp->macTestHarness__DOT__B0)))));
                        VL_MUL_W(4, __Vtemp40, __Vtemp38, __Vtemp39);
                        __Vdly__macTestHarness__DOT__golden_out3 
                            = __Vtemp40[3U];
                        VL_EXTEND_WI(128,32, __Vtemp41, 
                                     (((IData)(vlTOPp->macTestHarness__DOT__A3) 
                                       << 0x18U) | 
                                      (((IData)(vlTOPp->macTestHarness__DOT__A2) 
                                        << 0x10U) | 
                                       (((IData)(vlTOPp->macTestHarness__DOT__A1) 
                                         << 8U) | (IData)(vlTOPp->macTestHarness__DOT__A0)))));
                        VL_EXTEND_WI(128,32, __Vtemp42, 
                                     (((IData)(vlTOPp->macTestHarness__DOT__B3) 
                                       << 0x18U) | 
                                      (((IData)(vlTOPp->macTestHarness__DOT__B2) 
                                        << 0x10U) | 
                                       (((IData)(vlTOPp->macTestHarness__DOT__B1) 
                                         << 8U) | (IData)(vlTOPp->macTestHarness__DOT__B0)))));
                        VL_MUL_W(4, __Vtemp43, __Vtemp41, __Vtemp42);
                        __Vdly__macTestHarness__DOT__golden_out2 
                            = __Vtemp43[2U];
                        VL_EXTEND_WI(128,32, __Vtemp44, 
                                     (((IData)(vlTOPp->macTestHarness__DOT__A3) 
                                       << 0x18U) | 
                                      (((IData)(vlTOPp->macTestHarness__DOT__A2) 
                                        << 0x10U) | 
                                       (((IData)(vlTOPp->macTestHarness__DOT__A1) 
                                         << 8U) | (IData)(vlTOPp->macTestHarness__DOT__A0)))));
                        VL_EXTEND_WI(128,32, __Vtemp45, 
                                     (((IData)(vlTOPp->macTestHarness__DOT__B3) 
                                       << 0x18U) | 
                                      (((IData)(vlTOPp->macTestHarness__DOT__B2) 
                                        << 0x10U) | 
                                       (((IData)(vlTOPp->macTestHarness__DOT__B1) 
                                         << 8U) | (IData)(vlTOPp->macTestHarness__DOT__B0)))));
                        VL_MUL_W(4, __Vtemp46, __Vtemp44, __Vtemp45);
                        __Vdly__macTestHarness__DOT__golden_out1 
                            = __Vtemp46[1U];
                        VL_EXTEND_WI(128,32, __Vtemp47, 
                                     (((IData)(vlTOPp->macTestHarness__DOT__A3) 
                                       << 0x18U) | 
                                      (((IData)(vlTOPp->macTestHarness__DOT__A2) 
                                        << 0x10U) | 
                                       (((IData)(vlTOPp->macTestHarness__DOT__A1) 
                                         << 8U) | (IData)(vlTOPp->macTestHarness__DOT__A0)))));
                        VL_EXTEND_WI(128,32, __Vtemp48, 
                                     (((IData)(vlTOPp->macTestHarness__DOT__B3) 
                                       << 0x18U) | 
                                      (((IData)(vlTOPp->macTestHarness__DOT__B2) 
                                        << 0x10U) | 
                                       (((IData)(vlTOPp->macTestHarness__DOT__B1) 
                                         << 8U) | (IData)(vlTOPp->macTestHarness__DOT__B0)))));
                        VL_MUL_W(4, __Vtemp49, __Vtemp47, __Vtemp48);
                        __Vdly__macTestHarness__DOT__golden_out0 
                            = __Vtemp49[0U];
                    }
                }
            }
        }
    }
    vlTOPp->macTestHarness__DOT__dut__DOT__macmul0__DOT__A0B0 
        = (0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A0) 
                      * (IData)(vlTOPp->macTestHarness__DOT__B0)));
    vlTOPp->macTestHarness__DOT__dut__DOT__macmul1__DOT__A0B1 
        = (0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A0) 
                      * (IData)(vlTOPp->macTestHarness__DOT__B1)));
    vlTOPp->macTestHarness__DOT__dut__DOT__macmul0__DOT__A1B0 
        = (0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A1) 
                      * (IData)(vlTOPp->macTestHarness__DOT__B0)));
    vlTOPp->macTestHarness__DOT__dut__DOT__macmul1__DOT__A1B1 
        = (0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A1) 
                      * (IData)(vlTOPp->macTestHarness__DOT__B1)));
    vlTOPp->macTestHarness__DOT__dut__DOT__macmul2__DOT__A2B2 
        = (0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A2) 
                      * (IData)(vlTOPp->macTestHarness__DOT__B2)));
    vlTOPp->macTestHarness__DOT__dut__DOT__macmul3__DOT__A2B3 
        = (0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A2) 
                      * (IData)(vlTOPp->macTestHarness__DOT__B3)));
    vlTOPp->macTestHarness__DOT__dut__DOT__macmul2__DOT__A3B2 
        = (0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A3) 
                      * (IData)(vlTOPp->macTestHarness__DOT__B2)));
    vlTOPp->macTestHarness__DOT__dut__DOT__macmul3__DOT__A3B3 
        = (0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A3) 
                      * (IData)(vlTOPp->macTestHarness__DOT__B3)));
    vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out1 
        = __Vdly__macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out1;
    vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out3 
        = __Vdly__macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out3;
    vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out0 
        = __Vdly__macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out0;
    vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out2 
        = __Vdly__macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out2;
    vlTOPp->macTestHarness__DOT__pipelined_golden_out0 
        = vlTOPp->macTestHarness__DOT__golden_out0;
    vlTOPp->macTestHarness__DOT__pipelined_golden_out1 
        = vlTOPp->macTestHarness__DOT__golden_out1;
    vlTOPp->macTestHarness__DOT__pipelined_golden_out2 
        = vlTOPp->macTestHarness__DOT__golden_out2;
    vlTOPp->macTestHarness__DOT__pipelined_golden_out3 
        = vlTOPp->macTestHarness__DOT__golden_out3;
    if ((0U == (3U & vlTOPp->macTestHarness__DOT__cfg[0U]))) {
        vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out0 
            = (0xffffffffffULL & (QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macmul0__DOT__A0B0)));
        vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out1 
            = (0xffffffffffULL & (QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macmul1__DOT__A1B1)));
        vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out2 
            = (0xffffffffffULL & (QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macmul2__DOT__A2B2)));
        vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out3 
            = (0xffffffffffULL & (QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macmul3__DOT__A3B3)));
    } else {
        vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out0 
            = (0xffffffffffULL & ((1U == (3U & vlTOPp->macTestHarness__DOT__cfg[0U]))
                                   ? ((QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macmul0__DOT__A0B0)) 
                                      + (QData)((IData)(
                                                        ((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macmul0__DOT__A1B0) 
                                                         << 8U))))
                                   : ((2U == (3U & 
                                              vlTOPp->macTestHarness__DOT__cfg[0U]))
                                       ? ((((QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macmul0__DOT__A0B0)) 
                                            + (QData)((IData)(
                                                              ((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macmul0__DOT__A1B0) 
                                                               << 8U)))) 
                                           + (QData)((IData)(
                                                             (0xffff0000U 
                                                              & (((IData)(vlTOPp->macTestHarness__DOT__A2) 
                                                                  * (IData)(vlTOPp->macTestHarness__DOT__B0)) 
                                                                 << 0x10U))))) 
                                          + ((QData)((IData)(
                                                             (0xffffU 
                                                              & ((IData)(vlTOPp->macTestHarness__DOT__A3) 
                                                                 * (IData)(vlTOPp->macTestHarness__DOT__B0))))) 
                                             << 0x18U))
                                       : 0ULL)));
        vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out1 
            = (0xffffffffffULL & ((1U == (3U & vlTOPp->macTestHarness__DOT__cfg[0U]))
                                   ? ((QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macmul1__DOT__A0B1)) 
                                      + (QData)((IData)(
                                                        ((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macmul1__DOT__A1B1) 
                                                         << 8U))))
                                   : ((2U == (3U & 
                                              vlTOPp->macTestHarness__DOT__cfg[0U]))
                                       ? ((((QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macmul1__DOT__A0B1)) 
                                            + (QData)((IData)(
                                                              ((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macmul1__DOT__A1B1) 
                                                               << 8U)))) 
                                           + (QData)((IData)(
                                                             (0xffff0000U 
                                                              & (((IData)(vlTOPp->macTestHarness__DOT__A2) 
                                                                  * (IData)(vlTOPp->macTestHarness__DOT__B1)) 
                                                                 << 0x10U))))) 
                                          + ((QData)((IData)(
                                                             (0xffffU 
                                                              & ((IData)(vlTOPp->macTestHarness__DOT__A3) 
                                                                 * (IData)(vlTOPp->macTestHarness__DOT__B1))))) 
                                             << 0x18U))
                                       : 0ULL)));
        vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out2 
            = (0xffffffffffULL & ((1U == (3U & vlTOPp->macTestHarness__DOT__cfg[0U]))
                                   ? ((QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macmul2__DOT__A2B2)) 
                                      + (QData)((IData)(
                                                        ((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macmul2__DOT__A3B2) 
                                                         << 8U))))
                                   : ((2U == (3U & 
                                              vlTOPp->macTestHarness__DOT__cfg[0U]))
                                       ? ((((QData)((IData)(
                                                            (0xffffU 
                                                             & ((IData)(vlTOPp->macTestHarness__DOT__A0) 
                                                                * (IData)(vlTOPp->macTestHarness__DOT__B2))))) 
                                            + (QData)((IData)(
                                                              (0xffff00U 
                                                               & (((IData)(vlTOPp->macTestHarness__DOT__A1) 
                                                                   * (IData)(vlTOPp->macTestHarness__DOT__B2)) 
                                                                  << 8U))))) 
                                           + (QData)((IData)(
                                                             ((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macmul2__DOT__A2B2) 
                                                              << 0x10U)))) 
                                          + ((QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macmul2__DOT__A3B2)) 
                                             << 0x18U))
                                       : 0ULL)));
        vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out3 
            = (0xffffffffffULL & ((1U == (3U & vlTOPp->macTestHarness__DOT__cfg[0U]))
                                   ? ((QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macmul3__DOT__A2B3)) 
                                      + (QData)((IData)(
                                                        ((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macmul3__DOT__A3B3) 
                                                         << 8U))))
                                   : ((2U == (3U & 
                                              vlTOPp->macTestHarness__DOT__cfg[0U]))
                                       ? ((((QData)((IData)(
                                                            (0xffffU 
                                                             & ((IData)(vlTOPp->macTestHarness__DOT__A0) 
                                                                * (IData)(vlTOPp->macTestHarness__DOT__B3))))) 
                                            + (QData)((IData)(
                                                              (0xffff00U 
                                                               & (((IData)(vlTOPp->macTestHarness__DOT__A1) 
                                                                   * (IData)(vlTOPp->macTestHarness__DOT__B3)) 
                                                                  << 8U))))) 
                                           + (QData)((IData)(
                                                             ((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macmul3__DOT__A2B3) 
                                                              << 0x10U)))) 
                                          + ((QData)((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__macmul3__DOT__A3B3)) 
                                             << 0x18U))
                                       : 0ULL)));
    }
    if ((4U & vlTOPp->macTestHarness__DOT__cfg[0U])) {
        vlTOPp->macTestHarness__DOT__out1 = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out1;
        vlTOPp->macTestHarness__DOT__out3 = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out3;
        vlTOPp->macTestHarness__DOT__out0 = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out0;
        vlTOPp->macTestHarness__DOT__out2 = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out2;
    } else {
        vlTOPp->macTestHarness__DOT__out1 = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out1_reg;
        vlTOPp->macTestHarness__DOT__out3 = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out3_reg;
        vlTOPp->macTestHarness__DOT__out0 = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out0_reg;
        vlTOPp->macTestHarness__DOT__out2 = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out2_reg;
    }
    vlTOPp->macTestHarness__DOT__golden_out0 = __Vdly__macTestHarness__DOT__golden_out0;
    vlTOPp->macTestHarness__DOT__golden_out1 = __Vdly__macTestHarness__DOT__golden_out1;
    vlTOPp->macTestHarness__DOT__golden_out2 = __Vdly__macTestHarness__DOT__golden_out2;
    vlTOPp->macTestHarness__DOT__golden_out3 = __Vdly__macTestHarness__DOT__golden_out3;
    VL_EXTEND_WQ(128,40, __Vtemp50, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out0);
    VL_EXTEND_WQ(128,40, __Vtemp51, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out1);
    VL_SHIFTL_WWI(128,128,32, __Vtemp52, __Vtemp51, 8U);
    VL_ADD_W(4, __Vtemp53, __Vtemp50, __Vtemp52);
    VL_EXTEND_WQ(128,40, __Vtemp54, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out2);
    VL_SHIFTL_WWI(128,128,32, __Vtemp55, __Vtemp54, 0x10U);
    VL_ADD_W(4, __Vtemp56, __Vtemp53, __Vtemp55);
    VL_EXTEND_WQ(128,40, __Vtemp57, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out3);
    VL_SHIFTL_WWI(128,128,32, __Vtemp58, __Vtemp57, 0x18U);
    VL_ADD_W(4, __Vtemp59, __Vtemp56, __Vtemp58);
    vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out3 
        = ((1U == (3U & vlTOPp->macTestHarness__DOT__cfg[0U]))
            ? (IData)(((vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out2 
                        + (vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out3 
                           << 8U)) >> 0x20U)) : ((2U 
                                                  == 
                                                  (3U 
                                                   & vlTOPp->macTestHarness__DOT__cfg[0U]))
                                                  ? 
                                                 __Vtemp59[3U]
                                                  : (IData)(vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out3)));
    VL_EXTEND_WQ(128,40, __Vtemp60, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out0);
    VL_EXTEND_WQ(128,40, __Vtemp61, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out1);
    VL_SHIFTL_WWI(128,128,32, __Vtemp62, __Vtemp61, 8U);
    VL_EXTEND_WQ(128,40, __Vtemp63, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out2);
    VL_SHIFTL_WWI(128,128,32, __Vtemp64, __Vtemp63, 0x10U);
    VL_EXTEND_WQ(128,40, __Vtemp65, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out3);
    VL_SHIFTL_WWI(128,128,32, __Vtemp66, __Vtemp65, 0x18U);
    vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out0 
        = ((1U == (3U & vlTOPp->macTestHarness__DOT__cfg[0U]))
            ? ((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out0) 
               + (IData)((vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out1 
                          << 8U))) : ((2U == (3U & 
                                              vlTOPp->macTestHarness__DOT__cfg[0U]))
                                       ? (((__Vtemp60[0U] 
                                            + __Vtemp62[0U]) 
                                           + __Vtemp64[0U]) 
                                          + __Vtemp66[0U])
                                       : (IData)(vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out0)));
    VL_EXTEND_WQ(128,40, __Vtemp67, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out0);
    VL_EXTEND_WQ(128,40, __Vtemp68, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out1);
    VL_SHIFTL_WWI(128,128,32, __Vtemp69, __Vtemp68, 8U);
    VL_ADD_W(4, __Vtemp70, __Vtemp67, __Vtemp69);
    VL_EXTEND_WQ(128,40, __Vtemp71, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out2);
    VL_SHIFTL_WWI(128,128,32, __Vtemp72, __Vtemp71, 0x10U);
    VL_ADD_W(4, __Vtemp73, __Vtemp70, __Vtemp72);
    VL_EXTEND_WQ(128,40, __Vtemp74, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out3);
    VL_SHIFTL_WWI(128,128,32, __Vtemp75, __Vtemp74, 0x18U);
    VL_ADD_W(4, __Vtemp76, __Vtemp73, __Vtemp75);
    vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out2 
        = ((1U == (3U & vlTOPp->macTestHarness__DOT__cfg[0U]))
            ? ((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out2) 
               + (IData)((vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out3 
                          << 8U))) : ((2U == (3U & 
                                              vlTOPp->macTestHarness__DOT__cfg[0U]))
                                       ? __Vtemp76[2U]
                                       : (IData)(vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out2)));
    VL_EXTEND_WQ(128,40, __Vtemp77, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out0);
    VL_EXTEND_WQ(128,40, __Vtemp78, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out1);
    VL_SHIFTL_WWI(128,128,32, __Vtemp79, __Vtemp78, 8U);
    VL_ADD_W(4, __Vtemp80, __Vtemp77, __Vtemp79);
    VL_EXTEND_WQ(128,40, __Vtemp81, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out2);
    VL_SHIFTL_WWI(128,128,32, __Vtemp82, __Vtemp81, 0x10U);
    VL_ADD_W(4, __Vtemp83, __Vtemp80, __Vtemp82);
    VL_EXTEND_WQ(128,40, __Vtemp84, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out3);
    VL_SHIFTL_WWI(128,128,32, __Vtemp85, __Vtemp84, 0x18U);
    VL_ADD_W(4, __Vtemp86, __Vtemp83, __Vtemp85);
    vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out1 
        = ((1U == (3U & vlTOPp->macTestHarness__DOT__cfg[0U]))
            ? (IData)(((vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out0 
                        + (vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out1 
                           << 8U)) >> 0x20U)) : ((2U 
                                                  == 
                                                  (3U 
                                                   & vlTOPp->macTestHarness__DOT__cfg[0U]))
                                                  ? 
                                                 __Vtemp86[1U]
                                                  : (IData)(vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out1)));
}

void Vmac_test_harness::_eval(Vmac_test_harness__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmac_test_harness::_eval\n"); );
    Vmac_test_harness* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    if (((~ (IData)(vlTOPp->clk)) & (IData)(vlTOPp->__Vclklast__TOP__clk))) {
        vlTOPp->_sequent__TOP__1(vlSymsp);
    }
    if (((IData)(vlTOPp->clk) & (~ (IData)(vlTOPp->__Vclklast__TOP__clk)))) {
        vlTOPp->_sequent__TOP__2(vlSymsp);
        vlTOPp->__Vm_traceActivity[1U] = 1U;
    }
    // Final
    vlTOPp->__Vclklast__TOP__clk = vlTOPp->clk;
}

VL_INLINE_OPT QData Vmac_test_harness::_change_request(Vmac_test_harness__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmac_test_harness::_change_request\n"); );
    Vmac_test_harness* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    return (vlTOPp->_change_request_1(vlSymsp));
}

VL_INLINE_OPT QData Vmac_test_harness::_change_request_1(Vmac_test_harness__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmac_test_harness::_change_request_1\n"); );
    Vmac_test_harness* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // Change detection
    QData __req = false;  // Logically a bool
    return __req;
}

#ifdef VL_DEBUG
void Vmac_test_harness::_eval_debug_assertions() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmac_test_harness::_eval_debug_assertions\n"); );
    // Body
    if (VL_UNLIKELY((clk & 0xfeU))) {
        Verilated::overWidthError("clk");}
    if (VL_UNLIKELY((reset & 0xfeU))) {
        Verilated::overWidthError("reset");}
}
#endif  // VL_DEBUG
