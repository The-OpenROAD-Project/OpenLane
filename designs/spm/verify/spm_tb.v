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

module spm_tb;
	localparam bits = 32;
	reg clk;
	reg rst;
	reg load;
	reg[bits-1:0] x;
	reg[bits-1:0] a;

	wire[bits-1:0] srx_value;
	sreg #(bits) srx(
		.clk(clk),
		.rst(rst),
		.direction(1'b1),
		.serial_msb(1'b0),
		.serial_lsb(1'b0),
		.load(load),
		.load_value(x),
		.value(srx_value)
	);

	wire y;
	wire [bits*2-1:0] y_value;
	sreg #(bits * 2) sry(
		.clk(clk),
		.rst(rst),
		.direction(1'b1),
		.serial_msb(y),
		.serial_lsb(1'b0),
		.load(1'b0),
		.load_value({(bits*2){1'b0}}),
		.value(y_value)
	);

	spm dut(
		.clk(clk),
		.rst(rst),
		.x(srx_value[0]),
		.a(a),
		.y(y)
	);

	always #1 clk = ~clk;

	reg [bits*2-1:0] expected;

	initial begin
		$dumpvars(0, spm_tb);
		for (integer i = 0; i < 20; i = i + 1) begin
			clk = 0;
			rst = 0;
			load = 0;
			x = $random;
			a = $random;
			expected = x * a;
			#2;
			load = 1;
			rst = 1;
			#2;
			load = 0;
			#2; // No useful bit at the first clock cycle
			#(bits * 2 * 2); // 2 * bits * clock cycle duration
			$display("%h * %h", x, a);
			$display("expected %h, got %h (%s)", expected, y_value, expected==y_value ? "ok " : "err");
		end
		$finish;
	end
endmodule

module sreg #(parameter width = 32) (
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
