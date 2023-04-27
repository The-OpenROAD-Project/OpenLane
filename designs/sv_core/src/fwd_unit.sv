`timescale 1ns/1ps
`include "pipe_regs.svh"

module fwd_unit (
    input  data_fwd_t ex_stage_i, mem_stage_i,
    input  reg_meta_t dest_meta_i,
    output logic      load_use_stall_ao,
    output reg_meta_t dest_meta_o
);
  ///////////////////////////////////////
  // Individual Register Forward Units //
  ///////////////////////////////////////

  logic rs1_lus, rs2_lus;
  logic [31:0] rs1_updated, rs2_updated;

  reg_forwarder rs1_fwd_unit (
    .ex_stage_i,
    .mem_stage_i,
    .rs_i               (dest_meta_i.rs1),
    .rs_data_i          (dest_meta_i.rs1_data),
    .rs_used            (dest_meta_i.rs1_used),

    .rs_data_ao         (rs1_updated),
    .load_use_hazard_ao (rs1_lus)
  );

  reg_forwarder rs2_fwd_unit (
    .ex_stage_i,
    .mem_stage_i,
    .rs_i               (dest_meta_i.rs2),
    .rs_data_i          (dest_meta_i.rs2_data),
    .rs_used            (dest_meta_i.rs2_used),

    .rs_data_ao         (rs2_updated),
    .load_use_hazard_ao (rs2_lus)
  );

  ///////////////////////
  // Output assignment //
  ///////////////////////

  always_comb begin
    load_use_stall_ao = rs1_lus || rs2_lus;

    dest_meta_o = dest_meta_i;
    dest_meta_o.rs1_data = rs1_updated;
    dest_meta_o.rs2_data = rs2_updated;
  end

endmodule // forward_unit
