// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vmac_test_harness.h for the primary calling header

#include "Vmac_test_harness.h"
#include "Vmac_test_harness__Syms.h"

//==========

VL_CTOR_IMP(Vmac_test_harness) {
    Vmac_test_harness__Syms* __restrict vlSymsp = __VlSymsp = new Vmac_test_harness__Syms(this, name());
    Vmac_test_harness* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Reset internal values
    
    // Reset structure values
    _ctor_var_reset();
}

void Vmac_test_harness::__Vconfigure(Vmac_test_harness__Syms* vlSymsp, bool first) {
    if (false && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
    if (false && this->__VlSymsp) {}  // Prevent unused
    Verilated::timeunit(-12);
    Verilated::timeprecision(-12);
}

Vmac_test_harness::~Vmac_test_harness() {
    VL_DO_CLEAR(delete __VlSymsp, __VlSymsp = nullptr);
}

void Vmac_test_harness::_initial__TOP__3(Vmac_test_harness__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmac_test_harness::_initial__TOP__3\n"); );
    Vmac_test_harness* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Variables
    WData/*95:0*/ __Vtemp87[3];
    // Body
    vlTOPp->macTestHarness__DOT__test = 1U;
    vlTOPp->macTestHarness__DOT__num_tests = 0xaU;
    vlTOPp->macTestHarness__DOT__cfg[0U] = 0U;
    vlTOPp->macTestHarness__DOT__cfg[1U] = 0U;
    vlTOPp->macTestHarness__DOT__cfg[2U] = 0U;
    vlTOPp->macTestHarness__DOT__cfg[3U] = 0U;
    vlTOPp->macTestHarness__DOT__cfg[4U] = 0U;
    (void)VL_VALUEPLUSARGS_INW(131,std::string("cfg=%d"),
                               vlTOPp->macTestHarness__DOT__cfg);__Vtemp87[0U] = 0x733d2564U;
    __Vtemp87[1U] = 0x74657374U;
    __Vtemp87[2U] = 0x6e756d5fU;
    (void)VL_VALUEPLUSARGS_INI(32,VL_CVT_PACK_STR_NW(3, __Vtemp87),
                               vlTOPp->macTestHarness__DOT__num_tests);vlTOPp->macTestHarness__DOT__golden_out0 = 0U;
    vlTOPp->macTestHarness__DOT__golden_out1 = 0U;
    vlTOPp->macTestHarness__DOT__golden_out2 = 0U;
    vlTOPp->macTestHarness__DOT__golden_out3 = 0U;
}

void Vmac_test_harness::_settle__TOP__4(Vmac_test_harness__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmac_test_harness::_settle__TOP__4\n"); );
    Vmac_test_harness* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Variables
    WData/*127:0*/ __Vtemp88[4];
    WData/*127:0*/ __Vtemp89[4];
    WData/*127:0*/ __Vtemp90[4];
    WData/*127:0*/ __Vtemp91[4];
    WData/*127:0*/ __Vtemp92[4];
    WData/*127:0*/ __Vtemp93[4];
    WData/*127:0*/ __Vtemp94[4];
    WData/*127:0*/ __Vtemp95[4];
    WData/*127:0*/ __Vtemp96[4];
    WData/*127:0*/ __Vtemp97[4];
    WData/*127:0*/ __Vtemp98[4];
    WData/*127:0*/ __Vtemp99[4];
    WData/*127:0*/ __Vtemp100[4];
    WData/*127:0*/ __Vtemp101[4];
    WData/*127:0*/ __Vtemp102[4];
    WData/*127:0*/ __Vtemp103[4];
    WData/*127:0*/ __Vtemp104[4];
    WData/*127:0*/ __Vtemp105[4];
    WData/*127:0*/ __Vtemp106[4];
    WData/*127:0*/ __Vtemp107[4];
    WData/*127:0*/ __Vtemp108[4];
    WData/*127:0*/ __Vtemp109[4];
    WData/*127:0*/ __Vtemp110[4];
    WData/*127:0*/ __Vtemp111[4];
    WData/*127:0*/ __Vtemp112[4];
    WData/*127:0*/ __Vtemp113[4];
    WData/*127:0*/ __Vtemp114[4];
    WData/*127:0*/ __Vtemp115[4];
    WData/*127:0*/ __Vtemp116[4];
    WData/*127:0*/ __Vtemp117[4];
    WData/*127:0*/ __Vtemp118[4];
    WData/*127:0*/ __Vtemp119[4];
    WData/*127:0*/ __Vtemp120[4];
    WData/*127:0*/ __Vtemp121[4];
    WData/*127:0*/ __Vtemp122[4];
    WData/*127:0*/ __Vtemp123[4];
    WData/*127:0*/ __Vtemp124[4];
    // Body
    vlTOPp->macTestHarness__DOT__dut__DOT__macmul0__DOT__A0B0 
        = (0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A0) 
                      * (IData)(vlTOPp->macTestHarness__DOT__B0)));
    vlTOPp->macTestHarness__DOT__dut__DOT__macmul0__DOT__A1B0 
        = (0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A1) 
                      * (IData)(vlTOPp->macTestHarness__DOT__B0)));
    vlTOPp->macTestHarness__DOT__dut__DOT__macmul1__DOT__A1B1 
        = (0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A1) 
                      * (IData)(vlTOPp->macTestHarness__DOT__B1)));
    vlTOPp->macTestHarness__DOT__dut__DOT__macmul1__DOT__A0B1 
        = (0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A0) 
                      * (IData)(vlTOPp->macTestHarness__DOT__B1)));
    vlTOPp->macTestHarness__DOT__dut__DOT__macmul2__DOT__A2B2 
        = (0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A2) 
                      * (IData)(vlTOPp->macTestHarness__DOT__B2)));
    vlTOPp->macTestHarness__DOT__dut__DOT__macmul2__DOT__A3B2 
        = (0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A3) 
                      * (IData)(vlTOPp->macTestHarness__DOT__B2)));
    vlTOPp->macTestHarness__DOT__dut__DOT__macmul3__DOT__A3B3 
        = (0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A3) 
                      * (IData)(vlTOPp->macTestHarness__DOT__B3)));
    vlTOPp->macTestHarness__DOT__dut__DOT__macmul3__DOT__A2B3 
        = (0xffffU & ((IData)(vlTOPp->macTestHarness__DOT__A2) 
                      * (IData)(vlTOPp->macTestHarness__DOT__B3)));
    if ((4U & vlTOPp->macTestHarness__DOT__cfg[0U])) {
        vlTOPp->macTestHarness__DOT__out0 = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out0;
        vlTOPp->macTestHarness__DOT__out1 = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out1;
        vlTOPp->macTestHarness__DOT__out2 = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out2;
        vlTOPp->macTestHarness__DOT__out3 = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out3;
    } else {
        vlTOPp->macTestHarness__DOT__out0 = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out0_reg;
        vlTOPp->macTestHarness__DOT__out1 = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out1_reg;
        vlTOPp->macTestHarness__DOT__out2 = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out2_reg;
        vlTOPp->macTestHarness__DOT__out3 = vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out3_reg;
    }
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
    VL_EXTEND_WQ(128,40, __Vtemp88, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out0);
    VL_EXTEND_WQ(128,40, __Vtemp89, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out1);
    VL_SHIFTL_WWI(128,128,32, __Vtemp90, __Vtemp89, 8U);
    VL_ADD_W(4, __Vtemp91, __Vtemp88, __Vtemp90);
    VL_EXTEND_WQ(128,40, __Vtemp92, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out2);
    VL_SHIFTL_WWI(128,128,32, __Vtemp93, __Vtemp92, 0x10U);
    VL_ADD_W(4, __Vtemp94, __Vtemp91, __Vtemp93);
    VL_EXTEND_WQ(128,40, __Vtemp95, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out3);
    VL_SHIFTL_WWI(128,128,32, __Vtemp96, __Vtemp95, 0x18U);
    VL_ADD_W(4, __Vtemp97, __Vtemp94, __Vtemp96);
    vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out3 
        = ((1U == (3U & vlTOPp->macTestHarness__DOT__cfg[0U]))
            ? (IData)(((vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out2 
                        + (vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out3 
                           << 8U)) >> 0x20U)) : ((2U 
                                                  == 
                                                  (3U 
                                                   & vlTOPp->macTestHarness__DOT__cfg[0U]))
                                                  ? 
                                                 __Vtemp97[3U]
                                                  : (IData)(vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out3)));
    VL_EXTEND_WQ(128,40, __Vtemp98, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out0);
    VL_EXTEND_WQ(128,40, __Vtemp99, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out1);
    VL_SHIFTL_WWI(128,128,32, __Vtemp100, __Vtemp99, 8U);
    VL_EXTEND_WQ(128,40, __Vtemp101, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out2);
    VL_SHIFTL_WWI(128,128,32, __Vtemp102, __Vtemp101, 0x10U);
    VL_EXTEND_WQ(128,40, __Vtemp103, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out3);
    VL_SHIFTL_WWI(128,128,32, __Vtemp104, __Vtemp103, 0x18U);
    vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out0 
        = ((1U == (3U & vlTOPp->macTestHarness__DOT__cfg[0U]))
            ? ((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out0) 
               + (IData)((vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out1 
                          << 8U))) : ((2U == (3U & 
                                              vlTOPp->macTestHarness__DOT__cfg[0U]))
                                       ? (((__Vtemp98[0U] 
                                            + __Vtemp100[0U]) 
                                           + __Vtemp102[0U]) 
                                          + __Vtemp104[0U])
                                       : (IData)(vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out0)));
    VL_EXTEND_WQ(128,40, __Vtemp105, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out0);
    VL_EXTEND_WQ(128,40, __Vtemp106, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out1);
    VL_SHIFTL_WWI(128,128,32, __Vtemp107, __Vtemp106, 8U);
    VL_ADD_W(4, __Vtemp108, __Vtemp105, __Vtemp107);
    VL_EXTEND_WQ(128,40, __Vtemp109, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out2);
    VL_SHIFTL_WWI(128,128,32, __Vtemp110, __Vtemp109, 0x10U);
    VL_ADD_W(4, __Vtemp111, __Vtemp108, __Vtemp110);
    VL_EXTEND_WQ(128,40, __Vtemp112, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out3);
    VL_SHIFTL_WWI(128,128,32, __Vtemp113, __Vtemp112, 0x18U);
    VL_ADD_W(4, __Vtemp114, __Vtemp111, __Vtemp113);
    vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out2 
        = ((1U == (3U & vlTOPp->macTestHarness__DOT__cfg[0U]))
            ? ((IData)(vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out2) 
               + (IData)((vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out3 
                          << 8U))) : ((2U == (3U & 
                                              vlTOPp->macTestHarness__DOT__cfg[0U]))
                                       ? __Vtemp114[2U]
                                       : (IData)(vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out2)));
    VL_EXTEND_WQ(128,40, __Vtemp115, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out0);
    VL_EXTEND_WQ(128,40, __Vtemp116, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out1);
    VL_SHIFTL_WWI(128,128,32, __Vtemp117, __Vtemp116, 8U);
    VL_ADD_W(4, __Vtemp118, __Vtemp115, __Vtemp117);
    VL_EXTEND_WQ(128,40, __Vtemp119, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out2);
    VL_SHIFTL_WWI(128,128,32, __Vtemp120, __Vtemp119, 0x10U);
    VL_ADD_W(4, __Vtemp121, __Vtemp118, __Vtemp120);
    VL_EXTEND_WQ(128,40, __Vtemp122, vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out3);
    VL_SHIFTL_WWI(128,128,32, __Vtemp123, __Vtemp122, 0x18U);
    VL_ADD_W(4, __Vtemp124, __Vtemp121, __Vtemp123);
    vlTOPp->macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out1 
        = ((1U == (3U & vlTOPp->macTestHarness__DOT__cfg[0U]))
            ? (IData)(((vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out0 
                        + (vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out1 
                           << 8U)) >> 0x20U)) : ((2U 
                                                  == 
                                                  (3U 
                                                   & vlTOPp->macTestHarness__DOT__cfg[0U]))
                                                  ? 
                                                 __Vtemp124[1U]
                                                  : (IData)(vlTOPp->macTestHarness__DOT__dut__DOT__mac_mul_out1)));
}

void Vmac_test_harness::_eval_initial(Vmac_test_harness__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmac_test_harness::_eval_initial\n"); );
    Vmac_test_harness* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->__Vclklast__TOP__clk = vlTOPp->clk;
    vlTOPp->_initial__TOP__3(vlSymsp);
    vlTOPp->__Vm_traceActivity[1U] = 1U;
    vlTOPp->__Vm_traceActivity[0U] = 1U;
}

void Vmac_test_harness::final() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmac_test_harness::final\n"); );
    // Variables
    Vmac_test_harness__Syms* __restrict vlSymsp = this->__VlSymsp;
    Vmac_test_harness* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void Vmac_test_harness::_eval_settle(Vmac_test_harness__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmac_test_harness::_eval_settle\n"); );
    Vmac_test_harness* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->_settle__TOP__4(vlSymsp);
    vlTOPp->__Vm_traceActivity[1U] = 1U;
    vlTOPp->__Vm_traceActivity[0U] = 1U;
}

void Vmac_test_harness::_ctor_var_reset() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vmac_test_harness::_ctor_var_reset\n"); );
    // Body
    clk = VL_RAND_RESET_I(1);
    reset = VL_RAND_RESET_I(1);
    macTestHarness__DOT__r_reset = VL_RAND_RESET_I(1);
    macTestHarness__DOT__A0 = VL_RAND_RESET_I(8);
    macTestHarness__DOT__B0 = VL_RAND_RESET_I(8);
    macTestHarness__DOT__A1 = VL_RAND_RESET_I(8);
    macTestHarness__DOT__B1 = VL_RAND_RESET_I(8);
    macTestHarness__DOT__A2 = VL_RAND_RESET_I(8);
    macTestHarness__DOT__B2 = VL_RAND_RESET_I(8);
    macTestHarness__DOT__A3 = VL_RAND_RESET_I(8);
    macTestHarness__DOT__B3 = VL_RAND_RESET_I(8);
    VL_RAND_RESET_W(131, macTestHarness__DOT__cfg);
    macTestHarness__DOT__out0 = VL_RAND_RESET_I(32);
    macTestHarness__DOT__out1 = VL_RAND_RESET_I(32);
    macTestHarness__DOT__out2 = VL_RAND_RESET_I(32);
    macTestHarness__DOT__out3 = VL_RAND_RESET_I(32);
    macTestHarness__DOT__golden_out0 = VL_RAND_RESET_I(32);
    macTestHarness__DOT__golden_out1 = VL_RAND_RESET_I(32);
    macTestHarness__DOT__golden_out2 = VL_RAND_RESET_I(32);
    macTestHarness__DOT__golden_out3 = VL_RAND_RESET_I(32);
    macTestHarness__DOT__pipelined_golden_out0 = VL_RAND_RESET_I(32);
    macTestHarness__DOT__pipelined_golden_out1 = VL_RAND_RESET_I(32);
    macTestHarness__DOT__pipelined_golden_out2 = VL_RAND_RESET_I(32);
    macTestHarness__DOT__pipelined_golden_out3 = VL_RAND_RESET_I(32);
    macTestHarness__DOT__test = VL_RAND_RESET_I(32);
    macTestHarness__DOT__num_tests = VL_RAND_RESET_I(32);
    macTestHarness__DOT__dut__DOT__mac_mul_out0 = VL_RAND_RESET_Q(40);
    macTestHarness__DOT__dut__DOT__mac_mul_out1 = VL_RAND_RESET_Q(40);
    macTestHarness__DOT__dut__DOT__mac_mul_out2 = VL_RAND_RESET_Q(40);
    macTestHarness__DOT__dut__DOT__mac_mul_out3 = VL_RAND_RESET_Q(40);
    macTestHarness__DOT__dut__DOT__macmul0__DOT__A0B0 = VL_RAND_RESET_I(16);
    macTestHarness__DOT__dut__DOT__macmul0__DOT__A1B0 = VL_RAND_RESET_I(16);
    macTestHarness__DOT__dut__DOT__macmul1__DOT__A1B1 = VL_RAND_RESET_I(16);
    macTestHarness__DOT__dut__DOT__macmul1__DOT__A0B1 = VL_RAND_RESET_I(16);
    macTestHarness__DOT__dut__DOT__macmul2__DOT__A2B2 = VL_RAND_RESET_I(16);
    macTestHarness__DOT__dut__DOT__macmul2__DOT__A3B2 = VL_RAND_RESET_I(16);
    macTestHarness__DOT__dut__DOT__macmul3__DOT__A3B3 = VL_RAND_RESET_I(16);
    macTestHarness__DOT__dut__DOT__macmul3__DOT__A2B3 = VL_RAND_RESET_I(16);
    macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out0 = VL_RAND_RESET_I(32);
    macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out1 = VL_RAND_RESET_I(32);
    macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out2 = VL_RAND_RESET_I(32);
    macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out3 = VL_RAND_RESET_I(32);
    macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out0_reg = VL_RAND_RESET_I(32);
    macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out1_reg = VL_RAND_RESET_I(32);
    macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out2_reg = VL_RAND_RESET_I(32);
    macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out3_reg = VL_RAND_RESET_I(32);
    macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out0 = VL_RAND_RESET_I(32);
    macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out1 = VL_RAND_RESET_I(32);
    macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out2 = VL_RAND_RESET_I(32);
    macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out3 = VL_RAND_RESET_I(32);
    { int __Vi0=0; for (; __Vi0<2; ++__Vi0) {
            __Vm_traceActivity[__Vi0] = VL_RAND_RESET_I(1);
    }}
}
