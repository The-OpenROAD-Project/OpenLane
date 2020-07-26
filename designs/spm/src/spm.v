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

module spm(clk, rst, x, y, p);
    parameter size = 32;
    input clk, rst;
    input y;
    input[size-1:0] x;
    output p;

    wire[size-1:1] pp;
    wire[size-1:0] xy;

    genvar i;

    CSADD csa0 (.clk(clk), .rst(rst), .x(x[0]&y), .y(pp[1]), .sum(p));
    generate for(i=1; i<size-1; i=i+1) begin
        CSADD csa (.clk(clk), .rst(rst), .x(x[i]&y), .y(pp[i+1]), .sum(pp[i]));
    end endgenerate
    TCMP tcmp (.clk(clk), .rst(rst), .a(x[size-1]&y), .s(pp[size-1]));

endmodule

module TCMP(clk, rst, a, s);
    input clk, rst;
    input a;
    output reg s;

    reg z;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            //Reset logic goes here.
            s <= 1'b0;
            z <= 1'b0;
        end
        else begin
            //Sequential logic goes here.
            z <= a | z;
            s <= a ^ z;
        end
    end
endmodule

module CSADD(clk, rst, x, y, sum);
    input clk, rst;
    input x, y;
    output reg sum;

    reg sc;

    // Half Adders logic
    wire hsum1, hco1;
    assign hsum1 = y ^ sc;
    assign hco1 = y & sc;

    wire hsum2, hco2;
    assign hsum2 = x ^ hsum1;
    assign hco2 = x & hsum1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            //Reset logic goes here.
            sum <= 1'b0;
            sc <= 1'b0;
        end
        else begin
            //Sequential logic goes here.
            sum <= hsum2;
            sc <= hco1 ^ hco2;
        end
    end
endmodule


/*

module spm_tb;

	//Inputs
	reg clk;
	reg rst;
	reg [7: 0] x;

    reg[7:0] Y;
    reg[15:0] P;

	//Outputs
	wire p;

    reg[3:0] cnt;

	//Instantiation of Unit Under Test
	spm #(8) uut (
		.clk(clk),
		.rst(rst),
		.y(Y[0]),
		.x(x),
		.p(p)
	);

    always #5 clk = ~clk;

    always @ (posedge clk)
        if(rst) Y = -50;
        else Y <= {1'b0,Y[7:1]};

    always @ (posedge clk)
        if(rst) P = 0;
        else P <= {p, P[15:1]};

	always @ (posedge clk)
        if(rst) cnt = 0;
        else cnt <= cnt + 1;

	initial begin
	//Inputs initialization
		clk = 0;
		rst = 0;
		x = 50;

	//Reset
		#20 rst = 1;
		#20 rst = 0;
        #1000;
        $finish;
	end

endmodule
*/
