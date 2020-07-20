//-------------------------------------
// SPI controller for striVe (PicoSoC)
//-------------------------------------
// Written by Tim Edwards
// efabless, inc. December 23, 2019
//-------------------------------------

`include "spi_slave.v"

//-----------------------------------------------------------
// This is a standalone slave SPI for the striVe chip that is
// intended to be independent of the picosoc and independent
// of all IP blocks except the power-on-reset.  This SPI has
// register outputs controlling the functions that critically
// affect operation of the picosoc and so cannot be accessed
// from the picosoc itself.  This includes the PLL enables
// and trim, and the crystal oscillator enable.  It also has
// a general reset for the picosoc, an IRQ input, a bypass for
// the entire crystal oscillator and PLL chain, the
// manufacturer and product IDs and product revision number.
// To be independent of the 1.8V regulator, the slave SPI is
// synthesized with the 3V digital library and runs off of
// the 3V supply.
//
//-----------------------------------------------------------

//------------------------------------------------------------
// Picochip defined registers:
// Register 0:  SPI status and control (unused & reserved)
// Register 1h: Mask revision (= 0) (readonly)
// Register 1l and 2:  Manufacturer ID (0x456) (readonly)
// Register 3:  Product ID (= 2) (readonly)
//
// Register 4:  SkyWater IP enable and trim (xtal, regulator, PLL)  (8 bits)
// Register 5:  PLL bypass (1 bit)
// Register 6:  IRQ (1 bit)
// Register 7:  reset (1 bit)
// Register 8:  trap (1 bit) (readonly)
//------------------------------------------------------------

module striVe_spi(
`ifdef LVS
	vdd, vss, 
`endif
	RSTB, SCK, SDI, CSB, SDO, sdo_enb,
	xtal_ena, reg_ena, pll_dco_ena, pll_div, pll_sel,
	pll_trim, pll_bypass, irq, reset, RST, trap,
	mfgr_id, prod_id, mask_rev_in, mask_rev);

`ifdef LVS
    inout vdd;	    // 3.3V supply
    inout vss;	    // common ground
`endif
    
    input RSTB;	    // 3.3V domain
    input SCK;	    // 3.3V domain
    input SDI;	    // 3.3V domain
    input CSB;	    // 3.3V domain
    output SDO;	    // 3.3V domain
    output sdo_enb;
    output xtal_ena;
    output reg_ena;
    output pll_dco_ena;
    output [25:0] pll_trim;
    output [2:0] pll_sel;
    output [4:0] pll_div;
    output pll_bypass;
    output irq;
    output reset;
    output RST;
    input  trap;
    input [3:0] mask_rev_in;	// metal programmed;  3.3V domain
    output [11:0] mfgr_id;
    output [7:0] prod_id;
    output [3:0] mask_rev;

    reg xtal_ena;
    reg reg_ena;
    reg [25:0] pll_trim;
    reg [4:0] pll_div;
    reg [2:0] pll_sel;
    reg pll_dco_ena;
    reg pll_bypass;
    reg irq;
    reg reset;

    wire [7:0] odata;
    wire [7:0] idata;
    wire [7:0] iaddr;

    wire trap;
    wire rdstb;
    wire wrstb;

    assign RST = ~RSTB;

    // Instantiate the SPI slave module

    spi_slave U1 (
	.SCK(SCK),
	.SDI(SDI),
	.CSB(CSB),
	.SDO(SDO),
	.sdoenb(sdo_enb),
	.idata(odata),
	.odata(idata),
	.oaddr(iaddr),
	.rdstb(rdstb),
	.wrstb(wrstb)
    );

    wire [11:0] mfgr_id;
    wire [7:0] prod_id;
    wire [3:0] mask_rev;

    assign mfgr_id = 12'h456;		// Hard-coded
    assign prod_id = 8'h05;		// Hard-coded
    assign mask_rev = mask_rev_in;	// Copy in to out.

    // Send register contents to odata on SPI read command
    // All values are 1-4 bits and no shadow registers are required.

    assign odata = 
	(iaddr == 8'h00) ? 8'h00 :	// SPI status (fixed)
	(iaddr == 8'h01) ? {mask_rev, mfgr_id[11:8]} : 	// Mask rev (metal programmed)
	(iaddr == 8'h02) ? mfgr_id[7:0] :	// Manufacturer ID (fixed)
	(iaddr == 8'h03) ? prod_id :	// Product ID (fixed)
	(iaddr == 8'h04) ? {5'b00000, xtal_ena, reg_ena, pll_dco_ena} :
	(iaddr == 8'h05) ? {7'b0000000, pll_bypass} :
	(iaddr == 8'h06) ? {7'b0000000, irq} :
	(iaddr == 8'h07) ? {7'b0000000, reset} :
	(iaddr == 8'h08) ? {7'b0000000, trap} :
	(iaddr == 8'h09) ? pll_trim[7:0] :
	(iaddr == 8'h0a) ? pll_trim[15:8] :
	(iaddr == 8'h0b) ? pll_trim[23:16] :
	(iaddr == 8'h0c) ? {6'b000000, pll_trim[25:24]} :
	(iaddr == 8'h0d) ? {5'b00000, pll_sel} :
	(iaddr == 8'h0e) ? {3'b000, pll_div} :
			   8'h00;	// Default

    // Register mapping and I/O to slave module

    always @(posedge SCK or negedge RSTB) begin
	if (RSTB == 1'b0) begin
	    // Set trim for PLL at (almost) slowest rate (~90MHz).  However,
	    // pll_trim[12] must be set to zero for proper startup.
	    pll_trim <= 26'b11111111111110111111111111;
	    pll_sel <= 3'b000;
	    pll_div <= 5'b00100;	// Default divide-by-8
	    xtal_ena <= 1'b1;
	    reg_ena <= 1'b1;
	    pll_dco_ena <= 1'b1;	// Default free-running PLL
	    pll_bypass <= 1'b1;		// NOTE: Default bypass mode (don't use PLL)
	    irq <= 1'b0;
	    reset <= 1'b0;
	end else if (wrstb == 1'b1) begin
	    case (iaddr)
		8'h04: begin
			 pll_dco_ena <= idata[2];
			 reg_ena    <= idata[1];
			 xtal_ena  <= idata[0];
		       end
		8'h05: begin
			 pll_bypass <= idata[0];
		       end
		8'h06: begin
			 irq <= idata[0];
		       end
		8'h07: begin
			 reset <= idata[0];
		       end
		// Register 8 is read-only
		8'h09: begin
 			 pll_trim[7:0] <= idata;
		       end
		8'h0a: begin
 			 pll_trim[15:8] <= idata;
		       end
		8'h0b: begin
 			 pll_trim[23:16] <= idata;
		       end
		8'h0c: begin
 			 pll_trim[25:24] <= idata[1:0];
		       end
		8'h0d: begin
			 pll_sel <= idata[2:0];
		       end
		8'h0e: begin
			 pll_div <= idata[4:0];
		       end
	    endcase	// (iaddr)
	end
    end
endmodule	// striVe_spi_orig
