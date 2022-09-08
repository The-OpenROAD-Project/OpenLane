# Interactive Mode
You may run the flow interactively by using the `-interactive` option:

```
./flow.tcl -interactive
```

A tcl shell will be opened where the openlane package is automatically sourced:
```
% package require openlane
```

Then, you should be able to run the following main commands:

0. Any **valid** Tcl code.
1. `prep -design <design> -tag <tag> -config <config> -init_design_config -overwrite` similar to the command line arguments, design is required and the rest is optional
2. `run_synthesis`
3. `run_floorplan`
4. `run_placement`
5. `run_cts`
6. `run_routing`
7. `write_powered_verilog` followed by `set_netlist $::env(routing_logs)/$::env(DESIGN_NAME).powered.v`
8. `run_magic`
9. `run_magic_spice_export`
10. `run_magic_drc`
11. `run_lvs`
12. `run_antenna_check`


The above commands can also be written in a file and passed to `flow.tcl`:

```
./flow.tcl -interactive -file <file>
```

A more detailed list of all the commands supported by openlane could be found [here][0].

**Note 1:** Currently, configuration variables have higher priority over the above commands so if `RUN_MAGIC` is 0, command `run_magic` will have no effect.

**Note 2:** Currently, most of these commands must be run in the flow sequence and no steps should be skipped.

**Note 3:** You can pass the -design, -tag, etc.. flags to ```./flow.tcl -interactive``` directly without the need of entering the interactive mode and then executing the prep command.

[0]:./openlane_commands.md

