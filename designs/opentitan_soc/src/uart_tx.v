module uart_tx (
	clk_i,
	rst_ni,
	tx_enable,
	tick_baud_x16,
	parity_enable,
	wr,
	wr_parity,
	wr_data,
	idle,
	tx
);
	input clk_i;
	input rst_ni;
	input tx_enable;
	input tick_baud_x16;
	input wire parity_enable;
	input wr;
	input wire wr_parity;
	input [7:0] wr_data;
	output idle;
	output wire tx;
	reg [3:0] baud_div_q;
	reg tick_baud_q;
	reg [3:0] bit_cnt_q;
	reg [3:0] bit_cnt_d;
	reg [10:0] sreg_q;
	reg [10:0] sreg_d;
	reg tx_q;
	reg tx_d;
	assign tx = tx_q;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			baud_div_q <= 4'h0;
			tick_baud_q <= 1'b0;
		end
		else if (tick_baud_x16)
			{tick_baud_q, baud_div_q} <= {1'b0, baud_div_q} + 5'h01;
		else
			tick_baud_q <= 1'b0;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni) begin
			bit_cnt_q <= 4'h0;
			sreg_q <= 11'h7ff;
			tx_q <= 1'b1;
		end
		else begin
			bit_cnt_q <= bit_cnt_d;
			sreg_q <= sreg_d;
			tx_q <= tx_d;
		end
	always @(*)
		if (!tx_enable) begin
			bit_cnt_d = 4'h0;
			sreg_d = 11'h7ff;
			tx_d = 1'b1;
		end
		else begin
			bit_cnt_d = bit_cnt_q;
			sreg_d = sreg_q;
			tx_d = tx_q;
			if (wr) begin
				sreg_d = {1'b1, (parity_enable ? wr_parity : 1'b1), wr_data, 1'b0};
				bit_cnt_d = (parity_enable ? 4'd11 : 4'd10);
			end
			else if (tick_baud_q && (bit_cnt_q != 4'h0)) begin
				sreg_d = {1'b1, sreg_q[10:1]};
				tx_d = sreg_q[0];
				bit_cnt_d = bit_cnt_q - 4'h1;
			end
		end
	assign idle = (tx_enable ? bit_cnt_q == 4'h0 : 1'b1);
endmodule
