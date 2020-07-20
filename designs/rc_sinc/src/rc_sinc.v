//*********************************************************
// IEEE STD 1364-2001 Verilog file: rc_sinc.v
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org
//*********************************************************
module rc_sinc #(parameter OL = 2, //Output buffer length-1
IL = 3, //Input buffer length -1
L = 10) // Filter length -1
(input clk, // System clock
input reset, // Asynchronous reset
input signed [7:0] x_in, // System input
output [3:0] count_o, // Counter FSM
output ena_in_o, // Sample input enable
output ena_out_o, // Shift output enable
output ena_io_o, // Enable transfer2output
output signed [8:0] f0_o, // First Sinc filter output
output signed [8:0] f1_o, // Second Sinc filter output
output signed [8:0] f2_o, // Third Sinc filter output
output signed [8:0] y_out);// System output
// --------------------------------------------------------
reg [3:0] count; // Cycle R_1*R_2
reg ena_in, ena_out, ena_io; // FSM enables
reg signed [7:0] x [0:10]; // TAP registers for 3 filters
reg signed [7:0] ibuf [0:3]; // TAP in registers
reg signed [7:0] obuf [0:2]; // TAP out registers
reg signed [8:0] f0, f1, f2; // Filter outputs
// Constant arrays for multiplier and taps:
wire signed [8:0] c0 [0:10];
wire signed [8:0] c2 [0:10];

// filter coefficients for filter c0
assign c0[0] = -19; assign c0[1] = 26; assign c0[2]=-42;
assign c0[3] = 106; assign c0[4] = 212; assign c0[5]=-53;
assign c0[6] = 29; assign c0[7] = -21; assign c0[8]=16;
assign c0[9] = -13; assign c0[10] = 11;
// filter coefficients for filter c2
assign c2[0] = 11; assign c2[1] = -13;assign c2[2] = 16;
assign c2[3] = -21;assign c2[4] = 29; assign c2[5] = -53;
assign c2[6] = 212;assign c2[7] = 106;assign c2[8] = -42;
assign c2[9] = 26; assign c2[10] = -19;
always @(posedge reset or posedge clk)
begin : FSM // Control the system and sample at clk rate
if (reset) // Asynchronous reset
count <= 0;
else
if (count == 11) count <= 0;
else count <= count + 1;
end
always @(posedge clk)
begin // set the enable signal for the TAP lines
case (count)
2, 5, 8, 11 : ena_in <= 1;
default : ena_in <= 0;
endcase
case (count)
4, 8 : ena_out <= 1;
default : ena_out <= 0;
endcase
if (count == 0) ena_io <= 1;
else ena_io <= 0;
end
always @(posedge clk or posedge reset)// Input delay line
begin : INPUTMUX
integer I; // loop variable
if (reset) // Asynchronous clear
for (I=0; I<=IL; I=I+1) ibuf[I] <= 0;
else if (ena_in) begin

for (I=IL; I>=1; I=I-1)
ibuf[I] <= ibuf[I-1]; // shift one
ibuf[0] <= x_in; // Input in register 0
end
end
always @(posedge clk or posedge reset)//Output delay line
begin : OUPUTMUX
integer I; // loop variable
if (reset) // Asynchronous clear
for (I=0; I<=OL; I=I+1) obuf[I] <= 0;
else begin
if (ena_io) begin // store 3 samples in output buffer
obuf[0] <= f0;
obuf[1] <= f1;
obuf[2] <= f2;
end else if (ena_out) begin
for (I=OL; I>=1; I=I-1)
obuf[I] <= obuf[I-1]; // shift one
end
end
end
always @(posedge clk or posedge reset)
begin : TAP // get 4 samples at one time
integer I; // loop variable
if (reset) // Asynchronous clear
for (I=0; I<=10; I=I+1) x[I] <= 0;
else if (ena_io) begin // One tapped delay line
for (I=0; I<=3; I=I+1)
x[I] <= ibuf[I]; // take over input buffer
for (I=4; I<=10; I=I+1) // 0->4; 4->8 etc.
x[I] <= x[I-4]; // shift 4 taps
end
end
always @(posedge clk)
begin : SOP0 // Compute sum-of-products for f0
reg signed [16:0] sum; // temp sum
reg signed [16:0] p [0:10]; // temp products
integer I;
for (I=0; I<=L; I=I+1) // Infer L+1 multiplier
p[I] = c0[I] * x[I];
sum = p[0];
for (I=1; I<=L; I=I+1) // Compute the direct
sum = sum + p[I]; // filter adds
if (reset) f0 <= 0; // Asynchronous clear
else f0 <= sum >>> 8;
end
always @(posedge clk)
begin : SOP1 // Compute sum-of-products for f1
if (reset) f1 <= 0; // Asynchronous clear
else f1 <= x[5]; // No scaling, i.e., unit inpulse
end
always @(posedge clk) // Compute sum-of-products for f2
begin : SOP2
reg signed[16:0] sum; // temp sum
reg signed [16:0] p [0:10]; // temp products
integer I;
for (I=0; I<=L; I=I+1) // Infer L+1 multiplier
p[I] = c2[I] * x[I];
sum = p[0];
for (I=1; I<=L; I=I+1) // Compute the direct
sum = sum + p[I]; // filter adds
if (reset) f2 <= 0; // Asynchronous clear
else f2 <= sum >>> 8;
end
// Provide some test signals as outputs
assign f0_o = f0;
assign f1_o = f1;
assign f2_o = f2;
assign count_o = count;
assign ena_in_o = ena_in;
assign ena_out_o = ena_out;
assign ena_io_o = ena_io;
assign y_out = obuf[OL]; // Connect to output
endmodule