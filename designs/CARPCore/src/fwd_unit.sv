`timescale 1ns/1ps
`include "pipe_regs.svh"

module fwd_unit #(parameter N_STAGES = 2,
                  parameter MEM_READ_STAGE = 1) (
            input  data_fwd_t [N_STAGES-1:0] data_fwd_i,
            input  reg_meta_t                dest_meta_i,
            output logic                     load_use_stall_ao,
            output reg_meta_t                dest_meta_o
);

    // Explicitly named intermediate nets
    logic lus_1;
    logic lus_2;


    always_comb begin
        dest_meta_o = dest_meta_i;
        load_use_stall_ao = '0;
        lus_1 = '0;
        lus_2 = '0;

        for (int i = 0; i < N_STAGES; i = i + 1) begin
            // RS1 forwarding
            if (dest_meta_i.rs1 == data_fwd_i[i].rd && 
                data_fwd_i[i].rf_wr_en && 
                data_fwd_i[i].valid) begin
                // RAW and Load Use Hazard handling. Either stall or forward
                if (i < MEM_READ_STAGE && data_fwd_i[i].mem_read)
                    lus_1 = '1;
                else
                    dest_meta_o.rs1_data = data_fwd_i[i].rd_data;
            end

            // RS2 forwarding
            if (dest_meta_i.rs2 == data_fwd_i[i].rd && 
                data_fwd_i[i].rf_wr_en && 
                data_fwd_i[i].valid) begin
                // RAW and Load Use Hazard handling. Either stall or forward
                if (i < MEM_READ_STAGE && data_fwd_i[i].mem_read)
                    lus_2 = '1;
                else
                    dest_meta_o.rs2_data = data_fwd_i[i].rd_data;
            end
        end

        load_use_stall_ao = (lus_2 != '0) || (lus_1 != '0);
    end

endmodule // forward_unit
