module SPI_slave (
	reset,
	SS,
	SCLK,
	MOSI,
	REG_DIN,
	valid
);
	parameter DATA_WIDTH = 'd32;
	input reset;
	input SS;
	input SCLK;
	input MOSI;
	output reg [DATA_WIDTH - 1:0] REG_DIN;
	output reg valid;
	reg [DATA_WIDTH - 1:0] command;
	reg [DATA_WIDTH - 1:0] data_out;
	reg [4:0] rcv_bit_count;
	reg [4:0] prev_rcv_bit_count;
	wire byte_end = (rcv_bit_count == 5'b11111) && (prev_rcv_bit_count == 5'b11110);
	wire SSEL_active = ~SS;
	wire SSEL_endmessage = SS;
	wire MOSI_data = MOSI;
	always @(posedge SCLK or negedge reset)
		if (~reset) begin
			command <= 32'h00000000;
			rcv_bit_count <= 5'b11111;
			prev_rcv_bit_count <= 5'b11111;
			valid <= 1'b0;
		end
		else begin
			prev_rcv_bit_count <= rcv_bit_count;
			if (SSEL_active) begin
				rcv_bit_count <= rcv_bit_count + 1'b1;
				command <= {command[DATA_WIDTH - 2:0], MOSI_data};
				if (byte_end)
					valid <= 1'b1;
				else
					valid <= 1'b0;
			end
			else begin
				command <= 32'h00000000;
				rcv_bit_count <= 5'b11111;
				prev_rcv_bit_count <= 5'b11111;
				valid <= 1'b0;
			end
		end
	always @(posedge SSEL_endmessage or negedge reset)
		if (~reset)
			REG_DIN <= 32'h00000000;
		else if (valid)
			REG_DIN <= command;
		else
			REG_DIN <= REG_DIN;
endmodule
