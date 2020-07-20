module zuc_core(
	input				i_clk,
	input				i_rst,
	input				i_init,
	input	[127:0]		i_key,
    input   [127:0] 	i_iv,
    input               i_ready,
    output              o_valid,
    output  [31:0]      o_data
    );
	
	parameter DK0  = 15'h44D7;
	parameter DK1  = 15'h26BC;
	parameter DK2  = 15'h626B;
	parameter DK3  = 15'h135E;
	parameter DK4  = 15'h5789;
	parameter DK5  = 15'h35E2;
	parameter DK6  = 15'h7135;
	parameter DK7  = 15'h09AF;
	parameter DK8  = 15'h4D78;
	parameter DK9  = 15'h2F13;
	parameter DK10 = 15'h6BC4;
	parameter DK11 = 15'h1AF1;
	parameter DK12 = 15'h5E26;
	parameter DK13 = 15'h3C4D;
	parameter DK14 = 15'h789A;
	parameter DK15 = 15'h47AC;
	
	wire 	[31*16-1:0] s_lfsr_in;
	reg 	[31*16-1:0]	r_lfsr;	
	
	reg 	[31:0]	r_r1;
	reg 	[31:0]	r_r2;	
	
	wire	[31:0]	s_x0;
	wire 	[31:0]	s_x1;
	wire 	[31:0]	s_x2;
	wire 	[31:0]	s_x3;
	
	wire 	[31:0]	s_w;
	wire 	[31:0]	s_w1;
	wire 	[31:0]	s_w2;
	wire 	[31:0]	s_u;
	wire 	[31:0]	s_v;
	wire 	[31:0]	s_r1;
	wire 	[31:0]	s_r2;
	wire	[30:0]	s_lfv1;
	wire 	[30:0]	s_lfv2;
	wire 	[30:0]	s_lfv3;
	wire 	[30:0]	s_lfv4;
	wire 	[30:0]	s_lfv5;
	wire 	[30:0]	s_lfv6;
	
    reg     [4:0]   r_count;
    reg     [1:0]   r_state;
    
	wire    [30:0]  LFSR15;
    wire    [30:0]  LFSR14;
    wire    [30:0]  LFSR13;
    wire    [30:0]  LFSR11;
    wire    [30:0]  LFSR10;
    wire    [30:0]  LFSR9 ;
    wire    [30:0]  LFSR7 ;
    wire    [30:0]  LFSR5 ;
    wire    [30:0]  LFSR4 ;
    wire    [30:0]  LFSR2 ;
    wire    [30:0]  LFSR0 ;
    
    reg             r_valid;
    reg     [31:0]  r_data;
	
	//key input
	assign s_lfsr_in[31*16-1:31*15] = {i_key[7:0]    ,DK15, i_iv[7:0]    };
	assign s_lfsr_in[31*15-1:31*14] = {i_key[15:8]   ,DK14, i_iv[15:8]   };
	assign s_lfsr_in[31*14-1:31*13] = {i_key[23:16]  ,DK13, i_iv[23:16]  };
	assign s_lfsr_in[31*13-1:31*12] = {i_key[31:24]  ,DK12, i_iv[31:24]  };
	assign s_lfsr_in[31*12-1:31*11] = {i_key[39:32]  ,DK11, i_iv[39:32]  };
	assign s_lfsr_in[31*11-1:31*10] = {i_key[47:40]  ,DK10, i_iv[47:40]  };
	assign s_lfsr_in[31*10-1:31*9]  = {i_key[55:48]  ,DK9,  i_iv[55:48]  };
	assign s_lfsr_in[31*9-1 :31*8]  = {i_key[63:56]  ,DK8,  i_iv[63:56]  };
	assign s_lfsr_in[31*8-1 :31*7]  = {i_key[71:64]  ,DK7,  i_iv[71:64]  };
	assign s_lfsr_in[31*7-1 :31*6]  = {i_key[79:72]  ,DK6,  i_iv[79:72]  };
	assign s_lfsr_in[31*6-1 :31*5]  = {i_key[87:80]  ,DK5,  i_iv[87:80]  };
	assign s_lfsr_in[31*5-1 :31*4]  = {i_key[95:88]  ,DK4,  i_iv[95:88]  };
	assign s_lfsr_in[31*4-1 :31*3]  = {i_key[103:96] ,DK3,  i_iv[103:96] };
	assign s_lfsr_in[31*3-1 :31*2]  = {i_key[111:104],DK2,  i_iv[111:104]};
	assign s_lfsr_in[31*2-1 :31*1]  = {i_key[119:112],DK1,  i_iv[119:112]};
	assign s_lfsr_in[30:0]          = {i_key[127:120],DK0,  i_iv[127:120]};

	
	always@(posedge i_clk or posedge i_rst) begin
		if(i_rst) begin
			r_count <= 5'b0;
			r_lfsr  <= 496'b0;
			r_state <= 2'b0;
			r_r1    <= 32'b0;
			r_r2    <= 32'b0;
			r_valid <= 1'b0;
			r_data <= 32'b0;
		end else begin
			case(r_state) 
				2'b0: begin
					if(i_init) begin
						r_lfsr <= s_lfsr_in;
						r_r1 <= 32'h0;
						r_r2 <= 32'h0;
						r_state <= 2'b1;
					end else if(i_ready) begin
					    r_valid <= 1'b1;
					    r_data <= s_x3^s_w; 
					    r_r1 <= s_r1;
					    r_r2 <= s_r2;
					    if(s_lfv5==32'b0) r_lfsr <= {31'h7fff_ffff,r_lfsr[495:31]};
					    else r_lfsr <= {s_lfv5,r_lfsr[495:31]}; 
					end
				end
				2'b1: begin
					r_count <= r_count + 1'b1;
					if(r_count=='d31)
						r_state <= 2'd0;
					r_r1 <= s_r1;
					r_r2 <= s_r2;
					r_lfsr <= {s_lfv6,r_lfsr[495:31]};
				end
			endcase
		end 
	
	end
	
	assign LFSR15 = r_lfsr[31*15+30:31*15];
	assign LFSR14 = r_lfsr[31*14+30:31*14];
	assign LFSR13 = r_lfsr[31*13+30:31*13];
	assign LFSR11 = r_lfsr[31*11+30:31*11];
	assign LFSR10 = r_lfsr[31*10+30:31*10];
	assign LFSR9  = r_lfsr[31*9+30:31*9];
	assign LFSR7  = r_lfsr[31*7+30:31*7];
	assign LFSR5  = r_lfsr[31*5+30:31*5];
	assign LFSR4  = r_lfsr[31*4+30:31*4];
	assign LFSR2  = r_lfsr[31*2+30:31*2];
	assign LFSR0  = r_lfsr[30:0];
	
	//BitResconstruction
	assign s_x0 = {LFSR15[30:15],LFSR14[15:0]};
	assign s_x1 = {LFSR11[15:0],LFSR9[30:15]};
	assign s_x2 = {LFSR7[15:0],LFSR5[30:15]};
	assign s_x3 = {LFSR2[15:0],LFSR0[30:15]};
	
	//F(x1,x2,x3)
	assign s_w  = (s_x0^r_r1)+r_r2;
	assign s_w1 = r_r1+s_x1;
	assign s_w2 = r_r2^s_x2;
	assign s_u =  L1({s_w1[15:0],s_w2[31:16]});
	assign s_v =  L2({s_w2[15:0],s_w1[31:16]});	
	zuc_s0 s_1(.din(s_u[31:24]),.dout(s_r1[31:24]));
	zuc_s1 s_2(.din(s_u[23:16]),.dout(s_r1[23:16]));
	zuc_s0 s_3(.din(s_u[15:8]),.dout(s_r1[15:8]));
	zuc_s1 s_4(.din(s_u[7:0]),.dout(s_r1[7:0]));
	zuc_s0 s_5(.din(s_v[31:24]),.dout(s_r2[31:24]));
	zuc_s1 s_6(.din(s_v[23:16]),.dout(s_r2[23:16]));
	zuc_s0 s_7(.din(s_v[15:8]),.dout(s_r2[15:8]));
	zuc_s1 s_8(.din(s_v[7:0]),.dout(s_r2[7:0]));
	
	//LFSRWithInitializationMode(W>>1)
	assign s_lfv1 = ADD31(LFSR0,ROT31(LFSR0,8));
	assign s_lfv2 = ADD31(s_lfv1,ROT31(LFSR4,20));
	assign s_lfv3 = ADD31(s_lfv2,ROT31(LFSR10,21));
	assign s_lfv4 = ADD31(s_lfv3,ROT31(LFSR13,17));
	assign s_lfv5 = ADD31(s_lfv4,ROT31(LFSR15,15));
	assign s_lfv6 = ADD31(s_lfv5,s_w[31:1]);
	
    assign o_valid = r_valid;
	assign o_data = r_data; 
	
	function [30:0]	ADD31;
		input [30:0] a;
		input [30:0] b;
		reg [31:0] tmp;
		begin
			tmp = a + b;
			ADD31 = tmp[30:0] + tmp[31]; 
		end
	endfunction
		
	function [30:0]	ROT31;
		input [30:0] a;
		input [4:0] k;
		begin
		    ROT31 = (k==8) ? {a[22:0],a[30:23]}:
                   ((k==20)? {a[10:0],a[30:11]}:
                   ((k==21)? {a[9:0] ,a[30:10]}:
                   ((k==17)? {a[13:0],a[30:14] }:
                   ((k==15)? {a[15:0],a[30:16] }:31'b0))));
		end	
	endfunction
	
	function [31:0] ROT32;
		input [31:0] a;
		input [4:0] k;
		begin
		    ROT32 = (k==8) ? {a[23:0],a[31:24]}:
		           ((k==14)? {a[17:0],a[31:18]}:
		           ((k==22)? {a[9:0] ,a[31:10]}:
		           ((k==30)? {a[1:0] ,a[31:2] }:
		           ((k==2 )? {a[29:0],a[31:30]}:
		           ((k==10)? {a[21:0],a[31:22]}:
		           ((k==18)? {a[13:0],a[31:14]}:
		           ((k==24)? {a[7:0] ,a[31:8] }:32'b0)))))));
		end	
	endfunction	
	
	function [31:0]	L1;
		input [31:0] X;
		begin
			L1 = X^ROT32(X,2)^ROT32(X,10)^ROT32(X,18)^ROT32(X,24);
		end
	endfunction
	
	function [31:0] L2;
		input [31:0] X;
		begin
			L2 = X^ROT32(X,8)^ROT32(X,14)^ROT32(X,22)^ROT32(X,30);
		end
	endfunction
	
	
endmodule	

module zuc_s0(
    input   [7:0]   din,
    output  [7:0]   dout
    );
    reg [7:0] r_dout;
    assign dout = r_dout;
    always@(din) begin
        case(din)
			8'h00 : r_dout = 8'h3e;
			8'h01 : r_dout = 8'h72;
			8'h02 : r_dout = 8'h5b;
			8'h03 : r_dout = 8'h47;
			8'h04 : r_dout = 8'hca;
			8'h05 : r_dout = 8'he0;
			8'h06 : r_dout = 8'h00;
			8'h07 : r_dout = 8'h33;
			8'h08 : r_dout = 8'h04;
			8'h09 : r_dout = 8'hd1;
			8'h0a : r_dout = 8'h54;
			8'h0b : r_dout = 8'h98;
			8'h0c : r_dout = 8'h09;
			8'h0d : r_dout = 8'hb9;
			8'h0e : r_dout = 8'h6d;
			8'h0f : r_dout = 8'hcb;
			8'h10 : r_dout = 8'h7b;
			8'h11 : r_dout = 8'h1b;
			8'h12 : r_dout = 8'hf9;
			8'h13 : r_dout = 8'h32;
			8'h14 : r_dout = 8'haf;
			8'h15 : r_dout = 8'h9d;
			8'h16 : r_dout = 8'h6a;
			8'h17 : r_dout = 8'ha5;
			8'h18 : r_dout = 8'hb8;
			8'h19 : r_dout = 8'h2d;
			8'h1a : r_dout = 8'hfc;
			8'h1b : r_dout = 8'h1d;
			8'h1c : r_dout = 8'h08;
			8'h1d : r_dout = 8'h53;
			8'h1e : r_dout = 8'h03;
			8'h1f : r_dout = 8'h90;
			8'h20 : r_dout = 8'h4d;
			8'h21 : r_dout = 8'h4e;
			8'h22 : r_dout = 8'h84;
			8'h23 : r_dout = 8'h99;
			8'h24 : r_dout = 8'he4;
			8'h25 : r_dout = 8'hce;
			8'h26 : r_dout = 8'hd9;
			8'h27 : r_dout = 8'h91;
			8'h28 : r_dout = 8'hdd;
			8'h29 : r_dout = 8'hb6;
			8'h2a : r_dout = 8'h85;
			8'h2b : r_dout = 8'h48;
			8'h2c : r_dout = 8'h8b;
			8'h2d : r_dout = 8'h29;
			8'h2e : r_dout = 8'h6e;
			8'h2f : r_dout = 8'hac;
			8'h30 : r_dout = 8'hcd;
			8'h31 : r_dout = 8'hc1;
			8'h32 : r_dout = 8'hf8;
			8'h33 : r_dout = 8'h1e;
			8'h34 : r_dout = 8'h73;
			8'h35 : r_dout = 8'h43;
			8'h36 : r_dout = 8'h69;
			8'h37 : r_dout = 8'hc6;
			8'h38 : r_dout = 8'hb5;
			8'h39 : r_dout = 8'hbd;
			8'h3a : r_dout = 8'hfd;
			8'h3b : r_dout = 8'h39;
			8'h3c : r_dout = 8'h63;
			8'h3d : r_dout = 8'h20;
			8'h3e : r_dout = 8'hd4;
			8'h3f : r_dout = 8'h38;
			8'h40 : r_dout = 8'h76;
			8'h41 : r_dout = 8'h7d;
			8'h42 : r_dout = 8'hb2;
			8'h43 : r_dout = 8'ha7;
			8'h44 : r_dout = 8'hcf;
			8'h45 : r_dout = 8'hed;
			8'h46 : r_dout = 8'h57;
			8'h47 : r_dout = 8'hc5;
			8'h48 : r_dout = 8'hf3;
			8'h49 : r_dout = 8'h2c;
			8'h4a : r_dout = 8'hbb;
			8'h4b : r_dout = 8'h14;
			8'h4c : r_dout = 8'h21;
			8'h4d : r_dout = 8'h06;
			8'h4e : r_dout = 8'h55;
			8'h4f : r_dout = 8'h9b;
			8'h50 : r_dout = 8'he3;
			8'h51 : r_dout = 8'hef;
			8'h52 : r_dout = 8'h5e;
			8'h53 : r_dout = 8'h31;
			8'h54 : r_dout = 8'h4f;
			8'h55 : r_dout = 8'h7f;
			8'h56 : r_dout = 8'h5a;
			8'h57 : r_dout = 8'ha4;
			8'h58 : r_dout = 8'h0d;
			8'h59 : r_dout = 8'h82;
			8'h5a : r_dout = 8'h51;
			8'h5b : r_dout = 8'h49;
			8'h5c : r_dout = 8'h5f;
			8'h5d : r_dout = 8'hba;
			8'h5e : r_dout = 8'h58;
			8'h5f : r_dout = 8'h1c;
			8'h60 : r_dout = 8'h4a;
			8'h61 : r_dout = 8'h16;
			8'h62 : r_dout = 8'hd5;
			8'h63 : r_dout = 8'h17;
			8'h64 : r_dout = 8'ha8;
			8'h65 : r_dout = 8'h92;
			8'h66 : r_dout = 8'h24;
			8'h67 : r_dout = 8'h1f;
			8'h68 : r_dout = 8'h8c;
			8'h69 : r_dout = 8'hff;
			8'h6a : r_dout = 8'hd8;
			8'h6b : r_dout = 8'hae;
			8'h6c : r_dout = 8'h2e;
			8'h6d : r_dout = 8'h01;
			8'h6e : r_dout = 8'hd3;
			8'h6f : r_dout = 8'had;
			8'h70 : r_dout = 8'h3b;
			8'h71 : r_dout = 8'h4b;
			8'h72 : r_dout = 8'hda;
			8'h73 : r_dout = 8'h46;
			8'h74 : r_dout = 8'heb;
			8'h75 : r_dout = 8'hc9;
			8'h76 : r_dout = 8'hde;
			8'h77 : r_dout = 8'h9a;
			8'h78 : r_dout = 8'h8f;
			8'h79 : r_dout = 8'h87;
			8'h7a : r_dout = 8'hd7;
			8'h7b : r_dout = 8'h3a;
			8'h7c : r_dout = 8'h80;
			8'h7d : r_dout = 8'h6f;
			8'h7e : r_dout = 8'h2f;
			8'h7f : r_dout = 8'hc8;
			8'h80 : r_dout = 8'hb1;
			8'h81 : r_dout = 8'hb4;
			8'h82 : r_dout = 8'h37;
			8'h83 : r_dout = 8'hf7;
			8'h84 : r_dout = 8'h0a;
			8'h85 : r_dout = 8'h22;
			8'h86 : r_dout = 8'h13;
			8'h87 : r_dout = 8'h28;
			8'h88 : r_dout = 8'h7c;
			8'h89 : r_dout = 8'hcc;
			8'h8a : r_dout = 8'h3c;
			8'h8b : r_dout = 8'h89;
			8'h8c : r_dout = 8'hc7;
			8'h8d : r_dout = 8'hc3;
			8'h8e : r_dout = 8'h96;
			8'h8f : r_dout = 8'h56;
			8'h90 : r_dout = 8'h07;
			8'h91 : r_dout = 8'hbf;
			8'h92 : r_dout = 8'h7e;
			8'h93 : r_dout = 8'hf0;
			8'h94 : r_dout = 8'h0b;
			8'h95 : r_dout = 8'h2b;
			8'h96 : r_dout = 8'h97;
			8'h97 : r_dout = 8'h52;
			8'h98 : r_dout = 8'h35;
			8'h99 : r_dout = 8'h41;
			8'h9a : r_dout = 8'h79;
			8'h9b : r_dout = 8'h61;
			8'h9c : r_dout = 8'ha6;
			8'h9d : r_dout = 8'h4c;
			8'h9e : r_dout = 8'h10;
			8'h9f : r_dout = 8'hfe;
			8'ha0 : r_dout = 8'hbc;
			8'ha1 : r_dout = 8'h26;
			8'ha2 : r_dout = 8'h95;
			8'ha3 : r_dout = 8'h88;
			8'ha4 : r_dout = 8'h8a;
			8'ha5 : r_dout = 8'hb0;
			8'ha6 : r_dout = 8'ha3;
			8'ha7 : r_dout = 8'hfb;
			8'ha8 : r_dout = 8'hc0;
			8'ha9 : r_dout = 8'h18;
			8'haa : r_dout = 8'h94;
			8'hab : r_dout = 8'hf2;
			8'hac : r_dout = 8'he1;
			8'had : r_dout = 8'he5;
			8'hae : r_dout = 8'he9;
			8'haf : r_dout = 8'h5d;
			8'hb0 : r_dout = 8'hd0;
			8'hb1 : r_dout = 8'hdc;
			8'hb2 : r_dout = 8'h11;
			8'hb3 : r_dout = 8'h66;
			8'hb4 : r_dout = 8'h64;
			8'hb5 : r_dout = 8'h5c;
			8'hb6 : r_dout = 8'hec;
			8'hb7 : r_dout = 8'h59;
			8'hb8 : r_dout = 8'h42;
			8'hb9 : r_dout = 8'h75;
			8'hba : r_dout = 8'h12;
			8'hbb : r_dout = 8'hf5;
			8'hbc : r_dout = 8'h74;
			8'hbd : r_dout = 8'h9c;
			8'hbe : r_dout = 8'haa;
			8'hbf : r_dout = 8'h23;
			8'hc0 : r_dout = 8'h0e;
			8'hc1 : r_dout = 8'h86;
			8'hc2 : r_dout = 8'hab;
			8'hc3 : r_dout = 8'hbe;
			8'hc4 : r_dout = 8'h2a;
			8'hc5 : r_dout = 8'h02;
			8'hc6 : r_dout = 8'he7;
			8'hc7 : r_dout = 8'h67;
			8'hc8 : r_dout = 8'he6;
			8'hc9 : r_dout = 8'h44;
			8'hca : r_dout = 8'ha2;
			8'hcb : r_dout = 8'h6c;
			8'hcc : r_dout = 8'hc2;
			8'hcd : r_dout = 8'h93;
			8'hce : r_dout = 8'h9f;
			8'hcf : r_dout = 8'hf1;
			8'hd0 : r_dout = 8'hf6;
			8'hd1 : r_dout = 8'hfa;
			8'hd2 : r_dout = 8'h36;
			8'hd3 : r_dout = 8'hd2;
			8'hd4 : r_dout = 8'h50;
			8'hd5 : r_dout = 8'h68;
			8'hd6 : r_dout = 8'h9e;
			8'hd7 : r_dout = 8'h62;
			8'hd8 : r_dout = 8'h71;
			8'hd9 : r_dout = 8'h15;
			8'hda : r_dout = 8'h3d;
			8'hdb : r_dout = 8'hd6;
			8'hdc : r_dout = 8'h40;
			8'hdd : r_dout = 8'hc4;
			8'hde : r_dout = 8'he2;
			8'hdf : r_dout = 8'h0f;
			8'he0 : r_dout = 8'h8e;
			8'he1 : r_dout = 8'h83;
			8'he2 : r_dout = 8'h77;
			8'he3 : r_dout = 8'h6b;
			8'he4 : r_dout = 8'h25;
			8'he5 : r_dout = 8'h05;
			8'he6 : r_dout = 8'h3f;
			8'he7 : r_dout = 8'h0c;
			8'he8 : r_dout = 8'h30;
			8'he9 : r_dout = 8'hea;
			8'hea : r_dout = 8'h70;
			8'heb : r_dout = 8'hb7;
			8'hec : r_dout = 8'ha1;
			8'hed : r_dout = 8'he8;
			8'hee : r_dout = 8'ha9;
			8'hef : r_dout = 8'h65;
			8'hf0 : r_dout = 8'h8d;
			8'hf1 : r_dout = 8'h27;
			8'hf2 : r_dout = 8'h1a;
			8'hf3 : r_dout = 8'hdb;
			8'hf4 : r_dout = 8'h81;
			8'hf5 : r_dout = 8'hb3;
			8'hf6 : r_dout = 8'ha0;
			8'hf7 : r_dout = 8'hf4;
			8'hf8 : r_dout = 8'h45;
			8'hf9 : r_dout = 8'h7a;
			8'hfa : r_dout = 8'h19;
			8'hfb : r_dout = 8'hdf;
			8'hfc : r_dout = 8'hee;
			8'hfd : r_dout = 8'h78;
			8'hfe : r_dout = 8'h34;
			8'hff : r_dout = 8'h60;
        endcase
    end

endmodule

module zuc_s1(
    input   [7:0]   din,
    output  [7:0]   dout
    );
    reg [7:0] r_dout;
    assign dout = r_dout;
    always@(din) begin
        case(din)
			8'h00 : r_dout = 8'h55;
			8'h01 : r_dout = 8'hc2;
			8'h02 : r_dout = 8'h63;
			8'h03 : r_dout = 8'h71;
			8'h04 : r_dout = 8'h3b;
			8'h05 : r_dout = 8'hc8;
			8'h06 : r_dout = 8'h47;
			8'h07 : r_dout = 8'h86;
			8'h08 : r_dout = 8'h9f;
			8'h09 : r_dout = 8'h3c;
			8'h0a : r_dout = 8'hda;
			8'h0b : r_dout = 8'h5b;
			8'h0c : r_dout = 8'h29;
			8'h0d : r_dout = 8'haa;
			8'h0e : r_dout = 8'hfd;
			8'h0f : r_dout = 8'h77;
			8'h10 : r_dout = 8'h8c;
			8'h11 : r_dout = 8'hc5;
			8'h12 : r_dout = 8'h94;
			8'h13 : r_dout = 8'h0c;
			8'h14 : r_dout = 8'ha6;
			8'h15 : r_dout = 8'h1a;
			8'h16 : r_dout = 8'h13;
			8'h17 : r_dout = 8'h00;
			8'h18 : r_dout = 8'he3;
			8'h19 : r_dout = 8'ha8;
			8'h1a : r_dout = 8'h16;
			8'h1b : r_dout = 8'h72;
			8'h1c : r_dout = 8'h40;
			8'h1d : r_dout = 8'hf9;
			8'h1e : r_dout = 8'hf8;
			8'h1f : r_dout = 8'h42;
			8'h20 : r_dout = 8'h44;
			8'h21 : r_dout = 8'h26;
			8'h22 : r_dout = 8'h68;
			8'h23 : r_dout = 8'h96;
			8'h24 : r_dout = 8'h81;
			8'h25 : r_dout = 8'hd9;
			8'h26 : r_dout = 8'h45;
			8'h27 : r_dout = 8'h3e;
			8'h28 : r_dout = 8'h10;
			8'h29 : r_dout = 8'h76;
			8'h2a : r_dout = 8'hc6;
			8'h2b : r_dout = 8'ha7;
			8'h2c : r_dout = 8'h8b;
			8'h2d : r_dout = 8'h39;
			8'h2e : r_dout = 8'h43;
			8'h2f : r_dout = 8'he1;
			8'h30 : r_dout = 8'h3a;
			8'h31 : r_dout = 8'hb5;
			8'h32 : r_dout = 8'h56;
			8'h33 : r_dout = 8'h2a;
			8'h34 : r_dout = 8'hc0;
			8'h35 : r_dout = 8'h6d;
			8'h36 : r_dout = 8'hb3;
			8'h37 : r_dout = 8'h05;
			8'h38 : r_dout = 8'h22;
			8'h39 : r_dout = 8'h66;
			8'h3a : r_dout = 8'hbf;
			8'h3b : r_dout = 8'hdc;
			8'h3c : r_dout = 8'h0b;
			8'h3d : r_dout = 8'hfa;
			8'h3e : r_dout = 8'h62;
			8'h3f : r_dout = 8'h48;
			8'h40 : r_dout = 8'hdd;
			8'h41 : r_dout = 8'h20;
			8'h42 : r_dout = 8'h11;
			8'h43 : r_dout = 8'h06;
			8'h44 : r_dout = 8'h36;
			8'h45 : r_dout = 8'hc9;
			8'h46 : r_dout = 8'hc1;
			8'h47 : r_dout = 8'hcf;
			8'h48 : r_dout = 8'hf6;
			8'h49 : r_dout = 8'h27;
			8'h4a : r_dout = 8'h52;
			8'h4b : r_dout = 8'hbb;
			8'h4c : r_dout = 8'h69;
			8'h4d : r_dout = 8'hf5;
			8'h4e : r_dout = 8'hd4;
			8'h4f : r_dout = 8'h87;
			8'h50 : r_dout = 8'h7f;
			8'h51 : r_dout = 8'h84;
			8'h52 : r_dout = 8'h4c;
			8'h53 : r_dout = 8'hd2;
			8'h54 : r_dout = 8'h9c;
			8'h55 : r_dout = 8'h57;
			8'h56 : r_dout = 8'ha4;
			8'h57 : r_dout = 8'hbc;
			8'h58 : r_dout = 8'h4f;
			8'h59 : r_dout = 8'h9a;
			8'h5a : r_dout = 8'hdf;
			8'h5b : r_dout = 8'hfe;
			8'h5c : r_dout = 8'hd6;
			8'h5d : r_dout = 8'h8d;
			8'h5e : r_dout = 8'h7a;
			8'h5f : r_dout = 8'heb;
			8'h60 : r_dout = 8'h2b;
			8'h61 : r_dout = 8'h53;
			8'h62 : r_dout = 8'hd8;
			8'h63 : r_dout = 8'h5c;
			8'h64 : r_dout = 8'ha1;
			8'h65 : r_dout = 8'h14;
			8'h66 : r_dout = 8'h17;
			8'h67 : r_dout = 8'hfb;
			8'h68 : r_dout = 8'h23;
			8'h69 : r_dout = 8'hd5;
			8'h6a : r_dout = 8'h7d;
			8'h6b : r_dout = 8'h30;
			8'h6c : r_dout = 8'h67;
			8'h6d : r_dout = 8'h73;
			8'h6e : r_dout = 8'h08;
			8'h6f : r_dout = 8'h09;
			8'h70 : r_dout = 8'hee;
			8'h71 : r_dout = 8'hb7;
			8'h72 : r_dout = 8'h70;
			8'h73 : r_dout = 8'h3f;
			8'h74 : r_dout = 8'h61;
			8'h75 : r_dout = 8'hb2;
			8'h76 : r_dout = 8'h19;
			8'h77 : r_dout = 8'h8e;
			8'h78 : r_dout = 8'h4e;
			8'h79 : r_dout = 8'he5;
			8'h7a : r_dout = 8'h4b;
			8'h7b : r_dout = 8'h93;
			8'h7c : r_dout = 8'h8f;
			8'h7d : r_dout = 8'h5d;
			8'h7e : r_dout = 8'hdb;
			8'h7f : r_dout = 8'ha9;
			8'h80 : r_dout = 8'had;
			8'h81 : r_dout = 8'hf1;
			8'h82 : r_dout = 8'hae;
			8'h83 : r_dout = 8'h2e;
			8'h84 : r_dout = 8'hcb;
			8'h85 : r_dout = 8'h0d;
			8'h86 : r_dout = 8'hfc;
			8'h87 : r_dout = 8'hf4;
			8'h88 : r_dout = 8'h2d;
			8'h89 : r_dout = 8'h46;
			8'h8a : r_dout = 8'h6e;
			8'h8b : r_dout = 8'h1d;
			8'h8c : r_dout = 8'h97;
			8'h8d : r_dout = 8'he8;
			8'h8e : r_dout = 8'hd1;
			8'h8f : r_dout = 8'he9;
			8'h90 : r_dout = 8'h4d;
			8'h91 : r_dout = 8'h37;
			8'h92 : r_dout = 8'ha5;
			8'h93 : r_dout = 8'h75;
			8'h94 : r_dout = 8'h5e;
			8'h95 : r_dout = 8'h83;
			8'h96 : r_dout = 8'h9e;
			8'h97 : r_dout = 8'hab;
			8'h98 : r_dout = 8'h82;
			8'h99 : r_dout = 8'h9d;
			8'h9a : r_dout = 8'hb9;
			8'h9b : r_dout = 8'h1c;
			8'h9c : r_dout = 8'he0;
			8'h9d : r_dout = 8'hcd;
			8'h9e : r_dout = 8'h49;
			8'h9f : r_dout = 8'h89;
			8'ha0 : r_dout = 8'h01;
			8'ha1 : r_dout = 8'hb6;
			8'ha2 : r_dout = 8'hbd;
			8'ha3 : r_dout = 8'h58;
			8'ha4 : r_dout = 8'h24;
			8'ha5 : r_dout = 8'ha2;
			8'ha6 : r_dout = 8'h5f;
			8'ha7 : r_dout = 8'h38;
			8'ha8 : r_dout = 8'h78;
			8'ha9 : r_dout = 8'h99;
			8'haa : r_dout = 8'h15;
			8'hab : r_dout = 8'h90;
			8'hac : r_dout = 8'h50;
			8'had : r_dout = 8'hb8;
			8'hae : r_dout = 8'h95;
			8'haf : r_dout = 8'he4;
			8'hb0 : r_dout = 8'hd0;
			8'hb1 : r_dout = 8'h91;
			8'hb2 : r_dout = 8'hc7;
			8'hb3 : r_dout = 8'hce;
			8'hb4 : r_dout = 8'hed;
			8'hb5 : r_dout = 8'h0f;
			8'hb6 : r_dout = 8'hb4;
			8'hb7 : r_dout = 8'h6f;
			8'hb8 : r_dout = 8'ha0;
			8'hb9 : r_dout = 8'hcc;
			8'hba : r_dout = 8'hf0;
			8'hbb : r_dout = 8'h02;
			8'hbc : r_dout = 8'h4a;
			8'hbd : r_dout = 8'h79;
			8'hbe : r_dout = 8'hc3;
			8'hbf : r_dout = 8'hde;
			8'hc0 : r_dout = 8'ha3;
			8'hc1 : r_dout = 8'hef;
			8'hc2 : r_dout = 8'hea;
			8'hc3 : r_dout = 8'h51;
			8'hc4 : r_dout = 8'he6;
			8'hc5 : r_dout = 8'h6b;
			8'hc6 : r_dout = 8'h18;
			8'hc7 : r_dout = 8'hec;
			8'hc8 : r_dout = 8'h1b;
			8'hc9 : r_dout = 8'h2c;
			8'hca : r_dout = 8'h80;
			8'hcb : r_dout = 8'hf7;
			8'hcc : r_dout = 8'h74;
			8'hcd : r_dout = 8'he7;
			8'hce : r_dout = 8'hff;
			8'hcf : r_dout = 8'h21;
			8'hd0 : r_dout = 8'h5a;
			8'hd1 : r_dout = 8'h6a;
			8'hd2 : r_dout = 8'h54;
			8'hd3 : r_dout = 8'h1e;
			8'hd4 : r_dout = 8'h41;
			8'hd5 : r_dout = 8'h31;
			8'hd6 : r_dout = 8'h92;
			8'hd7 : r_dout = 8'h35;
			8'hd8 : r_dout = 8'hc4;
			8'hd9 : r_dout = 8'h33;
			8'hda : r_dout = 8'h07;
			8'hdb : r_dout = 8'h0a;
			8'hdc : r_dout = 8'hba;
			8'hdd : r_dout = 8'h7e;
			8'hde : r_dout = 8'h0e;
			8'hdf : r_dout = 8'h34;
			8'he0 : r_dout = 8'h88;
			8'he1 : r_dout = 8'hb1;
			8'he2 : r_dout = 8'h98;
			8'he3 : r_dout = 8'h7c;
			8'he4 : r_dout = 8'hf3;
			8'he5 : r_dout = 8'h3d;
			8'he6 : r_dout = 8'h60;
			8'he7 : r_dout = 8'h6c;
			8'he8 : r_dout = 8'h7b;
			8'he9 : r_dout = 8'hca;
			8'hea : r_dout = 8'hd3;
			8'heb : r_dout = 8'h1f;
			8'hec : r_dout = 8'h32;
			8'hed : r_dout = 8'h65;
			8'hee : r_dout = 8'h04;
			8'hef : r_dout = 8'h28;
			8'hf0 : r_dout = 8'h64;
			8'hf1 : r_dout = 8'hbe;
			8'hf2 : r_dout = 8'h85;
			8'hf3 : r_dout = 8'h9b;
			8'hf4 : r_dout = 8'h2f;
			8'hf5 : r_dout = 8'h59;
			8'hf6 : r_dout = 8'h8a;
			8'hf7 : r_dout = 8'hd7;
			8'hf8 : r_dout = 8'hb0;
			8'hf9 : r_dout = 8'h25;
			8'hfa : r_dout = 8'hac;
			8'hfb : r_dout = 8'haf;
			8'hfc : r_dout = 8'h12;
			8'hfd : r_dout = 8'h03;
			8'hfe : r_dout = 8'he2;
			8'hff : r_dout = 8'hf2;
        endcase
    end

endmodule

