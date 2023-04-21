module fwd_unit (
	data_fwd_i,
	dest_meta_i,
	load_use_stall_ao,
	dest_meta_o
);
	parameter N_STAGES = 2;
	parameter MEM_READ_STAGE = 1;
	input wire [(N_STAGES * 40) - 1:0] data_fwd_i;
	input wire [81:0] dest_meta_i;
	output reg load_use_stall_ao;
	output reg [81:0] dest_meta_o;
	reg lus_1;
	reg lus_2;
	

	always @(*) begin
		dest_meta_o = dest_meta_i;
		load_use_stall_ao = 1'sb0;
		lus_1 = 1'sb0;
		lus_2 = 1'sb0;
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < N_STAGES; i = i + 1)
				begin
					if (((dest_meta_i[80-:5] == data_fwd_i[(i * 40) + 37-:5]) && data_fwd_i[(i * 40) + 39]) && data_fwd_i[i * 40])
						if ((i < MEM_READ_STAGE) && data_fwd_i[(i * 40) + 38])
							lus_1= 1'sb1;
						else
							dest_meta_o[75-:32] = data_fwd_i[(i * 40) + 32-:32];
					if (((dest_meta_i[42-:5] == data_fwd_i[(i * 40) + 37-:5]) && data_fwd_i[(i * 40) + 39]) && data_fwd_i[i * 40])
						if ((i < MEM_READ_STAGE) && data_fwd_i[(i * 40) + 38])
							lus_2 = 1'sb1;
						else
							dest_meta_o[37-:32] = data_fwd_i[(i * 40) + 32-:32];
				end
		end
		load_use_stall_ao = (lus_2 != {MEM_READ_STAGE {1'sb0}}) || (lus_1 != {MEM_READ_STAGE {1'sb0}});
	end
endmodule
