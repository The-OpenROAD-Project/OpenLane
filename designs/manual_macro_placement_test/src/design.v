`default_nettype none
// Copyright 2020 Efabless Corporation
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

module manual_macro_placement_test(
    clk1,
    clk2,
    rst1,
    rst2,
    x1,
    x2,
    y1,
    y2,
    p1,
    p2
);
    parameter size = 32;
    input clk1, rst1;
    input clk2, rst2;
    input y1;
    input y2;
    input[size-1:0] x1;
    input[size-1:0] x2;
    output p1;
    output p2;

    spm spm_inst_0 (.clk(clk1), .rst(rst1), .x(x1), .y(y1), .p(p1));
    spm spm_inst_1 (.clk(clk2), .rst(rst2), .x(x2), .y(y2), .p(p2));
endmodule

(* blackbox *)
module spm(clk, rst, x, y, p);
    parameter size = 32;
    input clk, rst;
    input y;
    input[size-1:0] x;
    output p;
endmodule
