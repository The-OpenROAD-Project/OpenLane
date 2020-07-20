// file: RAM.v
// author: @tasneem_ismail

`timescale 1ns/1ns
module RAM(FFlag1, clk, rst, RW, Status,RegAddr, Data, Value, FFlag2);
		input [6:0] RegAddr; // address of reg should start from 16-->127
		input clk;
		input FFlag1;
		input [7:0] Status;//update status reg
		input RW; //if RW=1 -> write else read
		input [7:0] Data; //data to be written in selected reg
		output reg[7:0] Value; // value of the selected reg
		output reg FFlag2;
		input rst;
		reg [7:0] Mem [0:127];
		integer i;




		always @(posedge clk) begin

			if(!rst)begin
				for(i=0; i<128; i=i+1)  //initialize all regs to 0
						Mem[i]=8'b0;
			end
			else if(RW&&FFlag1)begin
				Mem[3]=Status;
				Mem[RegAddr]=Data;
				Value=8'b0;
				#20 FFlag2<=1;
			end
			else if(!RW&&FFlag1) begin
				Value=Mem[RegAddr];
				#20 FFlag2<=1;
			end

		end

	endmodule
