// file: InsMem.v
// author: @tasneem_ismail

`timescale 1ns/1ns
module InsMem(FFlag3, clk,rst, PC, Ins, FFlag1);
input clk;
input FFlag3;
input rst;
input [7:0]PC;
output reg[13:0]Ins;
output reg FFlag1;
reg [13:0] Mem [0:255];
 
always @(posedge clk)begin

	if(!rst)begin
	 Mem[0]=14'b00011110001000;//ADDWF d->1  reg[16]
	 Mem[1]=14'b00011100001001;//ADDWF d->0  reg[17]
	 Mem[2]=14'b00001010001010;//SUBWF d->1  reg[18]
	 Mem[3]=14'b00001000001011;//SUBWF d->0  reg[19]
	 Mem[4]=14'b00001000001100;//DECF d->1  reg[20]
	 Mem[5]=14'b00001100001101;//DECF d->0  reg[21]
	 Mem[6]=14'b00010110001000;//ANDWF d->1 reg[16]
	 Mem[7]=14'b00101000001001;//INCF d->0 reg[17]
	 Mem[8]=14'b00010010001010;//IORWF d->1 reg[18]
	 Mem[9]=14'b00100100001011;//COMF d->0 reg[19]
	 Mem[10]=14'b00011010001100;//XORWF d->1 reg[20]
	////////////////////////////////////////////////////
	 Mem[11]=14'b01001110001000;//BCF b->7  reg[16]
	 Mem[12]=14'b01000110001001;//BCF b->2  reg[17]
	 Mem[13]=14'b01010110001010;//BSF b->3  reg[18]
	 Mem[14]=14'b01010100001011;//BSF b->2  reg[20]
	////////////////////////////////////////////////////
	 Mem[15]=14'b11111100001111;//ADDLW K=00001111
	 Mem[16]=14'b11100100001000;//ANDLW K=00001000
	 Mem[17]=14'b11100000000001;//IORLW K=00000001
	 Mem[18]=14'b11110100000010;//SUBLW K=00000010
	 Mem[19]=14'b11101000000100;//XORLW K=00000100
	////////////////////////////////////////////////////
	end
	else if(FFlag3) begin
		Ins<=Mem[PC%20];
		#20 FFlag1<=1;
	end
	
end
endmodule
