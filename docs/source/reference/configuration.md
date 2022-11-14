# Configuration Variables
This page describes user-configurable variables and their default values.

## Load Order
The default configuration files in this folder are loaded in the order described in `load_order.txt`.

## Required variables

|Variable|Description|
|-|-|
| `DESIGN_NAME`   | The name of the top level module of the design        |
| `VERILOG_FILES` | The path of the design's verilog files, space-delimited. |
| `CLOCK_PERIOD`  | The clock period for the design in nanoseconds. |
| `CLOCK_NET` | The name of the net input to root clock buffer used in Clock Tree Synthesis. |
| `CLOCK_PORT`    | The name of the design's clock port used in Static Timing Analysis.   |

## Optional variables

These variables are optional that can be specified in the design configuration file.

### General
|Variable|Description|
|-|-|
| `PDK` | Specifies the process design kit (PDK). <br> (Default: `sky130A` )|
| `STD_CELL_LIBRARY` | Specifies the standard cell library to be used under the specified PDK. <br> (Default: `sky130_fd_sc_hd` )|
| `STD_CELL_LIBRARY_OPT` | Specifies the standard cell library to be used during resizer optimizations. <br> (Default: `STD_CELL_LIBRARY` )|
| `PDK_ROOT` | Specifies the folder path of the PDK. It searches for a `config.tcl` in `$::env(PDK_ROOT)/$::env(PDK)/libs.tech/openlane/` directory and at least have one standard cell library config defined in `$::env(PDK_ROOT)/$::env(PDK)/libs.tech/openlane/$::env(STD_CELL_LIBRARY)`. |
| `DIODE_PADDING` | Diode cell padding; increases the width of diode cells during placement checks. <br> (Default: `2` microns -- 2 sites)|
| `MERGED_LEF` | Points to `merged.lef`, which is a merger of various LEF files, including the technology lef, cells lef, any custom lefs, and IO lefs. |
| `NO_SYNTH_CELL_LIST` | Specifies the file that contains the don't-use-cell-list to be excluded from the liberty file during synthesis. If it's not defined, this path is searched `$::env(PDK_ROOT)/$::env(PDK)/libs.tech/openlane/$::env(STD_CELL_LIBRARY)/no_synth.cells` and if it's not found, then the original liberty will be used as is. |
| `DRC_EXCLUDE_CELL_LIST` | Specifies the file that contains the don't-use-cell-list to be excluded from the liberty file during synthesis and timing optimizations. If it's not defined, this path is searched `$::env(PDK_ROOT)/$::env(PDK)/libs.tech/openlane/$::env(STD_CELL_LIBRARY)/drc_exclude.cells` and if it's not found, then the original liberty will be used as is. In other words, `DRC_EXCLUDE_CELL_LIST` contain the only excluded cell list in timing optimizations. |

#### Macros/Chip Integration

|Variable|Description|
|-|-|
| `VERILOG_FILES_BLACKBOX` | Black-boxed, Verilog files where the implementation is ignored. Useful for pre-hardened macros you incorporate into your design, used during synthesis. |
| `EXTRA_LEFS` | Specifies LEF files of pre-hardened macros used in the current design, used in placement and routing. |
| `EXTRA_LIBS` | Specifies LIB files of pre-hardened macros used in the current design, used during timing analysis. (Optional) |
| `EXTRA_GDS_FILES` | Specifies GDS files of pre-hardened macros used in the current design, used during tape-out. |

### Synthesis

|Variable|Description|
|-|-|
| `SYNTH_BIN` | The yosys binary used in the flow. <br> (Default: `yosys`) |
| `SYNTH_CAP_LOAD` | The capacitive load on the output ports in femtofarads. <br> (Default: `33.5` ff)|
| `SYNTH_MAX_FANOUT`  | The max load that the output ports can drive. <br> (Default: `10` cells) |
| `SYNTH_MAX_TRAN` | The max transition time (slew) from high to low or low to high on cell inputs in ns. Used in synthesis <br> (Default: Calculated at runtime as `10%` of the provided clock period, unless this exceeds a set DEFAULT_MAX_TRAN, in which case it will be used as is). |
| `SYNTH_CLOCK_UNCERTAINTY`  | Specifies a value for the clock uncertainty/jitter for timing analysis. <br> (Default: `0.25`) |
| `SYNTH_CLOCK_TRANSITION`  |  Specifies a value for the clock transition /slew for timing analysis. <br> (Default: `0.15`) |
| `SYNTH_TIMING_DERATE`  | Specifies a derating factor to multiply the path delays with. It specifies the upper and lower ranges of timing. <br> (Default: `+5%/-5%`) |
| `SYNTH_STRATEGY` | Strategies for abc logic synthesis and technology mapping <br> Possible values are `DELAY/AREA 0-4/0-3`; the first part refers to the optimization target of the synthesis strategy (area vs. delay) and the second one is an index. <br> (Default: `AREA 0`)|
| `SYNTH_BUFFERING` | Enables abc cell buffering <br> Enabled = 1, Disabled = 0 <br> (Default: `1`)|
| `SYNTH_SIZING` | Enables abc cell sizing (instead of buffering) <br> Enabled = 1, Disabled = 0 <br> (Default: `0`)|
| `SYNTH_READ_BLACKBOX_LIB` | A flag that enable reading the full(untrimmed) liberty file as a blackbox for synthesis. Please note that this is not used in technology mapping. This should only be used when trying to preserve gate instances in the rtl of the design.  <br> Enabled = 1, Disabled = 0 <br> (Default: `0`)|
| `SYNTH_NO_FLAT` | A flag that disables flattening the hierarchy during synthesis, only flattening it after synthesis, mapping and optimizations. <br> Enabled = 1, Disabled = 0 <br> (Default: `0`)|
| `SYNTH_SHARE_RESOURCES` | A flag that enables yosys to reduce the number of cells by determining shareable resources and merging them. <br> Enabled = 1, Disabled = 0 <br> (Default: `1`)|
| `SYNTH_ADDER_TYPE` | Adder type to which the $add and $sub operators are mapped to. <br> Possible values are `YOSYS/FA/RCA/CSA`; where `YOSYS` refers to using Yosys internal adder definition, `FA` refers to full-adder structure, `RCA` refers to ripple carry adder structure, and `CSA` refers to carry select adder. <br> (Default: `YOSYS`)|
| `SYNTH_EXTRA_MAPPING_FILE` | Points to extra techmap file for yosys that runs right after yosys `synth` before generic techmap. <br> (Default: `""`)|
| `SYNTH_PARAMETERS` | Space-separated key value pairs to be `chparam`ed in Yosys. In the format `key1=value1 key2=value2` <br> (Default: None)  |
| `SYNTH_ELABORATE_ONLY` | "Elaborate" the design only without attempting any logic mapping. Useful when dealing with structural Verilog netlists. <br> (Default: `0`) |
| `CLOCK_BUFFER_FANOUT` | Fanout of clock tree buffers. <br> (Default: `16`) |
| `BASE_SDC_FILE` | Specifies the base sdc file to source before running Static Timing Analysis. <br> (Default: `$::env(OPENLANE_ROOT)/scripts/base.sdc`) |
| `VERILOG_INCLUDE_DIRS` | Specifies the verilog includes directories. <br> Optional. |
| `SYNTH_FLAT_TOP` | Specifies whether or not the top level should be flattened during elaboration. 1 = True, 0= False <br> (Default: `0` )|
| `IO_PCT` | Specifies the percentage of the clock period used in the input/output delays. Ranges from 0 to 1.0. <br> (Default: `0.2`) |

### STA

| Variable | Description |
|-|-|
| `STA_WRITE_LIB` | Controls whether a timing model is written using OpenROAD OpenSTA after static timing analysis. This is an option as it in its current state, the timing model generation (and the model itself) can be quite buggy. <br> (Default: `1`) |

### Floorplanning

|Variable|Description|
|-|-|
| `FP_CORE_UTIL`  | The core utilization percentage. <br> (Default: `50` percent)|
| `FP_ASPECT_RATIO`  | The core's aspect ratio (height / width). <br> (Default: `1`)|
| `FP_SIZING`  | Whether to use relative sizing by making use of `FP_CORE_UTIL` or absolute one using `DIE_AREA`. <br> (Default: `"relative"` - accepts `"absolute"` as well)|
| `DIE_AREA`  | Specific die area to be used in floorplanning when `FP_SIZING` is set to `absolute`. Specified as a 4-corner rectangle "x0 y0 x1 y1". Units in μm <br> (Default: unset)|
| `CORE_AREA` | Specific core area (i.e. die area minus margins) to be used in floorplanning when `FP_SIZING` is set to `absolute`. Specified as a 4-corner rectangle "x0 y0 x1 y1". Units in μm <br> (Default: unset)|
| `FP_IO_MODE`  | Decides the mode of the random IO placement option. 0=matching mode, 1=random equidistant mode <br> (Default: `1`)|
| `FP_WELLTAP_CELL`  | The name of the welltap cell during welltap insertion. |
| `FP_ENDCAP_CELL`  | The name of the endcap cell during endcap insertion. |
| `FP_PDN_VOFFSET`  | The offset of the vertical power stripes on the metal layer 4 in the power distribution network <br> (Default: `16.32`) |
| `FP_PDN_VPITCH`  | The pitch of the vertical power stripes on the metal layer 4 in the power distribution network <br> (Default: `153.6`) |
| `FP_PDN_HOFFSET`  | The offset of the horizontal power stripes on the metal layer 5 in the power distribution network <br> (Default: `16.65`) |
| `FP_PDN_HPITCH`  | The pitch of the horizontal power stripes on the metal layer 5 in the power distribution network <br> (Default: `153.18`) |
| `FP_PDN_AUTO_ADJUST` | Decides whether or not the flow should attempt to re-adjust the power grid, in order for it to fit inside the core area of the design, if needed. <br> 1=enabled, 0 =disabled (Default: `1`) |
| `FP_PDN_SKIPTRIM` | Enables `-skip_trim` option during pdngen which skips the metal trim step, which attempts to remove metal stubs <br> 1=enabled, 0 =disabled (Default: `1`) |
| `FP_TAPCELL_DIST`  | The horizontal distance between two tapcell columns <br> (Default: `14`) |
| `FP_IO_VEXTEND`  |  Extends the vertical io pins outside of the die by the specified units<br> (Default: `-1` Disabled) |
| `FP_IO_HEXTEND`  |  Extends the horizontal io pins outside of the die by the specified units<br> (Default: `-1` Disabled) |
| `FP_IO_VLENGTH`  | The length of the vertical IOs in microns. <br> (Default: `4`) |
| `FP_IO_HLENGTH`  | The length of the horizontal IOs in microns. <br> (Default: `4`) |
| `FP_IO_VTHICKNESS_MULT`  | A multiplier for vertical pin thickness. Base thickness is the pins layer minwidth <br> (Default: `2`) |
| `FP_IO_HTHICKNESS_MULT`  | A multiplier for horizontal pin thickness. Base thickness is the pins layer minwidth <br> (Default: `2`) |
| `FP_IO_UNMATCHED_ERROR`  | Exit on unmatched pins in a provided `FP_PIN_ORDER_CFG` file. 0=Disable 1=Enable. <br> (Default: `1` Enabled) |
| `BOTTOM_MARGIN_MULT`     | The core margin, in multiples of site heights, from the bottom boundary. If `FP_SIZING` is absolute and `CORE_AREA` is set, this variable has no effect. <br> (Default: `4`) |
| `TOP_MARGIN_MULT`        | The core margin, in multiples of site heights, from the top boundary. If `FP_SIZING` is absolute and `CORE_AREA` is set, this variable has no effect. <br> (Default: `4`) |
| `LEFT_MARGIN_MULT`       | The core margin, in multiples of site widths, from the left boundary. If `FP_SIZING` is absolute and `CORE_AREA` is set, this variable has no effect.  <br> (Default: `12`) |
| `RIGHT_MARGIN_MULT`      | The core margin, in multiples of site widths, from the right boundary. If `FP_SIZING` is absolute and `CORE_AREA` is set, this variable has no effect.   <br> (Default: `12`) |
| `FP_PDN_CORE_RING` | Enables adding a core ring around the design. More details on the control variables in the pdk configurations documentation. 0=Disable 1=Enable. <br> (Default: `0`) |
| `FP_PDN_ENABLE_RAILS` | Enables the creation of rails in the power grid. 0=Disable 1=Enable. <br> (Default: `1`) |
| `FP_PDN_ENABLE_MACROS_GRID` | Enables the connection of macros to the top level power grid. 0=Disable 1=Enable. <br> (Default: `1`) |
| `FP_PDN_MACRO_HOOKS` | Specifies explicit power connections of internal macros to the top level power grid. Comma separated list of macro instance names, power domain vdd and ground net names, and macro vdd and ground pin names: `<instance_name> <vdd_net> <gnd_net> <vdd_pin> <gnd_pin>` |
| `FP_PDN_CHECK_NODES` | Enables checking for unconnected nodes in the power grid. 0=Disable 1=Enable. <br> (Default: `1`) |
| `FP_TAP_HORIZONTAL_HALO` | Specify the horizontal halo size around macros during tap insertion. The value provided is in microns. <br> Default: `10` |
| `FP_TAP_VERTICAL_HALO` | Specify the vertical halo size around macros during tap insertion. The value provided is in microns. <br> Default: set to the value of `FP_TAP_HORIZONTAL_HALO` |
| `FP_PDN_HORIZONTAL_HALO` | Sets the horizontal halo around the macros during power grid insertion. The value provided is in microns. <br> Default: `10` |
| `FP_PDN_VERTICAL_HALO` | Sets the vertical halo around the macros during power grid insertion. The value provided is in microns. <br> Default: set to the value of `FP_PDN_HORIZONTAL_HALO` |
| `DESIGN_IS_CORE` | Controls the layers used in the power grid. Depending on whether the design is the core of the chip or a macro inside the core. 1=Is a Core, 0=Is a Macro <br> (Default: `1`)|
| `FP_PIN_ORDER_CFG` | Points to the pin order configuration file to set the pins in specific directions (S, W, E, N). Check this [file][0] as an example. If not set, then the IO pins will be placed based on one of the other methods depending on the rest of the configurations. <br> (Default: NONE)|
| `FP_CONTEXT_DEF` | Points to the parent DEF file that includes this macro/design and uses this DEF file to determine the best locations for the pins. It must be used with `FP_CONTEXT_LEF`, otherwise it's considered non-existing. If not set, then the IO pins will be placed based on one of the other methods depending on the rest of the configurations. <br> (Default: NONE)|
| `FP_CONTEXT_LEF` | Points to the parent LEF file that includes this macro/design and uses this LEF file to determine the best locations for the pins. It must be used with `FP_CONTEXT_DEF`, otherwise it's considered non-existing. If not set, then the IO pins will be placed based on one of the other methods depending on the rest of the configurations. <br> (Default: NONE)|
| `FP_DEF_TEMPLATE` | Points to the DEF file to be used as a template when running `apply_def_template`. This will be used to exctract pin names, locations, shapes -excluding power and ground pins- as well as the die area and replicate all this information in the `CURRENT_DEF`. |
| `VDD_NETS` | Specifies the power nets/pins to be used when creating the power grid for the design. |
| `GND_NETS` | Specifies the ground nets/pins to be used when creating the power grid for the design. |
| `SYNTH_USE_PG_PINS_DEFINES` | Specifies the power guard used in the verilog source code to specify the power and ground pins. This is used to automatically extract `VDD_NETS` and `GND_NET` variables from the verilog, with the assumption that they will be order `inout vdd1, inout gnd1, inout vdd2, inout gnd2, ...`. |
| `FP_IO_MIN_DISTANCE`  | The minmimum distance between the IOs in microns. <br> (Default: `3`) |
| `FP_PDN_IRDROP` | **Removed: worthless** Enable calculation of power grid IR drop during PDN generation. <br> (Default: `1`)|

#### Deprecated I/O Layer variables
These variables worked initially, but they were too sky130 specific and will be removed. Currently, if you define them in your design, they'll be used, but it's recommended to update your configuration to use `FP_IO_HLAYER` and `FP_IO_VLAYER`, which are defined in the PDK.

|Variable|Description|
|-|-|
| `FP_IO_HMETAL`  | The metal layer on which to place the io pins horizontally (top and bottom of the die). <br>(Default: `4`)|
| `FP_IO_VMETAL`  | The metal layer on which to place the io pins vertically (sides of the die) <br> (Default: `3`)|


### Resizer (Common)

|Variable|Description|
|-|-|
| `RSZ_LIB` | Points to the lib file, corresponding to the typical corner, that is used during resizer optimizations. This is copy of `LIB_SYNTH_COMPLETE`. <br> Default: automatically generated in `$::env(synthesis_tmpfiles)/resizer_<library-name>.lib` |
| `RSZ_DONT_TOUCH_RX` | A single regular expression designating nets as "don't touch" by resizer optimizations. <br> Default: `$^` (matches nothing.) |
| `LIB_RESIZER_OPT` | **Deprecated: use `RSZ_LIB`**: Points to the lib file, corresponding to the typical corner, that is used during resizer optimizations. This is copy of `LIB_SYNTH_COMPLETE`. <br> Default: automatically generated in `$::env(synthesis_tmpfiles)/resizer_<library-name>.lib` |

### Placement

|Variable|Description|
|-|-|
| `PL_TARGET_DENSITY` | The desired placement density of cells. It reflects how spread the cells would be on the core area. 1 = closely dense. 0 = widely spread <br> (Default: `($::env(FP_CORE_UTIL) +5 ) / 100.0`)|
| `PL_TIME_DRIVEN` | Specifies whether the placer should use time driven placement. 0 = false, 1 = true <br> (Default: `1`)|
| `PL_LIB` | Specifies the library for time driven placement <br> (Default: `LIB_TYPICAL`)|
| `PL_BASIC_PLACEMENT` | Specifies whether the placer should run basic placement or not (by running initial placement, increasing the minimum overflow to 0.9, and limiting the number of iterations to 20). 0 = false, 1 = true <br> (Default: `0`) |
| `PL_SKIP_INITIAL_PLACEMENT` | Specifies whether the placer should run initial placement or not. 0 = false, 1 = true <br> (Default: `0`) |
| `PL_RANDOM_GLB_PLACEMENT` | Specifies whether the placer should run random placement or not. This is useful if the design is tiny (less than 100 cells). 0 = false, 1 = true <br> (Default: `0`) |
| `PL_RANDOM_INITIAL_PLACEMENT` | Specifies whether the placer should run random placement or not followed by replace's initial placement. This is useful if the design is tiny (less than 100 cells). 0 = false, 1 = true <br> (Default: `0`) |
| `PL_ROUTABILITY_DRIVEN` | Specifies whether the placer should use routability driven placement. 0 = false, 1 = true <br> (Default: `1`) |
| `PL_RESIZER_DESIGN_OPTIMIZATIONS` | Specifies whether resizer design optimizations should be performed or not. 0 = false, 1 = true <br> (Default: `1`) |
| `PL_RESIZER_TIMING_OPTIMIZATIONS` | Specifies whether resizer timing optimizations should be performed or not. 0 = false, 1 = true <br> (Default: `1`) |
| `PL_RESIZER_MAX_WIRE_LENGTH` | Specifies the maximum wire length cap used by resizer to insert buffers. If set to 0, no buffers will be inserted. Value in microns. <br> (Default: `0`)|
| `PL_RESIZER_MAX_SLEW_MARGIN` | Specifies a margin for the slews in percentage. <br> (Default: `20`)|
| `PL_RESIZER_MAX_CAP_MARGIN` | Specifies a margin for the capacitances in percentage. <br> (Default: `20`)|
| `PL_RESIZER_HOLD_SLACK_MARGIN` | Specifies a time margin for the slack when fixing hold violations. Normally the resizer will stop when it reaches zero slack. This option allows you to overfix. <br> (Default: `0.1ns`.)|
| `PL_RESIZER_SETUP_SLACK_MARGIN` | Specifies a time margin for the slack when fixing setup violations. <br> (Default: `0.05ns`)|
| `PL_RESIZER_HOLD_MAX_BUFFER_PERCENT` | Specifies a max number of buffers to insert to fix hold violations. This number is calculated as a percentage of the number of instances in the design. <br> (Default: `50`)|
| `PL_RESIZER_SETUP_MAX_BUFFER_PERCENT` | Specifies a max number of buffers to insert to fix setup violations. This number is calculated as a percentage of the number of instances in the design. <br> (Default: `50`)|
| `PL_RESIZER_ALLOW_SETUP_VIOS` | Allows setup violations when fixing hold. <br> (Default: `0`)|

| `DONT_USE_CELLS` | The list of cells to not use during resizer optimizations. <br> Default: the contents of `DRC_EXCLUDE_CELL_LIST`. |
| `PL_ESTIMATE_PARASITICS` | Specifies whether or not to run STA after global placement using OpenROAD's estimate_parasitics -placement and generates reports under `logs/placement`. 1 = Enabled, 0 = Disabled. <br> (Default: `1`) |
| `PL_OPTIMIZE_MIRRORING` | Specifies whether or not to run an optimize_mirroring pass whenever detailed placement happens. This pass will mirror the cells whenever possible to optimize the design. 1 = Enabled, 0 = Disabled. <br> (Default: `1`) |
| `PL_RESIZER_BUFFER_INPUT_PORTS` | Specifies whether or not to insert buffers on input ports whenever resizer optimizations are run. For this to be used, `PL_RESIZER_DESIGN_OPTIMIZATIONS` must be set to 1. 1 = Enabled, 0 = Disabled. <br> (Default: `1`) |
| `PL_RESIZER_BUFFER_OUTPUT_PORTS` | Specifies whether or not to insert buffers on output ports whenever resizer optimizations are run. For this to be used, `PL_RESIZER_DESIGN_OPTIMIZATIONS` must be set to 1. 1 = Enabled, 0 = Disabled. <br> (Default: `1`) |
| `PL_RESIZER_REPAIR_TIE_FANOUT` | Specifies whether or not to repair tie cells fanout whenever resizer optimizations are run. For this to be used, `PL_RESIZER_DESIGN_OPTIMIZATIONS` must be set to 1. 1 = Enabled, 0 = Disabled. <br> (Default: `1`) |
| `PL_MAX_DISPLACEMENT_X` | Specifies how far an instance can be moved along the X-axis when finding a site where it can be placed during detailed placement. <br> (Default: `500`μm) |
| `PL_MAX_DISPLACEMENT_Y` | Specifies how far an instance can be moved along the Y-axis when finding a site where it can be placed during detailed placement. <br> (Default: `100`μm) |
| `PL_MACRO_HALO` | Macro placement halo. Format: `{Horizontal} {Vertical}` <br> (Default: `0 0`μm). |
| `PL_MACRO_CHANNEL` | Channel widths between macros. Format: `{Horizontal} {Vertical}` <br> (Default: `0 0`μm). |
| `MACRO_PLACEMENT_CFG` | Specifies the path a file specifying how openlane should place certain macros |
| `UNBUFFER_NETS` | **Deprecated: Use `RSZ_DONT_TOUCH_RX`** A regular expression used to match nets from which to remove buffers after every resizer run. Useful for analog ports in mixed-signal designs where OpenROAD may sometimes add a buffer. <br> (Default: `^$`, matches nothing.) |
| `DONT_BUFFER_PORTS` | **Removed: Use `RSZ_DONT_TOUCH_RX`.** Semicolon;delimited list of nets from which to remove buffers. <br> (Default: Empty) |

### CTS

|Variable|Description|
|-|-|
| `CTS_TARGET_SKEW` | The target clock skew in picoseconds. <br> (Default: `200`ps)|
| `CLOCK_TREE_SYNTH` | Enable clock tree synthesis. <br> (Default: `1`)|
| `FILL_INSERTION` | Enables fill cells insertion after cts (if enabled). 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `CTS_TOLERANCE` | An integer value that represents a tradeoff of QoR and runtime. Higher values will produce smaller runtime but worse QoR <br> (Default: `100`) |
| `CTS_SINK_CLUSTERING_SIZE` | Specifies the maximum number of sinks per cluster. <br> (Default: `25`) |
| `CTS_SINK_CLUSTERING_MAX_DIAMETER` | Specifies maximum diameter (in micron) of sink cluster. <br> (Default: `50`) |
| `CTS_REPORT_TIMING` | Specifies whether or not to run STA after clock tree synthesis using OpenROAD's estimate_parasitics -placement and generates reports under `logs/cts`. 1 = Enabled, 0 = Disabled. <br> (Default: `1`) |
| `CTS_CLK_MAX_WIRE_LENGTH` | Specifies the maximum wire length on the clock net. Value in microns. <br> (Default: `0`) |
| `CTS_DISABLE_POST_PROCESSING` | Specifies whether or not to disable post cts processing for outlier sinks. <br> (Default: `0`) |
| `CTS_DISTANCE_BETWEEN_BUFFERS` | Specifies the distance (in microns) between buffers when creating the clock tree (Default: `0`) |
| `LIB_CTS` | The liberty file used for CTS. By default, this is the `LIB_SYNTH_COMPLETE` minus the cells with drc errors as specified by the drc exclude list. <br> (Default: `$::env(cts_tmpfiles)/cts.lib`) |
| `RUN_SIMPLE_CTS` | **Removed: TritonCTS is always run**: Runs an alternative simple clock tree synthesis after synthesis instead of TritonCTS. 1 = Enabled, 0 = Disabled <br> (Default: `0`)|

### Routing

> **Note:** All variables previously prefixed GLB_RT_ have had their prefix changed to GRT_.

|Variable|Description|
|-|-|
| `GLOBAL_ROUTER` | Specifies which global router to use. Values: `fastroute`. (`cugr` is deprecated and fastroute will be used instead.) <br> (Default: `fastroute`) |
| `DETAILED_ROUTER` | Specifies which detailed router to use. Values: `tritonroute`. (`drcu`/`tritonroute_or` are both deprecated and tritonroute will be used instead.) <br> (Default: `tritonroute`)|
| `ROUTING_CORES` | Specifies the number of threads to be used in TritonRoute. Can be overriden via environment variable. <br> (Default: `2`) |
| `RT_CLOCK_MIN_LAYER` | The name of lowest layer to be used in routing the clock net. <br> (Default: `RT_MIN_LAYER`)|
| `RT_CLOCK_MAX_LAYER` | The name of highest layer to be used in routing the clock net. <br> (Default: `RT_MAX_LAYER`)|
| `GLB_RESIZER_TIMING_OPTIMIZATIONS` | Specifies whether resizer timing optimizations should be performed after global routing or not. 0 = false, 1 = true <br> (Default: `1`)
| `GLB_RESIZER_MAX_WIRE_LENGTH` | Specifies the maximum wire length cap used by resizer to insert buffers. If set to 0, no buffers will be inserted. Value in microns. <br> (Default: `0`)|
| `GLB_RESIZER_MAX_SLEW_MARGIN` | Specifies a margin for the slews. <br> (Default: `10`)|
| `GLB_RESIZER_MAX_CAP_MARGIN` | Specifies a margin for the capacitances. <br> (Default: `10`)|
| `GLB_RESIZER_HOLD_SLACK_MARGIN` | Specifies a time margin for the slack when fixing hold violations. Normally the resizer will stop when it reaches zero slack. This option allows you to overfix. <br> (Default: `0.05ns`)|
| `GLB_RESIZER_SETUP_SLACK_MARGIN` | Specifies a time margin for the slack when fixing setup violations. <br> (Default: `0.025ns`)|
| `GLB_RESIZER_HOLD_MAX_BUFFER_PERCENT` | Specifies a max number of buffers to insert to fix hold violations. This number is calculated as a percentage of the number of instances in the design. <br> (Default: `50`)|
| `GLB_RESIZER_SETUP_MAX_BUFFER_PERCENT` | Specifies a max number of buffers to insert to fix setup violations. This number is calculated as a percentage of the number of instances in the design. <br> (Default: `50`)|
| `GLB_RESIZER_ALLOW_SETUP_VIOS` | Allows setup violations when fixing hold. <br> (Default: `0`)|
| `GLB_OPTIMIZE_MIRRORING` | Specifies whether or not to run an optimize_mirroring pass whenever detailed placement happens after Routing timing optimization. This pass will mirror the cells whenever possible to optimize the design. 1 = Enabled, 0 = Disabled. <br> (Default: `1`) |
| `GRT_ALLOW_CONGESTION` | Allow congestion in the resulting guides. 0 = false, 1 = true <br> (Default: `0`) 
| `GRT_OVERFLOW_ITERS` | The maximum number of iterations waiting for the overflow to reach the desired value. <br> (Default: `50`) |
| `GRT_ANT_ITERS` | The maximum number of iterations for global router repair_antenna. This option is only available in `DIODE_INSERTION_STRATEGY` = `3`. <br> (Default: `3`) |
| `GRT_ESTIMATE_PARASITICS` | Specifies whether or not to run STA after global routing using OpenROAD's estimate_parasitics -global_routing and generates reports under `logs/routing`. 1 = Enabled, 0 = Disabled. <br> (Default: `1`) |
| `GRT_MAX_DIODE_INS_ITERS` | Controls the maximum number of iterations at which re-running Fastroute for diode insertion stops. Each iteration ARC detects the violations and FastRoute fixes them by inserting diodes, then producing the new DEF. The number of antenna violations is compared with the previous iteration and if they are equal or the number is greater the iterations stop and the DEF from the previous iteration is used in the rest of the flow. If the current antenna violations reach zero, the current def will be used and the iterations will not continue. This option is only available in DIODE_INSERTION_STRATEGY = `3` and `6`.  <br> (Default: `1`) |
| `GRT_OBS` | Specifies custom obstruction to be added prior to global routing. Comma separated list of layer and coordinates: `layer llx lly urx ury`, where `ll` and `ur` stand for "lower left" and "upper right" respectively.<br> (Example: `li1 0 100 1000 300, met5 0 0 1000 500`)  <br> (Default: unset) |
| `GRT_ADJUSTMENT` | Reduction in the routing capacity of the edges between the cells in the global routing graph. Values range from 0 to 1. <br> 1 = most reduction, 0 = least reduction  <br> (Default: `0.3`)|
| `GRT_MACRO_EXTENSION` | Sets the number of GCells added to the blockages boundaries from macros. A GCell is typically defined in terms of Mx routing tracks. The default GCell size is 15 M3 pitches. <br> (Default: `0`) |
| `DRT_MIN_LAYER` | An optional override to the lowest layer used in detailed routing. For example, in sky130, you may want global routing to avoid li1, but let detailed routing use li1 if it has to. <br> (Default: `RT_MIN_LAYER`)|
| `DRT_MAX_LAYER` | An optional override to the highest layer used in detailed routing. <br> (Default: `RT_MAX_LAYER`)|
| `DRT_OPT_ITERS` | Specifies the maximum number of optimization iterations during Detailed Routing in TritonRoute. <br> (Default: `64`) |
| `ROUTING_OPT_ITERS` |**Removed: Use DRT_OPT_ITERS**: Specifies the maximum number of optimization iterations during Detailed Routing in TritonRoute. <br> (Default: `64`) |
| `GLB_RT_MINLAYER` | **Removed: Use RT_MIN_LAYER**: The number of lowest layer to be used in routing. <br> (Default: `1`)|
| `GLB_RT_MAXLAYER` | **Removed: Use RT_MAX_LAYER**: The number of highest layer to be used in routing. <br> (Default: `6`)|
| `GLB_RT_CLOCK_MINLAYER` | **Removed: Use RT_CLOCK_MIN_LAYER**: The number of lowest layer to be used in routing the clock net. <br> (Default: `GLB_RT_MINLAYER`)|
| `GLB_RT_CLOCK_MAXLAYER` | **Removed: Use RT_CLOCK_MIN_LAYER**: The number of highest layer to be used in routing the clock net. <br> (Default: `GLB_RT_MAXLAYER`)|
| `GLB_RT_L{1/2/3/4/5/6}_ADJUSTMENT` | **Removed: See PDK variable `GRT_LAYER_ADJUSTMENTS` instead**: Reduction in the routing capacity of the edges between the cells in the global routing graph but specific to a metal layer in sky130A. Values ranged from 0 to 1 |
| `GLB_RT_UNIDIRECTIONAL` | **Removed**: Allow unidirectional routing. 0 = false, 1 = true <br> (Default: `1`) |
| `GLB_RT_TILES` | **Removed**: The size of the GCELL used by Fastroute during global routing. <br> (Default: `15`) |

### RC Extraction

|Variable|Description|
|-|-|
| `SPEF_EXTRACTOR` | Specifies which spef extractor to use. Values: `openrcx` or (**removed:** `def2spef`). <br> (Default: `openrcx`) |
| `RCX_MERGE_VIA_WIRE_RES` | Specifies whether to merge the via resistance with the wire resistance or separate it from the wire resistance. 1 = Merge via resistance, 0 = Separate via resistance <br> (Default: `1`)|
| `RCX_SDC_FILE` | Specifies SDC file to be used for RCX-based STA, which can be different from the one used for implementation. <br> (Default: `BASE_SDC_FILE`) |
| `SPEF_WIRE_MODEL` | **Removed:** Specifies the wire model used in SPEF extraction. Options are `L` or `Pi`  <br> (Default: `L`) |
| `SPEF_EDGE_CAP_FACTOR` | **Removed:** Specifies the edge capacitance factor used in SPEF extraction. Ranges from 0 to 1 <br> (Default: `1`) |

### Magic
|Variable|Description|
|-|-|
| `MAGIC_PAD` |  A flag to pad the views generated by magic (.mag, .lef, .gds) with one site. 1 = Enabled, 0 = Disabled <br> (Default: `0` )|
| `MAGIC_ZEROIZE_ORIGIN` | A flag to move the layout such that it's origin in the lef generated by magic is 0,0. 1 = Enabled, 0 = Disabled  <br> (Default: `1` )|
| `MAGIC_GENERATE_GDS` | A flag to generate gds view via magic. 1 = Enabled, 0 = Disabled  <br> (Default: `1` )|
| `MAGIC_GENERATE_LEF` | A flag to generate lef view via magic. 1 = Enabled, 0 = Disabled  <br> (Default: `1` )|
| `MAGIC_GENERATE_MAGLEF` | A flag to generate maglef view via magic. Requires `MAGIC_GENERATE_LEF` to be also set. 1 = Enabled, 0 = Disabled  <br> (Default: `1` )|
| `MAGIC_WRITE_FULL_LEF` | A flag to specify whether or not the output LEF should include all shapes inside the macro or an abstracted view of the macro lef view via magic. 1 = Full View, 0 = Abstracted View  <br> (Default: `0` )|
| `MAGIC_DRC_USE_GDS` | A flag to choose whether to run the magic DRC checks on GDS or not. If not, then the checks will be done on the DEF/LEF. 1 = GDS, 0 = DEF/LEF  <br> (Default: `1` )|
| `MAGIC_EXT_USE_GDS` | A flag to choose whether to run the magic extractions on GDS or DEF/LEF. If GDS was used Device Level LVS will be run. Otherwise, blackbox LVS will be run. 1 = GDS, 0 = DEF/LEF  <br> (Default: `0` )|
| `MAGIC_INCLUDE_GDS_POINTERS` | A flag to choose whether to include GDS pointers in the generated mag files or not. 1 = Enabled, 0 = Disabled  <br> (Default: `0` )|
| `MAGIC_DISABLE_HIER_GDS` | A flag to disable cif hier and array during GDSII writing.* 1=Enabled `<so this hier gds will be disabled>`, 0=Disabled `<so this hier gds will be enabled>`. <br> (Default: `1` )|
| `MAGIC_DEF_NO_BLOCKAGES` | A flag to choose whether blockages are read with DEF files or not (they are read as a sheet of metal by Magic). 1 = No Blockages, 0 = Blockages as Metal Sheets  <br> (Default: `1` )|
| `MAGIC_DEF_LABELS` | A flag to choose whether labels are read with DEF files or not. From the magic docs: "The '-labels' option to the 'def read' command causes each net in the NETS and SPECIALNETS sections of the DEF file to be annotated with a label having the net name as the label text." 1 = Labels, 0 = Unlabeled  <br> (Default: `1` )|
> * Tim Edwards's Explanation on disabling hier gds: The following is an explanation by Tim Edwards, provided in a slack thread, on how this affects the GDS writing process: "Magic can take a very long time writing out GDS while checking hierarchical interactions in a standard cell layout. If your design is all digital, I recommend using "gds *hier write disable" before "gds write" so that it does not try to resolve hierarchical interactions (since by definition, standard cells are designed to just sit next to each other without creating DRC issues).  That can actually make the difference between a 20 hour GDS write and a 2 minute GDS write.  For a standard cell design that takes up the majority of the user space, a > 24 hour write time (without disabling the hierarchy checks) would not surprise me."

### LVS

|Variable|Description|
|-|-|
| `LVS_INSERT_POWER_PINS` |  Enables power pins insertion before running lvs. 1 = Enabled, 0 = Disabled <br> (Default: `1` )|
| `LVS_CONNECT_BY_LABEL` | Enables connections by label in LVS by skipping `extract unique` in magic extractions. <br> Default: `0` |
| `YOSYS_REWRITE_VERILOG` | Enables yosys to rewrite the verilog before LVS producing a canonical verilog netlist with verbose wire declarations. 1 = Enabled, 0 = Disabled <br> (Default: `0` ) |

### Flow control

|Variable|Description|
|-|-|
| `USE_GPIO_PADS` | Decides whether or not to use the gpio pads in routing by merging their LEF file set in `::env(USE_GPIO_ROUTING_LEF)` and blackboxing their verilog modules set in `::env(GPIO_PADS_VERILOG)`. 1=Enabled, 0=Disabled. <br> (Default: `0`) |
| `LEC_ENABLE` | Enables logic verification using yosys, for comparing each netlist at each stage of the flow with the previous netlist and verifying that they are logically equivalent. Warning: this will increase the runtime significantly. 1 = Enabled, 0 = Disabled <br> (Default: `0`)|
| `RUN_DRT` | Enables detailed routing. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `RUN_LVS` | Enables running LVS. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `PRIMARY_SIGNOFF_TOOL` | Determines whether `magic` or `klayout` is the primary signoff tool. <br> (Default: `magic`) |
| `RUN_MAGIC` | Enables running magic and GDSII streaming. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `RUN_MAGIC_DRC` | Enables running magic DRC on GDSII produced by magic. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `RUN_KLAYOUT` | Enables running KLayout and GDSII streaming. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `RUN_KLAYOUT_DRC` | Enables running KLayout DRC on GDSII produced by magic. 1 = Enabled, 0 = Disabled <br> (Default: `0`)|
| `KLAYOUT_DRC_KLAYOUT_GDS` | Enables running KLayout DRC on GDSII produced by KLayout. 1 = Enabled, 0 = Disabled <br> (Default: `0`)|
| `RUN_KLAYOUT_XOR` | Enables running KLayout XOR on 2 GDSIIs, the defaults are the one produced by magic vs the one produced by klayout. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `KLAYOUT_XOR_GDS` | If `RUN_KLAYOUT_XOR` is enabled, this will enable producing a GDS output from the XOR along with it's PNG export. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `KLAYOUT_XOR_XML` | If `RUN_KLAYOUT_XOR` is enabled, this will enable producing an XML output from the XOR. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `TAKE_LAYOUT_SCROT` | Enables running KLayout to take a PNG screenshot of the produced layout (currently configured to run on the results of each stage).1 = Enabled, 0 = Disabled <br> (Default: `0`)|
| `TAP_DECAP_INSERTION` | Enables tap and decap cells insertion after floorplanning (if enabled) .1 = Enabled, 0 = Disabled <br> (Default: `1`) |
| `DIODE_INSERTION_STRATEGY` | Specifies the insertion strategy of diodes to be used in the flow. |
| | 0: No diode insertion. |
| | 1: Spray diodes. |
| | 2: Insert fake diodes and replace them with real diodes if needed. |
| | (**Default**) 3: Use OpenROAD's Antenna Avoidance flow. |
| | 4: Use Sylvain Minaut's custom script for diode insertion. |
| | 5: A combination of strategies 2 and 4. |
| | 6: A combination of strategies 3 and 4. | 
| `USE_ARC_ANTENNA_CHECK` | Specifies whether to use the openroad ARC antenna checker or magic antenna checker. 0=magic antenna checker, 1=ARC OR antenna checker <br> (Default: `1`)
| `RUN_SPEF_EXTRACTION` | Specifies whether or not to run SPEF extraction on the routed DEF. 1=enabled 0=disabled <br> Default: `1` |
| `GENERATE_FINAL_SUMMARY_REPORT` | Specifies whether or not to generate a final summary report after the run is completed. Check command `generate_final_summary_report`. 1=enabled 0=disabled <br> Default: `1` |
| `RUN_CVC` | Runs CVC on the output spice, which is a Circuit Validity Checker. Voltage aware ERC checker for CDL netlists. 1=Enabled, 0=Disabled. <br> Default: `1` |
| `RUN_IRDROP_REPORT` | Creates an IR Drop report using OpenROAD PSM. 1=Enabled, 0=Disabled. <br> Default: `0` |
| `MAGIC_CONVERT_DRC_TO_RDB` | **Removed: Will always run** Specifies whether or not generate a Calibre RDB out of the magic.drc report. Result is saved in `<run_path>/results/magic/`. 1=enabled 0=disabled <br> Default: `1`|
| `TEST_MISMATCHES` | **Removed: See `./flow.tcl -test_mismatches`** Test for mismatches between the OpenLane tool versions and the current environment. `all` tests all mismatches. `tools` tests all except the PDK. `pdk` only tests the PDK. `none` disables the check.<br> (Default: `all`) |
| `QUIT_ON_MISMATCHES` | **Removed: See `./flow.tcl -ignore_mismatches`** Whether to halt the flow execution or not if mismatches are found. (Default: `1`) |

### Checkers

|Variable|Description|
|-|-|
| `CHECK_UNMAPPED_CELLS` | Checks if there are unmapped cells after synthesis and aborts if any was found. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `CHECK_ASSIGN_STATEMENTS` | Checks for assign statement in the generated gate level netlist and aborts of any was found.1 = Enabled, 0 = Disabled <br> (Default: `0`)|
| `QUIT_ON_TR_DRC` | Checks for DRC violations after routing and exits the flow if any was found. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `QUIT_ON_LONG_WIRE` | Exits the flow if any wire length exceeds the threshold set in the PDK. 1 = Enabled, 0 = Disabled <br> (Default: `0`)|
| `QUIT_ON_MAGIC_DRC` | Checks for DRC violations after magic DRC is executed and exits the flow if any was found. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `QUIT_ON_ILLEGAL_OVERLAPS` | Checks for illegal overlaps during magic extraction. In some cases, these imply existing undetected shorts in the design. It also exits the flow if any was found. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `QUIT_ON_LVS_ERROR` | Checks for LVS errors after netgen LVS is executed and exits the flow if any was found. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|


[0]: ./../../../designs/spm/pin_order.cfg
