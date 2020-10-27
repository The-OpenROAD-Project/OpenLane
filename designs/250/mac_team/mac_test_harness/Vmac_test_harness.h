// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Primary design header
//
// This header should be included by all source files instantiating the design.
// The class here is then constructed to instantiate the design.
// See the Verilator manual for examples.

#ifndef _VMAC_TEST_HARNESS_H_
#define _VMAC_TEST_HARNESS_H_  // guard

#include "verilated_heavy.h"

//==========

class Vmac_test_harness__Syms;
class Vmac_test_harness_VerilatedVcd;


//----------

VL_MODULE(Vmac_test_harness) {
  public:
    
    // PORTS
    // The application code writes and reads these signals to
    // propagate new values into/out from the Verilated model.
    VL_IN8(clk,0,0);
    VL_IN8(reset,0,0);
    
    // LOCAL SIGNALS
    // Internals; generally not touched by application code
    CData/*0:0*/ macTestHarness__DOT__r_reset;
    CData/*7:0*/ macTestHarness__DOT__A0;
    CData/*7:0*/ macTestHarness__DOT__B0;
    CData/*7:0*/ macTestHarness__DOT__A1;
    CData/*7:0*/ macTestHarness__DOT__B1;
    CData/*7:0*/ macTestHarness__DOT__A2;
    CData/*7:0*/ macTestHarness__DOT__B2;
    CData/*7:0*/ macTestHarness__DOT__A3;
    CData/*7:0*/ macTestHarness__DOT__B3;
    SData/*15:0*/ macTestHarness__DOT__dut__DOT__macmul0__DOT__A0B0;
    SData/*15:0*/ macTestHarness__DOT__dut__DOT__macmul0__DOT__A1B0;
    SData/*15:0*/ macTestHarness__DOT__dut__DOT__macmul1__DOT__A1B1;
    SData/*15:0*/ macTestHarness__DOT__dut__DOT__macmul1__DOT__A0B1;
    SData/*15:0*/ macTestHarness__DOT__dut__DOT__macmul2__DOT__A2B2;
    SData/*15:0*/ macTestHarness__DOT__dut__DOT__macmul2__DOT__A3B2;
    SData/*15:0*/ macTestHarness__DOT__dut__DOT__macmul3__DOT__A3B3;
    SData/*15:0*/ macTestHarness__DOT__dut__DOT__macmul3__DOT__A2B3;
    WData/*130:0*/ macTestHarness__DOT__cfg[5];
    IData/*31:0*/ macTestHarness__DOT__out0;
    IData/*31:0*/ macTestHarness__DOT__out1;
    IData/*31:0*/ macTestHarness__DOT__out2;
    IData/*31:0*/ macTestHarness__DOT__out3;
    IData/*31:0*/ macTestHarness__DOT__golden_out0;
    IData/*31:0*/ macTestHarness__DOT__golden_out1;
    IData/*31:0*/ macTestHarness__DOT__golden_out2;
    IData/*31:0*/ macTestHarness__DOT__golden_out3;
    IData/*31:0*/ macTestHarness__DOT__pipelined_golden_out0;
    IData/*31:0*/ macTestHarness__DOT__pipelined_golden_out1;
    IData/*31:0*/ macTestHarness__DOT__pipelined_golden_out2;
    IData/*31:0*/ macTestHarness__DOT__pipelined_golden_out3;
    IData/*31:0*/ macTestHarness__DOT__test;
    IData/*31:0*/ macTestHarness__DOT__num_tests;
    IData/*31:0*/ macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out0;
    IData/*31:0*/ macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out1;
    IData/*31:0*/ macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out2;
    IData/*31:0*/ macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out3;
    IData/*31:0*/ macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out0_reg;
    IData/*31:0*/ macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out1_reg;
    IData/*31:0*/ macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out2_reg;
    IData/*31:0*/ macTestHarness__DOT__dut__DOT__macacc__DOT__mult_only_out3_reg;
    IData/*31:0*/ macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out0;
    IData/*31:0*/ macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out1;
    IData/*31:0*/ macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out2;
    IData/*31:0*/ macTestHarness__DOT__dut__DOT__macacc__DOT__acc_out3;
    QData/*39:0*/ macTestHarness__DOT__dut__DOT__mac_mul_out0;
    QData/*39:0*/ macTestHarness__DOT__dut__DOT__mac_mul_out1;
    QData/*39:0*/ macTestHarness__DOT__dut__DOT__mac_mul_out2;
    QData/*39:0*/ macTestHarness__DOT__dut__DOT__mac_mul_out3;
    
    // LOCAL VARIABLES
    // Internals; generally not touched by application code
    CData/*0:0*/ __Vclklast__TOP__clk;
    CData/*0:0*/ __Vm_traceActivity[2];
    
    // INTERNAL VARIABLES
    // Internals; generally not touched by application code
    Vmac_test_harness__Syms* __VlSymsp;  // Symbol table
    
    // CONSTRUCTORS
  private:
    VL_UNCOPYABLE(Vmac_test_harness);  ///< Copying not allowed
  public:
    /// Construct the model; called by application code
    /// The special name  may be used to make a wrapper with a
    /// single model invisible with respect to DPI scope names.
    Vmac_test_harness(const char* name = "TOP");
    /// Destroy the model; called (often implicitly) by application code
    ~Vmac_test_harness();
    /// Trace signals in the model; called by application code
    void trace(VerilatedVcdC* tfp, int levels, int options = 0);
    
    // API METHODS
    /// Evaluate the model.  Application must call when inputs change.
    void eval() { eval_step(); }
    /// Evaluate when calling multiple units/models per time step.
    void eval_step();
    /// Evaluate at end of a timestep for tracing, when using eval_step().
    /// Application must call after all eval() and before time changes.
    void eval_end_step() {}
    /// Simulation complete, run final blocks.  Application must call on completion.
    void final();
    
    // INTERNAL METHODS
  private:
    static void _eval_initial_loop(Vmac_test_harness__Syms* __restrict vlSymsp);
  public:
    void __Vconfigure(Vmac_test_harness__Syms* symsp, bool first);
  private:
    static QData _change_request(Vmac_test_harness__Syms* __restrict vlSymsp);
    static QData _change_request_1(Vmac_test_harness__Syms* __restrict vlSymsp);
    void _ctor_var_reset() VL_ATTR_COLD;
  public:
    static void _eval(Vmac_test_harness__Syms* __restrict vlSymsp);
  private:
#ifdef VL_DEBUG
    void _eval_debug_assertions();
#endif  // VL_DEBUG
  public:
    static void _eval_initial(Vmac_test_harness__Syms* __restrict vlSymsp) VL_ATTR_COLD;
    static void _eval_settle(Vmac_test_harness__Syms* __restrict vlSymsp) VL_ATTR_COLD;
    static void _initial__TOP__3(Vmac_test_harness__Syms* __restrict vlSymsp) VL_ATTR_COLD;
    static void _sequent__TOP__1(Vmac_test_harness__Syms* __restrict vlSymsp);
    static void _sequent__TOP__2(Vmac_test_harness__Syms* __restrict vlSymsp);
    static void _settle__TOP__4(Vmac_test_harness__Syms* __restrict vlSymsp) VL_ATTR_COLD;
  private:
    static void traceChgSub0(void* userp, VerilatedVcd* tracep);
    static void traceChgTop0(void* userp, VerilatedVcd* tracep);
    static void traceCleanup(void* userp, VerilatedVcd* /*unused*/);
    static void traceFullSub0(void* userp, VerilatedVcd* tracep) VL_ATTR_COLD;
    static void traceFullTop0(void* userp, VerilatedVcd* tracep) VL_ATTR_COLD;
    static void traceInitSub0(void* userp, VerilatedVcd* tracep) VL_ATTR_COLD;
    static void traceInitTop(void* userp, VerilatedVcd* tracep) VL_ATTR_COLD;
    void traceRegister(VerilatedVcd* tracep) VL_ATTR_COLD;
    static void traceInit(void* userp, VerilatedVcd* tracep, uint32_t code) VL_ATTR_COLD;
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);

//----------


#endif  // guard
