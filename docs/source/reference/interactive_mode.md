# Interactive Mode
You may run the flow interactively by using the `-interactive` option:

```sh
./flow.tcl -interactive
```

A tcl shell will be opened where the openlane package is automatically sourced:
```tcl
package require openlane
```

Then, you should be able to run the following main commands:

0. Any **valid** Tcl code.
1. `prep -design <design> [-tag TAG] [-config CONFIG] [-init_design_config] [-overwrite]`
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

```{note}
The commands should all be run in this order- skipping any may lead to
unexpected behavior.

You are free however to add any intermediate commands to achieve more complex
functionality.
```

The above commands can also be written in a file and passed to `flow.tcl` as shown:

```sh
./flow.tcl -interactive -file <file>
```

A comprehensive list of commands supported by OpenLane can be found
[here](./openlane_commands.md).