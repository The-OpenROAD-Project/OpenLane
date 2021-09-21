module ibex_pmp (
	clk_i,
	rst_ni,
	csr_pmp_cfg_i,
	csr_pmp_addr_i,
	priv_mode_i,
	pmp_req_addr_i,
	pmp_req_type_i,
	pmp_req_err_o
);
	parameter [31:0] PMPGranularity = 0;
	parameter [31:0] PMPNumChan = 2;
	parameter [31:0] PMPNumRegions = 4;
	input wire clk_i;
	input wire rst_ni;
	input wire [(0 >= (PMPNumRegions - 1) ? ((2 - PMPNumRegions) * 6) + (((PMPNumRegions - 1) * 6) - 1) : (PMPNumRegions * 6) - 1):(0 >= (PMPNumRegions - 1) ? (PMPNumRegions - 1) * 6 : 0)] csr_pmp_cfg_i;
	input wire [(0 >= (PMPNumRegions - 1) ? ((2 - PMPNumRegions) * 34) + (((PMPNumRegions - 1) * 34) - 1) : (PMPNumRegions * 34) - 1):(0 >= (PMPNumRegions - 1) ? (PMPNumRegions - 1) * 34 : 0)] csr_pmp_addr_i;
	input wire [(0 >= (PMPNumChan - 1) ? ((2 - PMPNumChan) * 2) + (((PMPNumChan - 1) * 2) - 1) : (PMPNumChan * 2) - 1):(0 >= (PMPNumChan - 1) ? (PMPNumChan - 1) * 2 : 0)] priv_mode_i;
	input wire [(0 >= (PMPNumChan - 1) ? ((2 - PMPNumChan) * 34) + (((PMPNumChan - 1) * 34) - 1) : (PMPNumChan * 34) - 1):(0 >= (PMPNumChan - 1) ? (PMPNumChan - 1) * 34 : 0)] pmp_req_addr_i;
	input wire [(0 >= (PMPNumChan - 1) ? ((2 - PMPNumChan) * 2) + (((PMPNumChan - 1) * 2) - 1) : (PMPNumChan * 2) - 1):(0 >= (PMPNumChan - 1) ? (PMPNumChan - 1) * 2 : 0)] pmp_req_type_i;
	output wire [0:PMPNumChan - 1] pmp_req_err_o;
	wire [33:0] region_start_addr [0:PMPNumRegions - 1];
	wire [33:PMPGranularity + 2] region_addr_mask [0:PMPNumRegions - 1];
	wire [(PMPNumChan * PMPNumRegions) - 1:0] region_match_gt;
	wire [(PMPNumChan * PMPNumRegions) - 1:0] region_match_lt;
	wire [(PMPNumChan * PMPNumRegions) - 1:0] region_match_eq;
	reg [(PMPNumChan * PMPNumRegions) - 1:0] region_match_all;
	wire [(PMPNumChan * PMPNumRegions) - 1:0] region_perm_check;
	reg [PMPNumChan - 1:0] access_fault;
	localparam [1:0] ibex_pkg_PMP_MODE_NAPOT = 2'b11;
	localparam [1:0] ibex_pkg_PMP_MODE_TOR = 2'b01;
	generate
		genvar r;
		for (r = 0; r < PMPNumRegions; r = r + 1) begin : g_addr_exp
			if (r == 0) begin : g_entry0
				assign region_start_addr[r] = (csr_pmp_cfg_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 6) + 4-:2] == ibex_pkg_PMP_MODE_TOR ? 34'h000000000 : csr_pmp_addr_i[(0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 34+:34]);
			end
			else begin : g_oth
				assign region_start_addr[r] = (csr_pmp_cfg_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 6) + 4-:2] == ibex_pkg_PMP_MODE_TOR ? csr_pmp_addr_i[(0 >= (PMPNumRegions - 1) ? r - 1 : (PMPNumRegions - 1) - (r - 1)) * 34+:34] : csr_pmp_addr_i[(0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 34+:34]);
			end
			genvar b;
			for (b = PMPGranularity + 2; b < 34; b = b + 1) begin : g_bitmask
				if (b == 2) begin : g_bit0
					assign region_addr_mask[r][b] = csr_pmp_cfg_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 6) + 4-:2] != ibex_pkg_PMP_MODE_NAPOT;
				end
				else begin : g_others
					assign region_addr_mask[r][b] = (csr_pmp_cfg_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 6) + 4-:2] != ibex_pkg_PMP_MODE_NAPOT) | ~&csr_pmp_addr_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 34) + ((b - 1) >= (PMPGranularity + 1) ? b - 1 : ((b - 1) + ((b - 1) >= (PMPGranularity + 1) ? ((b - 1) - (PMPGranularity + 1)) + 1 : ((PMPGranularity + 1) - (b - 1)) + 1)) - 1)-:((b - 1) >= (PMPGranularity + 1) ? ((b - 1) - (PMPGranularity + 1)) + 1 : ((PMPGranularity + 1) - (b - 1)) + 1)];
				end
			end
		end
	endgenerate
	localparam [1:0] ibex_pkg_PMP_ACC_EXEC = 2'b00;
	localparam [1:0] ibex_pkg_PMP_ACC_READ = 2'b10;
	localparam [1:0] ibex_pkg_PMP_ACC_WRITE = 2'b01;
	localparam [1:0] ibex_pkg_PMP_MODE_NA4 = 2'b10;
	localparam [1:0] ibex_pkg_PMP_MODE_OFF = 2'b00;
	localparam [1:0] ibex_pkg_PRIV_LVL_M = 2'b11;
	generate
		genvar c;
		for (c = 0; c < PMPNumChan; c = c + 1) begin : g_access_check
			for (r = 0; r < PMPNumRegions; r = r + 1) begin : g_regions
				assign region_match_eq[(c * PMPNumRegions) + r] = (pmp_req_addr_i[((0 >= (PMPNumChan - 1) ? c : (PMPNumChan - 1) - c) * 34) + (33 >= (PMPGranularity + 2) ? 33 : (33 + (33 >= (PMPGranularity + 2) ? 34 - (PMPGranularity + 2) : PMPGranularity - 30)) - 1)-:(33 >= (PMPGranularity + 2) ? 34 - (PMPGranularity + 2) : PMPGranularity - 30)] & region_addr_mask[r]) == (region_start_addr[r][33:PMPGranularity + 2] & region_addr_mask[r]);
				assign region_match_gt[(c * PMPNumRegions) + r] = pmp_req_addr_i[((0 >= (PMPNumChan - 1) ? c : (PMPNumChan - 1) - c) * 34) + (33 >= (PMPGranularity + 2) ? 33 : (33 + (33 >= (PMPGranularity + 2) ? 34 - (PMPGranularity + 2) : PMPGranularity - 30)) - 1)-:(33 >= (PMPGranularity + 2) ? 34 - (PMPGranularity + 2) : PMPGranularity - 30)] > region_start_addr[r][33:PMPGranularity + 2];
				assign region_match_lt[(c * PMPNumRegions) + r] = pmp_req_addr_i[((0 >= (PMPNumChan - 1) ? c : (PMPNumChan - 1) - c) * 34) + (33 >= (PMPGranularity + 2) ? 33 : (33 + (33 >= (PMPGranularity + 2) ? 34 - (PMPGranularity + 2) : PMPGranularity - 30)) - 1)-:(33 >= (PMPGranularity + 2) ? 34 - (PMPGranularity + 2) : PMPGranularity - 30)] < csr_pmp_addr_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 34) + (33 >= (PMPGranularity + 2) ? 33 : (33 + (33 >= (PMPGranularity + 2) ? 34 - (PMPGranularity + 2) : PMPGranularity - 30)) - 1)-:(33 >= (PMPGranularity + 2) ? 34 - (PMPGranularity + 2) : PMPGranularity - 30)];
				always @(*) begin
					region_match_all[(c * PMPNumRegions) + r] = 1'b0;
					case (csr_pmp_cfg_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 6) + 4-:2])
						ibex_pkg_PMP_MODE_OFF: region_match_all[(c * PMPNumRegions) + r] = 1'b0;
						ibex_pkg_PMP_MODE_NA4: region_match_all[(c * PMPNumRegions) + r] = region_match_eq[(c * PMPNumRegions) + r];
						ibex_pkg_PMP_MODE_NAPOT: region_match_all[(c * PMPNumRegions) + r] = region_match_eq[(c * PMPNumRegions) + r];
						ibex_pkg_PMP_MODE_TOR: region_match_all[(c * PMPNumRegions) + r] = (region_match_eq[(c * PMPNumRegions) + r] | region_match_gt[(c * PMPNumRegions) + r]) & region_match_lt[(c * PMPNumRegions) + r];
						default: region_match_all[(c * PMPNumRegions) + r] = 1'b0;
					endcase
				end
				assign region_perm_check[(c * PMPNumRegions) + r] = (((pmp_req_type_i[(0 >= (PMPNumChan - 1) ? c : (PMPNumChan - 1) - c) * 2+:2] == ibex_pkg_PMP_ACC_EXEC) & csr_pmp_cfg_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 6) + 2]) | ((pmp_req_type_i[(0 >= (PMPNumChan - 1) ? c : (PMPNumChan - 1) - c) * 2+:2] == ibex_pkg_PMP_ACC_WRITE) & csr_pmp_cfg_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 6) + 1])) | ((pmp_req_type_i[(0 >= (PMPNumChan - 1) ? c : (PMPNumChan - 1) - c) * 2+:2] == ibex_pkg_PMP_ACC_READ) & csr_pmp_cfg_i[(0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 6]);
			end
			always @(*) begin
				access_fault[c] = priv_mode_i[(0 >= (PMPNumChan - 1) ? c : (PMPNumChan - 1) - c) * 2+:2] != ibex_pkg_PRIV_LVL_M;
				begin : sv2v_autoblock_1
					reg signed [31:0] r;
					for (r = PMPNumRegions - 1; r >= 0; r = r - 1)
						if (region_match_all[(c * PMPNumRegions) + r])
							access_fault[c] = (priv_mode_i[(0 >= (PMPNumChan - 1) ? c : (PMPNumChan - 1) - c) * 2+:2] == ibex_pkg_PRIV_LVL_M ? csr_pmp_cfg_i[((0 >= (PMPNumRegions - 1) ? r : (PMPNumRegions - 1) - r) * 6) + 5] & ~region_perm_check[(c * PMPNumRegions) + r] : ~region_perm_check[(c * PMPNumRegions) + r]);
				end
			end
			assign pmp_req_err_o[c] = access_fault[c];
		end
	endgenerate
endmodule
