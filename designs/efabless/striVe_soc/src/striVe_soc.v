/*
 *  PicoSoC - A simple example SoC using PicoRV32
 *
 *  Copyright (C) 2017  Clifford Wolf <clifford@clifford.at>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *  Revision 1,  July 2019:  Added signals to drive flash_clk and flash_csb
 *  output enable (inverted), tied to reset so that the flash is completely
 *  isolated from the processor when the processor is in reset.
 *
 *  Also: Made ram_wenb a 4-bit bus so that the memory access can be made
 *  byte-wide for byte-wide instructions.
 */

`ifdef PICORV32_V
`error "openstriVe_soc.v must be read before picorv32.v!"
`endif

/* Note:  Synthesize register memory from flops */
/* Inefficient, but not terribly so */

/* Also note:  To avoid having a hard macro in the place & route	 */
/* (method not finished yet in qflow), SRAM pins are brought out to	 */
/* the openstriVe_soc I/O so that openstriVe_soc.v itself is fully synthesizable */
/* and routable with qflow as-is.					*/

`define PICORV32_REGS openstriVe_soc_regs

module striVe_soc (
`ifdef LVS
	inout vdd1v8,	    /* 1.8V domain */
	inout vss,
`endif
	input pll_clk,
	input ext_clk,
	input ext_clk_sel,
	/*
	input ext_reset,
	input reset,
	*/

	input clk,
	input resetn,
	// Main SRAM, including clk and resetn above
	// (Not used:  RAM is synthesized in this version)
	/*
	output [3:0] ram_wenb,
	output [9:0] ram_addr,
	output [31:0] ram_wdata,
	input  [31:0] ram_rdata,
	*/

	// Memory mapped I/O signals
	output [15:0] gpio_out_pad,		// Connect to out on gpio pad
	input  [15:0] gpio_in_pad,		// Connect to in on gpio pad
	output [15:0] gpio_mode0_pad,		// Connect to dm[0] on gpio pad
	output [15:0] gpio_mode1_pad,		// Connect to dm[2] on gpio pad
	output [15:0] gpio_outenb_pad,		// Connect to oe_n on gpio pad
	output [15:0] gpio_inenb_pad,		// Connect to inp_dis on gpio pad

	output 	      adc0_ena,
	output 	      adc0_convert,
	input  [9:0]  adc0_data,
	input  	      adc0_done,
	output	      adc0_clk,
	output [1:0]  adc0_inputsrc,
	output 	      adc1_ena,
	output 	      adc1_convert,
	output	      adc1_clk,
	output [1:0]  adc1_inputsrc,
	input  [9:0]  adc1_data,
	input  	      adc1_done,

	output	      dac_ena,
	output [9:0]  dac_value,

	output	      analog_out_sel,	// Analog output select (DAC or bandgap)
	output	      opamp_ena,	// Op-amp enable for analog output
	output	      opamp_bias_ena,	// Op-amp bias enable for analog output
	output	      bg_ena,		// Bandgap enable

	output	      comp_ena,
	output [1:0]  comp_ninputsrc,
	output [1:0]  comp_pinputsrc,
	output	      rcosc_ena,

	output	      overtemp_ena,
	input	      overtemp,
	input	      rcosc_in,		// RC oscillator output
	input	      xtal_in,		// crystal oscillator output
	input	      comp_in,		// comparator output
	input	      spi_sck,

	input [7:0]   spi_ro_config,
	input 	      spi_ro_xtal_ena,
	input 	      spi_ro_reg_ena,
	input 	      spi_ro_pll_dco_ena,
	input [4:0]   spi_ro_pll_div,
	input [2:0]   spi_ro_pll_sel,
	input [25:0]  spi_ro_pll_trim,

	input [11:0]  spi_ro_mfgr_id,
	input [7:0]   spi_ro_prod_id,
	input [3:0]   spi_ro_mask_rev,

	output ser_tx,
	input  ser_rx,

	// IRQ
	input  irq_pin,		// dedicated IRQ pin
	input  irq_spi,		// IRQ from standalone SPI

	// trap
	output trap,

	// Flash memory control (SPI master)
	output flash_csb,
	output flash_clk,

	output flash_csb_oeb,
	output flash_clk_oeb,

	output flash_io0_oeb,
	output flash_io1_oeb,
	output flash_io2_oeb,
	output flash_io3_oeb,

	output flash_csb_ieb,
	output flash_clk_ieb,

	output flash_io0_ieb,
	output flash_io1_ieb,
	output flash_io2_ieb,
	output flash_io3_ieb,

	output flash_io0_do,
	output flash_io1_do,
	output flash_io2_do,
	output flash_io3_do,

	input  flash_io0_di,
	input  flash_io1_di,
	input  flash_io2_di,
	input  flash_io3_di
);
	/* Increase scratchpad memory to 1K words */
	/* parameter integer MEM_WORDS = 1024; */
	/* Memory reverted back to 256 words while memory has to be synthesized */
	parameter integer MEM_WORDS = 256;
	parameter [31:0] STACKADDR = (4*MEM_WORDS);       // end of memory
	parameter [31:0] PROGADDR_RESET = 32'h 0010_0000; // 1 MB into flash

//	wire	      resetn;
//	wire	      clk;

	wire          iomem_valid;
	reg           iomem_ready;
	wire   [ 3:0] iomem_wstrb;
	wire   [31:0] iomem_addr;
	wire   [31:0] iomem_wdata;
	reg    [31:0] iomem_rdata;

	// memory-mapped I/O control registers

        wire   [15:0] gpio_pullup;      // Intermediate GPIO pullup
        wire   [15:0] gpio_pulldown;    // Intermediate GPIO pulldown
        wire   [15:0] gpio_outenb;      // Intermediate GPIO out enable (bar)
        wire   [15:0] gpio_out;         // Intermediate GPIO output

	reg    [15:0] gpio;		// GPIO output data
	reg    [15:0] gpio_pu;		// GPIO pull-up enable
	reg    [15:0] gpio_pd;		// GPIO pull-down enable
	reg    [15:0] gpio_oeb;		// GPIO output enable (sense negative)
	reg 	      adc0_ena;		// ADC0 enable
	reg 	      adc0_convert;	// ADC0 convert
	reg    [1:0]  adc0_clksrc;	// ADC0 clock source
	reg    [1:0]  adc0_inputsrc;	// ADC0 input source
	reg 	      adc1_ena;		// ADC1 enable
	reg 	      adc1_convert;	// ADC1 convert
	reg    [1:0]  adc1_clksrc;	// ADC1 clock source
	reg    [1:0]  adc1_inputsrc;	// ADC1 input source
	reg	      dac_ena;		// DAC enable
	reg    [9:0]  dac_value;	// DAC output value
	reg	      comp_ena;		// Comparator enable
	reg    [1:0]  comp_ninputsrc;	// Comparator negative input source
	reg    [1:0]  comp_pinputsrc;	// Comparator positive input source
	reg	      rcosc_ena;	// RC oscillator enable
	reg	      overtemp_ena;	// Over-temperature alarm enable
	reg    [1:0]  comp_output_dest; // Comparator output destination
	reg    [1:0]  rcosc_output_dest; // RC oscillator output destination
	reg    [1:0]  overtemp_dest;	// Over-temperature alarm destination
	reg    [1:0]  pll_output_dest;	// PLL clock output destination
	reg    [1:0]  xtal_output_dest; // Crystal oscillator output destination
	reg    [1:0]  trap_output_dest; // Trap signal output destination
	reg    [1:0]  irq_7_inputsrc;	// IRQ 5 source
	reg    [1:0]  irq_8_inputsrc;	// IRQ 6 source
	reg	      analog_out_sel;	// Analog output select
 	reg	      opamp_ena;	// Analog output op-amp enable
 	reg	      opamp_bias_ena;	// Analog output op-amp bias enable
 	reg	      bg_ena;		// Bandgap enable
	wire	      adc0_clk;		// ADC0 clock (multiplexed)
	wire	      adc1_clk;		// ADC1 clock (multiplexed)

	wire [3:0] ram_wenb;
	wire [9:0] ram_addr;
	wire [31:0] ram_wdata;
	
//	// Clock assignment (to do:  make this glitch-free)
//	assign clk = (ext_clk_sel == 1'b1) ? ext_clk : pll_clk;
//
//	// Reset assignment.  "reset" comes from POR, while "ext_reset"
//	// comes from standalone SPI (and is normally zero unless
//	// activated from the SPI).
//
//	// Staged-delay reset
//	reg [2:0] reset_delay;
//
//	always @(posedge clk or posedge reset) begin
//	    if (reset == 1'b1) begin
//		reset_delay <= 3'b111;
//	    end else begin
//		reset_delay <= {1'b0, reset_delay[2:1]};
//	    end
//	end
//
//	assign resetn = ~(reset_delay[0] | ext_reset);

	// ADC clock assignments
	
	assign adc0_clk = (adc0_clksrc == 2'b00) ? rcosc_in :
			  (adc0_clksrc == 2'b01) ? spi_sck :
			  (adc0_clksrc == 2'b10) ? xtal_in :
			  ext_clk;

	assign adc1_clk = (adc1_clksrc == 2'b00) ? rcosc_in :
			  (adc1_clksrc == 2'b01) ? spi_sck :
			  (adc1_clksrc == 2'b10) ? xtal_in :
			  ext_clk;

	// GPIO assignments

	assign gpio_out[0] = (comp_output_dest == 2'b01) ? comp_in : gpio[0];
	assign gpio_out[1] = (comp_output_dest == 2'b10) ? comp_in : gpio[1];
	assign gpio_out[2] = (rcosc_output_dest == 2'b01) ? rcosc_in : gpio[2];
	assign gpio_out[3] = (rcosc_output_dest == 2'b10) ? rcosc_in : gpio[3];
	assign gpio_out[4] = (rcosc_output_dest == 2'b11) ? rcosc_in : gpio[4];
	assign gpio_out[5] = (xtal_output_dest == 2'b01) ? xtal_in : gpio[5]; 
	assign gpio_out[6] = (xtal_output_dest == 2'b10) ? xtal_in : gpio[6]; 
	assign gpio_out[7] = (xtal_output_dest == 2'b11) ? xtal_in : gpio[7]; 
	assign gpio_out[8] = (pll_output_dest == 2'b01) ? pll_clk : gpio[8];
	assign gpio_out[9] = (pll_output_dest == 2'b10) ? pll_clk : gpio[9];
	assign gpio_out[10] = (pll_output_dest == 2'b11) ? clk : gpio[10];
	assign gpio_out[11] = (trap_output_dest == 2'b01) ? trap : gpio[11];
	assign gpio_out[12] = (trap_output_dest == 2'b10) ? trap : gpio[12];
	assign gpio_out[13] = (trap_output_dest == 2'b11) ? trap : gpio[13];
	assign gpio_out[14] = (overtemp_dest == 2'b01) ? overtemp : gpio[14];
	assign gpio_out[15] = (overtemp_dest == 2'b10) ? overtemp : gpio[15];

	assign gpio_outenb[0] = (comp_output_dest == 2'b00)  ? gpio_oeb[0] : 1'b0;
	assign gpio_outenb[1] = (comp_output_dest == 2'b00)  ? gpio_oeb[1] : 1'b0;
	assign gpio_outenb[2] = (rcosc_output_dest == 2'b00) ? gpio_oeb[2] : 1'b0; 
	assign gpio_outenb[3] = (rcosc_output_dest == 2'b00) ? gpio_oeb[3] : 1'b0;
	assign gpio_outenb[4] = (rcosc_output_dest == 2'b00) ? gpio_oeb[4] : 1'b0;
	assign gpio_outenb[5] = (xtal_output_dest == 2'b00)  ? gpio_oeb[5] : 1'b0;
	assign gpio_outenb[6] = (xtal_output_dest == 2'b00)  ? gpio_oeb[6] : 1'b0;
	assign gpio_outenb[7] = (xtal_output_dest == 2'b00)  ? gpio_oeb[7] : 1'b0;
	assign gpio_outenb[8] = (pll_output_dest == 2'b00)   ? gpio_oeb[8] : 1'b0;
	assign gpio_outenb[9] = (pll_output_dest == 2'b00)   ? gpio_oeb[9] : 1'b0;
	assign gpio_outenb[10] = (pll_output_dest == 2'b00)  ? gpio_oeb[10] : 1'b0;
	assign gpio_outenb[11] = (trap_output_dest == 2'b00) ? gpio_oeb[11] : 1'b0;
	assign gpio_outenb[12] = (trap_output_dest == 2'b00) ? gpio_oeb[12] : 1'b0;
	assign gpio_outenb[13] = (trap_output_dest == 2'b00) ? gpio_oeb[13] : 1'b0;
	assign gpio_outenb[14] = (overtemp_dest == 2'b00)    ? gpio_oeb[14] : 1'b0;
	assign gpio_outenb[15] = (overtemp_dest == 2'b00)    ? gpio_oeb[15] : 1'b0;

	assign gpio_pullup[0] = (comp_output_dest == 2'b00)  ? gpio_pu[0] : 1'b0;
	assign gpio_pullup[1] = (comp_output_dest == 2'b00)  ? gpio_pu[1] : 1'b0;
	assign gpio_pullup[2] = (rcosc_output_dest == 2'b00) ? gpio_pu[2] : 1'b0; 
	assign gpio_pullup[3] = (rcosc_output_dest == 2'b00) ? gpio_pu[3] : 1'b0;
	assign gpio_pullup[4] = (rcosc_output_dest == 2'b00) ? gpio_pu[4] : 1'b0;
	assign gpio_pullup[5] = (xtal_output_dest == 2'b00)  ? gpio_pu[5] : 1'b0;
	assign gpio_pullup[6] = (xtal_output_dest == 2'b00)  ? gpio_pu[6] : 1'b0;
	assign gpio_pullup[7] = (xtal_output_dest == 2'b00)  ? gpio_pu[7] : 1'b0;
	assign gpio_pullup[8] = (pll_output_dest == 2'b00)   ? gpio_pu[8] : 1'b0;
	assign gpio_pullup[9] = (pll_output_dest == 2'b00)   ? gpio_pu[9] : 1'b0;
	assign gpio_pullup[10] = (pll_output_dest == 2'b00)  ? gpio_pu[10] : 1'b0;
	assign gpio_pullup[11] = (trap_output_dest == 2'b00) ? gpio_pu[11] : 1'b0;
	assign gpio_pullup[12] = (trap_output_dest == 2'b00) ? gpio_pu[12] : 1'b0;
	assign gpio_pullup[13] = (trap_output_dest == 2'b00) ? gpio_pu[13] : 1'b0;
	assign gpio_pullup[14] = (overtemp_dest == 2'b00)    ? gpio_pu[14] : 1'b0;
	assign gpio_pullup[15] = (overtemp_dest == 2'b00)    ? gpio_pu[15] : 1'b0;

	assign gpio_pulldown[0] = (comp_output_dest == 2'b00)  ? gpio_pd[0] : 1'b0;
	assign gpio_pulldown[1] = (comp_output_dest == 2'b00)  ? gpio_pd[1] : 1'b0;
	assign gpio_pulldown[2] = (rcosc_output_dest == 2'b00) ? gpio_pd[2] : 1'b0; 
	assign gpio_pulldown[3] = (rcosc_output_dest == 2'b00) ? gpio_pd[3] : 1'b0;
	assign gpio_pulldown[4] = (rcosc_output_dest == 2'b00) ? gpio_pd[4] : 1'b0;
	assign gpio_pulldown[5] = (xtal_output_dest == 2'b00)  ? gpio_pd[5] : 1'b0;
	assign gpio_pulldown[6] = (xtal_output_dest == 2'b00)  ? gpio_pd[6] : 1'b0;
	assign gpio_pulldown[7] = (xtal_output_dest == 2'b00)  ? gpio_pd[7] : 1'b0;
	assign gpio_pulldown[8] = (pll_output_dest == 2'b00)   ? gpio_pd[8] : 1'b0;
	assign gpio_pulldown[9] = (pll_output_dest == 2'b00)   ? gpio_pd[9] : 1'b0;
	assign gpio_pulldown[10] = (pll_output_dest == 2'b00)  ? gpio_pd[10] : 1'b0;
	assign gpio_pulldown[11] = (trap_output_dest == 2'b00) ? gpio_pd[11] : 1'b0;
	assign gpio_pulldown[12] = (trap_output_dest == 2'b00) ? gpio_pd[12] : 1'b0;
	assign gpio_pulldown[13] = (trap_output_dest == 2'b00) ? gpio_pd[13] : 1'b0;
	assign gpio_pulldown[14] = (overtemp_dest == 2'b00)    ? gpio_pd[14] : 1'b0;
	assign gpio_pulldown[15] = (overtemp_dest == 2'b00)    ? gpio_pd[15] : 1'b0;

        // Convert GPIO signals to s8 pad signals
        convert_gpio_sigs convert_gpio_bit [15:0] (
            .gpio_out(gpio_out),
            .gpio_outenb(gpio_outenb),
            .gpio_pu(gpio_pullup),
            .gpio_pd(gpio_pulldown),
            .gpio_out_pad(gpio_out_pad),
            .gpio_outenb_pad(gpio_outenb_pad),
            .gpio_inenb_pad(gpio_inenb_pad),
            .gpio_mode1_pad(gpio_mode1_pad),
            .gpio_mode0_pad(gpio_mode0_pad)
        );

	wire irq_7, irq_8;

	assign irq_7 = (irq_7_inputsrc == 2'b01) ? gpio_in_pad[0] :
		       (irq_7_inputsrc == 2'b10) ? gpio_in_pad[1] :
		       (irq_7_inputsrc == 2'b11) ? gpio_in_pad[2] : 1'b0;
	assign irq_8 = (irq_8_inputsrc == 2'b01) ? gpio_in_pad[3] :
		       (irq_8_inputsrc == 2'b10) ? gpio_in_pad[4] :
		       (irq_8_inputsrc == 2'b11) ? gpio_in_pad[5] : 1'b0;

	assign ram_wenb = (mem_valid && !mem_ready && mem_addr < 4*MEM_WORDS) ?
		{~mem_wstrb[3], ~mem_wstrb[2], ~mem_wstrb[1], ~mem_wstrb[0]} : 4'b1111;
        assign ram_addr = mem_addr[11:2];
	assign ram_wdata = mem_wdata;		// Just for naming conventions.

	reg [31:0] irq;
	wire irq_stall = 0;
	wire irq_uart = 0;

	always @* begin
		irq = 0;
		irq[3] = irq_stall;
		irq[4] = irq_uart;
		irq[5] = irq_pin;
		irq[6] = irq_spi;
		irq[7] = irq_7;
		irq[8] = irq_8;
		irq[9] = comp_output_dest[0] & comp_output_dest[1] & comp_in;
		irq[10] = overtemp_dest[0] & overtemp_dest[1] & overtemp;
	end

	wire mem_valid;
	wire mem_instr;
	wire mem_ready;
	wire [31:0] mem_addr;
	wire [31:0] mem_wdata;
	wire [3:0] mem_wstrb;
	wire [31:0] mem_rdata;

	wire spimem_ready;
	wire [31:0] spimem_rdata;

	reg ram_ready;
	wire [31:0] ram_rdata;

	assign iomem_valid = mem_valid && (mem_addr[31:24] > 8'h 01);
	assign iomem_wstrb = mem_wstrb;
	assign iomem_addr = mem_addr;
	assign iomem_wdata = mem_wdata;

	wire spimemio_cfgreg_sel = mem_valid && (mem_addr == 32'h 0200_0000);
	wire [31:0] spimemio_cfgreg_do;

	wire        simpleuart_reg_div_sel = mem_valid && (mem_addr == 32'h 0200_0004);
	wire [31:0] simpleuart_reg_div_do;

	wire        simpleuart_reg_dat_sel = mem_valid && (mem_addr == 32'h 0200_0008);
	wire [31:0] simpleuart_reg_dat_do;
	wire        simpleuart_reg_dat_wait;

	assign mem_ready = (iomem_valid && iomem_ready) || spimem_ready || ram_ready || spimemio_cfgreg_sel ||
			simpleuart_reg_div_sel || (simpleuart_reg_dat_sel && !simpleuart_reg_dat_wait);

	assign mem_rdata = (iomem_valid && iomem_ready) ? iomem_rdata : spimem_ready ? spimem_rdata : ram_ready ? ram_rdata :
			spimemio_cfgreg_sel ? spimemio_cfgreg_do : simpleuart_reg_div_sel ? simpleuart_reg_div_do :
			simpleuart_reg_dat_sel ? simpleuart_reg_dat_do : 32'h 0000_0000;

	picorv32 #(
		.STACKADDR(STACKADDR),
		.PROGADDR_RESET(PROGADDR_RESET),
		.PROGADDR_IRQ(32'h 0000_0000),
		.BARREL_SHIFTER(1),
		.COMPRESSED_ISA(1),
		.ENABLE_MUL(1),
		.ENABLE_DIV(1),
		.ENABLE_IRQ(1),
		.ENABLE_IRQ_QREGS(0)
	) cpu (
		.clk         (clk        ),
		.resetn      (resetn     ),
		.mem_valid   (mem_valid  ),
		.mem_instr   (mem_instr  ),
		.mem_ready   (mem_ready  ),
		.mem_addr    (mem_addr   ),
		.mem_wdata   (mem_wdata  ),
		.mem_wstrb   (mem_wstrb  ),
		.mem_rdata   (mem_rdata  ),
		.irq         (irq        ),
		.trap        (trap       )
	);

	spimemio spimemio (
		.clk    (clk),
		.resetn (resetn),
		.valid  (mem_valid && mem_addr >= 4*MEM_WORDS && mem_addr < 32'h 0200_0000),
		.ready  (spimem_ready),
		.addr   (mem_addr[23:0]),
		.rdata  (spimem_rdata),

		.flash_csb    (flash_csb   ),
		.flash_clk    (flash_clk   ),

		.flash_csb_oeb (flash_csb_oeb),
		.flash_clk_oeb (flash_clk_oeb),

		.flash_io0_oeb (flash_io0_oeb),
		.flash_io1_oeb (flash_io1_oeb),
		.flash_io2_oeb (flash_io2_oeb),
		.flash_io3_oeb (flash_io3_oeb),

		.flash_csb_ieb (flash_csb_ieb),
		.flash_clk_ieb (flash_clk_ieb),

		.flash_io0_ieb (flash_io0_ieb),
		.flash_io1_ieb (flash_io1_ieb),
		.flash_io2_ieb (flash_io2_ieb),
		.flash_io3_ieb (flash_io3_ieb),

		.flash_io0_do (flash_io0_do),
		.flash_io1_do (flash_io1_do),
		.flash_io2_do (flash_io2_do),
		.flash_io3_do (flash_io3_do),

		.flash_io0_di (flash_io0_di),
		.flash_io1_di (flash_io1_di),
		.flash_io2_di (flash_io2_di),
		.flash_io3_di (flash_io3_di),

		.cfgreg_we(spimemio_cfgreg_sel ? mem_wstrb : 4'b 0000),
		.cfgreg_di(mem_wdata),
		.cfgreg_do(spimemio_cfgreg_do)
	);

	simpleuart simpleuart (
		.clk         (clk         ),
		.resetn      (resetn      ),

		.ser_tx      (ser_tx      ),
		.ser_rx      (ser_rx      ),

		.reg_div_we  (simpleuart_reg_div_sel ? mem_wstrb : 4'b 0000),
		.reg_div_di  (mem_wdata),
		.reg_div_do  (simpleuart_reg_div_do),

		.reg_dat_we  (simpleuart_reg_dat_sel ? mem_wstrb[0] : 1'b 0),
		.reg_dat_re  (simpleuart_reg_dat_sel && !mem_wstrb),
		.reg_dat_di  (mem_wdata),
		.reg_dat_do  (simpleuart_reg_dat_do),
		.reg_dat_wait(simpleuart_reg_dat_wait)
	);

	always @(posedge clk)
		ram_ready <= mem_valid && !mem_ready && mem_addr < 4*MEM_WORDS;

	// PicoSoC memory mapped IP
	// 2 ADCs (1 multiplexed from internal signals, including core 1.8V VDD,
	//	DAC output, comparator input, external input)
	// 1 DAC
	// 1 comparator (1 end tied to DAC, other could be shared w/ADC input)
	// 1 RC oscillator (output can be tied to one or both ADC clocks)
	// 1 crystal oscillator (output to level-shift-down = 3V buffer powered at 1.8V)
	// 1 1.8V regulator (sets VDD on padframe)
	// 1 bandgap
	// 1 power-on-reset (POR)
	// 1 temperature alarm
	
	// NOTE: Signals affecting critical core functions are controlled through
	// an independent SPI having read-only access through the picorv32 core.
	// SPI pins are independent of picorv32 SPI master.  Signals controlled by
	// the SPI are:
	// 1) crystal oscillator enable (default on)
	// 2) 1.8V regulator enable (default on)
	// 3) bandgap enable (default on)
	// 4) picorv32 internal debug signals (TBD)
	// 5) additional picorv32 IRQ (TBD)
	// 6) PLL enables (default on)
	// 7) PLL trim (default TBD)
	// NOTE:  SPI should have a pass-through mode that configures SDO as a
	// copy of a chosen signal for as long as CSB is held low.  This can be
	// an SPI command, allows other internal signals to be passed to the
	// output and viewed, including the RC oscillator output, comparator output,
	// and other edge-based signals.

	// Memory map:
	// NOTE:

	// SPI master:	0x02000000	(control)
	// UART:	0x02000004-8	(clock, data)
	// GPIO:	0x03000000	(in/out, pu/pd, data)
	// ADC0:	0x03000020
	// ADC1:	0x03000040
	// DAC:		0x03000060
	// comparator:	0x03000080
	// RC osc:	0x030000a0
	// SPI slave:	0x030000c0	(read-only)

	// Memory map details:
	// GPIO:	32 channels total.  
	//		addr 0x03000000		data (16 bits)
	//		addr 0x03000001		out (=1) or in (=0) (default 0)
	//		addr 0x03000002		pu (=1) or none (=0) (default 0)
	//		addr 0x03000003		pd (=1) or none (=0) (default 0)
	//		addr 0x03000004-f 	reserved (may be used for other pad I/O)
	//
	// ADC0:	addr 0x03000020		enable
	// 		addr 0x03000021		data (read-only)
	//      	addr 0x03000022		done (read-only)
	//		addr 0x03000023		start conversion
	//		addr 0x03000024		clock source (RC osc, SPI clk, xtal, core)
	//		addr 0x03000025		input source (core VDD, ext, DAC, comp in)
	//
	// ADC1:	addr 0x03000040		enable
	// 		addr 0x03000041		data (read-only)
	//      	addr 0x03000042		done (read-only)
	//		addr 0x03000043		start conversion
	//		addr 0x03000044		clock source (RC osc, SPI clk, xtal, core)
	//		addr 0x03000045		input source (bg, ext, I/O vdd, gnd)
	//
	// DAC:		addr 0x03000060		enable
	//     		addr 0x03000061		value
	//
	// comparator:  addr 0x03000080		enable
	//		addr 0x03000081		value
	//		addr 0x03000082		input source (DAC, bg, core VDD, ext)
	//		addr 0x03000083		output dest (ext gpio pin 0-1, IRQ, none)
	//
	// bandgap:	addr 0x03000090		enable
	//
	// RC osc:	addr 0x030000a0		enable
	//		addr 0x030000a1		output dest (ext gpio pin 2-4)
	//
	// SPI slave:	addr 0x030000c0		SPI configuration
	//		addr 0x030000c1		xtal osc, reg, bg enables
	// 		addr 0x030000c2		PLL enables, trim
	// 		addr 0x030000c3		manufacturer ID
	// 		addr 0x030000c4		product ID
	// 		addr 0x030000c5		product mask revision
	// Xtal mon:	addr 0x030000c6		xtal osc output dest (ext gpio pin 5-7)
	// PLL mon:	addr 0x030000c7		PLL output dest (ext gpio pin 8-10)
	// trap mon:	addr 0x030000c8		trap output dest (ext gpio pin 11-13)
	// IRQ7 src:	addr 0x030000c9		IRQ 7 source (ext gpio pin 0-3)
	// IRQ8 src:	addr 0x030000ca		IRQ 8 source (ext gpio pin 4-7)
	// Analog:	addr 0x030000cb		analog output select (DAC, bg)
	//
	// Overtemp:	addr 0x030000e0		over-temperature alarm enable
	//		addr 0x030000e1		over-temperature alarm data
	//		addr 0x030000e2		output dest (ext gpio pin 14-15, IRQ)

	always @(posedge clk) begin
		if (!resetn) begin
			gpio <= 0;
			gpio_oeb <= 16'hffff;
			gpio_pu <= 0;
			gpio_pd <= 0;
			adc0_ena <= 0;
			adc0_convert <= 0;
			adc0_clksrc <= 0;
			adc0_inputsrc <= 0;
			adc1_ena <= 0;
			adc1_convert <= 0;
			adc1_clksrc <= 0;
			adc1_inputsrc <= 0;
			dac_ena <= 0;
			dac_value <= 0;
			comp_ena <= 0;
			comp_ninputsrc <= 0;
			comp_pinputsrc <= 0;
			rcosc_ena <= 0;
			comp_output_dest <= 0;
			rcosc_output_dest <= 0;
			overtemp_dest <= 0;
			overtemp_ena <= 0;
			pll_output_dest <= 0;
			xtal_output_dest <= 0;
			trap_output_dest <= 0;
			irq_7_inputsrc <= 0;
			irq_8_inputsrc <= 0;
			analog_out_sel <= 0;
			opamp_ena <= 0;
			opamp_bias_ena <= 0;
			bg_ena <= 0;

		end else begin
			iomem_ready <= 0;
			if (iomem_valid && !iomem_ready && iomem_addr[31:8] == 24'h030000) begin
				iomem_ready <= 1;
				if (iomem_addr[7:0] == 8'h00) begin
					iomem_rdata <= {gpio_out, gpio_in_pad};
					if (iomem_wstrb[0]) gpio[ 7: 0] <= iomem_wdata[ 7: 0];
					if (iomem_wstrb[1]) gpio[15: 8] <= iomem_wdata[15: 8];
				end else if (iomem_addr[7:0] == 8'h04) begin
					iomem_rdata <= {16'd0, gpio_oeb};
					if (iomem_wstrb[0]) gpio_oeb[ 7: 0] <= iomem_wdata[ 7: 0];
					if (iomem_wstrb[1]) gpio_oeb[15: 8] <= iomem_wdata[15: 8];
				end else if (iomem_addr[7:0] == 8'h08) begin
					iomem_rdata <= {16'd0, gpio_pu};
					if (iomem_wstrb[0]) gpio_pu[ 7: 0] <= iomem_wdata[ 7: 0];
					if (iomem_wstrb[1]) gpio_pu[15: 8] <= iomem_wdata[15: 8];
				end else if (iomem_addr[7:0] == 8'h0c) begin
					iomem_rdata <= {16'd0, gpio_pu};
					if (iomem_wstrb[0]) gpio_pd[ 7: 0] <= iomem_wdata[ 7: 0];
					if (iomem_wstrb[1]) gpio_pd[15: 8] <= iomem_wdata[15: 8];
				end else if (iomem_addr[7:0] == 8'h10) begin
					iomem_rdata <= {31'd0, adc0_ena};
					if (iomem_wstrb[0]) adc0_ena <= iomem_wdata[0];
				end else if (iomem_addr[7:0] == 8'h14) begin
					iomem_rdata <= {22'd0, adc0_data};
				end else if (iomem_addr[7:0] == 8'h18) begin
					iomem_rdata <= {31'd0, adc0_done};
				end else if (iomem_addr[7:0] == 8'h1c) begin
					iomem_rdata <= {31'd0, adc0_convert};
					if (iomem_wstrb[0]) adc0_convert <= iomem_wdata[0];
				end else if (iomem_addr[7:0] == 8'h20) begin
					iomem_rdata <= {30'd0, adc0_clksrc};
					if (iomem_wstrb[0]) adc0_clksrc <= iomem_wdata[1:0];
				end else if (iomem_addr[7:0] == 8'h24) begin
					iomem_rdata <= {30'd0, adc0_inputsrc};
					if (iomem_wstrb[0]) adc0_inputsrc <= iomem_wdata[1:0];
				end else if (iomem_addr[7:0] == 8'h30) begin
					iomem_rdata <= {31'd0, adc1_ena};
					if (iomem_wstrb[0]) adc1_ena <= iomem_wdata[0];
				end else if (iomem_addr[7:0] == 8'h34) begin
					iomem_rdata <= {22'd0, adc1_data};
				end else if (iomem_addr[7:0] == 8'h38) begin
					iomem_rdata <= {31'd0, adc1_done};
				end else if (iomem_addr[7:0] == 8'h3c) begin
					iomem_rdata <= {31'd0, adc1_convert};
					if (iomem_wstrb[0]) adc1_convert <= iomem_wdata[0];
				end else if (iomem_addr[7:0] == 8'h40) begin
					iomem_rdata <= {30'd0, adc1_clksrc};
					if (iomem_wstrb[0]) adc1_clksrc <= iomem_wdata[1:0];
				end else if (iomem_addr[7:0] == 8'h44) begin
					iomem_rdata <= {30'd0, adc1_inputsrc};
					if (iomem_wstrb[0]) adc1_inputsrc <= iomem_wdata[1:0];
				end else if (iomem_addr[7:0] == 8'h50) begin
					iomem_rdata <= {31'd0, dac_ena};
					if (iomem_wstrb[0]) dac_ena <= iomem_wdata[0];
				end else if (iomem_addr[7:0] == 8'h54) begin
					iomem_rdata <= {22'd0, dac_value};
					if (iomem_wstrb[0]) dac_value[7:0] <= iomem_wdata[7:0];
					if (iomem_wstrb[1]) dac_value[9:8] <= iomem_wdata[9:8];
				end else if (iomem_addr[7:0] == 8'h60) begin
					iomem_rdata <= {31'd0, comp_ena};
					if (iomem_wstrb[0]) comp_ena <= iomem_wdata[0];
				end else if (iomem_addr[7:0] == 8'h64) begin
					iomem_rdata <= {30'd0, comp_ninputsrc};
					if (iomem_wstrb[0]) comp_ninputsrc <= iomem_wdata[1:0];
				end else if (iomem_addr[7:0] == 8'h68) begin
					iomem_rdata <= {30'd0, comp_pinputsrc};
					if (iomem_wstrb[0]) comp_pinputsrc <= iomem_wdata[1:0];
				end else if (iomem_addr[7:0] == 8'h6c) begin
					iomem_rdata <= {30'd0, comp_output_dest};
					if (iomem_wstrb[0]) comp_output_dest <= iomem_wdata[1:0];
				end else if (iomem_addr[7:0] == 8'h70) begin
					iomem_rdata <= {31'd0, rcosc_ena};
					if (iomem_wstrb[0]) rcosc_ena <= iomem_wdata[0];
				end else if (iomem_addr[7:0] == 8'h74) begin
					iomem_rdata <= {30'd0, rcosc_output_dest};
					if (iomem_wstrb[0]) rcosc_output_dest <= iomem_wdata[1:0];
				end else if (iomem_addr[7:0] == 8'h80) begin
					iomem_rdata <= {24'd0, spi_ro_config};
				end else if (iomem_addr[7:0] == 8'h84) begin
					iomem_rdata <= {22'd0, spi_ro_pll_div, spi_ro_pll_sel, spi_ro_xtal_ena, spi_ro_reg_ena};
				end else if (iomem_addr[7:0] == 8'h88) begin
					iomem_rdata <= {5'd0, spi_ro_pll_trim, spi_ro_pll_dco_ena};
				end else if (iomem_addr[7:0] == 8'h8c) begin
					iomem_rdata <= {20'd0, spi_ro_mfgr_id};
				end else if (iomem_addr[7:0] == 8'h90) begin
					iomem_rdata <= {24'd0, spi_ro_prod_id};
				end else if (iomem_addr[7:0] == 8'h94) begin
					iomem_rdata <= {28'd0, spi_ro_mask_rev};
				end else if (iomem_addr[7:0] == 8'h98) begin
					iomem_rdata <= {31'd0, ext_clk_sel};
				end else if (iomem_addr[7:0] == 8'ha0) begin
					iomem_rdata <= {30'd0, xtal_output_dest};
					if (iomem_wstrb[0]) xtal_output_dest <= iomem_wdata[1:0];
				end else if (iomem_addr[7:0] == 8'ha4) begin
					iomem_rdata <= {30'd0, pll_output_dest};
					if (iomem_wstrb[0]) pll_output_dest <= iomem_wdata[1:0];
				end else if (iomem_addr[7:0] == 8'ha8) begin
					iomem_rdata <= {30'd0, trap_output_dest};
					if (iomem_wstrb[0]) trap_output_dest <= iomem_wdata[1:0];
				end else if (iomem_addr[7:0] == 8'hb0) begin
					iomem_rdata <= {30'd0, irq_7_inputsrc};
					if (iomem_wstrb[0]) irq_7_inputsrc <= iomem_wdata[1:0];
				end else if (iomem_addr[7:0] == 8'hb4) begin
					iomem_rdata <= {30'd0, irq_8_inputsrc};
					if (iomem_wstrb[0]) irq_8_inputsrc <= iomem_wdata[1:0];
				end else if (iomem_addr[7:0] == 8'hc0) begin
					iomem_rdata <= {31'd0, analog_out_sel};
					if (iomem_wstrb[0]) analog_out_sel <= iomem_wdata[0];
				end else if (iomem_addr[7:0] == 8'hc4) begin
					iomem_rdata <= {31'd0, opamp_bias_ena};
					if (iomem_wstrb[0]) opamp_bias_ena <= iomem_wdata[0];
				end else if (iomem_addr[7:0] == 8'hc8) begin
					iomem_rdata <= {31'd0, opamp_ena};
					if (iomem_wstrb[0]) opamp_ena <= iomem_wdata[0];
				end else if (iomem_addr[7:0] == 8'hd0) begin
					iomem_rdata <= {31'd0, bg_ena};
					if (iomem_wstrb[0]) bg_ena <= iomem_wdata[0];
				end else if (iomem_addr[7:0] == 8'he0) begin
					iomem_rdata <= {31'd0, overtemp_ena};
					if (iomem_wstrb[0]) overtemp_ena <= iomem_wdata[0];
				end else if (iomem_addr[7:0] == 8'he4) begin
					iomem_rdata <= {31'd0, overtemp};
				end else if (iomem_addr[7:0] == 8'he8) begin
					iomem_rdata <= {30'd0, overtemp_dest};
					if (iomem_wstrb[0]) overtemp_dest <= iomem_wdata[1:0];
				end
			end
		end
	end

	openstriVe_soc_mem #(.WORDS(MEM_WORDS)) picomem (
		.clk(clk),
		.ena(resetn),
		.wen((mem_valid && !mem_ready && mem_addr < 4*MEM_WORDS) ? mem_wstrb : 4'b0),
		.addr(mem_addr[23:2]),
		.wdata(mem_wdata),
		.rdata(ram_rdata)
	);
endmodule

`include "picorv32.v"
`include "spimemio.v"
`include "simpleuart.v"

// Implementation note:
// Replace the following two modules with wrappers for your SRAM cells.

module openstriVe_soc_regs (
	input clk, wen,
	input [5:0] waddr,
	input [5:0] raddr1,
	input [5:0] raddr2,
	input [31:0] wdata,
	output [31:0] rdata1,
	output [31:0] rdata2
);
	reg [31:0] regs [0:31];

	always @(posedge clk)
		if (wen) regs[waddr[4:0]] <= wdata;

	assign rdata1 = regs[raddr1[4:0]];
	assign rdata2 = regs[raddr2[4:0]];
endmodule

module openstriVe_soc_mem #(
	parameter integer WORDS = 256
) (
	input clk,
	input ena,
	input [3:0] wen,
	input [21:0] addr,
	input [31:0] wdata,
	output reg [31:0] rdata
);
	reg [31:0] mem [0:WORDS-1];

	always @(posedge clk) begin
		if (ena == 1'b1) begin
			rdata <= mem[addr];
			if (wen[0]) mem[addr][ 7: 0] <= wdata[ 7: 0];
			if (wen[1]) mem[addr][15: 8] <= wdata[15: 8];
			if (wen[2]) mem[addr][23:16] <= wdata[23:16];
			if (wen[3]) mem[addr][31:24] <= wdata[31:24];
		end
	end
endmodule

/* Convert the standard set of GPIO signals: input, output, output_enb,
 * pullup, and pulldown into the set needed by the s8 GPIO pads:
 * input, output, output_enb, input_enb, mode.  Note that dm[2] on
 * thepads is always equal to dm[1] in this setup, so mode is shown as
 * only a 2-bit signal.
 *
 * This module is bit-sliced.  Instantiate once for each GPIO pad.
 */

module convert_gpio_sigs (
    input        gpio_out,
    input        gpio_outenb,
    input        gpio_pu,
    input        gpio_pd,
    output       gpio_out_pad,
    output       gpio_outenb_pad,
    output       gpio_inenb_pad,
    output       gpio_mode1_pad,
    output       gpio_mode0_pad
);

    assign gpio_out_pad = (gpio_pu == 1'b0 && gpio_pd == 1'b0) ? gpio_out :
            (gpio_pu == 1'b1) ? 1 : 0;

    assign gpio_outenb_pad = (gpio_outenb == 1'b0) ? 0 :
            (gpio_pu == 1'b1 || gpio_pd == 1'b1) ? 0 : 1;

    assign gpio_inenb_pad = ~gpio_outenb;

    assign gpio_mode1_pad = ~gpio_outenb_pad;
    assign gpio_mode0_pad = gpio_outenb;

endmodule

