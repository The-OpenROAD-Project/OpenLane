module mem_prep (
	mem_width_i,
	mem_data_i,
	mem_addr_i,
	mem_read_i,
	mem_write_i,
	mem_word_addr_ao,
	mem_write_data_ao,
	mem_strobe_ao,
	mem_illegal_ao
);
	input wire [1:0] mem_width_i;
	input [31:0] mem_data_i;
	input [31:0] mem_addr_i;
	input mem_read_i;
	input mem_write_i;
	output wire [31:0] mem_word_addr_ao;
	output wire [31:0] mem_write_data_ao;
	output wire [3:0] mem_strobe_ao;
	output wire mem_illegal_ao;
	reg illegal_addr;
	wire [1:0] pre_width;
	wire [31:0] pre_write_data;
	wire [1:0] req_byte_idx;
	reg [3:0] req_strobe;
	reg [31:0] req_write_data;
	assign pre_width = mem_width_i;
	assign pre_write_data = mem_data_i;
	assign req_byte_idx = mem_addr_i[1:0];
	assign mem_word_addr_ao = {mem_addr_i[31:2], 2'b00};
	assign mem_write_data_ao = req_write_data;
	assign mem_strobe_ao = (mem_write_i ? req_strobe : 4'b0000);
	assign mem_illegal_ao = illegal_addr && (mem_read_i || mem_write_i);
	always @(*) begin
		illegal_addr = 0;
		req_strobe = 4'b0000;
		req_write_data = pre_write_data;
		case (pre_width)
			2'b00: begin
				req_write_data = {4 {pre_write_data[7:0]}};
				req_strobe = 4'b0001 << req_byte_idx;
			end
			2'b01: begin
				req_write_data = {2 {pre_write_data[15:0]}};
				illegal_addr = req_byte_idx[0];
				req_strobe = (illegal_addr ? 4'b0000 : 4'b0011 << req_byte_idx);
			end
			2'b10: begin
				req_write_data = pre_write_data;
				illegal_addr = req_byte_idx != 2'b00;
				req_strobe = (illegal_addr ? 4'b0000 : 4'b1111);
			end
			default: illegal_addr = 1;
		endcase
	end
endmodule
