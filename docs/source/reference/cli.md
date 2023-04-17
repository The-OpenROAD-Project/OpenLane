# Command-Line Arguments

The following are the command-line arguments that can be passed to `flow.tcl`:

| Argument | Description |
| - | - |
| `-design <folder path>`  <br>(Optional) | Specifies the design folder. A design folder should contain a `config.json` or `config.tcl` file defining the design parameters. <br> If the folder is not found, ./designs directory is searched, and if this parameter is omitted, the current working directory is treated as the design. |
| `-config_file <file>`  <br>(Optional) | Specifies the design's configuration file for running the flow.  <br>For example, to run the flow using `./designs/spm/config2.tcl`  <br>Use run `./flow.tcl -design ./designs/spm -config_file ./designs/spm/config2.tcl`  <br>By default `config.tcl` is used, and if not found, `config.json` is used instead. |
| `-override_env` <br> Optional | Allows you to override certain configuration environment variables for this run. Format: `-override_env KEY1=VALUE1,KEY2=VALUE2` |
| `-expose_env` | Expose the following environment variables to `config.json` as configuration variables. Has no effect on config.tcl sourcing, which already has access to all environment variables. Format: `-expose_env KEY1,KEY2` |
| `-tag <name>`  <br>(Optional) | Specifies a "name" for a specific run. If the tag is not specified, a timestamp is generated for identification of that run.  |
| `-gui`  | Run the OpenROAD GUI to view the results of the run. Must be paired with `-tag <name>` to specify which tag to display.  |
| `-run_path <path>`  <br>(Optional) | Specifies a `path` to save the run in. By default the run is in `design_path/`, where the design path is the one passed to `-design` |
| `-src <verilog_source_file>`  <br>(Optional) | Sets the verilog source code file(s) in case of using `-init\_design\_config`.  <br>The default is that the source code files are under `design_path/src/`, where the design path is the one passed to `-design` |
| `-init_design_config`  <br>(Optional) | Creates a configuration file for a design. The config file is by default `openlane/config.json`, but can be overriden using the value from `-config_file`.  |
| `-add_to_designs` <br>(Optional) | Adds the design to the OpenLane folder instead of creating an `openlane` folder. This is the default behavior on earlier versions of OpenLane. |
| `-overwrite`  <br>(Optional) | Flag to overwrite an existing run with the same tag |
| `-interactive`  <br>(Optional) | Flag to run openlane flow in interactive mode |
| `-file <file_path>`  <br>(Optional) | Passes a script of interactive commands in interactive mode |
| `-synth_explore`  <br>(Boolean) | If enabled, synthesis exploration will be run (only synthesis exploration), which will try out the available synthesis strategies against the input design. The output will be the four possible gate level netlists under &lt;run_path/results/synthesis&gt; and a summary report under reports that compares the 4 outputs. |
| `-lvs`  <br>(Boolean) | If enabled, only LVS will be run on the design. in which case the user must also pass: -design DESIGN\_DIR -gds DESIGN\_GDS -net DESIGN_NETLIST. |
| `-drc`  <br>(Boolean) | If enabled, only DRC will be run on the design. in which case the user must also pass: -design DESIGN\_DIR -gds DESIGN\_GDS -report OUTPUT\_REPORT\_PATH -magicrc MAGICRC. |
| `-save`  <br>(Optional) |  A flag to save a runs results like .mag and .lef in the design's folder. |
| `-save_path <path>`  <br>(Optional) | Specifies a different path to save the design's result. This option is to be used with the `-save` flag. |
| `-verbose <level>` <br>(Optional) | Specifies a level of verbosity. 0, the default, only outputs high-level messages. 1 also outputs some of the inner workings of the flow scripts. 2 or higher forwards outputs from _all_ tools to your terminal. |
| `-test_mismatches <class>` <br>(Optional) | Test for mismatches between the OpenLane tool versions and the current environment. `all`, the default, tests all mismatches. `tools` tests all except the PDK. `pdk` only tests the PDK. `none` disables the check.<br> (Default: `all`) |
| `-ignore_mismatches` | If specified, halts the flow on detected environment mismatches. |