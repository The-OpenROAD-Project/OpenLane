// Pardis Pashakhanloo
// 91106449


module TEA (
	output done,
	output [31:0] enc_v0,
	output [31:0] enc_v1,
	input [31:0] delta,
	input [31:0] k0, k1, k2, k3,
	input [31:0] _v0, _v1,
	input clk
);

	wire [31:0] q_xor;
	reg [31:0] q_xor_reg;

	wire [31:0] m1, m2, x1, x2;

	wire [31:0] v0, v1;
	wire [31:0] sum;

	reg [10:0] step;

	initial step = 0;

	always @(posedge clk)
	begin
		q_xor_reg = q_xor;
		step = step + 1;
	end

	//initial $monitor($time, ": step=%d, v0=%d, v1=%d, sum=%d, q_xor_reg=%d", step, v0, v1, sum, q_xor_reg);

	assign q_xor = (m1 + m2) ^ x2;

	assign m1 = //iter 0
				(step == 0) ? sum :
				(step == 1) ? q_xor_reg :
				(step == 2) ? {v1[27:0], 4'b0} :
				(step == 3) ? sum :
				(step == 4) ? {5'b0, v1[31:5]} :
				(step == 5) ? q_xor_reg :
				(step == 6) ? q_xor_reg :
				(step == 7) ? q_xor_reg :
				(step == 8) ? {v0[27:0], 4'b0} :
				(step == 9) ? sum :
				(step == 10) ? {5'b0, v0[31:5]} :
				(step == 11) ? q_xor_reg : 
				(step == 12) ? q_xor_reg : 

				//iter 1
				(step == 13) ? sum :
				(step == 14) ? q_xor_reg :
				(step == 15) ? {v1[27:0], 4'b0} :
				(step == 16) ? sum :
				(step == 17) ? {5'b0, v1[31:5]} :
				(step == 18) ? q_xor_reg :
				(step == 19) ? q_xor_reg :
				(step == 20) ? q_xor_reg :
				(step == 21) ? {v0[27:0], 4'b0} :
				(step == 22) ? sum :
				(step == 23) ? {5'b0, v0[31:5]} :
				(step == 24) ? q_xor_reg : 
				(step == 25) ? q_xor_reg : 

				//iter 2
				(step == 26) ? sum :
				(step == 27) ? q_xor_reg :
				(step == 28) ? {v1[27:0], 4'b0} :
				(step == 29) ? sum :
				(step == 30) ? {5'b0, v1[31:5]} :
				(step == 31) ? q_xor_reg :
				(step == 32) ? q_xor_reg :
				(step == 33) ? q_xor_reg :
				(step == 34) ? {v0[27:0], 4'b0} :
				(step == 35) ? sum :
				(step == 36) ? {5'b0, v0[31:5]} :
				(step == 37) ? q_xor_reg : 
				(step == 38) ? q_xor_reg : 

				//iter 3
				(step == 39) ? sum :
				(step == 40) ? q_xor_reg :
				(step == 41) ? {v1[27:0], 4'b0} :
				(step == 42) ? sum :
				(step == 43) ? {5'b0, v1[31:5]} :
				(step == 44) ? q_xor_reg :
				(step == 45) ? q_xor_reg :
				(step == 46) ? q_xor_reg :
				(step == 47) ? {v0[27:0], 4'b0} :
				(step == 48) ? sum :
				(step == 49) ? {5'b0, v0[31:5]} :
				(step == 50) ? q_xor_reg : 
				(step == 51) ? q_xor_reg : 

				//iter 4
				(step == 52) ? sum :
				(step == 53) ? q_xor_reg :
				(step == 54) ? {v1[27:0], 4'b0} :
				(step == 55) ? sum :
				(step == 56) ? {5'b0, v1[31:5]} :
				(step == 57) ? q_xor_reg :
				(step == 58) ? q_xor_reg :
				(step == 59) ? q_xor_reg :
				(step == 60) ? {v0[27:0], 4'b0} :
				(step == 61) ? sum :
				(step == 62) ? {5'b0, v0[31:5]} :
				(step == 63) ? q_xor_reg : 
				(step == 64) ? q_xor_reg : 

				//iter 5
				(step == 65) ? sum :
				(step == 66) ? q_xor_reg :
				(step == 67) ? {v1[27:0], 4'b0} :
				(step == 68) ? sum :
				(step == 69) ? {5'b0, v1[31:5]} :
				(step == 70) ? q_xor_reg :
				(step == 71) ? q_xor_reg :
				(step == 72) ? q_xor_reg :
				(step == 73) ? {v0[27:0], 4'b0} :
				(step == 74) ? sum :
				(step == 75) ? {5'b0, v0[31:5]} :
				(step == 76) ? q_xor_reg : 
				(step == 77) ? q_xor_reg : 

				//iter 6
				(step == 78) ? sum :
				(step == 79) ? q_xor_reg :
				(step == 80) ? {v1[27:0], 4'b0} :
				(step == 81) ? sum :
				(step == 82) ? {5'b0, v1[31:5]} :
				(step == 83) ? q_xor_reg :
				(step == 84) ? q_xor_reg :
				(step == 85) ? q_xor_reg :
				(step == 86) ? {v0[27:0], 4'b0} :
				(step == 87) ? sum :
				(step == 88) ? {5'b0, v0[31:5]} :
				(step == 89) ? q_xor_reg : 
				(step == 90) ? q_xor_reg : 

				//iter 7
				(step == 91) ? sum :
				(step == 92) ? q_xor_reg :
				(step == 93) ? {v1[27:0], 4'b0} :
				(step == 94) ? sum :
				(step == 95) ? {5'b0, v1[31:5]} :
				(step == 96) ? q_xor_reg :
				(step == 97) ? q_xor_reg :
				(step == 98) ? q_xor_reg :
				(step == 99) ? {v0[27:0], 4'b0} :
				(step == 100) ? sum :
				(step == 101) ? {5'b0, v0[31:5]} :
				(step == 102) ? q_xor_reg : 
				(step == 103) ? q_xor_reg : 

				//iter 8
				(step == 104) ? sum :
				(step == 105) ? q_xor_reg :
				(step == 106) ? {v1[27:0], 4'b0} :
				(step == 107) ? sum :
				(step == 108) ? {5'b0, v1[31:5]} :
				(step == 109) ? q_xor_reg :
				(step == 110) ? q_xor_reg :
				(step == 111) ? q_xor_reg :
				(step == 112) ? {v0[27:0], 4'b0} :
				(step == 113) ? sum :
				(step == 114) ? {5'b0, v0[31:5]} :
				(step == 115) ? q_xor_reg : 
				(step == 116) ? q_xor_reg : 

				//iter 9
				(step == 117) ? sum :
				(step == 118) ? q_xor_reg :
				(step == 119) ? {v1[27:0], 4'b0} :
				(step == 120) ? sum :
				(step == 121) ? {5'b0, v1[31:5]} :
				(step == 122) ? q_xor_reg :
				(step == 123) ? q_xor_reg :
				(step == 124) ? q_xor_reg :
				(step == 125) ? {v0[27:0], 4'b0} :
				(step == 126) ? sum :
				(step == 127) ? {5'b0, v0[31:5]} :
				(step == 128) ? q_xor_reg : 
				(step == 129) ? q_xor_reg : 

				//iter 10
				(step == 130) ? sum :
				(step == 131) ? q_xor_reg :
				(step == 132) ? {v1[27:0], 4'b0} :
				(step == 133) ? sum :
				(step == 134) ? {5'b0, v1[31:5]} :
				(step == 135) ? q_xor_reg :
				(step == 136) ? q_xor_reg :
				(step == 137) ? q_xor_reg :
				(step == 138) ? {v0[27:0], 4'b0} :
				(step == 139) ? sum :
				(step == 140) ? {5'b0, v0[31:5]} :
				(step == 141) ? q_xor_reg : 
				(step == 142) ? q_xor_reg : 

				//iter 11
				(step == 143) ? sum :
				(step == 144) ? q_xor_reg :
				(step == 145) ? {v1[27:0], 4'b0} :
				(step == 146) ? sum :
				(step == 147) ? {5'b0, v1[31:5]} :
				(step == 148) ? q_xor_reg :
				(step == 149) ? q_xor_reg :
				(step == 150) ? q_xor_reg :
				(step == 151) ? {v0[27:0], 4'b0} :
				(step == 152) ? sum :
				(step == 153) ? {5'b0, v0[31:5]} :
				(step == 154) ? q_xor_reg : 
				(step == 155) ? q_xor_reg : 

				//iter 12
				(step == 156) ? sum :
				(step == 157) ? q_xor_reg :
				(step == 158) ? {v1[27:0], 4'b0} :
				(step == 159) ? sum :
				(step == 160) ? {5'b0, v1[31:5]} :
				(step == 161) ? q_xor_reg :
				(step == 162) ? q_xor_reg :
				(step == 163) ? q_xor_reg :
				(step == 164) ? {v0[27:0], 4'b0} :
				(step == 165) ? sum :
				(step == 166) ? {5'b0, v0[31:5]} :
				(step == 167) ? q_xor_reg : 
				(step == 168) ? q_xor_reg : 

				//iter 13
				(step == 169) ? sum :
				(step == 170) ? q_xor_reg :
				(step == 171) ? {v1[27:0], 4'b0} :
				(step == 172) ? sum :
				(step == 173) ? {5'b0, v1[31:5]} :
				(step == 174) ? q_xor_reg :
				(step == 175) ? q_xor_reg :
				(step == 176) ? q_xor_reg :
				(step == 177) ? {v0[27:0], 4'b0} :
				(step == 178) ? sum :
				(step == 179) ? {5'b0, v0[31:5]} :
				(step == 180) ? q_xor_reg : 
				(step == 181) ? q_xor_reg : 

				//iter 14
				(step == 182) ? sum :
				(step == 183) ? q_xor_reg :
				(step == 184) ? {v1[27:0], 4'b0} :
				(step == 185) ? sum :
				(step == 186) ? {5'b0, v1[31:5]} :
				(step == 187) ? q_xor_reg :
				(step == 188) ? q_xor_reg :
				(step == 189) ? q_xor_reg :
				(step == 190) ? {v0[27:0], 4'b0} :
				(step == 191) ? sum :
				(step == 192) ? {5'b0, v0[31:5]} :
				(step == 193) ? q_xor_reg : 
				(step == 194) ? q_xor_reg : 

				//iter 15
				(step == 195) ? sum :
				(step == 196) ? q_xor_reg :
				(step == 197) ? {v1[27:0], 4'b0} :
				(step == 198) ? sum :
				(step == 199) ? {5'b0, v1[31:5]} :
				(step == 200) ? q_xor_reg :
				(step == 201) ? q_xor_reg :
				(step == 202) ? q_xor_reg :
				(step == 203) ? {v0[27:0], 4'b0} :
				(step == 204) ? sum :
				(step == 205) ? {5'b0, v0[31:5]} :
				(step == 206) ? q_xor_reg : 
				(step == 207) ? q_xor_reg : 

				//iter 16
				(step == 208) ? sum :
				(step == 209) ? q_xor_reg :
				(step == 210) ? {v1[27:0], 4'b0} :
				(step == 211) ? sum :
				(step == 212) ? {5'b0, v1[31:5]} :
				(step == 213) ? q_xor_reg :
				(step == 214) ? q_xor_reg :
				(step == 215) ? q_xor_reg :
				(step == 216) ? {v0[27:0], 4'b0} :
				(step == 217) ? sum :
				(step == 218) ? {5'b0, v0[31:5]} :
				(step == 219) ? q_xor_reg : 
				(step == 220) ? q_xor_reg : 

				//iter 17
				(step == 221) ? sum :
				(step == 222) ? q_xor_reg :
				(step == 223) ? {v1[27:0], 4'b0} :
				(step == 224) ? sum :
				(step == 225) ? {5'b0, v1[31:5]} :
				(step == 226) ? q_xor_reg :
				(step == 227) ? q_xor_reg :
				(step == 228) ? q_xor_reg :
				(step == 229) ? {v0[27:0], 4'b0} :
				(step == 230) ? sum :
				(step == 231) ? {5'b0, v0[31:5]} :
				(step == 232) ? q_xor_reg : 
				(step == 233) ? q_xor_reg : 

				//iter 18
				(step == 234) ? sum :
				(step == 235) ? q_xor_reg :
				(step == 236) ? {v1[27:0], 4'b0} :
				(step == 237) ? sum :
				(step == 238) ? {5'b0, v1[31:5]} :
				(step == 239) ? q_xor_reg :
				(step == 240) ? q_xor_reg :
				(step == 241) ? q_xor_reg :
				(step == 242) ? {v0[27:0], 4'b0} :
				(step == 243) ? sum :
				(step == 244) ? {5'b0, v0[31:5]} :
				(step == 245) ? q_xor_reg : 
				(step == 246) ? q_xor_reg : 

				//iter 19
				(step == 247) ? sum :
				(step == 248) ? q_xor_reg :
				(step == 249) ? {v1[27:0], 4'b0} :
				(step == 250) ? sum :
				(step == 251) ? {5'b0, v1[31:5]} :
				(step == 252) ? q_xor_reg :
				(step == 253) ? q_xor_reg :
				(step == 254) ? q_xor_reg :
				(step == 255) ? {v0[27:0], 4'b0} :
				(step == 256) ? sum :
				(step == 257) ? {5'b0, v0[31:5]} :
				(step == 258) ? q_xor_reg : 
				(step == 259) ? q_xor_reg : 

				//iter 20
				(step == 260) ? sum :
				(step == 261) ? q_xor_reg :
				(step == 262) ? {v1[27:0], 4'b0} :
				(step == 263) ? sum :
				(step == 264) ? {5'b0, v1[31:5]} :
				(step == 265) ? q_xor_reg :
				(step == 266) ? q_xor_reg :
				(step == 267) ? q_xor_reg :
				(step == 268) ? {v0[27:0], 4'b0} :
				(step == 269) ? sum :
				(step == 270) ? {5'b0, v0[31:5]} :
				(step == 271) ? q_xor_reg : 
				(step == 272) ? q_xor_reg : 

				//iter 21
				(step == 273) ? sum :
				(step == 274) ? q_xor_reg :
				(step == 275) ? {v1[27:0], 4'b0} :
				(step == 276) ? sum :
				(step == 277) ? {5'b0, v1[31:5]} :
				(step == 278) ? q_xor_reg :
				(step == 279) ? q_xor_reg :
				(step == 280) ? q_xor_reg :
				(step == 281) ? {v0[27:0], 4'b0} :
				(step == 282) ? sum :
				(step == 283) ? {5'b0, v0[31:5]} :
				(step == 284) ? q_xor_reg : 
				(step == 285) ? q_xor_reg : 

				//iter 22
				(step == 286) ? sum :
				(step == 287) ? q_xor_reg :
				(step == 288) ? {v1[27:0], 4'b0} :
				(step == 289) ? sum :
				(step == 290) ? {5'b0, v1[31:5]} :
				(step == 291) ? q_xor_reg :
				(step == 292) ? q_xor_reg :
				(step == 293) ? q_xor_reg :
				(step == 294) ? {v0[27:0], 4'b0} :
				(step == 295) ? sum :
				(step == 296) ? {5'b0, v0[31:5]} :
				(step == 297) ? q_xor_reg : 
				(step == 298) ? q_xor_reg : 

				//iter 23
				(step == 299) ? sum :
				(step == 300) ? q_xor_reg :
				(step == 301) ? {v1[27:0], 4'b0} :
				(step == 302) ? sum :
				(step == 303) ? {5'b0, v1[31:5]} :
				(step == 304) ? q_xor_reg :
				(step == 305) ? q_xor_reg :
				(step == 306) ? q_xor_reg :
				(step == 307) ? {v0[27:0], 4'b0} :
				(step == 308) ? sum :
				(step == 309) ? {5'b0, v0[31:5]} :
				(step == 310) ? q_xor_reg : 
				(step == 311) ? q_xor_reg : 

				//iter 24
				(step == 312) ? sum :
				(step == 313) ? q_xor_reg :
				(step == 314) ? {v1[27:0], 4'b0} :
				(step == 315) ? sum :
				(step == 316) ? {5'b0, v1[31:5]} :
				(step == 317) ? q_xor_reg :
				(step == 318) ? q_xor_reg :
				(step == 319) ? q_xor_reg :
				(step == 320) ? {v0[27:0], 4'b0} :
				(step == 321) ? sum :
				(step == 322) ? {5'b0, v0[31:5]} :
				(step == 323) ? q_xor_reg : 
				(step == 324) ? q_xor_reg : 

				//iter 25
				(step == 325) ? sum :
				(step == 326) ? q_xor_reg :
				(step == 327) ? {v1[27:0], 4'b0} :
				(step == 328) ? sum :
				(step == 329) ? {5'b0, v1[31:5]} :
				(step == 330) ? q_xor_reg :
				(step == 331) ? q_xor_reg :
				(step == 332) ? q_xor_reg :
				(step == 333) ? {v0[27:0], 4'b0} :
				(step == 334) ? sum :
				(step == 335) ? {5'b0, v0[31:5]} :
				(step == 336) ? q_xor_reg : 
				(step == 337) ? q_xor_reg : 

				//iter 26
				(step == 338) ? sum :
				(step == 339) ? q_xor_reg :
				(step == 340) ? {v1[27:0], 4'b0} :
				(step == 341) ? sum :
				(step == 342) ? {5'b0, v1[31:5]} :
				(step == 343) ? q_xor_reg :
				(step == 344) ? q_xor_reg :
				(step == 345) ? q_xor_reg :
				(step == 346) ? {v0[27:0], 4'b0} :
				(step == 347) ? sum :
				(step == 348) ? {5'b0, v0[31:5]} :
				(step == 349) ? q_xor_reg : 
				(step == 350) ? q_xor_reg : 

				//iter 27
				(step == 351) ? sum :
				(step == 352) ? q_xor_reg :
				(step == 353) ? {v1[27:0], 4'b0} :
				(step == 354) ? sum :
				(step == 355) ? {5'b0, v1[31:5]} :
				(step == 356) ? q_xor_reg :
				(step == 357) ? q_xor_reg :
				(step == 358) ? q_xor_reg :
				(step == 359) ? {v0[27:0], 4'b0} :
				(step == 360) ? sum :
				(step == 361) ? {5'b0, v0[31:5]} :
				(step == 362) ? q_xor_reg : 
				(step == 363) ? q_xor_reg : 

				//iter 28
				(step == 364) ? sum :
				(step == 365) ? q_xor_reg :
				(step == 366) ? {v1[27:0], 4'b0} :
				(step == 367) ? sum :
				(step == 368) ? {5'b0, v1[31:5]} :
				(step == 369) ? q_xor_reg :
				(step == 370) ? q_xor_reg :
				(step == 371) ? q_xor_reg :
				(step == 372) ? {v0[27:0], 4'b0} :
				(step == 373) ? sum :
				(step == 374) ? {5'b0, v0[31:5]} :
				(step == 375) ? q_xor_reg : 
				(step == 376) ? q_xor_reg : 

				//iter 29
				(step == 377) ? sum :
				(step == 378) ? q_xor_reg :
				(step == 379) ? {v1[27:0], 4'b0} :
				(step == 380) ? sum :
				(step == 381) ? {5'b0, v1[31:5]} :
				(step == 382) ? q_xor_reg :
				(step == 383) ? q_xor_reg :
				(step == 384) ? q_xor_reg :
				(step == 385) ? {v0[27:0], 4'b0} :
				(step == 386) ? sum :
				(step == 387) ? {5'b0, v0[31:5]} :
				(step == 388) ? q_xor_reg : 
				(step == 389) ? q_xor_reg : 

				//iter 30
				(step == 390) ? sum :
				(step == 391) ? q_xor_reg :
				(step == 392) ? {v1[27:0], 4'b0} :
				(step == 393) ? sum :
				(step == 394) ? {5'b0, v1[31:5]} :
				(step == 395) ? q_xor_reg :
				(step == 396) ? q_xor_reg :
				(step == 397) ? q_xor_reg :
				(step == 398) ? {v0[27:0], 4'b0} :
				(step == 399) ? sum :
				(step == 400) ? {5'b0, v0[31:5]} :
				(step == 401) ? q_xor_reg : 
				(step == 402) ? q_xor_reg : 

				//iter 31
				(step == 403) ? sum :
				(step == 404) ? q_xor_reg :
				(step == 405) ? {v1[27:0], 4'b0} :
				(step == 406) ? sum :
				(step == 407) ? {5'b0, v1[31:5]} :
				(step == 408) ? q_xor_reg :
				(step == 409) ? q_xor_reg :
				(step == 410) ? q_xor_reg :
				(step == 411) ? {v0[27:0], 4'b0} :
				(step == 412) ? sum :
				(step == 413) ? {5'b0, v0[31:5]} :
				(step == 414) ? q_xor_reg : q_xor_reg;


	assign m2 = //iter 0
				(step == 0) ? delta :
				(step == 1) ? 0 :
				(step == 2) ? k0 :
				(step == 3) ? v1 :
				(step == 4) ? k1 :
				(step == 5) ? v0 :
				(step == 6) ? 0 :
				(step == 7) ? 0 :
				(step == 8) ? k2 :
				(step == 9) ? v0 :
				(step == 10) ? k3 :
				(step == 11) ? v1 :
				(step == 12) ? 0 :

				//iter 1
				(step == 13) ? delta :
				(step == 14) ? 0 :
				(step == 15) ? k0 :
				(step == 16) ? v1 :
				(step == 17) ? k1 :
				(step == 18) ? v0 :
				(step == 19) ? 0 :
				(step == 20) ? 0 :
				(step == 21) ? k2 :
				(step == 22) ? v0 :
				(step == 23) ? k3 :
				(step == 24) ? v1 :
				(step == 25) ? 0 :

				//iter 2
				(step == 26) ? delta :
				(step == 27) ? 0 :
				(step == 28) ? k0 :
				(step == 29) ? v1 :
				(step == 30) ? k1 :
				(step == 31) ? v0 :
				(step == 32) ? 0 :
				(step == 33) ? 0 :
				(step == 34) ? k2 :
				(step == 35) ? v0 :
				(step == 36) ? k3 :
				(step == 37) ? v1 :
				(step == 38) ? 0 :

				//iter 3
				(step == 39) ? delta :
				(step == 40) ? 0 :
				(step == 41) ? k0 :
				(step == 42) ? v1 :
				(step == 43) ? k1 :
				(step == 44) ? v0 :
				(step == 45) ? 0 :
				(step == 46) ? 0 :
				(step == 47) ? k2 :
				(step == 48) ? v0 :
				(step == 49) ? k3 :
				(step == 50) ? v1 :
				(step == 51) ? 0 :

				//iter 4
				(step == 52) ? delta :
				(step == 53) ? 0 :
				(step == 54) ? k0 :
				(step == 55) ? v1 :
				(step == 56) ? k1 :
				(step == 57) ? v0 :
				(step == 58) ? 0 :
				(step == 59) ? 0 :
				(step == 60) ? k2 :
				(step == 61) ? v0 :
				(step == 62) ? k3 :
				(step == 63) ? v1 :
				(step == 64) ? 0 :

				//iter 5
				(step == 65) ? delta :
				(step == 66) ? 0 :
				(step == 67) ? k0 :
				(step == 68) ? v1 :
				(step == 69) ? k1 :
				(step == 70) ? v0 :
				(step == 71) ? 0 :
				(step == 72) ? 0 :
				(step == 73) ? k2 :
				(step == 74) ? v0 :
				(step == 75) ? k3 :
				(step == 76) ? v1 :
				(step == 77) ? 0 :

				//iter 6
				(step == 78) ? delta :
				(step == 79) ? 0 :
				(step == 80) ? k0 :
				(step == 81) ? v1 :
				(step == 82) ? k1 :
				(step == 83) ? v0 :
				(step == 84) ? 0 :
				(step == 85) ? 0 :
				(step == 86) ? k2 :
				(step == 87) ? v0 :
				(step == 88) ? k3 :
				(step == 89) ? v1 :
				(step == 90) ? 0 :

				//iter 7
				(step == 91) ? delta :
				(step == 92) ? 0 :
				(step == 93) ? k0 :
				(step == 94) ? v1 :
				(step == 95) ? k1 :
				(step == 96) ? v0 :
				(step == 97) ? 0 :
				(step == 98) ? 0 :
				(step == 99) ? k2 :
				(step == 100) ? v0 :
				(step == 101) ? k3 :
				(step == 102) ? v1 :
				(step == 103) ? 0 :

				//iter 8
				(step == 104) ? delta :
				(step == 105) ? 0 :
				(step == 106) ? k0 :
				(step == 107) ? v1 :
				(step == 108) ? k1 :
				(step == 109) ? v0 :
				(step == 110) ? 0 :
				(step == 111) ? 0 :
				(step == 112) ? k2 :
				(step == 113) ? v0 :
				(step == 114) ? k3 :
				(step == 115) ? v1 :
				(step == 116) ? 0 :

				//iter 9
				(step == 117) ? delta :
				(step == 118) ? 0 :
				(step == 119) ? k0 :
				(step == 120) ? v1 :
				(step == 121) ? k1 :
				(step == 122) ? v0 :
				(step == 123) ? 0 :
				(step == 124) ? 0 :
				(step == 125) ? k2 :
				(step == 126) ? v0 :
				(step == 127) ? k3 :
				(step == 128) ? v1 :
				(step == 129) ? 0 :

				//iter 10
				(step == 130) ? delta :
				(step == 131) ? 0 :
				(step == 132) ? k0 :
				(step == 133) ? v1 :
				(step == 134) ? k1 :
				(step == 135) ? v0 :
				(step == 136) ? 0 :
				(step == 137) ? 0 :
				(step == 138) ? k2 :
				(step == 139) ? v0 :
				(step == 140) ? k3 :
				(step == 141) ? v1 :
				(step == 142) ? 0 :

				//iter 11
				(step == 143) ? delta :
				(step == 144) ? 0 :
				(step == 145) ? k0 :
				(step == 146) ? v1 :
				(step == 147) ? k1 :
				(step == 148) ? v0 :
				(step == 149) ? 0 :
				(step == 150) ? 0 :
				(step == 151) ? k2 :
				(step == 152) ? v0 :
				(step == 153) ? k3 :
				(step == 154) ? v1 :
				(step == 155) ? 0 :

				//iter 12
				(step == 156) ? delta :
				(step == 157) ? 0 :
				(step == 158) ? k0 :
				(step == 159) ? v1 :
				(step == 160) ? k1 :
				(step == 161) ? v0 :
				(step == 162) ? 0 :
				(step == 163) ? 0 :
				(step == 164) ? k2 :
				(step == 165) ? v0 :
				(step == 166) ? k3 :
				(step == 167) ? v1 :
				(step == 168) ? 0 :

				//iter 13
				(step == 169) ? delta :
				(step == 170) ? 0 :
				(step == 171) ? k0 :
				(step == 172) ? v1 :
				(step == 173) ? k1 :
				(step == 174) ? v0 :
				(step == 175) ? 0 :
				(step == 176) ? 0 :
				(step == 177) ? k2 :
				(step == 178) ? v0 :
				(step == 179) ? k3 :
				(step == 180) ? v1 :
				(step == 181) ? 0 :

				//iter 14
				(step == 182) ? delta :
				(step == 183) ? 0 :
				(step == 184) ? k0 :
				(step == 185) ? v1 :
				(step == 186) ? k1 :
				(step == 187) ? v0 :
				(step == 188) ? 0 :
				(step == 189) ? 0 :
				(step == 190) ? k2 :
				(step == 191) ? v0 :
				(step == 192) ? k3 :
				(step == 193) ? v1 :
				(step == 194) ? 0 :

				//iter 15
				(step == 195) ? delta :
				(step == 196) ? 0 :
				(step == 197) ? k0 :
				(step == 198) ? v1 :
				(step == 199) ? k1 :
				(step == 200) ? v0 :
				(step == 201) ? 0 :
				(step == 202) ? 0 :
				(step == 203) ? k2 :
				(step == 204) ? v0 :
				(step == 205) ? k3 :
				(step == 206) ? v1 :
				(step == 207) ? 0 :

				//iter 16
				(step == 208) ? delta :
				(step == 209) ? 0 :
				(step == 210) ? k0 :
				(step == 211) ? v1 :
				(step == 212) ? k1 :
				(step == 213) ? v0 :
				(step == 214) ? 0 :
				(step == 215) ? 0 :
				(step == 216) ? k2 :
				(step == 217) ? v0 :
				(step == 218) ? k3 :
				(step == 219) ? v1 :
				(step == 220) ? 0 :

				//iter 17
				(step == 221) ? delta :
				(step == 222) ? 0 :
				(step == 223) ? k0 :
				(step == 224) ? v1 :
				(step == 225) ? k1 :
				(step == 226) ? v0 :
				(step == 227) ? 0 :
				(step == 228) ? 0 :
				(step == 229) ? k2 :
				(step == 230) ? v0 :
				(step == 231) ? k3 :
				(step == 232) ? v1 :
				(step == 233) ? 0 :

				//iter 18
				(step == 234) ? delta :
				(step == 235) ? 0 :
				(step == 236) ? k0 :
				(step == 237) ? v1 :
				(step == 238) ? k1 :
				(step == 239) ? v0 :
				(step == 240) ? 0 :
				(step == 241) ? 0 :
				(step == 242) ? k2 :
				(step == 243) ? v0 :
				(step == 244) ? k3 :
				(step == 245) ? v1 :
				(step == 246) ? 0 :

				//iter 19
				(step == 247) ? delta :
				(step == 248) ? 0 :
				(step == 249) ? k0 :
				(step == 250) ? v1 :
				(step == 251) ? k1 :
				(step == 252) ? v0 :
				(step == 253) ? 0 :
				(step == 254) ? 0 :
				(step == 255) ? k2 :
				(step == 256) ? v0 :
				(step == 257) ? k3 :
				(step == 258) ? v1 :
				(step == 259) ? 0 :

				//iter 20
				(step == 260) ? delta :
				(step == 261) ? 0 :
				(step == 262) ? k0 :
				(step == 263) ? v1 :
				(step == 264) ? k1 :
				(step == 265) ? v0 :
				(step == 266) ? 0 :
				(step == 267) ? 0 :
				(step == 268) ? k2 :
				(step == 269) ? v0 :
				(step == 270) ? k3 :
				(step == 271) ? v1 :
				(step == 272) ? 0 :

				//iter 21
				(step == 273) ? delta :
				(step == 274) ? 0 :
				(step == 275) ? k0 :
				(step == 276) ? v1 :
				(step == 277) ? k1 :
				(step == 278) ? v0 :
				(step == 279) ? 0 :
				(step == 280) ? 0 :
				(step == 281) ? k2 :
				(step == 282) ? v0 :
				(step == 283) ? k3 :
				(step == 284) ? v1 :
				(step == 285) ? 0 :

				//iter 22
				(step == 286) ? delta :
				(step == 287) ? 0 :
				(step == 288) ? k0 :
				(step == 289) ? v1 :
				(step == 290) ? k1 :
				(step == 291) ? v0 :
				(step == 292) ? 0 :
				(step == 293) ? 0 :
				(step == 294) ? k2 :
				(step == 295) ? v0 :
				(step == 296) ? k3 :
				(step == 297) ? v1 :
				(step == 298) ? 0 :

				//iter 23
				(step == 299) ? delta :
				(step == 300) ? 0 :
				(step == 301) ? k0 :
				(step == 302) ? v1 :
				(step == 303) ? k1 :
				(step == 304) ? v0 :
				(step == 305) ? 0 :
				(step == 306) ? 0 :
				(step == 307) ? k2 :
				(step == 308) ? v0 :
				(step == 309) ? k3 :
				(step == 310) ? v1 :
				(step == 311) ? 0 :

				//iter 24
				(step == 312) ? delta :
				(step == 313) ? 0 :
				(step == 314) ? k0 :
				(step == 315) ? v1 :
				(step == 316) ? k1 :
				(step == 317) ? v0 :
				(step == 318) ? 0 :
				(step == 319) ? 0 :
				(step == 320) ? k2 :
				(step == 321) ? v0 :
				(step == 322) ? k3 :
				(step == 323) ? v1 :
				(step == 324) ? 0 :

				//iter 25
				(step == 325) ? delta :
				(step == 326) ? 0 :
				(step == 327) ? k0 :
				(step == 328) ? v1 :
				(step == 329) ? k1 :
				(step == 330) ? v0 :
				(step == 331) ? 0 :
				(step == 332) ? 0 :
				(step == 333) ? k2 :
				(step == 334) ? v0 :
				(step == 335) ? k3 :
				(step == 336) ? v1 :
				(step == 337) ? 0 :

				//iter 26
				(step == 338) ? delta :
				(step == 339) ? 0 :
				(step == 340) ? k0 :
				(step == 341) ? v1 :
				(step == 342) ? k1 :
				(step == 343) ? v0 :
				(step == 344) ? 0 :
				(step == 345) ? 0 :
				(step == 346) ? k2 :
				(step == 347) ? v0 :
				(step == 348) ? k3 :
				(step == 349) ? v1 :
				(step == 350) ? 0 :

				//iter 27
				(step == 351) ? delta :
				(step == 352) ? 0 :
				(step == 353) ? k0 :
				(step == 354) ? v1 :
				(step == 355) ? k1 :
				(step == 356) ? v0 :
				(step == 357) ? 0 :
				(step == 358) ? 0 :
				(step == 359) ? k2 :
				(step == 360) ? v0 :
				(step == 361) ? k3 :
				(step == 362) ? v1 :
				(step == 363) ? 0 :

				//iter 28
				(step == 364) ? delta :
				(step == 365) ? 0 :
				(step == 366) ? k0 :
				(step == 367) ? v1 :
				(step == 368) ? k1 :
				(step == 369) ? v0 :
				(step == 370) ? 0 :
				(step == 371) ? 0 :
				(step == 372) ? k2 :
				(step == 373) ? v0 :
				(step == 374) ? k3 :
				(step == 375) ? v1 :
				(step == 376) ? 0 :

				//iter 29
				(step == 377) ? delta :
				(step == 378) ? 0 :
				(step == 379) ? k0 :
				(step == 380) ? v1 :
				(step == 381) ? k1 :
				(step == 382) ? v0 :
				(step == 383) ? 0 :
				(step == 384) ? 0 :
				(step == 385) ? k2 :
				(step == 386) ? v0 :
				(step == 387) ? k3 :
				(step == 388) ? v1 :
				(step == 389) ? 0 :

				//iter 30
				(step == 390) ? delta :
				(step == 391) ? 0 :
				(step == 392) ? k0 :
				(step == 393) ? v1 :
				(step == 394) ? k1 :
				(step == 395) ? v0 :
				(step == 396) ? 0 :
				(step == 397) ? 0 :
				(step == 398) ? k2 :
				(step == 399) ? v0 :
				(step == 400) ? k3 :
				(step == 401) ? v1 :
				(step == 402) ? 0 :

				//iter 31
				(step == 403) ? delta :
				(step == 404) ? 0 :
				(step == 405) ? k0 :
				(step == 406) ? v1 :
				(step == 407) ? k1 :
				(step == 408) ? v0 :
				(step == 409) ? 0 :
				(step == 410) ? 0 :
				(step == 411) ? k2 :
				(step == 412) ? v0 :
				(step == 413) ? k3 :
				(step == 414) ? v1 : 0;


	assign x2 = //iter 0
				(step == 0) ? 0 :
				(step == 1) ? 0 :
				(step == 2) ? 0 :
				(step == 3) ? q_xor_reg :
				(step == 4) ? q_xor_reg :
				(step == 5) ? 0 :
				(step == 6) ? 0 :
				(step == 7) ? 0 :
				(step == 8) ? 0 :
				(step == 9) ? q_xor_reg :
				(step == 10) ? q_xor_reg :
				(step == 11) ? 0 :
				(step == 12) ? 0 :

				//iter 1
				(step == 13) ? 0 :
				(step == 14) ? 0 :
				(step == 15) ? 0 :
				(step == 16) ? q_xor_reg :
				(step == 17) ? q_xor_reg :
				(step == 18) ? 0 :
				(step == 19) ? 0 :
				(step == 20) ? 0 :
				(step == 21) ? 0 :
				(step == 22) ? q_xor_reg :
				(step == 23) ? q_xor_reg :
				(step == 24) ? 0 :
				(step == 25) ? 0 :

				//iter 2
				(step == 26) ? 0 :
				(step == 27) ? 0 :
				(step == 28) ? 0 :
				(step == 29) ? q_xor_reg :
				(step == 30) ? q_xor_reg :
				(step == 31) ? 0 :
				(step == 32) ? 0 :
				(step == 33) ? 0 :
				(step == 34) ? 0 :
				(step == 35) ? q_xor_reg :
				(step == 36) ? q_xor_reg :
				(step == 37) ? 0 :
				(step == 38) ? 0 :

				//iter 3
				(step == 39) ? 0 :
				(step == 40) ? 0 :
				(step == 41) ? 0 :
				(step == 42) ? q_xor_reg :
				(step == 43) ? q_xor_reg :
				(step == 44) ? 0 :
				(step == 45) ? 0 :
				(step == 46) ? 0 :
				(step == 47) ? 0 :
				(step == 48) ? q_xor_reg :
				(step == 49) ? q_xor_reg :
				(step == 50) ? 0 :
				(step == 51) ? 0 :

				//iter 4
				(step == 52) ? 0 :
				(step == 53) ? 0 :
				(step == 54) ? 0 :
				(step == 55) ? q_xor_reg :
				(step == 56) ? q_xor_reg :
				(step == 57) ? 0 :
				(step == 58) ? 0 :
				(step == 59) ? 0 :
				(step == 60) ? 0 :
				(step == 61) ? q_xor_reg :
				(step == 62) ? q_xor_reg :
				(step == 63) ? 0 :
				(step == 64) ? 0 :

				//iter 5
				(step == 65) ? 0 :
				(step == 66) ? 0 :
				(step == 67) ? 0 :
				(step == 68) ? q_xor_reg :
				(step == 69) ? q_xor_reg :
				(step == 70) ? 0 :
				(step == 71) ? 0 :
				(step == 72) ? 0 :
				(step == 73) ? 0 :
				(step == 74) ? q_xor_reg :
				(step == 75) ? q_xor_reg :
				(step == 76) ? 0 :
				(step == 77) ? 0 :

				//iter 6
				(step == 78) ? 0 :
				(step == 79) ? 0 :
				(step == 80) ? 0 :
				(step == 81) ? q_xor_reg :
				(step == 82) ? q_xor_reg :
				(step == 83) ? 0 :
				(step == 84) ? 0 :
				(step == 85) ? 0 :
				(step == 86) ? 0 :
				(step == 87) ? q_xor_reg :
				(step == 88) ? q_xor_reg :
				(step == 89) ? 0 :
				(step == 90) ? 0 :

				//iter 7
				(step == 91) ? 0 :
				(step == 92) ? 0 :
				(step == 93) ? 0 :
				(step == 94) ? q_xor_reg :
				(step == 95) ? q_xor_reg :
				(step == 96) ? 0 :
				(step == 97) ? 0 :
				(step == 98) ? 0 :
				(step == 99) ? 0 :
				(step == 100) ? q_xor_reg :
				(step == 101) ? q_xor_reg :
				(step == 102) ? 0 :
				(step == 103) ? 0 :

				//iter 8
				(step == 104) ? 0 :
				(step == 105) ? 0 :
				(step == 106) ? 0 :
				(step == 107) ? q_xor_reg :
				(step == 108) ? q_xor_reg :
				(step == 109) ? 0 :
				(step == 110) ? 0 :
				(step == 111) ? 0 :
				(step == 112) ? 0 :
				(step == 113) ? q_xor_reg :
				(step == 114) ? q_xor_reg :
				(step == 115) ? 0 :
				(step == 116) ? 0 :

				//iter 9
				(step == 117) ? 0 :
				(step == 118) ? 0 :
				(step == 119) ? 0 :
				(step == 120) ? q_xor_reg :
				(step == 121) ? q_xor_reg :
				(step == 122) ? 0 :
				(step == 123) ? 0 :
				(step == 124) ? 0 :
				(step == 125) ? 0 :
				(step == 126) ? q_xor_reg :
				(step == 127) ? q_xor_reg :
				(step == 128) ? 0 :
				(step == 129) ? 0 :

				//iter 10
				(step == 130) ? 0 :
				(step == 131) ? 0 :
				(step == 132) ? 0 :
				(step == 133) ? q_xor_reg :
				(step == 134) ? q_xor_reg :
				(step == 135) ? 0 :
				(step == 136) ? 0 :
				(step == 137) ? 0 :
				(step == 138) ? 0 :
				(step == 139) ? q_xor_reg :
				(step == 140) ? q_xor_reg :
				(step == 141) ? 0 :
				(step == 142) ? 0 :

				//iter 11
				(step == 143) ? 0 :
				(step == 144) ? 0 :
				(step == 145) ? 0 :
				(step == 146) ? q_xor_reg :
				(step == 147) ? q_xor_reg :
				(step == 148) ? 0 :
				(step == 149) ? 0 :
				(step == 150) ? 0 :
				(step == 151) ? 0 :
				(step == 152) ? q_xor_reg :
				(step == 153) ? q_xor_reg :
				(step == 154) ? 0 :
				(step == 155) ? 0 :

				//iter 12
				(step == 156) ? 0 :
				(step == 157) ? 0 :
				(step == 158) ? 0 :
				(step == 159) ? q_xor_reg :
				(step == 160) ? q_xor_reg :
				(step == 161) ? 0 :
				(step == 162) ? 0 :
				(step == 163) ? 0 :
				(step == 164) ? 0 :
				(step == 165) ? q_xor_reg :
				(step == 166) ? q_xor_reg :
				(step == 167) ? 0 :
				(step == 168) ? 0 :

				//iter 13
				(step == 169) ? 0 :
				(step == 170) ? 0 :
				(step == 171) ? 0 :
				(step == 172) ? q_xor_reg :
				(step == 173) ? q_xor_reg :
				(step == 174) ? 0 :
				(step == 175) ? 0 :
				(step == 176) ? 0 :
				(step == 177) ? 0 :
				(step == 178) ? q_xor_reg :
				(step == 179) ? q_xor_reg :
				(step == 180) ? 0 :
				(step == 181) ? 0 :

				//iter 14
				(step == 182) ? 0 :
				(step == 183) ? 0 :
				(step == 184) ? 0 :
				(step == 185) ? q_xor_reg :
				(step == 186) ? q_xor_reg :
				(step == 187) ? 0 :
				(step == 188) ? 0 :
				(step == 189) ? 0 :
				(step == 190) ? 0 :
				(step == 191) ? q_xor_reg :
				(step == 192) ? q_xor_reg :
				(step == 193) ? 0 :
				(step == 194) ? 0 :

				//iter 15
				(step == 195) ? 0 :
				(step == 196) ? 0 :
				(step == 197) ? 0 :
				(step == 198) ? q_xor_reg :
				(step == 199) ? q_xor_reg :
				(step == 200) ? 0 :
				(step == 201) ? 0 :
				(step == 202) ? 0 :
				(step == 203) ? 0 :
				(step == 204) ? q_xor_reg :
				(step == 205) ? q_xor_reg :
				(step == 206) ? 0 :
				(step == 207) ? 0 :

				//iter 16
				(step == 208) ? 0 :
				(step == 209) ? 0 :
				(step == 210) ? 0 :
				(step == 211) ? q_xor_reg :
				(step == 212) ? q_xor_reg :
				(step == 213) ? 0 :
				(step == 214) ? 0 :
				(step == 215) ? 0 :
				(step == 216) ? 0 :
				(step == 217) ? q_xor_reg :
				(step == 218) ? q_xor_reg :
				(step == 219) ? 0 :
				(step == 220) ? 0 :

				//iter 17
				(step == 221) ? 0 :
				(step == 222) ? 0 :
				(step == 223) ? 0 :
				(step == 224) ? q_xor_reg :
				(step == 225) ? q_xor_reg :
				(step == 226) ? 0 :
				(step == 227) ? 0 :
				(step == 228) ? 0 :
				(step == 229) ? 0 :
				(step == 230) ? q_xor_reg :
				(step == 231) ? q_xor_reg :
				(step == 232) ? 0 :
				(step == 233) ? 0 :

				//iter 18
				(step == 234) ? 0 :
				(step == 235) ? 0 :
				(step == 236) ? 0 :
				(step == 237) ? q_xor_reg :
				(step == 238) ? q_xor_reg :
				(step == 239) ? 0 :
				(step == 240) ? 0 :
				(step == 241) ? 0 :
				(step == 242) ? 0 :
				(step == 243) ? q_xor_reg :
				(step == 244) ? q_xor_reg :
				(step == 245) ? 0 :
				(step == 246) ? 0 :

				//iter 19
				(step == 247) ? 0 :
				(step == 248) ? 0 :
				(step == 249) ? 0 :
				(step == 250) ? q_xor_reg :
				(step == 251) ? q_xor_reg :
				(step == 252) ? 0 :
				(step == 253) ? 0 :
				(step == 254) ? 0 :
				(step == 255) ? 0 :
				(step == 256) ? q_xor_reg :
				(step == 257) ? q_xor_reg :
				(step == 258) ? 0 :
				(step == 259) ? 0 :

				//iter 20
				(step == 260) ? 0 :
				(step == 261) ? 0 :
				(step == 262) ? 0 :
				(step == 263) ? q_xor_reg :
				(step == 264) ? q_xor_reg :
				(step == 265) ? 0 :
				(step == 266) ? 0 :
				(step == 267) ? 0 :
				(step == 268) ? 0 :
				(step == 269) ? q_xor_reg :
				(step == 270) ? q_xor_reg :
				(step == 271) ? 0 :
				(step == 272) ? 0 :

				//iter 21
				(step == 273) ? 0 :
				(step == 274) ? 0 :
				(step == 275) ? 0 :
				(step == 276) ? q_xor_reg :
				(step == 277) ? q_xor_reg :
				(step == 278) ? 0 :
				(step == 279) ? 0 :
				(step == 280) ? 0 :
				(step == 281) ? 0 :
				(step == 282) ? q_xor_reg :
				(step == 283) ? q_xor_reg :
				(step == 284) ? 0 :
				(step == 285) ? 0 :

				//iter 22
				(step == 286) ? 0 :
				(step == 287) ? 0 :
				(step == 288) ? 0 :
				(step == 289) ? q_xor_reg :
				(step == 290) ? q_xor_reg :
				(step == 291) ? 0 :
				(step == 292) ? 0 :
				(step == 293) ? 0 :
				(step == 294) ? 0 :
				(step == 295) ? q_xor_reg :
				(step == 296) ? q_xor_reg :
				(step == 297) ? 0 :
				(step == 298) ? 0 :

				//iter 23
				(step == 299) ? 0 :
				(step == 300) ? 0 :
				(step == 301) ? 0 :
				(step == 302) ? q_xor_reg :
				(step == 303) ? q_xor_reg :
				(step == 304) ? 0 :
				(step == 305) ? 0 :
				(step == 306) ? 0 :
				(step == 307) ? 0 :
				(step == 308) ? q_xor_reg :
				(step == 309) ? q_xor_reg :
				(step == 310) ? 0 :
				(step == 311) ? 0 :

				//iter 24
				(step == 312) ? 0 :
				(step == 313) ? 0 :
				(step == 314) ? 0 :
				(step == 315) ? q_xor_reg :
				(step == 316) ? q_xor_reg :
				(step == 317) ? 0 :
				(step == 318) ? 0 :
				(step == 319) ? 0 :
				(step == 320) ? 0 :
				(step == 321) ? q_xor_reg :
				(step == 322) ? q_xor_reg :
				(step == 323) ? 0 :
				(step == 324) ? 0 :

				//iter 25
				(step == 325) ? 0 :
				(step == 326) ? 0 :
				(step == 327) ? 0 :
				(step == 328) ? q_xor_reg :
				(step == 329) ? q_xor_reg :
				(step == 330) ? 0 :
				(step == 331) ? 0 :
				(step == 332) ? 0 :
				(step == 333) ? 0 :
				(step == 334) ? q_xor_reg :
				(step == 335) ? q_xor_reg :
				(step == 336) ? 0 :
				(step == 337) ? 0 :

				//iter 26
				(step == 338) ? 0 :
				(step == 339) ? 0 :
				(step == 340) ? 0 :
				(step == 341) ? q_xor_reg :
				(step == 342) ? q_xor_reg :
				(step == 343) ? 0 :
				(step == 344) ? 0 :
				(step == 345) ? 0 :
				(step == 346) ? 0 :
				(step == 347) ? q_xor_reg :
				(step == 348) ? q_xor_reg :
				(step == 349) ? 0 :
				(step == 350) ? 0 :

				//iter 27
				(step == 351) ? 0 :
				(step == 352) ? 0 :
				(step == 353) ? 0 :
				(step == 354) ? q_xor_reg :
				(step == 355) ? q_xor_reg :
				(step == 356) ? 0 :
				(step == 357) ? 0 :
				(step == 358) ? 0 :
				(step == 359) ? 0 :
				(step == 360) ? q_xor_reg :
				(step == 361) ? q_xor_reg :
				(step == 362) ? 0 :
				(step == 363) ? 0 :

				//iter 28
				(step == 364) ? 0 :
				(step == 365) ? 0 :
				(step == 366) ? 0 :
				(step == 367) ? q_xor_reg :
				(step == 368) ? q_xor_reg :
				(step == 369) ? 0 :
				(step == 370) ? 0 :
				(step == 371) ? 0 :
				(step == 372) ? 0 :
				(step == 373) ? q_xor_reg :
				(step == 374) ? q_xor_reg :
				(step == 375) ? 0 :
				(step == 376) ? 0 :

				//iter 29
				(step == 377) ? 0 :
				(step == 378) ? 0 :
				(step == 379) ? 0 :
				(step == 380) ? q_xor_reg :
				(step == 381) ? q_xor_reg :
				(step == 382) ? 0 :
				(step == 383) ? 0 :
				(step == 384) ? 0 :
				(step == 385) ? 0 :
				(step == 386) ? q_xor_reg :
				(step == 387) ? q_xor_reg :
				(step == 388) ? 0 :
				(step == 389) ? 0 :

				//iter 30
				(step == 390) ? 0 :
				(step == 391) ? 0 :
				(step == 392) ? 0 :
				(step == 393) ? q_xor_reg :
				(step == 394) ? q_xor_reg :
				(step == 395) ? 0 :
				(step == 396) ? 0 :
				(step == 397) ? 0 :
				(step == 398) ? 0 :
				(step == 399) ? q_xor_reg :
				(step == 400) ? q_xor_reg :
				(step == 401) ? 0 :
				(step == 402) ? 0 :

				//iter 31
				(step == 403) ? 0 :
				(step == 404) ? 0 :
				(step == 405) ? 0 :
				(step == 406) ? q_xor_reg :
				(step == 407) ? q_xor_reg :
				(step == 408) ? 0 :
				(step == 409) ? 0 :
				(step == 410) ? 0 :
				(step == 411) ? 0 :
				(step == 412) ? q_xor_reg :
				(step == 413) ? q_xor_reg :
				(step == 414) ? 0 : 0;


	assign sum = (step == 0) ? 0 : 
				 (step == 1) ? q_xor_reg :
				 (step == 14) ? q_xor_reg :
				 (step == 27) ? q_xor_reg :
				 (step == 40) ? q_xor_reg :
				 (step == 53) ? q_xor_reg :
				 (step == 66) ? q_xor_reg :
				 (step == 79) ? q_xor_reg :
				 (step == 92) ? q_xor_reg :
				 (step == 105) ? q_xor_reg :
				 (step == 118) ? q_xor_reg :
				 (step == 131) ? q_xor_reg :
				 (step == 144) ? q_xor_reg :
				 (step == 157) ? q_xor_reg :
				 (step == 170) ? q_xor_reg :
				 (step == 183) ? q_xor_reg :
				 (step == 196) ? q_xor_reg :
				 (step == 209) ? q_xor_reg :
				 (step == 222) ? q_xor_reg :
				 (step == 235) ? q_xor_reg :
				 (step == 248) ? q_xor_reg :
				 (step == 261) ? q_xor_reg :
				 (step == 274) ? q_xor_reg :
				 (step == 287) ? q_xor_reg :
				 (step == 300) ? q_xor_reg :
				 (step == 313) ? q_xor_reg :
				 (step == 326) ? q_xor_reg :
				 (step == 339) ? q_xor_reg :
				 (step == 352) ? q_xor_reg :
				 (step == 365) ? q_xor_reg :
				 (step == 378) ? q_xor_reg :
				 (step == 391) ? q_xor_reg :
				 (step == 404) ? q_xor_reg : sum;

	assign v0 = (step == 0) ? _v0 :
				(step == 6) ? q_xor_reg :
				(step == 19) ? q_xor_reg :
				(step == 32) ? q_xor_reg :
				(step == 45) ? q_xor_reg :
				(step == 58) ? q_xor_reg :
				(step == 71) ? q_xor_reg :
				(step == 84) ? q_xor_reg :
				(step == 97) ? q_xor_reg :
				(step == 110) ? q_xor_reg :
				(step == 123) ? q_xor_reg :
				(step == 136) ? q_xor_reg :
				(step == 149) ? q_xor_reg :
				(step == 162) ? q_xor_reg :
				(step == 175) ? q_xor_reg :
				(step == 188) ? q_xor_reg :
				(step == 201) ? q_xor_reg :
				(step == 214) ? q_xor_reg :
				(step == 227) ? q_xor_reg :
				(step == 240) ? q_xor_reg :
				(step == 253) ? q_xor_reg :
				(step == 266) ? q_xor_reg :
				(step == 279) ? q_xor_reg :
				(step == 292) ? q_xor_reg :
				(step == 305) ? q_xor_reg :
				(step == 318) ? q_xor_reg :
				(step == 331) ? q_xor_reg :
				(step == 344) ? q_xor_reg :
				(step == 357) ? q_xor_reg :
				(step == 370) ? q_xor_reg :
				(step == 383) ? q_xor_reg :
				(step == 396) ? q_xor_reg :
				(step == 409) ? q_xor_reg : v0;

	assign v1 = (step == 0) ? _v1 :
				(step == 12) ? q_xor_reg :
				(step == 25) ? q_xor_reg :
				(step == 38) ? q_xor_reg :
				(step == 51) ? q_xor_reg :
				(step == 64) ? q_xor_reg :
				(step == 77) ? q_xor_reg :
				(step == 90) ? q_xor_reg :
				(step == 103) ? q_xor_reg :
				(step == 116) ? q_xor_reg :
				(step == 129) ? q_xor_reg :
				(step == 142) ? q_xor_reg :
				(step == 155) ? q_xor_reg :
				(step == 168) ? q_xor_reg :
				(step == 181) ? q_xor_reg :
				(step == 194) ? q_xor_reg :
				(step == 207) ? q_xor_reg :
				(step == 220) ? q_xor_reg :
				(step == 233) ? q_xor_reg :
				(step == 246) ? q_xor_reg :
				(step == 259) ? q_xor_reg :
				(step == 272) ? q_xor_reg :
				(step == 285) ? q_xor_reg :
				(step == 298) ? q_xor_reg :
				(step == 311) ? q_xor_reg :
				(step == 324) ? q_xor_reg :
				(step == 337) ? q_xor_reg :
				(step == 350) ? q_xor_reg :
				(step == 363) ? q_xor_reg :
				(step == 376) ? q_xor_reg :
				(step == 389) ? q_xor_reg :
				(step == 402) ? q_xor_reg :
				(step == 415) ? q_xor_reg : v1;

	assign done = (step == 416) ? 1 : 0;

	assign enc_v0 = v0;
	assign enc_v1 = v1;

endmodule
