# Flow Configuration Variables
This page is the comprehensive manual for user-configurable flow variables
and their default values.
Variables that are defined by the PDK configuration support files and not the
flow itself are listed [in this chapter](./pdk_configuration.md).

:::{admonition} A couple things to keep in mind
* This is a comprehesive list- there are many variables here you would never
  need to touch. If you want just a brief list of variables you should be
  using, see the usage guide [Hardening Macros](../usage/hardening_macros.md).

* Deprecated variables are automatically translated to their new names for at
  least 6 months. Removed variables will be entirely ignored by the flow.

* Variables prefixed `RUN_` enable or disable a certain step as part of the
  larger OpenLane flow, not when calling the relevant function standalone.
  For example, if RUN_DRT is set 0, but calling `detailed_routing` in
  interactive mode will still run detailed routing.
:::

## General

```{warning}
The `` `include `` directive is *not* supported in Verilog files. List all the
files you may be depending on, including headers, in `VERILOG_FILES`.
```

|Variable|Description|
|-|-|
| `PDK` <a id="PDK"></a> | Specifies the process design kit (PDK). <br> (Default: `sky130A`)|
| `DESIGN_NAME` <a id="DESIGN_NAME"></a>   | The name of the top level module of the design        |
| `VERILOG_FILES` <a id="VERILOG_FILES"></a> | The path of the design's Verilog files, provided as an array of files in JSON or a whitespace-delimited list of files in Tcl. The files are evaluated in order, i.e., if file B depends on file A, file A must be listed first. |
| `CLOCK_PERIOD` <a id="CLOCK_PERIOD"></a>  | The clock period used for clocks in the design, in nanoseconds.  |
| `CLOCK_PORT` <a id="CLOCK_PORT"></a>    | The name of the design's clock port.   |
| `CLOCK_NET` <a id="CLOCK_NET"></a> | The name of the net input to root clock buffer. <br> (Default: `CLOCK_PORT`) |
| `STD_CELL_LIBRARY` <a id="STD_CELL_LIBRARY"></a> | Specifies the standard cell library to be used under the specified PDK. <br> (Default: `sky130_fd_sc_hd`)|
| `STD_CELL_LIBRARY_OPT` <a id="STD_CELL_LIBRARY_OPT"></a> | Specifies the standard cell library to be used during resizer optimizations. <br> (Default: `STD_CELL_LIBRARY`)|
| `PDK_ROOT` <a id="PDK_ROOT"></a> | Specifies the folder path of the PDK. It searches for a `config.tcl` in `$::env(PDK_ROOT)/$::env(PDK)/libs.tech/openlane/` directory and at least have one standard cell library config defined in `$::env(PDK_ROOT)/$::env(PDK)/libs.tech/openlane/$::env(STD_CELL_LIBRARY)`. |
| `DIODE_PADDING` <a id="DIODE_PADDING"></a> | Number of sites to left pad `DIODE_CELL` during detailed placement. <br> (Default: `2` sites)|
| `MERGED_LEF` <a id="MERGED_LEF"></a> | Points to `merged.lef`, which is a merger of various LEF files, including the technology lef, cells lef, any custom lefs, and IO lefs. |
| `NO_SYNTH_CELL_LIST` <a id="NO_SYNTH_CELL_LIST"></a> | Specifies the file that contains the don't-use-cell-list to be excluded from the liberty file during synthesis. If it's not defined, this path is searched `$::env(PDK_ROOT)/$::env(PDK)/libs.tech/openlane/$::env(STD_CELL_LIBRARY)/no_synth.cells` and if it's not found, then the original liberty will be used as is. |
| `DRC_EXCLUDE_CELL_LIST` <a id="DRC_EXCLUDE_CELL_LIST"></a> | Specifies the file that contains the don't-use-cell-list to be excluded from the liberty file during synthesis and timing optimizations. If it's not defined, this path is searched `$::env(PDK_ROOT)/$::env(PDK)/libs.tech/openlane/$::env(STD_CELL_LIBRARY)/drc_exclude.cells` and if it's not found, then the original liberty will be used as is. In other words, `DRC_EXCLUDE_CELL_LIST` contain the only excluded cell list in timing optimizations. |
| `BASE_SDC_FILE` <a id="BASE_SDC_FILE"></a> | Specifies the base SDC file using during the flow. It is the default SDC file used for `PNR_SDC_FILE` and `SIGNOFF_SDC_FILE` <br> (Default: `$::env(OPENLANE_ROOT)/scripts/base.SDC`) |
| `PNR_SDC_FILE` <a id="PNR_SDC_FILE"></a> | Specifies the SDC file used during all implementation (PnR) stages. It is used by tools in the flow and during STA done at these stages. It is *not* used during signoff stage. <br> (Default: `$::env(BASE_SDC_FILE)`) |

### Macros/Chip Integration

|Variable|Description|
|-|-|
| `VERILOG_FILES_BLACKBOX` <a id="VERILOG_FILES_BLACKBOX"></a> | Black-boxed, Verilog files where the implementation is ignored. Useful for pre-hardened macros you incorporate into your design, used during synthesis and OpenSTA. `/// sta-blackbox` can be added to a file in order to skip that file while doing STA. This will blackbox all the modules defined inside that file. It is recommended to provide a gatelevel netlist whenever possible to do full STA. |
| `EXTRA_LEFS` <a id="EXTRA_LEFS"></a> | Specifies LEF files of pre-hardened macros used in the current design, used in placement and routing. |
| `EXTRA_LIBS` <a id="EXTRA_LIBS"></a> | Specifies LIB files of pre-hardened macros used in the current design, used during timing analysis. (Optional) |
| `EXTRA_GDS_FILES` <a id="EXTRA_GDS_FILES"></a> | Specifies GDS files of pre-hardened macros used in the current design, used during tape-out. |

## Linting

* If you're running a hierarchical design (i.e. one that incorporates Macros
  or directly instantiates SCLs), Linting may not work correctly. You have two
  options:
    1. Provide blackboxes for all gate-level models instantiated by the top level
    design or any of its macros.
        * Files in `VERILOG_FILES_BLACKBOX` will not be included by default.
        * 
    2. Disable linting altogether.

|Variable|Description|
|-|-|
| `RUN_LINTER` <a id="RUN_LINTER"></a> | Enable linter (currently Verilator) <br> (Default: `1`)
| `LINTER_RELATIVE_INCLUDES` <a id="LINTER_RELATIVE_INCLUDES"></a>‡ | When a file references an include file, resolve the filename relative to the path of the referencing file, instead of relative to the current directory. <br> (Default: `1`) |
| `LINTER_DEFINES` <a id="LINTER_DEFINES"></a> | A list of defines that are passed to the linter. The syntax for each item in the list is as follows `<define>(=<value>)`. `(=value)` is optional. Both `PnR=1` or `PnR` are accepted <br> (Default: `SYNTH_DEFINES`) |
| `LINTER_INCLUDE_PDK_MODELS` <a id="LINTER_INCLUDE_PDK_MODELS"></a> | Enables including verilog models of the pdk with the linter. This is useful when the design has hand instantiated macros. This variable has no effect if the PDK/STD_CELL_LIBRARY aren't supported. Currently, sky130A/sky130_fd_sc_hd and sky130B/sky130_fd_sc_hd are the only ones supported <br> (Default: `1`) |

> **‡** Variable previously prefixed `VERILATOR_` have had their prefix changed to `LINTER_`. The replaced variable is deprecated and will be translated to its new form automatically by the flow.

## Synthesis

|Variable|Description|
|-|-|
| `SYNTH_AUTONAME` <a id="SYNTH_AUTONAME"></a> | Add a synthesis step to generate names for instances. This results in instance names that can be very long, but may be more useful than the internal names that are six digit numbers. <br> Enabled = 1, Disabled = 0 <br> (Default: `0`)|
| `SYNTH_BIN` <a id="SYNTH_BIN"></a> | The yosys binary used in the flow. <br> (Default: `yosys`) |
| `SYNTH_DEFINES` <a id="SYNTH_DEFINES"></a> | Specifies verilog defines. Variable should be provided as a json/tcl list. <br> (Default: None) |
| `SYNTH_CLOCK_UNCERTAINTY` <a id="SYNTH_CLOCK_UNCERTAINTY"></a>  | Specifies a value for the clock uncertainty/jitter for timing analysis. <br> (Default: `0.25`) |
| `SYNTH_CLOCK_TRANSITION` <a id="SYNTH_CLOCK_TRANSITION"></a>  |  Specifies a value for the clock transition /slew for timing analysis. <br> (Default: `0.15`) |
| `SYNTH_TIMING_DERATE` <a id="SYNTH_TIMING_DERATE"></a>  | Specifies a derating factor to multiply the path delays with. It specifies the upper and lower ranges of timing. <br> (Default: `+5%/-5%`) |
| `SYNTH_STRATEGY` <a id="SYNTH_STRATEGY"></a> | Strategies for abc logic synthesis and technology mapping <br> Possible values are `DELAY/AREA 0-4/0-3`; the first part refers to the optimization target of the synthesis strategy (area vs. delay) and the second one is an index. <br> (Default: `AREA 0`)|
| `SYNTH_BUFFERING` <a id="SYNTH_BUFFERING"></a> | Enables abc cell buffering <br> Enabled = 1, Disabled = 0 <br> (Default: `1`)|
| `SYNTH_SIZING` <a id="SYNTH_SIZING"></a> | Enables abc cell sizing (instead of buffering) <br> Enabled = 1, Disabled = 0 <br> (Default: `0`)|
| `SYNTH_NO_FLAT` <a id="SYNTH_NO_FLAT"></a> | A flag that disables flattening the hierarchy during synthesis, only flattening it after synthesis, mapping and optimizations. <br> Enabled = 1, Disabled = 0 <br> (Default: `0`)|
| `SYNTH_SHARE_RESOURCES` <a id="SYNTH_SHARE_RESOURCES"></a> | A flag that enables yosys to reduce the number of cells by determining shareable resources and merging them. <br> Enabled = 1, Disabled = 0 <br> (Default: `1`)|
| `SYNTH_ABC_LEGACY_REFACTOR` <a id="SYNTH_ABC_LEGACY_REFACTOR"></a> | Replaces the ABC command `drf -l` with `refactor` which matches older versions of OpenLane but is more unstable.  <br> Enabled = 1, Disabled = 0 <br> (Default: `0`) |
| `SYNTH_ABC_LEGACY_REWRITE` <a id="SYNTH_ABC_LEGACY_REWRITE"></a> | Replaces the ABC command `drw -l` with `rewrite` which matches older versions of OpenLane but is more unstable.  <br> Enabled = 1, Disabled = 0 <br> (Default: `0`) |
| `SYNTH_ADDER_TYPE` <a id="SYNTH_ADDER_TYPE"></a> | Adder type to which the $add and $sub operators are mapped to. <br> Possible values are `YOSYS/FA/RCA/CSA`; where `YOSYS` refers to using Yosys internal adder definition, `FA` refers to full-adder structure, `RCA` refers to ripple carry adder structure, and `CSA` refers to carry select adder. <br> (Default: `YOSYS`)|
| `SYNTH_EXTRA_MAPPING_FILE` <a id="SYNTH_EXTRA_MAPPING_FILE"></a> | Points to extra techmap file for yosys that runs right after yosys `synth` before generic techmap. <br> (Default: `""`)|
| `SYNTH_PARAMETERS` <a id="SYNTH_PARAMETERS"></a> | Whitespace-delimited key value pairs to be `chparam`ed in Yosys. In the format `key1=value1 key2=value2` <br> (Default: None)  |
| `SYNTH_ELABORATE_ONLY` <a id="SYNTH_ELABORATE_ONLY"></a> | "Elaborate" the design only without attempting any logic mapping. Useful when dealing with structural Verilog netlists. <br> (Default: `0`) |
| `VERILOG_INCLUDE_DIRS` <a id="VERILOG_INCLUDE_DIRS"></a> | Specifies the verilog includes directories. <br> Optional. |
| `SYNTH_FLAT_TOP` <a id="SYNTH_FLAT_TOP"></a> | Specifies whether or not the top level should be flattened during elaboration. 1 = True, 0= False <br> (Default: `0`)|
| `IO_PCT` <a id="IO_PCT"></a> | Specifies the percentage of the clock period used in the input/output delays. Ranges from 0 to 1.0. <br> (Default: `0.2`) |
| `SYNTH_BUFFER_DIRECT_WIRES` <a id="SYNTH_BUFFER_DIRECT_WIRES"></a> | Insert buffer cells into the design for directly connected wires. <br> (Default: `1`) |
| `SYNTH_SPLITNETS` <a id="SYNTH_SPLITNETS"></a> | Splits multi-bit nets into single-bit nets. <br> (Default: `1`) |
| `SYNTH_TOP_LEVEL` <a id="SYNTH_TOP_LEVEL"></a> | **Deprecated: Use `SYNTH_ELABORATE_ONLY`**: "Elaborate" the design only without attempting any logic mapping. Useful when dealing with structural Verilog netlists. |
| `SYNTH_MAX_FANOUT` <a id="SYNTH_MAX_FANOUT"></a>  | **Deprecated: Use the PDK's `MAX_FANOUT_CONSTRAINT` value**: The max load that the output ports can drive. |
| `SYNTH_MAX_TRAN` <a id="SYNTH_MAX_TRAN"></a> |  **Deprecated: Use the PDK's `MAX_TRANSITION_CONSTRAINT` value**: The max transition time (slew) from high to low or low to high on cell inputs in ns. If unset, the library's default maximum transition time will be used. |
| `SYNTH_READ_BLACKBOX_LIB` <a id="SYNTH_READ_BLACKBOX_LIB"></a> | **Removed: The liberty file is always read now. A flag that enable reading the full(untrimmed) liberty file as a blackbox for synthesis. Please note that this is not used in technology mapping. This should only be used when trying to preserve gate instances in the rtl of the design.  <br> Enabled = 1, Disabled = 0 <br> (Default: `0`)|
## Static Timing Analysis (STA)

| Variable | Description |
|-|-|
| `STA_REPORT_POWER` <a id="STA_REPORT_POWER"></a> | Enables reporting power in sta. <br> (Default: `1`) |
| `EXTRA_SPEFS` <a id="EXTRA_SPEFS"></a> | Specifies min, nom, max spef files for modules(s). Variable should be provided as a json/tcl list or a space delimited tcl string. Note that a module name is provided not an instance name. A module may have multiple instances. Each module must have define 3 files, one for each corner. For example: `module1 min1 nom1 max1 module2 min2 nom2 max2`. A file can be used multiple time in case of absence of other corner files. For example: `module nom nom nom`. In this case, the nom file will be used in all corners of sta. At all times a module must specify 3 files.  <br> (Default: None) |
| `STA_WRITE_LIB` <a id="STA_WRITE_LIB"></a> | Controls whether a timing model is written using OpenROAD OpenSTA after static timing analysis. This is an option as it in its current state, the timing model generation (and the model itself) can be quite buggy. <br> (Default: `1`) |

## Floorplanning (FP)

|Variable|Description|
|-|-|
| `RUN_TAP_DECAP_INSERTION` <a id="RUN_TAP_DECAP_INSERTION"></a> | Enables tap and decap cells insertion after floorplanning. 1 = Enabled, 0 = Disabled <br> (Default: `1`) |
| `FP_CORE_UTIL` <a id="FP_CORE_UTIL"></a>  | The core utilization percentage. <br> (Default: `50` percent)|
| `FP_ASPECT_RATIO` <a id="FP_ASPECT_RATIO"></a>  | The core's aspect ratio (height / width). <br> (Default: `1`)|
| `FP_SIZING` <a id="FP_SIZING"></a>  | Whether to use relative sizing by making use of `FP_CORE_UTIL` or absolute one using `DIE_AREA`. <br> (Default: `"relative"` - accepts `"absolute"` as well)|
| `DIE_AREA` <a id="DIE_AREA"></a>  | Specific die area to be used in floorplanning when `FP_SIZING` is set to `absolute`. Specified as a 4-corner rectangle "x0 y0 x1 y1". Units in μm <br> (Default: unset)|
| `CORE_AREA` <a id="CORE_AREA"></a> | Specific core area (i.e. die area minus margins) to be used in floorplanning when `FP_SIZING` is set to `absolute`. Specified as a 4-corner rectangle "x0 y0 x1 y1". Units in μm <br> (Default: unset)|
| `FP_IO_MODE` <a id="FP_IO_MODE"></a>  | Decides the mode of the random IO placement option. 0=matching mode, 1=random equidistant mode. Matching mode attempts to optimize pin and cell placement. Random equidistant mode places equidistant pins with a random order <br> (Default: `0`)|
| `FP_WELLTAP_CELL` <a id="FP_WELLTAP_CELL"></a>  | The name of the welltap cell during welltap insertion. |
| `FP_ENDCAP_CELL` <a id="FP_ENDCAP_CELL"></a>  | The name of the endcap cell during endcap insertion. |
| `FP_PDN_CFG` <a id="FP_PDN_CFG"></a> | Points to a PDN configuration file that describes how to construct the PDN in detail. <br> (Default: `scripts/openroad/common/pdn_cfg.tcl`) |
| `FP_PDN_AUTO_ADJUST` <a id="FP_PDN_AUTO_ADJUST"></a> | Decides whether or not the flow should attempt to re-adjust the power grid, in order for it to fit inside the core area of the design, if needed. 1 = Enabled, 0 = Disabled. <br>(Default: `1`) |
| `FP_PDN_SKIPTRIM` <a id="FP_PDN_SKIPTRIM"></a> | Enables `-skip_trim` option during pdngen which skips the metal trim step, which attempts to remove metal stubs. 1 = Enabled, 0 = Disabled. <br> (Default: `1`) |
| `FP_TAPCELL_DIST` <a id="FP_TAPCELL_DIST"></a>  | The horizontal distance between two tapcell columns <br> (Default: `14`) |
| `FP_IO_VEXTEND` <a id="FP_IO_VEXTEND"></a>  |  Extends the vertical io pins outside of the die by the specified units<br> (Default: `0` Disabled) |
| `FP_IO_HEXTEND` <a id="FP_IO_HEXTEND"></a>  |  Extends the horizontal io pins outside of the die by the specified units<br> (Default: `0` Disabled) |
| `FP_IO_VLENGTH` <a id="FP_IO_VLENGTH"></a>  | The length of the vertical IOs in microns. <br> (Default: `4`) |
| `FP_IO_HLENGTH` <a id="FP_IO_HLENGTH"></a>  | The length of the horizontal IOs in microns. <br> (Default: `4`) |
| `FP_IO_VTHICKNESS_MULT` <a id="FP_IO_VTHICKNESS_MULT"></a>  | A multiplier for vertical pin thickness. Base thickness is the pins layer minwidth <br> (Default: `2`) |
| `FP_IO_HTHICKNESS_MULT` <a id="FP_IO_HTHICKNESS_MULT"></a>  | A multiplier for horizontal pin thickness. Base thickness is the pins layer minwidth <br> (Default: `2`) |
| `FP_IO_UNMATCHED_ERROR` <a id="FP_IO_UNMATCHED_ERROR"></a>  | Exit on unmatched pins in a provided `FP_PIN_ORDER_CFG` file. 1 = Enabled, 0 = Disabled. <br> (Default: `1`) |
| `BOTTOM_MARGIN_MULT` <a id="BOTTOM_MARGIN_MULT"></a>     | The core margin, in multiples of site heights, from the bottom boundary. If `FP_SIZING` is absolute and `CORE_AREA` is set, this variable has no effect. <br> (Default: `4`) |
| `TOP_MARGIN_MULT` <a id="TOP_MARGIN_MULT"></a>        | The core margin, in multiples of site heights, from the top boundary. If `FP_SIZING` is absolute and `CORE_AREA` is set, this variable has no effect. <br> (Default: `4`) |
| `LEFT_MARGIN_MULT` <a id="LEFT_MARGIN_MULT"></a>       | The core margin, in multiples of site widths, from the left boundary. If `FP_SIZING` is absolute and `CORE_AREA` is set, this variable has no effect.  <br> (Default: `12`) |
| `RIGHT_MARGIN_MULT` <a id="RIGHT_MARGIN_MULT"></a>      | The core margin, in multiples of site widths, from the right boundary. If `FP_SIZING` is absolute and `CORE_AREA` is set, this variable has no effect.   <br> (Default: `12`) |
| `FP_PDN_CORE_RING` <a id="FP_PDN_CORE_RING"></a> | Enables adding a core ring around the design. More details on the control variables in the pdk configurations documentation. 1 = Enabled, 0 = Disabled. <br> (Default: `0`) |
| `FP_PDN_ENABLE_GLOBAL_CONNECTIONS` <a id="FP_PDN_ENABLE_GLOBAL_CONNECTIONS"></a>  | Enables power connection to std cells. It is rare that this variable needs to be disabled <br> (Default: `1`) |
| `FP_PDN_ENABLE_RAILS` <a id="FP_PDN_ENABLE_RAILS"></a> | Enables the creation of rails in the power grid. 1 = Enabled, 0 = Disabled. <br> (Default: `1`) |
| `FP_PDN_ENABLE_MACROS_GRID` <a id="FP_PDN_ENABLE_MACROS_GRID"></a> | Enables the connection of macros to the top level power grid. 1 = Enabled, 0 = Disabled. <br> (Default: `1`) |
| `FP_PDN_MACRO_HOOKS` <a id="FP_PDN_MACRO_HOOKS"></a> | Specifies explicit power connections of internal macros to the top level power grid as a list of macro instance names, power domain vdd and ground net names, and macro vdd and ground pin names: `<instance_name> <vdd_net> <gnd_net> <vdd_pin> <gnd_pin>`. In JSON, declare it as an array of strings, and in Tcl, use commas as a delimiter. |
| `FP_PDN_CHECK_NODES` <a id="FP_PDN_CHECK_NODES"></a> | Enables checking for unconnected nodes in the power grid. 1 = Enabled, 0 = Disabled. <br> (Default: `1`) |
| `FP_TAP_HORIZONTAL_HALO` <a id="FP_TAP_HORIZONTAL_HALO"></a> | Specify the horizontal halo size around macros during tap insertion. The value provided is in microns. <br> (Default: `10`) |
| `FP_TAP_VERTICAL_HALO` <a id="FP_TAP_VERTICAL_HALO"></a> | Specify the vertical halo size around macros during tap insertion. The value provided is in microns. <br> (Default: set to the value of `FP_TAP_HORIZONTAL_HALO`) |
| `FP_PDN_HORIZONTAL_HALO` <a id="FP_PDN_HORIZONTAL_HALO"></a> | Sets the horizontal halo around the macros during power grid insertion. The value provided is in microns. <br> (Default: `10`) |
| `FP_PDN_VERTICAL_HALO` <a id="FP_PDN_VERTICAL_HALO"></a> | Sets the vertical halo around the macros during power grid insertion. The value provided is in microns. <br> (Default: set to the value of `FP_PDN_HORIZONTAL_HALO`) |
| `FP_PDN_MULTILAYER` <a id="FP_PDN_MULTILAYER"></a> | Controls the layers used in the power grid. If set to `0` (Tcl)/`false` (JSON), only the lower, vertical layer will be used, which is useful when hardening a macro for integrating into a larger top-level design. <br> (Default: `1`)|
| `FP_PIN_ORDER_CFG` <a id="FP_PIN_ORDER_CFG"></a> | Points to the pin order configuration file to set the pins in specific directions (S, W, E, N). If not set, then the IO pins will be placed based on one of the other methods depending on the rest of the configurations. `$<number>` i.e. `$1` can be used to place a virtual pin where `<number>` is the count of virtual pins. This can create separation between pins. You can also use `@min_distance=<number>` i.e. `@min_distance=0.8` to set preferred min distance between pins in a specific direction. See spm configuration file as an example.<br> (Default: None)|
| `FP_CONTEXT_DEF` <a id="FP_CONTEXT_DEF"></a> | Points to the parent DEF file that includes this macro/design and uses this DEF file to determine the best locations for the pins. It must be used with `FP_CONTEXT_LEF`, otherwise it's considered non-existing. If not set, then the IO pins will be placed based on one of the other methods depending on the rest of the configurations. <br> (Default: None)|
| `FP_CONTEXT_LEF` <a id="FP_CONTEXT_LEF"></a> | Points to the parent LEF file that includes this macro/design and uses this LEF file to determine the best locations for the pins. It must be used with `FP_CONTEXT_DEF`, otherwise it's considered non-existing. If not set, then the IO pins will be placed based on one of the other methods depending on the rest of the configurations. <br> (Default: None)|
| `FP_DEF_TEMPLATE` <a id="FP_DEF_TEMPLATE"></a> | Points to the DEF file to be used as a template when running `apply_def_template`. This will be used to exctract pin names, locations, shapes -excluding power and ground pins- as well as the die area and replicate all this information in the `CURRENT_DEF`. |
| `VDD_NETS` <a id="VDD_NETS"></a> | Specifies the power nets/pins to be used when creating the power grid for the design. |
| `GND_NETS` <a id="GND_NETS"></a> | Specifies the ground nets/pins to be used when creating the power grid for the design. |
| `SYNTH_USE_PG_PINS_DEFINES` <a id="SYNTH_USE_PG_PINS_DEFINES"></a> | Specifies the power guard used in the verilog source code to specify the power and ground pins. This is used to automatically extract `VDD_NETS` and `GND_NET` variables from the verilog, with the assumption that they will be order `inout vdd1, inout gnd1, inout vdd2, inout gnd2, ...`. |
| `FP_IO_MIN_DISTANCE` <a id="FP_IO_MIN_DISTANCE"></a>  | The minmimum distance between the IOs in microns. <br> (Default: `3`) |
| `FP_PADFRAME_CFG` <a id="FP_PADFRAME_CFG"></a>  | A configuration file passed to padringer, a padframe generator. <br> (Default: None) |
| `PDN_CFG` <a id="PDN_CFG"></a> | **Deprecated: Use `FP_PDN_CFG`**: Points to a PDN configuration file that describes how to construct the PDN in detail. |
| `FP_HORIZONTAL_HALO` <a id="FP_HORIZONTAL_HALO"></a> | **Deprecated: Use `FP_PDN_HORIZONTAL_HALO`**: Sets the horizontal halo around the macros during power grid insertion. The value provided is in microns.|
| `FP_PDN_VERTICAL_HALO` <a id="FP_PDN_VERTICAL_HALO"></a> | **Deprecated: Use `FP_PDN_VERTICAL_HALO`**: Sets the vertical halo around the macros during power grid insertion. The value provided is in microns. |
| `DESIGN_IS_CORE` <a id="DESIGN_IS_CORE"></a> | **Deprecated as even macros can have a full-stack PDN if core rings are used: New variable is `FP_PDN_MULTILAYER`** Controls the layers used in the power grid. Depending on whether the design is the core of the chip or a macro inside the core. 1=Is a Core, 0=Is a Macro <br> (Default: `1`)|
| `FP_PDN_IRDROP` <a id="FP_PDN_IRDROP"></a> | **Removed: No point running it this early in the flow**: Enable calculation of power grid IR drop during PDN generation. |

### Deprecated I/O Layer variables
These variables worked initially, but they were too sky130 specific and will be removed. Currently, if you define them in your design, they'll be used, but it's recommended to update your configuration to use `FP_IO_HLAYER` and `FP_IO_VLAYER`, which are defined in the PDK.

|Variable|Description|
|-|-|
| `FP_IO_HMETAL` <a id="FP_IO_HMETAL"></a>  | The metal layer on which to place the io pins horizontally (top and bottom of the die). <br>(Default: `4`)|
| `FP_IO_VMETAL` <a id="FP_IO_VMETAL"></a>  | The metal layer on which to place the io pins vertically (sides of the die) <br> (Default: `3`)|


## All Resizer (RSZ) Steps

|Variable|Description|
|-|-|
| `RSZ_LIB` <a id="RSZ_LIB"></a> | Points to one or more lib files, corresponding to the typical corner, that is used during resizer optimizations. <br> (Default: set to the value of PDK's `LIB_SYNTH`) |
| `RSZ_LIB_FASTEST` <a id="RSZ_LIB_FASTEST"></a> | Points to one or more lib files, corresponding to the fastest corner, that is used during resizer optimizations. <br> (Default: set to the value of PDK's `LIB_FASTEST`) |
| `RSZ_LIB_SLOWEST` <a id="RSZ_LIB_SLOWEST"></a> | Points to one or more lib files, corresponding to the slowest corner, that is used during resizer optimizations. <br> (Default: set to the value of PDK's `LIB_SLOWEST`) |
| `RSZ_MULTICORNER_LIB` <a id="RSZ_MULTICORNER_LIB"></a> | A flag for reading fastest and slowest corner during resizer optimizations. <br> (Default: `1`) |
| `RSZ_DONT_TOUCH_RX` <a id="RSZ_DONT_TOUCH_RX"></a> | A single regular expression designating nets as "don't touch" by resizer optimizations. <br> (Default: `$^` (matches nothing)) |
| `RSZ_DONT_TOUCH` <a id="RSZ_DONT_TOUCH"></a> | A list of nets or instances to set as "don't touch". <br> (Default: Empty) |
| `LIB_RESIZER_OPT` <a id="LIB_RESIZER_OPT"></a> | **Deprecated: Use `RSZ_LIB`**: Points to the lib file, corresponding to the typical corner, that is used during resizer optimizations. This is copy of `LIB_SYNTH`.|

## Global and Detailed Placement (GPL/DPL)

|Variable|Description|
|-|-|
| `PL_TARGET_DENSITY` <a id="PL_TARGET_DENSITY"></a> | The desired placement density of cells. It reflects how spread the cells would be on the core area. 1 = closely dense. 0 = widely spread <br> (Default: `($::env(FP_CORE_UTIL) + 10 + (5 * $::env(GPL_CELL_PADDING)) ) / 100.0`)|
| `PL_TIME_DRIVEN` <a id="PL_TIME_DRIVEN"></a> | Specifies whether the placer should use time driven placement. 0 = false, 1 = true <br> (Default: `1`)|
| `PL_BASIC_PLACEMENT` <a id="PL_BASIC_PLACEMENT"></a> | Specifies whether the placer should run basic placement. Basic placement is used for extremely simple, low-density designs of only a few dozens of gates, and should be disabled for most designs. 0 = false, 1 = true <br> (Default: `0`) |
| `PL_SKIP_INITIAL_PLACEMENT` <a id="PL_SKIP_INITIAL_PLACEMENT"></a> | Specifies whether the placer should run initial placement or not. 0 = false, 1 = true <br> (Default: `0`) |
| `PL_RANDOM_GLB_PLACEMENT` <a id="PL_RANDOM_GLB_PLACEMENT"></a> | Specifies whether the placer should run random placement or not. This is useful if the design is tiny (less than 100 cells). 0 = false, 1 = true <br> (Default: `0`) |
| `PL_RANDOM_INITIAL_PLACEMENT` <a id="PL_RANDOM_INITIAL_PLACEMENT"></a> | Specifies whether the placer should run random placement or not followed by replace's initial placement. This is useful if the design is tiny (less than 100 cells). 0 = false, 1 = true <br> (Default: `0`) |
| `PL_ROUTABILITY_DRIVEN` <a id="PL_ROUTABILITY_DRIVEN"></a> | Specifies whether the placer should use routability driven placement. 0 = false, 1 = true <br> (Default: `1`) |
| `PL_RESIZER_TIE_SEPERATION` <a id="PL_RESIZER_TIE_SEPERATION"></a> | Distance between load and an inserted tie cell in microns. <br> (Default: `0`)|
| `PL_RESIZER_DESIGN_OPTIMIZATIONS` <a id="PL_RESIZER_DESIGN_OPTIMIZATIONS"></a> | Specifies whether resizer design optimizations should be performed or not. 0 = false, 1 = true <br> (Default: `1`) |
| `PL_RESIZER_TIMING_OPTIMIZATIONS` <a id="PL_RESIZER_TIMING_OPTIMIZATIONS"></a> | Specifies whether resizer timing optimizations should be performed or not. 0 = false, 1 = true <br> (Default: `1`) |
| `PL_RESIZER_MAX_WIRE_LENGTH` <a id="PL_RESIZER_MAX_WIRE_LENGTH"></a> | Specifies the maximum wire length cap used by resizer to insert buffers. If set to 0, no buffers will be inserted. Value in microns. <br> (Default: `0`)|
| `PL_RESIZER_MAX_SLEW_MARGIN` <a id="PL_RESIZER_MAX_SLEW_MARGIN"></a> | Specifies a margin for the slews in percentage. <br> (Default: `20`)|
| `PL_RESIZER_MAX_CAP_MARGIN` <a id="PL_RESIZER_MAX_CAP_MARGIN"></a> | Specifies a margin for the capacitances in percentage. <br> (Default: `20`)|
| `PL_RESIZER_HOLD_SLACK_MARGIN` <a id="PL_RESIZER_HOLD_SLACK_MARGIN"></a> | Specifies a time margin for the slack when fixing hold violations. Normally the resizer will stop when it reaches zero slack. This option allows you to overfix. <br> (Default: `0.1ns`.)|
| `PL_RESIZER_SETUP_SLACK_MARGIN` <a id="PL_RESIZER_SETUP_SLACK_MARGIN"></a> | Specifies a time margin for the slack when fixing setup violations. <br> (Default: `0.05ns`)|
| `PL_RESIZER_HOLD_MAX_BUFFER_PERCENT` <a id="PL_RESIZER_HOLD_MAX_BUFFER_PERCENT"></a> | Specifies a max number of buffers to insert to fix hold violations. This number is calculated as a percentage of the number of instances in the design. <br> (Default: `50`)|
| `PL_RESIZER_SETUP_MAX_BUFFER_PERCENT` <a id="PL_RESIZER_SETUP_MAX_BUFFER_PERCENT"></a> | Specifies a max number of buffers to insert to fix setup violations. This number is calculated as a percentage of the number of instances in the design. <br> (Default: `50`)|
| `PL_RESIZER_ALLOW_SETUP_VIOS` <a id="PL_RESIZER_ALLOW_SETUP_VIOS"></a> | Allows setup violations when fixing hold. <br> (Default: `0`)|
| `PL_WIRELENGTH_COEF` <a id="PL_WIRELENGTH_COEF"></a> | Global placement initial wirelength coefficient. Decreasing the variable will modify the initial placement of the standard cells to reduce the wirelengths. <br> (Default: `0.25`).|
| `DONT_USE_CELLS` <a id="DONT_USE_CELLS"></a> | The list of cells to not use during resizer optimizations. <br> (Default: the contents of `DRC_EXCLUDE_CELL_LIST`) |
| `PL_ESTIMATE_PARASITICS` <a id="PL_ESTIMATE_PARASITICS"></a> | Specifies whether or not to run STA after global placement using OpenROAD's estimate_parasitics -placement and generates reports under `logs/placement`. 1 = Enabled, 0 = Disabled. <br> (Default: `1`) |
| `PL_OPTIMIZE_MIRRORING` <a id="PL_OPTIMIZE_MIRRORING"></a> | Specifies whether or not to run an optimize_mirroring pass whenever detailed placement happens. This pass will mirror the cells whenever possible to optimize the design. 1 = Enabled, 0 = Disabled. <br> (Default: `1`) |
| `PL_RESIZER_BUFFER_INPUT_PORTS` <a id="PL_RESIZER_BUFFER_INPUT_PORTS"></a> | Specifies whether or not to insert buffers on input ports whenever resizer optimizations are run. For this to be used, `PL_RESIZER_DESIGN_OPTIMIZATIONS` must be set to 1. 1 = Enabled, 0 = Disabled. <br> (Default: `1`) |
| `PL_RESIZER_BUFFER_OUTPUT_PORTS` <a id="PL_RESIZER_BUFFER_OUTPUT_PORTS"></a> | Specifies whether or not to insert buffers on output ports whenever resizer optimizations are run. For this to be used, `PL_RESIZER_DESIGN_OPTIMIZATIONS` must be set to 1. 1 = Enabled, 0 = Disabled. <br> (Default: `1`) |
| `PL_RESIZER_REPAIR_TIE_FANOUT` <a id="PL_RESIZER_REPAIR_TIE_FANOUT"></a> | Specifies whether or not to repair tie cells fanout whenever resizer optimizations are run. For this to be used, `PL_RESIZER_DESIGN_OPTIMIZATIONS` must be set to 1. 1 = Enabled, 0 = Disabled. <br> (Default: `1`) |
| `PL_MAX_DISPLACEMENT_X` <a id="PL_MAX_DISPLACEMENT_X"></a> | Specifies how far an instance can be moved along the X-axis when finding a site where it can be placed during detailed placement. <br> (Default: `500`μm) |
| `PL_MAX_DISPLACEMENT_Y` <a id="PL_MAX_DISPLACEMENT_Y"></a> | Specifies how far an instance can be moved along the Y-axis when finding a site where it can be placed during detailed placement. <br> (Default: `100`μm) |
| `PL_MACRO_HALO` <a id="PL_MACRO_HALO"></a> | Macro placement halo. Format: `{Horizontal} {Vertical}` <br> (Default: `0 0`μm). |
| `PL_MACRO_CHANNEL` <a id="PL_MACRO_CHANNEL"></a> | Channel widths between macros. Format: `{Horizontal} {Vertical}` <br> (Default: `0 0`μm). |
| `MACRO_PLACEMENT_CFG` <a id="MACRO_PLACEMENT_CFG"></a> | Specifies the path to a file that instructs OpenLane how and where to place certain macros. For information about the format of this file, see [Macro placement configuration](#macro-placement-configuration). |
| `UNBUFFER_NETS` <a id="UNBUFFER_NETS"></a> | **Deprecated: Use `RSZ_DONT_TOUCH_RX`**: A regular expression used to match nets from which to remove buffers after every resizer run. Useful for analog ports in mixed-signal designs where OpenROAD may sometimes add a buffer. |
| `DONT_BUFFER_PORTS` <a id="DONT_BUFFER_PORTS"></a> | **Removed: Use `RSZ_DONT_TOUCH_RX`**: Semicolon;delimited list of nets from which to remove buffers. |

### Macro placement configuration

`MACRO_PLACEMENT_CFG` specifies a file (often called `macro.cfg` or `macro_placement.cfg`) listing macros (i.e. already-hardened design layouts) to be placed as submodules within the layout being hardened. For example, using JSON configuration:

```json
"MACRO_PLACEMENT_CFG": "dir::macro.cfg",
```

In that specified `macro.cfg` file each non-blank/non-comment line declares: a single macro to be included; where it is to be placed; and whether it is to be rotated or mirrored. This example places 3 macros:

```bash
# Some macros:
my_controller  100  150  N
your_device   1200 1400  FS  # Face south by flipping upside-down.

# Another macro of some kind:
our_bridge     200  800  S
```

Each line comprises 4 parameters (separated by *any* amount of whitespace but formatted as columns in this example for readability), and they are as follows:
1.  Name of the macro (e.g. `my_controller`).
2.  Horizontal placement of the macro (e.g. `100`, which is 100&micro;m). This is the horizontal offset from the parent layout's left edge, to the macro's left edge.
3.  Vertical placement (e.g. `150`, or 150&micro;m). Vertical offset from the parent's bottom edge to the macro's bottom edge.
4.  Orientation specifier (e.g. `N`, meaning the macro's own North or *top* edge points in the North direction, and hence is not rotated).

The `N` orientation is used most often, but sometimes it is necessary to rotate and/or flip macros. The orientation specifier follows the LEF/DEF language reference, and can be one of the following:

| Orientation     | Effect                                        | Result                                                      |
|-----------------|-----------------------------------------------|-------------------------------------------------------------|
| `N`  or `R0`    | No rotation                                   | Macro's "top" faces North.                                  |
| `S`  or `R180`  | Rotate 180&deg;                               | Macro's "top" faces South, by rotation.                     |
| `W`  or `R90`   | Rotate 90&deg; anti-clockwise                 | Macro's "top" faces West, by rotation.                      |
| `E`  or `R270`  | Rotate 90&deg; clockwise                      | Macro's "top" faces East, by rotation.                      |
| `FN` or `MY`    | Mirror about the Y axis                       | Macro's "top" faces North and is *flipped* left-to-right.   |
| `FS` or `MX`    | Mirror about the X axis                       | Macro's "top" faces South by being *flipped* top-to-bottom. |
| `FW` or `MXR90` | Mirror about X, rotate 90&deg; anti-clockwise | Macro's "top" faces **East** by flipping `W` left-to-right. |
| `FE` or `MYR90` | Mirror about Y, rotate 90&deg; anti-clockwise | Macro's "top" faces **West** by flipping `E` right-to-left. |

:::{note}
The alternative names (`R0`, `MXR90`, etc.) follow the OpenAccess database format, and specifically these 8 alternatives are also supported by OpenLane.
:::

:::{note}
Be careful if using East/West orientations: Ensure the macro's PDN is still able to properly intersect/connect with the parent layout's PDN.
:::

For more information on integrating macros and other relevant configuration variables, see:
*   [Macros/Chip Integration](#macroschip-integration)
*   [`FP_PDN_MACRO_HOOKS`](#FP_PDN_MACRO_HOOKS)
*   [`EXTRA_SPEFS`](#EXTRA_SPEFS)
*   [`CLOCK_NET`](#CLOCK_NET) (which can be an array to specify multiple clock nets if needed) and [`CLOCK_PORT`](#CLOCK_PORT)


## Clock Tree Synthesis (CTS)

|Variable|Description|
|-|-|
| `RUN_CTS` <a id="RUN_CTS"></a> | Enable clock tree synthesis. <br> (Default: `1`)|
| `RUN_FILL_INSERTION` <a id="RUN_FILL_INSERTION"></a> | Enables fill cells insertion after cts (if enabled). 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `CTS_SINK_CLUSTERING_SIZE` <a id="CTS_SINK_CLUSTERING_SIZE"></a> | Specifies the maximum number of sinks per cluster. <br> (Default: `25`) |
| `CTS_SINK_CLUSTERING_MAX_DIAMETER` <a id="CTS_SINK_CLUSTERING_MAX_DIAMETER"></a> | Specifies maximum diameter (in micron) of sink cluster. <br> (Default: `50`) |
| `CTS_REPORT_TIMING` <a id="CTS_REPORT_TIMING"></a> | Specifies whether or not to run STA after clock tree synthesis using OpenROAD's estimate_parasitics -placement and generates reports under `logs/cts`. 1 = Enabled, 0 = Disabled. <br> (Default: `1`) |
| `CTS_CLK_MAX_WIRE_LENGTH` <a id="CTS_CLK_MAX_WIRE_LENGTH"></a> | Specifies the maximum wire length on the clock net. Value in microns. <br> (Default: `0`) |
| `CTS_DISABLE_POST_PROCESSING` <a id="CTS_DISABLE_POST_PROCESSING"></a> | Specifies whether or not to disable post cts processing for outlier sinks. <br> (Default: `0`) |
| `CTS_DISTANCE_BETWEEN_BUFFERS` <a id="CTS_DISTANCE_BETWEEN_BUFFERS"></a> | Specifies the distance (in microns) between buffers when creating the clock tree (Default: `0`) |
| `LIB_CTS` <a id="LIB_CTS"></a> | The liberty file used for CTS for typical corner. By default, this is the `LIB_SYNTH` minus the cells with drc errors as specified by the drc exclude list. <br> (Default: `$::env(cts_tmpfiles)/cts.lib`) |
| `LIB_CTS_SLOWEST` <a id="LIB_CTS_SLOWEST"></a> | The liberty file used for CTS for slowest corner. By default, this is the `LIB_SLOWEST` minus the cells with drc errors as specified by the drc exclude list. <br> (Default: `$::env(cts_tmpfiles)/cts-slowest.lib`) |
| `LIB_CTS_FASTEST` <a id="LIB_CTS_FASTEST"></a> | The liberty file used for CTS for fastest corner. By default, this is the `LIB_FASTEST` minus the cells with drc errors as specified by the drc exclude list. <br> (Default: `$::env(cts_tmpfiles)/cts-fastest.lib`) |
| `CTS_MULTICORNER_LIB` <a id="CTS_MULTICORNER_LIB"></a> | A flag for reading fastest and slowest corner during CTS. <br> (Default: `1`) |
| `CLOCK_TREE_SYNTH` <a id="CLOCK_TREE_SYNTH"></a> | **Deprecated: Use `RUN_CTS`**: Enable clock tree synthesis. 1 = Enabled, 0 = Disabled. |
| `FILL_INSERTION` <a id="FILL_INSERTION"></a> | **Removed: Use `RUN_FILL_INSERTION`**: Enables fill cells insertion after CTS. 1 = Enabled, 0 = Disabled. |
| `RUN_SIMPLE_CTS` <a id="RUN_SIMPLE_CTS"></a> | **Removed: TritonCTS is always run**: Run an alternative simple clock tree synthesis after synthesis instead of TritonCTS. 1 = Enabled, 0 = Disabled. |
| `CTS_TARGET_SKEW` <a id="CTS_TARGET_SKEW"></a> | **Removed: No longer supported by underlying utility**: The target clock skew in picoseconds. <br> (Default: `200`ps)|
| `CLOCK_BUFFER_FANOUT` <a id="CLOCK_BUFFER_FANOUT"></a> | **Removed: Unused**: Fanout of clock tree buffers. <br> (Default: `16`) |
| `CTS_TOLERANCE` <a id="CTS_TOLERANCE"></a> | **Removed: Unused**: An integer value that represents a tradeoff of QoR and runtime. Higher values will produce smaller runtime but worse QoR <br> (Default: `100`) |


## Global and Detailed Routing (GRT/DRT) 

|Variable|Description|
|-|-|
| `RUN_DRT` <a id="RUN_DRT"></a> | Enables detailed routing. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `GLOBAL_ROUTER` <a id="GLOBAL_ROUTER"></a> | Specifies which global router to use. Values: `fastroute`. (`cugr` is deprecated and fastroute will be used instead.) <br> (Default: `fastroute`) |
| `DETAILED_ROUTER` <a id="DETAILED_ROUTER"></a> | Specifies which detailed router to use. Values: `tritonroute`. (`drcu`/`tritonroute_or` are both deprecated and tritonroute will be used instead.) <br> (Default: `tritonroute`)|
| `ROUTING_CORES` <a id="ROUTING_CORES"></a> | Specifies the number of threads to be used in TritonRoute. Can be overriden via environment variable. <br> (Default: `2`) |
| `RT_CLOCK_MIN_LAYER` <a id="RT_CLOCK_MIN_LAYER"></a> | The name of lowest layer to be used in routing the clock net. <br> (Default: `RT_MIN_LAYER`)|
| `RT_CLOCK_MAX_LAYER` <a id="RT_CLOCK_MAX_LAYER"></a> | The name of highest layer to be used in routing the clock net. <br> (Default: `RT_MAX_LAYER`)|
| `GLB_RESIZER_TIMING_OPTIMIZATIONS` <a id="GLB_RESIZER_TIMING_OPTIMIZATIONS"></a> | Specifies whether resizer timing optimizations should be performed after global routing or not. 1 = Enabled, 0 = Disabled. <br> (Default: `1`)
| `GLB_RESIZER_DESIGN_OPTIMIZATIONS` <a id="GLB_RESIZER_DESIGN_OPTIMIZATIONS"></a> | Specifies whether resizer design optimizations should be performed after global routing or not. 1 = Enabled, 0 = Disabled. <br> (Default: `1`)
| `GLB_RESIZER_MAX_WIRE_LENGTH` <a id="GLB_RESIZER_MAX_WIRE_LENGTH"></a> | Specifies the maximum wire length cap used by resizer to insert buffers. If set to 0, no buffers will be inserted. Value in microns. <br> (Default: `0`)|
| `GLB_RESIZER_MAX_SLEW_MARGIN` <a id="GLB_RESIZER_MAX_SLEW_MARGIN"></a> | Specifies a margin for the slews. <br> (Default: `10`)|
| `GLB_RESIZER_MAX_CAP_MARGIN` <a id="GLB_RESIZER_MAX_CAP_MARGIN"></a> | Specifies a margin for the capacitances. <br> (Default: `10`)|
| `GLB_RESIZER_HOLD_SLACK_MARGIN` <a id="GLB_RESIZER_HOLD_SLACK_MARGIN"></a> | Specifies a time margin for the slack when fixing hold violations. Normally the resizer will stop when it reaches zero slack. This option allows you to overfix. <br> (Default: `0.05ns`)|
| `GLB_RESIZER_SETUP_SLACK_MARGIN` <a id="GLB_RESIZER_SETUP_SLACK_MARGIN"></a> | Specifies a time margin for the slack when fixing setup violations. <br> (Default: `0.025ns`)|
| `GLB_RESIZER_HOLD_MAX_BUFFER_PERCENT` <a id="GLB_RESIZER_HOLD_MAX_BUFFER_PERCENT"></a> | Specifies a max number of buffers to insert to fix hold violations. This number is calculated as a percentage of the number of instances in the design. <br> (Default: `50`)|
| `GLB_RESIZER_SETUP_MAX_BUFFER_PERCENT` <a id="GLB_RESIZER_SETUP_MAX_BUFFER_PERCENT"></a> | Specifies a max number of buffers to insert to fix setup violations. This number is calculated as a percentage of the number of instances in the design. <br> (Default: `50`)|
| `GLB_RESIZER_ALLOW_SETUP_VIOS` <a id="GLB_RESIZER_ALLOW_SETUP_VIOS"></a> | Allows setup violations when fixing hold. <br> (Default: `0`)|
| `GLB_OPTIMIZE_MIRRORING` <a id="GLB_OPTIMIZE_MIRRORING"></a> | Specifies whether or not to run an optimize_mirroring pass whenever detailed placement happens after Routing timing optimization. This pass will mirror the cells whenever possible to optimize the design. 1 = Enabled, 0 = Disabled. <br> (Default: `1`) |
| `GRT_ALLOW_CONGESTION` <a id="GRT_ALLOW_CONGESTION"></a>‡ | Allow congestion in the resulting guides. 0 = false, 1 = true <br> (Default: `0`) 
| `GRT_OVERFLOW_ITERS` <a id="GRT_OVERFLOW_ITERS"></a>‡ | The maximum number of iterations waiting for the overflow to reach the desired value. <br> (Default: `50`) |
| `GRT_ANT_ITERS` <a id="GRT_ANT_ITERS"></a>‡ | The maximum number of iterations for global router repair_antenna. This option is only available when `GRT_REPAIR_ANTENNAS` is enabled. <br> (Default: `15`) |
| `GRT_ANT_MARGIN` <a id="GRT_ANT_MARGIN"></a>‡ | The margin to over fix antenna violations in global routing as a percentage. This option is only available when `GRT_REPAIR_ANTENNAS` is enabled. <br> (Default: `10`) |
| `GRT_ESTIMATE_PARASITICS` <a id="GRT_ESTIMATE_PARASITICS"></a>‡ | Specifies whether or not to run STA after global routing using OpenROAD's estimate_parasitics -global_routing and generates reports under `logs/routing`. 1 = Enabled, 0 = Disabled. <br> (Default: `1`) |
| `GRT_MAX_DIODE_INS_ITERS` <a id="GRT_MAX_DIODE_INS_ITERS"></a>‡ | Controls the maximum number of iterations at which re-running Fastroute for diode insertion stops. Each iteration ARC detects the violations and FastRoute fixes them by inserting diodes, then producing the new DEF. The number of antenna violations is compared with the previous iteration and if they are equal or the number is greater the iterations stop and the DEF from the previous iteration is used in the rest of the flow. If the current antenna violations reach zero, the current def will be used and the iterations will not continue. This option is only available in when `GRT_REPAIR_ANTENNAS` is enabled.  <br> (Default: `1`) |
| `GRT_REPAIR_ANTENNAS` <a id="GRT_REPAIR_ANTENNAS"></a>‡ | Enables OpenROAD's antenna avoidance flow. <br> (Default: `1`) |
| `GRT_OBS` <a id="GRT_OBS"></a>‡ | Specifies custom obstruction to be added prior to global routing as of layer and coordinates in the format `layer llx lly urx ury`, where `ll` and `ur` stand for "lower left" and "upper right" respectively. In JSON, declare it as an array of strings, and in Tcl, use commas as a delimiter. (Example: `li1 0 100 1000 300, met5 0 0 1000 500`) <br> (Default: unset) |
| `GRT_ADJUSTMENT` <a id="GRT_ADJUSTMENT"></a>‡ | Reduction in the routing capacity of the edges between the cells in the global routing graph. Values range from 0 to 1. <br> 1 = most reduction, 0 = least reduction  <br> (Default: `0.3`)|
| `GRT_MACRO_EXTENSION` <a id="GRT_MACRO_EXTENSION"></a>‡ | Sets the number of GCells added to the blockages boundaries from macros. A GCell is typically defined in terms of Mx routing tracks. The default GCell size is 15 M3 pitches. <br> (Default: `0`) |
| `DRT_MIN_LAYER` <a id="DRT_MIN_LAYER"></a> | An optional override to the lowest layer used in detailed routing. For example, in sky130, you may want global routing to avoid li1, but let detailed routing use li1 if it has to. <br> (Default: `RT_MIN_LAYER`)|
| `DRT_MAX_LAYER` <a id="DRT_MAX_LAYER"></a> | An optional override to the highest layer used in detailed routing. <br> (Default: `RT_MAX_LAYER`)|
| `DRT_OPT_ITERS` <a id="DRT_OPT_ITERS"></a> | Specifies the maximum number of optimization iterations during Detailed Routing in TritonRoute. Values allowed are integers from `1` to `64`. <br> (Default: `64`) |
| `ROUTING_OPT_ITERS` <a id="ROUTING_OPT_ITERS"></a> |**Removed: Use `DRT_OPT_ITERS`**: Specifies the maximum number of optimization iterations during Detailed Routing in TritonRoute.|
| `GLB_RT_MINLAYER` <a id="GLB_RT_MINLAYER"></a> | **Removed: Use `RT_MIN_LAYER`**: The number of lowest layer to be used in routing.|
| `GLB_RT_MAXLAYER` <a id="GLB_RT_MAXLAYER"></a> | **Removed: Use `RT_MAX_LAYER`**: The number of highest layer to be used in routing.|
| `GLB_RT_CLOCK_MINLAYER` <a id="GLB_RT_CLOCK_MINLAYER"></a> | **Removed: Use `RT_CLOCK_MIN_LAYER`**: The number of lowest layer to be used in routing the clock net.|
| `GLB_RT_CLOCK_MAXLAYER` <a id="GLB_RT_CLOCK_MAXLAYER"></a> | **Removed: Use `RT_CLOCK_MIN_LAYER`**: The number of highest layer to be used in routing the clock net.|
| `GLB_RT_L{1/2/3/4/5/6}_ADJUSTMENT` | **Removed: See PDK variable `GRT_LAYER_ADJUSTMENTS` instead**: Reduction in the routing capacity of the edges between the cells in the global routing graph but specific to a metal layer in sky130A. Values ranged from 0 to 1 |
| `GLB_RT_UNIDIRECTIONAL` <a id="GLB_RT_UNIDIRECTIONAL"></a> | **Removed**: Allow unidirectional routing. 1 = Enabled, 0 = Disabled. |
| `GLB_RT_TILES` <a id="GLB_RT_TILES"></a> | **Removed**: The size of the GCELL used by Fastroute during global routing. |

> **‡** Variable previously prefixed `GLB_RT_` have had its prefix changed to `GRT_`. The replaced variable is deprecated and will be translated to its new form automatically by the flow.

### Custom Diode Insertion Scripts

|Variable|Description|
|-|-|
| `RUN_HEURISTIC_DIODE_INSERTION` <a id="RUN_HEURISTIC_DIODE_INSERTION"></a> | Runs a script by [Sylvain Munaut](https://github.com/smunaut) that inserts diodes heuristically based on . 1 = Enabled, 0 = Disabled <br> (Default: `0`)|
| `HEURISTIC_ANTENNA_THRESHOLD` <a id="HEURISTIC_ANTENNA_THRESHOLD"></a> | Minimum manhattan distance of a net to insert a diode in microns. Only applicable for `RUN_HEURISTIC_DIODE_INSERTION` is enabled. <br> (Default: `90`)
| `DIODE_ON_PORTS` <a id="DIODE_ON_PORTS"></a> | Insert diodes on ports with the specified polarities. Available options are `none`, `in`, `out` and `both`. <br> (Default: `none`) |

## Parasitic Resistance/Capacitance Extraction (RCX)

|Variable|Description|
|-|-|
| `RUN_SPEF_EXTRACTION` <a id="RUN_SPEF_EXTRACTION"></a> | Specifies whether or not to run SPEF extraction on the routed DEF. 1=enabled 0=disabled <br> (Default: `1`) |
| `SPEF_EXTRACTOR` <a id="SPEF_EXTRACTOR"></a> | Specifies which spef extractor to use. Values: `openrcx` or (**removed:** `def2spef`). <br> (Default: `openrcx`) |
| `RCX_MERGE_VIA_WIRE_RES` <a id="RCX_MERGE_VIA_WIRE_RES"></a> | Specifies whether to merge the via resistance with the wire resistance or separate it from the wire resistance. 1 = Merge via resistance, 0 = Separate via resistance <br> (Default: `1`)|
| `RCX_SDC_FILE` <a id="RCX_SDC_FILE"></a> | **Deprecated: Use `SIGNOFF_SDC_FILE`**: Specifies SDC file to be used for RCX-based STA, which can be different from the one used for implementation. <br> (Default: `BASE_SDC_FILE`) |
| `SPEF_WIRE_MODEL` <a id="SPEF_WIRE_MODEL"></a> | **Removed:** Specifies the wire model used in SPEF extraction. Options are `L` or `Pi` |
| `SPEF_EDGE_CAP_FACTOR` <a id="SPEF_EDGE_CAP_FACTOR"></a> | **Removed:** Specifies the edge capacitance factor used in SPEF extraction. Ranges from 0 to 1 |

## IR Drop Analysis

|Variable|Description|
|-|-|
| `RUN_IRDROP_REPORT` <a id="RUN_IRDROP_REPORT"></a> | Creates an IR Drop report using OpenROAD PSM. 1 = Enabled, 0 = Disabled. <br> (Default: `1`) |
| `VSRC_LOC_FILES` <a id="VSRC_LOC_FILES"></a> | Map of voltage source nets to OpenROAD PSM location files. Variable should be provided as a Tcl dict, i.e.: `net1 file1 net2 file2`. See [this](https://github.com/The-OpenROAD-Project/OpenROAD/tree/master/src/psm#commands) for more info. <br> (Default: None)  |

## Signoff


|Variable|Description|
|-|-|
| `PRIMARY_GDSII_STREAMOUT_TOOL` <a id="PRIMARY_GDSII_STREAMOUT_TOOL"></a> | Determines whether `magic` or `klayout` is the primary signoff tool. <br> (Default: `magic`) |
| `USE_ARC_ANTENNA_CHECK` <a id="USE_ARC_ANTENNA_CHECK"></a> | Specifies whether to use the openroad ARC antenna checker or magic antenna checker. 0=magic antenna checker, 1=ARC OR antenna checker <br> (Default: `1`)
| `RUN_CVC` <a id="RUN_CVC"></a> | Runs CVC on the output spice, which is a Circuit Validity Checker. Voltage aware ERC checker for CDL netlists. 1 = Enabled, 0 = Disabled. <br> (Default: `1`) |
| `SIGNOFF_SDC_FILE` <a id="SIGNOFF_SDC_FILE"></a> | Specifies SDC file used by multicorner STA during signoff stage, which can be different from the one used for implementation. <br> (Default: `BASE_SDC_FILE`) |

### Magic
|Variable|Description|
|-|-|
| `RUN_MAGIC` <a id="RUN_MAGIC"></a> | Enables running magic and GDSII streaming. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `RUN_MAGIC_DRC` <a id="RUN_MAGIC_DRC"></a> | Enables running magic DRC on either GDSII produced by `PRIMARY_GDSII_STREAMOUT_TOOL` or final produced DEF file depending on `MAGIC_DRC_USE_GDS`. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `MAGIC_PAD` <a id="MAGIC_PAD"></a> |  A flag to pad the views generated by magic (.mag, .lef, .gds) with one site. 1 = Enabled, 0 = Disabled <br> (Default: `0`)|
| `MAGIC_ZEROIZE_ORIGIN` <a id="MAGIC_ZEROIZE_ORIGIN"></a> | A flag to move the layout such that it's origin in the lef generated by magic is 0,0. 1 = Enabled, 0 = Disabled  <br> (Default: `1`)|
| `MAGIC_GENERATE_GDS` <a id="MAGIC_GENERATE_GDS"></a> | A flag to generate gds view via magic. 1 = Enabled, 0 = Disabled  <br> (Default: `1`)|
| `MAGIC_GENERATE_LEF` <a id="MAGIC_GENERATE_LEF"></a> | A flag to generate lef view via magic. 1 = Enabled, 0 = Disabled  <br> (Default: `1`)|
| `MAGIC_GENERATE_MAGLEF` <a id="MAGIC_GENERATE_MAGLEF"></a> | A flag to generate maglef view via magic. Requires `MAGIC_GENERATE_LEF` to be also set. 1 = Enabled, 0 = Disabled  <br> (Default: `1`)|
| `MAGIC_WRITE_FULL_LEF` <a id="MAGIC_WRITE_FULL_LEF"></a> | A flag to specify whether or not the output LEF should include all shapes inside the macro or an abstracted view of the macro lef view via magic. 1 = Full View, 0 = Abstracted View  <br> (Default: `0`)|
| `MAGIC_DRC_USE_GDS` <a id="MAGIC_DRC_USE_GDS"></a> | A flag to choose whether to run the magic DRC checks on GDS or not. If not, then the checks will be done on the DEF/LEF. 1 = GDS, 0 = DEF/LEF  <br> (Default: `1`)|
| `MAGIC_EXT_USE_GDS` <a id="MAGIC_EXT_USE_GDS"></a> | A flag to choose whether to run the magic extractions on GDS or DEF/LEF. If GDS was used Device Level LVS will be run. Otherwise, blackbox LVS will be run. 1 = GDS, 0 = DEF/LEF  <br> (Default: `0`)|
| `MAGIC_LEF_WRITE_USE_GDS` <a id="MAGIC_LEF_WRITE_USE_GDS"></a> | A flag to choose whether to run the magic lef write on GDS or DEF/LEF. 1 = GDS, 0 = DEF/LEF  <br> (Default: `0`)|
| `MAGIC_INCLUDE_GDS_POINTERS` <a id="MAGIC_INCLUDE_GDS_POINTERS"></a> | A flag to choose whether to include GDS pointers in the generated mag files or not. 1 = Enabled, 0 = Disabled  <br> (Default: `0`)|
| `MAGIC_DISABLE_HIER_GDS` <a id="MAGIC_DISABLE_HIER_GDS"></a> | A flag to disable cif hier and array during GDSII writing.* 1=Enabled `<so this hier gds will be disabled>`, 0=Disabled `<so this hier gds will be enabled>`. <br> (Default: `1`)|
| `MAGIC_DEF_NO_BLOCKAGES` <a id="MAGIC_DEF_NO_BLOCKAGES"></a> | A flag to choose whether blockages are read with DEF files or not (they are read as a sheet of metal by Magic). 1 = No Blockages, 0 = Blockages as Metal Sheets  <br> (Default: `1`)|
| `MAGIC_DEF_LABELS` <a id="MAGIC_DEF_LABELS"></a> | A flag to choose whether labels are read with DEF files or not. From magic docs: "The '-labels' option to the 'def read' command causes each net in the NETS and SPECIALNETS sections of the DEF file to be annotated with a label having the net name as the label text." 1 = Labels, 0 = Unlabeled  <br> (Default: `1`)|
| `MAGIC_GDS_ALLOW_ABSTRACT` <a id="MAGIC_GDS_ALLOW_ABSTRACT"></a> | A flag to allow abstract view of macros during magic gds generation. 1 = Allow, 0 = Disallow  <br> (Default: `0`)|
| `MAGIC_GDS_POLYGON_SUBCELLS` <a id="MAGIC_GDS_POLYGON_SUBCELLS"></a> | A flag to enable polygon subcells in magic for gds read potentially speeding up magic. From magic docs: "Put non-Manhattan polygons. This prevents interations with other polygons on the same plane and so reduces tile splitting" 1 = Allow, 0 = Disallow  <br> (Default: `0`)|
> * Tim Edwards's Explanation on disabling hier gds: The following is an explanation by Tim Edwards, provided in a slack thread, on how this affects the GDS writing process: "Magic can take a very long time writing out GDS while checking hierarchical interactions in a standard cell layout. If your design is all digital, I recommend using "gds *hier write disable" before "gds write" so that it does not try to resolve hierarchical interactions (since by definition, standard cells are designed to just sit next to each other without creating DRC issues).  That can actually make the difference between a 20 hour GDS write and a 2 minute GDS write.  For a standard cell design that takes up the majority of the user space, a > 24 hour write time (without disabling the hierarchy checks) would not surprise me."


### KLayout

|Variable|Description|
|-|-|
| `RUN_KLAYOUT` <a id="RUN_KLAYOUT"></a> | Enables running KLayout and GDSII streaming. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `RUN_KLAYOUT_XOR` <a id="RUN_KLAYOUT_XOR"></a> | Enables running KLayout XOR on 2 GDSIIs, the defaults are the one produced by magic vs the one produced by klayout. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `RUN_KLAYOUT_DRC` <a id="RUN_KLAYOUT_DRC"></a> | Enables running KLayout DRC on GDSII produced by `PRIMARY_GDSII_STREAMOUT_TOOL`. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `KLAYOUT_DRC_KLAYOUT_GDS` <a id="KLAYOUT_DRC_KLAYOUT_GDS"></a> | Enables running KLayout DRC on GDSII produced by KLayout. 1 = Enabled, 0 = Disabled <br> (Default: `0`)|
| `KLAYOUT_XOR_THREADS` <a id="KLAYOUT_XOR_THREADS"></a> | Specifies number of threads used in klayout xor check <br> (Default: `1`)|
| `KLAYOUT_DRC_THREADS` <a id="KLAYOUT_DRC_THREADS"></a> | Specifies number of threads used in klayout drc check <br> (Default: `1`)|
| `TAKE_LAYOUT_SCROT` <a id="TAKE_LAYOUT_SCROT"></a> | Enables running KLayout to take a PNG screenshot of the produced layout (currently configured to run on the results of each stage).1 = Enabled, 0 = Disabled <br> (Default: `0`)|


## Layout vs. Schematic (LVS)

|Variable|Description|
|-|-|
| `RUN_LVS` <a id="RUN_LVS"></a> | Enables running LVS. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `LVS_INSERT_POWER_PINS` <a id="LVS_INSERT_POWER_PINS"></a> |  Enables power pins insertion before running lvs. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `LVS_CONNECT_BY_LABEL` <a id="LVS_CONNECT_BY_LABEL"></a> | Enables connections by label in LVS by skipping `extract unique` in magic extractions. <br> (Default: `0`) |
| `YOSYS_REWRITE_VERILOG` <a id="YOSYS_REWRITE_VERILOG"></a> | Enables yosys to rewrite the verilog before LVS producing a canonical verilog netlist with verbose wire declarations. 1 = Enabled, 0 = Disabled <br> (Default: `0`) |


## Checkers

|Variable|Description|
|-|-|
| `QUIT_ON_SYNTH_CHECKS` <a id="QUIT_ON_SYNTH_CHECKS"></a> | Quit if any of the following conditions are met: (1) `check -assert` in yosys. This checks for combinational loops, conflicting drivers and wires with no drivers. (2) Using a signal that doesn't match a module port size in the RTL. For instance, given such a module `module example(x); input x; endmodule` it gets instantiated like that `example y(2'b11);` (3) Found Latches in the design. (4) Out of bound(range) errors in the RTL. e.g. `wire [10:0] x; assign x[13] = 1'b1`. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `SYNTH_CHECKS_ALLOW_TRISTATE` <a id="SYNTH_CHECKS_ALLOW_TRISTATE"></a> | Allow tristate logic in `QUIT_ON_SYNTH_CHECKS`. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `QUIT_ON_UNMAPPED_CELLS` <a id="QUIT_ON_UNMAPPED_CELLS"></a> | Checks if there are unmapped cells after synthesis and aborts if any was found. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `QUIT_ON_ASSIGN_STATEMENTS` <a id="QUIT_ON_ASSIGN_STATEMENTS"></a> | Checks for assign statement in the generated gate level netlist and aborts of any was found.1 = Enabled, 0 = Disabled <br> (Default: `0`)|
| `QUIT_ON_TR_DRC` <a id="QUIT_ON_TR_DRC"></a> | Checks for DRC violations after routing and exits the flow if any was found. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `QUIT_ON_LONG_WIRE` <a id="QUIT_ON_LONG_WIRE"></a> | Exits the flow if any wire length exceeds the threshold set in the PDK. 1 = Enabled, 0 = Disabled <br> (Default: `0`)|
| `QUIT_ON_MAGIC_DRC` <a id="QUIT_ON_MAGIC_DRC"></a> | Checks for DRC violations after magic DRC is executed and exits the flow if any was found. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `QUIT_ON_ILLEGAL_OVERLAPS` <a id="QUIT_ON_ILLEGAL_OVERLAPS"></a> | Checks for illegal overlaps during magic extraction. In some cases, these imply existing undetected shorts in the design. It also exits the flow if any was found. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `QUIT_ON_LVS_ERROR` <a id="QUIT_ON_LVS_ERROR"></a> | Checks for LVS errors after netgen LVS is executed and exits the flow if any was found. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `QUIT_ON_HOLD_VIOLATIONS` <a id="QUIT_ON_HOLD_VIOLATIONS"></a> | Exits the flow on hold violations at the typical corner <br> (Default: `1`)|
| `QUIT_ON_SETUP_VIOLATIONS` <a id="QUIT_ON_SETUP_VIOLATIONS"></a> | Exits the flow on setup violations at the typical corner <br> (Default: `1`)|
| `QUIT_ON_TIMING_VIOLATIONS` <a id="QUIT_ON_TIMING_VIOLATIONS"></a> | Controls `QUIT_ON_HOLD_VIOLATIONS` and `QUIT_ON_SETUP_VIOLATIONS` <br> (Default: `1`)|
| `QUIT_ON_LINTER_WARNINGS` <a id="QUIT_ON_LINTER_WARNINGS"></a> | Quit on warnings generated by linter (currently Verilator) <br> (Default: `0`)|
| `QUIT_ON_LINTER_ERRORS` <a id="QUIT_ON_LINTER_ERRORS"></a> | Quit on errors generated by linter (currently Verilator) <br> (Default: `1`)|
| `QUIT_ON_XOR_ERROR` <a id="QUIT_ON_XOR_ERROR"></a> | Quit on XOR differences between GDSII generated by Magic and KLayout <br> (Default: `1`)|
| `QUIT_ON_KLAYOUT_DRC` <a id="QUIT_ON_KLAYOUT_DRC"></a> | Checks for DRC violations after KLayout DRC is executed and exits the flow if any was found. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|

## Misc.

|Variable|Description|
|-|-|
| `GENERATE_FINAL_SUMMARY_REPORT` <a id="GENERATE_FINAL_SUMMARY_REPORT"></a> | Specifies whether or not to generate a final summary report after the run is completed. Check command `generate_final_summary_report`. 1 = Enabled, 0 = Disabled. <br> (Default: `1`) |
| `USE_GPIO_PADS` <a id="USE_GPIO_PADS"></a> | Decides whether or not to use the gpio pads in routing by merging their LEF file set in `::env(USE_GPIO_ROUTING_LEF)` and blackboxing their verilog modules set in `::env(GPIO_PADS_VERILOG)`. 1 = Enabled, 0 = Disabled. <br> (Default: `0`) |
| `TAP_DECAP_INSERTION` <a id="TAP_DECAP_INSERTION"></a> | **Deprecated: Use `RUN_TAP_DECAP_INSERTION`**: Enables tap and decap cells insertion after floorplanning. 1 = Enabled, 0 = Disabled. |
| `RUN_ROUTING_DETAILED` <a id="RUN_ROUTING_DETAILED"></a> | **Deprecated: Use `RUN_DRT`**: Enables detailed routing. 1 = Enabled, 0 = Disabled. <br> (Default: `1`)|
| `DIODE_INSERTION_STRATEGY` <a id="DIODE_INSERTION_STRATEGY"></a> | **Deprecated: Update replacement variables `GRT_REPAIR_ANTENNAS` and `RUN_HEURISTIC_DIODE_INSERTION` as per the instructions below**: Specifies the insertion strategy of diodes to be used in the flow. |
| | 0: No diode insertion. Equivalent to replacement variables being set to `0`. |
| | 1: **Removed**: Spray diodes. |
| | 2: **Removed**: Insert fake diodes and replace them with real diodes if needed. |
| | 3: Use OpenROAD's Antenna Avoidance flow. Equivalent to replacement variables being set to `1` and `0` respectively. |
| | 4: Use Sylvain Minaut's custom script for diode insertion. Equivalent to replacement variables being set to `0` and `1` respectively. |
| | 5: **Removed**: A combination of strategies 2 and 4. |
| | 6: A combination of strategies 3 and 4. Equivalent to replacement variables being set to `1`. |
| `MAGIC_CONVERT_DRC_TO_RDB` <a id="MAGIC_CONVERT_DRC_TO_RDB"></a> | **Removed: Will always run**: Specifies whether or not generate a Calibre RDB out of the magic.drc report. Result is saved in `<run_path>/results/magic/`. 1 = Enabled, 0 = Disabled. |
| `TEST_MISMATCHES` <a id="TEST_MISMATCHES"></a> | **Removed: See `./flow.tcl -test_mismatches`**: Test for mismatches between the OpenLane tool versions and the current environment. `all` tests all mismatches. `tools` tests all except the PDK. `pdk` only tests the PDK. `none` disables the check. |
| `QUIT_ON_MISMATCHES` <a id="QUIT_ON_MISMATCHES"></a> | **Removed: See `./flow.tcl -ignore_mismatches`**: Whether to halt the flow execution or not if `TEST_MISMATCHES` is enabled and any mismatches are found. |
| `KLAYOUT_XOR_GDS` <a id="KLAYOUT_XOR_GDS"></a> | **Removed: GDS always generated**: If `RUN_KLAYOUT_XOR` is enabled, this will enable producing a GDS output from the XOR along with it's PNG export. 1 = Enabled, 0 = Disabled.|
| `KLAYOUT_XOR_XML` <a id="KLAYOUT_XOR_XML"></a> | **Removed: XML always generated**: If `RUN_KLAYOUT_XOR` is enabled, this will enable producing an XML output from the XOR. 1 = Enabled, 0 = Disabled. |
| `LEC_ENABLE` <a id="LEC_ENABLE"></a> | **Removed: buggy** Enables logic verification using yosys, for comparing each netlist at each stage of the flow with the previous netlist and verifying that they are logically equivalent. Warning: this will increase the runtime significantly. 1 = Enabled, 0 = Disabled <br> (Default: `0`)|
