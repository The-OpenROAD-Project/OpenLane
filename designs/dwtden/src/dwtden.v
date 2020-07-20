//********************************************************* 
// IEEE STD 1364-2001 Verilog file: dwtden.v
// Author-EMAIL: Uwe.Meyer-Baese@ieee.org 
//********************************************************* 
module dwtden
  #(parameter D1L = 28, //D1 buffer length
              D2L = 10) // D2 buffer length
    (input clk,
     input reset,
     input signed [15:0] x_in,
     input signed [15:0] t4d1, t4d2, t4d3, t4a3,// Thresholds
      output signed [15:0] d1_out, // Level 1 detail
      output signed [15:0] a1_out, // Level 1 approximation 
      output signed [15:0] d2_out, // Level 2 detail
      output signed [15:0] a2_out, // Level 2 approximation 
      output signed [15:0] d3_out, // Level 3 detail
      output signed [15:0] a3_out, // Level 3 approximation 
      // Debug signals:
      output signed [15:0] s3_out, a3up_out, d3up_out, // L3 
      output signed [15:0] s2_out, s3up_out, d2up_out, // L2 
      output signed [15:0] s1_out, s2up_out, d1up_out, // L1 
      output signed [15:0] y_out,

      output ena1_out,
      output ena2_out,
      output ena3_out

      ); // System output
// --------------------------------------------------------
  reg [2:0] count; // Cycle 2**max level
  reg signed [15:0] x, xd; // Input delays
  reg signed [15:0] a1, a2 ; // Analysis filter

  wire signed [15:0] d1, d2, a3, d3 ; // Analysis filter
  reg signed [15:0] d1t, d2t, d3t, a3t ;
// Before thresholding 
wire signed [15:0] abs_d1t, abs_d2t, abs_d3t, abs_a3t ;
                                         // Absolute values
  reg signed [15:0] a1up, a3up, d3up ;
  reg signed [15:0] a1upd, s3upd, a3upd, d3upd ;
  reg signed [15:0] a1d, a2d; // Delay filter output 
  reg ena1, ena2, ena3; // Clock enables
  reg t1, t2, t3; // Toggle flip-flops
  reg signed [15:0] s2, s3up, s3, d2syn ;
  reg signed [15:0] s1, s2up, s2upd ;
  // Delay lines for d1 and d2
  reg signed [15:0] d2upd [0:11];
  reg signed [15:0] d1upd [0:29];

  always @(posedge reset or posedge clk) // Control the
  begin : FSM                  // system sample at clk rate
    if (reset) begin             // Asynchronous reset
      count <= 0; ena1 <= 0; ena2 <= 0; ena3 <= 0;
    end 
    else begin
      if (count == 7) 
        count <= 0;
      else           
        count <= count + 1;
      
      case (count)     // Level 1 enable
        3'b001  : ena1 <= 1;
        3'b011  : ena1 <= 1;
        3'b101  : ena1 <= 1;
        3'b111  : ena1 <= 1;
        default : ena1 <= 0;
      endcase
      
      case (count)  // Level 2 enable
        3'b001  : ena2 <= 1;
        3'b101  : ena2 <= 1;
        default : ena2 <= 0;
      endcase
      
      case (count)   // Level 3 enable
        3'b101  : ena3 <= 1;
        default : ena3 <= 0;
      endcase
end end
//  Haar analysis filter bank
  always @(posedge reset or posedge clk)

  begin : Analysis
    if (reset) begin          // Asynchronous clear
      x <= 0; xd <= 0; d1t <= 0; a1 <= 0; a1d <= 0;
      d2t <= 0; a2 <= 0; a2d <= 0; d3t <= 0; a3t <= 0;
    end else begin
x <= x_in;
xd <= x;
if (ena1) begin // Level 1 analysis
d1t <= x - xd; a1 <=x+xd; a1d <= a1;
      end
      if (ena2) begin  // Level 2 analysis
d2t <= a1 - a1d; a2 <= a1 + a1d; a2d <= a2;
      end
      if (ena3) begin  // Level 3 analysis
d3t <= a2 - a2d;
        a3t <= a2 + a2d;
      end
end end
// Take absolute values first
assign abs_d1t = (d1t>=0)? d1t : -d1t; 
assign abs_d2t = (d2t>=0)? d2t : -d2t; 
assign abs_d3t = (d3t>=0)? d3t : -d3t; 
assign abs_a3t = (a3t>=0)? a3t : -a3t;
// Thresholding of d1, d2, d3 and a3 
assign d1 = (abs_d1t > t4d1)? d1t : 0; 
assign d2 = (abs_d2t > t4d2)? d2t : 0; 
assign d3 = (abs_d3t > t4d3)? d3t : 0; 
assign a3 = (abs_a3t > t4a3)? a3t : 0;
// Down followed by up sampling is implemented by setting // every 2. value to zero
  always @(posedge reset or posedge clk)
  begin : Synthesis
    integer k;    // Loop variable
    if (reset) begin          // Asynchronous clear
      t1 <= 0; t2 <= 0; t3 <= 0;
      s3up <= 0;s3upd <= 0;
      d3up <= 0; a3up <= 0; a3upd<=0; d3upd <= 0;
      s3 <= 0; s2 <= 0;
      s1 <= 0; s2up <= 0; s2upd <= 0;
  
      for (k=0; k<=D2L+1; k=k+1) // delay to match s3up
        d2upd[k] <= 0;
  
      for (k=0; k<=D1L+1; k=k+1) // delay to match s2up
        d1upd[k] <= 0;
  end 
  else begin
    t1 <= ~t1; // toggle FF level 1 
    if (t1) begin
    d1upd[0] <= d1;
    s2up <= s2;
  end else begin
    d1upd[0] <= 0;
    s2up <= 0; 
  end
  s2upd <= s2up;
  for (k=1; k<=D1L+1; k=k+1) // Delay to match s2up
    d1upd[k] <= d1upd[k-1];
  s1 <= (s2up + s2upd -d1upd[D1L] +d1upd[D1L+1]) >>> 1; if (ena1) begin
  t2 <= ~t2; // toggle FF level 2 
  if (t2) begin
      d2upd[0] <= d2;
      s3up <= s3;
    end else begin
      d2upd[0] <= 0;
s3up <= 0; end
    s3upd <= s3up;
    for (k=1; k<=D2L+1; k=k+1) // Delay to match s3up
d2upd[k] <= d2upd[k-1];
s2 <= (s3up +s3upd -d2upd[D2L] +d2upd[D2L+1])>>> 1;
end
if (ena2) begin // Synthesis level 3 
t3 <= ~t3; // toggle FF
if (t3) begin
d3up <= d3;
      a3up <= a3;
    end else begin
d3up <= 0;
a3up <= 0; end

a3upd <= a3up;
d3upd <= d3up;
s3 <= (a3up + a3upd - d3up + d3upd) >>> 1;
end end
end
    assign a1_out = a1;// Provide some test signal as outputs 
    assign d1_out = d1;
    assign a2_out = a2;
    assign d2_out = d2;
    assign a3_out = a3;
    assign d3_out = d3;
    assign a3up_out = a3up; 
    assign d3up_out = d3up; 
    assign s3_out = s3;
    assign s3up_out = s3up; 
    assign d2up_out = d2upd[D2L]; 
    assign s2_out = s2;
    assign s1_out = s1;
    assign s2up_out = s2up; 
    assign d1up_out = d1upd[D1L]; 
    assign y_out = s1;
    assign ena1_out = ena1; 
    assign ena2_out = ena2; 
    assign ena3_out = ena3;

endmodule

