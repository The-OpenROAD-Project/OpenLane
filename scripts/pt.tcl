read_verilog $::env(RUN_DIR)/results/lvs/$::env(lvs_result_file_tag).powered.v
set link_path "platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"
link
read_parasitics $::env(RUN_DIR)/results/routing/18-$::env(DESIGN_NAME).tt.spef
source $::env(RUN_DIR)/results/cts/$::env(DESIGN_NAME).cts.sdc

report_timing -delay_type min
fix_eco_timing -type hold -buffer_list sky130_fd_sc_hd__dlygate4sd3_1

set wcfile $::env(RUN_DIR)/results/eco/${eco_iter}_wc.tcl
write_changes -format dctcl -output $wcfile

exec sed -i {s/-new_net_names //g} $wcfile
exec sed -i {s/([^0-9])\]/\1/g} $wcfile
exec sed -i {s/-new_cell_names //g} $wcfile
exec sed -i {s/[{}]//g} $wcfile
exec sed -i {s/\[get_pins //g} $wcfile
