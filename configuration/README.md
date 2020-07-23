# Variables information

This page describes configuration variables and their default values.

## Required variables

| Variable      | Description                                           |
|---------------|-------------------------------------------------------|
| `DESIGN_NAME`   | The name of the top level module of the design        |
| `VERILOG_FILES` | The path of the design's verilog files |
| `CLOCK_PERIOD`  | The clock period for the design in ns       |
| `CLOCK_NET` | The name of the Net input to root clock buffer. |
| `CLOCK_PORT`    | The name of the design's clock port    |

## Optional variables

These variables are optional that can be specified in the design configuration file.

### Synthesis

| Variable      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `LIB_SYNTH` | The library used for synthesis by yosys. <br> (Default: `./pdks/ef-skywater-s8/EFS8A/libs.ref/liberty/efs8hd/efs8hd_tt_1.80v_25C.lib`)|
| `SYNTH_DRIVING_CELL`  | The cell to drive the input ports. <br>(Default: `efs8hd_inv_8`)|
| `SYNTH_DRIVING_CELL_PIN`  | The name of the SYNTH_DRIVING_CELL output pin. <br>(Default: `Y`)|
| `SYNTH_CAP_LOAD` | The capacitive load on the output ports in femtofarads. <br> (Default: `17.65` ff)|
| `SYNTH_MAX_FANOUT`  | The max load that the output ports can drive. <br> (Default: `5` cells) |
| `SYNTH_MAX_TRANS` | The max transition time (slew) from high to low or low to high on cell inputs in ns. Used in synthesis <br> (Default: Calculated at runtime as `10%` of the provided clock period)|
| `SYNTH_STRATEGY` | Strategies for abc logic synthesis and technology mapping <br> Possible values are 0, 1 (delay), 2, and 3 (area)<br> (Default: `2`)|
| `SYNTH_BUFFERING` | Enables abc cell buffering <br> Enabled = 1, Disabled = 0 <br> (Default: `1`)|
| `SYNTH_SIZING` | Enables abc cell sizing (instead of buffering) <br> Enabled = 1, Disabled = 0 <br> (Default: `0`)|
| `SYNTH_READ_BLACKBOX_LIB` | A flag that enable reading the full(untrimmed) libretry file as a blackbox for synthesis. Please note that this is not used in technology mapping. This should only be used when trying to preserve gate instances in the rtl of the design.  <br> Enabled = 1, Disabled = 0 <br> (Default: `0`)|
| `SYNTH_NO_FLAT` | A flag that disables flattening the heirachry during synthesis, only flattening it after synthesis, mapping and optimizations. <br> Enabled = 1, Disabled = 0 <br> (Default: `0`)|
| `LIB_MIN` | Library used for min delay calculation during STA. <br> (Default:`./pdks/ef-skywater-s8/EFS8A/libs.ref/liberty/efs8hd/efs8hd_ss_1.60v_100C.lib`) |
| `LIB_MAX`  | Library used for max delay calculation during STA. <br> (Default:`./pdks/ef-skywater-s8/EFS8A/libs.ref/liberty/efs8hd/efs8hd_ff_1.95v_-40C.lib`) |
| `LIB_TYPICAL` | Library used for typical delay calculation during STA. <br> (Default`LIB_SYNTH`) |
| `CLOCK_BUFFER_FANOUT` | Fanout of clock tree buffers. <br> (Default: `16`) |
| `ROOT_CLK_BUFFER` | Root clock buffer of the clock tree. <br> (Default: `efs8hd_clkbuf_16`) |
| `CLK_BUFFER` | Clock buffer used for inner nodes of the clock tree. <br> (Default: `efs8hd_clkbuf_4`) |
| `CLK_BUFFER_INPUT` | Input pin of the clock tree buffer. <br> (Default: `A`) |
| `CLK_BUFFER_OUTPUT` | Output pin of the clock tree buffer. <br> (Default: `X`) |




### Floorplanning

| Variable      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `FP_CORE_UTIL`  | The core utilization percentage. <br> (Default: `50` percent)|
| `FP_ASPECT_RATIO`  | The core's aspect ratio (height / width). <br> (Default: `1`)|
| `FP_CORE_MARGIN`  | The length of the margin surrounding the core area. <br> (Default: `3.36` microns)|
| `FP_IO_HMETAL`  | The metal layer on which to place the io pins horizontally (top and bottom of the die). <br>(Default: `3`)|
| `FP_IO_VMETAL`  | The metal layer on which to place the io pins vertically (sides of the die) <br> (Default: `2`)|
| `FP_WELLTAP_CELL`  | The name of the welltap cell during welltap insertion. <br> (Default: `efs8hd_tap_1`)|
| `FP_ENDCAP_CELL`  | The name of the endcap cell during endcap insertion. <br> (Default: `efs8hd_decap_3`)|
| `FP_PDN_VOFFSET`  | The offset of the vertical power stripes on the metal layer 4 in the power distribution network <br> (Default: `16.32`) |
| `FP_PDN_VPITCH`  | The pitch of the vertical power stripes on the metal layer 4 in the power distribution network <br> (Default: `153.6`) |
| `FP_PDN_HOFFSET`  | The offset of the horizontal power stripes on the metal layer 5 in the power distribution network <br> (Default: `16.65`) |
| `FP_PDN_HPITCH`  | The pitch of the horizontal power stripes on the metal layer 5 in the power distribution network <br> (Default: `153.18`) |
| `FP_TAPCELL_DIST`  | The horizontal distance between two tapcell columns <br> (Default: `25`) |
| `FP_IO_VEXTEND`  |  Extends the vertical io pins outside of the die by the specified units<br> (Default: `-1` Disabled) |
| `FP_IO_HEXTEND`  |  Extends the horizontal io pins outside of the die by the specified units<br> (Default: `-1` Disabled) |
| `FP_IO_VTHICKNESS_MULT`  | A multiplier for vertical pin thickness. Base thickness is the pins layer minwidth <br> (Default: `1`) |
| `FP_IO_HTHICKNESS_MULT`  | A multiplier for horizontal pin thickness. Base thickness is the pins layer minwidth <br> (Default: `1`) |

### Placement

| Variable      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `PL_TARGET_DENSITY` | The desired placement density of cells. It reflects how spread the cells would be on the core area. 1 = closely dense. 0 = widely spread <br> (Default: `0.4`)|
| `PL_TIME_DIRVEN` | Specifies whether the placer should use time driven placement. 0 = false, 1 = true <br> (Default: `0`)|
| `PL_LIB` | Specifies the library for time driven placement <br> (Default: `LIB_TYPICAL`)|

### CTS

| Variable      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `CTS_TARGET_SKEW` | The target clock skew in picoseconds. <br> (Default: `20` ps)|
| `CTS_ROOT_BUFFER`| The name of cell inserted at the root of the clock tree. <br> (Default: `efs8hd_clkbuf_16`)|
| `CLOCK_TREE_SYNTH` | Enable clock tree synthesis for tirtonCTS. <br> (Default: `1`)|
| `CTS_TOLERANCE` | an integer value that represents a tradeoff of QoR and runtime. Higher values will produce smaller runtime but worse QoR <br> (Default: `100`) |

### Routing

| Variable      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `GLB_RT_MAXLAYER` | The number of highest layer to be used in routing. <br> (Default: `6`)|
| `GLB_RT_ADJUSTMENT` | Reduction in the routing capacity of the edges between the cells in the global routing graph. Values range from 0 to 1. <br> 1 = most reduction, 0 = least reduction  <br> (Default: `0.15`)|
| `GLB_RT_L1_ADJUSTMENT` | Reduction in the routing capacity of the edges between the cells in the global routing graph but specific to li1 layer in ef-skywater-s8/EFS8A. Values range from 0 to 1 <br> (Default: `0`) |
| `GLB_RT_L2_ADJUSTMENT` | Reduction in the routing capacity of the edges between the cells in the global routing graph but specific to met1 in ef-skywater-s8/EFS8A. Values range from 0 to 1 <br> (Default: `0`) |
| `ROUTING_STRATEGY` | Specifies the optimization mode to be used in TritonRoute. Values range from 0 to 3. If set to 14 TritonRoute14 will be used. <br> (Default: `0`) |

### Magic
| Variable      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `MAGIC_PAD` |  A flag to pad the views generated by magic (.mag, .lef, .gds) with one site. 1 = Enabled, 0 = Disabled <br> (Default: `0` )|
| `MAGIC_ZEROIZE_ORIGIN` | A flag to move the layout such that it's origin in the lef generated by magic is 0,0. 1 = Enabled, 0 = Disabled  <br> (Default: `1` )|
| `MAGIC_GENERATE_GDS` | A flag to generate gds view via magic . 1 = Enabled, 0 = Disabled  <br> (Default: `1` )|
| `MAGIC_GENERATE_LEF` | A flag to generate lef view via magic . 1 = Enabled, 0 = Disabled  <br> (Default: `1` )|

### Misc
| Variable      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `PDK` | Specifies the process design kit (pdk). <br> (Default: `ef-skywater-s8/EFS8A` )|
| `PDK_VARIANT` | Specifies the process design kit (pdk) variant. <br> (Default: `efs8hd` )|
| `PDK_ROOT` | Specifies the folder path of the pdk. It searches for a `config.tcl` in `$PDK_ROOT/$PDK/libs.tech/openlane/` directory and at least have one variant config defined in `$PDK_ROOT/$PDK/libs.tech/openlane/$PAD_VARIANT`. <br> See [this][3] pdk config file and  [this][4] variant config file as an example . <br> (Default: `$OPENLANE_ROOT/pdks/` )|
| `CELL_PAD` | Cell padding; increases the width of cells. <br> (Default: `2` microns -- 2 sites)|

### Flow control
| Variable      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `RUN_ROUTING_DETAILED` | Enables detailed routing. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `RUN_MAGIC` | Enables running magic and GDSII streaming.1 = Enabled, 0 = Disabled <br> (Default: `0`)|
| `RUN_SIMPLE_CTS` | Enables inserting simple clock tree after synthesis .1 = Enabled, 0 = Disabled <br> (Default: `0`)|
| `RUN_RESIZER_OVERBUFFER` | Enables inserting buffers to reduce the number of long wires.1 = Enabled, 0 = Disabled <br> (Default: `0`)|
| `FILL_INSERTION` | Enables fill cells insertion after cts (if enabled) .1 = Enabled, 0 = Disabled <br> (Default: `0`)|
| `DIODE_INSERTION_STRATEGY` | Specifies the insertion strategy of diodes to be used in the flow. 0 = No diode insertion, 1 = Spray diodes, 2 = insert fake diodes and replace them with real diodes if needed <br> (Default: `1`) |
| `WIDEN_SITE` | Specifies the new virtual width of the site to be used in all stages up to diode insertion, then switched back to the original site width. It can be either a factor or an absolute value controlled by `WIDEN_SITE_IS_FACTOR` <br> (Default: `1`) |
| `WIDEN_SITE_IS_FACTOR` | Specifies Whether the given `WIDEN_SITE` should be treated as a factor or an absolute value. 0 = absolute, 1 = factor <br> (Default: `1`) |

### Checkers
| Variable      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `CHECK_UNMAPPED_CELLS` | Checks if there are unmapped cells after synthesis and aborts if any was found. 1 = Enabled, 0 = Disabled <br> (Default: `0`)|
| `CHECK_ASSIGN_STATEMENTS` | Checks for assign statement in the generated gate level netlist and aborts of any was found.1 = Enabled, 0 = Disabled <br> (Default: `0`)|
| `CHECK_LATCHES_IN_DESIGN` | Checks for any latches or failures in synthesis and aborts if any was found. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `CHECK_DIODE_PLACEMENT` | Checks if there was any failure in legalizing placement after inserting diodes and aborts if any was found.1 = Enabled, 0 = Disabled <br> (Default: `1`)|


[3]: ../pdks/ef-skywater-s8/EFS8A/libs.tech/config.tcl
[4]: ../pdks/ef-skywater-s8/EFS8A/libs.tech/config.tcl


