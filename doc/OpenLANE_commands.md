# OpenLANE Interactive Mode Commands

This page describes the list of commands available in openlane, their functionality, and their expected inputs and outputs.

**NOTE:** You must run the `prep` command before running any of the other commands, in order to have the necessary files and configurations loaded.

The Following list is available in the interactive mode: `./flow.tcl -interactive` and under:
```
% package require openlane 0.9
```
Which runs automatically when you enter the interactive mode.


## General Commands 

Most of the following commands' implementation exists in this [file][0]
 
| Command      | Flags                   | Description                                           |
|---------------|------------------------|-----------------------------------------|
| `set_netlist <netlist>`   | | Sets the current netlist used by the flow to `<netlist>` |
|    | `[-lec]` | Runs logic verification for the new netlist against the previous netlist. <br> Optional flag.       |
| `set_def <def>`   | | Sets the current def file used by the flow to `<def>` |
| `prep_lefs`   | | prepares the used lef files by the flow. This process includes merging the techlef and cells lef, generated a merged.lef and a merged_unpadded.lef. Both to be used by different stages of the flow.|
| `trim_lib`   | | prepares a liberty file (i.e. `LIB_SYNTH`) by trimming the `no_synth.cells` from another input liberty file (i.e. `$::env(LIB_SYNTH_COMPLETE)`).|
|    | `[-output <lib_file>]` | The lib file to output the trimmed liberty into. <br> Default: `$::env(LIB_SYNTH)` <br> Optional flag. |
|    | `[-input <lib_file>]` | The input liberty file to trim the cells from. <br> Default: `$::env(LIB_SYNTH_COMPLETE)` <br> Optional flag. |
| `source_config <config_file>`   | | Sources the configurations inside `<config_file>`, whether it is a tcl file or a json file.|
| `prep`  | | Prepares a run in openlane or loads a previously stopped run in order to proceed with it. It calls `trim_lib`, `prep_lefs`, `source_config`, and other procs to set all the needed environment variables.<br> It has similar flags to ./flow.tcl. |
|    | `-design <design_name>` |  Specifies the design folder. A design folder should contain a config.tcl definig the design parameters. <br> If the folder is not found, ./designs directory is searched.|
|    | `[-overwrite]` |  Flag to overwirte an existing run with the same tag. <br> Optional flag. |
|    | `[-run_path <path>]` |  Specifies a <code>path</code> to save the run in. By default the run is in <code>design_path/</code>, where the design path is the one passed to <code>-design</code> <br> Optional flag. |
|    | `[-tag <tag>]` |  Specifies a <code>name</code> for a specific run. If the tag is not specified, a timestamp is generated for identification of that run. <br> Can Specify the configuration file name in case of using <code>-init_design_config</code>. <br> Optional flag. |
|    | `[-init_design_config]` |  Creates a tcl configuration file for a design. <code>-tag &lt;name&gt;</code> can be added to rename the config file to <code>&lt;name&gt;.tcl</code>. <br> Optional flag.|
|    | `[-src <verilog_source>]` |  Sets the verilog source code file(s) in case of using `-init_design_config`. The default is that the source code files are under <code>design_path/src/</code>, where the design path is the one passed to <code>-design</code>. <br> Optional flag. |
|    | `[-config_tag <config_tag>]` |  Specifies the design's configuration file for running the flow. <br> For example, to run the flow using <code>designs/spm/config2.tcl</code> <br> Use run <code>./flow.tcl -design spm -config_tag config2.tcl</code> <br> By default <code>config.tcl</code> is used. <br> Optional flag. |
|    | `[-config_file <config_file>]` |  Specifies the design's configuration file for running the flow. <br> For example, to run the flow using <code>/spm/config2.tcl</code> <br> Use run <code>./flow.tcl -design /spm -config_file /spm/config2.tcl</code> <br> By default <code>config.tcl</code> is used. <br> Optional flag. |
|    | `[-disable_output]` |  Disables outputing to the terminal. <br> Optional flag.|
| `padframe_gen`   | | Generates the padframe for a design based on the files and configurations under `padframe_folder`. Also, it generates a padframe.cfg if it's not present. The padframe.cfg is a file that describes the order of the pads and their relative location on the chip.|
|    | `-folder <padframe_folder>` |  specifies the `<padframe_folder>` for the padframe generator. The folder should contain the following: `./mag/<mag files>`, `./verilog/<verilog files>`, and optionally `./mag/padframe.cfg`|
| `save_views` | | Saves the views of a given `run_tag` into the specifies `path`(s).|
|    | `-tag <run_tag>` |  Specifies the `<run_tag>` from which the views were generated.|
|    | `[-lef_path <path>]` |  Changes the save path for the lef files to `<path>`. <br> The default is the `<run_path>` under the `<design_path>` specified by the `<run_tag>` and the processed `design` <br> Optional flag.|
|    | `[-mag_path <path>]` |  Changes the save path for the mag files to `<path>`. <br> The default is the `<run_path>` under the `<design_path>` specified by the `<run_tag>` and the processed `design` <br> Optional flag.|
|    | `[-def_path <path>]` |  Changes the save path for the def files to `<path>`. <br> The default is the `<run_path>` under the `<design_path>` specified by the `<run_tag>` and the processed `design` <br> Optional flag.|
|    | `[-gds_path <path>]` |  Changes the save path for the gds files to `<path>`. <br> The default is the `<run_path>` under the `<design_path>` specified by the `<run_tag>` and the processed `design` <br> Optional flag.|
|    | `[-verilog_path <path>]` |  Changes the save path for the verilog files to `<path>`. <br> The default is the `<run_path>` under the `<design_path>` specified by the `<run_tag>` and the processed `design` <br> Optional flag.|
|    | `[-spice_path <path>]` |  Changes the save path for the spice files to `<path>`. <br> The default is the `<run_path>` under the `<design_path>` specified by the `<run_tag>` and the processed `design` <br> Optional flag.|
|    | `[-save_path <path>]` |  Changes the save path for the save path for all the types of files to `<path>`. <br> The default is the `<run_path>` under the `<design_path>` specified by the `<run_tag>` and the processed `design` <br> Optional flag.|
| `widen_site_width`   | | generates two new lef files (merged_wider.lef and merged_unpadded_wider.lef) with a widened site width based on the values of `WIDEN_SITE_IS_FACTOR` and `WIDEN_SITE`, more about those in the [configurations/readme.md][13].|
| `use_widened_lefs`   | | Switches to using the lef files with the widened site width in the flow.|
| `use_original_lefs`   | | Switches to using the normal lef files in the flow.|
| `label_macro_pins `   | | Labels the pins of a given macro def according to the netlist for lvs.|
|    | `-lef <lef_file>` |  LEF file needed to have a proper view of the netlist AND the input DEF.|
|    | `-netlist_def <def_file>` |  DEF view of the design that has the connectivity information.|
|    | `-pad_pin_name <pad_pin_name>` |  Name of the pin of the pad as it appears in the netlist def. |
|    | `[-output <output_def>]` |  Output labeled def file. <br> Defaults to the `CURRENT_DEF`. <br> Optional flag.|
|    | `[-extra_args <extra_args>]` | Gives extra control on the rest of the flags of the labeling script. For more information on the other args that the script supports, run: `python3 $OPENLANE_ROOT/scripts/label_macro_pins.py -h`. <br> Optional flag.|
| `write_verilog <filename>` | | Generates a verilog netlist from a given def file. Stores the resulting netlist in `<filename>`, and sets the generated netlist as the `CURRENT_NETLIST` used by the flow.|
|    | `[-def <def_file>]` |  DEF view of the design from which to generate the netlist. <br> Defaults to the `CURRENT_DEF`. <br> Optional flag.|
| `add_macro_obs` | |Creates and obstruction in def and lef files.|
|    | `-defFile <def_file>` |  DEF view of the design to write the obstruction into.|
|    | `-lefFile <lef_file>` |  LEF file of the design to write the obstruction into.|
|    | ` -obstruction <obstruction_name> ` |  Name of obstruction.|
|    | `[-placementX <base_x_coordinate>]` |  X coordinate to place the obstruction. <br> Defaults to 0. <br> Optional flag.|
|    | `[-placementY <base_y_coordinate>]` |  Y coordinate to place the obstruction. <br> Defaults to 0. <br> Optional flag.|
|    | `-sizeWidth <width>` |  The width of the obstruction.|
|    | `-sizeHeight <height>` |  The height of the macro obstruction.|
|    | `-fixed <val>` |  if `<val>` is 1, then the macro is set as FIXED, else it's set as PLACED in the def file.|
|    | `[-dbunit <val>]` | `<val>` reflects the value of the data base unit. <br> Defaults to 1000. <br> Optional flag.|
|    | `-layerNames <list_of_layer_names>` |  the list of layer names on which to place the obstruction. |
| `set_layer_tracks  ` | | sets the tracks on a layer to specific value.|
|    | `-defFile <def_file>` |  DEF view of the design in which to edit the tracks values.|
|    | `-layer <layer_name>` | layer to change.|
|    | `-valuesFile <file>` |  tmp file to read the new track values from.|
|    | `-originalFile <file>` |  tmp file to store the original value.|
| `padframe_extract_area` | | Returns the Diearea extracted from the given padframe configuration file. |
|    | `-cfg <padframe_configurations_file>` | The file containing the padframe information. |
| `set_core_dims` | | Extracts the core dimensions based on the existing set environment variables. The results are set into `CORE_WIDTH` and `CORE_HEIGHT`. |
|    | `-log_path <path>` | The path to write the logs into. |
| `run_spef_extraction` | | Runs SPEF extraction on the `::env(CURRENT_DEF)` file followed by Static Timing Analysis using OpenSTA. The results are reported under `<run_path>/reports/synthesis/opensta_spef_*`. |

## Checker Commands 

Most of the following commands' implementation exists in this [file][1]

| Command      | Flags                   | Description                                           |
|---------------|------------------------|-----------------------------------------|
| `check_synthesis_failure` | | Checks if any cells were unmapped or any latches were produced in the generated netlist by yosys. |
| `check_assign_statements` | | Checks if the netlist generated by yosys contains any assign statements. |


## Synthesis/Verilog Commands 

Most of the following commands' implementation exists in this [file][9]
 
| Command      | Flags                   | Description                                           |
|---------------|------------------------|-----------------------------------------|
| `get_yosys_bin` | | Returns the used binary for yosys. |
| `run_yosys` | | Runs yosys synthesis on the design processed in the flow (the design is set by the `prep` command). if `LEC_ENABLE` is set to 1, a logic verification will be run after generating the new netlist vs the previous netlist if it exists. |
|    | `[-output <output_file>]` | Sets the outputfile from yosys synthesis. Defaults to `/<run_path>/results/synthesis/<design_name>.synthesis.v`  <br> Optional flag.       |
| `run_sta` | | Runs OpenSTA timing analysis on the current design, and produces a log under `/<run_path>/logs/synthesis/` and timing reports under `/<run_path>/reports/synthesis/`. |
| `run_synthesis` | | Runs yosys synthesis on the current design as well as OpenSTA timing analysis on the generated netlist. The logs are produced under `/<run_path>/logs/synthesis/`, the timing reports are under `/<run_path>/reports/synthesis/`, and the synthesized netlist under `/<run_path>/results/synthesis/`. |
| `verilog_elaborate <optional args>` | | Runs on structural verilog (top-level netlists) and elaborates it. The `<optional args>` are used to control what is passed to `run_yosys` |
| `yosys_rewrite_verilog <filename>` | | Runs yosys to rewrite the verilog given in `<filename>` into the already set environment variable `SAVE_NETLIST`.  Mainly used to generate explicit wire declarations |
| `logic_equiv_check` | | Runs logic verification using yosys between the two given netlists. |
|    | `-lhs <verilog_netlist_file>` | The first netlist (lefthand-side) in the logic verification comparison. |
|    | `-rhs <verilog_netlist_file>` | The second netlist (righthand-side) in the logic verification comparison. |
| `verilog_to_verilogPower` | | Adds the power pins and connections to a verilog file. |
|    | `-input <verilog_netlist_file>` | The input verilog that doesn't contain the power pins and connections. |
|    | `-output <verilog_netlist_file>` | The output verilog file. |
|    | `-lef <lef_file>` | The LEF view with the power pins information. |
|    | `-power <power_pin>` | The name of the power pin. |
|    | `-ground <ground_pin>` | The name of the ground pin. |
| `write_powered_verilog` | | writes a verilog file that contains the power pins and connections from a DEF file. |
|    | `[-def <def_file>]` | The input DEF file. <br> Defaults to the `CURRENT_DEF` of the processed design. |
|    | `[-output_def <def_file>]` | The output DEF file. <br> Defaults to `/<run_path>/tmp/routing/<design_name>.powered.def` |
|    | `[-output_verilog] <verilog_netlist_file>` | The output verilog file. <br> Defaults to `/<run_path>/results/lvs/<design_name>.powered.v` |
|    | `[-lef <lef_file>]` | The LEF view with the power pins information. <br> Defaults to the `MERGED_LEF` |
|    | `[-power <power_pin>]` | The name of the power pin. <br> Defaults to `VDD_PIN` |
|    | `[-ground <ground_pin>]` | The name of the ground pin. <br> Defaults to `GND_PIN` |


## Floorplan Commands 

Most of the following commands' implementation exists in this [file][3]
 
| Command      | Flags                   | Description                                           |
|---------------|------------------------|-----------------------------------------|
| `init_floorplan_or` | | Runs floorplanning on the processed design using the openroad app. The resulting file is under `/<run_path>/tmp/floorplan/` . |
| `place_io` | | Runs io placement on the design processed using the openroad app. The resulting file is under `/<run_path>/tmp/floorplan/` . |
| `place_contextualized_io` | | contextualizes io placement on a given macro (the processed design) with the context of the higher macro that contains it. This allows the io pins to be placed in location closer to what they will be connected with on the bigger macro. The resuls are saved under `/<run_path>/tmp/floorplan/` . |
|    | `-lef <lef_file>` | LEF file needed to have a proper view of the top-level DEF |
|    | `-def <def_file>` | DEF view of the top-level design where the macro is instantiated.       |
| `tap_decap_or` | | Runs tap/decap placement on the design processed using the openroad app. The resulting file is under `/<run_path>/tmp/floorplan/` . |
| `chip_floorplan` | | Runs floorplanning on a chip removing pins section and other empty sections from the def. The resulting file is under `/<run_path>/tmp/floorplan/` . |
| `run_floorplan` | | Runs `init_floorplan_or`, `place_io`, and `tap_decap_or` on the processed design. The resulting files are under `/<run_path>/tmp/floorplan/` . |


## Placement Commands 

Most of the following commands' implementation exists in this [file][7]
 
| Command      | Flags                   | Description                                           |
|---------------|------------------------|-----------------------------------------|
| `global_placement_or` | | Runs global placement  on the processed design using the openroad app. The resulting file is under `/<run_path>/tmp/placement/` . |
| `global_placement` | | Runs global placement on the processed design using RePlace. The resulting file is under `/<run_path>/tmp/placement/` . |
| `detailed_placement_or` | | Runs detailed placement on the processed design using the openroad app. The resulting file is under `/<run_path>/results/placement/` . |
| `detailed_placement` | | Runs detailed placement on the processed design using OpenDP. The resulting file is under `/<run_path>/results/placement/` . |
| `add_macro_placement <macro_name> <x_coordinate> <y_coordinate> [<orientation>]` | | Writes a configuration file to be processed by `manual_macro_placement` by setting the initial placement of the macro `<macro_name>` to location (`<x_coordinate>`,`<y_coordinate>`) on the chip with the option of specifying the `<orientation>` as well. The line written will be appened to this configuration file `/run_path/tmp/macro_placements.cfg`. |
| `manual_macro_placement [f]` | | Uses the configuration file generated by `add_macro_placement` (`/run_path/tmp/macro_placements.cfg`) to manually initialize the placement of the macros to the locations determined in the file. It works on the currently processed design and it overwrites the `CURRENT_DEF`. if `f` is passed as the first argument, the placement will be fixed and final, and the placement tools will not be allowed to change it.|
| `basic_macro_placement` | | Runs basic macro placement on the chip level using the openroad app, and it overwrites the `CURRENT_DEF`. |
| `repair_wire_length`| | Runs resizer overbuffering to limit the wire length given in `MAX_WIRE_LENGTH` using the openroad app. |
| `run_openPhySyn` | | Runs OpenPhySyn timing optimizations: capacitance_violations, transition_violations, fanout_violations, and negative_slack_violations. |
| `run_placement`| | Runs global placement, then applies the optional optimizations, then runs the detailed placement. |

## CTS Commands 

Most of the following commands' implementation exists in this [file][2]
 
| Command      | Flags                   | Description                                           |
|---------------|------------------------|-----------------------------------------|
| `simple_cts` | | Runs clock tree synthesis using the simple cts application. The resulting file is under `/<run_path>/results/cts/` . <br> Not Advised to use. Legacy Command.|
|    | `-verilog <file>` | The input verilog file. |
|    | `-fanout <val>` | The maximum fanout value.       |
|    | `-clk_net <name>` | Clock net name.       |
|    | `-root_clk_buf <name>` | Root clk buffer name.       |
|    | `-clk_buf <list>` | List of the other clock buffers.       |
|    | `-clk_buf_input <pin_name>` | Clock buffer input pin name.  |
|    | `-clk_buf_output <pin_name>` | Clock buffer output pin name.    |
|    | `-cell_clk_port <name>` | Clock buffer port name.    |
|    | `-output <output_file>` | Output file path.    |
| `run_cts` | | Runs clock tree synthesis using the openroad app on the processed design. The resulting file is under `/<run_path>/results/cts/` . It also generates a the updated netlist using yosys and stores the results under `/<run_path>/results/synthesis` and runs yosys logic verification if enabled. |


## Fill Insertion/Diode Insertion Commands

Most of the following commands' implementation exists in this [file][8]
 
| Command      | Flags                   | Description                                           |
|---------------|------------------------|-----------------------------------------|
| `ins_fill_cells_or` | | Runs fill insertion on the processed design using the openroad app. The resulting file is under `/<run_path>/tmp/routing/` . |
| `ins_fill_cells` | | Runs fill insertion on the processed design using addspacers. The resulting file is under `/<run_path>/tmp/routing/` . |
| `ins_diode_cells` | | Runs diode insertion on the processed design using the openroad app. The resulting file is under `/<run_path>/tmp/routing/` . It also generates a the updated netlist using yosys and stores the results under `/<run_path>/results/synthesis` and runs yosys logic verification if enabled. |
| `heal_antenna_violators`   | | Replaces the not needed diodes with fake diodes based on the magic antenna report. Therefore, magic antenna check should be run before this step (`run_magic_antenna_check`). <br> Runs only if `DIODE_INSERTION_STRATEGY` is set to `2`|


## PDN Generation Commands

Most of the following commands' implementation exists in this [file][8]
 
| Command      | Flags                   | Description                                           |
|---------------|------------------------|-----------------------------------------|
| `gen_pdn` | | Runs power grid generation on the processed design using the openroad app. The resulting file is under `/<run_path>/tmp/routing/` . |


## Routing Commands 

Most of the following commands' implementation exists in this [file][8]
 
| Command      | Flags                   | Description                                           |
|---------------|------------------------|-----------------------------------------|
| `global_routing_or` | | Runs global routing  on the processed design using the openroad app. The resulting file is under `/<run_path>/tmp/routing/` . |
| `detailed_routing` | | Runs detailed routing on the processed design using TritonRoute. The resulting file is under `/<run_path>/results/routing/` . |
| `add_route_obs`| | Uses `GLB_RT_OBS` to insert obstruction for each macro in order to prevent routing for each specified layer on each macro. Check `GLB_RT_OBS` in the configurations documentation for more details.|
| `run_routing` | | Runs global routing, fill insertion, diode insertion, detailed routing, and SPEF extraction on the processed design. The resulting file is under `/<run_path>/results/routing/`. It also generates a pre_route netlist and a powered netlist using yosys and stores the results under `/<run_path>/results/synthesis` and `/<run_path>/results/lvs` respectively, and it runs yosys logic verification if enabled.|



## Magic Commands 

Most of the following commands' implementation exists in this [file][6]
 
| Command      | Flags                   | Description                                           |
|---------------|------------------------|-----------------------------------------|
| `run_magic` | | Streams the final GDS and a mag view. The resulting file is under `/<run_path>/results/magic/` . |
| `run_magic_drc` | | Runs a drc check on the `CURRENT_DEF`. The resulting file is under `/<run_path>/logs/magic/magic.drc` . |
| `run_magic_spice_export` | | Runs spice extractions on the processed design. The resulting file is under `/<run_path>/results/magic/` . |
| `export_magic_view` | | Export a mag view of a given def file. |
|    | `-def <def_file>` | The input DEF file. |
|    | `-output <output_file>` | The output mag file path. |
| `run_magic_antenna_check` | | Runs spice extractions on the processed design and performs antenna checks. The resulting file is under `/<run_path>/results/magic/` and `/<run_path>/reports/magic/` . |

## LVS Commands 

Most of the following commands' implementation exists in this [file][5]
 
| Command      | Flags                   | Description                                           |
|---------------|------------------------|-----------------------------------------|
| `run_lvs` | | Runs an lvs check between an extracted spice netlist (so `run_magic_spice_export` should be run before it.) and the current verilog netlist of the processed design `CURRENT_NETLIST`. The resulting file is under `/<run_path>/results/lvs/` and `/<run_path>/reports/lvs/`. |


## Utility Commands 

Most of the following commands' implementation exists in these files: [deflef][10] and [general][12]
 
| Command      | Flags                   | Description                                           |
|---------------|------------------------|-----------------------------------------|
| `generate_final_summary_report` | | Generates a final summary csv report of the most important statistics and configurations in the run. This command is controlled by the flag `$::env(GENERATE_FINAL_SUMMARY_REPORT)`. | 
|    | `[-output_file <output_file_path>]` | The ouput file path. <br> Defaults to being generated under `<run_path>/reports/`. |
| `remove_pins` | | Removes the pins' section from a given DEF file. |
|    | `-input <def_file>` | The input DEF file. |
| `remove_empty_nets` | | Removes the empty nets from a given DEF file. |
|    | `-input <def_file>` | The input DEF file. |
| `resize_die` | | Resizes the DIEAREA in a given DEF file to the given size. |
|    | `-def <def_file>` | The input DEF file. |
|    | `-area <list>` | The new coordinates of the DIEARA listed as (llx, lly, urx, ury). |
| `get_instance_position` | | Returns the position of a given instance from the DEF view file. |
|    | `-instance <instance_name>` | The name of the instance. |
|    | `[-def <def_file>]` | The input DEF file. <br> Defaults to `CURRENT_DEF` of the currently processed design. <br> Optional Flag. |
| `add_lefs` | | Merges the given `<-src>` LEF files to the existing processed LEF files. |
|    | `-src <lef_files>` | The input LEF files. |
| `merge_components` | | Merges the components section of two DEF files. |
|    | `-input1 <def_file>` | The first DEF file. |
|    | `-input2 <def_file>` | The second DEF file. |
|    | `-output <def_file>` | The output DEF file. |
| `move_pins` | | Moves the PINS section from one DEF file to another. |
|    | `-from <def_file>` | The input DEF file. |
|    | `-to <def_file>` | The target DEF file. |
| `zeroize_origin_lef` | | Zeroizes the origin of all views in a LEF file. |
|    | `-file <lef_file>` | The input LEF file. |
| `fake_display_buffer` | | Runs a fake display buffer for the pad generator. |
| `kill_display_buffer` | | Kills the fake display buffer. |
| `set_if_unset <var> <default_value>` | | If `<var>` doesn't exist/have a value, it will be set to `<default_value>`. |
| `try_catch <command>` | | A minimal try_catch block to execute the `<command>`. |
| `puts_err <text>` | | Prints `[ERROR]: ` followed by the `<text>` in red. |
| `puts_success <text>` | | Prints `[SUCCESS]: ` followed by the `<text>` in green. |
| `puts_warn <text>` | | Prints `[WARNING]: ` followed by the `<text>` in yellow. |
| `puts_info <text>` | | Prints `[INFO]: ` followed by the `<text>` in cyan. |



[0]: ./../scripts/tcl_commands/all.tcl
[1]:./../scripts/tcl_commands/checkers.tcl
[2]:./../scripts/tcl_commands/cts.tcl
[3]:./../scripts/tcl_commands/floorplan.tcl
[4]:./../scripts/tcl_commands/init_design.tcl
[5]:./../scripts/tcl_commands/lvs.tcl
[6]:./../scripts/tcl_commands/magic.tcl
[7]:./../scripts/tcl_commands/placement.tcl
[8]:./../scripts/tcl_commands/routing.tcl
[9]:./../scripts/tcl_commands/synthesis.tcl
[10]:./../scripts/utils/deflef_utils.tcl
[11]:./../scripts/utils/fake_display_buffer.tcl
[12]:./../scripts/utils/utils.tcl
[13]: ./../configuration/README.md


