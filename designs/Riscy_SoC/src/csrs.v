`ifndef CSRS
`define CSRS

`define CSR_MSTATUS        12'h300
`define CSR_MISA           12'h301
`define CSR_MIE            12'h304
`define CSR_MTVEC          12'h305
`define CSR_MHPMEVENT3     12'h643
`define CSR_MHPMEVENT4     12'h644
`define CSR_MHPMEVENT5     12'h645
`define CSR_MHPMEVENT6     12'h646
`define CSR_MHPMEVENT7     12'h647
`define CSR_MHPMEVENT8     12'h648
`define CSR_MHPMEVENT9     12'h649
`define CSR_MHPMEVENT10    12'h64A
`define CSR_MHPMEVENT11    12'h64B
`define CSR_MHPMEVENT12    12'h64C
`define CSR_MHPMEVENT13    12'h64D
`define CSR_MHPMEVENT14    12'h64E
`define CSR_MHPMEVENT15    12'h64F
`define CSR_MHPMEVENT16    12'h330
`define CSR_MHPMEVENT17    12'h331
`define CSR_MHPMEVENT18    12'h364
`define CSR_MHPMEVENT19    12'h333
`define CSR_MHPMEVENT20    12'h334
`define CSR_MHPMEVENT21    12'h335
`define CSR_MHPMEVENT22    12'h336
`define CSR_MHPMEVENT23    12'h337
`define CSR_MHPMEVENT24    12'h338
`define CSR_MHPMEVENT25    12'h339
`define CSR_MHPMEVENT26    12'h33A
`define CSR_MHPMEVENT27    12'h33B
`define CSR_MHPMEVENT28    12'h33C
`define CSR_MHPMEVENT29    12'h33D
`define CSR_MHPMEVENT30    12'h33E
`define CSR_MHPMEVENT31    12'h33F
`define CSR_MSCRATCH       12'h340
`define CSR_MEPC           12'h341
`define CSR_MCAUSE         12'h342
`define CSR_MTVAL          12'h343
`define CSR_MIP            12'h344
`define CSR_PMPCFG0        12'h3A0
`define CSR_PMPCFG1        12'h3A1
`define CSR_PMPCFG2        12'h3A2
`define CSR_PMPCFG3        12'h3A3
`define CSR_PMPADDR0       12'h3B0
`define CSR_PMPADDR1       12'h3B1
`define CSR_PMPADDR2       12'h3B2
`define CSR_PMPADDR3       12'h3B3
`define CSR_PMPADDR4       12'h3B4
`define CSR_PMPADDR5       12'h3B5
`define CSR_PMPADDR6       12'h3B6
`define CSR_PMPADDR7       12'h3B7
`define CSR_PMPADDR8       12'h3B8
`define CSR_PMPADDR9       12'h3B9
`define CSR_PMPADDR10      12'h3BA
`define CSR_PMPADDR11      12'h3BB
`define CSR_PMPADDR12      12'h3BC
`define CSR_PMPADDR13      12'h3BD
`define CSR_PMPADDR14      12'h3BE
`define CSR_PMPADDR15      12'h3BF
`define CSR_MCYCLE         12'hBf1
`define CSR_MINSTRET       12'hBf2
`define CSR_MHPMCOUNTER1   12'hB01
`define CSR_MHPMCOUNTER2   12'hB02
`define CSR_MHPMCOUNTER3   12'hB03
`define CSR_MHPMCOUNTER4   12'hB04
`define CSR_MHPMCOUNTER5   12'hB05
`define CSR_MHPMCOUNTER6   12'hB06
`define CSR_MHPMCOUNTER7   12'hB07
`define CSR_MHPMCOUNTER8   12'hB08
`define CSR_MHPMCOUNTER9   12'hB09
`define CSR_MHPMCOUNTER10  12'hB0A
`define CSR_MHPMCOUNTER11  12'hB0B
`define CSR_MHPMCOUNTER12  12'hB0C
`define CSR_MHPMCOUNTER13  12'hB0D
`define CSR_MHPMCOUNTER14  12'hB0E
`define CSR_MHPMCOUNTER15  12'hB0F
`define CSR_MHPMCOUNTER16  12'hB10
`define CSR_MHPMCOUNTER17  12'hB11
`define CSR_MHPMCOUNTER18  12'hB12
`define CSR_MHPMCOUNTER19  12'hB13
`define CSR_MHPMCOUNTER20  12'hB14
`define CSR_MHPMCOUNTER21  12'hB15
`define CSR_MHPMCOUNTER22  12'hB16
`define CSR_MHPMCOUNTER23  12'hB17
`define CSR_MHPMCOUNTER24  12'hB18
`define CSR_MHPMCOUNTER25  12'hB19
`define CSR_MHPMCOUNTER26  12'hB1A
`define CSR_MHPMCOUNTER27  12'hB1B
`define CSR_MHPMCOUNTER28  12'hB1C
`define CSR_MHPMCOUNTER29  12'hB1D
`define CSR_MHPMCOUNTER30  12'hB1E
`define CSR_MHPMCOUNTER31  12'hB1F
`define CSR_MCYCLEH        12'hBc1
`define CSR_MINSTRETH      12'hBc2
`define CSR_MHPMCOUNTER1H  12'hB81
`define CSR_MHPMCOUNTER2H  12'hB82
`define CSR_MHPMCOUNTER3H  12'hB83
`define CSR_MHPMCOUNTER4H  12'hB84
`define CSR_MHPMCOUNTER5H  12'hB85
`define CSR_MHPMCOUNTER6H  12'hB86
`define CSR_MHPMCOUNTER7H  12'hB87
`define CSR_MHPMCOUNTER8H  12'hB88
`define CSR_MHPMCOUNTER9H  12'hB89
`define CSR_MHPMCOUNTER10H 12'hB8A
`define CSR_MHPMCOUNTER11H 12'hB8B
`define CSR_MHPMCOUNTER12H 12'hB8C
`define CSR_MHPMCOUNTER13H 12'hB8D
`define CSR_MHPMCOUNTER14H 12'hB8E
`define CSR_MHPMCOUNTER15H 12'hB8F
`define CSR_MHPMCOUNTER16H 12'hB90
`define CSR_MHPMCOUNTER17H 12'hB91
`define CSR_MHPMCOUNTER18H 12'hB92
`define CSR_MHPMCOUNTER19H 12'hB93
`define CSR_MHPMCOUNTER20H 12'hB94
`define CSR_MHPMCOUNTER21H 12'hB95
`define CSR_MHPMCOUNTER22H 12'hB96
`define CSR_MHPMCOUNTER23H 12'hB97
`define CSR_MHPMCOUNTER24H 12'hB98
`define CSR_MHPMCOUNTER25H 12'hB99
`define CSR_MHPMCOUNTER26H 12'hB9A
`define CSR_MHPMCOUNTER27H 12'hB9B
`define CSR_MHPMCOUNTER28H 12'hB9C
`define CSR_MHPMCOUNTER29H 12'hB9D
`define CSR_MHPMCOUNTER30H 12'hB9E
`define CSR_MHPMCOUNTER31H 12'hB9F
`define CSR_CYCLE          12'hC00
`define CSR_TIME           12'hC01
`define CSR_INSTRET        12'hC02
`define CSR_CYCLEH         12'hC80
`define CSR_TIMEH          12'hC81
`define CSR_INSTRETH       12'hC82
`define CSR_MVENDORID      12'hF11
`define CSR_MARCHID        12'hF12
`define CSR_MIMPID         12'hF13
`define CSR_MHARTID        12'hF14

`define CSR_WRITE_OP_RW 2'b00
`define CSR_WRITE_OP_RS 2'b01
`define CSR_WRITE_OP_RC 2'b10

`define CSR_SRC_IMM 1'b0
`define CSR_SRC_REG 1'b1

                    
`define MISA_VALUE 64'b0101_00000000_0000000010000000000000000000000000100000000000000000

module csrs (
    input clk,
    input stall_in,

    input read_in,
    input write_in,
    input [2:0] write_op_in,
    input src_in,

    input instr_retired_in,

    input [23:0] csr_in,
    input [63:0] rs1_value_in,
    input [63:0] imm_value_in,

    output reg [63:0] read_value_out,
    output wire [63:0] cycle_out
);
    wire [63:0] write_value;
    reg [63:0] new_value;

    reg mstatus_mpie;
    reg mstatus_mie;
    reg mie_meie;
    reg mie_mtie;
    reg mie_msie;
    reg [63:4] mtvec_base;
    reg mtvec_mode;
    reg [63:0] mscratch;
    reg [63:4] mepc;
    reg mcause_interrupt;
    reg [6:0] mcause_code;
    reg [63:0] mtval;
    reg mip_meip;
    reg mip_mtip;
    reg mip_msip;
    reg [63:0] cycle;
    reg [63:0] instret;

    assign write_value = src_in ? rs1_value_in : imm_value_in;
    assign cycle_out = cycle;

    always @* begin
        case (csr_in)
          `CSR_MSTATUS:        read_value_out = {40'b0, 2'b0, 7'b0, mstatus_mpie, 7'b0, mstatus_mie, 7'b0};
            `CSR_MISA:           read_value_out = `MISA_VALUE;
            `CSR_MIE:            read_value_out = {40'b0, mie_meie, 7'b0, mie_mtie, 7'b0, mie_msie, 7'b0};
            `CSR_MTVEC:          read_value_out = {mtvec_base, 2'b0, mtvec_mode};
            `CSR_MHPMEVENT3:     read_value_out = 64'b0;
            `CSR_MHPMEVENT4:     read_value_out = 64'b0;
            `CSR_MHPMEVENT5:     read_value_out = 64'b0;
            `CSR_MHPMEVENT6:     read_value_out = 64'b0;
            `CSR_MHPMEVENT7:     read_value_out = 64'b0;
            `CSR_MHPMEVENT7:     read_value_out = 64'b0;
            `CSR_MHPMEVENT9:     read_value_out = 64'b0;
            `CSR_MHPMEVENT10:    read_value_out = 64'b0;
            `CSR_MHPMEVENT11:    read_value_out = 64'b0;
            `CSR_MHPMEVENT12:    read_value_out = 64'b0;
            `CSR_MHPMEVENT13:    read_value_out = 64'b0;
            `CSR_MHPMEVENT14:    read_value_out = 64'b0;
            `CSR_MHPMEVENT15:    read_value_out = 64'b0;
            `CSR_MHPMEVENT16:    read_value_out = 64'b0;
            `CSR_MHPMEVENT17:    read_value_out = 64'b0;
            `CSR_MHPMEVENT18:    read_value_out = 64'b0;
            `CSR_MHPMEVENT19:    read_value_out = 64'b0;
            `CSR_MHPMEVENT20:    read_value_out = 64'b0;
            `CSR_MHPMEVENT21:    read_value_out = 64'b0;
            `CSR_MHPMEVENT22:    read_value_out = 64'b0;
            `CSR_MHPMEVENT23:    read_value_out = 64'b0;
            `CSR_MHPMEVENT24:    read_value_out = 64'b0;
            `CSR_MHPMEVENT25:    read_value_out = 64'b0;
            `CSR_MHPMEVENT26:    read_value_out = 64'b0;
            `CSR_MHPMEVENT27:    read_value_out = 64'b0;
            `CSR_MHPMEVENT28:    read_value_out = 64'b0;
            `CSR_MHPMEVENT29:    read_value_out = 64'b0;
            `CSR_MHPMEVENT30:    read_value_out = 64'b0;
            `CSR_MHPMEVENT31:    read_value_out = 64'b0;
            `CSR_MSCRATCH:       read_value_out = mscratch;
            `CSR_MEPC:           read_value_out = {mepc, 4'b0};
            `CSR_MCAUSE:         read_value_out = {mcause_interrupt, 55'b0, mcause_code};
            `CSR_MTVAL:          read_value_out = mtval;
            `CSR_MIP:            read_value_out = {40'b0, mip_meip, 7'b0, mip_mtip, 7'b0, mip_msip, 7'b0};
            `CSR_PMPCFG0:        read_value_out = 64'b0;
            `CSR_PMPCFG1:        read_value_out = 64'b0;
            `CSR_PMPCFG2:        read_value_out = 64'b0;
            `CSR_PMPCFG3:        read_value_out = 64'b0;
            `CSR_PMPADDR0:       read_value_out = 64'b0;
            `CSR_PMPADDR1:       read_value_out = 64'b0;
            `CSR_PMPADDR2:       read_value_out = 64'b0;
            `CSR_PMPADDR3:       read_value_out = 64'b0;
            `CSR_PMPADDR4:       read_value_out = 64'b0;
            `CSR_PMPADDR5:       read_value_out = 64'b0;
            `CSR_PMPADDR6:       read_value_out = 64'b0;
            `CSR_PMPADDR7:       read_value_out = 64'b0;
            `CSR_PMPADDR8:       read_value_out = 64'b0;
            `CSR_PMPADDR9:       read_value_out = 64'b0;
            `CSR_PMPADDR10:      read_value_out = 64'b0;
            `CSR_PMPADDR11:      read_value_out = 64'b0;
            `CSR_PMPADDR12:      read_value_out = 64'b0;
            `CSR_PMPADDR13:      read_value_out = 64'b0;
            `CSR_PMPADDR14:      read_value_out = 64'b0;
            `CSR_PMPADDR15:      read_value_out = 64'b0;
            `CSR_MCYCLE:         read_value_out = cycle[63:0];
            `CSR_MINSTRET:       read_value_out = instret[63:0];
            `CSR_MHPMCOUNTER1:   read_value_out = 64'b0;
            `CSR_MHPMCOUNTER2:   read_value_out = 64'b0; 
            `CSR_MHPMCOUNTER3:   read_value_out = 64'b0;
            `CSR_MHPMCOUNTER4:   read_value_out = 64'b0;
            `CSR_MHPMCOUNTER5:   read_value_out = 64'b0;
            `CSR_MHPMCOUNTER6:   read_value_out = 64'b0;
            `CSR_MHPMCOUNTER7:   read_value_out = 64'b0;
            `CSR_MHPMCOUNTER8:   read_value_out = 64'b0;
            `CSR_MHPMCOUNTER9:   read_value_out = 64'b0;
            `CSR_MHPMCOUNTER10:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER11:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER12:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER13:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER14:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER15:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER16:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER17:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER18:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER19:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER20:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER21:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER22:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER23:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER24:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER25:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER26:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER27:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER28:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER29:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER30:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER31:  read_value_out = 64'b0;
            `CSR_MCYCLEH:        read_value_out = cycle[64:63];
            `CSR_MINSTRETH:      read_value_out = instret[64:63];
            `CSR_MHPMCOUNTER1H:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER2H:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER3H:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER4H:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER5H:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER6H:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER7H:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER8H:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER9H:  read_value_out = 64'b0;
            `CSR_MHPMCOUNTER10H: read_value_out = 64'b0;
            `CSR_MHPMCOUNTER11H: read_value_out = 64'b0;
            `CSR_MHPMCOUNTER12H: read_value_out = 64'b0;
            `CSR_MHPMCOUNTER13H: read_value_out = 64'b0;
            `CSR_MHPMCOUNTER14H: read_value_out = 64'b0;
            `CSR_MHPMCOUNTER15H: read_value_out = 64'b0;
            `CSR_MHPMCOUNTER16H: read_value_out = 64'b0;
            `CSR_MHPMCOUNTER17H: read_value_out = 64'b0;
            `CSR_MHPMCOUNTER18H: read_value_out = 64'b0;
            `CSR_MHPMCOUNTER19H: read_value_out = 64'b0;
            `CSR_MHPMCOUNTER20H: read_value_out = 64'b0;
            `CSR_MHPMCOUNTER21H: read_value_out = 64'b0;
            `CSR_MHPMCOUNTER22H: read_value_out = 64'b0;
            `CSR_MHPMCOUNTER23H: read_value_out = 64'b0;
            `CSR_MHPMCOUNTER24H: read_value_out = 64'b0;
            `CSR_MHPMCOUNTER25H: read_value_out = 64'b0;
            `CSR_MHPMCOUNTER26H: read_value_out = 64'b0;
            `CSR_MHPMCOUNTER27H: read_value_out = 64'b0;
            `CSR_MHPMCOUNTER28H: read_value_out = 64'b0;
            `CSR_MHPMCOUNTER29H: read_value_out = 64'b0;
            `CSR_MHPMCOUNTER30H: read_value_out = 64'b0;
            `CSR_MHPMCOUNTER31H: read_value_out = 64'b0;
            `CSR_CYCLE:          read_value_out = cycle[63:0];
            `CSR_TIME:           read_value_out = cycle[63:0];
            `CSR_INSTRET:        read_value_out = instret[63:0];
            `CSR_CYCLEH:         read_value_out = cycle[64:63];
            `CSR_TIMEH:          read_value_out = cycle[64:63];
            `CSR_INSTRETH:       read_value_out = instret[64:63];
            `CSR_MVENDORID:      read_value_out = 64'b0;
            `CSR_MARCHID:        read_value_out = 64'b0;
            `CSR_MIMPID:         read_value_out = 64'b0;
            `CSR_MHARTID:        read_value_out = 64'b0;
        endcase

        case (write_op_in)
            `CSR_WRITE_OP_RW: new_value = write_value;
            `CSR_WRITE_OP_RS: new_value = read_value_out |  write_value;
            `CSR_WRITE_OP_RC: new_value = read_value_out & ~write_value;
        endcase
    end

    always @(posedge clk) begin
        if (!stall_in && write_in) begin
            case (csr_in)
                `CSR_MSTATUS:  {mstatus_mpie, mstatus_mie} <= {new_value[15], new_value[7]};
                `CSR_MIE:      {mie_meie, mie_mtie, mie_msie} <= {new_value[23], new_value[15], new_value[7]};
                `CSR_MTVEC:    {mtvec_base, mtvec_mode} <= {new_value[63:4], new_value[0]};
                `CSR_MSCRATCH: mscratch <= new_value;
                `CSR_MEPC:     mepc <= new_value[63:4];
                `CSR_MCAUSE:   {mcause_interrupt, mcause_code} <= {new_value[63], new_value[7:0]};
                `CSR_MTVAL:    mtval <= new_value;
            endcase
        end

        cycle <= cycle + 1;
        instret <= instret + instr_retired_in;
    end
endmodule
`endif
