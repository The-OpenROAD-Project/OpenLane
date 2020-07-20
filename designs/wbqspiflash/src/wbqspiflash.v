////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	wbspiflash.v
//
// Project:	A Set of Wishbone Controlled SPI Flash Controllers
//
// Purpose:	Access a Quad SPI flash via a WISHBONE interface.  This
//		includes both read and write (and erase) commands to the SPI
//		flash.  All read/write commands are accomplished using the
//		high speed (4-bit) interface.  Further, the device will be
//		left/kept in the 4-bit read interface mode between accesses,
//		for a minimum read latency.
//
//	Wishbone Registers (See spec sheet for more detail):
//	0: local config(r) / erase commands(w) / deep power down cmds / etc.
//	R: (Write in Progress), (dirty-block), (spi_port_busy), 1'b0, 9'h00,
//		{ last_erased_sector, 14'h00 } if (WIP)
//		else { current_sector_being_erased, 14'h00 }
//		current if write in progress, last if written
//	W: (1'b1 to erase), (12'h ignored), next_erased_block, 14'h ignored)
//	1: Configuration register
//	2: Status register (R/w)
//	3: Read ID (read only)
//	(19 bits): Data (R/w, but expect writes to take a while)
//		
//	This core has been deprecated.  All of my new projects are using one of
//	my universal flash controllers now: qflexpress, dualflexpress, or spixpress.
//	These can be found in my https://github.com/ZipCPU/qspiflash repository.
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2015-2019, Gisselquist Technology, LLC
//
// This file is part of the set of Wishbone controlled SPI flash controllers
// project
//
// The Wishbone SPI flash controller project is free software (firmware):
// you can redistribute it and/or modify it under the terms of the GNU Lesser
// General Public License as published by the Free Software Foundation, either
// version 3 of the License, or (at your option) any later version.
//
// The Wishbone SPI flash controller project is distributed in the hope
// that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTIBILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  (It's in the $(ROOT)/doc directory.  Run make
// with no target there if the PDF file isn't present.)  If not, see
// <http://www.gnu.org/licenses/> for a copy.
//
// License:	LGPL, v3, as defined and found on www.gnu.org,
//		http://www.gnu.org/licenses/lgpl.html
//
//
////////////////////////////////////////////////////////////////////////////////
//
//
//
`default_nettype	none
//
`define	WBQSPI_RESET		5'd0
`define	WBQSPI_RESET_QUADMODE	5'd1
`define	WBQSPI_IDLE		5'd2
`define	WBQSPI_RDIDLE		5'd3	// Idle, but in fast read mode
`define	WBQSPI_WBDECODE		5'd4
`define	WBQSPI_RD_DUMMY		5'd5
`define	WBQSPI_QRD_ADDRESS	5'd6
`define	WBQSPI_QRD_DUMMY	5'd7
`define	WBQSPI_READ_CMD		5'd8
`define	WBQSPI_READ_DATA	5'd9
`define	WBQSPI_WAIT_TIL_RDIDLE	5'd10
`define	WBQSPI_READ_ID_CMD	5'd11
`define	WBQSPI_READ_ID		5'd12
`define	WBQSPI_READ_STATUS	5'd13
`define	WBQSPI_READ_CONFIG	5'd14
`define	WBQSPI_WAIT_TIL_IDLE	5'd15
//
//
`define	WBQSPI_WAIT_WIP_CLEAR	5'd16
`define	WBQSPI_CHECK_WIP_CLEAR	5'd17
`define	WBQSPI_CHECK_WIP_DONE	5'd18
`define	WBQSPI_WEN		5'd19
`define	WBQSPI_PP		5'd20	// Program page
`define	WBQSPI_QPP		5'd21	// Program page, 4 bit mode
`define	WBQSPI_WR_DATA		5'd22
`define	WBQSPI_WR_BUS_CYCLE	5'd23
`define	WBQSPI_WRITE_STATUS	5'd24
`define	WBQSPI_WRITE_CONFIG	5'd25
`define	WBQSPI_ERASE_WEN	5'd26
`define	WBQSPI_ERASE_CMD	5'd27
`define	WBQSPI_ERASE_BLOCK	5'd28
`define	WBQSPI_CLEAR_STATUS	5'd29
`define	WBQSPI_IDLE_CHECK_WIP	5'd30
//
module	wbqspiflash(i_clk,
		// Internal wishbone connections
		i_wb_cyc, i_wb_data_stb, i_wb_ctrl_stb, i_wb_we,
		i_wb_addr, i_wb_data,
		// Wishbone return values
		o_wb_ack, o_wb_stall, o_wb_data,
		// Quad Spi connections to the external device
		o_qspi_sck, o_qspi_cs_n, o_qspi_mod, o_qspi_dat, i_qspi_dat,
		o_interrupt);
	parameter	ADDRESS_WIDTH=22;
	parameter [0:0]	OPT_READ_ONLY = 1'b0;
	localparam	AW = ADDRESS_WIDTH-2;
	input	wire		i_clk;
	// Wishbone, inputs first
	input	wire		i_wb_cyc, i_wb_data_stb, i_wb_ctrl_stb, i_wb_we;
	input	wire	[(AW-1):0]	i_wb_addr;
	input	wire	[31:0]	i_wb_data;
	// then outputs
	output	reg		o_wb_ack;
	output	reg		o_wb_stall;
	output	reg	[31:0]	o_wb_data;
	// Quad SPI control wires
	output	wire		o_qspi_sck, o_qspi_cs_n;
	output	wire	[1:0]	o_qspi_mod;
	output	wire	[3:0]	o_qspi_dat;
	input	wire	[3:0]	i_qspi_dat;
	// Interrupt line
	output	reg		o_interrupt;
	// output	wire	[31:0]	o_debug;

	reg		spi_wr, spi_hold, spi_spd, spi_dir;
	reg	[31:0]	spi_in;
	reg	[1:0]	spi_len;
	wire	[31:0]	spi_out;
	wire		spi_valid, spi_busy;
	wire		w_qspi_sck, w_qspi_cs_n;
	wire	[3:0]	w_qspi_dat;
	wire	[1:0]	w_qspi_mod;
	// wire	[22:0]	spi_dbg;
	llqspi	lldriver(i_clk,
			spi_wr, spi_hold, spi_in, spi_len, spi_spd, spi_dir,
				spi_out, spi_valid, spi_busy,
			w_qspi_sck, w_qspi_cs_n, w_qspi_mod, w_qspi_dat,
				i_qspi_dat);

	// Erase status tracking
	reg		write_in_progress, write_protect;
	reg	[(ADDRESS_WIDTH-17):0]	erased_sector;
	reg		dirty_sector;
	initial	begin
		write_in_progress = 1'b0;
		erased_sector = 0;
		dirty_sector  = 1'b1;
		write_protect = 1'b1;
	end

	wire	[23:0]	w_wb_addr;
	generate
	if (ADDRESS_WIDTH>=24)
		assign w_wb_addr = { i_wb_addr[21:0], 2'b00 };
	else
		assign w_wb_addr = { {(24-ADDRESS_WIDTH){1'b0}}, i_wb_addr, 2'b00 };
	endgenerate

	// Repeat for spif_addr
	reg	[(ADDRESS_WIDTH-3):0]	spif_addr;
	wire	[23:0]	w_spif_addr;
	generate
	if (ADDRESS_WIDTH>=24)
		assign w_spif_addr = { spif_addr[21:0], 2'b00 };
	else
		assign w_spif_addr = { {(24-ADDRESS_WIDTH){1'b0}}, spif_addr, 2'b00 };
	endgenerate
		
	reg	[7:0]	last_status;
	reg	[9:0]	reset_counter;
	reg		quad_mode_enabled;
	reg		spif_cmd, spif_override;
	reg	[31:0]	spif_data;
	reg	[4:0]	state;
	reg		spif_ctrl, spif_req;
	reg		alt_cmd, alt_ctrl;
	wire	[(ADDRESS_WIDTH-17):0]	spif_sector;
	assign	spif_sector = spif_addr[(AW-1):14];

	// assign	o_debug = { spi_wr, spi_spd, spi_hold, state, spi_dbg };

	initial	state = `WBQSPI_RESET;
	initial o_wb_ack   = 1'b0;
	initial o_wb_stall = 1'b1;
	initial spi_wr     = 1'b0;
	initial	spi_len    = 2'b00;
	initial	quad_mode_enabled = 1'b0;
	initial o_interrupt = 1'b0;
	initial	spif_override = 1'b1;
	initial	spif_ctrl     = 1'b0;
	always @(posedge i_clk)
	begin
	spif_override <= 1'b0;
	alt_cmd  <= (reset_counter[9:8]==2'b10)?reset_counter[3]:1'b1; // Toggle CS_n
	alt_ctrl <= (reset_counter[9:8]==2'b10)?reset_counter[0]:1'b1; // Toggle clock too
	if (state == `WBQSPI_RESET)
	begin
		// From a reset, we should
		//	Enable the Quad I/O mode
		//	Disable the Write protection bits in the status register
		//	Chip should already be up and running, so we can start
		//	immediately ....
		o_wb_ack <= 1'b0;
		o_wb_stall <= 1'b1;
		spi_wr   <= 1'b0;
		spi_hold <= 1'b0;
		spi_spd  <= 1'b0;
		spi_dir  <= 1'b0;
		last_status <= 8'h00;
		state <= `WBQSPI_RESET_QUADMODE;
		spif_req <= 1'b0;
		spif_override <= 1'b1;
		last_status   <= 8'h00; //
		reset_counter <= 10'h3fc; //
			// This guarantees that we aren't starting in quad
			// I/O mode, where the FPGA configuration scripts may
			// have left us.
	end else if (state == `WBQSPI_RESET_QUADMODE)
	begin
		// Okay, so here's the problem: we don't know whether or not
		// the Xilinx loader started us up in Quad Read I/O idle mode.
		// So, thus we need to toggle the clock and CS_n, with fewer
		// clocks than are necessary to transmit a word.
		//
		// Not ready to handle the bus yet, so stall any requests
		o_wb_ack   <= 1'b0;
		o_wb_stall <= 1'b1;

		// Do something ...
		if (reset_counter == 10'h00)
		begin
			spif_override <= 1'b0;
			state <= `WBQSPI_IDLE;

			// Find out if we can use Quad I/O mode ...
			state <= `WBQSPI_READ_CONFIG;
			spi_wr <= 1'b1;
			spi_len <= 2'b01;
			spi_in <= { 8'h35, 24'h00};

		end else begin
			reset_counter <= reset_counter - 10'h1;
			spif_override <= 1'b1;
		end
	end else if (state == `WBQSPI_IDLE)
	begin
		o_interrupt <= 1'b0;
		o_wb_stall <= 1'b0;
		o_wb_ack <= 1'b0;
		spif_cmd   <= i_wb_we;
		spif_addr  <= i_wb_addr;
		spif_data  <= i_wb_data;
		spif_ctrl  <= (i_wb_ctrl_stb)&&(!i_wb_data_stb);
		spif_req   <= (i_wb_ctrl_stb)||(i_wb_data_stb);
		spi_wr <= 1'b0; // Keep the port idle, unless told otherwise
		spi_hold <= 1'b0;
		spi_spd  <= 1'b0;
		spi_dir <= 1'b0; // Write (for now, 'cause of cmd)
		// Data register access
		if (i_wb_data_stb)
		begin

			if ((OPT_READ_ONLY)&&(i_wb_we)) // Write request
			begin
				o_wb_ack <= 1'b1;
				o_wb_stall <= 1'b0;
			end else if (i_wb_we) // Request to write a page
			begin
				if((!write_protect)&&(!write_in_progress))
				begin // 00
					spi_wr <= 1'b1;
					spi_len <= 2'b00; // 8 bits
					// Send a write enable command
					spi_in <= { 8'h06, 24'h00 };
					state <= `WBQSPI_WEN;

					o_wb_ack <= 1'b0;
					o_wb_stall <= 1'b1;
				end else if (write_protect)
				begin // whether or not write-in_progress ...
					// Do nothing on a write protect
					// violation
					//
					o_wb_ack <= 1'b1;
					o_wb_stall <= 1'b0;
				end else begin // write is in progress, wait
					// for it to complete
					state <= `WBQSPI_WAIT_WIP_CLEAR;
					o_wb_ack <= 1'b0;
					o_wb_stall <= 1'b1;
				end
			end else if (!write_in_progress)
			begin // Read access, normal mode(s)
				o_wb_ack   <= 1'b0;
				o_wb_stall <= 1'b1;
				spi_wr     <= 1'b1;	// Write cmd to device
				if (quad_mode_enabled)
				begin
					spi_in <= { 8'heb, w_wb_addr };
					state <= `WBQSPI_QRD_ADDRESS;
					spi_len    <= 2'b00; // single byte, cmd only
				end else begin
					spi_in <= { 8'h0b, w_wb_addr };
					state <= `WBQSPI_RD_DUMMY;
					spi_len    <= 2'b11; // cmd+addr,32bits
				end
			end else if (!OPT_READ_ONLY) begin
				// A write is in progress ... need to stall
				// the bus until the write is complete.
				state <= `WBQSPI_WAIT_WIP_CLEAR;
				o_wb_ack   <= 1'b0;
				o_wb_stall <= 1'b1;
			end
		end else if ((OPT_READ_ONLY)&&(i_wb_ctrl_stb)&&(i_wb_we))
		begin
			o_wb_ack   <= 1'b1;
			o_wb_stall <= 1'b0;
		end else if ((i_wb_ctrl_stb)&&(i_wb_we))
		begin
			o_wb_stall <= 1'b1;
			case(i_wb_addr[1:0])
			2'b00: begin // Erase command register
				write_protect <= !i_wb_data[28];
				o_wb_stall <= 1'b0;

				if((i_wb_data[31])&&(!write_in_progress))
				begin
					// Command an erase--ack it immediately

					o_wb_ack <= 1'b1;
					o_wb_stall <= 1'b0;

					if ((i_wb_data[31])&&(!write_protect))
					begin
						spi_wr <= 1'b1;
						spi_len <= 2'b00;
						// Send a write enable command
						spi_in <= { 8'h06, 24'h00 };
						state <= `WBQSPI_ERASE_CMD;
						o_wb_stall <= 1'b1;
					end
				end else if (i_wb_data[31])
				begin
					state <= `WBQSPI_WAIT_WIP_CLEAR;
					o_wb_ack   <= 1'b1;
					o_wb_stall <= 1'b1;
				end else begin
					o_wb_ack   <= 1'b1;
					o_wb_stall <= 1'b0;
				end end
			2'b01: begin
				// Write the configuration register
				o_wb_ack <= 1'b1;
				o_wb_stall <= 1'b1;

				// Need to send a write enable command first
				spi_wr <= 1'b1;
				spi_len <= 2'b00; // 8 bits
				// Send a write enable command
				spi_in <= { 8'h06, 24'h00 };
				state <= `WBQSPI_WRITE_CONFIG;
				end
			2'b10: begin
				// Write the status register
				o_wb_ack <= 1'b1; // Ack immediately
				o_wb_stall <= 1'b1; // Stall other cmds
				// Need to send a write enable command first
				spi_wr <= 1'b1;
				spi_len <= 2'b00; // 8 bits
				// Send a write enable command
				spi_in <= { 8'h06, 24'h00 };
				state <= `WBQSPI_WRITE_STATUS;
				end
			2'b11: begin // Write the ID register??? makes no sense
				o_wb_ack <= 1'b1;
				o_wb_stall <= 1'b0;
				end
			endcase
		end else if (i_wb_ctrl_stb) // &&(!i_wb_we))
		begin
			case(i_wb_addr[1:0])
			2'b00: begin // Read local register
				if (write_in_progress) // Read status
				begin// register, is write still in progress?
					state <= `WBQSPI_READ_STATUS;
					spi_wr <= 1'b1;
					spi_len <= 2'b01;// 8 bits out, 8 bits in
					spi_in <= { 8'h05, 24'h00};

					o_wb_ack <= 1'b0;
					o_wb_stall <= 1'b1;
				end else begin // Return w/o talking to device
					o_wb_ack <= 1'b1;
					o_wb_stall <= 1'b0;
					o_wb_data <= { write_in_progress,
						dirty_sector, spi_busy,
						~write_protect,
						quad_mode_enabled,
						{(29-ADDRESS_WIDTH){1'b0}},
						erased_sector, 14'h000 };
				end end
			2'b01: begin // Read configuration register
				state <= `WBQSPI_READ_CONFIG;
				spi_wr <= 1'b1;
				spi_len <= 2'b01;
				spi_in <= { 8'h35, 24'h00};

				o_wb_ack <= 1'b0;
				o_wb_stall <= 1'b1;
				end
			2'b10: begin // Read status register
				state <= `WBQSPI_READ_STATUS;
				spi_wr <= 1'b1;
				spi_len <= 2'b01; // 8 bits out, 8 bits in
				spi_in <= { 8'h05, 24'h00};

				o_wb_ack <= 1'b0;
				o_wb_stall <= 1'b1;
				end
			2'b11: begin // Read ID register
				state <= `WBQSPI_READ_ID_CMD;
				spi_wr <= 1'b1;
				spi_len <= 2'b00;
				spi_in <= { 8'h9f, 24'h00};

				o_wb_ack <= 1'b0;
				o_wb_stall <= 1'b1;
				end
			endcase
		end else if ((!OPT_READ_ONLY)&&(!i_wb_cyc)&&(write_in_progress))
		begin
			state <= `WBQSPI_IDLE_CHECK_WIP;
			spi_wr <= 1'b1;
			spi_len <= 2'b01; // 8 bits out, 8 bits in
			spi_in <= { 8'h05, 24'h00};

			o_wb_ack <= 1'b0;
			o_wb_stall <= 1'b1;
		end
	end else if (state == `WBQSPI_RDIDLE)
	begin
		spi_wr <= 1'b0;
		o_wb_stall <= 1'b0;
		o_wb_ack <= 1'b0;
		spif_cmd   <= i_wb_we;
		spif_addr  <= i_wb_addr;
		spif_data  <= i_wb_data;
		spif_ctrl  <= (i_wb_ctrl_stb)&&(!i_wb_data_stb);
		spif_req   <= (i_wb_ctrl_stb)||(i_wb_data_stb);
		spi_hold <= 1'b0;
		spi_spd<= 1'b1;
		spi_dir <= 1'b0; // Write (for now)
		if ((i_wb_data_stb)&&(!i_wb_we))
		begin // Continue our read ... send the new address / mode
			o_wb_stall <= 1'b1;
			spi_wr <= 1'b1;
			spi_len <= 2'b10; // Write address, but not mode byte
			spi_in <= { w_wb_addr, 8'ha0 };
			state <= `WBQSPI_QRD_DUMMY;
		end else if((i_wb_ctrl_stb)&&(!i_wb_we)&&(i_wb_addr[1:0] == 2'b00))
		begin
			// A local read that doesn't touch the device, so leave
			// the device in its current state
			o_wb_stall <= 1'b0;
			o_wb_ack <= 1'b1;
			o_wb_data <= { write_in_progress,
					dirty_sector, spi_busy,
					~write_protect,
					quad_mode_enabled,
					{(29-ADDRESS_WIDTH){1'b0}},
					erased_sector, 14'h000 };
		end else if(((i_wb_ctrl_stb)||(i_wb_data_stb)))
		begin // Need to release the device from quad mode for all else
			o_wb_ack   <= 1'b0;
			o_wb_stall <= 1'b1;
			spi_wr <= 1'b1;
			spi_len <= 2'b11;
			spi_in <= 32'h00;
			state <= `WBQSPI_WBDECODE;
		end
	end else if (state == `WBQSPI_WBDECODE)
	begin
		// We were in quad SPI read mode, and had to get out.
		// Now we've got a command (not data read) to read and
		// execute.  Accomplish what we would've done while in the
		// IDLE state here, save only that we don't have to worry
		// about data reads, and we need to operate on a stored
		// version of the bus command
		o_wb_stall <= 1'b1;
		o_wb_ack <= 1'b0;
		spi_wr <= 1'b0; // Keep the port idle, unless told otherwise
		spi_hold <= 1'b0;
		spi_spd <= 1'b0;
		spi_dir <= 1'b0;
		spif_req<= (spif_req) && (i_wb_cyc);
		if ((!spi_busy)&&(o_qspi_cs_n)&&(!spi_wr)) // only in full idle ...
		begin
			// Data register access
			if (!spif_ctrl)
			begin
				if ((OPT_READ_ONLY)&&(spif_cmd)) // Request to write a page
				begin
					o_wb_ack <= spif_req;
					o_wb_stall <= 1'b0;
					state <= `WBQSPI_IDLE;
				end else if (spif_cmd)
				begin
					if((!write_protect)&&(!write_in_progress))
					begin // 00
						spi_wr <= 1'b1;
						spi_len <= 2'b00; // 8 bits
						// Send a write enable command
						spi_in <= { 8'h06, 24'h00 };
						state <= `WBQSPI_WEN;
	
						o_wb_ack <= 1'b0;
						o_wb_stall <= 1'b1;
					end else if (write_protect)
					begin // whether or not write-in_progress ...
						// Do nothing on a write protect
						// violation
						//
						o_wb_ack <= spif_req;
						o_wb_stall <= 1'b0;
						state <= `WBQSPI_IDLE;
					end else begin // write is in progress, wait
						// for it to complete
						state <= `WBQSPI_WAIT_WIP_CLEAR;
						o_wb_ack <= 1'b0;
						o_wb_stall <= 1'b1;
					end
				// end else if (!write_in_progress) // always true
				// but ... we wouldn't get here on a normal read access
				end else begin
					// Something's wrong, we should never
					//   get here
					// Attempt to go to idle to recover
					state <= `WBQSPI_IDLE;
				end
			end else if ((OPT_READ_ONLY)&&(spif_ctrl)&&(spif_cmd))
			begin
				o_wb_ack   <= spif_req;
				o_wb_stall <= 1'b0;
				state <= `WBQSPI_IDLE;
			end else if ((spif_ctrl)&&(spif_cmd)) begin
				o_wb_stall <= 1'b1;
				case(spif_addr[1:0])
				2'b00: begin // Erase command register
					o_wb_ack   <= spif_req;
					o_wb_stall <= 1'b0;
					state <= `WBQSPI_IDLE;
					write_protect <= ~spif_data[28];
					// Are we commanding an erase?
					// We're in read mode, writes cannot
					// be in progress, so ...
					if (spif_data[31]) // Command an erase
					begin
						// Since we're not going back
						// to IDLE, we must stall the
						// bus here
						o_wb_stall <= 1'b1;
						spi_wr <= 1'b1;
						spi_len <= 2'b00;
						// Send a write enable command
						spi_in <= { 8'h06, 24'h00 };
						state <= `WBQSPI_ERASE_CMD;
					end end
				2'b01: begin
					// Write the configuration register
					o_wb_ack <= spif_req;
					o_wb_stall <= 1'b1;

					// Need to send a write enable command first
					spi_wr <= 1'b1;
					spi_len <= 2'b00; // 8 bits
					// Send a write enable command
					spi_in <= { 8'h06, 24'h00 };
					state <= `WBQSPI_WRITE_CONFIG;
					end
				2'b10: begin
					// Write the status register
					o_wb_ack <= spif_req; // Ack immediately
					o_wb_stall <= 1'b1; // Stall other cmds
					// Need to send a write enable command first
					spi_wr <= 1'b1;
					spi_len <= 2'b00; // 8 bits
					// Send a write enable command
					spi_in <= { 8'h06, 24'h00 };
					state <= `WBQSPI_WRITE_STATUS;
					end
				2'b11: begin // Write the ID register??? makes no sense
					o_wb_ack <= spif_req;
					o_wb_stall <= 1'b0;
					state <= `WBQSPI_IDLE;
					end
				endcase
			end else begin // on (!spif_we)
				case(spif_addr[1:0])
				2'b00: begin // Read local register
					// Nonsense case--would've done this
					// already
					state <= `WBQSPI_IDLE;
					o_wb_ack <= spif_req;
					o_wb_stall <= 1'b0;
					end
				2'b01: begin // Read configuration register
					state <= `WBQSPI_READ_CONFIG;
					spi_wr <= 1'b1;
					spi_len <= 2'b01;
					spi_in <= { 8'h35, 24'h00};

					o_wb_ack <= 1'b0;
					o_wb_stall <= 1'b1;
					end
				2'b10: begin // Read status register
					state <= `WBQSPI_READ_STATUS;
					spi_wr <= 1'b1;
					spi_len <= 2'b01; // 8 bits out, 8 bits in
					spi_in <= { 8'h05, 24'h00};

					o_wb_ack <= 1'b0;
					o_wb_stall <= 1'b1;
					end
				2'b11: begin // Read ID register
					state <= `WBQSPI_READ_ID_CMD;
					spi_wr <= 1'b1;
					spi_len <= 2'b00;
					spi_in <= { 8'h9f, 24'h00};

					o_wb_ack <= 1'b0;
					o_wb_stall <= 1'b1;
					end
				endcase
			end
		end
//
//
//	READ DATA section: for both data and commands
//
	end else if (state == `WBQSPI_RD_DUMMY)
	begin
		o_wb_ack   <= 1'b0;
		o_wb_stall <= 1'b1;

		spi_wr <= 1'b1; // Non-stop
		// Need to read one byte of dummy data,
		// just to consume 8 clocks
		spi_in <= { 8'h00, 24'h00 };
		spi_len <= 2'b00; // Read 8 bits
		spi_spd <= 1'b0;
		spi_hold <= 1'b0;
		spif_req<= (spif_req) && (i_wb_cyc);
		
		if ((!spi_busy)&&(!o_qspi_cs_n))
			// Our command was accepted
			state <= `WBQSPI_READ_CMD;
	end else if (state == `WBQSPI_QRD_ADDRESS)
	begin
		// We come in here immediately upon issuing a QRD read
		// command (8-bits), but we have to pause to give the
		// address (24-bits) and mode (8-bits) in quad speed.
		o_wb_ack   <= 1'b0;
		o_wb_stall <= 1'b1;

		spi_wr <= 1'b1; // Non-stop
		spi_in <= { w_spif_addr, 8'ha0 };
		spi_len <= 2'b10; // Write address, not mode byte
		spi_spd <= 1'b1;
		spi_dir <= 1'b0; // Still writing
		spi_hold <= 1'b0;
		spif_req<= (spif_req) && (i_wb_cyc);
		
		if ((!spi_busy)&&(spi_spd))
			// Our command was accepted
			state <= `WBQSPI_QRD_DUMMY;
	end else if (state == `WBQSPI_QRD_DUMMY)
	begin
		o_wb_ack   <= 1'b0;
		o_wb_stall <= 1'b1;

		spi_wr <= 1'b1; // Non-stop
		spi_in <= { 8'ha0, 24'h00 }; // Mode byte, then 2 bytes dummy
		spi_len <= 2'b10; // Write 24 bits
		spi_spd <= 1'b1;
		spi_dir <= 1'b0; // Still writing
		spi_hold <= 1'b0;
		spif_req<= (spif_req) && (i_wb_cyc);
		
		if ((!spi_busy)&&(spi_in[31:28] == 4'ha))
			// Our command was accepted
			state <= `WBQSPI_READ_CMD;
	end else if (state == `WBQSPI_READ_CMD)
	begin // Issue our first command to read 32 bits.
		o_wb_ack   <= 1'b0;
		o_wb_stall <= 1'b1;

		spi_wr <= 1'b1;
		spi_in <= { 8'hff, 24'h00 }; // Empty
		spi_len <= 2'b11; // Read 32 bits
		spi_dir <= 1'b1; // Now reading
		spi_hold <= 1'b0;
		spif_req<= (spif_req) && (i_wb_cyc);
		if ((spi_valid)&&(spi_len == 2'b11))
			state <= `WBQSPI_READ_DATA;
	end else if (state == `WBQSPI_READ_DATA)
	begin
		// Pipelined read support
		spi_wr <=((i_wb_data_stb)&&(!i_wb_we)&&(i_wb_addr== (spif_addr+1)))&&(spif_req);
		spi_in <= 32'h00;
		spi_len <= 2'b11;
		// Don't adjust the speed here, it was set in the setup
		spi_dir <= 1'b1;	// Now we get to read
		// Don't let the device go to idle until the bus cycle ends.
		//	This actually prevents a *really* nasty race condition,
		//	where the strobe comes in after the lower level device
		//	has decided to stop waiting.  The write is then issued,
		//	but no one is listening.  By leaving the device open,
		//	the device is kept in a state where a valid strobe
		//	here will be useful.  Of course, we don't accept
		//	all commands, just reads.  Further, the strobe needs
		//	to be high for two clocks cycles without changing
		//	anything on the bus--one for us to notice it and pull
		//	our head out of the sand, and a second for whoever
		//	owns the bus to realize their command went through.
		spi_hold <= 1'b1;
		spif_req<= (spif_req) && (i_wb_cyc);
		if ((spi_valid)&&(!spi_in[31]))
		begin // Single pulse acknowledge and write data out
			o_wb_ack <= spif_req;
			o_wb_stall <= (!spi_wr);
			// adjust endian-ness to match the PC
			o_wb_data <= spi_out; 
			state <= (spi_wr)?`WBQSPI_READ_DATA
				: ((spi_spd) ? `WBQSPI_WAIT_TIL_RDIDLE : `WBQSPI_WAIT_TIL_IDLE);
			spif_req <= spi_wr;
			spi_hold <= (!spi_wr);
			if (spi_wr)
				spif_addr <= i_wb_addr;
		end else if ((!spif_req)||(!i_wb_cyc))
		begin // FAIL SAFE: If the bus cycle ends, forget why we're
			// here, just go back to idle
			state <= ((spi_spd) ? `WBQSPI_WAIT_TIL_RDIDLE : `WBQSPI_WAIT_TIL_IDLE);
			spi_hold <= 1'b0;
			o_wb_ack <= 1'b0;
			o_wb_stall <= 1'b1;
		end else begin
			o_wb_ack <= 1'b0;
			o_wb_stall <= 1'b1;
		end
	end else if (state == `WBQSPI_WAIT_TIL_RDIDLE)
	begin // Wait 'til idle, but then go to fast read idle instead of full
		spi_wr     <= 1'b0;	// idle
		spi_hold   <= 1'b0;
		o_wb_stall <= 1'b1;
		o_wb_ack   <= 1'b0;
		spif_req   <= 1'b0;
		if ((!spi_busy)&&(o_qspi_cs_n)&&(!spi_wr)) // Wait for a full
		begin // clearing of the SPI port before moving on
			state <= `WBQSPI_RDIDLE;
			o_wb_stall <= 1'b0; 
			o_wb_ack   <= 1'b0;// Shouldn't be acking anything here
		end
	end else if (state == `WBQSPI_READ_ID_CMD)
	begin // We came into here immediately after issuing a 0x9f command
		// Now we need to read 32 bits of data.  Result should be
		// 0x0102154d (8'h manufacture ID, 16'h device ID, followed
		// by the number of extended bytes available 8'h4d).
		o_wb_ack <= 1'b0;
		o_wb_stall<= 1'b1;

		spi_wr <= 1'b1; // No data to send, but need four bytes, since
		spi_len <= 2'b11; // 32 bits of data are ... useful
		spi_in <= 32'h00; // Irrelevant
		spi_spd <= 1'b0; // Slow speed
		spi_dir <= 1'b1; // Reading
		spi_hold <= 1'b0;
		spif_req <= (spif_req) && (i_wb_cyc);
		if ((!spi_busy)&&(!o_qspi_cs_n)&&(spi_len == 2'b11))
			// Our command was accepted, now go read the result
			state <= `WBQSPI_READ_ID;
	end else if (state == `WBQSPI_READ_ID)
	begin
		o_wb_ack <= 1'b0; // Assuming we're still waiting
		o_wb_stall <= 1'b1;

		spi_wr <= 1'b0; // No more writes, we've already written the cmd
		spi_hold <= 1'b0;
		spif_req <= (spif_req) && (i_wb_cyc);

		// Here, we just wait until the result comes back
		// The problem is, the result may be the previous result.
		// So we use spi_len as an indicator
		spi_len <= 2'b00;
		if((spi_valid)&&(spi_len==2'b00))
		begin // Put the results out as soon as possible
			o_wb_data <= spi_out[31:0];
			o_wb_ack <= spif_req;
			spif_req <= 1'b0;
		end else if ((!spi_busy)&&(o_qspi_cs_n))
		begin
			state <= `WBQSPI_IDLE;
			o_wb_stall <= 1'b0;
		end
	end else if (state == `WBQSPI_READ_STATUS)
	begin // We enter after the command has been given, for now just
		// read and return
		spi_wr <= 1'b0;
		o_wb_ack <= 1'b0;
		spi_hold <= 1'b0;
		spif_req <= (spif_req) && (i_wb_cyc);
		if (spi_valid)
		begin
			o_wb_ack <= spif_req;
			o_wb_stall <= 1'b1;
			spif_req <= 1'b0;
			last_status <= spi_out[7:0];
			write_in_progress <= spi_out[0];
			if (spif_addr[1:0] == 2'b00) // Local read, checking
			begin // status, 'cause we're writing
				o_wb_data <= { spi_out[0],
					dirty_sector, spi_busy,
					~write_protect,
					quad_mode_enabled,
					{(29-ADDRESS_WIDTH){1'b0}},
					erased_sector, 14'h000 };
			end else begin
				o_wb_data <= { 24'h00, spi_out[7:0] };
			end
		end

		if ((!spi_busy)&&(!spi_wr))
			state <= `WBQSPI_IDLE;
	end else if (state == `WBQSPI_READ_CONFIG)
	begin // We enter after the command has been given, for now just
		// read and return
		spi_wr <= 1'b0;
		o_wb_ack <= 1'b0;
		o_wb_stall <= 1'b1;
		spi_hold <= 1'b0;
		spif_req <= (spif_req) && (i_wb_cyc);

		if (spi_valid)
		begin
			o_wb_data <= { 24'h00, spi_out[7:0] };
			quad_mode_enabled <= spi_out[1];
		end

		if ((!spi_busy)&&(!spi_wr))
		begin
			state <= `WBQSPI_IDLE;
			o_wb_ack   <= spif_req;
			o_wb_stall <= 1'b0;
			spif_req <= 1'b0;
		end

//
//
//	Write/erase data section
//
	end else if ((!OPT_READ_ONLY)&&(state == `WBQSPI_WAIT_WIP_CLEAR))
	begin
		o_wb_stall <= 1'b1;
		o_wb_ack   <= 1'b0;
		spi_wr <= 1'b0;
		spif_req<= (spif_req) && (i_wb_cyc);
		if (!spi_busy)
		begin
			spi_wr   <= 1'b1;
			spi_in   <= { 8'h05, 24'h0000 };
			spi_hold <= 1'b1;
			spi_len  <= 2'b01; // 16 bits write, so we can read 8
			state <= `WBQSPI_CHECK_WIP_CLEAR;
			spi_spd  <= 1'b0; // Slow speed
			spi_dir  <= 1'b0;
		end
	end else if ((!OPT_READ_ONLY)&&(state == `WBQSPI_CHECK_WIP_CLEAR))
	begin
		o_wb_stall <= 1'b1;
		o_wb_ack   <= 1'b0;
		// Repeat as often as necessary until we are clear
		spi_wr <= 1'b1;
		spi_in <= 32'h0000; // Values here are actually irrelevant
		spi_hold <= 1'b1;
		spi_len <= 2'b00; // One byte at a time
		spi_spd  <= 1'b0; // Slow speed
		spi_dir  <= 1'b0;
		spif_req<= (spif_req) && (i_wb_cyc);
		if ((spi_valid)&&(!spi_out[0]))
		begin
			state <= `WBQSPI_CHECK_WIP_DONE;
			spi_wr   <= 1'b0;
			spi_hold <= 1'b0;
			write_in_progress <= 1'b0;
			last_status <= spi_out[7:0];
		end
	end else if ((!OPT_READ_ONLY)&&(state == `WBQSPI_CHECK_WIP_DONE))
	begin
		o_wb_stall <= 1'b1;
		o_wb_ack   <= 1'b0;
		// Let's let the SPI port come back to a full idle,
		// and the chip select line go low before continuing
		spi_wr   <= 1'b0;
		spi_len  <= 2'b00;
		spi_hold <= 1'b0;
		spi_spd  <= 1'b0; // Slow speed
		spi_dir  <= 1'b0;
		spif_req<= (spif_req) && (i_wb_cyc);
		if ((o_qspi_cs_n)&&(!spi_busy)) // Chip select line is high, we can continue
		begin
			spi_wr   <= 1'b0;
			spi_hold <= 1'b0;

			casez({ spif_cmd, spif_ctrl, spif_addr[1:0] })
			4'b00??: begin // Read data from ... somewhere
				spi_wr     <= 1'b1;	// Write cmd to device
				if (quad_mode_enabled)
				begin
					spi_in <= { 8'heb, w_spif_addr };
					state <= `WBQSPI_QRD_ADDRESS;
					// spi_len    <= 2'b00; // single byte, cmd only
				end else begin
					spi_in <= { 8'h0b, w_spif_addr };
					state <= `WBQSPI_RD_DUMMY;
					spi_len    <= 2'b11; // Send cmd and addr
				end end
			4'b10??: begin // Write data to ... anywhere
				spi_wr <= 1'b1;
				spi_len <= 2'b00; // 8 bits
				// Send a write enable command
				spi_in <= { 8'h06, 24'h00 };
				state <= `WBQSPI_WEN;
				end
			4'b0110: begin // Read status register
				state <= `WBQSPI_READ_STATUS;
				spi_wr <= 1'b1;
				spi_len <= 2'b01; // 8 bits out, 8 bits in
				spi_in <= { 8'h05, 24'h00};
				end
			4'b0111: begin
				state <= `WBQSPI_READ_ID_CMD;
				spi_wr <= 1'b1;
				spi_len <= 2'b00;
				spi_in <= { 8'h9f, 24'h00};
				end
			default: begin //
				o_wb_stall <= 1'b1;
				o_wb_ack <= spif_req;
				state <= `WBQSPI_WAIT_TIL_IDLE;
				end
			endcase
		// spif_cmd   <= i_wb_we;
		// spif_addr  <= i_wb_addr;
		// spif_data  <= i_wb_data;
		// spif_ctrl  <= (i_wb_ctrl_stb)&&(!i_wb_data_stb);
		// spi_wr <= 1'b0; // Keep the port idle, unless told otherwise
		end
	end else if ((!OPT_READ_ONLY)&&(state == `WBQSPI_WEN))
	begin // We came here after issuing a write enable command
		spi_wr <= 1'b0;
		o_wb_ack <= 1'b0;
		o_wb_stall <= 1'b1;
		spif_req<= (spif_req) && (i_wb_cyc);
		if ((!spi_busy)&&(o_qspi_cs_n)&&(!spi_wr)) // Let's come to a full stop
			state <= (quad_mode_enabled)?`WBQSPI_QPP:`WBQSPI_PP;
			// state <= `WBQSPI_PP;
	end else if ((!OPT_READ_ONLY)&&(state == `WBQSPI_PP))
	begin // We come here under a full stop / full port idle mode
		// Issue our command immediately
		spi_wr <= 1'b1;
		spi_in <= { 8'h02, w_spif_addr };
		spi_len <= 2'b11;
		spi_hold <= 1'b1;
		spi_spd  <= 1'b0;
		spi_dir  <= 1'b0; // Writing
		spif_req<= (spif_req) && (i_wb_cyc);

		// Once we get busy, move on
		if (spi_busy)
			state <= `WBQSPI_WR_DATA;
		if (spif_sector == erased_sector)
			dirty_sector <= 1'b1;
	end else if ((!OPT_READ_ONLY)&&(state == `WBQSPI_QPP))
	begin // We come here under a full stop / full port idle mode
		// Issue our command immediately
		spi_wr <= 1'b1;
		spi_in <= { 8'h32, w_spif_addr };
		spi_len <= 2'b11;
		spi_hold <= 1'b1;
		spi_spd  <= 1'b0;
		spi_dir  <= 1'b0; // Writing
		spif_req<= (spif_req) && (i_wb_cyc);

		// Once we get busy, move on
		if (spi_busy)
		begin
			// spi_wr is irrelevant here ...
			// Set the speed value once, but wait til we get busy
			// to do so.
			spi_spd <= 1'b1;
			state <= `WBQSPI_WR_DATA;
		end
		if (spif_sector == erased_sector)
			dirty_sector <= 1'b1;
	end else if ((!OPT_READ_ONLY)&&(state == `WBQSPI_WR_DATA))
	begin
		o_wb_stall <= 1'b1;
		o_wb_ack   <= 1'b0;
		spi_wr   <= 1'b1; // write without waiting
		spi_in   <= spif_data;
		spi_len  <= 2'b11; // Write 4 bytes
		spi_hold <= 1'b1;
		if (!spi_busy)
		begin
			o_wb_ack <= spif_req; // Ack when command given
			state <= `WBQSPI_WR_BUS_CYCLE;
		end
		spif_req<= (spif_req) && (i_wb_cyc);
	end else if ((!OPT_READ_ONLY)&&(state == `WBQSPI_WR_BUS_CYCLE))
	begin
		o_wb_ack <= 1'b0; // Turn off our ack and stall flags
		o_wb_stall <= 1'b1;
		spi_wr <= 1'b0;
		spi_hold <= 1'b1;
		write_in_progress <= 1'b1;
		spif_req<= (spif_req) && (i_wb_cyc);
		if (!i_wb_cyc)
		begin
			state <= `WBQSPI_WAIT_TIL_IDLE;
			spi_hold <= 1'b0;
		end else if (spi_wr)
		begin // Give the SPI a chance to get busy on the last write
			// Do nothing here.
		end else if ((spif_req)&&(i_wb_data_stb)&&(i_wb_we)
				&&(i_wb_addr == (spif_addr+1))
				&&(i_wb_addr[(AW-1):6]==spif_addr[(AW-1):6]))
		begin
			spif_cmd  <= 1'b1;
			spif_data <= i_wb_data;
			spif_addr <= i_wb_addr;
			spif_ctrl  <= 1'b0;
			spif_req<= 1'b1;
			// We'll keep the bus stalled on this request
			// for a while
			state <= `WBQSPI_WR_DATA;
			o_wb_ack   <= 1'b0;
			o_wb_stall <= 1'b0;
		end else if ((i_wb_data_stb|i_wb_ctrl_stb)&&(!o_wb_ack)) // Writing out of bounds
		begin
			spi_hold <= 1'b0;
			spi_wr   <= 1'b0;
			state <= `WBQSPI_WAIT_TIL_IDLE;
		end // Otherwise we stay here
	end else if ((!OPT_READ_ONLY)&&(state == `WBQSPI_WRITE_CONFIG))
	begin // We enter immediately after commanding a WEN
		o_wb_ack   <= 1'b0;
		o_wb_stall <= 1'b1;

		spi_len <= 2'b10;
		spi_in <= { 8'h01, last_status, spif_data[7:0], 8'h00 };
		spi_wr <= 1'b0;
		spi_hold <= 1'b0;
		spif_req <= (spif_req) && (i_wb_cyc);
		if ((!spi_busy)&&(!spi_wr))
		begin
			spi_wr <= 1'b1;
			state <= `WBQSPI_WAIT_TIL_IDLE;
			write_in_progress <= 1'b1;
			quad_mode_enabled <= spif_data[1];
		end
	end else if ((!OPT_READ_ONLY)&&(state == `WBQSPI_WRITE_STATUS))
	begin // We enter immediately after commanding a WEN
		o_wb_ack   <= 1'b0;
		o_wb_stall <= 1'b1;

		spi_len <= 2'b01;
		spi_in <= { 8'h01, spif_data[7:0], 16'h00 };
		// last_status <= i_wb_data[7:0]; // We'll read this in a moment
		spi_wr <= 1'b0;
		spi_hold <= 1'b0;
		spif_req <= (spif_req) && (i_wb_cyc);
		if ((!spi_busy)&&(!spi_wr))
		begin
			spi_wr <= 1'b1;
			last_status <= spif_data[7:0];
			write_in_progress <= 1'b1;
			if(((last_status[6])||(last_status[5]))
				&&((!spif_data[6])&&(!spif_data[5])))
				state <= `WBQSPI_CLEAR_STATUS;
			else
				state <= `WBQSPI_WAIT_TIL_IDLE;
		end
	end else if ((!OPT_READ_ONLY)&&(state == `WBQSPI_ERASE_CMD))
	begin // Know that WIP is clear on entry, WEN has just been commanded
		spi_wr     <= 1'b0;
		o_wb_ack   <= 1'b0;
		o_wb_stall <= 1'b1;
		spi_hold   <= 1'b0;
		spi_spd <= 1'b0;
		spi_dir <= 1'b0;
		spif_req <= (spif_req) && (i_wb_cyc);

		// Here's the erase command
		spi_in <= { 8'hd8, 2'h0, spif_data[19:14], 14'h000, 2'b00 };
		spi_len <= 2'b11; // 32 bit write
		// together with setting our copy of the WIP bit
		write_in_progress <= 1'b1;
		// keeping track of which sector we just erased
		erased_sector <= spif_data[(AW-1):14];
		// and marking this erase sector as no longer dirty
		dirty_sector <= 1'b0;

		// Wait for a full stop before issuing this command
		if ((!spi_busy)&&(!spi_wr)&&(o_qspi_cs_n))
		begin // When our command is accepted, move to the next state
			spi_wr <= 1'b1;
			state <= `WBQSPI_ERASE_BLOCK;
		end
	end else if ((!OPT_READ_ONLY)&&(state == `WBQSPI_ERASE_BLOCK))
	begin
		spi_wr     <= 1'b0;
		spi_hold   <= 1'b0;
		o_wb_stall <= 1'b1;
		o_wb_ack   <= 1'b0;
		spif_req <= (spif_req) && (i_wb_cyc);
		// When the port clears, we can head back to idle
		//	No ack necessary, we ackd before getting
		//	here.
		if ((!spi_busy)&&(!spi_wr))
			state <= `WBQSPI_IDLE;
	end else if ((!OPT_READ_ONLY)&&(state == `WBQSPI_CLEAR_STATUS))
	begin // Issue a clear status command
		spi_wr <= 1'b1;
		spi_hold <= 1'b0;
		spi_len <= 2'b00; // 8 bit command
		spi_in <= { 8'h30, 24'h00 };
		spi_spd <= 1'b0;
		spi_dir <= 1'b0;
		last_status[6:5] <= 2'b00;
		spif_req <= (spif_req) && (i_wb_cyc);
		if ((spi_wr)&&(!spi_busy))
			state <= `WBQSPI_WAIT_TIL_IDLE;
	end else if ((!OPT_READ_ONLY)&&(state == `WBQSPI_IDLE_CHECK_WIP))
	begin // We are now in read status register mode

		// No bus commands have (yet) been given
		o_wb_stall <= 1'b1;
		o_wb_ack   <= 1'b0;
		spif_req <= (spif_req) && (i_wb_cyc);

		// Stay in this mode unless/until we get a command, or
		// 	the write is over
		spi_wr <= (((!i_wb_cyc)||((!i_wb_data_stb)&&(!i_wb_ctrl_stb)))
				&&(write_in_progress));
		spi_len <= 2'b00; // 8 bit reads
		spi_spd <= 1'b0;  // SPI, not quad
		spi_dir <= 1'b1;  // Read
		if (spi_valid)
		begin
			write_in_progress <= spi_out[0];
			if ((!spi_out[0])&&(write_in_progress))
				o_interrupt <= 1'b1;
		end else
			o_interrupt <= 1'b0;

		if ((!spi_wr)&&(!spi_busy)&&(o_qspi_cs_n))
		begin // We can now go to idle and process a command
			o_wb_stall <= 1'b0;
			o_wb_ack   <= 1'b0;
			state <= `WBQSPI_IDLE;
		end
	end else // if (state == `WBQSPI_WAIT_TIL_IDLE) or anything else
	begin
		spi_wr     <= 1'b0;
		spi_hold   <= 1'b0;
		o_wb_stall <= 1'b1;
		o_wb_ack   <= 1'b0;
		spif_req   <= 1'b0;
		if ((!spi_busy)&&(o_qspi_cs_n)&&(!spi_wr)) // Wait for a full
		begin // clearing of the SPI port before moving on
			state <= `WBQSPI_IDLE;
			o_wb_stall <= 1'b0; 
			o_wb_ack   <= 1'b0; // Shouldn't be acking anything here
		end
	end
	end

	// Command and control during the reset sequence
	assign	o_qspi_cs_n = (spif_override)?alt_cmd :w_qspi_cs_n;
	assign	o_qspi_sck  = (spif_override)?alt_ctrl:w_qspi_sck;
	assign	o_qspi_mod  = (spif_override)?  2'b01 :w_qspi_mod;
	assign	o_qspi_dat  = (spif_override)?  4'b00 :w_qspi_dat;
endmodule

`default_nettype	none
//
`define	QSPI_IDLE	3'h0
`define	QSPI_START	3'h1
`define	QSPI_BITS	3'h2
`define	QSPI_READY	3'h3
`define	QSPI_HOLDING	3'h4
`define	QSPI_STOP	3'h5
`define	QSPI_STOP_B	3'h6

// Modes
`define	QSPI_MOD_SPI	2'b00
`define	QSPI_MOD_QOUT	2'b10
`define	QSPI_MOD_QIN	2'b11

// Which level of formal proofs will we be doing?  As a component, or a
// top-level?
`ifdef	LLQSPI_TOP
`define	ASSUME	assume
`else
`define	ASSUME	assert
`endif
//
module	llqspi(i_clk,
		// Module interface
		i_wr, i_hold, i_word, i_len, i_spd, i_dir,
			o_word, o_valid, o_busy,
		// QSPI interface
		o_sck, o_cs_n, o_mod, o_dat, i_dat);
	input	wire		i_clk;
	// Chip interface
	//	Can send info
	//		i_dir = 1, i_spd = 0, i_hold = 0, i_wr = 1,
	//			i_word = { 1'b0, 32'info to send },
	//			i_len = # of bytes in word-1
	input	wire		i_wr, i_hold;
	input	wire	[31:0]	i_word;
	input	wire	[1:0]	i_len;	// 0=>8bits, 1=>16 bits, 2=>24 bits, 3=>32 bits
	input	wire		i_spd; // 0 -> normal QPI, 1 -> QSPI
	input	wire		i_dir; // 0 -> read, 1 -> write to SPI
	output	reg	[31:0]	o_word;
	output	reg		o_valid, o_busy;
	// Interface with the QSPI lines
	output	reg		o_sck;
	output	reg		o_cs_n;
	output	reg	[1:0]	o_mod;
	output	reg	[3:0]	o_dat;
	input	wire	[3:0]	i_dat;

	// output	wire	[22:0]	o_dbg;
	// assign	o_dbg = { state, spi_len,
		// o_busy, o_valid, o_cs_n, o_sck, o_mod, o_dat, i_dat };

	// Timing:
	//
	//	Tick	Clk	BSY/WR	CS_n	BIT/MO	STATE
	//	 0	1	0/0	1	 -	
	//	 1	1	0/1	1	 -
	//	 2	1	1/0	0	 -	QSPI_START
	//	 3	0	1/0	0	 -	QSPI_START
	//	 4	0	1/0	0	 0	QSPI_BITS
	//	 5	1	1/0	0	 0	QSPI_BITS
	//	 6	0	1/0	0	 1	QSPI_BITS
	//	 7	1	1/0	0	 1	QSPI_BITS
	//	 8	0	1/0	0	 2	QSPI_BITS
	//	 9	1	1/0	0	 2	QSPI_BITS
	//	10	0	1/0	0	 3	QSPI_BITS
	//	11	1	1/0	0	 3	QSPI_BITS
	//	12	0	1/0	0	 4	QSPI_BITS
	//	13	1	1/0	0	 4	QSPI_BITS
	//	14	0	1/0	0	 5	QSPI_BITS
	//	15	1	1/0	0	 5	QSPI_BITS
	//	16	0	1/0	0	 6	QSPI_BITS
	//	17	1	1/1	0	 6	QSPI_BITS
	//	18	0	1/1	0	 7	QSPI_READY
	//	19	1	0/1	0	 7	QSPI_READY
	//	20	0	1/0/V	0	 8	QSPI_BITS
	//	21	1	1/0	0	 8	QSPI_BITS
	//	22	0	1/0	0	 9	QSPI_BITS
	//	23	1	1/0	0	 9	QSPI_BITS
	//	24	0	1/0	0	10	QSPI_BITS
	//	25	1	1/0	0	10	QSPI_BITS
	//	26	0	1/0	0	11	QSPI_BITS
	//	27	1	1/0	0	11	QSPI_BITS
	//	28	0	1/0	0	12	QSPI_BITS
	//	29	1	1/0	0	12	QSPI_BITS
	//	30	0	1/0	0	13	QSPI_BITS
	//	31	1	1/0	0	13	QSPI_BITS
	//	32	0	1/0	0	14	QSPI_BITS
	//	33	1	1/0	0	14	QSPI_BITS
	//	34	0	1/0	0	15	QSPI_READY
	//	35	1	1/0	0	15	QSPI_READY
	//	36	1	1/0/V	0	 -	QSPI_STOP
	//	37	1	1/0	0	 -	QSPI_STOPB
	//	38	1	1/0	1	 -	QSPI_IDLE
	//	39	1	0/0	1	 -
	// Now, let's switch from single bit to quad mode
	//	40	1	0/0	1	 -	QSPI_IDLE
	//	41	1	0/1	1	 -	QSPI_IDLE
	//	42	1	1/0	0	 -	QSPI_START
	//	43	0	1/0	0	 -	QSPI_START
	//	44	0	1/0	0	 0	QSPI_BITS
	//	45	1	1/0	0	 0	QSPI_BITS
	//	46	0	1/0	0	 1	QSPI_BITS
	//	47	1	1/0	0	 1	QSPI_BITS
	//	48	0	1/0	0	 2	QSPI_BITS
	//	49	1	1/0	0	 2	QSPI_BITS
	//	50	0	1/0	0	 3	QSPI_BITS
	//	51	1	1/0	0	 3	QSPI_BITS
	//	52	0	1/0	0	 4	QSPI_BITS
	//	53	1	1/0	0	 4	QSPI_BITS
	//	54	0	1/0	0	 5	QSPI_BITS
	//	55	1	1/0	0	 5	QSPI_BITS
	//	56	0	1/0	0	 6	QSPI_BITS
	//	57	1	1/1/QR	0	 6	QSPI_BITS
	//	58	0	1/1/QR	0	 7	QSPI_READY
	//	59	1	0/1/QR	0	 7	QSPI_READY
	//	60	0	1/0/?/V	0	 8-11	QSPI_BITS
	//	61	1	1/0/?	0	 8-11	QSPI_BITS
	//	62	0	1/0/?	0	 12-15	QSPI_BITS
	//	63	1	1/0/?	0	 12-15	QSPI_BITS
	//	64	1	1/0/?/V	0	-	QSPI_STOP
	//	65	1	1/0/?	0	-	QSPI_STOPB
	//	66	1	1/0/?	1	-	QSPI_IDLE
	//	67	1	0/0	1	-	QSPI_IDLE
	// Now let's try something entirely in Quad read mode, from the
	// beginning
	//	68	1	0/1/QR	1	-	QSPI_IDLE
	//	69	1	1/0	0	-	QSPI_START
	//	70	0	1/0	0	-	QSPI_START
	//	71	0	1/0	0	0-3	QSPI_BITS
	//	72	1	1/0	0	0-3	QSPI_BITS
	//	73	0	1/1/QR	0	4-7	QSPI_BITS
	//	74	1	0/1/QR	0	4-7	QSPI_BITS
	//	75	0	1/?/?/V	0	8-11	QSPI_BITS
	//	76	1	1/?/?	0	8-11	QSPI_BITS
	//	77	0	1/1/QR	0	12-15	QSPI_BITS
	//	78	1	0/1/QR	0	12-15	QSPI_BITS
	//	79	0	1/?/?/V	0	16-19	QSPI_BITS
	//	80	1	1/0	0	16-19	QSPI_BITS
	//	81	0	1/0	0	20-23	QSPI_BITS
	//	82	1	1/0	0	20-23	QSPI_BITS
	//	83	1	1/0/V	0	-	QSPI_STOP
	//	84	1	1/0	0	-	QSPI_STOPB
	//	85	1	1/0	1	-	QSPI_IDLE
	//	86	1	0/0	1	-	QSPI_IDLE

	wire	i_miso;
	assign	i_miso = i_dat[1];

	reg		r_spd, r_dir;
	reg	[5:0]	spi_len;
	reg	[31:0]	r_word;
	reg	[30:0]	r_input;
	reg	[2:0]	state;
	initial	state = `QSPI_IDLE;
	initial	o_sck   = 1'b1;
	initial	o_cs_n  = 1'b1;
	initial	o_dat   = 4'hd;
	initial	o_valid = 1'b0;
	initial	o_busy  = 1'b0;
	initial	r_input = 31'h000;
	initial o_mod   = `QSPI_MOD_SPI;
	initial o_word  = 0;
	always @(posedge i_clk)
		if ((state == `QSPI_IDLE)&&(o_sck))
		begin
			o_cs_n <= 1'b1;
			o_valid <= 1'b0;
			o_busy  <= 1'b0;
			o_mod <= `QSPI_MOD_SPI;
			r_word <= i_word;
			r_spd <= i_spd;
			r_dir <= i_dir;
			if ((i_wr)&&(!o_busy))
			begin
				state <= `QSPI_START;
				spi_len<= { 1'b0, i_len, 3'b000 } + 6'h8;
				o_cs_n <= 1'b0;
				// o_sck <= 1'b1;
				o_busy <= 1'b1;
			end
		end else if (state == `QSPI_START)
		begin // We come in here with sck high, stay here 'til sck is low
			o_sck <= 1'b0;
			if (o_sck == 1'b0)
			begin
				state <= `QSPI_BITS;
				spi_len<= spi_len - ( (r_spd)? 6'h4 : 6'h1 );
				if (r_spd)
					r_word <= { r_word[27:0], 4'h0 };
				else
					r_word <= { r_word[30:0], 1'b0 };
			end
			o_mod <= (r_spd) ? { 1'b1, r_dir } : `QSPI_MOD_SPI;
			o_cs_n <= 1'b0;
			o_busy <= 1'b1;
			o_valid <= 1'b0;
			if (r_spd)
				o_dat <= r_word[31:28];
			else
				o_dat <= { 3'b110, r_word[31] };
		end else if (!o_sck)
		begin
			o_sck <= 1'b1;
			o_busy <= ((state != `QSPI_READY)||(!i_wr));
			o_valid <= 1'b0;
		end else if (state == `QSPI_BITS)
		begin
			// Should enter into here with at least a spi_len
			// of one, perhaps more
			o_sck <= 1'b0;
			o_busy <= 1'b1;
			if (r_spd)
			begin
				o_dat <= r_word[31:28];
				r_word <= { r_word[27:0], 4'h0 };
				spi_len <= spi_len - 6'h4;
				if (spi_len == 6'h4)
					state <= `QSPI_READY;
			end else begin
				o_dat <= { 3'b110, r_word[31] };
				r_word <= { r_word[30:0], 1'b0 };
				spi_len <= spi_len - 6'h1;
				if (spi_len == 6'h1)
					state <= `QSPI_READY;
			end

			o_valid <= 1'b0;
			if (!o_mod[1])
				r_input <= { r_input[29:0], i_miso };
			else if (o_mod[1])
				r_input <= { r_input[26:0], i_dat };
		end else if (state == `QSPI_READY)
		begin
			o_valid <= 1'b0;
			o_cs_n <= 1'b0;
			o_busy <= 1'b1;
			// This is the state on the last clock (both low and
			// high clocks) of the data.  Data is valid during
			// this state.  Here we chose to either STOP or
			// continue and transmit more.
			o_sck <= (i_hold); // No clocks while holding
			r_spd <= i_spd;
			r_dir <= i_dir;
			if (i_spd)
			begin
				r_word <= { i_word[27:0], 4'h0 };
				spi_len<= { 1'b0, i_len, 3'b000 } + 6'h8 - 6'h4;
			end else begin
				r_word <= { i_word[30:0], 1'b0 };
				spi_len<= { 1'b0, i_len, 3'b000 } + 6'h8 - 6'h1;
			end
			if((!o_busy)&&(i_wr))// Acknowledge a new request
			begin
				state <= `QSPI_BITS;
				o_busy <= 1'b1;
				o_sck <= 1'b0;

				// Read the new request off the bus
				// Set up the first bits on the bus
				o_mod <= (i_spd) ? { 1'b1, i_dir } : `QSPI_MOD_SPI;
				if (i_spd)
					o_dat <= i_word[31:28];
				else
					o_dat <= { 3'b110, i_word[31] };

			end else begin
				o_sck <= 1'b1;
				state <= (i_hold)?`QSPI_HOLDING : `QSPI_STOP;
				o_busy <= (!i_hold);
			end

			// Read a bit upon any transition
			o_valid <= 1'b1;
			if (!o_mod[1])
			begin
				r_input <= { r_input[29:0], i_miso };
				o_word  <= { r_input[30:0], i_miso };
			end else if (o_mod[1])
			begin
				r_input <= { r_input[26:0], i_dat };
				o_word  <= { r_input[27:0], i_dat };
			end
		end else if (state == `QSPI_HOLDING)
		begin
			// We need this state so that the o_valid signal
			// can get strobed with our last result.  Otherwise
			// we could just sit in READY waiting for a new command.
			//
			// Incidentally, the change producing this state was
			// the result of a nasty race condition.  See the
			// commends in wbqspiflash for more details.
			//
			o_valid <= 1'b0;
			o_cs_n <= 1'b0;
			o_busy <= 1'b0;
			r_spd <= i_spd;
			r_dir <= i_dir;
			if (i_spd)
			begin
				r_word <= { i_word[27:0], 4'h0 };
				spi_len<= { 1'b0, i_len, 3'b100 };
			end else begin
				r_word <= { i_word[30:0], 1'b0 };
				spi_len<= { 1'b0, i_len, 3'b111 };
			end
			if((!o_busy)&&(i_wr))// Acknowledge a new request
			begin
				state  <= `QSPI_BITS;
				o_busy <= 1'b1;
				o_sck  <= 1'b0;

				// Read the new request off the bus
				// Set up the first bits on the bus
				o_mod<=(i_spd)?{ 1'b1, i_dir } : `QSPI_MOD_SPI;
				if (i_spd)
					o_dat <= i_word[31:28];
				else
					o_dat <= { 3'b110, i_word[31] };
			end else begin
				o_sck <= 1'b1;
				state <= (i_hold)?`QSPI_HOLDING : `QSPI_STOP;
				o_busy <= (!i_hold);
			end
		end else if (state == `QSPI_STOP)
		begin
			o_sck   <= 1'b1; // Stop the clock
			o_valid <= 1'b0; // Output may have just been valid, but no more
			o_busy  <= 1'b1; // Still busy till port is clear
			state <= `QSPI_STOP_B;
			o_mod <= `QSPI_MOD_SPI;
		end else if (state == `QSPI_STOP_B)
		begin
			o_cs_n <= 1'b1;
			o_sck <= 1'b1;
			// Do I need this????
			// spi_len <= 3; // Minimum CS high time before next cmd
			state <= `QSPI_IDLE;
			o_valid <= 1'b0;
			o_busy <= 1'b1;
			o_mod <= `QSPI_MOD_SPI;
		end else begin // Invalid states, should never get here
			state   <= `QSPI_STOP;
			o_valid <= 1'b0;
			o_busy  <= 1'b1;
			o_cs_n  <= 1'b1;
			o_sck   <= 1'b1;
			o_mod   <= `QSPI_MOD_SPI;
			o_dat   <= 4'hd;
		end

`ifdef	FORMAL
	reg	prev_i_clk, past_valid;

	initial	`ASSUME(i_clk == 1'b0);
	initial	prev_i_clk  = 1;
	always @($global_clock)
	begin
		prev_i_clk  <= i_clk;
		`ASSUME(i_clk != prev_i_clk);
	end

	reg	past_valid;
	initial	past_valid = 1'b0;
	always @(posedge i_clk)
		past_valid <= 1'b1;

	/*
	always @(*)
		if (!$stable(i_spd))
			assert($rose(i_clk));
	*/

	always @(posedge i_clk) begin
		if ((past_valid)&&($past(i_wr))&&($past(o_busy)))
		begin
			// any time i_wr and o_busy are true, nothing changes
			// of spd, len, word or dir
			`ASSUME(i_wr);
			`ASSUME(i_spd  == $past(i_spd));
			`ASSUME(i_len  == $past(i_len));
			`ASSUME(i_word == $past(i_word));
			`ASSUME(i_dir  == $past(i_dir));
			`ASSUME(i_hold == $past(i_hold));
		end
		if ((past_valid)&&($past(i_wr))&&($past(o_busy))&&($past(state == `QSPI_IDLE)))
			assert($past(state)==state);
		if (i_hold == $past(i_hold))
			assert($stable(i_hold));
	end

	always @(*) begin
		if (o_mod == `QSPI_MOD_QOUT)
			`ASSUME(i_dat == o_dat);
		if (o_mod == `QSPI_MOD_SPI)
			`ASSUME(i_dat[3:2] == 2'b11);
		if (o_mod == `QSPI_MOD_SPI)
			`ASSUME(i_dat[0] == o_dat[0]);
	end

	initial	`ASSUME(i_wr == 1'b0);
	initial	`ASSUME(i_word == 0);

	always @($global_clock)
	if (!$rose(i_clk))
	begin
		`ASSUME($stable(i_wr));
		//
		`ASSUME($stable(i_len));
		`ASSUME($stable(i_dir));
		`ASSUME($stable(i_spd));
		`ASSUME($stable(i_word));
		//
		`ASSUME($stable(i_hold));
	end

	always @($global_clock)
	if (!$fell(o_sck))
		assume($stable(i_dat));

	// This is ... not as believable.  There might be a delay here.
	// For now, we'll just assume (not necessarily true) that the
	// output
	always @(posedge i_clk)
		if (past_valid)
		`ASSUME( (i_dat == $past(i_dat)) || (o_sck != $past(o_sck)) );

	reg	f_last_sck;
	always @(posedge i_clk)
		f_last_sck <= o_sck;

	reg	[31:0]	f_shiftreg, f_goal;
	initial	f_shiftreg = 0;
	initial	f_goal = 0;
	always @(posedge i_clk)
		if ((o_sck)&&(!f_last_sck))
		begin
			if (o_mod == `QSPI_MOD_QOUT)
				f_shiftreg <= { f_shiftreg[28:0], o_dat };
			else if (o_mod == `QSPI_MOD_SPI)
				f_shiftreg <= { f_shiftreg[30:0], o_dat[0] };
		end

	reg	[5:0]	f_nsent, f_vsent;
	reg	[2:0]	f_nbits_r;
	wire	[5:0]	f_nbits;
	always @(posedge i_clk)
		if ((i_wr)&&(!o_busy))
		begin
			f_goal <= i_word;
			f_nbits_r <= { 1'b0, i_len } + 3'h1;
		end
	assign	f_nbits = { f_nbits_r, 3'b000 };
	always @(posedge i_clk)
		if ((!o_sck)||(!o_cs_n))
			assert(f_nbits != 0);

	always @(posedge i_clk)
		if (o_cs_n)
			f_nsent <= 0;
		else if ((!o_busy)&&(i_wr))
			f_nsent <= 0;
		else if ((!f_last_sck)&&(o_sck))
		begin
			if (o_mod == `QSPI_MOD_SPI)
				f_nsent <= f_nsent + 6'h1;
			else
				f_nsent <= f_nsent + 6'h4;
		end
	always @(posedge i_clk)
		if (o_cs_n)
			f_vsent <= 0;
		else
			f_vsent <= f_nsent;
	always @(posedge i_clk)
		if ((!o_cs_n)&&(state == `QSPI_BITS)&&(!o_sck))
		begin
			if (o_mod != `QSPI_MOD_SPI)
				assert(f_nsent + spi_len + 6'h4 == f_nbits);
			else
				assert(f_nsent + spi_len + 6'h1 == f_nbits);
		end

	always @(posedge i_clk)
		assert((o_busy)||(f_goal[(f_nbits-1):0] == f_shiftreg[(f_nbits-1):0]));

	always @(posedge i_clk) begin
		// We are only ever in one of three speed modes, fourth mode
		// isn't allowed
		assert(	(o_mod == `QSPI_MOD_SPI)
			||(o_mod == `QSPI_MOD_QIN)
			||(o_mod == `QSPI_MOD_QOUT));

		if ((past_valid)&&($past(i_wr))&&(!$past(o_busy)))
		begin
			// Any accepted request leaves us in an active state
			assert(!o_cs_n);

			// Any accepted request allows us to set our speed
			assert(r_spd == $past(i_spd));
		end

		// We're either busy, or idle with the clock high
		//   or pausing (upon a request) mid-transaction
		assert((o_busy)
			||((state == `QSPI_IDLE)&&(o_sck)&&(o_cs_n))
			||((state == `QSPI_READY)&&(o_sck)&&(!o_cs_n))
			||((state == `QSPI_HOLDING)&&(o_sck)&&(!o_cs_n))
			);

		// Anytime CS is idle, SCK is high
		if (o_cs_n)
			assert(o_sck);


		// What can we assert about i_hold?

		// When i_hold is asserted before a transaction completes,
		// the transaction will "hold" and wait for a next input.
		// i.e. the clock will stop

		// First assert that o_busy will be deasserted any time the
		// currently requested word has been sent
		//
		//if ((($past(i_wr))||(i_hold))
		//		&&(f_nsent == f_nbits)&&(!o_sck)&&(!o_cs_n))
		//	assert(!o_busy);


		// First, assert of i_hold that !o_busy will be set.
		if ((past_valid)&&($past(i_hold))&&(f_nsent == f_nbits)&&(!o_cs_n))
		begin
			assert((!o_busy)||(o_sck));
		end
		if ((past_valid)&&($past(i_hold))&&(!$past(i_wr))
			&&(!$past(o_busy))&&(!$past(o_cs_n)))
		begin
			assert(!o_cs_n);
			assert($past(o_sck)==o_sck);
		end

		// DATA only changes on the falling edge of SCK
		if ((past_valid)&&(o_sck))
			assert(o_dat==$past(o_dat));

		// Valid is only ever true for one clock
		if ((past_valid)&&(o_valid))
			assert(!$past(o_valid));

		// Valid is only ever true after receiving a full number of bits
		if ((past_valid)&&(o_valid))
		begin
			if ((!$past(i_wr))||($past(o_busy)))
				assert(f_nsent == f_nbits);
		end

		// In SPI mode, the top bits of o_dat are always 3'b110
		//
		// This should be true, but there's a problem holding this
		// true
		// assert( (o_mod != `QSPI_MOD_SPI)||(o_dat[3:1] == 3'b110) );

		// Either valid is true (this clock), or our output word is
		// identical to what it was on the last clock
		if (past_valid)
			assert((o_valid) || (o_word == $past(o_word)));
	end
`endif

endmodule