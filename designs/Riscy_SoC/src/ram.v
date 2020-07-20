`ifndef RAM
`define RAM

module ram (
    input clk,
    input [63:0] address_in,
    input sel_in,
    output wire [63:0] read_value_out,
    input [7:0] write_mask_in,
    input [63:0] write_value_in
);
    reg [63:0] mem [4095:0];
    reg [63:0] read_value;

    assign read_value_out = sel_in ? read_value : 0;

    always @(negedge clk) begin
        read_value <= {mem[address_in[63:4]][7:0], mem[address_in[63:4]][15:8], mem[address_in[63:4]][23:16], mem[address_in[63:4]][63:24], mem[address_in[63:4]][39:32], mem[address_in[63:4]][47:40], mem[address_in[63:4]][55:48], mem[address_in[63:4]][63:56]};

        if (sel_in) begin
            if (write_mask_in[7])
                mem[address_in[63:4]][7:0] <= write_value_in[63:56]; 

            if (write_mask_in[6])
                mem[address_in[63:4]][15:8] <= write_value_in[55:48]; 

            if (write_mask_in[5])
                mem[address_in[63:4]][23:16] <= write_value_in[47:40]; 

            if (write_mask_in[4])
                mem[address_in[63:4]][31:24] <= write_value_in[39:32]; 

            if (write_mask_in[3])
                mem[address_in[63:4]][39:32] <= write_value_in[31:24]; 

            if (write_mask_in[2])
                mem[address_in[63:4]][47:40] <= write_value_in[23:16]; 

            if (write_mask_in[1])
                mem[address_in[63:4]][55:48] <= write_value_in[15:8];

            if (write_mask_in[0])
                mem[address_in[63:4]][63:56] <= write_value_in[7:0]; 
        end
    end
endmodule

`endif
