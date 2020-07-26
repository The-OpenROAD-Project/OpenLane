// Copyright (c) 2012-2013 Ludvig Strigeus
// This program is GPL Licensed. See COPYING for the full license.

// Module handles updating the loopy scroll register
module LoopyGen(input clk, input ce,
                input is_rendering,
                input [2:0] ain,   // input address from CPU
                input [7:0] din,   // data input
                input read,        // read
                input write,       // write
                input is_pre_render, // Is this the pre-render scanline
                input [8:0] cycle,
                output [14:0] loopy,
                output [2:0] fine_x_scroll);  // Current loopy value
  // Controls how much to increment on each write
  reg ppu_incr; // 0 = 1, 1 = 32
  // Current VRAM address
  reg [14:0] loopy_v;
  // Temporary VRAM address
  reg [14:0] loopy_t;
  // Fine X scroll (3 bits)
  reg [2:0] loopy_x;
  // Latch
  reg ppu_address_latch;
  initial begin
    ppu_incr = 0;
    loopy_v = 0;
    loopy_t = 0;
    loopy_x = 0;
    ppu_address_latch = 0;  
  end
  // Handle updating loopy_t and loopy_v
  always @(posedge clk) if (ce) begin
    if (is_rendering) begin
      // Increment course X scroll right after attribute table byte was fetched.
      if (cycle[2:0] == 3 && (cycle < 256 || cycle >= 320 && cycle < 336)) begin
        loopy_v[4:0] <= loopy_v[4:0] + 1;
        loopy_v[10] <= loopy_v[10] ^ (loopy_v[4:0] == 31);
      end

      // Vertical Increment  
      if (cycle == 251) begin
        loopy_v[14:12] <= loopy_v[14:12] + 1;
        if (loopy_v[14:12] == 7) begin
          if (loopy_v[9:5] == 29) begin
            loopy_v[9:5] <= 0;
            loopy_v[11] <= !loopy_v[11];
          end else begin
            loopy_v[9:5] <= loopy_v[9:5] + 1;
          end
        end
      end
      
      // Horizontal Reset at cycle 257
      if (cycle == 256)
        {loopy_v[10], loopy_v[4:0]} <= {loopy_t[10], loopy_t[4:0]};
  
      // On cycle 256 of each scanline, copy horizontal bits from loopy_t into loopy_v
      // On cycle 304 of the pre-render scanline, copy loopy_t into loopy_v
      if (cycle == 304 && is_pre_render) begin
        loopy_v <= loopy_t;
      end
    end
    if (write && ain == 0) begin
      loopy_t[10] <= din[0];
      loopy_t[11] <= din[1];
      ppu_incr <= din[2];
    end else if (write && ain == 5) begin
      if (!ppu_address_latch) begin
        loopy_t[4:0] <= din[7:3];
        loopy_x <= din[2:0];
      end else begin
        loopy_t[9:5] <= din[7:3];
        loopy_t[14:12] <= din[2:0];
      end
      ppu_address_latch <= !ppu_address_latch;
    end else if (write && ain == 6) begin
      if (!ppu_address_latch) begin
        loopy_t[13:8] <= din[5:0];
        loopy_t[14] <= 0;
      end else begin
        loopy_t[7:0] <= din;
        loopy_v <= {loopy_t[14:8], din};
      end
      ppu_address_latch <= !ppu_address_latch;
    end else if (read && ain == 2) begin
      ppu_address_latch <= 0; //Reset PPU address latch
    end else if ((read || write) && ain == 7 && !is_rendering) begin
      // Increment address every time we accessed a reg
      loopy_v <= loopy_v + (ppu_incr ? 32 : 1);
    end
  end
  assign loopy = loopy_v;
  assign fine_x_scroll = loopy_x;
endmodule
  
  
// Generates the current scanline / cycle counters
module ClockGen(input clk, input ce, input reset,
                input is_rendering,
                output reg [8:0] scanline,
                output reg [8:0] cycle,
                output reg is_in_vblank,
                output end_of_line,
                output at_last_cycle_group,
                output exiting_vblank,
                output entering_vblank,
                output reg is_pre_render);
  reg second_frame;
  
  // Scanline 0..239 = picture scan lines
  // Scanline 240 = dummy scan line
  // Scanline 241..260 = VBLANK
  // Scanline -1 = Pre render scanline (Fetches objects for next line)
  assign at_last_cycle_group = (cycle[8:3] == 42);
  // Every second pre-render frame is only 340 cycles instead of 341.
  assign end_of_line = at_last_cycle_group && cycle[3:0] == (is_pre_render && second_frame && is_rendering ? 3 : 4);
  // Set the clock right before vblank begins
  assign entering_vblank = end_of_line && scanline == 240;
  // Set the clock right before vblank ends
  assign exiting_vblank = end_of_line && scanline == 260;
  // New value for is_in_vblank flag
  wire new_is_in_vblank = entering_vblank ? 1'b1 : exiting_vblank ? 1'b0 : is_in_vblank;
  // Set if the current line is line 0..239
  always @(posedge clk) if (reset) begin
    cycle <= 0;
    is_in_vblank <= 1;
  end else if (ce) begin
    cycle <= end_of_line ? 0 : cycle + 1;
    is_in_vblank <= new_is_in_vblank;
  end
//  always @(posedge clk) if (ce) begin
//    $write("%x %x %x %x %x\n", new_is_in_vblank, entering_vblank, exiting_vblank, is_in_vblank, entering_vblank ? 1'b1 : exiting_vblank ? 1'b0 : is_in_vblank);
    
//  end
  always @(posedge clk) if (reset) begin
    scanline <= 0;
    is_pre_render <= 0;
    second_frame <= 0;
  end else if (ce && end_of_line) begin
    // Once the scanline counter reaches end of 260, it gets reset to -1.
    scanline <= exiting_vblank ? 9'b111111111 : scanline + 1;
    // The pre render flag is set while we're on scanline -1.
    is_pre_render <= exiting_vblank;
    
    if (exiting_vblank)
      second_frame <= !second_frame;
  end
  
endmodule // ClockGen

// 8 of these exist, they are used to output sprites.
module Sprite(input clk, input ce,
              input enable,
              input [3:0] load, 
              input [26:0] load_in,
              output [26:0] load_out,
              output [4:0] bits); // Low 4 bits = pixel, high bit = prio
  reg [1:0] upper_color; // Upper 2 bits of color
  reg [7:0] x_coord;     // X coordinate where we want things
  reg [7:0] pix1, pix2;  // Shift registers, output when x_coord == 0
  reg aprio;             // Current prio
  wire active = (x_coord == 0);
  always @(posedge clk) if (ce) begin
    if (enable) begin
      if (!active) begin
        // Decrease until x_coord is zero.
        x_coord <= x_coord - 8'h01;
      end else begin
        pix1 <= pix1 >> 1;
        pix2 <= pix2 >> 1;
      end
    end
    if (load[3]) pix1 <= load_in[26:19];
    if (load[2]) pix2 <= load_in[18:11];
    if (load[1]) x_coord <= load_in[10:3];
    if (load[0]) {upper_color, aprio} <= load_in[2:0];
  end
  assign bits = {aprio, upper_color, active && pix2[0], active && pix1[0]};
  assign load_out = {pix1, pix2, x_coord, upper_color, aprio};
endmodule  // SpriteGen
					
// This contains all 8 sprites. Will return the pixel value of the highest prioritized sprite.
// When load is set, and clocked, load_in is loaded into sprite 7 and all others are shifted down.
// Sprite 0 has highest prio.
// 226 LUTs, 68 Slices
module SpriteSet(input clk, input ce,   // Input clock
                 input enable,          // Enable pixel generation
                 input [3:0] load,      // Which parts of the state to load/shift.
                 input [26:0] load_in,  // State to load with 
                 output [4:0] bits,     // Output bits
                 output is_sprite0);    // Set to true if sprite #0 was output

  wire [26:0] load_out7, load_out6, load_out5, load_out4, load_out3, load_out2, load_out1, load_out0; 
  wire [4:0] bits7, bits6, bits5, bits4, bits3, bits2, bits1, bits0;
  Sprite sprite7(clk, ce, enable, load, load_in,   load_out7, bits7);
  Sprite sprite6(clk, ce, enable, load, load_out7, load_out6, bits6);
  Sprite sprite5(clk, ce, enable, load, load_out6, load_out5, bits5);
  Sprite sprite4(clk, ce, enable, load, load_out5, load_out4, bits4);
  Sprite sprite3(clk, ce, enable, load, load_out4, load_out3, bits3);
  Sprite sprite2(clk, ce, enable, load, load_out3, load_out2, bits2);
  Sprite sprite1(clk, ce, enable, load, load_out2, load_out1, bits1);
  Sprite sprite0(clk, ce, enable, load, load_out1, load_out0, bits0);          
  // Determine which sprite is visible on this pixel.
  assign bits = bits0[1:0] != 0 ? bits0 : 
                bits1[1:0] != 0 ? bits1 : 
                bits2[1:0] != 0 ? bits2 : 
                bits3[1:0] != 0 ? bits3 : 
                bits4[1:0] != 0 ? bits4 : 
                bits5[1:0] != 0 ? bits5 : 
                bits6[1:0] != 0 ? bits6 : 
                                  bits7;
  assign is_sprite0 = bits0[1:0] != 0;                             
endmodule  // SpriteSet

module SpriteRAM(input clk, input ce,
                 input reset_line,          // OAM evaluator needs to be reset before processing is started.
                 input sprites_enabled,     // Set to 1 if evaluations are enabled
                 input exiting_vblank,      // Set to 1 when exiting vblank so spr_overflow can be reset
                 input obj_size,            // Set to 1 if objects are 16 pixels.
                 input [8:0] scanline,      // Current scan line (compared against Y)
                 input [8:0] cycle,         // Current cycle.
                 output reg [7:0] oam_bus,  // Current value on the OAM bus, returned to NES through $2004.
                 input oam_ptr_load,        // Load oam with specified value, when writing to NES $2003.
                 input oam_load,            // Load oam_ptr with specified value, when writing to NES $2004.
                 input [7:0] data_in,       // New value for oam or oam_ptr
                 output reg spr_overflow,   // Set to true if we had more than 8 objects on a scan line. Reset when exiting vblank.
                 output reg sprite0);       // True if sprite#0 is included on the scan line currently being painted.
  reg [7:0] sprtemp[0:31];   // Sprite Temporary Memory. 32 bytes.
  reg [7:0] oam[0:255];      // Sprite OAM. 256 bytes.
  reg [7:0] oam_ptr;         // Pointer into oam_ptr.
  reg [2:0] p;               // Upper 3 bits of pointer into temp, the lower bits are oam_ptr[1:0].
  reg [1:0] state;           // Current state machine state
  wire [7:0] oam_data = oam[oam_ptr];
  // Compute the current address we read/write in sprtemp.
  reg [4:0] sprtemp_ptr;
  // Check if the current Y coordinate is inside.
  wire [8:0] spr_y_coord = scanline - {1'b0, oam_data};
  wire spr_is_inside = (spr_y_coord[8:4] == 0) && (obj_size || spr_y_coord[3] == 0);
  reg [7:0] new_oam_ptr;     // [wire] New value for oam ptr
  reg [1:0] oam_inc;         // [wire] How much to increment oam ptr
  reg sprite0_curr;          // If sprite0 is included on the line being processed.
  reg oam_wrapped;           // [wire] if new_oam or new_p wrapped.
  
  wire [7:0] sprtemp_data = sprtemp[sprtemp_ptr];
  always @*  begin
    // Compute address to read/write in temp sprite ram
    case({cycle[8], cycle[2]}) 
    2'b0_?: sprtemp_ptr = {p, oam_ptr[1:0]};
    2'b1_0: sprtemp_ptr = {cycle[5:3], cycle[1:0]}; // 1-4. Read Y, Tile, Attribs
    2'b1_1: sprtemp_ptr = {cycle[5:3], 2'b11};      // 5-8. Keep reading X.
    endcase
  end
    
  always @* begin
    /* verilator lint_off CASEOVERLAP */
    // Compute value to return to cpu through $2004. And also the value that gets written to temp sprite ram.
    case({sprites_enabled, cycle[8], cycle[6], state, oam_ptr[1:0]})
    7'b1_10_??_??: oam_bus = sprtemp_data;         // At cycle 256-319 we output what's in sprite temp ram
    7'b1_??_00_??: oam_bus = 8'b11111111;                  // On the first 64 cycles (while inside state 0), we output 0xFF.
    7'b1_??_01_00: oam_bus = {4'b0000, spr_y_coord[3:0]};  // Y coord that will get written to temp ram.
    7'b?_??_??_10: oam_bus = {oam_data[7:5], 3'b000, oam_data[1:0]}; // Bits 2-4 of attrib are always zero when reading oam.
    default:       oam_bus = oam_data;                     // Default to outputting from oam.
    endcase
  end

  always @* begin
    // Compute incremented oam counters
    case ({oam_load, state, oam_ptr[1:0]})
    5'b1_??_??: oam_inc = {oam_ptr[1:0] == 3, 1'b1};       // Always increment by 1 when writing to oam.
    5'b0_00_??: oam_inc = 2'b01;                           // State 0: On the the first 64 cycles we fill temp ram with 0xFF, increment low bits.
    5'b0_01_00: oam_inc = {!spr_is_inside, spr_is_inside}; // State 1: Copy Y coordinate and increment oam by 1 if it's inside, otherwise 4.
    5'b0_01_??: oam_inc = {oam_ptr[1:0] == 3, 1'b1};       // State 1: Copy remaining 3 bytes of the oam.
    // State 3: We've had more than 8 sprites. Set overflow flag if we found a sprite that overflowed.
    // NES BUG: It increments both low and high counters.
    5'b0_11_??: oam_inc = 2'b11;
    // While in the final state, keep incrementing the low bits only until they're zero.
    5'b0_10_??: oam_inc = {1'b0, oam_ptr[1:0] != 0};
    endcase
    /* verilator lint_on CASEOVERLAP */
    new_oam_ptr[1:0] = oam_ptr[1:0] + {1'b0, oam_inc[0]};
    {oam_wrapped, new_oam_ptr[7:2]} = {1'b0, oam_ptr[7:2]} + {6'b0, oam_inc[1]};
  end
  always @(posedge clk) if (ce) begin
     
    // Some bits of the OAM are hardwired to zero.
    if (oam_load)
      oam[oam_ptr] <= (oam_ptr & 3) == 2 ? data_in & 8'hE3: data_in;
    if (cycle[0] && sprites_enabled || oam_load || oam_ptr_load) begin
      oam_ptr <= oam_ptr_load ? data_in : new_oam_ptr;
    end
    // Set overflow flag?
    if (sprites_enabled && state == 2'b11 && spr_is_inside)
      spr_overflow <= 1;
    // Remember if sprite0 is included on the scanline, needed for hit test later.
    sprite0_curr <= (state == 2'b01 && oam_ptr[7:2] == 0 && spr_is_inside || sprite0_curr);
    
//    if (scanline == 0 && cycle[0] && (state == 2'b01 || state == 2'b00))
//      $write("Drawing sprite %d/%d. bus=%d oam_ptr=%X->%X oam_data=%X p=%d (%d %d %d)\n", scanline, cycle, oam_bus, oam_ptr, new_oam_ptr, oam_data, p,
//         cycle[0] && sprites_enabled, oam_load, oam_ptr_load);
    
    // Always writing to temp ram while we're in state 0 or 1.
    if (!state[1]) sprtemp[sprtemp_ptr] <= oam_bus;
    // Update state machine on every second cycle.
    if (cycle[0]) begin
      // Increment p whenever oam_ptr carries in state 0 or 1.
      if (!state[1] && oam_ptr[1:0] == 2'b11) p <= p + 1;
      // Set sprite0 if sprite1 was included on the scan line
      case({state, (p == 7) && (oam_ptr[1:0] == 2'b11), oam_wrapped})
      4'b00_0_?: state <= 2'b00;  // State #0: Keep filling
      4'b00_1_?: state <= 2'b01;  // State #0: Until we filled 64 items.
      4'b01_?_1: state <= 2'b10;  // State #1: Goto State 2 if processed all OAM
      4'b01_1_0: state <= 2'b11;  // State #1: Goto State 3 if we found 8 sprites
      4'b01_0_0: state <= 2'b01;  // State #1: Keep comparing Y coordinates.
      4'b11_?_1: state <= 2'b10;  // State #3: Goto State 2 if processed all OAM
      4'b11_?_0: state <= 2'b11;  // State #3: Keep comparing Y coordinates
      4'b10_?_?: state <= 2'b10;  // Stuck in state 2.
      endcase
    end
    if (reset_line) begin
      state <= 0;
      p <= 0;
      oam_ptr <= 0;
      sprite0_curr <= 0;
      sprite0 <= sprite0_curr;
    end
    if (exiting_vblank)
      spr_overflow <= 0;
  end
endmodule  // SpriteRAM


// Generates addresses in VRAM where we'll fetch sprite graphics from,
// and populates load, load_in so the SpriteGen can be loaded.
// 10 LUT, 4 Slices
module SpriteAddressGen(input clk, input ce,
                        input enabled,          // If unset, |load| will be all zeros.
                        input obj_size,         // 0: Sprite Height 8, 1: Sprite Height 16.
                        input obj_patt,         // Object pattern table selection
                        input [2:0] cycle,      // Current load cycle. At #4, first bitmap byte is loaded. At #6, second bitmap byte is.
                        input [7:0] temp,       // Input temp data from SpriteTemp. #0 = Y Coord, #1 = Tile, #2 = Attribs, #3 = X Coord
                        output [12:0] vram_addr,// Low bits of address in VRAM that we'd like to read.
                        input [7:0] vram_data,  // Byte of VRAM in the specified address
                        output [3:0] load,      // Which subset of load_in that is now valid, will be loaded into SpritesGen.
                        output [26:0] load_in); // Bits to load into SpritesGen.
  reg [7:0] temp_tile;    // Holds the tile that we will get
  reg [3:0] temp_y;       // Holds the Y coord (will be swapped based on FlipY).
  reg flip_x, flip_y;     // If incoming bitmap data needs to be flipped in the X or Y direction.
  wire load_y =    (cycle == 0);
  wire load_tile = (cycle == 1);
  wire load_attr = (cycle == 2) && enabled;
  wire load_x =    (cycle == 3) && enabled;
  wire load_pix1 = (cycle == 5) && enabled;
  wire load_pix2 = (cycle == 7) && enabled;
  reg dummy_sprite; // Set if attrib indicates the sprite is invalid.
  // Flip incoming vram data based on flipx. Zero out the sprite if it's invalid. The bits are already flipped once.
  wire [7:0] vram_f = dummy_sprite ? 0 : 
                      !flip_x ?      {vram_data[0], vram_data[1], vram_data[2], vram_data[3], vram_data[4], vram_data[5], vram_data[6], vram_data[7]} : 
                                     vram_data;
  wire [3:0] y_f = temp_y ^ {flip_y, flip_y, flip_y, flip_y};
  assign load = {load_pix1, load_pix2, load_x, load_attr};
  assign load_in = {vram_f, vram_f, temp, temp[1:0], temp[5]};
  // If $2000.5 = 0, the tile index data is used as usual, and $2000.3 
  // selects the pattern table to use. If $2000.5 = 1, the MSB of the range 
  // result value become the LSB of the indexed tile, and the LSB of the tile 
  // index value determines pattern table selection. The lower 3 bits of the 
  // range result value are always used as the fine vertical offset into the 
  // selected pattern.
  assign vram_addr = {obj_size ? temp_tile[0] : obj_patt, 
                      temp_tile[7:1], obj_size ? y_f[3] : temp_tile[0], cycle[1], y_f[2:0] };
  always @(posedge clk) if (ce) begin
    if (load_y) temp_y <= temp[3:0];
    if (load_tile) temp_tile <= temp;
    if (load_attr) {flip_y, flip_x, dummy_sprite} <= {temp[7:6], temp[4]};
  end
//  always @(posedge clk) begin
//    if (load[3]) $write("Loading pix1: %x\n", load_in[26:19]);
//    if (load[2]) $write("Loading pix2: %x\n", load_in[18:11]);
//    if (load[1]) $write("Loading x: %x\n", load_in[10:3]);
//
//    if (valid_sprite && enabled)
//      $write("%d. Found %d. Flip:%d%d, Addr: %x, Vram: %x!\n", cycle, temp, flip_x, flip_y, vram_addr, vram_data);
//  end

endmodule  // SpriteAddressGen

module BgPainter(input clk, input ce,
                 input enable,             // Shift registers activated
                 input [2:0] cycle,
                 input [2:0] fine_x_scroll,
                 input [14:0] loopy,
                 output [7:0] name_table,  // VRAM name table to read next.
                 input [7:0] vram_data,
                 output [3:0] pixel);
  reg [15:0] playfield_pipe_1; // Name table pixel pipeline #1
  reg [15:0] playfield_pipe_2; // Name table pixel pipeline #2
  reg [8:0]  playfield_pipe_3; // Attribute table pixel pipe #1
  reg [8:0]  playfield_pipe_4; // Attribute table pixel pipe #2
  reg [7:0] current_name_table;      // Holds the current name table byte
  reg [1:0] current_attribute_table; // Holds the 2 current attribute table bits
  reg [7:0] bg0;                // Pixel data for last loaded background
  wire [7:0] bg1 =  vram_data;
  initial begin
    playfield_pipe_1 = 0;
    playfield_pipe_2 = 0;
    playfield_pipe_3 = 0;
    playfield_pipe_4 = 0;
    current_name_table = 0;
    current_attribute_table = 0;
    bg0 = 0;
  end
  always @(posedge clk) if (ce) begin
    case (cycle[2:0])
    1: current_name_table <= vram_data;
    3: current_attribute_table <= (!loopy[1] && !loopy[6]) ? vram_data[1:0] : 
                                  ( loopy[1] && !loopy[6]) ? vram_data[3:2] :
                                  (!loopy[1] &&  loopy[6]) ? vram_data[5:4] : 
                                                             vram_data[7:6];
    5: bg0 <= vram_data; // Pattern table bitmap #0
//    7: bg1 <= vram_data; // Pattern table bitmap #1
    endcase
    if (enable) begin
      playfield_pipe_1[14:0] <= playfield_pipe_1[15:1];
      playfield_pipe_2[14:0] <= playfield_pipe_2[15:1];
      playfield_pipe_3[7:0] <= playfield_pipe_3[8:1];
      playfield_pipe_4[7:0] <= playfield_pipe_4[8:1];
      // Load the new values into the shift registers at the last pixel.
      if (cycle[2:0] == 7) begin
        playfield_pipe_1[15:8] <= {bg0[0], bg0[1], bg0[2], bg0[3], bg0[4], bg0[5], bg0[6], bg0[7]};
        playfield_pipe_2[15:8] <= {bg1[0], bg1[1], bg1[2], bg1[3], bg1[4], bg1[5], bg1[6], bg1[7]};
        playfield_pipe_3[8] <= current_attribute_table[0];
        playfield_pipe_4[8] <= current_attribute_table[1];
      end
    end
  end
  assign name_table = current_name_table;
  wire [3:0] i = {1'b0, fine_x_scroll};
  assign pixel = {playfield_pipe_4[i], playfield_pipe_3[i],
                  playfield_pipe_2[i], playfield_pipe_1[i]};
endmodule  // BgPainter
 
module PixelMuxer(input [3:0] bg, input [3:0] obj, input obj_prio, output [3:0] out, output is_obj);
  wire bg_flag = bg[0] | bg[1];
  wire obj_flag = obj[0] | obj[1];
  assign is_obj = !(obj_prio && bg_flag) && obj_flag;
  assign out = is_obj ? obj : bg;
endmodule
 

module PaletteRam(input clk, input ce, input [4:0] addr, input [5:0] din, output [5:0] dout, input write);
  reg [5:0] palette [0:31];
  initial begin
     //$readmemh("oam_palette.txt", palette);
  end
  // Force read from backdrop channel if reading from any addr 0.
  wire [4:0] addr2 = (addr[1:0] == 0) ? 0 : addr;
  assign dout = palette[addr2];
  always @(posedge clk) if (ce && write) begin
    // Allow writing only to x0
    if (!(addr[3:2] != 0 && addr[1:0] == 0))
      palette[addr2] <= din;
  end
endmodule  // PaletteRam
 
module PPU(input clk, input ce, input reset,   // input clock  21.48 MHz / 4. 1 clock cycle = 1 pixel
           output [5:0] color, // output color value, one pixel outputted every clock
           input [7:0] din,   // input data from bus
           output [7:0] dout, // output data to CPU
           input [2:0] ain,   // input address from CPU
           input read,        // read
           input write,       // write
           output nmi,    // one while inside vblank
           output vram_r, // read from vram active
           output vram_w, // write to vram active
           output [13:0] vram_a, // vram address
           input [7:0] vram_din, // vram input
           output [7:0] vram_dout,
           output [8:0] scanline,
           output [8:0] cycle,
           output [19:0] mapper_ppu_flags);
  // These are stored in control register 0
  reg obj_patt; // Object pattern table
  reg bg_patt;  // Background pattern table
  reg obj_size; // 1 if sprites are 16 pixels high, else 0.
  reg vbl_enable;  // Enable VBL flag
  // These are stored in control register 1
  reg grayscale; // Disable color burst
  reg playfield_clip;     // 0: Left side 8 pixels playfield clipping
  reg object_clip;        // 0: Left side 8 pixels object clipping
  reg enable_playfield;   // Enable playfield display
  reg enable_objects;     // Enable objects display
  reg [2:0] color_intensity; // Color intensity
  
  initial begin
    obj_patt = 0;
    bg_patt = 0;
    obj_size = 0;
    vbl_enable = 0;
    grayscale = 0;
    playfield_clip = 0;
    object_clip = 0;
    enable_playfield = 0;
    enable_objects = 0;
    color_intensity = 0;
  end
  
  reg nmi_occured;         // True if NMI has occured but not cleared.
  reg [7:0] vram_latch;
  // Clock generator
  wire is_in_vblank;        // True if we're in VBLANK
  //wire [8:0] scanline;      // Current scanline
  //wire [8:0] cycle;         // Current cycle inside of the line
  wire end_of_line;         // At the last pixel of a line
  wire at_last_cycle_group; // At the very last cycle group of the scan line.
  wire exiting_vblank;      // At the very last cycle of the vblank
  wire entering_vblank;     // 
  wire is_pre_render_line;  // True while we're on the pre render scanline
  wire is_rendering = (enable_playfield || enable_objects) && !is_in_vblank && scanline != 240;
  
  ClockGen clock(clk, ce, reset, is_rendering, scanline, cycle, is_in_vblank, end_of_line, at_last_cycle_group,
                 exiting_vblank, entering_vblank, is_pre_render_line);
  
  
  // The loopy module handles updating of the loopy address
  wire [14:0] loopy;
  wire [2:0] fine_x_scroll;
  LoopyGen loopy0(clk, ce, is_rendering, ain, din, read, write, is_pre_render_line, cycle, loopy, fine_x_scroll);
  // Set to true if the current ppu_addr pointer points into
  // palette ram.
  wire is_pal_address = (loopy[13:8] == 6'b111111);

  // Paints background
  wire [7:0] bg_name_table;
  wire [3:0] bg_pixel_noblank;
  BgPainter bg_painter(clk, ce, !at_last_cycle_group, cycle[2:0], fine_x_scroll, loopy, bg_name_table, vram_din, bg_pixel_noblank);
  
  // Blank out BG in the leftmost 8 pixels?
  wire show_bg_on_pixel = (playfield_clip || (cycle[7:3] != 0)) && enable_playfield;
  wire [3:0] bg_pixel = {bg_pixel_noblank[3:2], show_bg_on_pixel ? bg_pixel_noblank[1:0] : 2'b00};

  // This will set oam_ptr to 0 right before the scanline 240 and keep it there throughout vblank.
  wire before_line = (enable_playfield || enable_objects) && (exiting_vblank || end_of_line && !is_in_vblank);
  wire [7:0] oam_bus;
  wire sprite_overflow;
  wire obj0_on_line;                        // True if sprite#0 is included on the current line
  SpriteRAM sprite_ram(clk, ce,
                       before_line,         // Condition for resetting the sprite line state.
                       is_rendering,        // Condition for enabling sprite ram logic. Check so we're not on 
                       exiting_vblank,
                       obj_size,
                       scanline, cycle,
                       oam_bus,
                       write && (ain == 3), // Write to oam_ptr
                       write && (ain == 4), // Write to oam[oam_ptr]
                       din,
                       sprite_overflow,
                       obj0_on_line);
  wire [4:0] obj_pixel_noblank;
  wire [12:0] sprite_vram_addr;
  wire is_obj0_pixel;               // True if obj_pixel originates from sprite0.
  wire [3:0] spriteset_load;          // Which subset of the |load_in| to load into SpriteSet
  wire [26:0] spriteset_load_in;      // Bits to load into SpriteSet
  // Between 256..319 (64 cycles), fetches bitmap data for the 8 sprites and fills in the SpriteSet
  // so that it can start drawing on the next frame.
  SpriteAddressGen address_gen(clk, ce,
                               cycle[8] && !cycle[6],     // Load sprites between 256..319
                               obj_size, obj_patt,        // Object size and pattern table
                               cycle[2:0],                // Cycle counter
                               oam_bus,                   // Info from temp buffer.
                               sprite_vram_addr,          // [out] VRAM Address that we want data from
                               vram_din,                  // [in] Data at the specified address
                               spriteset_load,
                               spriteset_load_in);        // Which parts of SpriteGen to load
  // Between 0..255 (256 cycles), draws pixels.
  // Between 256..319 (64 cycles), will be populated for next line
  SpriteSet sprite_gen(clk, ce, !cycle[8], spriteset_load, spriteset_load_in, obj_pixel_noblank, is_obj0_pixel);
  // Blank out obj in the leftmost 8 pixels?    
  wire show_obj_on_pixel = (object_clip || (cycle[7:3] != 0)) && enable_objects;
  wire [4:0] obj_pixel = {obj_pixel_noblank[4:2], show_obj_on_pixel ? obj_pixel_noblank[1:0] : 2'b00};
  
  reg sprite0_hit_bg;            // True if sprite#0 has collided with the BG in the last frame.
  always @(posedge clk) if (ce) begin
    if (exiting_vblank)
      sprite0_hit_bg <= 0;
    else if (is_rendering &&         // Object rendering is enabled
             !cycle[8] &&            // X Pixel 0..255
             cycle[7:0] != 255 &&    // X pixel != 255
             !is_pre_render_line &&  // Y Pixel 0..239
             obj0_on_line &&         // True if sprite#0 is included on the scan line.
             is_obj0_pixel &&        // True if the pixel came from tempram #0.
             show_obj_on_pixel &&
             bg_pixel[1:0] != 0) begin // Background pixel nonzero.
      sprite0_hit_bg <= 1;
      
    end

//    if (!cycle[8] && is_visible_line && obj0_on_line && is_obj0_pixel)
//      $write("Sprite0 hit bg scan %d!!\n", scanline);

//    if (is_obj0_pixel)
//      $write("drawing obj0 pixel %d/%d\n", scanline, cycle);
  end
 
  wire [3:0] pixel;
  wire pixel_is_obj;
  PixelMuxer pixel_muxer(bg_pixel, obj_pixel[3:0], obj_pixel[4], pixel, pixel_is_obj);
 
  // Compute the value to put on the VRAM address bus
  assign vram_a = !is_rendering    ? loopy[13:0] : // VRAM
                  (cycle[2:1] == 0)     ? {2'b10, loopy[11:0]} : // Name table
                  (cycle[2:1] == 1)     ? {2'b10, loopy[11:10], 4'b1111, loopy[9:7], loopy[4:2]} : // Attribute table
                  cycle[8] && !cycle[6] ? {1'b0, sprite_vram_addr} : 
                                          {1'b0, bg_patt, bg_name_table, cycle[1], loopy[14:12]}; // Pattern table bitmap #0, #1
  // Read from VRAM, either when user requested a manual read, or when we're generating pixels.
  assign vram_r = read && (ain == 7) ||
                  is_rendering && cycle[0] == 0 && !end_of_line;
  
  // Write to VRAM?
  assign vram_w = write && (ain == 7) && !is_pal_address && !is_rendering;

  wire [5:0] color2;
  PaletteRam palette_ram(clk, ce, 
                         is_rendering ? {pixel_is_obj, pixel[3:0]} : (is_pal_address ? loopy[4:0] : 5'b0000), // Read addr
                         din[5:0], // Value to write
                         color2,    // Output color
                         write && (ain == 7) && is_pal_address); // Condition for writing
  assign color = grayscale ? {color2[5:4], 4'b0} : color2;
//  always @(posedge clk)  
//  if (scanline == 194 && cycle < 8 && color == 15) begin
//    $write("Pixel black %x %x %x %x %x\n", bg_pixel,obj_pixel,pixel,pixel_is_obj,color);
//  end

 
  always @(posedge clk) if (ce) begin
//    if (!is_in_vblank && write)
//      $write("%d/%d: $200%d <= %x\n", scanline, cycle, ain, din);
    if (write) begin
      case (ain)
      0: begin // PPU Control Register 1
      // t:....BA.. ........ = d:......BA
        obj_patt <= din[3];
        bg_patt <= din[4];
        obj_size <= din[5];
        vbl_enable <= din[7];
        
        //$write("PPU Control #0 <= %X\n", din);
      end
      1: begin // PPU Control Register 2
        grayscale <= din[0];
        playfield_clip <= din[1];
        object_clip <= din[2];
        enable_playfield <= din[3];
        enable_objects <= din[4];
        color_intensity <= din[7:5];
        if (!din[3] && scanline == 59)
          $write("Disabling playfield at cycle %d\n", cycle);
      end
      endcase
    end
     
    // Reset frame specific counters upon exiting vblank
    if (exiting_vblank)
      nmi_occured <= 0;
    // Set the 
    if (entering_vblank)
      nmi_occured <= 1;
    // Reset NMI register when reading from Status
    if (read && ain == 2)
      nmi_occured <= 0;
  end
  
  // If we're triggering a VBLANK NMI 
  assign nmi = nmi_occured && vbl_enable;

  // One cycle after vram_r was asserted, the value
  // is available on the bus.
  reg vram_read_delayed;
  always @(posedge clk) if (ce) begin
    if (vram_read_delayed)
      vram_latch <= vram_din;
    vram_read_delayed = vram_r;
  end
  
  // Value currently being written to video ram
  assign vram_dout = din;

  reg [7:0] latched_dout;
  always @* begin
    case (ain)
    2: latched_dout = {nmi_occured,
               sprite0_hit_bg,
               sprite_overflow,
               5'b00000};
    4: latched_dout = oam_bus;
    default: if (is_pal_address) begin
        latched_dout = {2'b00, color};
      end else begin
        latched_dout = vram_latch;
      end 
    endcase
  end
  
  assign dout = latched_dout;
  
  
  assign mapper_ppu_flags = {scanline, cycle, obj_size, is_rendering};

endmodule  // PPU
