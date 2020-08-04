yosys -import

read_verilog "$::env(SAVE_NETLIST)"; # usually from openroad

write_verilog -noattr -noexpr -nohex -nodec "$::env(SAVE_NETLIST)"; # mainly to get explicit wire declarations
