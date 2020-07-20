//------------------------------------------------
// spi_slave.v
//------------------------------------------------
// General purpose SPI slave module
//------------------------------------------------
// Written by Tim Edwards
// efabless, inc., april 23, 2017
//------------------------------------------------
// This file is distributed free and open source
//------------------------------------------------

// SCK ---   Clock input
// SDI ---   Data  input
// SDO ---   Data  output
// CSB ---   Chip  select (sense negative)
// idata --- Data from chip to transmit out, in 8 bits
// odata --- Input data to chip, in 8 bits
// addr  --- Decoded address to upstream circuits
// rdstb --- Read strobe, tells upstream circuit to supply next byte to idata
// wrstb --- Write strobe, tells upstream circuit to latch odata.

// Data format (general purpose):
// 8 bit format
// 1st byte:   Command word (see below)
// 2nd byte:   Address word (register 0 to 255)
// 3rd byte:   Data word    (value 0 to 255)

// Command format:
// 00000000  No operation
// 10000000  Write until CSB raised
// 01000000  Read  until CSB raised
// 11000000  Simultaneous read/write until CSB raised
// wrnnn000  Read/write as above, for nnn = 1 to 7 bytes, then terminate

// Lower three bits are reserved for future use.
// All serial bytes are read and written msb first.

// Fixed control and status registers

// Address 0 is reserved and contains flags for SPI mode.  This is
// currently undefined and is always value 0.
// Address 1 is reserved and contains manufacturer ID low 8 bits.
// Address 2 is reserved and contains manufacturer ID high 4 bits
// and mask revision number (4 bits).
// Address 3 is reserved and contains product ID (8 bits).
// Addresses 4 to 255 are available for general purpose use.

`define COMMAND  2'b00
`define ADDRESS  2'b01
`define DATA     2'b10
`define IDLE     2'b11	// Not used

module spi_slave(SCK, SDI, CSB, SDO, sdoenb, idata, odata, oaddr, rdstb, wrstb);
    input SCK;
    input SDI;
    input CSB;
    output SDO;
    output sdoenb;
    input [7:0] idata;
    output [7:0] odata;
    output [7:0] oaddr;
    output rdstb;
    output wrstb; 

    reg  [7:0]  addr;
    reg		wrstb;
    reg		rdstb;
    reg		sdoenb;
    reg  [1:0]  state;
    reg  [2:0]  count;
    reg		writemode;
    reg		readmode;
    reg  [2:0]	fixed;
    wire [7:0]  odata;
    reg  [6:0]  predata;
    wire [7:0]  oaddr;
    reg  [7:0]  ldata;

    assign odata = {predata, SDI};
    assign oaddr = (state == `ADDRESS) ? {addr[6:0], SDI} : addr;
    assign SDO = ldata[7];

    // Readback data is captured on the falling edge of SCK so that
    // it is guaranteed valid at the next rising edge.
    always @(negedge SCK or posedge CSB) begin
	if (CSB == 1'b1) begin
	    wrstb <= 1'b0;
	    ldata  <= 8'b00000000;
	    sdoenb <= 1'b1;
        end else begin

	    // After CSB low, 1st SCK starts command

	    if (state == `DATA) begin
		if (readmode == 1'b1) begin
		    sdoenb <= 1'b0;
		    if (count == 3'b000) begin
			ldata <= idata;
		    end else begin
			ldata <= {ldata[6:0], 1'b0};	// Shift out
		    end
		end else begin
		    sdoenb <= 1'b1;
		end

		// Apply write strobe on SCK negative edge on the next-to-last
		// data bit so that it updates data on the rising edge of SCK
		// on the last data bit.
 
		if (count == 3'b111) begin
		    if (writemode == 1'b1) begin
			wrstb <= 1'b1;
 		    end
		end else begin
		    wrstb <= 1'b0;
		end
	    end else begin
		wrstb <= 1'b0;
		sdoenb <= 1'b1;
	    end		// ! state `DATA
	end		// ! CSB
    end			// always @ ~SCK

    always @(posedge SCK or posedge CSB) begin
	if (CSB == 1'b1) begin
	    // Default state on reset
	    addr <= 8'h00;
	    rdstb <= 1'b0;
	    predata <= 7'b0000000;
	    state  <= `COMMAND;
	    count  <= 3'b000;
	    readmode <= 1'b0;
	    writemode <= 1'b0;
	    fixed <= 3'b000;
        end else begin
	    // After CSB low, 1st SCK starts command
	    if (state == `COMMAND) begin
		rdstb <= 1'b0;
		count <= count + 1;
		if (count == 3'b000) begin
		    writemode <= SDI;
		end else if (count == 3'b001) begin
		    readmode <= SDI;
		end else if (count < 3'b101) begin
		    fixed <= {fixed[1:0], SDI}; 
		end else if (count == 3'b111) begin
		    state <= `ADDRESS;
		end
	    end else if (state == `ADDRESS) begin
		count <= count + 1;
		addr <= {addr[6:0], SDI};
		if (count == 3'b111) begin
		    if (readmode == 1'b1) begin
			rdstb <= 1'b1;
		    end
		    state <= `DATA;
		end else begin
		    rdstb <= 1'b0;
		end
	    end else if (state == `DATA) begin
		predata <= {predata[6:0], SDI};
		count <= count + 1;
		if (count == 3'b111) begin
		    if (fixed == 3'b001) begin
			state <= `COMMAND;
		    end else if (fixed != 3'b000) begin
			fixed <= fixed - 1;
			addr <= addr + 1;	// Auto increment address (fixed)
		    end else begin	
			addr <= addr + 1;	// Auto increment address (streaming)
		    end
		end else begin
		    rdstb <= 1'b0;
		end
	    end		// ! state `DATA
	end		// ! CSB
    end			// always @ SCK

endmodule // spi_slave
