// Copyright 2023 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// (Parameterized) Unsigned Serial/Parallel Multiplier:
// - Multiplicand x (Input bit-serially)
// - Multiplier a (All bits at the same time/Parallel)
// - Product y (Output bit-serial)
module spm #(parameter bits=32) (
    input clk,
    input rst,
    input x,
    input[bits-1: 0] a,
    output y
);
    wire[bits: 0] y_chain;
    assign y_chain[0] = 0;
    assign y = y_chain[bits];

    wire[bits-1:0] a_flip;
    generate 
        for (genvar i = 0; i < bits; i = i + 1) begin : flip_block
            assign a_flip[i] = a[bits - i - 1];
        end 
    endgenerate

    DelayedSerialAdder dsa[bits-1:0](
        .clk(clk),
        .rst(rst),
        .x(x),
        .a(a_flip),
        .y_in(y_chain[bits-1:0]),
        .y_out(y_chain[bits:1])
    );

endmodule

module DelayedSerialAdder(
    input clk,
    input rst,
    input x,
    input a,
    input y_in,
    output reg y_out
);
    reg lastCarry;
    wire lastCarry_next;
    wire y_out_next;

    wire g = x & a;
    assign {lastCarry_next, y_out_next} = g + y_in + lastCarry;

    always @ (posedge clk or negedge rst) begin
        if (!rst) begin
            lastCarry <= 1'b0;
            y_out <= 1'b0;
        end else begin
            lastCarry <= lastCarry_next;
            y_out <= y_out_next;
        end
    end
endmodule

// Not part of the SPM but pretty much required when using it in another design
module ShiftRegister #(parameter width = 32) (
    input clk,
    input rst,
    input direction, // 0 -> load from lsb side; 1 -> load from msb side
    input serial_msb,
    input serial_lsb,
    input load,
    input[width-1:0] load_value,
    output[width-1:0] value
);
    reg[width-1:0] store;

    assign value = store;

    always @ (posedge clk or negedge rst) begin
        if (!rst) begin
            store <= {(width){1'b0}};
        end else begin
            store <= load ? load_value  :
                            direction   ?   {serial_msb, store[width-1:1]}:
                                            {store[width-2:0], serial_lsb};
        end
    end
endmodule