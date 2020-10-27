#include <verilated.h>          // Defines common routines
#include <iostream>             // Need std::cout
#include "Vmac_test_harness.h"// From Verilating "riscv_test_harness.v"
#include "verilated_vcd_c.h"

using namespace std;
Vmac_test_harness *top;       // Instantiation of module
VerilatedVcdC   *m_trace;

vluint64_t main_time = 0;       // Current simulation time
// This is a 64-bit integer to reduce wrap over issues and
// allow modulus.  This is in units of the timeprecision
// used in Verilog (or from --timescale-override)

double sc_time_stamp () {       // Called by $time in Verilog
    return main_time;           // converts to double, to match
                                // what SystemC does
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);   // Remember args
    Verilated::traceEverOn(true);

    top = new Vmac_test_harness;        // Create instance

    if (!m_trace) {
        m_trace = new VerilatedVcdC;
        top->trace(m_trace, 99);
        m_trace->open("waves.vcd");
    }

    top->reset = 1;           // Set some inputs

    while (!Verilated::gotFinish()) {
        if (main_time > 10) {
            top->reset = 0;   // Deassert reset
        }
        if ((main_time % 10) == 1) {
            top->clk = 1;       // Toggle clock
        }
        if ((main_time % 10) == 6) {
            top->clk = 0;
        }
        top->eval();            // Evaluate model

        if (m_trace) {
            m_trace->dump(main_time);
            m_trace->flush();
        }
        main_time++;            // Time passes...
    }

    if (m_trace) {
        m_trace->close();
        m_trace = NULL;
    }

    top->final();               // Done simulating
    //    // (Though this example doesn't get here)
    delete top;
}