# Tcl Commands

This page describes the list of commands available in OpenLane, their functionality, and their expected inputs and outputs.

**NOTE:** You must run the `prep` command before running any of the other commands, in order to have the necessary files and configurations loaded.

The following commands are available in the interactive mode: `./flow.tcl -interactive`, or in Tclsh using `% package require openlane 0.9`.

## General Commands

Most of the following commands' implementation exists in this [file][0]

| Command      | Flags                   | Description                                           |
|---------------|------------------------|-----------------------------------------|
| `set_netlist <netlist>`   | | Sets the current netlist used by the flow to `<netlist>` |
|    | `[-lec]` | Runs logic verification for the new netlist against the previous netlist, if `LEC_ENABLE` is set to 1. <br> Optional flag. |
| `set_def <def>`   | | Sets the current def file used by the flow to `<def>` |
| `prep_lefs`   | | prepares the used lef files by the flow. This process includes merging the techlef and cells lef, generating a merged.lef.|
| `trim_lib`   | | prepares a liberty file (i.e. `LIB_SYNTH`) by trimming the `NO_SYNTH_CELL_LIST` and `DRC_EXCLUDE_CELL_LIST` from another input liberty file (i.e. `$::env(LIB_SYNTH_COMPLETE)`). |
|    | `[-output <lib_file>]` | The lib file to output the trimmed liberty into. Required. |
|    | `[-input <lib_file>]` | The input liberty file to trim the cells from. Required. |
|    | `[-drc_exclude_only]` | If provided, it will only use `DRC_EXCLUDE_CELL_LIST` to create the exclude list. <br> Optional flag. |
| `gen_exclude_list`   | | generates an exclude list file for a liberty file (i.e. `LIB_SYNTH`) by concatenating the `NO_SYNTH_CELL_LIST` and `DRC_EXCLUDE_CELL_LIST` into the output file. |
|    | `-lib <lib_file_path>` | The lib file that the list will be trimmed from. This will general a `<-lib>.exclude.list` |
|    | `[-drc_exclude_only]` | If provided, it will only use `DRC_EXCLUDE_CELL_LIST` to create the exclude list. <br> Optional flag. |
|    | `[-create_dont_use_list]` | If provided, it will create an environment variable with the file content. The variable will be named `DONT_USE_CELLS`. <br> Optional flag. |
| `prep`  | | Prepares a run in openlane or loads a previously stopped run in order to proceed with it. It calls `trim_lib`, `prep_lefs`, `source_config`, and other procs to set all the needed environment variables.<br> It has similar flags to ./flow.tcl. |
|    | `-design <design_name>` |  Specifies the design folder. A design folder should contain a `config.tcl` or `config.json` file defining the design parameters. <br> If the folder is not found, the ./designs directory is searched for said file. |
|    | `-override_env` | Allows you to override certain configuration environment variables for this run. Format: `-override_env KEY1=VALUE1,KEY2=VALUE2` <br> Optional flag. |
|    | `-expose_env` | Expose the following environment variables to `config.json` as configuration variables. Has no effect on config.tcl sourcing, which already has access to all environment variables. Format: `-expose KEY1,KEY2` <br> Optional flag. |
|    | `[-overwrite]` |  Flag to overwirte an existing run with the same tag. <br> Optional flag. |
|    | `[-run_path <path>]` |  Specifies a <code>path</code> to save the run in. By default the run is in <code>design_path/</code>, where the design path is the one passed to <code>-design</code> <br> Optional flag. |
|    | `[-tag <tag>]` |  Specifies a <code>name</code> for a specific run. If the tag is not specified, a timestamp is generated for identification of that run. <br> Can Specify the configuration file name in case of using <code>-init_design_config</code>. <br> Optional flag. |
|    | `[-init_design_config]` |  Creates a tcl configuration file for a design. <code>-tag &lt;name&gt;</code> can be added to rename the config file to <code>&lt;name&gt;.tcl</code>. <br> Optional flag.|
|    | `[-src <verilog_source>]` |  Sets the verilog source code file(s) in case of using `-init_design_config`. The default is that the source code files are under <code>design_path/src/</code>, where the design path is the one passed to <code>-design</code>. <br> Optional flag. |
|    | `[-config_file <config_file>]` |  Specifies the design's configuration file for running the flow. <br> For example, to run the flow using <code>/spm/config2.tcl</code> <br> Use run <code>./flow.tcl -design /spm -config_file /spm/config2.tcl</code> <br> By default <code>config.tcl</code> is used. <br> Optional flag. |
|    | `[-verbose <level>]` |  Sets a verbose output level. 0 disables verbose information and tool outputs. 1 enables verbose information but disables tool outputs. 2 and greater outputs everything. More verbose levels may be added over time, so if you want absolutely all output, set it to something like 99.|
|    | `[-disable_output]` |  **Removed: Default Behavior** Disables outputing to the terminal. <br> Optional flag.|
| `padframe_gen`   | | Generates the padframe for a design based on the files and configurations under `padframe_folder`. Also, it generates a padframe.cfg if it's not present. The padframe.cfg is a file that describes the order of the pads and their relative location on the chip.|
|    | `-folder <padframe_folder>` |  specifies the `<padframe_folder>` for the padframe generator. The folder should contain the following: `./mag/<mag files>`, `./verilog/<verilog files>`, and optionally `./mag/padframe.cfg`|
| `save_views` | | Saves the views of a given `run_tag` into the specifies `path`(s).|
|    | `[-lef_path <path>]` |  Changes the save path for the lef files to `<path>`. <br> The default is the `<run_path>` under the `<design_path>` specified by the `<run_tag>` and the processed `design` <br> Optional flag.|
|    | `[-mag_path <path>]` |  Changes the save path for the mag files to `<path>`. <br> The default is the `<run_path>` under the `<design_path>` specified by the `<run_tag>` and the processed `design` <br> Optional flag.|
|    | `[-def_path <path>]` |  Changes the save path for the def files to `<path>`. <br> The default is the `<run_path>` under the `<design_path>` specified by the `<run_tag>` and the processed `design` <br> Optional flag.|
|    | `[-gds_path <path>]` |  Changes the save path for the gds files to `<path>`. <br> The default is the `<run_path>` under the `<design_path>` specified by the `<run_tag>` and the processed `design` <br> Optional flag.|
|    | `[-verilog_path <path>]` |  Changes the save path for the verilog files to `<path>`. <br> The default is the `<run_path>` under the `<design_path>` specified by the `<run_tag>` and the processed `design` <br> Optional flag.|
|    | `[-spice_path <path>]` |  Changes the save path for the spice files to `<path>`. <br> The default is the `<run_path>` under the `<design_path>` specified by the `<run_tag>` and the processed `design` <br> Optional flag.|
|    | `[-save_path <path>]` |  Changes the save path for the save path for all the types of files to `<path>`. <br> The default is the `<run_path>/results/final`.<br> Optional flag.|
|    | `-tag <run_tag>` |  **Removed:** Specifies the `<run_tag>` from which the views were generated.|
| `label_macro_pins `   | | Labels the pins of a given macro def according to the netlist for lvs.|
|    | `-lef <lef_file>` |  LEF file needed to have a proper view of the netlist AND the input DEF.|
|    | `-netlist_def <def_file>` |  DEF view of the design that has the connectivity information.|
|    | `-pad_pin_name <pad_pin_name>` |  Name of the pin of the pad as it appears in the netlist def. |
|    | `[-output <output_def>]` |  Output labeled def file. <br> Defaults to the `CURRENT_DEF`. <br> Optional flag.|
|    | `[-extra_args <extra_args>]` | Gives extra control on the rest of the flags of the labeling script. For more information on the other args that the script supports, run: `openroad -python $OPENLANE_ROOT/scripts/odbpy/label_macro_pins.py -h`. <br> Optional flag.|
| `write_verilog <filename>` | | Generates a verilog netlist from a given def file. Stores the resulting netlist in `<filename>` and updates `CURRENT_NETLIST`. |
|    | `[-def <def_file>]` | The def file to write a verilog netlist from. <br> Defaults to the `CURRENT_DEF`. <br> Optional flag.|
|    | `[-log <log_file>]` | A file to which the output of OpenROAD is logged. <br> Defaults to `/dev/null`. <br> Optional flag.|
|    | `[-powered]` | Add power and ground pins, and save to `CURRENT_POWERED_NETLIST` instead. <br> Optional flag. |  
| `add_macro_obs` | | Creates obstructions in def and lef files.|
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
| `extract_core_dims` | | Extracts the core dimensions based on the existing set environment variables. The results are set into `CORE_WIDTH` and `CORE_HEIGHT`. |
|    | `-log_path <path>` | The path to write the logs into. |
| `run_spef_extraction` | | Runs SPEF extraction on the `::env(CURRENT_DEF)` file followed by Static Timing Analysis using OpenSTA. The results are reported under `<run_path>/reports/<step>/opensta_spef_*`. |
| `run_antenna_check` | | Runs antenna checks based on the value of `::env(USE_ARC_ANTENNA_CHECK)`, either calling `run_or_antenna_check` or `run_magic_antenna_check`. |
| `run_or_antenna_check` | | Runs antenna checks using OpenROAD's Antenna Rule Checker on the `::env(CURRENT_DEF)`, the result is saved in `<run_path>/reports/signoff/antenna.rpt`|
| `save_state` | | Saves environment variables to  `<run_path>/config.tcl`, needed for -from -to|
| `run_sta` | | Runs OpenSTA timing analysis on the current design, and produces a log under `/<run_path>/logs/<step>/` and timing reports under `/<run_path>/reports/<step>/`. |
| `set_layer_tracks  ` | | **Removed:** sets the tracks on a layer to specific value.|
|    | `-defFile <def_file>` |  DEF view of the design in which to edit the tracks values.|
|    | `-layer <layer_name>` | layer to change.|
|    | `-valuesFile <file>` |  tmp file to read the new track values from.|
|    | `-originalFile <file>` |  tmp file to store the original value.|

## Checker Commands

Most of the following commands' implementation exists in this [file][1]

| Command      | Flags                   | Description                                           |
|---------------|------------------------|-----------------------------------------|
| `check_synthesis_failure` | | Checks if any cells were unmapped or any latches were produced in the generated netlist by yosys. |
| `check_assign_statements` | | Checks if the netlist generated by yosys contains any assign statements. |
| `check_floorplan_missing_lef` | | Checks if the LEF was properly read in the floorplan stage. This is to detect if EXTRA_LEFS isn't set correctly. |
| `check_floorplan_missing_pins` | | Checks if the LEF contains all pins, and that EXTRA_LEFS was set correctly. |
| `check_cts_clock_nets` | | Checks if clock tree synthesis was successful and clock nets were added. |
| `check_replace_divergence` | | Catches replace divergence and exits the flow because global placement failed. |
| `check_macro_placer_num_solns` | | Checks if macro placment was successful using basic placement. |
| `quit_on_tr_drc` | | Checks for DRC violations after routing and exits the flow if any was found. Controlled by `QUIT_ON_TR_DRC`. |
| `quit_on_magic_drc` | | Checks for DRC violations after magic DRC is executed and exits the flow if any was found. Controlled by `QUIT_ON_MAGIC_DRC`. |
| `quit_on_lvs_error` | | Checks for LVS errors after netgen LVS is executed and exits the flow if any was found. Controlled by `QUIT_ON_LVS_ERROR`. |
|    | `-log <file_parsed.log>` |  The parsed LVS log, generated at the end of running LVS. The reason why this is passed over is because there are two types of LVS and each produces a different report, and this might be expanded later. |
| `quit_on_illegal_overlaps` | | Checks for illegal overlaps during magic extraction. In some cases, these imply existing undetected shorts in the design. It also exits the flow if any was found. Controlled by `QUIT_ON_ILLEGAL_OVERLAPS`. |
|    | `-log <magic_ext_feedback.log>` |  The magic extraction feedback log, generated at the end of running Magic extractions. |


## Synthesis/Verilog Commands

Most of the following commands' implementation exists in this [file][9]

| Command      | Flags                   | Description                                           |
|---------------|------------------------|-----------------------------------------|
| `run_yosys` | | Runs yosys synthesis on the design processed in the flow (the design is set by the `prep` command). if `LEC_ENABLE` is set to 1, a logic verification will be run after generating the new netlist vs the previous netlist if it exists. |
|    | `[-output <output_file>]` | Sets the outputfile from yosys synthesis. <br> Defaults to `/<run_path>/results/synthesis/<design_name>.synthesis.v`  <br> Optional flag.       |
| `run_synthesis` | | Runs yosys synthesis on the current design as well as OpenSTA timing analysis on the generated netlist. The logs are produced under `/<run_path>/logs/synthesis/`, the timing reports are under `/<run_path>/reports/synthesis/`, and the synthesized netlist under `/<run_path>/results/synthesis/`. |
| `run_synth_exploration` | | Runs synthesis exploration, which will try out the available synthesis strategies against the input design. The output will be the four possible gate level netlists under `<run_path>/results/synthesis` and a summary report under `<run_path>/reports` that compares the 4 outputs. |
| `verilog_elaborate <optional args>` | | Runs on structural verilog (top-level netlists) and elaborates it. The `<optional args>` are used to control what is passed to `run_yosys` |
| `yosys_rewrite_verilog <filename>` | | Runs yosys to rewrite the verilog given in `<filename>` into the already set environment variable `SAVE_NETLIST`.  Mainly used to generate explicit wire declarations |
| `logic_equiv_check` | | Runs logic verification using yosys between the two given netlists. |
|    | `-lhs <verilog_netlist_file>` | The first netlist (lefthand-side) in the logic verification comparison. |
|    | `-rhs <verilog_netlist_file>` | The second netlist (righthand-side) in the logic verification comparison. |
| `get_yosys_bin` | | **Deprecated:** Returns the used binary for yosys. |
| `verilog_to_verilogPower` | | **Removed: Use `write_verilog -powered`** Adds the power pins and connections to a verilog file. |
|    | `-input <verilog_netlist_file>` | The input verilog that doesn't contain the power pins and connections. |
|    | `-output <verilog_netlist_file>` | The output verilog file. |
|    | `-lef <lef_file>` | The LEF view with the power pins information. |
|    | `-power <power_pin>` | The name of the power pin. |
|    | `-ground <ground_pin>` | The name of the ground pin. |
| `write_powered_verilog` | | writes a verilog file that contains the power pins and connections from a DEF file. It stores the result in `/<run_path>/results/lvs` |
|    | `[-odb <odb_file>]` | The input ODB file. <br> Defaults to the `CURRENT_ODB` of the processed design. |
|    | `[-output_def <def_file>]` | The output DEF file. Required. |
|    | `[-output_verilog <verilog_netlist_file>]` | The output verilog file. Required. |
|    | `[-lef <lef_file>]` | The LEF view with the power pins information. <br> Defaults to the `MERGED_LEF` |
|    | `[-power <power_pin>]` | The name of the power pin. <br> Defaults to `VDD_PIN` |
|    | `[-ground <ground_pin>]` | The name of the ground pin. <br> Defaults to `GND_PIN` |
|    | `[-powered_netlist <verilog_netlist_file>]` | The verilog netlist parsed from yosys that contains the internal power connections in case the design has internal macros file. <br> Defaults to `/<run_path>/tmp/synthesis/synthesis.pg_define.v` if `::env(SYNTH_USE_PG_PINS_DEFINES)` is defined, and to empty string otherwise. |

## Floorplan Commands

Most of the following commands' implementation exists in this [file][3]

| Command      | Flags                   | Description                                           |
|---------------|------------------------|-----------------------------------------|
| `init_floorplan` | | Runs floorplanning on the processed design using the openroad app. The resulting file is under `/<run_path>/tmp/floorplan/` . |
| `place_io` | | Runs io placement on the design processed using the openroad app. The resulting file is under `/<run_path>/tmp/floorplan/` . |
| `place_io_ol` | | Runs IO placement based on an input configuration file to place the pins in the orientation and order requiered by the user. |
|    | `[-lef <lef_file>]` | LEF file to be used. It must also include the technology information. <br> Defaults to `::env(MERGED_LEF)`. |
|    | `[-def <def_file>]` | DEF file to be used. <br> Defaults to `::env(CURRENT_DEF)`.       |
|    | `[-cfg <cfg_file>]` | configuration file containing the list of desired pin order. An example could be found [here][14]. The file should contain `#orientation` followed by the pin names each in a new line in the desired order. Between each orientation section there should be a new empty line. <br> Defaults to `::env(FP_PIN_ORDER_CFG)`.       |
|    | `[-horizontal_layer <val>]` |  The metal layer on which to place the io pins horizontally (top and bottom of the die). <br> Defaults to `::env(FP_IO_HMETAL)`.       |
|    | `[-vertical_layer <val>]` |  The metal layer on which to place the io pins vertically (left and right of the die). <br> Defaults to `::env(FP_IO_VMETAL)`.       |
|    | `[-vertical_mult <val>]` | A multiplier for vertical pin thickness. Base thickness is the pins layer minwidth. <br> Defaults to `::env(FP_IO_VTHICKNESS_MULT)`.       |
|    | `[-horizontal_mult <val>]` | A multiplier for horizontal pin thickness. Base thickness is the pins layer minwidth. <br> Defaults to `::env(FP_IO_HTHICKNESS_MULT)`.   |
|    | `[-vertical_ext <val>]` |  Extends the vertical io pins outside of the die by the specified units. <br> Defaults to `::env(FP_IO_VEXTEND)`.       |
|    | `[-horizontal_ext <val>]` |  Extends the horizontal io pins outside of the die by the specified units. <br> Defaults to `::env(FP_IO_HEXTEND)`.       |
|    | `[-length <val>]` | IO length to be used. <br> Defaults to maximum of `::env(FP_IO_VLENGTH)` and `::env(FP_IO_HLENGTH)`.       |
|    | `[-output_def <def_file>]` | output DEF file to be written. <br> Defaults to `<run_path>/tmp/floorplan/ioplacer.def`.       |
| `place_contextualized_io` | | contextualizes io placement on a given macro (the processed design) with the context of the higher macro that contains it. This allows the io pins to be placed in location closer to what they will be connected with on the bigger macro. The resuls are saved under `/<run_path>/tmp/floorplan/` . |
|    | `-lef <lef_file>` | LEF file needed to have a proper view of the top-level DEF |
|    | `-def <def_file>` | DEF view of the top-level design where the macro is instantiated.       |
| `tap_decap_or` | | Runs tap/decap placement on the design processed using the openroad app. The resulting file is under `/<run_path>/tmp/floorplan/` . |
| `chip_floorplan` | | Runs floorplanning on a chip removing pins section and other empty sections from the def. The resulting file is under `/<run_path>/tmp/floorplan/` . |
| `run_floorplan` | | Runs `init_floorplan`, followed by one of the io placement functions: if `::env(FP_PIN_ORDER_CFG)` is defined then `place_io_ol` is run; otherwise, if `::env(FP_CONTEXT_DEF)` and `::env(FP_CONTEXT_LEF)` are defined it runs `place_contextualized_io`, if nothing of those is defined then it runs the vanilla `place_io`. Then it runs `tap_decap_or` on the processed design. Finally, power grid is generated utilizing `::env(VDD_NETS)`, `::env(GND_NETS)`, and `::env(SYNTH_USE_PG_PINS_DEFINES)` if they are defined, otherwise vanilla  gen_pdn is used. The resulting files are under `/<run_path>/tmp/floorplan/` and `/<run_path>/results/floorplan/`. |
| `apply_def_template` | | Applies the DIE_AREA, pin names, and pin locations excluding power and ground pins from `::env(FP_DEF_TEMPLATE)` to the `::env(CURRENT_DEF)`. |

## Placement Commands

Most of the following commands' implementation exists in this [file][7]

| Command      | Flags                   | Description                                           |
|---------------|------------------------|-----------------------------------------|
| `global_placement_or` | | Runs global placement on the processed design using OpenROAD. The resulting file is under `/<run_path>/tmp/placement/` . |
| `global_placement` | Alias for `global_placement_or`. |
| `random_global_placement` | | Runs random global placement using a custom OpenROAD-based script. Useful for tiny designs. The resulting file is under `/<run_path>/tmp/placement/`. |
| `detailed_placement_or` | | Runs detailed placement on the processed design using OpenROAD. The resulting file is under `/<run_path>/results/placement/` . |
| `detailed_placement` | | Alias for `detailed_placement_or`. |
| `add_macro_placement <macro_name> <x_coordinate> <y_coordinate> [<orientation>]` | | Writes a configuration file to be processed by `manual_macro_placement` by setting the initial placement of the macro `<macro_name>` to location (`<x_coordinate>`,`<y_coordinate>`) on the chip with the option of specifying the `<orientation>` as well. The line written will be appened to this configuration file `/run_path/tmp/macro_placements.cfg`. |
| `manual_macro_placement [-f]` | | Uses the configuration file generated by `add_macro_placement` (`/run_path/tmp/macro_placements.cfg`) to manually initialize the placement of the macros to the locations determined in the file. It works on the currently processed design and it overwrites the `CURRENT_DEF`. if `-f` is passed as an argument, the placement will be fixed and final, and the placement tools will not be allowed to change it.|
| `basic_macro_placement` | | Runs basic macro placement on the chip level using the openroad app, and it writes into `::env(CURRENT_DEF).macro_placement.def`. |
| `run_resizer_design` | | Runs resizer design optimizations to insert buffers on nets to repair max slew, max capacitance, max fanout violations, and on long wires to reduce RC delay in the wire. It also resizes cells. |
| `run_placement`| | Runs global placement (`global_placement_or` or `random_global_placement` based on the value of `PL_RANDOM_GLB_PLACEMENT`), then applies the optional optimizations `repair_wire_length` followed by `run_openPhySyn` if enabled, then runs the detailed placement (`detailed_placement_or`). |

## CTS Commands

Most of the following commands' implementation exists in this [file][2]

| Command      | Flags                   | Description                                           |
|---------------|------------------------|-----------------------------------------|
| `run_cts` | | Runs clock tree synthesis using the openroad app on the processed design. The resulting file is under `/<run_path>/results/cts/`. It also generates a the updated netlist using yosys and stores the results under `/<run_path>/results/cts` and runs yosys logic verification if enabled. |
| `run_resizer_timing` | | Runs resizer timing optimizations which repairs setup and hold violations.  |


## Fill Insertion/Diode Insertion Commands

Most of the following commands' implementation exists in this [file][8]

| Command      | Flags                   | Description                                           |
|---------------|------------------------|-----------------------------------------|
| `ins_fill_cells` | | Runs fill insertion on the processed design using the openroad app. The resulting file is under `/<run_path>/tmp/routing/`.  |
| `ins_diode_cells_1` | | Runs diode insertion on the processed design using an opendb custom script following diode insertion strategies 1 and 2. The resulting file is under `/<run_path>/tmp/placement/` . It also generates a the updated netlist using yosys and stores the results under `/<run_path>/results/synthesis` and runs yosys logic verification if enabled. |
| `ins_diode_cells_4` | | Runs diode insertion on the processed design using an opendb custom script following diode insertion strategies 4 and 5. The resulting file is under `/<run_path>/tmp/placement/` . It also generates a the updated netlist using yosys and stores the results under `/<run_path>/results/synthesis` and runs yosys logic verification if enabled. |
| `heal_antenna_violators`   | | Replaces the not needed diodes with fake diodes based on the magic antenna report. Therefore, magic antenna check should be run before this step (`run_magic_antenna_check`). <br> Runs on `CURRENT_DEF` and only if `DIODE_INSERTION_STRATEGY` is set to `2`.|


## PDN Generation Commands

Most of the following commands' implementation exists in this [file][8]

| Command      | Flags                   | Description                                           |
|---------------|------------------------|-----------------------------------------|
| `gen_pdn` | | Runs basic power grid generation on the processed design using the openroad app. The resulting file is under `/<run_path>/tmp/floorplan/` . |
| `power_routing` | | Performs power routing on a chip level design. More details in [Chip Integration][15]. |
|    | `[-odb <odb_file>]` | The input ODB file. <br> Defaults to `CURRENT_ODB`. |
|    | `[-power <power_pin>]` | The name of the power pin. <br> Defaults to `VDD_PIN` |
|    | `[-ground <ground_pin>]` | The name of the ground pin. <br> Defaults to `GND_PIN` |
|    | `[-output_def <output_def_file>]` | The output DEF file path. <br> Defaults to `<run_path>/tmp/routing/$::env(DESIGN_NAME).power_routed.def` |
|    | `[-output_odb <output_odb_file>]` | The output ODB file path. <br> Defaults to `<run_path>/tmp/routing/$::env(DESIGN_NAME).power_routed.odb` |
| `run_power_grid_generation` | | Runs power grid generation with the advanced control options, `VDD_NETS`, `GND_NETS`, etc... This proc is capable of generating multiple power grid. Check [this documentation][16] for more details about controlling this command.

## Routing Commands

Most of the following commands' implementation exists in this [file][8]

| Command      | Flags                   | Description                                           |
|---------------|------------------------|-----------------------------------------|
| `global_routing` | | Runs global routing  on the processed design The resulting file is under `/<run_path>/tmp/routing/` . |
| `global_routing_fastroute` | | Runs global routing  on the processed design using the openroad app's fastroute. The resulting file is under `/<run_path>/tmp/routing/` . |
| `detailed_routing` | | Runs detailed routing on the processed design. The resulting file is under `/<run_path>/results/routing/` . |
| `detailed_routing_tritonroute` | | Runs detailed routing on the processed design using OpenROAD TritonRoute. The resulting file is under `/<run_path>/results/routing/` . 
| `apply_route_obs`| | Uses `GRT_OBS` to insert obstruction for each macro in order to prevent routing for each specified layer on each macro. Check `GRT_OBS` in the configurations documentation for more details.|
| `add_route_obs`| | Uses `GRT_OBS` to call `apply_route_obs`, then calls `apply_route_obs` again to apply obstructions over the whole die area based on the value of `GRT_MAXLAYER` up to the highest available metal layer.|
| `run_routing` | | Runs diode insertion based on the strategy, then adds the routing obstructions, followed by `global_routing`, then `ins_fill_cells`, `detailed_routing`, and finally SPEF extraction on the processed design. The resulting file is under `/<run_path>/results/routing/`. It also generates a pre_route netlist using yosys and stores the results under `/<run_path>/results/synthesis`, and it runs yosys logic verification if enabled. |
| `global_routing_cugr` | | **Removed: Aliases global_routing_fastroute**: Runs global routing  on the processed design using cugr. The resulting file is under `/<run_path>/tmp/routing/` . |
| `detailed_routing_drcu` | | **Removed: Aliases detailed_routing_tritonroute**: Runs detailed routing on the processed design using DRCU. The resulting file is under `/<run_path>/results/routing/` . |

## Magic Commands

Most of the following commands' implementation exists in this [file][6]

| Command      | Flags                   | Description                                           |
|---------------|------------------------|-----------------------------------------|
| `run_magic` | | Streams the final GDS and a mag view + a PNG screenshot of the layout. This is controlled by `RUN_MAGIC` and `TAKE_LAYOUT_SCROT`. The resulting file is under `/<run_path>/results/magic/` . |
| `run_magic_drc` | | Runs a drc check on the `CURRENT_DEF` or the `CURRENT_GDS` based on the value of `MAGIC_DRC_USE_GDS`. The resulting file is under `/<run_path>/logs/magic/magic.drc` . |
| `run_magic_spice_export` | | Runs spice extractions on the processed design. Based on the value of `MAGIC_EXT_USE_GDS` either the GDS or the DEF/LEF is used for the extraction. The resulting file is under `/<run_path>/results/magic/` . |
| `export_magic_view` | | Export a mag view of a given def file. |
|    | `-def <def_file>` | The input DEF file, the default is `::env(CURRENT_DEF)`. |
|    | `-output <output_file>` | The output mag file path. |
| `run_magic_antenna_check` | | Runs spice extractions on the processed design and performs antenna checks. The resulting file is under `/<run_path>/results/magic/` and `/<run_path>/reports/magic/` . |

## KLayout Commands

Most of the following commands' implementation exists in this [file][17]

| Command      | Flags                   | Description                                           |
|---------------|------------------------|-----------------------------------------|
| `run_klayout` | | Streams the back-up final GDSII, generates a PNG screenshot, then runs KLayout DRC deck on it. This is controlled by `RUN_KLAYOUT`, `TAKE_LAYOUT_SCROT` ,and `KLAYOUT_DRC_KLAYOUT_GDS`. The resulting file is under `/<run_path>/results/klayout/` . |
| `scrot_klayout` | | Export a PNG view of a given GDSII or DEF file. This is controlled by `TAKE_LAYOUT_SCROT`. |
|    | `[-log <log_file>]` | Output log file. |
|    | `[-layout <layout_file>]` | The input GDS or DEF file, the default is `::env(CURRENT_GDS)`. |
| `run_klayout_drc` | | Runs KLayout DRC on a given GDSII file. This is controlled by `RUN_KLAYOUT_DRC`. |
|    | `[-gds <gds_file>]` | The input GDS file, the default is `::env(CURRENT_GDS)`. |
|    | `[-stage <stage>]` | The output stage using the DRC, the default is `magic`. The `magic` implies that the drc was run on the default GDS which is produced by magic. |
| `run_klayout_gds_xor` | | Runs KLayout XOR on 2 GDSIIs. This is controlled by `RUN_KLAYOUT_XOR` and `KLAYOUT_XOR_GDS` and `KLAYOUT_XOR_XML`. |
|    | `[-layout1 <gds_file>]` | The input GDS file, the default is the magic generated GDSII under `<run_path>/results/magic/<design_name>.gds`. |
|    | `[-layout2 <gds_file>]` | The input GDS file, the default is the klayout generated GDSII under `<run_path>/results/klayout/<design_name>.gds`. |
|    | `[-output_gds <gds_file>]` | The output GDS file with the xor result, the default under `<run_path>/results/klayout/<design_name>.xor.gds`. |
|    | `[-output_xml <xml_file>]` | The output XML file with the xor result, the default under `<run_path>/results/klayout/<design_name>.xor.xml`. |
| `open_in_klayout` | | Opens a design in the KLayout GUI with MERGED_LEF for the cell/macro definitions. Useful as it works around KLayout's LEF import peculiarities. |
|    | `[-layout <def_file>]` | The input DEF file, the default is `::env(CURRENT_DEF)`. |

## LVS Commands

Most of the following commands' implementation exists in this [file][5]

| Command      | Flags                   | Description                                           |
|---------------|------------------------|-----------------------------------------|
| `run_lvs` | | Runs an lvs check between an extracted spice netlist `EXT_NETLIST` (so `run_magic_spice_export` should be run before it.) and the current verilog netlist of the processed design `CURRENT_NETLIST`. The resulting file is under `/<run_path>/results/lvs/` and `/<run_path>/reports/lvs/`. The LVS could be on the block/cell level or on the device/transistor level, this is controlled by the extraction type set by `MAGIC_EXT_USE_GDS`. If the GDS is used in extraction then the LVS will be run down to the device/transistor level, otherwise it will be run on the block/cell level which is the default behavior in OpenLane. |

## ERC Commands

Most of the following commands' implementation exists in this [file][18]

| Command      | Flags                   | Description                                           |
|---------------|------------------------|-----------------------------------------|
| `run_erc` | | Runs Circuit Validity Checker Electrical Rule Checking. Voltage aware ERC checker for CDL netlists. The output files exist under `<run-path>/results/cvc/`..|
| `run_lef_cvc` | | **Deprecated: Use run_erc**: Runs Circuit Validity Checker ERC on the output spice, which is a Circuit Validity Checker. Voltage aware ERC checker for CDL netlists. The output files exist under `<run-path>/results/cvc/`..|

## Utility Commands

Most of the following commands' implementation exists in these files: [deflef][10] and [general][12]

| Command      | Flags                   | Description                                           |
|---------------|------------------------|-----------------------------------------|
| `generate_final_summary_report` | | Generates a final summary csv report of the most important statistics and configurations in the run as well as a manufacturability report with the sumamry of DRC, LVS, and Antenna violations. This command is controlled by the flag `$::env(GENERATE_FINAL_SUMMARY_REPORT)`. |
|    | `[-output_file <output_file>]` | The ouput final summary csv report file path. <br> Defaults to being generated under `<run_path>/reports/metrics.csv`. |
|    | `[-man_report <man_report>]` | The ouput manufacturability report file path. <br> Defaults to being generated under `<run_path>/reports/manufacturability.rpt`. |
| `remove_pins` | | Removes pins from a given database. |
|    | `-input <odb_file>` | The ODB file to merge the components in to. <br> Defaults to `CURRENT_ODB`. |
|    | `-output <odb_file>` | The output ODB file. <br> Defaults to the value of `-input`. |
| `remove_nets` | | Removes nets from a given database. |
|    | `-input <odb_file>` | The ODB file to merge the components in to. <br> Defaults to `CURRENT_ODB`. |
|    | `-output <odb_file>` | The output ODB file. <br> Defaults to the value of `-input`. |
|    | `-rx <regular expression>` | A regular expression to match to delete a certain net. Must match whole name of the net. <br> Defaults to `.+` (matches everything.) |
|    | `-empty`
| `resize_die` | | Resizes the DIEAREA in a given DEF file to the given size. |
|    | `-def <def_file>` | The input DEF file. |
|    | `-area <list>` | The new coordinates of the DIEARA listed as (llx, lly, urx, ury). |
| `get_instance_position` | | Returns the position of a given instance from the DEF view file. |
|    | `-instance <instance_name>` | The name of the instance. |
|    | `[-def <def_file>]` | The input DEF file. <br> Defaults to `CURRENT_DEF` of the currently processed design. <br> Optional Flag. |
| `add_lefs` | | Merges the given `<-src>` LEF files to the existing processed LEF files. |
|    | `-src <lef_files>` | The input LEF files. |
| `merge_components` | | Appends the components of a `def` file into the current database. |
|    | `-input <odb_file>` | The ODB file to merge the components in to. <br> Defaults to `CURRENT_ODB`. |
|    | `-donor <def_file>` | The DEF file to merge components from. |
|    | `-output <odb_file>` | The output ODB file. <br> Defaults to the value of `-input`. |
| `relocate_pins` | | **Previously: `replace_pins`**: Moves pins that are common between a template DEF file and a database to the location specified in the template DEF. |
|    | `-input <odb_file>` | The ODB file to relocate the common pins of. <br> Defaults to `CURRENT_ODB`. |
|    | `-template <def_file>` | The DEF file to relocate pins to. |
|    | `-output <odb_file>` | The output ODB file. <br> Defaults to the value of `-input`. |
| `fake_display_buffer` | | Runs a fake display buffer for the pad generator. |
| `kill_display_buffer` | | Kills the fake display buffer. |
| `set_if_unset <var> <default_value>` | | If `<var>` doesn't exist/have a value, it will be set to `<default_value>`. |
| `try_catch <command>` | | A minimal try_catch block to execute the `<command>`. |
| `puts_err <text>` | | Prints `[ERROR]: ` followed by the `<text>` in red. |
| `puts_success <text>` | | Prints `[SUCCESS]: ` followed by the `<text>` in green. |
| `puts_warn <text>` | | Prints `[WARNING]: ` followed by the `<text>` in yellow. |
| `puts_info <text>` | | Prints `[INFO]: ` followed by the `<text>` in cyan. |
| `copy_gds_properties <arg_1.mag> <arg2.mag>` | | copies the GDS properties from `<arg_1.mag>` to `<arg2.mag>`. |
| `increment_index` | |  Increments `CURRENT_INDEX` by 1. |
| `index_file <file>` | | Adds an index prefix to the file name keeping it's path. The prefix is `CURRENT_INDEX`. The current value of the `CURRENT_INDEX` could be found in `<run_path>/config.tcl`. |
| `calc_total_runtime` | | Finalizes the generated `runtime.yaml` file for the design followed  with the total runtime from the beginning of the flow. |
|    | `[-status <status>]` | The status message printed in the file. <br> Defaults to `flow completed`. |
| `flow_fail` | | Calls `generate_final_summary_report`, calls `calc_total_runtime` with status `flow failed`, and finally prints `Flow Failed` to the terminal. |
| `find_all <ext>` | | Print a sorted list of *.ext files that are found in the current run directory. |
| `remove_empty_nets` | | **Deprecated: use `remove_nets -empty`** the empty nets from a given ODB file. |
|    | `-input <odb_file>` | The input ODB file. |
| `zeroize_origin_lef` | | **Removed:** Zeroizes the origin of all views in a LEF file. |
|    | `-file <lef_file>` | The input LEF file. |


[0]: ./../../../scripts/tcl_commands/all.tcl
[1]: ./../../../scripts/tcl_commands/checkers.tcl
[2]: ./../../../scripts/tcl_commands/cts.tcl
[3]: ./../../../scripts/tcl_commands/floorplan.tcl
[4]: ./../../../scripts/tcl_commands/init_design.tcl
[5]: ./../../../scripts/tcl_commands/lvs.tcl
[6]: ./../../../scripts/tcl_commands/magic.tcl
[7]: ./../../../scripts/tcl_commands/placement.tcl
[8]: ./../../../scripts/tcl_commands/routing.tcl
[9]: ./../../../scripts/tcl_commands/synthesis.tcl
[10]: ./../../../scripts/utils/deflef_utils.tcl
[11]: ./../../../scripts/utils/fake_display_buffer.tcl
[12]: ./../../../scripts/utils/utils.tcl
[13]: ./configuration.md
[14]: https://github.com/The-OpenROAD-Project/openlane/blob/master/designs/spm/pin_order.cfg
[15]: ../usage/chip_integration.md
[16]: ../usage/advanced_power_grid_control.md
[17]: ./../../../scripts/tcl_commands/klayout.tcl
[18]: ./../../../scripts/tcl_commands/cvc_rv.tcl
