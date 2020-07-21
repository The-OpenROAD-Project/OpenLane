# Variables information

## Default Printed Information Variables
| Variable      | Description                                           |
|---------------|-------------------------------------------------------|
| `design`   | The name of the top level module of the design        |
| `config`   | The name of the configurations file of the design        |
| `runtime`   | The runtime of running the process on the design. Extracted from runtime.txt       |
| `DIEAREA_mm^2`   | The diearea in mm<sup>2</sup> as reported from the def file.        |
| `CellPer_mm^2`   | The number of cells in the design as reported by yosys divided by the diearea in mm<sup>2</sup>.      |
| `(Cell/mm^2)/Core_Util`   | The number of cells in the design as reported by yosys divided by the diearea in mm<sup>2</sup>, all divided by the FP_CORE_UTIL configuration parameter.     |
| `OpenDP_Util`   | The core utilization of the design. Extracted from openDP logs.        |
| `Peak_Memory_Usage_MB`   | The peak memory usage of triton route during optimization iterations. Extracted from tritonRoute logs.        |
| `cell_count`   | The number of cells in the design. Extracted from yosys logs.        |
| `tritonRoute_Violations`   | The total number of violations from running TritonRoute. Extracted from tritonRoute logs.        |
| `Short_Violations`   | The total number of shorts violations from running TritonRoute. Extracted from tritonRoute drc.        |
| `MetSpc_violations`   | The total number of MetSpc violations from running TritonRoute. Extracted from tritonRoute drc.        |
| `OffGrid_violations`   | The total number of off-grid violations from running TritonRoute. Extracted from tritonRoute drc.        |
| `MinHole_violations`   | The total number of MinHole violations from running TritonRoute. Extracted from tritonRoute drc.        |
| `Other_violations`   | The total number of other types of violations from running TritonRoute. Extracted from tritonRoute drc.        |
| `Magic_violations`   | The total number of magic drc violations from running TritonRoute. Extracted from Magic drc.        |
| `antenna_violations`   | The total number of magic drc violations from running TritonRoute. Extracted from Magic drc.        |
| `wire_length`   | The total wire length in the design. Extracted from tritonRoute logs.        |
| `vias`   | The number of vias in the final design. Extracted from tritonRoute logs.        |
| `wns`   | Worst Negative Slack. Extracted from OpenSTA.        |
| `HPWL`   | Final value for the half-perimeter wire length. Extracted from RePlace logs.       |
| `wires_count`   | The number of wires in the design. Extracted from yosys logs.        |
| `wire_bits`   | The number of wire bits in the design. Extracted from yosys logs.        |
| `public_wires_count`   | The number of public wires in the design. Extracted from yosys logs.        |
| `public_wire_bits`   | The number of public wire bits in the design. Extracted from yosys logs.        |
| `memories_count`   | The number of memories in the design. Extracted from yosys logs.        |
| `memory_bits`   | The number of memory bits in the design. Extracted from yosys logs.        |
| `cells_pre_abc`   | The number of cells before ABC. Extracted from yosys logs.        |
| `AND`   | The number of AND gates in the design. Extracted from yosys logs.        |
| `DFF`   | The number of flip flops in the design. Extracted from yosys logs.        |
| `NAND`   | The number of NAND gates in the design. Extracted from yosys logs.        |
| `NOR`   | The number of NOR gates in the design. Extracted from yosys logs.        |
| `OR`   | The number of OR gates in the design. Extracted from yosys logs.        |
| `XOR`   | The number of XOR gates in the design. Extracted from yosys logs.        |
| `XNOR`   | The number of XNOR gates in the design. Extracted from yosys logs.        |
| `MUX`   | The number of multiplexers in the design. Extracted from yosys logs.        |
| `inputs`   | The number of inputs in the design. Extracted from yosys logs.        |
| `outputs`   | The number of outputs in the design. Extracted from yosys logs.        |
| `level`   | The number of levels in the final design. Extracted from yosys logs.        |
| `EndCaps`   | The number of endcaps in the final design. Extracted from tapcell log.        |
| `TapCells`   | The number of tapcells in the final design. Extracted from tapcell log.        |
| `Diodes`   | The number of diodes in the final design. Extracted from diode logs.        |
| `Total_Physical_Cells`   | The sum of endcaps, tapcells, and diodes in the final design.        |


## Default Printed Configuration Variables

| Variable      | Description                                           |
|---------------|-------------------------------------------------------|
| `CLOCK_PERIOD`  | The clock period for the design in ns       |
| `SYNTH_STRATEGY` | Strategies for abc logic synthesis and technology mapping <br> Possible values are 0, 1 (delay), 2, and 3 (area)<br> (Default: `2`)|
| `SYNTH_MAX_FANOUT`  | The max load that the output ports can drive. <br> (Default: `5` cells) |
| `FP_CORE_UTIL`  | The core utilization percentage. <br> (Default: `50` percent)|
| `FP_CORE_MARGIN`  | The length of the margin surrounding the core area. <br> (Default: `3.36` microns)|
| `FP_ASPECT_RATIO`  | The core's aspect ratio (height / width). <br> (Default: `1`)|
| `FP_PDN_VPITCH`  | The pitch of the vertical power stripes on the metal layer 4 in the power distribution network <br> (Default: `153.6`) |
| `FP_PDN_HPITCH`  | The pitch of the horizontal power stripes on the metal layer 5 in the power distribution network <br> (Default: `153.18`) |
| `PL_TARGET_DENSITY` | The desired placement density of cells. It reflects how spread the cells would be on the core area. 1 = closely dense. 0 = widely spread <br> (Default: `0.4`)|
| `GLB_RT_ADJUSTMENT` | Reduction in the routing capacity of the edges between the cells in the global routing graph. Values range from 0 to 1. <br> 1 = most reduction, 0 = least reduction  <br> (Default: `0.15`)|
| `PDK_VARIANT` | Specifies the process design kit (pdk) variant. <br> (Default: `efs8hd` )|
| `CELL_PAD` | Cell padding; increases the width of cells. <br> (Default: `2` microns -- 2 sites)|
| `ROUTING_STRATEGY` | Specifies the optimization mode to be used in TritonRoute. Values range from 0 to 3 <br> (Default: `0`) |



## Optional variables

These variables are optional that can be specified in the configuration parameters file.

### Synthesis

| Variable      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `LIB_SYNTH` | The library used for synthesis by yosys. <br> (Default: `./pdks/ef-skywater-s8/EFS8A/libs.ref/liberty/efs8hd/efs8hd_tt_1.80v_25C.lib`)|
| `SYNTH_DRIVING_CELL`  | The cell to drive the input ports. <br>(Default: `efs8hd_inv_8`)|
| `SYNTH_CAP_LOAD` | The capacitive load on the output ports in femtofarads. <br> (Default: `17.65` ff)|
| `SYNTH_BUFFERING` | Enables abc cell buffering <br> Enabled = 1, Disabled = 0 <br> (Default: `1`)|
| `SYNTH_SIZING` | Enables abc cell sizing (instead of buffering) <br> Enabled = 1, Disabled = 0 <br> (Default: `0`)|
| `SYNTH_READ_BLACKBOX_LIB` | A flag that enable reading the full(untrimmed) libretry file as a blackbox for synthesis. Please note that this is not used in technology mapping. This should only be used when trying to preserve gate instances in the rtl of the design.  <br> Enabled = 1, Disabled = 0 <br> (Default: `0`)|
| `SYNTH_NO_FLAT` | A flag that disables flattening the heirachry during synthesis, only flattening it after synthesis, mapping and optimizations. <br> Enabled = 1, Disabled = 0 <br> (Default: `0`)|
| `LIB_MIN` | Library used for min delay calculation during STA. <br> (Default:`./pdks/ef-skywater-s8/EFS8A/libs.ref/liberty/efs8hd/efs8hd_ss_1.60v_100C.lib`) |
| `LIB_MAX`  | Library used for max delay calculation during STA. <br> (Default:`./pdks/ef-skywater-s8/EFS8A/libs.ref/liberty/efs8hd/efs8hd_ff_1.95v_-40C.lib`) |
| `CLOCK_BUFFER_FANOUT` | Fanout of clock tree buffers. <br> (Default: `16`) |
| `SYNTH_TOP_LEVEL` | Treats everything as a blackbox. Runs no logical synthesis nor optimizations <br> (Default: `0`) |





### Floorplanning

| Variable      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `FP_IO_HMETAL`  | The metal layer on which to place the io pins horizontally (top and bottom of the die). <br>(Default: `3`)|
| `FP_IO_VMETAL`  | The metal layer on which to place the io pins vertically (sides of the die) <br> (Default: `2`)|
| `FP_SIZING`  | Specifies whether the floorplan size is absolute (exact dimensions) or relative (core utilization)<br> (Default: `relative`) |
| `FP_PDN_VOFFSET`  | The offset of the vertical power stripes on the metal layer 4 in the power distribution network <br> (Default: `16.32`) |
| `FP_PDN_HOFFSET`  | The offset of the horizontal power stripes on the metal layer 5 in the power distribution network <br> (Default: `16.65`) |
| `FP_TAPCELL_DIST`  | The horizontal distance between two tapcell columns <br> (Default: `25`) |
| `FP_IO_VLENGTH`  | The length of the vertical io pins on the die by the specified units <br> (Default:`4`) |
| `FP_IO_HLENGTH`  | The length of the horizontal io pins on the die by the specified units <br> (Default:`4`) |
| `FP_IO_VEXTEND`  |  Extends the vertical io pins outside of the die by the specified units<br> (Default: `-1` Disabled) |
| `FP_IO_HEXTEND`  |  Extends the horizontal io pins outside of the die by the specified units<br> (Default: `-1` Disabled) |
| `FP_IO_VTHICKNESS_MULT`  | A multiplier for vertical pin thickness. Base thickness is the pins layer minwidth <br> (Default: `1`) |
| `FP_IO_HTHICKNESS_MULT`  | A multiplier for horizontal pin thickness. Base thickness is the pins layer minwidth <br> (Default: `1`) |
| `BOTTOM_MARGIN_MULT`  | The length of the margin surrounding the core area in the bottom direction as a multiple of the site-height. <br> (Default:`4`) |
| `TOP_MARGIN_MULT`  | The length of the margin surrounding the core area in the top direction as a multiple of the site-height. <br> (Default: `4`) |
| `LEFT_MARGIN_MULT`  | The length of the margin surrounding the core area in the left direction as a multiple of the site-height. <br> (Default: `12`) |
| `RIGHT_MARGIN_MULT`  | The length of the margin surrounding the core area in the bottom direction as a multiple of the site-height. <br> (Default: `12`) |


### Placement

| Variable      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `PL_TIME_DIRVEN` | Specifies whether the placer should use time driven placement. 0 = false, 1 = true <br> (Default: `0`)|
| `PL_INITIAL_PLACEMENT` | Specifies whether to perform minimal placement. 0 = false, 1 = true. <br> (Default: `0`) |

### CTS

| Variable      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `CTS_TARGET_SKEW` | The target clock skew in picoseconds. <br> (Default: `20` ps)|
| `CTS_TOLERANCE` | an integer value that represents a tradeoff of QoR and runtime. Higher values will produce smaller runtime but worse QoR <br> (Default: `100`) |

### Routing

| Variable      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `GLB_RT_MINLAYER` | The number of lowest layer to be used in routing. <br> (Default: `1`)|
| `GLB_RT_MAXLAYER` | The number of highest layer to be used in routing. <br> (Default: `6`)|
| `GLB_RT_LI1_ADJUSTMENT` | Reduction in the routing capacity of the edges between the cells in the global routing graph but specific to li1 layer in ef-skywater-s8/EFS8A. Values range from 0 to 1 <br> (Default: `0`) |
| `GLB_RT_MET1_ADJUSTMENT` | Reduction in the routing capacity of the edges between the cells in the global routing graph but specific to met1 in ef-skywater-s8/EFS8A. Values range from 0 to 1 <br> (Default: `0`) |
| `GLB_RT_TILES` | Specifies the Gcell size <br> (Default: `15`) |
| `DIODE_PADDING` | Specifies the padding around the diode cells <br> (Default: `2`) |

### Magic
| Variable      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `MAGTYPE` | Specifies the source of the .mag view <br> (Default: `maglef`) |
| `MAGIC_PAD` |  A flag to pad the views generated by magic (.mag, .lef, .gds) with one site. 1 = Enabled, 0 = Disabled <br> (Default: `0` )|
| `MAGIC_ZEROIZE_ORIGIN` | A flag to move the layout such that it's origin in the lef generated by magic is 0,0. 1 = Enabled, 0 = Disabled  <br> (Default: `1` )|
| `MAGIC_GENERATE_GDS` | A flag to generate gds view via magic . 1 = Enabled, 0 = Disabled  <br> (Default: `1` )|
| `MAGIC_GENERATE_LEF` | A flag to generate lef view via magic . 1 = Enabled, 0 = Disabled  <br> (Default: `1` )|

### Flow Control
| Variable      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `RUN_ROUTING_DETAILED` | Enables detailed routing. 1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `RUN_MAGIC` | Enables running magic and GDSII streaming.1 = Enabled, 0 = Disabled <br> (Default: `0`)|
| `RUN_SIMPLE_CTS` | Enables inserting simple clock tree after synthesis .1 = Enabled, 0 = Disabled <br> (Default: `1`)|
| `CLOCK_TREE_SYNTH` | Enables cts.1 = Enabled, 0 = Disabled <br> (Default: `0`)|
| `FILL_INSERTION` | Enables fill cells insertion after cts (if enabled) .1 = Enabled, 0 = Disabled <br> (Default: `0`)|
| `DIODE_INSERTION_STRATEGY` | Specifies the insertion strategy of diodes to be used in the flow. 0 = No diode insertion, 1 = Spray diodes, 2 = insert fake diodes and replace them with real diodes if needed <br> (Default: `1`) |


### Checkers
| Variable      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `CHECK_UNMAPPED_CELLS` | Checks if there are unmapped cells after synthesis and aborts if any was found. 1 = Enabled, 0 = Disabled <br> (Default: `0`)|
| `CHECK_ASSIGN_STATEMENTS` | Checks for assign statement in the generated gate level netlist and aborts of any was found.1 = Enabled, 0 = Disabled <br> (Default: `0`)|
| `CHECK_LATCHES_IN_DESIGN` | Checks for any latches or failures in synthesis and aborts if any was found. 1 = Enabled, 0 = Disabled <br> (Default: `0`)|
| `CHECK_DIODE_PLACEMENT` | Checks if there was any failure in legalizing placement after inserting diodes and aborts if any was found.1 = Enabled, 0 = Disabled <br> (Default: `0`)|
