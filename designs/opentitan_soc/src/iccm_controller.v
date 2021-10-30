module iccm_controller (
	clk_i,
	rst_ni,
	rx_dv_i,
	rx_byte_i,
	we_o,
	addr_o,
	wdata_o,
	reset_o,

	rx_spi_i,
	sel
);
	input wire clk_i;
	input wire rst_ni;
	input wire rx_dv_i;
	input wire [7:0] rx_byte_i; // byte that receives from UART
	output wire we_o;
	output wire [13:0] addr_o;
	output wire [31:0] wdata_o;
	output wire reset_o;
	
	input wire [31:0] rx_spi_i;
	input wire sel; // 0 : SPI, 1 : UART

	reg [1:0] ctrl_fsm_cs;
	reg [1:0] ctrl_fsm_ns;
	wire [7:0] rx_byte_d;
	reg [7:0] rx_byte_q0;
	reg [7:0] rx_byte_q1;
	reg [7:0] rx_byte_q2;
	reg [7:0] rx_byte_q3;
	reg we_q;
	reg we_d;
	reg [13:0] addr_q;
	reg [13:0] addr_d;
	reg reset_q;
	reg reset_d;
	reg [1:0] byte_count;
	
	localparam [1:0] DONE = 3;
	localparam [1:0] LOAD = 1;
	localparam [1:0] PROG = 2;
	localparam [1:0] RESET = 0;
	
	always @(*) begin
		we_d = we_q;
		addr_d = addr_q;
		reset_d = reset_q;
		ctrl_fsm_ns = ctrl_fsm_cs;
		case (ctrl_fsm_cs)	
			RESET: begin
				we_d = 1'b0;
				reset_d = 1'b0;
				if (rx_dv_i)
					ctrl_fsm_ns = LOAD;
				else
					ctrl_fsm_ns = RESET;
			end
			
			LOAD: begin
				if (~sel) begin
					we_d = 1'b1;
					ctrl_fsm_ns = PROG;
				end
				else if (((byte_count == 2'b11) && (rx_byte_q2 != 8'h0f)) && (rx_byte_d != 8'hff)) begin
					we_d = 1'b1;
					ctrl_fsm_ns = PROG;
				end
				else
					ctrl_fsm_ns = DONE;
			end
			
			PROG: begin
				we_d = 1'b0;
				ctrl_fsm_ns = DONE;
			end
			
			DONE: begin				
				if (wdata_o == 32'h00000fff) begin // ending instruction (program is fully sent)
					ctrl_fsm_ns = DONE;
					reset_d = 1'b1;
				end
				else if (rx_dv_i)
					ctrl_fsm_ns = LOAD;
				else
					ctrl_fsm_ns = DONE;
			end
			
			default: ctrl_fsm_ns = RESET;
		endcase
	end
	
	assign rx_byte_d = rx_byte_i;
	assign we_o = we_q;
	assign addr_o = addr_q;
	assign wdata_o = sel ? {rx_byte_q3, rx_byte_q2, rx_byte_q1, rx_byte_q0} : rx_spi_i;
	assign reset_o = reset_q;
	
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			we_q <= 1'b0;
			addr_q <= 14'b00000000000000;
			rx_byte_q0 <= 8'b00000000;
			rx_byte_q1 <= 8'b00000000;
			rx_byte_q2 <= 8'b00000000;
			rx_byte_q3 <= 8'b00000000;
			reset_q <= 1'b0;
			byte_count <= 2'b00;
			ctrl_fsm_cs <= RESET;
		end
		else begin
			we_q <= we_d;
			if (ctrl_fsm_cs == LOAD && sel == 1'b1) begin
				if (byte_count == 2'b00) begin
					rx_byte_q0 <= rx_byte_d;
					byte_count <= 2'b01;
				end
				else if (byte_count == 2'b01) begin
					rx_byte_q1 <= rx_byte_d;
					byte_count <= 2'b10;
				end
				else if (byte_count == 2'b10) begin
					rx_byte_q2 <= rx_byte_d;
					byte_count <= 2'b11;
				end
				else begin
					rx_byte_q3 <= rx_byte_d;
					byte_count <= 2'b00;
				end
				addr_q <= addr_d;
			end
			if (ctrl_fsm_cs == PROG)
				addr_q <= addr_d + 1'b1;
			reset_q <= reset_d;
			ctrl_fsm_cs <= ctrl_fsm_ns;
		end
endmodule
