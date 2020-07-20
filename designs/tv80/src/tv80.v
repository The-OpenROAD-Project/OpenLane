

module tv80 (/*AUTOARG*/
  // Outputs
  m1_n, iorq, no_read, write, rfsh_n, halt_n, busak_n, A, do, mc, ts, 
  intcycle_n, IntE, stop, 
  // Inputs
  reset_n, clk, cen, wait_n, int_n, nmi_n, busrq_n, dinst, di
  );
  // Beginning of automatic inputs (from unused autoinst inputs)
  // End of automatics
  
  parameter Mode = 1;   // 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
  parameter IOWait = 1; // 0 => Single cycle I/O, 1 => Std I/O cycle
  parameter Flag_C = 0;
  parameter Flag_N = 1;
  parameter Flag_P = 2;
  parameter Flag_X = 3;
  parameter Flag_H = 4;
  parameter Flag_Y = 5;
  parameter Flag_Z = 6;
  parameter Flag_S = 7;

  input     reset_n;            
  input     clk;                
  input     cen;                
  input     wait_n;             
  input     int_n;              
  input     nmi_n;              
  input     busrq_n;            
  output    m1_n;               
  output    iorq;               
  output    no_read;            
  output    write;              
  output    rfsh_n;             
  output    halt_n;             
  output    busak_n;            
  output [15:0] A; 
  input [7:0]   dinst;  
  input [7:0]   di;     
  output [7:0]  do;     
  output [6:0]  mc;     
  output [6:0]  ts;     
  output        intcycle_n;     
  output        IntE;           
  output        stop;           

  reg    m1_n;          
  reg    iorq;          
  reg    rfsh_n;                
  reg    halt_n;                
  reg    busak_n;               
  reg [15:0] A; 
  reg [7:0]  do;        
  reg [6:0]  mc;        
  reg [6:0]  ts;        
  reg   intcycle_n;     
  reg   IntE;           
  reg   stop;           

  parameter     aNone    = 3'b111;
  parameter     aBC      = 3'b000;
  parameter     aDE      = 3'b001;
  parameter     aXY      = 3'b010;
  parameter     aIOA     = 3'b100;
  parameter     aSP      = 3'b101;
  parameter     aZI      = 3'b110;

  // Registers
  reg [7:0]     ACC, F;
  reg [7:0]     Ap, Fp;
  reg [7:0]     I;
  reg [7:0]     R;
  reg [15:0]    SP, PC;
  reg [7:0]     RegDIH;
  reg [7:0]     RegDIL;
  wire [15:0]   RegBusA;
  wire [15:0]   RegBusB;
  wire [15:0]   RegBusC;
  reg [2:0]     RegAddrA_r;
  reg [2:0]     RegAddrA;
  reg [2:0]     RegAddrB_r;
  reg [2:0]     RegAddrB;
  reg [2:0]     RegAddrC;
  reg           RegWEH;
  reg           RegWEL;
  reg           Alternate;

  // Help Registers
  reg [15:0]    TmpAddr;        // Temporary address register
  reg [7:0]     IR;             // Instruction register
  reg [1:0]     ISet;           // Instruction set selector
  reg [15:0]    RegBusA_r;

  reg [15:0]    ID16;
  reg [7:0]     Save_Mux;

  reg [6:0]     tstate;
  reg [6:0]     mcycle;
  reg           last_mcycle, last_tstate;
  reg           IntE_FF1;
  reg           IntE_FF2;
  reg           Halt_FF;
  reg           BusReq_s;
  reg           BusAck;
  reg           ClkEn;
  reg           NMI_s;
  reg           INT_s;
  reg [1:0]     IStatus;

  reg [7:0]     DI_Reg;
  reg           T_Res;
  reg [1:0]     XY_State;
  reg [2:0]     Pre_XY_F_M;
  reg           NextIs_XY_Fetch;
  reg           XY_Ind;
  reg           No_BTR;
  reg           BTR_r;
  reg           Auto_Wait;
  reg           Auto_Wait_t1;
  reg           Auto_Wait_t2;
  reg           IncDecZ;

  // ALU signals
  reg [7:0]     BusB;
  reg [7:0]     BusA;
  wire [7:0]    ALU_Q;
  wire [7:0]    F_Out;

  // Registered micro code outputs
  reg [4:0]     Read_To_Reg_r;
  reg           Arith16_r;
  reg           Z16_r;
  reg [3:0]     ALU_Op_r;
  reg           Save_ALU_r;
  reg           PreserveC_r;
  reg [2:0]     mcycles;

  // Micro code outputs
  wire [2:0]    mcycles_d;
  wire [2:0]    tstates;
  reg           IntCycle;
  reg           NMICycle;
  wire          Inc_PC;
  wire          Inc_WZ;
  wire [3:0]    IncDec_16;
  wire [1:0]    Prefix;
  wire          Read_To_Acc;
  wire          Read_To_Reg;
  wire [3:0]     Set_BusB_To;
  wire [3:0]     Set_BusA_To;
  wire [3:0]     ALU_Op;
  wire           Save_ALU;
  wire           PreserveC;
  wire           Arith16;
  wire [2:0]     Set_Addr_To;
  wire           Jump;
  wire           JumpE;
  wire           JumpXY;
  wire           Call;
  wire           RstP;
  wire           LDZ;
  wire           LDW;
  wire           LDSPHL;
  wire           iorq_i;
  wire [2:0]     Special_LD;
  wire           ExchangeDH;
  wire           ExchangeRp;
  wire           ExchangeAF;
  wire           ExchangeRS;
  wire           I_DJNZ;
  wire           I_CPL;
  wire           I_CCF;
  wire           I_SCF;
  wire           I_RETN;
  wire           I_BT;
  wire           I_BC;
  wire           I_BTR;
  wire           I_RLD;
  wire           I_RRD;
  wire           I_INRC;
  wire           SetDI;
  wire           SetEI;
  wire [1:0]     IMode;
  wire           Halt;

  reg [15:0]     PC16;
  reg [15:0]     PC16_B;
  reg [15:0]     SP16, SP16_A, SP16_B;
  reg [15:0]     ID16_B;
  reg            Oldnmi_n;
  
  tv80_mcode #(Mode, Flag_C, Flag_N, Flag_P, Flag_X, Flag_H, Flag_Y, Flag_Z, Flag_S) i_mcode
    (
     .IR                   (IR),
     .ISet                 (ISet),
     .MCycle               (mcycle),
     .F                    (F),
     .NMICycle             (NMICycle),
     .IntCycle             (IntCycle),
     .MCycles              (mcycles_d),
     .TStates              (tstates),
     .Prefix               (Prefix),
     .Inc_PC               (Inc_PC),
     .Inc_WZ               (Inc_WZ),
     .IncDec_16            (IncDec_16),
     .Read_To_Acc          (Read_To_Acc),
     .Read_To_Reg          (Read_To_Reg),
     .Set_BusB_To          (Set_BusB_To),
     .Set_BusA_To          (Set_BusA_To),
     .ALU_Op               (ALU_Op),
     .Save_ALU             (Save_ALU),
     .PreserveC            (PreserveC),
     .Arith16              (Arith16),
     .Set_Addr_To          (Set_Addr_To),
     .IORQ                 (iorq_i),
     .Jump                 (Jump),
     .JumpE                (JumpE),
     .JumpXY               (JumpXY),
     .Call                 (Call),
     .RstP                 (RstP),
     .LDZ                  (LDZ),
     .LDW                  (LDW),
     .LDSPHL               (LDSPHL),
     .Special_LD           (Special_LD),
     .ExchangeDH           (ExchangeDH),
     .ExchangeRp           (ExchangeRp),
     .ExchangeAF           (ExchangeAF),
     .ExchangeRS           (ExchangeRS),
     .I_DJNZ               (I_DJNZ),
     .I_CPL                (I_CPL),
     .I_CCF                (I_CCF),
     .I_SCF                (I_SCF),
     .I_RETN               (I_RETN),
     .I_BT                 (I_BT),
     .I_BC                 (I_BC),
     .I_BTR                (I_BTR),
     .I_RLD                (I_RLD),
     .I_RRD                (I_RRD),
     .I_INRC               (I_INRC),
     .SetDI                (SetDI),
     .SetEI                (SetEI),
     .IMode                (IMode),
     .Halt                 (Halt),
     .NoRead               (no_read),
     .Write                (write)
     );

  tv80_alu #(Mode, Flag_C, Flag_N, Flag_P, Flag_X, Flag_H, Flag_Y, Flag_Z, Flag_S) i_alu
    (
     .Arith16              (Arith16_r),
     .Z16                  (Z16_r),
     .ALU_Op               (ALU_Op_r),
     .IR                   (IR[5:0]),
     .ISet                 (ISet),
     .BusA                 (BusA),
     .BusB                 (BusB),
     .F_In                 (F),
     .Q                    (ALU_Q),
     .F_Out                (F_Out)
     );

  function [6:0] number_to_bitvec;
    input [2:0] num;
    begin
      case (num)
        1 : number_to_bitvec = 7'b0000001;
        2 : number_to_bitvec = 7'b0000010;
        3 : number_to_bitvec = 7'b0000100;
        4 : number_to_bitvec = 7'b0001000;
        5 : number_to_bitvec = 7'b0010000;
        6 : number_to_bitvec = 7'b0100000;
        7 : number_to_bitvec = 7'b1000000;
        default : number_to_bitvec = 7'bx;
      endcase // case(num)
    end
  endfunction // number_to_bitvec
  
  always @(/*AUTOSENSE*/mcycle or mcycles or tstate or tstates)
    begin
      case (mcycles)
        1 : last_mcycle = mcycle[0];
        2 : last_mcycle = mcycle[1];
        3 : last_mcycle = mcycle[2];
        4 : last_mcycle = mcycle[3];
        5 : last_mcycle = mcycle[4];
        6 : last_mcycle = mcycle[5];
        7 : last_mcycle = mcycle[6];
        default : last_mcycle = 1'bx;
      endcase // case(mcycles)

      case (tstates)
        0 : last_tstate = tstate[0];
        1 : last_tstate = tstate[1];
        2 : last_tstate = tstate[2];
        3 : last_tstate = tstate[3];
        4 : last_tstate = tstate[4];
        5 : last_tstate = tstate[5];
        6 : last_tstate = tstate[6];
        default : last_tstate = 1'bx;
      endcase
    end // always @ (...
  
          
  always @(/*AUTOSENSE*/ALU_Q or BusAck or BusB or DI_Reg
           or ExchangeRp or IR or Save_ALU_r or Set_Addr_To or XY_Ind
           or XY_State or cen or last_tstate or mcycle)
    begin
      ClkEn = cen && ~ BusAck;

      if (last_tstate)
        T_Res = 1'b1;
      else T_Res = 1'b0;
      
      if (XY_State != 2'b00 && XY_Ind == 1'b0 &&
          ((Set_Addr_To == aXY) ||
           (mcycle[0] && IR == 8'b11001011) ||
           (mcycle[0] && IR == 8'b00110110)))
        NextIs_XY_Fetch = 1'b1;
      else 
        NextIs_XY_Fetch = 1'b0;

      if (ExchangeRp)
        Save_Mux = BusB;
      else if (!Save_ALU_r)
        Save_Mux = DI_Reg;
      else
        Save_Mux = ALU_Q;
    end // always @ *
  
  always @ (posedge clk)
    begin
      if (reset_n == 1'b0 ) 
        begin
          PC <= #1 0;  // Program Counter
          A <= #1 0;
          TmpAddr <= #1 0;
          IR <= #1 8'b00000000;
          ISet <= #1 2'b00;
          XY_State <= #1 2'b00;
          IStatus <= #1 2'b00;
          mcycles <= #1 3'b000;
          do <= #1 8'b00000000;

          ACC <= #1 8'hFF;
          F <= #1 8'hFF;
          Ap <= #1 8'hFF;
          Fp <= #1 8'hFF;
          I <= #1 0;
          `ifdef TV80_REFRESH
          R <= #1 0;
          `endif
          SP <= #1 16'hFFFF;
          Alternate <= #1 1'b0;

          Read_To_Reg_r <= #1 5'b00000;
          Arith16_r <= #1 1'b0;
          BTR_r <= #1 1'b0;
          Z16_r <= #1 1'b0;
          ALU_Op_r <= #1 4'b0000;
          Save_ALU_r <= #1 1'b0;
          PreserveC_r <= #1 1'b0;
          XY_Ind <= #1 1'b0;
        end 
      else 
        begin

          if (ClkEn == 1'b1 ) 
            begin

              ALU_Op_r <= #1 4'b0000;
              Save_ALU_r <= #1 1'b0;
              Read_To_Reg_r <= #1 5'b00000;

              mcycles <= #1 mcycles_d;

              if (IMode != 2'b11 ) 
                begin
                  IStatus <= #1 IMode;
                end

              Arith16_r <= #1 Arith16;
              PreserveC_r <= #1 PreserveC;
              if (ISet == 2'b10 && ALU_Op[2] == 1'b0 && ALU_Op[0] == 1'b1 && mcycle[2] ) 
                begin
                  Z16_r <= #1 1'b1;
                end 
              else 
                begin
                  Z16_r <= #1 1'b0;
                end

              if (mcycle[0] && (tstate[1] | tstate[2] | tstate[3] )) 
                begin
                  // mcycle == 1 && tstate == 1, 2, || 3
                  if (tstate[2] && wait_n == 1'b1 ) 
                    begin
                      `ifdef TV80_REFRESH
                      if (Mode < 2 ) 
                        begin
                          A[7:0] <= #1 R;
                          A[15:8] <= #1 I;
                          R[6:0] <= #1 R[6:0] + 1;
                        end
                      `endif
                      if (Jump == 1'b0 && Call == 1'b0 && NMICycle == 1'b0 && IntCycle == 1'b0 && ~ (Halt_FF == 1'b1 || Halt == 1'b1) ) 
                        begin
                          PC <= #1 PC16;
                        end

                      if (IntCycle == 1'b1 && IStatus == 2'b01 ) 
                        begin
                          IR <= #1 8'b11111111;
                        end 
                      else if (Halt_FF == 1'b1 || (IntCycle == 1'b1 && IStatus == 2'b10) || NMICycle == 1'b1 ) 
                        begin
                          IR <= #1 8'b00000000;
                        end 
                      else 
                        begin
                          IR <= #1 dinst;
                        end

                      ISet <= #1 2'b00;
                      if (Prefix != 2'b00 ) 
                        begin
                          if (Prefix == 2'b11 ) 
                            begin
                              if (IR[5] == 1'b1 ) 
                                begin
                                  XY_State <= #1 2'b10;
                                end 
                              else 
                                begin
                                  XY_State <= #1 2'b01;
                                end
                            end 
                          else 
                            begin
                              if (Prefix == 2'b10 ) 
                                begin
                                  XY_State <= #1 2'b00;
                                  XY_Ind <= #1 1'b0;
                                end
                              ISet <= #1 Prefix;
                            end
                        end 
                      else 
                        begin
                          XY_State <= #1 2'b00;
                          XY_Ind <= #1 1'b0;
                        end
                    end // if (tstate == 2 && wait_n == 1'b1 )
                  

                end 
              else 
                begin
                  // either (mcycle > 1) OR (mcycle == 1 AND tstate > 3)

                  if (mcycle[5] ) 
                    begin
                      XY_Ind <= #1 1'b1;
                      if (Prefix == 2'b01 ) 
                        begin
                          ISet <= #1 2'b01;
                        end
                    end
                  
                  if (T_Res == 1'b1 ) 
                    begin
                      BTR_r <= #1 (I_BT || I_BC || I_BTR) && ~ No_BTR;
                      if (Jump == 1'b1 ) 
                        begin
                          A[15:8] <= #1 DI_Reg;
                          A[7:0] <= #1 TmpAddr[7:0];
                          PC[15:8] <= #1 DI_Reg;
                          PC[7:0] <= #1 TmpAddr[7:0];
                        end 
                      else if (JumpXY == 1'b1 ) 
                        begin
                          A <= #1 RegBusC;
                          PC <= #1 RegBusC;
                        end else if (Call == 1'b1 || RstP == 1'b1 ) 
                          begin
                            A <= #1 TmpAddr;
                            PC <= #1 TmpAddr;
                          end 
                        else if (last_mcycle && NMICycle == 1'b1 ) 
                          begin
                            A <= #1 16'b0000000001100110;
                            PC <= #1 16'b0000000001100110;
                          end 
                        else if (mcycle[2] && IntCycle == 1'b1 && IStatus == 2'b10 ) 
                          begin
                            A[15:8] <= #1 I;
                            A[7:0] <= #1 TmpAddr[7:0];
                            PC[15:8] <= #1 I;
                            PC[7:0] <= #1 TmpAddr[7:0];
                          end 
                        else 
                          begin
                            case (Set_Addr_To)
                              aXY :
                                begin
                                  if (XY_State == 2'b00 ) 
                                    begin
                                      A <= #1 RegBusC;
                                    end 
                                  else 
                                    begin
                                      if (NextIs_XY_Fetch == 1'b1 )
                                        begin
                                          A <= #1 PC;
                                        end 
                                      else 
                                        begin
                                          A <= #1 TmpAddr;
                                        end
                                    end // else: !if(XY_State == 2'b00 )
                                end // case: aXY
                              
                              aIOA :
                                begin
                                  if (Mode == 3 ) 
                                    begin
                                      // Memory map I/O on GBZ80
                                      A[15:8] <= #1 8'hFF;
                                    end 
                                  else if (Mode == 2 ) 
                                    begin
                                      // Duplicate I/O address on 8080
                                      A[15:8] <= #1 DI_Reg;
                                    end 
                                  else 
                                    begin
                                      A[15:8] <= #1 ACC;
                                    end
                                  A[7:0] <= #1 DI_Reg;
                                end // case: aIOA

                              
                              aSP :
                                begin
                                  A <= #1 SP;
                                end
                              
                              aBC :
                                begin
                                  if (Mode == 3 && iorq_i == 1'b1 ) 
                                    begin
                                      // Memory map I/O on GBZ80
                                      A[15:8] <= #1 8'hFF;
                                      A[7:0] <= #1 RegBusC[7:0];
                                    end 
                                  else 
                                    begin
                                      A <= #1 RegBusC;
                                    end
                                end // case: aBC
                              
                              aDE :
                                begin
                                  A <= #1 RegBusC;
                                end
                              
                              aZI :
                                begin                                  
                                  if (Inc_WZ == 1'b1 ) 
                                    begin
                                      A <= #1 TmpAddr + 1;
                                    end 
                                  else 
                                    begin
                                      A[15:8] <= #1 DI_Reg;
                                      A[7:0] <= #1 TmpAddr[7:0];
                                    end
                                end // case: aZI
                              
                              default   :
                                begin                                    
                                  A <= #1 PC;
                                end
                            endcase // case(Set_Addr_To)
                            
                          end // else: !if(mcycle[2] && IntCycle == 1'b1 && IStatus == 2'b10 )
                      

                      Save_ALU_r <= #1 Save_ALU;
                      ALU_Op_r <= #1 ALU_Op;
                      
                      if (I_CPL == 1'b1 ) 
                        begin
                          // CPL
                          ACC <= #1 ~ ACC;
                          F[Flag_Y] <= #1 ~ ACC[5];
                          F[Flag_H] <= #1 1'b1;
                          F[Flag_X] <= #1 ~ ACC[3];
                          F[Flag_N] <= #1 1'b1;
                        end
                      if (I_CCF == 1'b1 ) 
                        begin
                          // CCF
                          F[Flag_C] <= #1 ~ F[Flag_C];
                          F[Flag_Y] <= #1 ACC[5];
                          F[Flag_H] <= #1 F[Flag_C];
                          F[Flag_X] <= #1 ACC[3];
                          F[Flag_N] <= #1 1'b0;
                        end
                      if (I_SCF == 1'b1 ) 
                        begin
                          // SCF
                          F[Flag_C] <= #1 1'b1;
                          F[Flag_Y] <= #1 ACC[5];
                          F[Flag_H] <= #1 1'b0;
                          F[Flag_X] <= #1 ACC[3];
                          F[Flag_N] <= #1 1'b0;
                        end
                    end // if (T_Res == 1'b1 )
                  

                  if (tstate[2] && wait_n == 1'b1 ) 
                    begin
                      if (ISet == 2'b01 && mcycle[6] ) 
                        begin
                          IR <= #1 dinst;
                        end
                      if (JumpE == 1'b1 ) 
                        begin
                          PC <= #1 PC16;
                        end 
                      else if (Inc_PC == 1'b1 ) 
                        begin
                          //PC <= #1 PC + 1;
                          PC <= #1 PC16;
                        end
                      if (BTR_r == 1'b1 ) 
                        begin
                          //PC <= #1 PC - 2;
                          PC <= #1 PC16;
                        end
                      if (RstP == 1'b1 ) 
                        begin
                          TmpAddr <= #1 { 10'h0, IR[5:3], 3'h0 };
                          //TmpAddr <= #1 (others =>1'b0);
                          //TmpAddr[5:3] <= #1 IR[5:3];
                        end
                    end
                  if (tstate[3] && mcycle[5] ) 
                    begin
                      TmpAddr <= #1 SP16;
                    end

                  if ((tstate[2] && wait_n == 1'b1) || (tstate[4] && mcycle[0]) ) 
                    begin
                      if (IncDec_16[2:0] == 3'b111 ) 
                        begin
                          SP <= #1 SP16;
                        end
                    end

                  if (LDSPHL == 1'b1 ) 
                    begin
                      SP <= #1 RegBusC;
                    end
                  if (ExchangeAF == 1'b1 ) 
                    begin
                      Ap <= #1 ACC;
                      ACC <= #1 Ap;
                      Fp <= #1 F;
                      F <= #1 Fp;
                    end
                  if (ExchangeRS == 1'b1 ) 
                    begin
                      Alternate <= #1 ~ Alternate;
                    end
                end // else: !if(mcycle  == 3'b001 && tstate(2) == 1'b0 )
              

              if (tstate[3] ) 
                begin
                  if (LDZ == 1'b1 ) 
                    begin
                      TmpAddr[7:0] <= #1 DI_Reg;
                    end
                  if (LDW == 1'b1 ) 
                    begin
                      TmpAddr[15:8] <= #1 DI_Reg;
                    end

                  if (Special_LD[2] == 1'b1 ) 
                    begin
                      case (Special_LD[1:0])
                        2'b00 :
                          begin
                            ACC <= #1 I;
                            F[Flag_P] <= #1 IntE_FF2;
                          end
                        
                        2'b01 :
                          begin
                            ACC <= #1 R;
                            F[Flag_P] <= #1 IntE_FF2;
                          end
                        
                        2'b10 :
                          I <= #1 ACC;

                        `ifdef TV80_REFRESH                        
                        default :
                          R <= #1 ACC;
                        `else
                        default : ;
                        `endif                        
                      endcase
                    end
                end // if (tstate == 3 )
              

              if ((I_DJNZ == 1'b0 && Save_ALU_r == 1'b1) || ALU_Op_r == 4'b1001 ) 
                begin
                  if (Mode == 3 ) 
                    begin
                      F[6] <= #1 F_Out[6];
                      F[5] <= #1 F_Out[5];
                      F[7] <= #1 F_Out[7];
                      if (PreserveC_r == 1'b0 ) 
                        begin
                          F[4] <= #1 F_Out[4];
                        end
                    end 
                  else 
                    begin
                      F[7:1] <= #1 F_Out[7:1];
                      if (PreserveC_r == 1'b0 ) 
                        begin
                          F[Flag_C] <= #1 F_Out[0];
                        end
                    end
                end // if ((I_DJNZ == 1'b0 && Save_ALU_r == 1'b1) || ALU_Op_r == 4'b1001 )
              
              if (T_Res == 1'b1 && I_INRC == 1'b1 ) 
                begin
                  F[Flag_H] <= #1 1'b0;
                  F[Flag_N] <= #1 1'b0;
                  if (DI_Reg[7:0] == 8'b00000000 ) 
                    begin
                      F[Flag_Z] <= #1 1'b1;
                    end 
                  else 
                    begin
                      F[Flag_Z] <= #1 1'b0;
                    end
                  F[Flag_S] <= #1 DI_Reg[7];
                  F[Flag_P] <= #1 ~ (^DI_Reg[7:0]);
                end // if (T_Res == 1'b1 && I_INRC == 1'b1 )
              

              if (tstate[1] && Auto_Wait_t1 == 1'b0 ) 
                begin
                  do <= #1 BusB;
                  if (I_RLD == 1'b1 ) 
                    begin
                      do[3:0] <= #1 BusA[3:0];
                      do[7:4] <= #1 BusB[3:0];
                    end
                  if (I_RRD == 1'b1 ) 
                    begin
                      do[3:0] <= #1 BusB[7:4];
                      do[7:4] <= #1 BusA[3:0];
                    end
                end

              if (T_Res == 1'b1 ) 
                begin
                  Read_To_Reg_r[3:0] <= #1 Set_BusA_To;
                  Read_To_Reg_r[4] <= #1 Read_To_Reg;
                  if (Read_To_Acc == 1'b1 ) 
                    begin
                      Read_To_Reg_r[3:0] <= #1 4'b0111;
                      Read_To_Reg_r[4] <= #1 1'b1;
                    end
                end

              if (tstate[1] && I_BT == 1'b1 ) 
                begin
                  F[Flag_X] <= #1 ALU_Q[3];
                  F[Flag_Y] <= #1 ALU_Q[1];
                  F[Flag_H] <= #1 1'b0;
                  F[Flag_N] <= #1 1'b0;
                end
              if (I_BC == 1'b1 || I_BT == 1'b1 ) 
                begin
                  F[Flag_P] <= #1 IncDecZ;
                end

              if ((tstate[1] && Save_ALU_r == 1'b0 && Auto_Wait_t1 == 1'b0) ||
                  (Save_ALU_r == 1'b1 && ALU_Op_r != 4'b0111) ) 
                begin
                  case (Read_To_Reg_r)
                    5'b10111 :
                      ACC <= #1 Save_Mux;
                    5'b10110 :
                      do <= #1 Save_Mux;
                    5'b11000 :
                      SP[7:0] <= #1 Save_Mux;
                    5'b11001 :
                      SP[15:8] <= #1 Save_Mux;
                    5'b11011 :
                      F <= #1 Save_Mux;
                  endcase
                end // if ((tstate == 1 && Save_ALU_r == 1'b0 && Auto_Wait_t1 == 1'b0) ||...              
            end // if (ClkEn == 1'b1 )         
        end // else: !if(reset_n == 1'b0 )
    end
  

  //-------------------------------------------------------------------------
  //
  // BC('), DE('), HL('), IX && IY
  //
  //-------------------------------------------------------------------------
  always @ (posedge clk)
    begin
      if (ClkEn == 1'b1 ) 
        begin
          // Bus A / Write
          RegAddrA_r <= #1  { Alternate, Set_BusA_To[2:1] };
          if (XY_Ind == 1'b0 && XY_State != 2'b00 && Set_BusA_To[2:1] == 2'b10 ) 
            begin
              RegAddrA_r <= #1 { XY_State[1],  2'b11 };
            end

          // Bus B
          RegAddrB_r <= #1 { Alternate, Set_BusB_To[2:1] };
          if (XY_Ind == 1'b0 && XY_State != 2'b00 && Set_BusB_To[2:1] == 2'b10 ) 
            begin
              RegAddrB_r <= #1 { XY_State[1],  2'b11 };
            end

          // Address from register
          RegAddrC <= #1 { Alternate,  Set_Addr_To[1:0] };
          // Jump (HL), LD SP,HL
          if ((JumpXY == 1'b1 || LDSPHL == 1'b1) ) 
            begin
              RegAddrC <= #1 { Alternate, 2'b10 };
            end
          if (((JumpXY == 1'b1 || LDSPHL == 1'b1) && XY_State != 2'b00) || (mcycle[5]) ) 
            begin
              RegAddrC <= #1 { XY_State[1],  2'b11 };
            end

          if (I_DJNZ == 1'b1 && Save_ALU_r == 1'b1 && Mode < 2 ) 
            begin
              IncDecZ <= #1 F_Out[Flag_Z];
            end
          if ((tstate[2] || (tstate[3] && mcycle[0])) && IncDec_16[2:0] == 3'b100 ) 
            begin
              if (ID16 == 0 ) 
                begin
                  IncDecZ <= #1 1'b0;
                end 
              else 
                begin
                  IncDecZ <= #1 1'b1;
                end
            end
          
          RegBusA_r <= #1 RegBusA;
        end
      
    end // always @ (posedge clk)
  

  always @(/*AUTOSENSE*/Alternate or ExchangeDH or IncDec_16
           or RegAddrA_r or RegAddrB_r or XY_State or mcycle or tstate)
    begin
      if ((tstate[2] || (tstate[3] && mcycle[0] && IncDec_16[2] == 1'b1)) && XY_State == 2'b00)
        RegAddrA = { Alternate, IncDec_16[1:0] };
      else if ((tstate[2] || (tstate[3] && mcycle[0] && IncDec_16[2] == 1'b1)) && IncDec_16[1:0] == 2'b10)
        RegAddrA = { XY_State[1], 2'b11 };
      else if (ExchangeDH == 1'b1 && tstate[3])
        RegAddrA = { Alternate, 2'b10 };
      else if (ExchangeDH == 1'b1 && tstate[4])
        RegAddrA = { Alternate, 2'b01 };
      else
        RegAddrA = RegAddrA_r;
      
      if (ExchangeDH == 1'b1 && tstate[3])
        RegAddrB = { Alternate, 2'b01 };
      else
        RegAddrB = RegAddrB_r;
    end // always @ *
  

  always @(/*AUTOSENSE*/ALU_Op_r or Auto_Wait_t1 or ExchangeDH
           or IncDec_16 or Read_To_Reg_r or Save_ALU_r or mcycle
           or tstate or wait_n)
    begin
      RegWEH = 1'b0;
      RegWEL = 1'b0;
      if ((tstate[1] && Save_ALU_r == 1'b0 && Auto_Wait_t1 == 1'b0) ||
          (Save_ALU_r == 1'b1 && ALU_Op_r != 4'b0111) ) 
        begin
          case (Read_To_Reg_r)
            5'b10000 , 5'b10001 , 5'b10010 , 5'b10011 , 5'b10100 , 5'b10101 :
              begin
                RegWEH = ~ Read_To_Reg_r[0];
                RegWEL = Read_To_Reg_r[0];
              end
          endcase // case(Read_To_Reg_r)
          
        end // if ((tstate == 1 && Save_ALU_r == 1'b0 && Auto_Wait_t1 == 1'b0) ||...
      

      if (ExchangeDH == 1'b1 && (tstate[3] || tstate[4]) ) 
        begin
          RegWEH = 1'b1;
          RegWEL = 1'b1;
        end

      if (IncDec_16[2] == 1'b1 && ((tstate[2] && wait_n == 1'b1 && mcycle != 3'b001) || (tstate[3] && mcycle[0])) ) 
        begin
          case (IncDec_16[1:0])
            2'b00 , 2'b01 , 2'b10 :
              begin
                RegWEH = 1'b1;
                RegWEL = 1'b1;
              end
          endcase
        end
    end // always @ *
  

  always @(/*AUTOSENSE*/ExchangeDH or ID16 or IncDec_16 or RegBusA_r
           or RegBusB or Save_Mux or mcycle or tstate)
    begin
      RegDIH = Save_Mux;
      RegDIL = Save_Mux;

      if (ExchangeDH == 1'b1 && tstate[3] ) 
        begin
          RegDIH = RegBusB[15:8];
          RegDIL = RegBusB[7:0];
        end
      else if (ExchangeDH == 1'b1 && tstate[4] ) 
        begin
          RegDIH = RegBusA_r[15:8];
          RegDIL = RegBusA_r[7:0];
        end
      else if (IncDec_16[2] == 1'b1 && ((tstate[2] && mcycle != 3'b001) || (tstate[3] && mcycle[0])) ) 
        begin
          RegDIH = ID16[15:8];
          RegDIL = ID16[7:0];
        end
    end

  tv80_reg i_reg
    (
     .clk                  (clk),
     .CEN                  (ClkEn),
     .WEH                  (RegWEH),
     .WEL                  (RegWEL),
     .AddrA                (RegAddrA),
     .AddrB                (RegAddrB),
     .AddrC                (RegAddrC),
     .DIH                  (RegDIH),
     .DIL                  (RegDIL),
     .DOAH                 (RegBusA[15:8]),
     .DOAL                 (RegBusA[7:0]),
     .DOBH                 (RegBusB[15:8]),
     .DOBL                 (RegBusB[7:0]),
     .DOCH                 (RegBusC[15:8]),
     .DOCL                 (RegBusC[7:0])
     );

  //-------------------------------------------------------------------------
  //
  // Buses
  //
  //-------------------------------------------------------------------------

  always @ (posedge clk)
    begin
      if (ClkEn == 1'b1 ) 
        begin
          case (Set_BusB_To)
            4'b0111 :
              BusB <= #1 ACC;
            4'b0000 , 4'b0001 , 4'b0010 , 4'b0011 , 4'b0100 , 4'b0101 :
              begin
                if (Set_BusB_To[0] == 1'b1 ) 
                  begin
                    BusB <= #1 RegBusB[7:0];
                  end 
                else 
                  begin
                    BusB <= #1 RegBusB[15:8];
                  end
              end
            4'b0110 :
              BusB <= #1 DI_Reg;
            4'b1000 :
              BusB <= #1 SP[7:0];
            4'b1001 :
              BusB <= #1 SP[15:8];
            4'b1010 :
              BusB <= #1 8'b00000001;
            4'b1011 :
              BusB <= #1 F;
            4'b1100 :
              BusB <= #1 PC[7:0];
            4'b1101 :
              BusB <= #1 PC[15:8];
            4'b1110 :
              BusB <= #1 8'b00000000;
            default :
              BusB <= #1 8'hxx;
          endcase

          case (Set_BusA_To)
            4'b0111 :
              BusA <= #1 ACC;
            4'b0000 , 4'b0001 , 4'b0010 , 4'b0011 , 4'b0100 , 4'b0101 :
              begin
                if (Set_BusA_To[0] == 1'b1 )
                  begin
                    BusA <= #1 RegBusA[7:0];
                  end 
                else 
                  begin
                    BusA <= #1 RegBusA[15:8];
                  end
              end
            4'b0110 :
              BusA <= #1 DI_Reg;
            4'b1000 :
              BusA <= #1 SP[7:0];
            4'b1001 :
              BusA <= #1 SP[15:8];
            4'b1010 :
              BusA <= #1 8'b00000000;
            default :
              BusB <= #1  8'hxx;
          endcase
        end
    end

  //-------------------------------------------------------------------------
  //
  // Generate external control signals
  //
  //-------------------------------------------------------------------------
`ifdef TV80_REFRESH
  always @ (posedge clk)
    begin
      if (reset_n == 1'b0 ) 
        begin
          rfsh_n <= #1 1'b1;
        end 
      else
        begin
          if (cen == 1'b1 ) 
            begin
              if (mcycle[0] && ((tstate[2]  && wait_n == 1'b1) || tstate[3]) ) 
                begin
                  rfsh_n <= #1 1'b0;
                end 
              else 
                begin
                  rfsh_n <= #1 1'b1;
                end
            end
        end
    end
`endif  

  always @(/*AUTOSENSE*/BusAck or Halt_FF or I_DJNZ or IntCycle
           or IntE_FF1 or di or iorq_i or mcycle or tstate)
    begin
      mc = mcycle;
      ts = tstate;
      DI_Reg = di;
      halt_n = ~ Halt_FF;
      busak_n = ~ BusAck;
      intcycle_n = ~ IntCycle;
      IntE = IntE_FF1;
      iorq = iorq_i;
      stop = I_DJNZ;
    end

  //-----------------------------------------------------------------------
  //
  // Syncronise inputs
  //
  //-----------------------------------------------------------------------

  always @ (posedge clk)
    begin : sync_inputs

      if (reset_n == 1'b0 ) 
        begin
          BusReq_s <= #1 1'b0;
          INT_s <= #1 1'b0;
          NMI_s <= #1 1'b0;
          Oldnmi_n <= #1 1'b0;
        end 
      else
        begin
          if (cen == 1'b1 ) 
            begin
              BusReq_s <= #1 ~ busrq_n;
              INT_s <= #1 ~ int_n;
              if (NMICycle == 1'b1 ) 
                begin
                  NMI_s <= #1 1'b0;
                end 
              else if (nmi_n == 1'b0 && Oldnmi_n == 1'b1 ) 
                begin
                  NMI_s <= #1 1'b1;
                end
              Oldnmi_n <= #1 nmi_n;
            end
        end
    end

  //-----------------------------------------------------------------------
  //
  // Main state machine
  //
  //-----------------------------------------------------------------------

  always @ (posedge clk)
    begin
      if (reset_n == 1'b0 ) 
        begin
          mcycle <= #1 7'b0000001;
          tstate <= #1 7'b0000001;
          Pre_XY_F_M <= #1 3'b000;
          Halt_FF <= #1 1'b0;
          BusAck <= #1 1'b0;
          NMICycle <= #1 1'b0;
          IntCycle <= #1 1'b0;
          IntE_FF1 <= #1 1'b0;
          IntE_FF2 <= #1 1'b0;
          No_BTR <= #1 1'b0;
          Auto_Wait_t1 <= #1 1'b0;
          Auto_Wait_t2 <= #1 1'b0;
          m1_n <= #1 1'b1;
        end 
      else
        begin
          if (cen == 1'b1 ) 
            begin
              if (T_Res == 1'b1 ) 
                begin
                  Auto_Wait_t1 <= #1 1'b0;
                end 
              else 
                begin
                  Auto_Wait_t1 <= #1 Auto_Wait || iorq_i;
                end
              Auto_Wait_t2 <= #1 Auto_Wait_t1;
              No_BTR <= #1 (I_BT && (~ IR[4] || ~ F[Flag_P])) ||
                        (I_BC && (~ IR[4] || F[Flag_Z] || ~ F[Flag_P])) ||
                        (I_BTR && (~ IR[4] || F[Flag_Z]));
              if (tstate[2] ) 
                begin
                  if (SetEI == 1'b1 ) 
                    begin
                      IntE_FF1 <= #1 1'b1;
                      IntE_FF2 <= #1 1'b1;
                    end
                  if (I_RETN == 1'b1 ) 
                    begin
                      IntE_FF1 <= #1 IntE_FF2;
                    end
                end
              if (tstate[3] ) 
                begin
                  if (SetDI == 1'b1 ) 
                    begin
                      IntE_FF1 <= #1 1'b0;
                      IntE_FF2 <= #1 1'b0;
                    end
                end
              if (IntCycle == 1'b1 || NMICycle == 1'b1 ) 
                begin
                  Halt_FF <= #1 1'b0;
                end
              if (mcycle[0] && tstate[2] && wait_n == 1'b1 ) 
                begin
                  m1_n <= #1 1'b1;
                end
              if (BusReq_s == 1'b1 && BusAck == 1'b1 ) 
                begin
                end 
              else 
                begin
                  BusAck <= #1 1'b0;
                  if (tstate[2] && wait_n == 1'b0 ) 
                    begin
                    end 
                  else if (T_Res == 1'b1 ) 
                    begin
                      if (Halt == 1'b1 ) 
                        begin
                          Halt_FF <= #1 1'b1;
                        end
                      if (BusReq_s == 1'b1 ) 
                        begin
                          BusAck <= #1 1'b1;
                        end 
                      else 
                        begin
                          tstate <= #1 7'b0000010;
                          if (NextIs_XY_Fetch == 1'b1 ) 
                            begin
                              mcycle <= #1 7'b0100000;
                              Pre_XY_F_M <= #1 mcycle;
                              if (IR == 8'b00110110 && Mode == 0 ) 
                                begin
                                  Pre_XY_F_M <= #1 3'b010;
                                end
                            end 
                          else if ((mcycle[6]) || (mcycle[5] && Mode == 1 && ISet != 2'b01) ) 
                            begin
                              mcycle <= #1 number_to_bitvec(Pre_XY_F_M + 1);
                            end 
                          else if ((last_mcycle) ||
                                   No_BTR == 1'b1 ||
                                   (mcycle[1] && I_DJNZ == 1'b1 && IncDecZ == 1'b1) ) 
                            begin
                              m1_n <= #1 1'b0;
                              mcycle <= #1 7'b0000001;
                              IntCycle <= #1 1'b0;
                              NMICycle <= #1 1'b0;
                              if (NMI_s == 1'b1 && Prefix == 2'b00 ) 
                                begin
                                  NMICycle <= #1 1'b1;
                                  IntE_FF1 <= #1 1'b0;
                                end 
                              else if ((IntE_FF1 == 1'b1 && INT_s == 1'b1) && Prefix == 2'b00 && SetEI == 1'b0 ) 
                                begin
                                  IntCycle <= #1 1'b1;
                                  IntE_FF1 <= #1 1'b0;
                                  IntE_FF2 <= #1 1'b0;
                                end
                            end 
                          else 
                            begin
                              mcycle <= #1 { mcycle[5:0], mcycle[6] };
                            end
                        end
                    end 
                  else 
                    begin   // verilog has no "nor" operator
                      if ( ~(Auto_Wait == 1'b1 && Auto_Wait_t2 == 1'b0) &&
                           ~(IOWait == 1 && iorq_i == 1'b1 && Auto_Wait_t1 == 1'b0) ) 
                        begin
                          tstate <= #1 { tstate[5:0], tstate[6] };
                        end
                    end
                end
              if (tstate[0]) 
                begin
                  m1_n <= #1 1'b0;
                end
            end
        end
    end

  always @(/*AUTOSENSE*/BTR_r or DI_Reg or IncDec_16 or JumpE or PC
           or RegBusA or RegBusC or SP or tstate)
    begin
      if (JumpE == 1'b1 ) 
        begin
          PC16_B = { {8{DI_Reg[7]}}, DI_Reg };
        end 
      else if (BTR_r == 1'b1 ) 
        begin
          PC16_B = -2;
        end
      else
        begin
          PC16_B = 1;
        end

      if (tstate[3])
        begin
          SP16_A = RegBusC;
          SP16_B = { {8{DI_Reg[7]}}, DI_Reg };
        end
      else
        begin
          // suspect that ID16 and SP16 could be shared
          SP16_A = SP;
          
          if (IncDec_16[3] == 1'b1)
            SP16_B = -1;
          else
            SP16_B = 1;
        end

      if (IncDec_16[3])  
        ID16_B = -1;
      else
        ID16_B = 1;

      ID16 = RegBusA + ID16_B;
      PC16 = PC + PC16_B;
      SP16 = SP16_A + SP16_B;
    end // always @ *
  

  always @(/*AUTOSENSE*/IntCycle or NMICycle or mcycle)
    begin
      Auto_Wait = 1'b0;
      if (IntCycle == 1'b1 || NMICycle == 1'b1 ) 
        begin
          if (mcycle[0] ) 
            begin
              Auto_Wait = 1'b1;
            end
        end
    end // always @ *
  
// synopsys dc_script_begin
// set_attribute current_design "revision" "$Id: tv80_core.v,v 1.5 2005-01-26 18:55:47 ghutchis Exp $" -type string -quiet
// synopsys dc_script_end
endmodule // T80



module tv80_alu (/*AUTOARG*/
  // Outputs
  Q, F_Out, 
  // Inputs
  Arith16, Z16, ALU_Op, IR, ISet, BusA, BusB, F_In
  );

  parameter		Mode   = 0;
  parameter		Flag_C = 0;
  parameter		Flag_N = 1;
  parameter		Flag_P = 2;
  parameter		Flag_X = 3;
  parameter		Flag_H = 4;
  parameter		Flag_Y = 5;
  parameter		Flag_Z = 6;
  parameter		Flag_S = 7;

  input 		Arith16;
  input 		Z16;
  input [3:0]           ALU_Op ;
  input [5:0]           IR;
  input [1:0]           ISet;
  input [7:0]           BusA;
  input [7:0]           BusB;
  input [7:0]           F_In;
  output [7:0]          Q;
  output [7:0]          F_Out;
  reg [7:0]             Q;
  reg [7:0]             F_Out;

  function [4:0] AddSub4;
    input [3:0] A;
    input [3:0] B;
    input Sub;
    input Carry_In;
    begin
      AddSub4 = { 1'b0, A } + { 1'b0, (Sub)?~B:B } + Carry_In;
    end
  endfunction // AddSub4
  
  function [3:0] AddSub3;
    input [2:0] A;
    input [2:0] B;
    input Sub;
    input Carry_In;
    begin
      AddSub3 = { 1'b0, A } + { 1'b0, (Sub)?~B:B } + Carry_In;
    end
  endfunction // AddSub4

  function [1:0] AddSub1;
    input A;
    input B;
    input Sub;
    input Carry_In;
    begin
      AddSub1 = { 1'b0, A } + { 1'b0, (Sub)?~B:B } + Carry_In;
    end
  endfunction // AddSub4

  // AddSub variables (temporary signals)
  reg UseCarry;
  reg Carry7_v;
  reg OverFlow_v;
  reg HalfCarry_v;
  reg Carry_v;
  reg [7:0] Q_v;

  reg [7:0] BitMask;


  always @(/*AUTOSENSE*/ALU_Op or BusA or BusB or F_In or IR)
    begin
      case (IR[5:3])
        3'b000 : BitMask = 8'b00000001;
        3'b001 : BitMask = 8'b00000010;
        3'b010 : BitMask = 8'b00000100; 
        3'b011 : BitMask = 8'b00001000; 
        3'b100 : BitMask = 8'b00010000; 
        3'b101 : BitMask = 8'b00100000; 
        3'b110 : BitMask = 8'b01000000; 
        default: BitMask = 8'b10000000; 
      endcase // case(IR[5:3])
      
      UseCarry = ~ ALU_Op[2] && ALU_Op[0];
      { HalfCarry_v, Q_v[3:0] } = AddSub4(BusA[3:0], BusB[3:0], ALU_Op[1], ALU_Op[1] ^ (UseCarry && F_In[Flag_C]) );
      { Carry7_v, Q_v[6:4]  } = AddSub3(BusA[6:4], BusB[6:4], ALU_Op[1], HalfCarry_v);
      { Carry_v, Q_v[7] } = AddSub1(BusA[7], BusB[7], ALU_Op[1], Carry7_v);
      OverFlow_v = Carry_v ^ Carry7_v;
    end // always @ *
  
  reg [7:0] Q_t;
  reg [8:0] DAA_Q;
  
  always @ (/*AUTOSENSE*/ALU_Op or Arith16 or BitMask or BusA or BusB
	    or Carry_v or F_In or HalfCarry_v or IR or ISet
	    or OverFlow_v or Q_v or Z16)
    begin
      Q_t = 8'hxx;
      DAA_Q = {9{1'bx}};
      
      F_Out = F_In;
      case (ALU_Op)
	4'b0000, 4'b0001,  4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111 :
          begin
	    F_Out[Flag_N] = 1'b0;
	    F_Out[Flag_C] = 1'b0;
            
	    case (ALU_Op[2:0])
              
	      3'b000, 3'b001 : // ADD, ADC
                begin
		  Q_t = Q_v;
		  F_Out[Flag_C] = Carry_v;
		  F_Out[Flag_H] = HalfCarry_v;
		  F_Out[Flag_P] = OverFlow_v;
                end
              
	      3'b010, 3'b011, 3'b111 : // SUB, SBC, CP
                begin
		  Q_t = Q_v;
		  F_Out[Flag_N] = 1'b1;
		  F_Out[Flag_C] = ~ Carry_v;
		  F_Out[Flag_H] = ~ HalfCarry_v;
		  F_Out[Flag_P] = OverFlow_v;
                end
              
	      3'b100 : // AND
                begin
		  Q_t[7:0] = BusA & BusB;
		  F_Out[Flag_H] = 1'b1;
                end
              
	      3'b101 : // XOR
                begin
		  Q_t[7:0] = BusA ^ BusB;
		  F_Out[Flag_H] = 1'b0;
                end
              
	      default : // OR 3'b110
                begin
		  Q_t[7:0] = BusA | BusB;
		  F_Out[Flag_H] = 1'b0;
                end
              
	    endcase // case(ALU_OP[2:0])
            
	    if (ALU_Op[2:0] == 3'b111 ) 
              begin // CP
		F_Out[Flag_X] = BusB[3];
		F_Out[Flag_Y] = BusB[5];
	      end 
            else 
              begin
		F_Out[Flag_X] = Q_t[3];
		F_Out[Flag_Y] = Q_t[5];
	      end
            
	    if (Q_t[7:0] == 8'b00000000 ) 
              begin
		F_Out[Flag_Z] = 1'b1;
		if (Z16 == 1'b1 ) 
                  begin
		    F_Out[Flag_Z] = F_In[Flag_Z];	// 16 bit ADC,SBC
		  end
	      end 
            else 
              begin
		F_Out[Flag_Z] = 1'b0;
	      end // else: !if(Q_t[7:0] == 8'b00000000 )
            
	    F_Out[Flag_S] = Q_t[7];
	    case (ALU_Op[2:0])
	      3'b000, 3'b001, 3'b010, 3'b011, 3'b111 : // ADD, ADC, SUB, SBC, CP
                ;
              
	      default :
	        F_Out[Flag_P] = ~(^Q_t);                    
	    endcase // case(ALU_Op[2:0])
            
	    if (Arith16 == 1'b1 ) 
              begin
		F_Out[Flag_S] = F_In[Flag_S];
		F_Out[Flag_Z] = F_In[Flag_Z];
		F_Out[Flag_P] = F_In[Flag_P];
	      end
          end // case: 4'b0000, 4'b0001,  4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111
        
	4'b1100 :
          begin
	    // DAA
	    F_Out[Flag_H] = F_In[Flag_H];
	    F_Out[Flag_C] = F_In[Flag_C];
	    DAA_Q[7:0] = BusA;
	    DAA_Q[8] = 1'b0;
	    if (F_In[Flag_N] == 1'b0 ) 
              begin
		// After addition
		// Alow > 9 || H == 1
		if (DAA_Q[3:0] > 9 || F_In[Flag_H] == 1'b1 ) 
                  begin
		    if ((DAA_Q[3:0] > 9) ) 
                      begin
			F_Out[Flag_H] = 1'b1;
		      end 
                    else 
                      begin
			F_Out[Flag_H] = 1'b0;
		      end
		    DAA_Q = DAA_Q + 6;
		  end // if (DAA_Q[3:0] > 9 || F_In[Flag_H] == 1'b1 )
                
		// new Ahigh > 9 || C == 1
		if (DAA_Q[8:4] > 9 || F_In[Flag_C] == 1'b1 ) 
                  begin
		    DAA_Q = DAA_Q + 96; // 0x60
		  end
	      end 
            else 
              begin
		// After subtraction
		if (DAA_Q[3:0] > 9 || F_In[Flag_H] == 1'b1 ) 
                  begin
		    if (DAA_Q[3:0] > 5 ) 
                      begin
			F_Out[Flag_H] = 1'b0;
		      end
		    DAA_Q[7:0] = DAA_Q[7:0] - 6;
		  end
		if (BusA > 153 || F_In[Flag_C] == 1'b1 ) 
                  begin
		    DAA_Q = DAA_Q - 352; // 0x160
		  end
	      end // else: !if(F_In[Flag_N] == 1'b0 )
            
	    F_Out[Flag_X] = DAA_Q[3];
	    F_Out[Flag_Y] = DAA_Q[5];
	    F_Out[Flag_C] = F_In[Flag_C] || DAA_Q[8];
	    Q_t = DAA_Q[7:0];
            
	    if (DAA_Q[7:0] == 8'b00000000 ) 
              begin
		F_Out[Flag_Z] = 1'b1;
	      end 
            else 
              begin
		F_Out[Flag_Z] = 1'b0;
	      end
            
	    F_Out[Flag_S] = DAA_Q[7];
	    F_Out[Flag_P] = ~ (^DAA_Q);
          end // case: 4'b1100
        
	4'b1101, 4'b1110 :
          begin
	    // RLD, RRD
	    Q_t[7:4] = BusA[7:4];
	    if (ALU_Op[0] == 1'b1 ) 
              begin
		Q_t[3:0] = BusB[7:4];
	      end 
            else 
              begin
		Q_t[3:0] = BusB[3:0];
	      end
	    F_Out[Flag_H] = 1'b0;
	    F_Out[Flag_N] = 1'b0;
	    F_Out[Flag_X] = Q_t[3];
	    F_Out[Flag_Y] = Q_t[5];
	    if (Q_t[7:0] == 8'b00000000 ) 
              begin
		F_Out[Flag_Z] = 1'b1;
	      end 
            else 
              begin
		F_Out[Flag_Z] = 1'b0;
	      end
	    F_Out[Flag_S] = Q_t[7];
            F_Out[Flag_P] = ~(^Q_t);
          end // case: when 4'b1101, 4'b1110
        
	4'b1001 :
          begin
	    // BIT
	    Q_t[7:0] = BusB & BitMask;
	    F_Out[Flag_S] = Q_t[7];
	    if (Q_t[7:0] == 8'b00000000 ) 
              begin
		F_Out[Flag_Z] = 1'b1;
		F_Out[Flag_P] = 1'b1;
	      end 
            else 
              begin
		F_Out[Flag_Z] = 1'b0;
		F_Out[Flag_P] = 1'b0;
	      end
	    F_Out[Flag_H] = 1'b1;
	    F_Out[Flag_N] = 1'b0;
	    F_Out[Flag_X] = 1'b0;
	    F_Out[Flag_Y] = 1'b0;
	    if (IR[2:0] != 3'b110 ) 
              begin
		F_Out[Flag_X] = BusB[3];
		F_Out[Flag_Y] = BusB[5];
	      end
          end // case: when 4'b1001
        
	4'b1010 :
	  // SET
	  Q_t[7:0] = BusB | BitMask;
        
	4'b1011 :
	  // RES
	  Q_t[7:0] = BusB & ~ BitMask;
        
	4'b1000 :
          begin
	    // ROT
	    case (IR[5:3])
	      3'b000 : // RLC
                begin
		  Q_t[7:1] = BusA[6:0];
		  Q_t[0] = BusA[7];
		  F_Out[Flag_C] = BusA[7];
                end
              
	      3'b010 : // RL
                begin
		  Q_t[7:1] = BusA[6:0];
		  Q_t[0] = F_In[Flag_C];
		  F_Out[Flag_C] = BusA[7];
                end
              
	      3'b001 : // RRC
                begin
		  Q_t[6:0] = BusA[7:1];
		  Q_t[7] = BusA[0];
		  F_Out[Flag_C] = BusA[0];
                end
              
	      3'b011 : // RR
                begin                        
		  Q_t[6:0] = BusA[7:1];
		  Q_t[7] = F_In[Flag_C];
		  F_Out[Flag_C] = BusA[0];
                end
              
	      3'b100 : // SLA
                begin
		  Q_t[7:1] = BusA[6:0];
		  Q_t[0] = 1'b0;
		  F_Out[Flag_C] = BusA[7];
                end
              
	      3'b110 : // SLL (Undocumented) / SWAP
                begin
		  if (Mode == 3 ) 
                    begin
		      Q_t[7:4] = BusA[3:0];
		      Q_t[3:0] = BusA[7:4];
		      F_Out[Flag_C] = 1'b0;                            
		    end 
                  else 
                    begin
		      Q_t[7:1] = BusA[6:0];
		      Q_t[0] = 1'b1;
		      F_Out[Flag_C] = BusA[7];
		    end // else: !if(Mode == 3 )
                end // case: 3'b110
              
	      3'b101 : // SRA
                begin
		  Q_t[6:0] = BusA[7:1];
		  Q_t[7] = BusA[7];
		  F_Out[Flag_C] = BusA[0];
                end
              
	      default : // SRL
                begin
		  Q_t[6:0] = BusA[7:1];
		  Q_t[7] = 1'b0;
		  F_Out[Flag_C] = BusA[0];
                end
	    endcase // case(IR[5:3])
            
	    F_Out[Flag_H] = 1'b0;
	    F_Out[Flag_N] = 1'b0;
	    F_Out[Flag_X] = Q_t[3];
	    F_Out[Flag_Y] = Q_t[5];
	    F_Out[Flag_S] = Q_t[7];
	    if (Q_t[7:0] == 8'b00000000 ) 
              begin
		F_Out[Flag_Z] = 1'b1;
	      end 
            else 
              begin
		F_Out[Flag_Z] = 1'b0;
	      end
            F_Out[Flag_P] = ~(^Q_t);

	    if (ISet == 2'b00 ) 
              begin
		F_Out[Flag_P] = F_In[Flag_P];
		F_Out[Flag_S] = F_In[Flag_S];
		F_Out[Flag_Z] = F_In[Flag_Z];
	      end
          end // case: 4'b1000
        
        
	default :
	  ;
        
      endcase // case(ALU_Op)
      
      Q = Q_t;
    end // always @ (Arith16, ALU_OP, F_In, BusA, BusB, IR, Q_v, Carry_v, HalfCarry_v, OverFlow_v, BitMask, ISet, Z16)
  
endmodule // T80_ALU


module tv80s (/*AUTOARG*/
  // Outputs
  m1_n, mreq_n, iorq_n, rd_n, wr_n, rfsh_n, halt_n, busak_n, A, do, 
  // Inputs
  reset_n, clk, wait_n, int_n, nmi_n, busrq_n, di
  );

  parameter Mode = 0;    // 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
  parameter T2Write = 1; // 0 => wr_n active in T3, /=0 => wr_n active in T2
  parameter IOWait  = 1; // 0 => Single cycle I/O, 1 => Std I/O cycle


  input         reset_n; 
  input         clk; 
  input         wait_n; 
  input         int_n; 
  input         nmi_n; 
  input         busrq_n; 
  output        m1_n; 
  output        mreq_n; 
  output        iorq_n; 
  output        rd_n; 
  output        wr_n; 
  output        rfsh_n; 
  output        halt_n; 
  output        busak_n; 
  output [15:0] A;
  input [7:0]   di;
  output [7:0]  do;

  reg           mreq_n; 
  reg           iorq_n; 
  reg           rd_n; 
  reg           wr_n; 
  
  wire          cen;
  wire          intcycle_n;
  wire          no_read;
  wire          write;
  wire          iorq;
  reg [7:0]     di_reg;
  wire [6:0]    mcycle;
  wire [6:0]    tstate;

  assign    cen = 1;

  tv80_core #(Mode, IOWait) i_tv80_core
    (
     .cen (cen),
     .m1_n (m1_n),
     .iorq (iorq),
     .no_read (no_read),
     .write (write),
     .rfsh_n (rfsh_n),
     .halt_n (halt_n),
     .wait_n (wait_n),
     .int_n (int_n),
     .nmi_n (nmi_n),
     .reset_n (reset_n),
     .busrq_n (busrq_n),
     .busak_n (busak_n),
     .clk (clk),
     .IntE (),
     .stop (),
     .A (A),
     .dinst (di),
     .di (di_reg),
     .do (do),
     .mc (mcycle),
     .ts (tstate),
     .intcycle_n (intcycle_n)
     );  

  always @(posedge clk)
    begin
      if (!reset_n)
        begin
          rd_n   <= #1 1'b1;
          wr_n   <= #1 1'b1;
          iorq_n <= #1 1'b1;
          mreq_n <= #1 1'b1;
          di_reg <= #1 0;
        end
      else
        begin
          rd_n <= #1 1'b1;
          wr_n <= #1 1'b1;
          iorq_n <= #1 1'b1;
          mreq_n <= #1 1'b1;
          if (mcycle[0])
            begin
              if (tstate[1] || (tstate[2] && wait_n == 1'b0))
                begin
                  rd_n <= #1 ~ intcycle_n;
                  mreq_n <= #1 ~ intcycle_n;
                  iorq_n <= #1 intcycle_n;
                end
            `ifdef TV80_REFRESH
              if (tstate[3])
            mreq_n <= #1 1'b0;
            `endif
            end // if (mcycle[0])          
          else
            begin
              if ((tstate[1] || (tstate[2] && wait_n == 1'b0)) && no_read == 1'b0 && write == 1'b0)
                begin
                  rd_n <= #1 1'b0;
                  iorq_n <= #1 ~ iorq;
                  mreq_n <= #1 iorq;
                end
              if (T2Write == 0)
                begin                          
                  if (tstate[2] && write == 1'b1)
                    begin
                      wr_n <= #1 1'b0;
                      iorq_n <= #1 ~ iorq;
                      mreq_n <= #1 iorq;
                    end
                end
              else
                begin
                  if ((tstate[1] || (tstate[2] && wait_n == 1'b0)) && write == 1'b1)
                    begin
                      wr_n <= #1 1'b0;
                      iorq_n <= #1 ~ iorq;
                      mreq_n <= #1 iorq;
                  end
                end // else: !if(T2write == 0)
              
            end // else: !if(mcycle[0])
          
          if (tstate[2] && wait_n == 1'b1)
            di_reg <= #1 di;
        end // else: !if(!reset_n)
    end // always @ (posedge clk or negedge reset_n)
  
endmodule // t80s



module tv80n (/*AUTOARG*/
  // Outputs
  m1_n, mreq_n, iorq_n, rd_n, wr_n, rfsh_n, halt_n, busak_n, A, do, 
  // Inputs
  reset_n, clk, wait_n, int_n, nmi_n, busrq_n, di
  );

  parameter Mode = 0;    // 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
  parameter T2Write = 0; // 0 => wr_n active in T3, /=0 => wr_n active in T2
  parameter IOWait  = 1; // 0 => Single cycle I/O, 1 => Std I/O cycle


  input         reset_n; 
  input         clk; 
  input         wait_n; 
  input         int_n; 
  input         nmi_n; 
  input         busrq_n; 
  output        m1_n; 
  output        mreq_n; 
  output        iorq_n; 
  output        rd_n; 
  output        wr_n; 
  output        rfsh_n; 
  output        halt_n; 
  output        busak_n; 
  output [15:0] A;
  input [7:0]   di;
  output [7:0]  do;

  reg           mreq_n; 
  reg           iorq_n; 
  reg           rd_n; 
  reg           wr_n; 
  reg           nxt_mreq_n; 
  reg           nxt_iorq_n; 
  reg           nxt_rd_n; 
  reg           nxt_wr_n; 
  
  wire          cen;
  wire          intcycle_n;
  wire          no_read;
  wire          write;
  wire          iorq;
  reg [7:0]     di_reg;
  wire [6:0]    mcycle;
  wire [6:0]    tstate;

  assign    cen = 1;

  tv80_core #(Mode, IOWait) i_tv80_core
    (
     .cen (cen),
     .m1_n (m1_n),
     .iorq (iorq),
     .no_read (no_read),
     .write (write),
     .rfsh_n (rfsh_n),
     .halt_n (halt_n),
     .wait_n (wait_n),
     .int_n (int_n),
     .nmi_n (nmi_n),
     .reset_n (reset_n),
     .busrq_n (busrq_n),
     .busak_n (busak_n),
     .clk (clk),
     .IntE (),
     .stop (),
     .A (A),
     .dinst (di),
     .di (di_reg),
     .do (do),
     .mc (mcycle),
     .ts (tstate),
     .intcycle_n (intcycle_n)
     );  

  always @*
    begin
      nxt_mreq_n = 1;
      nxt_rd_n   = 1;
      nxt_iorq_n = 1;
      nxt_wr_n   = 1;
      
      if (mcycle[0])
        begin
	  if (tstate[1] || tstate[2])
            begin
	      nxt_rd_n = ~ intcycle_n;
	      nxt_mreq_n = ~ intcycle_n;
	      nxt_iorq_n = intcycle_n;
	    end
        end // if (mcycle[0])          
      else
        begin
	  if ((tstate[1] || tstate[2]) && !no_read && !write)
            begin
	      nxt_rd_n = 1'b0;
	      nxt_iorq_n = ~ iorq;
	      nxt_mreq_n = iorq;
	    end
	  if (T2Write == 0)
            begin                          
	      if (tstate[2] && write)
                begin
		  nxt_wr_n = 1'b0;
		  nxt_iorq_n = ~ iorq;
		  nxt_mreq_n = iorq;
                end
            end
	  else
            begin
	      if ((tstate[1] || (tstate[2] && !wait_n)) && write)
                begin
		  nxt_wr_n = 1'b0;
		  nxt_iorq_n = ~ iorq;
		  nxt_mreq_n = iorq;
		end
	    end // else: !if(T2write == 0)          
	end // else: !if(mcycle[0])
    end // always @ *

  always @(negedge clk)
    begin
      if (!reset_n)
        begin
	  rd_n   <= #1 1'b1;
	  wr_n   <= #1 1'b1;
	  iorq_n <= #1 1'b1;
	  mreq_n <= #1 1'b1;
        end
      else
        begin
	  rd_n <= #1 nxt_rd_n;
	  wr_n <= #1 nxt_wr_n;
	  iorq_n <= #1 nxt_iorq_n;
	  mreq_n <= #1 nxt_mreq_n;
	end // else: !if(!reset_n)
    end // always @ (posedge clk or negedge reset_n)

  always @(posedge clk)
    begin
      if (!reset_n)
        begin
	  di_reg <= #1 0;
        end
      else
        begin
	  if (tstate[2] && wait_n == 1'b1)
	    di_reg <= #1 di;
	end // else: !if(!reset_n)
    end // always @ (posedge clk)
  
endmodule // t80n



module tv80_reg (/*AUTOARG*/
  // Outputs
  DOBH, DOAL, DOCL, DOBL, DOCH, DOAH, 
  // Inputs
  AddrC, AddrA, AddrB, DIH, DIL, clk, CEN, WEH, WEL
  );
    input  [2:0] AddrC;
    output [7:0] DOBH;
    input  [2:0] AddrA;
    input  [2:0] AddrB;
    input  [7:0] DIH;
    output [7:0] DOAL;
    output [7:0] DOCL;
    input  [7:0] DIL;
    output [7:0] DOBL;
    output [7:0] DOCH;
    output [7:0] DOAH;
    input  clk, CEN, WEH, WEL;

  reg [7:0] RegsH [0:7];
  reg [7:0] RegsL [0:7];

  always @(posedge clk)
    begin
      if (CEN)
        begin
          if (WEH) RegsH[AddrA] <= DIH;
          if (WEL) RegsL[AddrA] <= DIL;
        end
    end
          
  assign DOAH = RegsH[AddrA];
  assign DOAL = RegsL[AddrA];
  assign DOBH = RegsH[AddrB];
  assign DOBL = RegsL[AddrB];
  assign DOCH = RegsH[AddrC];
  assign DOCL = RegsL[AddrC];

  // break out ram bits for waveform debug
  wire [7:0] H = RegsH[2];
  wire [7:0] L = RegsL[2];
  
// synopsys dc_script_begin
// set_attribute current_design "revision" "$Id: tv80_reg.v,v 1.1 2004-05-16 17:39:57 ghutchis Exp $" -type string -quiet
// synopsys dc_script_end
endmodule

module tv80_mcode 
  (/*AUTOARG*/
  // Outputs
  MCycles, TStates, Prefix, Inc_PC, Inc_WZ, IncDec_16, Read_To_Reg, 
  Read_To_Acc, Set_BusA_To, Set_BusB_To, ALU_Op, Save_ALU, PreserveC, 
  Arith16, Set_Addr_To, IORQ, Jump, JumpE, JumpXY, Call, RstP, LDZ, 
  LDW, LDSPHL, Special_LD, ExchangeDH, ExchangeRp, ExchangeAF, 
  ExchangeRS, I_DJNZ, I_CPL, I_CCF, I_SCF, I_RETN, I_BT, I_BC, I_BTR, 
  I_RLD, I_RRD, I_INRC, SetDI, SetEI, IMode, Halt, NoRead, Write, 
  // Inputs
  IR, ISet, MCycle, F, NMICycle, IntCycle
  );
  
  parameter             Mode   = 0;
  parameter             Flag_C = 0;
  parameter             Flag_N = 1;
  parameter             Flag_P = 2;
  parameter             Flag_X = 3;
  parameter             Flag_H = 4;
  parameter             Flag_Y = 5;
  parameter             Flag_Z = 6;
  parameter             Flag_S = 7;

  input [7:0]           IR;
  input [1:0]           ISet                    ;
  input [6:0]           MCycle                  ;
  input [7:0]           F                       ;
  input                 NMICycle                ;
  input                 IntCycle                ;
  output [2:0]          MCycles                 ;
  output [2:0]          TStates                 ;
  output [1:0]          Prefix                  ; // None,BC,ED,DD/FD
  output                Inc_PC                  ;
  output                Inc_WZ                  ;
  output [3:0]          IncDec_16               ; // BC,DE,HL,SP   0 is inc
  output                Read_To_Reg             ;
  output                Read_To_Acc             ;
  output [3:0]          Set_BusA_To     ; // B,C,D,E,H,L,DI/DB,A,SP(L),SP(M),0,F
  output [3:0]          Set_BusB_To     ; // B,C,D,E,H,L,DI,A,SP(L),SP(M),1,F,PC(L),PC(M),0
  output [3:0]          ALU_Op                  ;
  output                Save_ALU                ;
  output                PreserveC               ;
  output                Arith16                 ;
  output [2:0]          Set_Addr_To             ; // aNone,aXY,aIOA,aSP,aBC,aDE,aZI
  output                IORQ                    ;
  output                Jump                    ;
  output                JumpE                   ;
  output                JumpXY                  ;
  output                Call                    ;
  output                RstP                    ;
  output                LDZ                     ;
  output                LDW                     ;
  output                LDSPHL                  ;
  output [2:0]          Special_LD              ; // A,I;A,R;I,A;R,A;None
  output                ExchangeDH              ;
  output                ExchangeRp              ;
  output                ExchangeAF              ;
  output                ExchangeRS              ;
  output                I_DJNZ                  ;
  output                I_CPL                   ;
  output                I_CCF                   ;
  output                I_SCF                   ;
  output                I_RETN                  ;
  output                I_BT                    ;
  output                I_BC                    ;
  output                I_BTR                   ;
  output                I_RLD                   ;
  output                I_RRD                   ;
  output                I_INRC                  ;
  output                SetDI                   ;
  output                SetEI                   ;
  output [1:0]          IMode                   ;
  output                Halt                    ;
  output                NoRead                  ;
  output                Write   ;                

  // regs
  reg [2:0]             MCycles                 ;
  reg [2:0]             TStates                 ;
  reg [1:0]             Prefix                  ; // None,BC,ED,DD/FD
  reg                   Inc_PC                  ;
  reg                   Inc_WZ                  ;
  reg [3:0]             IncDec_16               ; // BC,DE,HL,SP   0 is inc
  reg                   Read_To_Reg             ;
  reg                   Read_To_Acc             ;
  reg [3:0]             Set_BusA_To     ; // B,C,D,E,H,L,DI/DB,A,SP(L),SP(M),0,F
  reg [3:0]             Set_BusB_To     ; // B,C,D,E,H,L,DI,A,SP(L),SP(M),1,F,PC(L),PC(M),0
  reg [3:0]             ALU_Op                  ;
  reg                   Save_ALU                ;
  reg                   PreserveC               ;
  reg                   Arith16                 ;
  reg [2:0]             Set_Addr_To             ; // aNone,aXY,aIOA,aSP,aBC,aDE,aZI
  reg                   IORQ                    ;
  reg                   Jump                    ;
  reg                   JumpE                   ;
  reg                   JumpXY                  ;
  reg                   Call                    ;
  reg                   RstP                    ;
  reg                   LDZ                     ;
  reg                   LDW                     ;
  reg                   LDSPHL                  ;
  reg [2:0]             Special_LD              ; // A,I;A,R;I,A;R,A;None
  reg                   ExchangeDH              ;
  reg                   ExchangeRp              ;
  reg                   ExchangeAF              ;
  reg                   ExchangeRS              ;
  reg                   I_DJNZ                  ;
  reg                   I_CPL                   ;
  reg                   I_CCF                   ;
  reg                   I_SCF                   ;
  reg                   I_RETN                  ;
  reg                   I_BT                    ;
  reg                   I_BC                    ;
  reg                   I_BTR                   ;
  reg                   I_RLD                   ;
  reg                   I_RRD                   ;
  reg                   I_INRC                  ;
  reg                   SetDI                   ;
  reg                   SetEI                   ;
  reg [1:0]             IMode                   ;
  reg                   Halt                    ;
  reg                   NoRead                  ;
  reg                   Write   ;                

  parameter             aNone   = 3'b111;
  parameter             aBC     = 3'b000;
  parameter             aDE     = 3'b001;
  parameter             aXY     = 3'b010;
  parameter             aIOA    = 3'b100;
  parameter             aSP     = 3'b101;
  parameter             aZI     = 3'b110;
  //    constant aNone  : std_logic_vector[2:0] = 3'b000;
  //    constant aXY    : std_logic_vector[2:0] = 3'b001;
  //    constant aIOA   : std_logic_vector[2:0] = 3'b010;
  //    constant aSP    : std_logic_vector[2:0] = 3'b011;
  //    constant aBC    : std_logic_vector[2:0] = 3'b100;
  //    constant aDE    : std_logic_vector[2:0] = 3'b101;
  //    constant aZI    : std_logic_vector[2:0] = 3'b110;

  function is_cc_true;
    input [7:0] F;
    input [2:0] cc;
    begin
      if (Mode == 3 ) 
        begin
          case (cc)
            3'b000  : is_cc_true = F[7] == 1'b0; // NZ
            3'b001  : is_cc_true = F[7] == 1'b1; // Z
            3'b010  : is_cc_true = F[4] == 1'b0; // NC
            3'b011  : is_cc_true = F[4] == 1'b1; // C
            3'b100  : is_cc_true = 0;
            3'b101  : is_cc_true = 0;
            3'b110  : is_cc_true = 0;
            3'b111  : is_cc_true = 0;
          endcase
        end 
      else 
        begin
          case (cc)
            3'b000  : is_cc_true = F[6] == 1'b0; // NZ
            3'b001  : is_cc_true = F[6] == 1'b1; // Z
            3'b010  : is_cc_true = F[0] == 1'b0; // NC
            3'b011  : is_cc_true = F[0] == 1'b1; // C
            3'b100  : is_cc_true = F[2] == 1'b0; // PO
            3'b101  : is_cc_true = F[2] == 1'b1; // PE
            3'b110  : is_cc_true = F[7] == 1'b0; // P
            3'b111  : is_cc_true = F[7] == 1'b1; // M
          endcase
        end
    end
  endfunction // is_cc_true
  

  reg [2:0] DDD;
  reg [2:0] SSS;
  reg [1:0] DPAIR;
  
  always @ (/*AUTOSENSE*/F or IR or ISet or IntCycle or MCycle
            or NMICycle)
    begin
      DDD = IR[5:3];
      SSS = IR[2:0];
      DPAIR = IR[5:4];

      MCycles = 3'b001;
      if (MCycle[0] ) 
        begin
          TStates = 3'b100;
        end 
      else 
        begin
          TStates = 3'b011;
        end
      Prefix = 2'b00;
      Inc_PC = 1'b0;
      Inc_WZ = 1'b0;
      IncDec_16 = 4'b0000;
      Read_To_Acc = 1'b0;
      Read_To_Reg = 1'b0;
      Set_BusB_To = 4'b0000;
      Set_BusA_To = 4'b0000;
      ALU_Op = { 1'b0, IR[5:3] };
      Save_ALU = 1'b0;
      PreserveC = 1'b0;
      Arith16 = 1'b0;
      IORQ = 1'b0;
      Set_Addr_To = aNone;
      Jump = 1'b0;
      JumpE = 1'b0;
      JumpXY = 1'b0;
      Call = 1'b0;
      RstP = 1'b0;
      LDZ = 1'b0;
      LDW = 1'b0;
      LDSPHL = 1'b0;
      Special_LD = 3'b000;
      ExchangeDH = 1'b0;
      ExchangeRp = 1'b0;
      ExchangeAF = 1'b0;
      ExchangeRS = 1'b0;
      I_DJNZ = 1'b0;
      I_CPL = 1'b0;
      I_CCF = 1'b0;
      I_SCF = 1'b0;
      I_RETN = 1'b0;
      I_BT = 1'b0;
      I_BC = 1'b0;
      I_BTR = 1'b0;
      I_RLD = 1'b0;
      I_RRD = 1'b0;
      I_INRC = 1'b0;
      SetDI = 1'b0;
      SetEI = 1'b0;
      IMode = 2'b11;
      Halt = 1'b0;
      NoRead = 1'b0;
      Write = 1'b0;
      
      case (ISet)
        2'b00  :
          begin

            //----------------------------------------------------------------------------
            //
            //  Unprefixed instructions
            //
            //----------------------------------------------------------------------------

            casex (IR)
              // 8 BIT LOAD GROUP
              8'b01xxxxxx :
                begin
                  if (IR[5:0] == 6'b110110)
                    Halt = 1'b1;
                  else if (IR[2:0] == 3'b110)
                    begin
                      // LD r,(HL)
                      MCycles = 3'b010;
                      if (MCycle[0])
                        Set_Addr_To = aXY;
                      if (MCycle[1])
                        begin
                          Set_BusA_To[2:0] = DDD;
                          Read_To_Reg = 1'b1;
                        end
                    end // if (IR[2:0] == 3'b110)
                  else if (IR[5:3] == 3'b110)
                    begin
                      // LD (HL),r
                      MCycles = 3'b010;
                      if (MCycle[0])
                        begin
                          Set_Addr_To = aXY;
                          Set_BusB_To[2:0] = SSS;
                          Set_BusB_To[3] = 1'b0;
                        end
                      if (MCycle[1])
                        Write = 1'b1;
                    end // if (IR[5:3] == 3'b110)
                  else
                    begin
                      Set_BusB_To[2:0] = SSS;
                      ExchangeRp = 1'b1;
                      Set_BusA_To[2:0] = DDD;
                      Read_To_Reg = 1'b1;
                    end // else: !if(IR[5:3] == 3'b110)
                end // case: 8'b01xxxxxx                                    

              8'b00xxx110 :
                begin
                  if (IR[5:3] == 3'b110)
                    begin
                      // LD (HL),n
                      MCycles = 3'b011;
                      if (MCycle[1])
                        begin
                          Inc_PC = 1'b1;
                          Set_Addr_To = aXY;
                          Set_BusB_To[2:0] = SSS;
                          Set_BusB_To[3] = 1'b0;
                        end
                      if (MCycle[2])
                        Write = 1'b1;
                    end // if (IR[5:3] == 3'b110)
                  else
                    begin
                      // LD r,n
                      MCycles = 3'b010;
                      if (MCycle[1])
                        begin
                          Inc_PC = 1'b1;
                          Set_BusA_To[2:0] = DDD;
                          Read_To_Reg = 1'b1;
                        end
                    end
                end
              
              8'b00001010  :
                begin
                  // LD A,(BC)
                  MCycles = 3'b010;
                  if (MCycle[0])
                    Set_Addr_To = aBC;
                  if (MCycle[1])
                    Read_To_Acc = 1'b1;
                end // case: 8'b00001010
              
              8'b00011010  :
                begin
                  // LD A,(DE)
                  MCycles = 3'b010;
                  if (MCycle[0])
                    Set_Addr_To = aDE;
                  if (MCycle[1])
                    Read_To_Acc = 1'b1;
                end // case: 8'b00011010
              
              8'b00111010  :
                begin
                  if (Mode == 3 ) 
                    begin
                      // LDD A,(HL)
                      MCycles = 3'b010;
                      if (MCycle[0])
                        Set_Addr_To = aXY;
                      if (MCycle[1])
                        begin
                          Read_To_Acc = 1'b1;
                          IncDec_16 = 4'b1110;
                        end
                    end 
                  else 
                    begin
                      // LD A,(nn)
                      MCycles = 3'b100;
                      if (MCycle[1])
                        begin
                          Inc_PC = 1'b1;
                          LDZ = 1'b1;
                        end
                      if (MCycle[2])
                        begin
                          Set_Addr_To = aZI;
                          Inc_PC = 1'b1;
                        end
                      if (MCycle[3])
                        begin
                          Read_To_Acc = 1'b1;
                        end
                    end // else: !if(Mode == 3 )
                end // case: 8'b00111010
              
              8'b00000010  :
                begin
                  // LD (BC),A
                  MCycles = 3'b010;
                  if (MCycle[0])
                    begin
                      Set_Addr_To = aBC;
                      Set_BusB_To = 4'b0111;
                    end
                  if (MCycle[1])
                    begin
                      Write = 1'b1;
                    end
                end // case: 8'b00000010
              
              8'b00010010  :
                begin
                  // LD (DE),A
                  MCycles = 3'b010;
                  case (1'b1) // MCycle
                    MCycle[0] :
                      begin
                        Set_Addr_To = aDE;
                        Set_BusB_To = 4'b0111;
                      end
                    MCycle[1] :
                      Write = 1'b1;
                    default :;
                  endcase // case(MCycle)
                end // case: 8'b00010010
              
              8'b00110010  :
                begin
                  if (Mode == 3 ) 
                    begin
                      // LDD (HL),A
                      MCycles = 3'b010;
                      case (1'b1) // MCycle
                        MCycle[0] :
                          begin
                            Set_Addr_To = aXY;
                            Set_BusB_To = 4'b0111;
                          end
                        MCycle[1] :
                          begin
                            Write = 1'b1;
                            IncDec_16 = 4'b1110;
                          end
                        default :;
                      endcase // case(MCycle)
                      
                    end 
                  else 
                    begin
                      // LD (nn),A
                      MCycles = 3'b100;
                      case (1'b1) // MCycle
                        MCycle[1] :
                          begin
                            Inc_PC = 1'b1;
                            LDZ = 1'b1;
                          end
                        MCycle[2] :
                          begin
                            Set_Addr_To = aZI;
                            Inc_PC = 1'b1;
                            Set_BusB_To = 4'b0111;
                          end
                        MCycle[3] :
                          begin
                            Write = 1'b1;
                          end
                        default :;
                      endcase
                    end // else: !if(Mode == 3 )
                end // case: 8'b00110010
              

              // 16 BIT LOAD GROUP
              8'b00000001,8'b00010001,8'b00100001,8'b00110001  :
                begin
                  // LD dd,nn
                  MCycles = 3'b011;
                  case (1'b1) // MCycle
                    MCycle[1] :
                      begin
                        Inc_PC = 1'b1;
                        Read_To_Reg = 1'b1;
                        if (DPAIR == 2'b11 ) 
                          begin
                            Set_BusA_To[3:0] = 4'b1000;
                          end 
                        else 
                          begin
                            Set_BusA_To[2:1] = DPAIR;
                            Set_BusA_To[0] = 1'b1;
                          end
                      end // case: 2
                    
                    MCycle[2] :
                      begin
                        Inc_PC = 1'b1;
                        Read_To_Reg = 1'b1;
                        if (DPAIR == 2'b11 ) 
                          begin
                            Set_BusA_To[3:0] = 4'b1001;
                          end 
                        else 
                          begin
                            Set_BusA_To[2:1] = DPAIR;
                            Set_BusA_To[0] = 1'b0;
                          end
                      end // case: 3
                    
                    default :;
                  endcase // case(MCycle)
                end // case: 8'b00000001,8'b00010001,8'b00100001,8'b00110001
              
              8'b00101010  :
                begin
                  if (Mode == 3 ) 
                    begin
                      // LDI A,(HL)
                      MCycles = 3'b010;
                      case (1'b1) // MCycle
                        MCycle[0] :
                          Set_Addr_To = aXY;
                        MCycle[1] :
                          begin
                            Read_To_Acc = 1'b1;
                            IncDec_16 = 4'b0110;
                          end
                        
                        default :;
                      endcase
                    end 
                  else 
                    begin
                      // LD HL,(nn)
                      MCycles = 3'b101;
                      case (1'b1) // MCycle
                        MCycle[1] :
                          begin
                            Inc_PC = 1'b1;
                            LDZ = 1'b1;
                          end
                        MCycle[2] :
                          begin
                            Set_Addr_To = aZI;
                            Inc_PC = 1'b1;
                            LDW = 1'b1;
                          end
                        MCycle[3] :
                          begin
                            Set_BusA_To[2:0] = 3'b101; // L
                            Read_To_Reg = 1'b1;
                            Inc_WZ = 1'b1;
                            Set_Addr_To = aZI;
                          end
                        MCycle[4] :
                          begin
                            Set_BusA_To[2:0] = 3'b100; // H
                            Read_To_Reg = 1'b1;
                          end
                        default :;
                      endcase
                    end // else: !if(Mode == 3 )
                end // case: 8'b00101010
              
              8'b00100010  :
                begin
                  if (Mode == 3 ) 
                    begin
                      // LDI (HL),A
                      MCycles = 3'b010;
                      case (1'b1) // MCycle
                        MCycle[0] :
                          begin
                            Set_Addr_To = aXY;
                            Set_BusB_To = 4'b0111;
                          end
                        MCycle[1] :
                          begin
                            Write = 1'b1;
                            IncDec_16 = 4'b0110;
                          end
                        default :;
                      endcase
                    end 
                  else 
                    begin
                      // LD (nn),HL
                      MCycles = 3'b101;
                      case (1'b1) // MCycle                        
                        MCycle[1] :
                          begin
                            Inc_PC = 1'b1;
                            LDZ = 1'b1;
                          end
                        
                        MCycle[2] :
                          begin
                            Set_Addr_To = aZI;
                            Inc_PC = 1'b1;
                            LDW = 1'b1;
                            Set_BusB_To = 4'b0101; // L
                          end
                        
                        MCycle[3] :
                          begin
                            Inc_WZ = 1'b1;
                            Set_Addr_To = aZI;
                            Write = 1'b1;
                            Set_BusB_To = 4'b0100; // H
                          end
                        MCycle[4] :                          
                          Write = 1'b1;
                        default :;
                      endcase
                    end // else: !if(Mode == 3 )
                end // case: 8'b00100010
              
              8'b11111001  :
                begin
                  // LD SP,HL
                  TStates = 3'b110;
                  LDSPHL = 1'b1;
                end
              
              8'b11xx0101 :
                begin
                  // PUSH qq
                  MCycles = 3'b011;
                  case (1'b1) // MCycle                    
                    MCycle[0] :
                      begin
                        TStates = 3'b101;
                        IncDec_16 = 4'b1111;
                        Set_Addr_To = aSP;
                        if (DPAIR == 2'b11 ) 
                          begin
                            Set_BusB_To = 4'b0111;
                          end 
                        else
                          begin
                            Set_BusB_To[2:1] = DPAIR;
                            Set_BusB_To[0] = 1'b0;
                            Set_BusB_To[3] = 1'b0;
                          end
                      end // case: 1
                    
                    MCycle[1] :
                      begin
                        IncDec_16 = 4'b1111;
                        Set_Addr_To = aSP;
                        if (DPAIR == 2'b11 ) 
                          begin
                            Set_BusB_To = 4'b1011;
                          end 
                        else 
                          begin
                            Set_BusB_To[2:1] = DPAIR;
                            Set_BusB_To[0] = 1'b1;
                            Set_BusB_To[3] = 1'b0;
                          end
                        Write = 1'b1;
                      end // case: 2
                    
                    MCycle[2] :
                      Write = 1'b1;
                    default :;
                  endcase // case(MCycle)
                end // case: 8'b11000101,8'b11010101,8'b11100101,8'b11110101
              
              8'b11xx0001 :
                begin
                  // POP qq
                  MCycles = 3'b011;
                  case (1'b1) // MCycle
                    MCycle[0] :
                      Set_Addr_To = aSP;
                    MCycle[1] :
                      begin
                        IncDec_16 = 4'b0111;
                        Set_Addr_To = aSP;
                        Read_To_Reg = 1'b1;
                        if (DPAIR == 2'b11 ) 
                          begin
                            Set_BusA_To[3:0] = 4'b1011;
                          end 
                        else 
                          begin
                            Set_BusA_To[2:1] = DPAIR;
                            Set_BusA_To[0] = 1'b1;
                          end
                      end // case: 2
                    
                    MCycle[2] :
                      begin
                        IncDec_16 = 4'b0111;
                        Read_To_Reg = 1'b1;
                        if (DPAIR == 2'b11 ) 
                          begin
                            Set_BusA_To[3:0] = 4'b0111;
                          end 
                        else 
                          begin
                            Set_BusA_To[2:1] = DPAIR;
                            Set_BusA_To[0] = 1'b0;
                          end
                      end // case: 3
                    
                    default :;
                  endcase // case(MCycle)
                end // case: 8'b11000001,8'b11010001,8'b11100001,8'b11110001
              

              // EXCHANGE, BLOCK TRANSFER AND SEARCH GROUP
              8'b11101011  :
                begin
                  if (Mode != 3 ) 
                    begin
                      // EX DE,HL
                      ExchangeDH = 1'b1;
                    end
                end
              
              8'b00001000  :
                begin
                  if (Mode == 3 ) 
                    begin
                      // LD (nn),SP
                      MCycles = 3'b101;
                      case (1'b1) // MCycle
                        MCycle[1] :
                          begin
                            Inc_PC = 1'b1;
                            LDZ = 1'b1;
                          end
                        
                        MCycle[2] :
                          begin
                            Set_Addr_To = aZI;
                            Inc_PC = 1'b1;
                            LDW = 1'b1;
                            Set_BusB_To = 4'b1000;
                          end
                        
                        MCycle[3] :
                          begin
                            Inc_WZ = 1'b1;
                            Set_Addr_To = aZI;
                            Write = 1'b1;
                            Set_BusB_To = 4'b1001;
                          end
                        
                        MCycle[4] :
                          Write = 1'b1;
                        default :;
                      endcase
                    end 
                  else if (Mode < 2 ) 
                    begin
                      // EX AF,AF'
                      ExchangeAF = 1'b1;
                    end
                end // case: 8'b00001000
              
              8'b11011001  :
                begin
                  if (Mode == 3 ) 
                    begin
                      // RETI
                      MCycles = 3'b011;
                      case (1'b1) // MCycle
                        MCycle[0] :
                          Set_Addr_To = aSP;
                        MCycle[1] :
                          begin
                            IncDec_16 = 4'b0111;
                            Set_Addr_To = aSP;
                            LDZ = 1'b1;
                          end
                        
                        MCycle[2] :
                          begin
                            Jump = 1'b1;
                            IncDec_16 = 4'b0111;
                            I_RETN = 1'b1;
                            SetEI = 1'b1;
                          end
                        default :;
                      endcase
                    end 
                  else if (Mode < 2 ) 
                    begin
                      // EXX
                      ExchangeRS = 1'b1;
                    end
                end // case: 8'b11011001
              
              8'b11100011  :
                begin
                  if (Mode != 3 ) 
                    begin
                      // EX (SP),HL
                      MCycles = 3'b101;
                      case (1'b1) // MCycle
                        MCycle[0] :
                          Set_Addr_To = aSP;
                        MCycle[1] :
                          begin
                            Read_To_Reg = 1'b1;
                            Set_BusA_To = 4'b0101;
                            Set_BusB_To = 4'b0101;
                            Set_Addr_To = aSP;
                          end
                        MCycle[2] :
                          begin
                            IncDec_16 = 4'b0111;
                            Set_Addr_To = aSP;
                            TStates = 3'b100;
                            Write = 1'b1;
                          end
                        MCycle[3] :
                          begin
                            Read_To_Reg = 1'b1;
                            Set_BusA_To = 4'b0100;
                            Set_BusB_To = 4'b0100;
                            Set_Addr_To = aSP;
                          end
                        MCycle[4] :
                          begin
                            IncDec_16 = 4'b1111;
                            TStates = 3'b101;
                            Write = 1'b1;
                          end
                        
                        default :;
                      endcase
                    end // if (Mode != 3 )
                end // case: 8'b11100011
              

              // 8 BIT ARITHMETIC AND LOGICAL GROUP
              8'b10xxxxxx :
                begin
                  if (IR[2:0] == 3'b110)
                    begin
                      // ADD A,(HL)
                      // ADC A,(HL)
                      // SUB A,(HL)
                      // SBC A,(HL)
                      // AND A,(HL)
                      // OR A,(HL)
                      // XOR A,(HL)
                      // CP A,(HL)
                      MCycles = 3'b010;
                      case (1'b1) // MCycle
                        MCycle[0] :
                          Set_Addr_To = aXY;
                        MCycle[1] :
                          begin
                            Read_To_Reg = 1'b1;
                            Save_ALU = 1'b1;
                            Set_BusB_To[2:0] = SSS;
                            Set_BusA_To[2:0] = 3'b111;
                          end
                        
                        default :;
                      endcase // case(MCycle)
                    end // if (IR[2:0] == 3'b110)
                  else
                    begin
                      // ADD A,r
                      // ADC A,r
                      // SUB A,r
                      // SBC A,r
                      // AND A,r
                      // OR A,r
                      // XOR A,r
                      // CP A,r
                      Set_BusB_To[2:0] = SSS;
                      Set_BusA_To[2:0] = 3'b111;
                      Read_To_Reg = 1'b1;
                      Save_ALU = 1'b1;
                    end // else: !if(IR[2:0] == 3'b110)                  
                end // case: 8'b10000000,8'b10000001,8'b10000010,8'b10000011,8'b10000100,8'b10000101,8'b10000111,...
              
              8'b11xxx110 :
                begin
                  // ADD A,n
                  // ADC A,n
                  // SUB A,n
                  // SBC A,n
                  // AND A,n
                  // OR A,n
                  // XOR A,n
                  // CP A,n
                  MCycles = 3'b010;
                  if (MCycle[1] ) 
                    begin
                      Inc_PC = 1'b1;
                      Read_To_Reg = 1'b1;
                      Save_ALU = 1'b1;
                      Set_BusB_To[2:0] = SSS;
                      Set_BusA_To[2:0] = 3'b111;
                    end
                end
              
              8'b00xxx100 :
                begin
                  if (IR[5:3] == 3'b110)
                    begin
                      // INC (HL)
                      MCycles = 3'b011;
                      case (1'b1) // MCycle
                        MCycle[0] :
                          Set_Addr_To = aXY;
                        MCycle[1] :
                          begin
                            TStates = 3'b100;
                            Set_Addr_To = aXY;
                            Read_To_Reg = 1'b1;
                            Save_ALU = 1'b1;
                            PreserveC = 1'b1;
                            ALU_Op = 4'b0000;
                            Set_BusB_To = 4'b1010;
                            Set_BusA_To[2:0] = DDD;
                          end // case: 2
                        
                        MCycle[2] :
                          Write = 1'b1;
                        default :;
                      endcase // case(MCycle)
                    end // case: 8'b00110100
                  else
                    begin
                      // INC r
                      Set_BusB_To = 4'b1010;
                      Set_BusA_To[2:0] = DDD;
                      Read_To_Reg = 1'b1;
                      Save_ALU = 1'b1;
                      PreserveC = 1'b1;
                      ALU_Op = 4'b0000;
                    end
                end
              
              8'b00xxx101 :
                begin               
                  if (IR[5:3] == 3'b110)
                    begin
                      // DEC (HL)
                      MCycles = 3'b011;
                      case (1'b1) // MCycle
                        MCycle[0] :
                          Set_Addr_To = aXY;
                        MCycle[1] :
                          begin
                            TStates = 3'b100;
                            Set_Addr_To = aXY;
                            ALU_Op = 4'b0010;
                            Read_To_Reg = 1'b1;
                            Save_ALU = 1'b1;
                            PreserveC = 1'b1;
                            Set_BusB_To = 4'b1010;
                            Set_BusA_To[2:0] = DDD;
                          end // case: 2
                        
                        MCycle[2] :
                          Write = 1'b1;
                        default :;
                      endcase // case(MCycle)
                    end
                  else
                    begin
                      // DEC r
                      Set_BusB_To = 4'b1010;
                      Set_BusA_To[2:0] = DDD;
                      Read_To_Reg = 1'b1;
                      Save_ALU = 1'b1;
                      PreserveC = 1'b1;
                      ALU_Op = 4'b0010;
                    end
                end
              
              // GENERAL PURPOSE ARITHMETIC AND CPU CONTROL GROUPS
              8'b00100111  :
                begin
                  // DAA
                  Set_BusA_To[2:0] = 3'b111;
                  Read_To_Reg = 1'b1;
                  ALU_Op = 4'b1100;
                  Save_ALU = 1'b1;
                end
              
              8'b00101111  :
                // CPL
                I_CPL = 1'b1;
              
              8'b00111111  :
                // CCF
                I_CCF = 1'b1;
              
              8'b00110111  :
                // SCF
                I_SCF = 1'b1;
              
              8'b00000000  :
                begin
                  if (NMICycle == 1'b1 ) 
                    begin
                      // NMI
                      MCycles = 3'b011;
                      case (1'b1) // MCycle
                        MCycle[0] :
                          begin
                            TStates = 3'b101;
                            IncDec_16 = 4'b1111;
                            Set_Addr_To = aSP;
                            Set_BusB_To = 4'b1101;
                          end
                        
                        MCycle[1] :
                          begin
                            TStates = 3'b100;
                            Write = 1'b1;
                            IncDec_16 = 4'b1111;
                            Set_Addr_To = aSP;
                            Set_BusB_To = 4'b1100;
                          end
                        
                        MCycle[2] :
                          begin
                            TStates = 3'b100;
                            Write = 1'b1;
                          end
                        
                        default :;
                      endcase // case(MCycle)
                      
                    end 
                  else if (IntCycle == 1'b1 ) 
                    begin
                      // INT (IM 2)
                      MCycles = 3'b101;
                      case (1'b1) // MCycle
                        MCycle[0] :
                          begin
                            LDZ = 1'b1;
                            TStates = 3'b101;
                            IncDec_16 = 4'b1111;
                            Set_Addr_To = aSP;
                            Set_BusB_To = 4'b1101;
                          end
                        
                        MCycle[1] :
                          begin
                            TStates = 3'b100;
                            Write = 1'b1;
                            IncDec_16 = 4'b1111;
                            Set_Addr_To = aSP;
                            Set_BusB_To = 4'b1100;
                          end
                        
                        MCycle[2] :
                          begin
                            TStates = 3'b100;
                            Write = 1'b1;
                          end
                        
                        MCycle[3] :
                          begin
                            Inc_PC = 1'b1;
                            LDZ = 1'b1;
                          end
                        
                        MCycle[4] :
                          Jump = 1'b1;
                        default :;
                      endcase
                    end
                end // case: 8'b00000000
              
              8'b11110011  :
                // DI
                SetDI = 1'b1;
              
              8'b11111011  :
                // EI
                SetEI = 1'b1;

              // 16 BIT ARITHMETIC GROUP
              8'b00xx1001  :
                begin
                  // ADD HL,ss
                  MCycles = 3'b011;
                  case (1'b1) // MCycle
                    MCycle[1] :
                      begin
                        NoRead = 1'b1;
                        ALU_Op = 4'b0000;
                        Read_To_Reg = 1'b1;
                        Save_ALU = 1'b1;
                        Set_BusA_To[2:0] = 3'b101;
                        case (IR[5:4])
                          0,1,2  :
                            begin
                              Set_BusB_To[2:1] = IR[5:4];
                              Set_BusB_To[0] = 1'b1;
                            end
                          
                          default :
                            Set_BusB_To = 4'b1000;
                        endcase // case(IR[5:4])
                        
                        TStates = 3'b100;
                        Arith16 = 1'b1;
                      end // case: 2
                    
                    MCycle[2] :
                      begin
                        NoRead = 1'b1;
                        Read_To_Reg = 1'b1;
                        Save_ALU = 1'b1;
                        ALU_Op = 4'b0001;
                        Set_BusA_To[2:0] = 3'b100;
                        case (IR[5:4])
                          0,1,2  :
                            Set_BusB_To[2:1] = IR[5:4];
                          default :
                            Set_BusB_To = 4'b1001;
                        endcase
                        Arith16 = 1'b1;
                      end // case: 3
                    
                    default :;
                  endcase // case(MCycle)
                end // case: 8'b00001001,8'b00011001,8'b00101001,8'b00111001              
              
              8'b00xx0011 :
                begin
                  // INC ss
                  TStates = 3'b110;
                  IncDec_16[3:2] = 2'b01;
                  IncDec_16[1:0] = DPAIR;
                end
              
              8'b00xx1011 :
                begin
                  // DEC ss
                  TStates = 3'b110;
                  IncDec_16[3:2] = 2'b11;
                  IncDec_16[1:0] = DPAIR;
                end

              // ROTATE AND SHIFT GROUP
              8'b00000111,
                  // RLCA
                  8'b00010111,
                  // RLA
                  8'b00001111,
                  // RRCA
                  8'b00011111 :
                    // RRA
                    begin
                      Set_BusA_To[2:0] = 3'b111;
                      ALU_Op = 4'b1000;
                      Read_To_Reg = 1'b1;
                      Save_ALU = 1'b1;
                    end // case: 8'b00000111,...
              

              // JUMP GROUP
              8'b11000011  :
                begin
                  // JP nn
                  MCycles = 3'b011;
                  if (MCycle[1])
                    begin
                      Inc_PC = 1'b1;
                      LDZ = 1'b1;
                    end
                  
                  if (MCycle[2])
                    begin
                      Inc_PC = 1'b1;
                      Jump = 1'b1;
                    end
                  
                end // case: 8'b11000011
              
              8'b11xxx010  :
                begin
                  if (IR[5] == 1'b1 && Mode == 3 ) 
                    begin
                      case (IR[4:3])
                        2'b00  :
                          begin
                            // LD ($FF00+C),A
                            MCycles = 3'b010;
                            case (1'b1) // MCycle
                              MCycle[0] :
                                begin
                                  Set_Addr_To = aBC;
                                  Set_BusB_To   = 4'b0111;
                                end
                              MCycle[1] :
                                begin
                                  Write = 1'b1;
                                  IORQ = 1'b1;
                                end
                              
                              default :;
                            endcase // case(MCycle)
                          end // case: 2'b00
                        
                        2'b01  :
                          begin
                            // LD (nn),A
                            MCycles = 3'b100;
                            case (1'b1) // MCycle
                              MCycle[1] :
                                begin
                                  Inc_PC = 1'b1;
                                  LDZ = 1'b1;
                                end
                              
                              MCycle[2] :
                                begin
                                  Set_Addr_To = aZI;
                                  Inc_PC = 1'b1;
                                  Set_BusB_To = 4'b0111;
                                end
                              
                              MCycle[3] :
                                Write = 1'b1;
                              default :;
                            endcase // case(MCycle)
                          end // case: default :...
                        
                        2'b10  :
                          begin
                            // LD A,($FF00+C)
                            MCycles = 3'b010;
                            case (1'b1) // MCycle
                              MCycle[0] :
                                Set_Addr_To = aBC;
                              MCycle[1] :
                                begin
                                  Read_To_Acc = 1'b1;
                                  IORQ = 1'b1;
                                end
                              default :;
                            endcase // case(MCycle)
                          end // case: 2'b10
                        
                        2'b11  :
                          begin
                            // LD A,(nn)
                            MCycles = 3'b100;
                            case (1'b1) // MCycle
                              MCycle[1] :
                                begin
                                  Inc_PC = 1'b1;
                                  LDZ = 1'b1;
                                end
                              MCycle[2] :
                                begin
                                  Set_Addr_To = aZI;
                                  Inc_PC = 1'b1;
                                end
                              MCycle[3] :
                                Read_To_Acc = 1'b1;
                              default :;
                            endcase // case(MCycle)
                          end
                      endcase
                    end 
                  else 
                    begin
                      // JP cc,nn
                      MCycles = 3'b011;
                      case (1'b1) // MCycle
                        MCycle[1] :
                          begin
                            Inc_PC = 1'b1;
                            LDZ = 1'b1;
                          end
                        MCycle[2] :
                          begin
                            Inc_PC = 1'b1;
                            if (is_cc_true(F, IR[5:3]) ) 
                              begin
                                Jump = 1'b1;
                              end
                          end
                        
                        default :;
                      endcase
                    end // else: !if(DPAIR == 2'b11 )
                end // case: 8'b11000010,8'b11001010,8'b11010010,8'b11011010,8'b11100010,8'b11101010,8'b11110010,8'b11111010
              
              8'b00011000  :
                begin
                  if (Mode != 2 ) 
                    begin
                      // JR e
                      MCycles = 3'b011;
                      case (1'b1) // MCycle
                        MCycle[1] :
                          Inc_PC = 1'b1;
                        MCycle[2] :
                          begin
                            NoRead = 1'b1;
                            JumpE = 1'b1;
                            TStates = 3'b101;
                          end
                        default :;
                      endcase
                    end // if (Mode != 2 )
                end // case: 8'b00011000

              // Conditional relative jumps (JR [C/NC/Z/NZ], e)
              8'b001xx000  :
                begin
                  if (Mode != 2 ) 
                    begin
                      MCycles = 3'd3;
                      case (1'b1) // MCycle
                        MCycle[1] :
                          begin
                            Inc_PC = 1'b1;

                            case (IR[4:3])
                              0 : MCycles = (F[Flag_Z]) ? 3'd2 : 3'd3;
                              1 : MCycles = (!F[Flag_Z]) ? 3'd2 : 3'd3;
                              2 : MCycles = (F[Flag_C]) ? 3'd2 : 3'd3;
                              3 : MCycles = (!F[Flag_C]) ? 3'd2 : 3'd3;
                            endcase
                          end
                        
                        MCycle[2] :
                          begin
                            NoRead = 1'b1;
                            JumpE = 1'b1;
                            TStates = 3'd5;
                          end
                        default :;
                      endcase
                    end // if (Mode != 2 )
                end // case: 8'b00111000              
              
              8'b11101001  :
                // JP (HL)
                JumpXY = 1'b1;
              
              8'b00010000  :
                begin
                  if (Mode == 3 ) 
                    begin
                      I_DJNZ = 1'b1;
                    end 
                  else if (Mode < 2 ) 
                    begin
                      // DJNZ,e
                      MCycles = 3'b011;
                      case (1'b1) // MCycle
                        MCycle[0] :
                          begin
                            TStates = 3'b101;
                            I_DJNZ = 1'b1;
                            Set_BusB_To = 4'b1010;
                            Set_BusA_To[2:0] = 3'b000;
                            Read_To_Reg = 1'b1;
                            Save_ALU = 1'b1;
                            ALU_Op = 4'b0010;
                          end
                        MCycle[1] :
                          begin
                            I_DJNZ = 1'b1;
                            Inc_PC = 1'b1;
                          end
                        MCycle[2] :
                          begin
                            NoRead = 1'b1;
                            JumpE = 1'b1;
                            TStates = 3'b101;
                          end
                        default :;
                      endcase
                    end // if (Mode < 2 )
                end // case: 8'b00010000
              

              // CALL AND RETURN GROUP
              8'b11001101  :
                begin
                  // CALL nn
                  MCycles = 3'b101;
                  case (1'b1) // MCycle
                    MCycle[1] :
                      begin
                        Inc_PC = 1'b1;
                        LDZ = 1'b1;
                      end
                    MCycle[2] :
                      begin
                        IncDec_16 = 4'b1111;
                        Inc_PC = 1'b1;
                        TStates = 3'b100;
                        Set_Addr_To = aSP;
                        LDW = 1'b1;
                        Set_BusB_To = 4'b1101;
                      end
                    MCycle[3] :
                      begin
                        Write = 1'b1;
                        IncDec_16 = 4'b1111;
                        Set_Addr_To = aSP;
                        Set_BusB_To = 4'b1100;
                      end
                    MCycle[4] :
                      begin
                        Write = 1'b1;
                        Call = 1'b1;
                      end
                    default :;
                  endcase // case(MCycle)
                end // case: 8'b11001101
              
              8'b11xxx100  :
                begin
                  if (IR[5] == 1'b0 || Mode != 3 ) 
                    begin
                      // CALL cc,nn
                      MCycles = 3'b101;
                      case (1'b1) // MCycle
                        MCycle[1] :
                          begin
                            Inc_PC = 1'b1;
                            LDZ = 1'b1;
                          end
                        MCycle[2] :
                          begin
                            Inc_PC = 1'b1;
                            LDW = 1'b1;
                            if (is_cc_true(F, IR[5:3]) ) 
                              begin
                                IncDec_16 = 4'b1111;
                                Set_Addr_To = aSP;
                                TStates = 3'b100;
                                Set_BusB_To = 4'b1101;
                              end 
                            else 
                              begin
                                MCycles = 3'b011;
                              end // else: !if(is_cc_true(F, IR[5:3]) )
                          end // case: 3
                        
                        MCycle[3] :
                          begin
                            Write = 1'b1;
                            IncDec_16 = 4'b1111;
                            Set_Addr_To = aSP;
                            Set_BusB_To = 4'b1100;
                          end
                        
                        MCycle[4] :
                          begin
                            Write = 1'b1;
                            Call = 1'b1;
                          end
                        
                        default :;
                      endcase
                    end // if (IR[5] == 1'b0 || Mode != 3 )
                end // case: 8'b11000100,8'b11001100,8'b11010100,8'b11011100,8'b11100100,8'b11101100,8'b11110100,8'b11111100
              
              8'b11001001  :
                begin
                  // RET
                  MCycles = 3'b011;
                  case (1'b1) // MCycle
                    MCycle[0] :
                      begin
                        TStates = 3'b101;
                        Set_Addr_To = aSP;
                      end
                    
                    MCycle[1] :
                      begin
                        IncDec_16 = 4'b0111;
                        Set_Addr_To = aSP;
                        LDZ = 1'b1;
                      end
                    
                    MCycle[2] :
                      begin
                        Jump = 1'b1;
                        IncDec_16 = 4'b0111;
                      end
                    
                    default :;
                  endcase // case(MCycle)
                end // case: 8'b11001001
              
              8'b11000000,8'b11001000,8'b11010000,8'b11011000,8'b11100000,8'b11101000,8'b11110000,8'b11111000  :
                begin                  
                  if (IR[5] == 1'b1 && Mode == 3 ) 
                    begin
                      case (IR[4:3])
                        2'b00  :
                          begin
                            // LD ($FF00+nn),A
                            MCycles = 3'b011;
                            case (1'b1) // MCycle
                              MCycle[1] :
                                begin
                                  Inc_PC = 1'b1;
                                  Set_Addr_To = aIOA;
                                  Set_BusB_To   = 4'b0111;
                                end
                              
                              MCycle[2] :
                                Write = 1'b1;
                              default :;
                            endcase // case(MCycle)
                          end // case: 2'b00
                        
                        2'b01  :
                          begin
                            // ADD SP,n
                            MCycles = 3'b011;
                            case (1'b1) // MCycle
                              MCycle[1] :
                                begin
                                  ALU_Op = 4'b0000;
                                  Inc_PC = 1'b1;
                                  Read_To_Reg = 1'b1;
                                  Save_ALU = 1'b1;
                                  Set_BusA_To = 4'b1000;
                                  Set_BusB_To = 4'b0110;
                                end
                              
                              MCycle[2] :
                                begin
                                  NoRead = 1'b1;
                                  Read_To_Reg = 1'b1;
                                  Save_ALU = 1'b1;
                                  ALU_Op = 4'b0001;
                                  Set_BusA_To = 4'b1001;
                                  Set_BusB_To = 4'b1110;        // Incorrect unsigned !!!!!!!!!!!!!!!!!!!!!
                                end
                              
                              default :;
                            endcase // case(MCycle)
                          end // case: 2'b01
                        
                        2'b10  :
                          begin
                            // LD A,($FF00+nn)
                            MCycles = 3'b011;
                            case (1'b1) // MCycle
                              MCycle[1] :
                                begin
                                  Inc_PC = 1'b1;
                                  Set_Addr_To = aIOA;
                                end
                              
                              MCycle[2] :
                                Read_To_Acc = 1'b1;
                              default :;
                            endcase // case(MCycle)
                          end // case: 2'b10
                        
                        2'b11  :
                          begin
                            // LD HL,SP+n       -- Not correct !!!!!!!!!!!!!!!!!!!
                            MCycles = 3'b101;
                            case (1'b1) // MCycle
                              MCycle[1] :
                                begin
                                  Inc_PC = 1'b1;
                                  LDZ = 1'b1;
                                end
                              
                              MCycle[2] :
                                begin
                                  Set_Addr_To = aZI;
                                  Inc_PC = 1'b1;
                                  LDW = 1'b1;
                                end
                              
                              MCycle[3] :
                                begin
                                  Set_BusA_To[2:0] = 3'b101; // L
                                  Read_To_Reg = 1'b1;
                                  Inc_WZ = 1'b1;
                                  Set_Addr_To = aZI;
                                end
                              
                              MCycle[4] :
                                begin
                                  Set_BusA_To[2:0] = 3'b100; // H
                                  Read_To_Reg = 1'b1;
                                end
                              
                              default :;
                            endcase // case(MCycle)
                          end // case: 2'b11
                        
                      endcase // case(IR[4:3])
                      
                    end 
                  else 
                    begin
                      // RET cc
                      MCycles = 3'b011;
                      case (1'b1) // MCycle
                        MCycle[0] :
                          begin
                            if (is_cc_true(F, IR[5:3]) )                              
                              begin
                                Set_Addr_To = aSP;
                              end 
                            else 
                              begin
                                MCycles = 3'b001;
                              end
                            TStates = 3'b101;
                          end // case: 1
                        
                        MCycle[1] :
                          begin
                            IncDec_16 = 4'b0111;
                            Set_Addr_To = aSP;
                            LDZ = 1'b1;
                          end
                        MCycle[2] :
                          begin
                            Jump = 1'b1;
                            IncDec_16 = 4'b0111;
                          end
                        default :;
                      endcase
                    end // else: !if(IR[5] == 1'b1 && Mode == 3 )
                end // case: 8'b11000000,8'b11001000,8'b11010000,8'b11011000,8'b11100000,8'b11101000,8'b11110000,8'b11111000
              
              8'b11000111,8'b11001111,8'b11010111,8'b11011111,8'b11100111,8'b11101111,8'b11110111,8'b11111111  :
                begin
                  // RST p
                  MCycles = 3'b011;
                  case (1'b1) // MCycle
                    MCycle[0] :
                      begin
                        TStates = 3'b101;
                        IncDec_16 = 4'b1111;
                        Set_Addr_To = aSP;
                        Set_BusB_To = 4'b1101;
                      end
                    
                    MCycle[1] :
                      begin
                        Write = 1'b1;
                        IncDec_16 = 4'b1111;
                        Set_Addr_To = aSP;
                        Set_BusB_To = 4'b1100;
                      end
                    
                    MCycle[2] :
                      begin
                        Write = 1'b1;
                        RstP = 1'b1;
                      end
                    
                    default :;
                  endcase // case(MCycle)
                end // case: 8'b11000111,8'b11001111,8'b11010111,8'b11011111,8'b11100111,8'b11101111,8'b11110111,8'b11111111
              
              // INPUT AND OUTPUT GROUP
              8'b11011011  :
                begin
                  if (Mode != 3 ) 
                    begin
                      // IN A,(n)
                      MCycles = 3'b011;
                      case (1'b1) // MCycle
                        MCycle[1] :
                          begin
                            Inc_PC = 1'b1;
                            Set_Addr_To = aIOA;
                          end
                        
                        MCycle[2] :
                          begin
                            Read_To_Acc = 1'b1;
                            IORQ = 1'b1;
                          end
                        
                        default :;
                      endcase
                    end // if (Mode != 3 )
                end // case: 8'b11011011
              
              8'b11010011  :
                begin
                  if (Mode != 3 ) 
                    begin
                      // OUT (n),A
                      MCycles = 3'b011;
                      case (1'b1) // MCycle
                        MCycle[1] :
                          begin
                            Inc_PC = 1'b1;
                            Set_Addr_To = aIOA;
                            Set_BusB_To = 4'b0111;
                          end
                        
                        MCycle[2] :
                          begin
                            Write = 1'b1;
                            IORQ = 1'b1;
                          end
                        
                        default :;
                      endcase
                    end // if (Mode != 3 )
                end // case: 8'b11010011
              

              //----------------------------------------------------------------------------
              //----------------------------------------------------------------------------
              // MULTIBYTE INSTRUCTIONS
              //----------------------------------------------------------------------------
              //----------------------------------------------------------------------------

              8'b11001011  :
                begin
                  if (Mode != 2 ) 
                    begin
                      Prefix = 2'b01;
                    end
                end              

              8'b11101101  :
                begin
                  if (Mode < 2 ) 
                    begin
                      Prefix = 2'b10;
                    end
                end

              8'b11011101,8'b11111101  :
                begin
                  if (Mode < 2 ) 
                    begin
                      Prefix = 2'b11;
                    end
                end
              
            endcase // case(IR)
          end // case: 2'b00
        

        2'b01  :
          begin
            

            //----------------------------------------------------------------------------
            //
            //  CB prefixed instructions
            //
            //----------------------------------------------------------------------------
            
            Set_BusA_To[2:0] = IR[2:0];
            Set_BusB_To[2:0] = IR[2:0];
            
            casex (IR)
              8'b00000000,8'b00000001,8'b00000010,8'b00000011,8'b00000100,8'b00000101,8'b00000111,
              8'b00010000,8'b00010001,8'b00010010,8'b00010011,8'b00010100,8'b00010101,8'b00010111,
              8'b00001000,8'b00001001,8'b00001010,8'b00001011,8'b00001100,8'b00001101,8'b00001111,
              8'b00011000,8'b00011001,8'b00011010,8'b00011011,8'b00011100,8'b00011101,8'b00011111,
              8'b00100000,8'b00100001,8'b00100010,8'b00100011,8'b00100100,8'b00100101,8'b00100111,
              8'b00101000,8'b00101001,8'b00101010,8'b00101011,8'b00101100,8'b00101101,8'b00101111,
              8'b00110000,8'b00110001,8'b00110010,8'b00110011,8'b00110100,8'b00110101,8'b00110111,
              8'b00111000,8'b00111001,8'b00111010,8'b00111011,8'b00111100,8'b00111101,8'b00111111 :
                begin
                  // RLC r
                  // RL r
                  // RRC r
                  // RR r
                  // SLA r
                  // SRA r
                  // SRL r
                  // SLL r (Undocumented) / SWAP r
                  if (MCycle[0] ) begin
                    ALU_Op = 4'b1000;
                    Read_To_Reg = 1'b1;
                    Save_ALU = 1'b1;
                  end
                end // case: 8'b00000000,8'b00000001,8'b00000010,8'b00000011,8'b00000100,8'b00000101,8'b00000111,...
              
              8'b00xxx110  :
                begin
                  // RLC (HL)
                  // RL (HL)
                  // RRC (HL)
                  // RR (HL)
                  // SRA (HL)
                  // SRL (HL)
                  // SLA (HL)
                  // SLL (HL) (Undocumented) / SWAP (HL)
                  MCycles = 3'b011;
                  case (1'b1) // MCycle
                    MCycle[0], MCycle[6] :
                      Set_Addr_To = aXY;
                    MCycle[1] :
                      begin
                        ALU_Op = 4'b1000;
                        Read_To_Reg = 1'b1;
                        Save_ALU = 1'b1;
                        Set_Addr_To = aXY;
                        TStates = 3'b100;
                      end
                    
                    MCycle[2] :
                      Write = 1'b1;
                    default :;
                  endcase // case(MCycle)
                end // case: 8'b00000110,8'b00010110,8'b00001110,8'b00011110,8'b00101110,8'b00111110,8'b00100110,8'b00110110
              
              8'b01000000,8'b01000001,8'b01000010,8'b01000011,8'b01000100,8'b01000101,8'b01000111,
                  8'b01001000,8'b01001001,8'b01001010,8'b01001011,8'b01001100,8'b01001101,8'b01001111,
                  8'b01010000,8'b01010001,8'b01010010,8'b01010011,8'b01010100,8'b01010101,8'b01010111,
                  8'b01011000,8'b01011001,8'b01011010,8'b01011011,8'b01011100,8'b01011101,8'b01011111,
                  8'b01100000,8'b01100001,8'b01100010,8'b01100011,8'b01100100,8'b01100101,8'b01100111,
                  8'b01101000,8'b01101001,8'b01101010,8'b01101011,8'b01101100,8'b01101101,8'b01101111,
                  8'b01110000,8'b01110001,8'b01110010,8'b01110011,8'b01110100,8'b01110101,8'b01110111,
                  8'b01111000,8'b01111001,8'b01111010,8'b01111011,8'b01111100,8'b01111101,8'b01111111 :
                    begin
                      // BIT b,r
                      if (MCycle[0] )
                        begin
                          Set_BusB_To[2:0] = IR[2:0];
                          ALU_Op = 4'b1001;
                        end
                    end // case: 8'b01000000,8'b01000001,8'b01000010,8'b01000011,8'b01000100,8'b01000101,8'b01000111,...
              
              8'b01000110,8'b01001110,8'b01010110,8'b01011110,8'b01100110,8'b01101110,8'b01110110,8'b01111110  :
                begin
                  // BIT b,(HL)
                  MCycles = 3'b010;
                  case (1'b1) // MCycle
                    MCycle[0], MCycle[6] :
                      Set_Addr_To = aXY;
                    MCycle[1] :
                      begin
                        ALU_Op = 4'b1001;
                        TStates = 3'b100;
                      end
                    
                    default :;
                  endcase // case(MCycle)
                end // case: 8'b01000110,8'b01001110,8'b01010110,8'b01011110,8'b01100110,8'b01101110,8'b01110110,8'b01111110
              
              8'b11000000,8'b11000001,8'b11000010,8'b11000011,8'b11000100,8'b11000101,8'b11000111,
                  8'b11001000,8'b11001001,8'b11001010,8'b11001011,8'b11001100,8'b11001101,8'b11001111,
                  8'b11010000,8'b11010001,8'b11010010,8'b11010011,8'b11010100,8'b11010101,8'b11010111,
                  8'b11011000,8'b11011001,8'b11011010,8'b11011011,8'b11011100,8'b11011101,8'b11011111,
                  8'b11100000,8'b11100001,8'b11100010,8'b11100011,8'b11100100,8'b11100101,8'b11100111,
                  8'b11101000,8'b11101001,8'b11101010,8'b11101011,8'b11101100,8'b11101101,8'b11101111,
                  8'b11110000,8'b11110001,8'b11110010,8'b11110011,8'b11110100,8'b11110101,8'b11110111,
                  8'b11111000,8'b11111001,8'b11111010,8'b11111011,8'b11111100,8'b11111101,8'b11111111 :
                    begin
                      // SET b,r
                      if (MCycle[0] ) 
                        begin
                          ALU_Op = 4'b1010;
                          Read_To_Reg = 1'b1;
                          Save_ALU = 1'b1;
                        end
                    end // case: 8'b11000000,8'b11000001,8'b11000010,8'b11000011,8'b11000100,8'b11000101,8'b11000111,...
              
              8'b11000110,8'b11001110,8'b11010110,8'b11011110,8'b11100110,8'b11101110,8'b11110110,8'b11111110  :
                begin
                  // SET b,(HL)
                  MCycles = 3'b011;
                  case (1'b1) // MCycle
                    MCycle[0], MCycle[6] :
                      Set_Addr_To = aXY;
                    MCycle[1] :
                      begin
                        ALU_Op = 4'b1010;
                        Read_To_Reg = 1'b1;
                        Save_ALU = 1'b1;
                        Set_Addr_To = aXY;
                        TStates = 3'b100;
                      end
                    MCycle[2] :
                      Write = 1'b1;
                    default :;
                  endcase // case(MCycle)
                end // case: 8'b11000110,8'b11001110,8'b11010110,8'b11011110,8'b11100110,8'b11101110,8'b11110110,8'b11111110
              
              8'b10000000,8'b10000001,8'b10000010,8'b10000011,8'b10000100,8'b10000101,8'b10000111,
                  8'b10001000,8'b10001001,8'b10001010,8'b10001011,8'b10001100,8'b10001101,8'b10001111,
                  8'b10010000,8'b10010001,8'b10010010,8'b10010011,8'b10010100,8'b10010101,8'b10010111,
                  8'b10011000,8'b10011001,8'b10011010,8'b10011011,8'b10011100,8'b10011101,8'b10011111,
                  8'b10100000,8'b10100001,8'b10100010,8'b10100011,8'b10100100,8'b10100101,8'b10100111,
                  8'b10101000,8'b10101001,8'b10101010,8'b10101011,8'b10101100,8'b10101101,8'b10101111,
                  8'b10110000,8'b10110001,8'b10110010,8'b10110011,8'b10110100,8'b10110101,8'b10110111,
                  8'b10111000,8'b10111001,8'b10111010,8'b10111011,8'b10111100,8'b10111101,8'b10111111 :
                    begin
                      // RES b,r
                      if (MCycle[0] ) 
                        begin
                          ALU_Op = 4'b1011;
                          Read_To_Reg = 1'b1;
                          Save_ALU = 1'b1;
                        end
                    end // case: 8'b10000000,8'b10000001,8'b10000010,8'b10000011,8'b10000100,8'b10000101,8'b10000111,...
              
              8'b10000110,8'b10001110,8'b10010110,8'b10011110,8'b10100110,8'b10101110,8'b10110110,8'b10111110  :
                begin
                  // RES b,(HL)
                  MCycles = 3'b011;
                  case (1'b1) // MCycle
                    MCycle[0], MCycle[6] :
                      Set_Addr_To = aXY;
                    MCycle[1] :
                      begin
                        ALU_Op = 4'b1011;
                        Read_To_Reg = 1'b1;
                        Save_ALU = 1'b1;
                        Set_Addr_To = aXY;
                        TStates = 3'b100;
                      end
                    
                    MCycle[2] :
                      Write = 1'b1;
                    default :;
                  endcase // case(MCycle)
                end // case: 8'b10000110,8'b10001110,8'b10010110,8'b10011110,8'b10100110,8'b10101110,8'b10110110,8'b10111110
              
            endcase // case(IR)
          end // case: 2'b01
        
        
        default :
          begin : default_ed_block
            
            //----------------------------------------------------------------------------
            //
            //  ED prefixed instructions
            //
            //----------------------------------------------------------------------------

            casex (IR)
	      /*
	       * Undocumented NOP instructions commented out to reduce size of mcode
	       *
              8'b00000000,8'b00000001,8'b00000010,8'b00000011,8'b00000100,8'b00000101,8'b00000110,8'b00000111
                ,8'b00001000,8'b00001001,8'b00001010,8'b00001011,8'b00001100,8'b00001101,8'b00001110,8'b00001111
                  ,8'b00010000,8'b00010001,8'b00010010,8'b00010011,8'b00010100,8'b00010101,8'b00010110,8'b00010111
                    ,8'b00011000,8'b00011001,8'b00011010,8'b00011011,8'b00011100,8'b00011101,8'b00011110,8'b00011111
                      ,8'b00100000,8'b00100001,8'b00100010,8'b00100011,8'b00100100,8'b00100101,8'b00100110,8'b00100111
                        ,8'b00101000,8'b00101001,8'b00101010,8'b00101011,8'b00101100,8'b00101101,8'b00101110,8'b00101111
                          ,8'b00110000,8'b00110001,8'b00110010,8'b00110011,8'b00110100,8'b00110101,8'b00110110,8'b00110111
                            ,8'b00111000,8'b00111001,8'b00111010,8'b00111011,8'b00111100,8'b00111101,8'b00111110,8'b00111111
                

                              ,8'b10000000,8'b10000001,8'b10000010,8'b10000011,8'b10000100,8'b10000101,8'b10000110,8'b10000111
                                ,8'b10001000,8'b10001001,8'b10001010,8'b10001011,8'b10001100,8'b10001101,8'b10001110,8'b10001111
                                  ,8'b10010000,8'b10010001,8'b10010010,8'b10010011,8'b10010100,8'b10010101,8'b10010110,8'b10010111
                                    ,8'b10011000,8'b10011001,8'b10011010,8'b10011011,8'b10011100,8'b10011101,8'b10011110,8'b10011111
                                      ,                                            8'b10100100,8'b10100101,8'b10100110,8'b10100111
                                        ,                                            8'b10101100,8'b10101101,8'b10101110,8'b10101111
                                          ,                                            8'b10110100,8'b10110101,8'b10110110,8'b10110111
                                            ,                                            8'b10111100,8'b10111101,8'b10111110,8'b10111111
                                              ,8'b11000000,8'b11000001,8'b11000010,8'b11000011,8'b11000100,8'b11000101,8'b11000110,8'b11000111
                                                ,8'b11001000,8'b11001001,8'b11001010,8'b11001011,8'b11001100,8'b11001101,8'b11001110,8'b11001111
                                                  ,8'b11010000,8'b11010001,8'b11010010,8'b11010011,8'b11010100,8'b11010101,8'b11010110,8'b11010111
                                                    ,8'b11011000,8'b11011001,8'b11011010,8'b11011011,8'b11011100,8'b11011101,8'b11011110,8'b11011111
                                                      ,8'b11100000,8'b11100001,8'b11100010,8'b11100011,8'b11100100,8'b11100101,8'b11100110,8'b11100111
                                                        ,8'b11101000,8'b11101001,8'b11101010,8'b11101011,8'b11101100,8'b11101101,8'b11101110,8'b11101111
                                                          ,8'b11110000,8'b11110001,8'b11110010,8'b11110011,8'b11110100,8'b11110101,8'b11110110,8'b11110111
                                                            ,8'b11111000,8'b11111001,8'b11111010,8'b11111011,8'b11111100,8'b11111101,8'b11111110,8'b11111111 :
                                                              ; // NOP, undocumented
              
              8'b01111110,8'b01111111  :
                // NOP, undocumented
                ;
	       */
	      
              // 8 BIT LOAD GROUP
              8'b01010111  :
                begin
                  // LD A,I
                  Special_LD = 3'b100;
                  TStates = 3'b101;
                end
              
              8'b01011111  :
                begin
                  // LD A,R
                  Special_LD = 3'b101;
                  TStates = 3'b101;
                end
              
              8'b01000111  :
                begin
                  // LD I,A
                  Special_LD = 3'b110;
                  TStates = 3'b101;
                end
              
              8'b01001111  :
                begin
                  // LD R,A
                  Special_LD = 3'b111;
                  TStates = 3'b101;
                end
              
              // 16 BIT LOAD GROUP
              8'b01001011,8'b01011011,8'b01101011,8'b01111011  :
                begin
                  // LD dd,(nn)
                  MCycles = 3'b101;
                  case (1'b1) // MCycle
                    MCycle[1] :
                      begin
                        Inc_PC = 1'b1;
                        LDZ = 1'b1;
                      end
                    
                    MCycle[2] :
                      begin
                        Set_Addr_To = aZI;
                        Inc_PC = 1'b1;
                        LDW = 1'b1;
                      end
                    
                    MCycle[3] :
                      begin
                        Read_To_Reg = 1'b1;
                        if (IR[5:4] == 2'b11 ) 
                          begin
                            Set_BusA_To = 4'b1000;
                          end 
                        else 
                          begin
                            Set_BusA_To[2:1] = IR[5:4];
                            Set_BusA_To[0] = 1'b1;
                          end
                        Inc_WZ = 1'b1;
                        Set_Addr_To = aZI;
                      end // case: 4
                    
                    MCycle[4] :
                      begin
                        Read_To_Reg = 1'b1;
                        if (IR[5:4] == 2'b11 ) 
                          begin
                            Set_BusA_To = 4'b1001;
                          end 
                        else 
                          begin
                            Set_BusA_To[2:1] = IR[5:4];
                            Set_BusA_To[0] = 1'b0;
                          end
                      end // case: 5
                    
                    default :;
                  endcase // case(MCycle)
                end // case: 8'b01001011,8'b01011011,8'b01101011,8'b01111011
              
              
              8'b01000011,8'b01010011,8'b01100011,8'b01110011  :
                begin
                  // LD (nn),dd
                  MCycles = 3'b101;
                  case (1'b1) // MCycle
                    MCycle[1] :
                      begin
                        Inc_PC = 1'b1;
                        LDZ = 1'b1;
                      end
                    
                    MCycle[2] :
                      begin
                        Set_Addr_To = aZI;
                        Inc_PC = 1'b1;
                        LDW = 1'b1;
                        if (IR[5:4] == 2'b11 ) 
                          begin
                            Set_BusB_To = 4'b1000;
                          end 
                        else 
                          begin
                            Set_BusB_To[2:1] = IR[5:4];
                            Set_BusB_To[0] = 1'b1;
                            Set_BusB_To[3] = 1'b0;
                          end
                      end // case: 3
                    
                    MCycle[3] :
                      begin
                        Inc_WZ = 1'b1;
                        Set_Addr_To = aZI;
                        Write = 1'b1;
                        if (IR[5:4] == 2'b11 ) 
                          begin
                            Set_BusB_To = 4'b1001;
                          end 
                        else 
                          begin
                            Set_BusB_To[2:1] = IR[5:4];
                            Set_BusB_To[0] = 1'b0;
                            Set_BusB_To[3] = 1'b0;
                          end
                      end // case: 4
                    
                    MCycle[4] :
                      begin
                        Write = 1'b1;
                      end
                    
                    default :;
                  endcase // case(MCycle)
                end // case: 8'b01000011,8'b01010011,8'b01100011,8'b01110011
              
              8'b10100000 , 8'b10101000 , 8'b10110000 , 8'b10111000  :
                begin
                  // LDI, LDD, LDIR, LDDR
                  MCycles = 3'b100;
                  case (1'b1) // MCycle
                    MCycle[0] :
                      begin
                        Set_Addr_To = aXY;
                        IncDec_16 = 4'b1100; // BC
                      end
                    
                    MCycle[1] :
                      begin
                        Set_BusB_To = 4'b0110;
                        Set_BusA_To[2:0] = 3'b111;
                        ALU_Op = 4'b0000;
                        Set_Addr_To = aDE;
                        if (IR[3] == 1'b0 ) 
                          begin
                            IncDec_16 = 4'b0110; // IX
                          end 
                        else 
                          begin
                            IncDec_16 = 4'b1110;
                          end
                      end // case: 2
                    
                    MCycle[2] :
                      begin
                        I_BT = 1'b1;
                        TStates = 3'b101;
                        Write = 1'b1;
                        if (IR[3] == 1'b0 ) 
                          begin
                            IncDec_16 = 4'b0101; // DE
                          end 
                        else 
                          begin
                            IncDec_16 = 4'b1101;
                          end
                      end // case: 3
                    
                    MCycle[3] :
                      begin
                        NoRead = 1'b1;
                        TStates = 3'b101;
                      end
                    
                    default :;
                  endcase // case(MCycle)
                end // case: 8'b10100000 , 8'b10101000 , 8'b10110000 , 8'b10111000
              
              8'b10100001 , 8'b10101001 , 8'b10110001 , 8'b10111001  :
                begin
                  // CPI, CPD, CPIR, CPDR
                  MCycles = 3'b100;
                  case (1'b1) // MCycle
                    MCycle[0] :
                      begin
                        Set_Addr_To = aXY;
                        IncDec_16 = 4'b1100; // BC
                      end
                    
                    MCycle[1] :
                      begin
                        Set_BusB_To = 4'b0110;
                        Set_BusA_To[2:0] = 3'b111;
                        ALU_Op = 4'b0111;
                        Save_ALU = 1'b1;
                        PreserveC = 1'b1;
                        if (IR[3] == 1'b0 ) 
                          begin
                            IncDec_16 = 4'b0110;
                          end 
                        else 
                          begin
                            IncDec_16 = 4'b1110;
                          end
                      end // case: 2
                    
                    MCycle[2] :
                      begin
                        NoRead = 1'b1;
                        I_BC = 1'b1;
                        TStates = 3'b101;
                      end
                    
                    MCycle[3] :
                      begin
                        NoRead = 1'b1;
                        TStates = 3'b101;
                      end
                    
                    default :;
                  endcase // case(MCycle)
                end // case: 8'b10100001 , 8'b10101001 , 8'b10110001 , 8'b10111001
              
              8'b01000100,8'b01001100,8'b01010100,8'b01011100,8'b01100100,8'b01101100,8'b01110100,8'b01111100  :
                begin
                  // NEG
                  ALU_Op = 4'b0010;
                  Set_BusB_To = 4'b0111;
                  Set_BusA_To = 4'b1010;
                  Read_To_Acc = 1'b1;
                  Save_ALU = 1'b1;
                end
              
              8'b01000110,8'b01001110,8'b01100110,8'b01101110  :
                begin
                  // IM 0
                  IMode = 2'b00;
                end
              
              8'b01010110,8'b01110110  :
                // IM 1
                IMode = 2'b01;
              
              8'b01011110,8'b01110111  :
                // IM 2
                IMode = 2'b10;
              
              // 16 bit arithmetic
              8'b01001010,8'b01011010,8'b01101010,8'b01111010  :
                begin
                  // ADC HL,ss
                  MCycles = 3'b011;
                  case (1'b1) // MCycle
                    MCycle[1] :
                      begin
                        NoRead = 1'b1;
                        ALU_Op = 4'b0001;
                        Read_To_Reg = 1'b1;
                        Save_ALU = 1'b1;
                        Set_BusA_To[2:0] = 3'b101;
                        case (IR[5:4])
                          0,1,2  :
                            begin
                              Set_BusB_To[2:1] = IR[5:4];
                              Set_BusB_To[0] = 1'b1;
                            end
                          default :
                            Set_BusB_To = 4'b1000;
                        endcase
                        TStates = 3'b100;
                      end // case: 2
                    
                    MCycle[2] :
                      begin
                        NoRead = 1'b1;
                        Read_To_Reg = 1'b1;
                        Save_ALU = 1'b1;
                        ALU_Op = 4'b0001;
                        Set_BusA_To[2:0] = 3'b100;
                        case (IR[5:4])
                          0,1,2  :
                            begin
                              Set_BusB_To[2:1] = IR[5:4];
                              Set_BusB_To[0] = 1'b0;
                            end
                          default :
                            Set_BusB_To = 4'b1001;
                        endcase // case(IR[5:4])
                      end // case: 3
                    
                    default :;
                  endcase // case(MCycle)
                end // case: 8'b01001010,8'b01011010,8'b01101010,8'b01111010
              
              8'b01000010,8'b01010010,8'b01100010,8'b01110010  :
                begin
                  // SBC HL,ss
                  MCycles = 3'b011;
                  case (1'b1) // MCycle
                    MCycle[1] :
                      begin
                        NoRead = 1'b1;
                        ALU_Op = 4'b0011;
                        Read_To_Reg = 1'b1;
                        Save_ALU = 1'b1;
                        Set_BusA_To[2:0] = 3'b101;
                        case (IR[5:4])
                          0,1,2  :
                            begin
                              Set_BusB_To[2:1] = IR[5:4];
                              Set_BusB_To[0] = 1'b1;
                            end
                          default :
                            Set_BusB_To = 4'b1000;
                        endcase
                        TStates = 3'b100;
                      end // case: 2
                    
                    MCycle[2] :
                      begin
                        NoRead = 1'b1;
                        ALU_Op = 4'b0011;
                        Read_To_Reg = 1'b1;
                        Save_ALU = 1'b1;
                        Set_BusA_To[2:0] = 3'b100;
                        case (IR[5:4])
                          0,1,2  :
                            Set_BusB_To[2:1] = IR[5:4];
                          default :
                            Set_BusB_To = 4'b1001;
                        endcase
                      end // case: 3
                    
                    default :;
                    
                  endcase // case(MCycle)
                end // case: 8'b01000010,8'b01010010,8'b01100010,8'b01110010
              
              8'b01101111  :
                begin
                  // RLD
                  MCycles = 3'b100;
                  case (1'b1) // MCycle
                    MCycle[1] :
                      begin
                        NoRead = 1'b1;
                        Set_Addr_To = aXY;
                      end
                    
                    MCycle[2] :
                      begin
                        Read_To_Reg = 1'b1;
                        Set_BusB_To[2:0] = 3'b110;
                        Set_BusA_To[2:0] = 3'b111;
                        ALU_Op = 4'b1101;
                        TStates = 3'b100;
                        Set_Addr_To = aXY;
                        Save_ALU = 1'b1;
                      end
                    
                    MCycle[3] :
                      begin
                        I_RLD = 1'b1;
                        Write = 1'b1;
                      end
                    
                    default :;
                  endcase // case(MCycle)
                end // case: 8'b01101111
              
              8'b01100111  :
                begin
                  // RRD
                  MCycles = 3'b100;
                  case (1'b1) // MCycle
                    MCycle[1] :
                      Set_Addr_To = aXY;
                    MCycle[2] :
                      begin
                        Read_To_Reg = 1'b1;
                        Set_BusB_To[2:0] = 3'b110;
                        Set_BusA_To[2:0] = 3'b111;
                        ALU_Op = 4'b1110;
                        TStates = 3'b100;
                        Set_Addr_To = aXY;
                        Save_ALU = 1'b1;
                      end
                    
                    MCycle[3] :
                      begin
                        I_RRD = 1'b1;
                        Write = 1'b1;
                      end
                    
                    default :;
                  endcase // case(MCycle)
                end // case: 8'b01100111
              
              8'b01000101,8'b01001101,8'b01010101,8'b01011101,8'b01100101,8'b01101101,8'b01110101,8'b01111101  :
                begin
                  // RETI, RETN
                  MCycles = 3'b011;
                  case (1'b1) // MCycle
                    MCycle[0] :
                      Set_Addr_To = aSP;
                    
                    MCycle[1] :
                      begin
                        IncDec_16 = 4'b0111;
                        Set_Addr_To = aSP;
                        LDZ = 1'b1;
                      end
                    
                    MCycle[2] :
                      begin
                        Jump = 1'b1;
                        IncDec_16 = 4'b0111;
                        I_RETN = 1'b1;
                      end
                    
                    default :;
                  endcase // case(MCycle)
                end // case: 8'b01000101,8'b01001101,8'b01010101,8'b01011101,8'b01100101,8'b01101101,8'b01110101,8'b01111101
              
              8'b01000000,8'b01001000,8'b01010000,8'b01011000,8'b01100000,8'b01101000,8'b01110000,8'b01111000  :
                begin
                  // IN r,(C)
                  MCycles = 3'b010;
                  case (1'b1) // MCycle
                    MCycle[0] :
                      Set_Addr_To = aBC;
                    
                    MCycle[1] :
                      begin
                        IORQ = 1'b1;
                        if (IR[5:3] != 3'b110 ) 
                          begin
                            Read_To_Reg = 1'b1;
                            Set_BusA_To[2:0] = IR[5:3];
                          end
                        I_INRC = 1'b1;
                      end
                    
                    default :;
                  endcase // case(MCycle)
                end // case: 8'b01000000,8'b01001000,8'b01010000,8'b01011000,8'b01100000,8'b01101000,8'b01110000,8'b01111000
              
              8'b01000001,8'b01001001,8'b01010001,8'b01011001,8'b01100001,8'b01101001,8'b01110001,8'b01111001  :
                begin
                  // OUT (C),r
                  // OUT (C),0
                  MCycles = 3'b010;
                  case (1'b1) // MCycle
                    MCycle[0] :
                      begin
                        Set_Addr_To = aBC;
                        Set_BusB_To[2:0]        = IR[5:3];
                        if (IR[5:3] == 3'b110 ) 
                          begin
                            Set_BusB_To[3] = 1'b1;
                          end
                      end
                    
                    MCycle[1] :
                      begin
                        Write = 1'b1;
                        IORQ = 1'b1;
                      end
                    
                    default :;
                  endcase // case(MCycle)
                end // case: 8'b01000001,8'b01001001,8'b01010001,8'b01011001,8'b01100001,8'b01101001,8'b01110001,8'b01111001
              
              8'b10100010 , 8'b10101010 , 8'b10110010 , 8'b10111010  :
                begin
                  // INI, IND, INIR, INDR
                  MCycles = 3'b100;
                  case (1'b1) // MCycle
                    MCycle[0] :
                      begin
                        Set_Addr_To = aBC;
                        Set_BusB_To = 4'b1010;
                        Set_BusA_To = 4'b0000;
                        Read_To_Reg = 1'b1;
                        Save_ALU = 1'b1;
                        ALU_Op = 4'b0010;
                      end
                    
                    MCycle[1] :
                      begin
                        IORQ = 1'b1;
                        Set_BusB_To = 4'b0110;
                        Set_Addr_To = aXY;
                      end
                    
                    MCycle[2] :
                      begin
                        if (IR[3] == 1'b0 ) 
                          begin
			    IncDec_16 = 4'b0110;
                          end 
                        else 
                          begin
			    IncDec_16 = 4'b1110;
                          end
                        TStates = 3'b100;
                        Write = 1'b1;
                        I_BTR = 1'b1;
                      end // case: 3
                    
                    MCycle[3] :
                      begin
                        NoRead = 1'b1;
                        TStates = 3'b101;
                      end
                    
                    default :;
                  endcase // case(MCycle)
                end // case: 8'b10100010 , 8'b10101010 , 8'b10110010 , 8'b10111010
              
              8'b10100011 , 8'b10101011 , 8'b10110011 , 8'b10111011  :
                begin
                  // OUTI, OUTD, OTIR, OTDR
                  MCycles = 3'b100;
                  case (1'b1) // MCycle
                    MCycle[0] :
                      begin
                        TStates = 3'b101;
                        Set_Addr_To = aXY;
                        Set_BusB_To = 4'b1010;
                        Set_BusA_To = 4'b0000;
                        Read_To_Reg = 1'b1;
                        Save_ALU = 1'b1;
                        ALU_Op = 4'b0010;
                      end
                    
                    MCycle[1] :
                      begin
                        Set_BusB_To = 4'b0110;
                        Set_Addr_To = aBC;
                        if (IR[3] == 1'b0 ) 
                          begin
                            IncDec_16 = 4'b0110;
                          end 
                        else 
                          begin
                            IncDec_16 = 4'b1110;
                          end
                      end
                    
                    MCycle[2] :
                      begin
                        if (IR[3] == 1'b0 ) 
                          begin
                            IncDec_16 = 4'b0010;
                          end 
                        else 
                          begin
                            IncDec_16 = 4'b1010;
                          end
                        IORQ = 1'b1;
                        Write = 1'b1;
                        I_BTR = 1'b1;
                      end // case: 3
                    
                    MCycle[3] :
                      begin
                        NoRead = 1'b1;
                        TStates = 3'b101;
                      end
                    
                    default :;
                  endcase // case(MCycle)
                end // case: 8'b10100011 , 8'b10101011 , 8'b10110011 , 8'b10111011
              
            endcase // case(IR)                  
          end // block: default_ed_block        
      endcase // case(ISet)
      
      if (Mode == 1 ) 
        begin
          if (MCycle[0] ) 
            begin
              //TStates = 3'b100;
            end 
          else 
            begin
              TStates = 3'b011;
            end
        end

      if (Mode == 3 ) 
        begin
          if (MCycle[0] ) 
            begin
              //TStates = 3'b100;
            end 
          else 
            begin
              TStates = 3'b100;
            end
        end

      if (Mode < 2 ) 
        begin
          if (MCycle[5] ) 
            begin
              Inc_PC = 1'b1;
              if (Mode == 1 ) 
                begin
                  Set_Addr_To = aXY;
                  TStates = 3'b100;
                  Set_BusB_To[2:0] = SSS;
                  Set_BusB_To[3] = 1'b0;
                end
              if (IR == 8'b00110110 || IR == 8'b11001011 ) 
                begin
                  Set_Addr_To = aNone;
                end
            end
          if (MCycle[6] ) 
            begin
              if (Mode == 0 ) 
                begin
                  TStates = 3'b101;
                end
              if (ISet != 2'b01 ) 
                begin
                  Set_Addr_To = aXY;
                end
              Set_BusB_To[2:0] = SSS;
              Set_BusB_To[3] = 1'b0;
              if (IR == 8'b00110110 || ISet == 2'b01 ) 
                begin
                  // LD (HL),n
                  Inc_PC = 1'b1;
                end 
              else 
                begin
                  NoRead = 1'b1;
                end
            end
        end // if (Mode < 2 )      
      
    end // always @ (IR, ISet, MCycle, F, NMICycle, IntCycle)
endmodule // T80_MCode
