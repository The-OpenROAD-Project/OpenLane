// UC Berkeley CS251
// Spring 2018
// Arya Reais-Parsi (aryap@berkeley.edu)

// Stage #3: Write-back unit.

`include "const.vh"

module WriteBackStage #(

)(
  input clk, reset,
  input wire [2:0] s3_rdata_sel,
  input wire [1:0] byte_select,

  input wire [`CPU_DATA_BITS-1:0] s3_rdata,
  output reg [`CPU_DATA_BITS-1:0] s3_rdata_out
);

  // TODO(aryap): This is because I don't want to understand Verilog's
  // signed/unsigned operator semantics. There's probably an easier way...
  localparam BYTE_SIGN_BITS = `CPU_DATA_BITS - 8;
  localparam HALF_WORD_SIGN_BITS = `CPU_DATA_BITS - 16;


  wire [31:0] byteX =
    (s3_rdata & (32'hFF << (byte_select * 8))) >> (byte_select * 8);
  wire [31:0] half_word =
    (s3_rdata & (32'hFFFF << (byte_select * 8))) >> (byte_select * 8);

  always @(*) begin
    case (s3_rdata_sel)
      `S3_RDATA_SEL_PASSTHROUGH:
        s3_rdata_out = s3_rdata;
      `S3_RDATA_SEL_LOW_BYTE:
        s3_rdata_out = {{BYTE_SIGN_BITS{1'b0}}, byteX[7:0]};
      `S3_RDATA_SEL_LOW_BYTE_SIGNED:
        s3_rdata_out = {{BYTE_SIGN_BITS{byteX[7]}}, byteX[7:0]};
      `S3_RDATA_SEL_LOW_HALF_WORD:
        s3_rdata_out = {{HALF_WORD_SIGN_BITS{1'b0}}, half_word[15:0]};
      `S3_RDATA_SEL_LOW_HALF_WORD_SIGNED: 
        s3_rdata_out =
            {{HALF_WORD_SIGN_BITS{half_word[15]}}, half_word[15:0]};
      default: s3_rdata_out = s3_rdata;
    endcase
  end

endmodule
