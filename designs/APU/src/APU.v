// Copyright (c) 2012-2013 Ludvig Strigeus
// This program is GPL Licensed. See COPYING for the full license.

module LenCtr_Lookup(input [4:0] X, output [7:0] Yout);
reg [6:0] Y;
always @*
begin
  case(X)
  0: Y = 7'h05;
  1: Y = 7'h7F;
  2: Y = 7'h0A;
  3: Y = 7'h01;
  4: Y = 7'h14;
  5: Y = 7'h02;
  6: Y = 7'h28;
  7: Y = 7'h03;
  8: Y = 7'h50;
  9: Y = 7'h04;
  10: Y = 7'h1E;
  11: Y = 7'h05;
  12: Y = 7'h07;
  13: Y = 7'h06;
  14: Y = 7'h0D;
  15: Y = 7'h07;
  16: Y = 7'h06;
  17: Y = 7'h08;
  18: Y = 7'h0C;
  19: Y = 7'h09;
  20: Y = 7'h18;
  21: Y = 7'h0A;
  22: Y = 7'h30;
  23: Y = 7'h0B;
  24: Y = 7'h60;
  25: Y = 7'h0C;
  26: Y = 7'h24;
  27: Y = 7'h0D;
  28: Y = 7'h08;
  29: Y = 7'h0E;
  30: Y = 7'h10;
  31: Y = 7'h0F;
  endcase
end
assign Yout = {Y, 1'b0};
endmodule

module SquareChan(input clk, input ce, input reset, input sq2,
                  input [1:0] Addr,
                  input [7:0] DIN,
                  input MW,
                  input LenCtr_Clock,
                  input Env_Clock,
                  input Enabled,
                  input [7:0] LenCtr_In,
                  output reg [3:0] Sample,
                  output IsNonZero);
reg [7:0] LenCtr;

// Register 1
reg [1:0] Duty;
reg EnvLoop, EnvDisable, EnvDoReset;
reg [3:0] Volume, Envelope, EnvDivider;
wire LenCtrHalt = EnvLoop; // Aliased bit
assign IsNonZero = (LenCtr != 0);
// Register 2
reg SweepEnable, SweepNegate, SweepReset;
reg [2:0] SweepPeriod, SweepDivider, SweepShift;

reg [10:0] Period;
reg [11:0] TimerCtr;
reg [2:0] SeqPos;
wire [10:0] ShiftedPeriod = (Period >> SweepShift);
wire [10:0] PeriodRhs = (SweepNegate ? (~ShiftedPeriod + {10'b0, sq2}) : ShiftedPeriod);
wire [11:0] NewSweepPeriod = Period + PeriodRhs;
wire ValidFreq = Period[10:3] >= 8 && (SweepNegate || !NewSweepPeriod[11]);

always @(posedge clk) if (reset) begin
    LenCtr <= 0;
    Duty <= 0;
    EnvDoReset <= 0;
    EnvLoop <= 0;
    EnvDisable <= 0;
    Volume <= 0;
    Envelope <= 0;
    EnvDivider <= 0;
    SweepEnable <= 0;
    SweepNegate <= 0;
    SweepReset <= 0;
    SweepPeriod <= 0;
    SweepDivider <= 0;
    SweepShift <= 0;
    Period <= 0;
    TimerCtr <= 0;
    SeqPos <= 0;
  end else if (ce) begin
  // Check if writing to the regs of this channel
  // NOTE: This needs to be done before the clocking below.
  if (MW) begin
    case(Addr)
    0: begin
//      if (sq2) $write("SQ0: Duty=%d, EnvLoop=%d, EnvDisable=%d, Volume=%d\n", DIN[7:6], DIN[5], DIN[4], DIN[3:0]);
      Duty <= DIN[7:6];
      EnvLoop <= DIN[5];
      EnvDisable <= DIN[4];
      Volume <= DIN[3:0];
    end
    1: begin
//      if (sq2) $write("SQ1: SweepEnable=%d, SweepPeriod=%d, SweepNegate=%d, SweepShift=%d, DIN=%X\n", DIN[7], DIN[6:4], DIN[3], DIN[2:0], DIN);
      SweepEnable <= DIN[7];
      SweepPeriod <= DIN[6:4];
      SweepNegate <= DIN[3];
      SweepShift <= DIN[2:0];
      SweepReset <= 1;
    end
    2: begin
//      if (sq2) $write("SQ2: Period=%d. DIN=%X\n", DIN, DIN);
      Period[7:0] <= DIN;
    end
    3: begin
      // Upper bits of the period
//      if (sq2) $write("SQ3: PeriodUpper=%d LenCtr=%x DIN=%X\n", DIN[2:0], LenCtr_In, DIN);
      Period[10:8] <= DIN[2:0];
      LenCtr <= LenCtr_In;
      EnvDoReset <= 1;
      SeqPos <= 0;
    end
    endcase
  end


  // Count down the square timer...
  if (TimerCtr == 0) begin
    // Timer was clocked
    TimerCtr <= {Period, 1'b0};
    SeqPos <= SeqPos - 1;
  end else begin
    TimerCtr <= TimerCtr - 1;
  end

  // Clock the length counter?
  if (LenCtr_Clock && LenCtr != 0 && !LenCtrHalt) begin
    LenCtr <= LenCtr - 1;
  end

  // Clock the sweep unit?
  if (LenCtr_Clock) begin
    if (SweepDivider == 0) begin
      SweepDivider <= SweepPeriod;
      if (SweepEnable && SweepShift != 0 && ValidFreq)
        Period <= NewSweepPeriod[10:0];
    end else begin
      SweepDivider <= SweepDivider - 1;
    end
    if (SweepReset)
      SweepDivider <= SweepPeriod;
    SweepReset <= 0;
  end

  // Clock the envelope generator?
  if (Env_Clock) begin
    if (EnvDoReset) begin
      EnvDivider <= Volume;
      Envelope <= 15;
      EnvDoReset <= 0;
    end else if (EnvDivider == 0) begin
      EnvDivider <= Volume;
      if (Envelope != 0 || EnvLoop)
        Envelope <= Envelope - 1;
    end else begin
      EnvDivider <= EnvDivider - 1;
    end
  end

  // Length counter forced to zero if disabled.
  if (!Enabled)
    LenCtr <= 0;
end

reg DutyEnabled;
always @* begin
  // Determine if the duty is enabled or not
  case (Duty)
  0: DutyEnabled = (SeqPos == 7);
  1: DutyEnabled = (SeqPos >= 6);
  2: DutyEnabled = (SeqPos >= 4);
  3: DutyEnabled = (SeqPos < 6);
  endcase

  // Compute the output
  if (LenCtr == 0 || !ValidFreq || !DutyEnabled)
    Sample = 0;
  else
    Sample = EnvDisable ? Volume : Envelope;
end
endmodule



module TriangleChan(input clk, input ce, input reset,
                    input [1:0] Addr,
                    input [7:0] DIN,
                    input MW,
                    input LenCtr_Clock,
                    input LinCtr_Clock,
                    input Enabled,
                    input [7:0] LenCtr_In,
                    output [3:0] Sample,
                    output IsNonZero);
  //
  reg [10:0] Period, TimerCtr;
  reg [4:0] SeqPos;
  //
  // Linear counter state
  reg [6:0] LinCtrPeriod, LinCtr;
  reg LinCtrl, LinHalt;
  wire LinCtrZero = (LinCtr == 0);
  //
  // Length counter state
  reg [7:0] LenCtr;
  wire LenCtrHalt = LinCtrl; // Aliased bit
  wire LenCtrZero = (LenCtr == 0);
  assign IsNonZero = !LenCtrZero;
  //
  always @(posedge clk) if (reset) begin
    Period <= 0;
    TimerCtr <= 0;
    SeqPos <= 0;
    LinCtrPeriod <= 0;
    LinCtr <= 0;
    LinCtrl <= 0;
    LinHalt <= 0;
    LenCtr <= 0;
  end else if (ce) begin
    // Check if writing to the regs of this channel
    if (MW) begin
      case (Addr)
      0: begin
        LinCtrl <= DIN[7];
        LinCtrPeriod <= DIN[6:0];
      end
      2: begin
        Period[7:0] <= DIN;
      end
      3: begin
        Period[10:8] <= DIN[2:0];
        LenCtr <= LenCtr_In;
        LinHalt <= 1;
      end
      endcase
    end

    // Count down the period timer...
    if (TimerCtr == 0) begin
      TimerCtr <= Period;
    end else begin
      TimerCtr <= TimerCtr - 1;
    end
    //
    // Clock the length counter?
    if (LenCtr_Clock && !LenCtrZero && !LenCtrHalt) begin
      LenCtr <= LenCtr - 1;
    end
    //
    // Clock the linear counter?
    if (LinCtr_Clock) begin
      if (LinHalt)
        LinCtr <= LinCtrPeriod;
      else if (!LinCtrZero)
        LinCtr <= LinCtr - 1;
      if (!LinCtrl)
        LinHalt <= 0;
    end
    //
    // Length counter forced to zero if disabled.
    if (!Enabled)
      LenCtr <= 0;
      //
    // Clock the sequencer position
    if (TimerCtr == 0 && !LenCtrZero && !LinCtrZero)
      SeqPos <= SeqPos + 1;
  end
  // Generate the output
  assign Sample = SeqPos[3:0] ^ {4{~SeqPos[4]}};
  //
endmodule


module NoiseChan(input clk, input ce, input reset,
                 input [1:0] Addr,
                 input [7:0] DIN,
                 input MW,
                 input LenCtr_Clock,
                 input Env_Clock,
                 input Enabled,
                 input [7:0] LenCtr_In,
                 output [3:0] Sample,
                 output IsNonZero);
  //
  // Envelope volume
  reg EnvLoop, EnvDisable, EnvDoReset;
  reg [3:0] Volume, Envelope, EnvDivider;
  // Length counter
  wire LenCtrHalt = EnvLoop; // Aliased bit
  reg [7:0] LenCtr;
  //
  reg ShortMode;
  reg [14:0] Shift = 1;

  assign IsNonZero = (LenCtr != 0);
  //
  // Period stuff
  reg [3:0] Period;
  reg [11:0] NoisePeriod, TimerCtr;
  always @* begin
    case (Period)
    0: NoisePeriod = 12'h004;
    1: NoisePeriod = 12'h008;
    2: NoisePeriod = 12'h010;
    3: NoisePeriod = 12'h020;
    4: NoisePeriod = 12'h040;
    5: NoisePeriod = 12'h060;
    6: NoisePeriod = 12'h080;
    7: NoisePeriod = 12'h0A0;
    8: NoisePeriod = 12'h0CA;
    9: NoisePeriod = 12'h0FE;
    10: NoisePeriod = 12'h17C;
    11: NoisePeriod = 12'h1FC;
    12: NoisePeriod = 12'h2FA;
    13: NoisePeriod = 12'h3F8;
    14: NoisePeriod = 12'h7F2;
    15: NoisePeriod = 12'hFE4;
    endcase
  end
  //
  always @(posedge clk) if (reset) begin
    EnvLoop <= 0;
    EnvDisable <= 0;
    EnvDoReset <= 0;
    Volume <= 0;
    Envelope <= 0;
    EnvDivider <= 0;
    LenCtr <= 0;
    ShortMode <= 0;
    Shift <= 1;
    Period <= 0;
    TimerCtr <= 0;
  end else if (ce) begin
    // Check if writing to the regs of this channel
    if (MW) begin
      case (Addr)
      0: begin
        EnvLoop <= DIN[5];
        EnvDisable <= DIN[4];
        Volume <= DIN[3:0];
      end
      2: begin
        ShortMode <= DIN[7];
        Period <= DIN[3:0];
      end
      3: begin
        LenCtr <= LenCtr_In;
        EnvDoReset <= 1;
      end
      endcase
    end
    // Count down the period timer...
    if (TimerCtr == 0) begin
      TimerCtr <= NoisePeriod;
      // Clock the shift register. Use either
      // bit 1 or 6 as the tap.
      Shift <= {
        Shift[0] ^ (ShortMode ? Shift[6] : Shift[1]),
        Shift[14:1]};
    end else begin
      TimerCtr <= TimerCtr - 1;
    end
    // Clock the length counter?
    if (LenCtr_Clock && LenCtr != 0 && !LenCtrHalt) begin
      LenCtr <= LenCtr - 1;
    end
    // Clock the envelope generator?
    if (Env_Clock) begin
      if (EnvDoReset) begin
        EnvDivider <= Volume;
        Envelope <= 15;
        EnvDoReset <= 0;
      end else if (EnvDivider == 0) begin
        EnvDivider <= Volume;
        if (Envelope != 0)
          Envelope <= Envelope - 1;
        else if (EnvLoop)
          Envelope <= 15;
      end else
        EnvDivider <= EnvDivider - 1;
    end
    if (!Enabled)
      LenCtr <= 0;
  end
  // Produce the output signal
  assign Sample =
    (LenCtr == 0 || Shift[0]) ?
      0 :
      (EnvDisable ? Volume : Envelope);
endmodule

module DmcChan(input clk, input ce, input reset,
               input odd_or_even,
               input [2:0] Addr,
               input [7:0] DIN,
               input MW,
               output [6:0] Sample,
               output DmaReq,          // 1 when DMC wants DMA
               input DmaAck,           // 1 when DMC byte is on DmcData. DmcDmaRequested should go low.
               output [15:0] DmaAddr,  // Address DMC wants to read
               input [7:0] DmaData,    // Input data to DMC from memory.
               output Irq,
               output IsDmcActive);
  reg IrqEnable;
  reg IrqActive;
  reg Loop;                 // Looping enabled
  reg [3:0] Freq;           // Current value of frequency register
  reg [6:0] Dac = 0;        // Current value of DAC
  reg [7:0] SampleAddress;  // Base address of sample
  reg [7:0] SampleLen;      // Length of sample
  reg [7:0] ShiftReg;       // Shift register
  reg [8:0] Cycles;         // Down counter, is the period
  reg [14:0] Address;        // 15 bits current address, 0x8000-0xffff
  reg [11:0] BytesLeft;      // 12 bits bytes left counter 0 - 4081.
  reg [2:0] BitsUsed;        // Number of bits left in the SampleBuffer.
  reg [7:0] SampleBuffer;    // Next value to be loaded into shift reg
  reg HasSampleBuffer;       // Sample buffer is nonempty
  reg HasShiftReg;           // Shift reg is non empty
  reg [8:0] NewPeriod[0:15];
  reg DmcEnabled;
  reg [1:0] ActivationDelay;
  assign DmaAddr = {1'b1, Address};
  assign Sample = Dac;
  assign Irq = IrqActive;
  assign IsDmcActive = DmcEnabled;

  assign DmaReq = !HasSampleBuffer && DmcEnabled && !ActivationDelay[0];

  initial begin
    NewPeriod[0] = 428;
    NewPeriod[1] = 380;
    NewPeriod[2] = 340;
    NewPeriod[3] = 320;
    NewPeriod[4] = 286;
    NewPeriod[5] = 254;
    NewPeriod[6] = 226;
    NewPeriod[7] = 214;
    NewPeriod[8] = 190;
    NewPeriod[9] = 160;
    NewPeriod[10] = 142;
    NewPeriod[11] = 128;
    NewPeriod[12] = 106;
    NewPeriod[13] = 84;
    NewPeriod[14] = 72;
    NewPeriod[15] = 54;
  end
  // Shift register initially loaded with 07
  always @(posedge clk) begin
    if (reset) begin
      IrqEnable <= 0;
      IrqActive <= 0;
      Loop <= 0;
      Freq <= 0;
      Dac <= 0;
      SampleAddress <= 0;
      SampleLen <= 0;
      ShiftReg <= 8'hff;
      Cycles <= 439;
      Address <= 0;
      BytesLeft <= 0;
      BitsUsed <= 0;
      SampleBuffer <= 0;
      HasSampleBuffer <= 0;
      HasShiftReg <= 0;
      DmcEnabled <= 0;
      ActivationDelay <= 0;
    end else if (ce) begin
      if (ActivationDelay == 3 && !odd_or_even) ActivationDelay <= 1;
      if (ActivationDelay == 1) ActivationDelay <= 0;

      if (MW) begin
        case (Addr)
        0: begin  // $4010   il-- ffff   IRQ enable, loop, frequency index
            IrqEnable <= DIN[7];
            Loop <= DIN[6];
            Freq <= DIN[3:0];
            if (!DIN[7]) IrqActive <= 0;
          end
        1: begin  // $4011   -ddd dddd   DAC
            // This will get missed if the Dac <= far below runs, that is by design.
            Dac <= DIN[6:0];
          end
        2: begin  // $4012   aaaa aaaa   sample address
            SampleAddress <= DIN[7:0];
          end
        3: begin  // $4013   llll llll   sample length
            SampleLen <= DIN[7:0];
          end
        5: begin // $4015 write	---D NT21  Enable DMC (D)
            IrqActive <= 0;
            DmcEnabled <= DIN[4];
            // If the DMC bit is set, the DMC sample will be restarted only if not already active.
            if (DIN[4] && !DmcEnabled) begin
              Address <= {1'b1, SampleAddress, 6'b000000};
              BytesLeft <= {SampleLen, 4'b0000};
              ActivationDelay <= 3;
            end
          end
        endcase
      end

      Cycles <= Cycles - 1;
      if (Cycles == 1) begin
        Cycles <= NewPeriod[Freq];
        if (HasShiftReg) begin
          if (ShiftReg[0]) begin
            Dac[6:1] <= (Dac[6:1] != 6'b111111) ? Dac[6:1] + 6'b000001 : Dac[6:1];
          end else begin
            Dac[6:1] <= (Dac[6:1] != 6'b000000) ? Dac[6:1] + 6'b111111 : Dac[6:1];
          end
        end
        ShiftReg <= {1'b0, ShiftReg[7:1]};
        BitsUsed <= BitsUsed + 1;
        if (BitsUsed == 7) begin
          HasShiftReg <= HasSampleBuffer;
          ShiftReg <= SampleBuffer;
          HasSampleBuffer <= 0;
        end
      end

      // Acknowledge DMA?
      if (DmaAck) begin
        Address <= Address + 1;
        BytesLeft <= BytesLeft - 1;
        HasSampleBuffer <= 1;
        SampleBuffer <= DmaData;
        if (BytesLeft == 0) begin
          Address <= {1'b1, SampleAddress, 6'b000000};
          BytesLeft <= {SampleLen, 4'b0000};
          DmcEnabled <= Loop;
          if (!Loop && IrqEnable)
            IrqActive <= 1;
        end
      end
    end
  end
endmodule

module ApuLookupTable(input clk, input [7:0] in_a, input [7:0] in_b, output [15:0] out);
  reg [15:0] lookup[0:511];
  reg [15:0] tmp_a, tmp_b;
  initial begin
    lookup[  0] =     0; lookup[  1] =   760; lookup[  2] =  1503; lookup[  3] =  2228;
    lookup[  4] =  2936; lookup[  5] =  3627; lookup[  6] =  4303; lookup[  7] =  4963;
    lookup[  8] =  5609; lookup[  9] =  6240; lookup[ 10] =  6858; lookup[ 11] =  7462;
    lookup[ 12] =  8053; lookup[ 13] =  8631; lookup[ 14] =  9198; lookup[ 15] =  9752;
    lookup[ 16] = 10296; lookup[ 17] = 10828; lookup[ 18] = 11349; lookup[ 19] = 11860;
    lookup[ 20] = 12361; lookup[ 21] = 12852; lookup[ 22] = 13334; lookup[ 23] = 13807;
    lookup[ 24] = 14270; lookup[ 25] = 14725; lookup[ 26] = 15171; lookup[ 27] = 15609;
    lookup[ 28] = 16039; lookup[ 29] = 16461; lookup[ 30] = 16876; lookup[256] =     0;
    lookup[257] =   439; lookup[258] =   874; lookup[259] =  1306; lookup[260] =  1735;
    lookup[261] =  2160; lookup[262] =  2581; lookup[263] =  2999; lookup[264] =  3414;
    lookup[265] =  3826; lookup[266] =  4234; lookup[267] =  4639; lookup[268] =  5041;
    lookup[269] =  5440; lookup[270] =  5836; lookup[271] =  6229; lookup[272] =  6618;
    lookup[273] =  7005; lookup[274] =  7389; lookup[275] =  7769; lookup[276] =  8147;
    lookup[277] =  8522; lookup[278] =  8895; lookup[279] =  9264; lookup[280] =  9631;
    lookup[281] =  9995; lookup[282] = 10356; lookup[283] = 10714; lookup[284] = 11070;
    lookup[285] = 11423; lookup[286] = 11774; lookup[287] = 12122; lookup[288] = 12468;
    lookup[289] = 12811; lookup[290] = 13152; lookup[291] = 13490; lookup[292] = 13825;
    lookup[293] = 14159; lookup[294] = 14490; lookup[295] = 14818; lookup[296] = 15145;
    lookup[297] = 15469; lookup[298] = 15791; lookup[299] = 16110; lookup[300] = 16427;
    lookup[301] = 16742; lookup[302] = 17055; lookup[303] = 17366; lookup[304] = 17675;
    lookup[305] = 17981; lookup[306] = 18286; lookup[307] = 18588; lookup[308] = 18888;
    lookup[309] = 19187; lookup[310] = 19483; lookup[311] = 19777; lookup[312] = 20069;
    lookup[313] = 20360; lookup[314] = 20648; lookup[315] = 20935; lookup[316] = 21219;
    lookup[317] = 21502; lookup[318] = 21783; lookup[319] = 22062; lookup[320] = 22339;
    lookup[321] = 22615; lookup[322] = 22889; lookup[323] = 23160; lookup[324] = 23431;
    lookup[325] = 23699; lookup[326] = 23966; lookup[327] = 24231; lookup[328] = 24494;
    lookup[329] = 24756; lookup[330] = 25016; lookup[331] = 25274; lookup[332] = 25531;
    lookup[333] = 25786; lookup[334] = 26040; lookup[335] = 26292; lookup[336] = 26542;
    lookup[337] = 26791; lookup[338] = 27039; lookup[339] = 27284; lookup[340] = 27529;
    lookup[341] = 27772; lookup[342] = 28013; lookup[343] = 28253; lookup[344] = 28492;
    lookup[345] = 28729; lookup[346] = 28964; lookup[347] = 29198; lookup[348] = 29431;
    lookup[349] = 29663; lookup[350] = 29893; lookup[351] = 30121; lookup[352] = 30349;
    lookup[353] = 30575; lookup[354] = 30800; lookup[355] = 31023; lookup[356] = 31245;
    lookup[357] = 31466; lookup[358] = 31685; lookup[359] = 31904; lookup[360] = 32121;
    lookup[361] = 32336; lookup[362] = 32551; lookup[363] = 32764; lookup[364] = 32976;
    lookup[365] = 33187; lookup[366] = 33397; lookup[367] = 33605; lookup[368] = 33813;
    lookup[369] = 34019; lookup[370] = 34224; lookup[371] = 34428; lookup[372] = 34630;
    lookup[373] = 34832; lookup[374] = 35032; lookup[375] = 35232; lookup[376] = 35430;
    lookup[377] = 35627; lookup[378] = 35823; lookup[379] = 36018; lookup[380] = 36212;
    lookup[381] = 36405; lookup[382] = 36597; lookup[383] = 36788; lookup[384] = 36978;
    lookup[385] = 37166; lookup[386] = 37354; lookup[387] = 37541; lookup[388] = 37727;
    lookup[389] = 37912; lookup[390] = 38095; lookup[391] = 38278; lookup[392] = 38460;
    lookup[393] = 38641; lookup[394] = 38821; lookup[395] = 39000; lookup[396] = 39178;
    lookup[397] = 39355; lookup[398] = 39532; lookup[399] = 39707; lookup[400] = 39881;
    lookup[401] = 40055; lookup[402] = 40228; lookup[403] = 40399; lookup[404] = 40570;
    lookup[405] = 40740; lookup[406] = 40909; lookup[407] = 41078; lookup[408] = 41245;
    lookup[409] = 41412; lookup[410] = 41577; lookup[411] = 41742; lookup[412] = 41906;
    lookup[413] = 42070; lookup[414] = 42232; lookup[415] = 42394; lookup[416] = 42555;
    lookup[417] = 42715; lookup[418] = 42874; lookup[419] = 43032; lookup[420] = 43190;
    lookup[421] = 43347; lookup[422] = 43503; lookup[423] = 43659; lookup[424] = 43813;
    lookup[425] = 43967; lookup[426] = 44120; lookup[427] = 44273; lookup[428] = 44424;
    lookup[429] = 44575; lookup[430] = 44726; lookup[431] = 44875; lookup[432] = 45024;
    lookup[433] = 45172; lookup[434] = 45319; lookup[435] = 45466; lookup[436] = 45612;
    lookup[437] = 45757; lookup[438] = 45902; lookup[439] = 46046; lookup[440] = 46189;
    lookup[441] = 46332; lookup[442] = 46474; lookup[443] = 46615; lookup[444] = 46756;
    lookup[445] = 46895; lookup[446] = 47035; lookup[447] = 47173; lookup[448] = 47312;
    lookup[449] = 47449; lookup[450] = 47586; lookup[451] = 47722; lookup[452] = 47857;
    lookup[453] = 47992; lookup[454] = 48127; lookup[455] = 48260; lookup[456] = 48393;
    lookup[457] = 48526; lookup[458] = 48658;
  end
  always @(posedge clk) begin
    tmp_a <= lookup[{1'b0, in_a}];
    tmp_b <= lookup[{1'b1, in_b}];
  end
  assign out = tmp_a + tmp_b;
endmodule


module APU(input clk, input ce, input reset,
           input [4:0] ADDR,  // APU Address Line
           input [7:0] DIN,   // Data to APU
           output [7:0] DOUT, // Data from APU
           input MW,          // Writes to APU
           input MR,          // Reads from APU
           input [4:0] audio_channels, // Enabled audio channels
           output [15:0] Sample,

           output DmaReq,      // 1 when DMC wants DMA
           input DmaAck,           // 1 when DMC byte is on DmcData. DmcDmaRequested should go low.
           output [15:0] DmaAddr,  // Address DMC wants to read
           input [7:0] DmaData,    // Input data to DMC from memory.

           output odd_or_even,
           output IRQ);       // IRQ asserted

// Which channels are enabled?
reg [3:0] Enabled;

// Output samples from the 4 channels
wire [3:0] Sq1Sample,Sq2Sample,TriSample,NoiSample;

// Output samples from the DMC channel
wire [6:0] DmcSample;
wire DmcIrq;
wire IsDmcActive;

// Generate internal memory write signals
wire ApuMW0 = MW && ADDR[4:2]==0; // SQ1
wire ApuMW1 = MW && ADDR[4:2]==1; // SQ2
wire ApuMW2 = MW && ADDR[4:2]==2; // TRI
wire ApuMW3 = MW && ADDR[4:2]==3; // NOI
wire ApuMW4 = MW && ADDR[4:2]>=4; // DMC
wire ApuMW5 = MW && ADDR[4:2]==5; // Control registers

wire Sq1NonZero, Sq2NonZero, TriNonZero, NoiNonZero;

// Common input to all channels
wire [7:0] LenCtr_In;
LenCtr_Lookup len(DIN[7:3], LenCtr_In);


// Frame sequencer registers
reg FrameSeqMode;
reg [15:0] Cycles;
reg ClkE, ClkL;
reg Wrote4017;
reg [1:0] IrqCtr;
reg InternalClock; // APU Differentiates between Even or Odd clocks
assign odd_or_even = InternalClock;


// Generate each channel
SquareChan   Sq1(clk, ce, reset, 1'b0, ADDR[1:0], DIN, ApuMW0, ClkL, ClkE, Enabled[0], LenCtr_In, Sq1Sample, Sq1NonZero);
SquareChan   Sq2(clk, ce, reset, 1'b1, ADDR[1:0], DIN, ApuMW1, ClkL, ClkE, Enabled[1], LenCtr_In, Sq2Sample, Sq2NonZero);
TriangleChan Tri(clk, ce, reset, ADDR[1:0], DIN, ApuMW2, ClkL, ClkE, Enabled[2], LenCtr_In, TriSample, TriNonZero);
NoiseChan    Noi(clk, ce, reset, ADDR[1:0], DIN, ApuMW3, ClkL, ClkE, Enabled[3], LenCtr_In, NoiSample, NoiNonZero);
DmcChan      Dmc(clk, ce, reset, odd_or_even, ADDR[2:0], DIN, ApuMW4, DmcSample, DmaReq, DmaAck, DmaAddr, DmaData, DmcIrq, IsDmcActive);

// Reading this register clears the frame interrupt flag (but not the DMC interrupt flag).
// If an interrupt flag was set at the same moment of the read, it will read back as 1 but it will not be cleared.
reg FrameInterrupt, DisableFrameInterrupt;


//mode 0: 4-step  effective rate (approx)
//---------------------------------------
//    - - - f      60 Hz
//    - l - l     120 Hz
//    e e e e     240 Hz


//mode 1: 5-step  effective rate (approx)
//---------------------------------------
//    - - - - -   (interrupt flag never set)
//    l - l - -    96 Hz
//    e e e e -   192 Hz


always @(posedge clk) if (reset) begin
  FrameSeqMode <= 0;
  DisableFrameInterrupt <= 0;
  FrameInterrupt <= 0;
  Enabled <= 0;
  InternalClock <= 0;
  Wrote4017 <= 0;
  ClkE <= 0;
  ClkL <= 0;
  Cycles <= 4; // This needs to be 5 for proper power up behavior
  IrqCtr <= 0;
end else if (ce) begin
  FrameInterrupt <= IrqCtr[1] ? 1 : (ADDR == 5'h15 && MR || ApuMW5 && ADDR[1:0] == 3 && DIN[6]) ? 0 : FrameInterrupt;
  InternalClock <= !InternalClock;
  IrqCtr <= {IrqCtr[0], 1'b0};
  Cycles <= Cycles + 1;
  ClkE <= 0;
  ClkL <= 0;
  if (Cycles == 7457) begin
    ClkE <= 1;
  end else if (Cycles == 14913) begin
    ClkE <= 1;
    ClkL <= 1;
    ClkE <= 1;
    ClkL <= 1;
  end else if (Cycles == 22371) begin
    ClkE <= 1;
  end else if (Cycles == 29829) begin
    if (!FrameSeqMode) begin
      ClkE <= 1;
      ClkL <= 1;
      Cycles <= 0;
      IrqCtr <= 3;
      FrameInterrupt <= 1;
    end
  end else if (Cycles == 37281) begin
    ClkE <= 1;
    ClkL <= 1;
    Cycles <= 0;
  end

  // Handle one cycle delayed write to 4017.
  Wrote4017 <= 0;
  if (Wrote4017) begin
    if (FrameSeqMode) begin
      ClkE <= 1;
      ClkL <= 1;
    end
    Cycles <= 0;
  end

//  if (ClkE||ClkL) $write("%d: Clocking %s%s\n", Cycles, ClkE?"E":" ", ClkL?"L":" ");

  // Handle writes to control registers
  if (ApuMW5) begin
    case (ADDR[1:0])
    1: begin // Register $4015
      Enabled <= DIN[3:0];
//      $write("$4015 = %X\n", DIN);
    end
    3: begin // Register $4017
      FrameSeqMode <= DIN[7]; // 1 = 5 frames cycle, 0 = 4 frames cycle
      DisableFrameInterrupt <= DIN[6];

      // If the internal clock is even, things happen
      // right away.
      if (!InternalClock) begin
        if (DIN[7]) begin
          ClkE <= 1;
          ClkL <= 1;
        end
        Cycles <= 0;
      end

      // Otherwise they get delayed one clock
      Wrote4017 <= InternalClock;
    end
    endcase
  end


end

ApuLookupTable lookup(clk,
                      (audio_channels[0] ? {4'b0, Sq1Sample} : 8'b0) +
                      (audio_channels[1] ? {4'b0, Sq2Sample} : 8'b0),
                      (audio_channels[2] ? {4'b0, TriSample} + {3'b0, TriSample, 1'b0} : 8'b0) +
                      (audio_channels[3] ? {3'b0, NoiSample, 1'b0} : 8'b0) +
                      (audio_channels[4] ? {1'b0, DmcSample} : 8'b0),
                      Sample);

wire frame_irq = FrameInterrupt && !DisableFrameInterrupt;

// Generate bus output
assign DOUT = {DmcIrq, frame_irq, 1'b0,
               IsDmcActive,
               NoiNonZero,
               TriNonZero,
               Sq2NonZero,
               Sq1NonZero};

assign IRQ = frame_irq || DmcIrq;

endmodule
