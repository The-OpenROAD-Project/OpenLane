# PDK Configuration Variables

These variables are defined by PDK configuration files to support the OpenLane
flow and its steps.

All these variables (unless marked optional) are defined by the PDK, but some may
also be overriden by a user configuration.

```{note}
Any examples provided are for the `sky130A` PDK.
```

## User-Modifiable

These values may be modified by the user configuration and the
included values should be considered "defaults."

| Variable      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `FP_PDN_RAIL_OFFSET` | Defines the rail offset for met1 used in PDN. <br> (Example: `0`) |
| `FP_PDN_HSPACING`  | The spacing between horizontal power/ground pair <br> (Default: `1.7`) |
| `FP_PDN_VSPACING`  | The spacing between vertical power/ground pair <br> (Default: `1.7`) |
| `FP_PDN_VOFFSET`  | The offset of the vertical power stripes on the metal layer 5 in the power distribution network <br> (Default: `16.32`) |
| `FP_PDN_VPITCH`  | The pitch of the vertical power stripes on the metal layer 4 in the power distribution network <br> (Default: `153.6`) |
| `FP_PDN_HOFFSET`  | The offset of the horizontal power stripes on the metal layer 5 in the power distribution network <br> (Default: `16.65`) |
| `FP_PDN_HPITCH`  | The pitch of the horizontal power stripes on the metal layer 5 in the power distribution network <br> (Default: `153.18`) |
| `FP_PDN_VWIDTH` | Defines the strap width for the vertical layer used in PDN. <br> (Example: `1.6`) |
| `FP_PDN_HWIDTH` | Defines the strap width for the horizontal layer used in PDN. <br> (Example: `1.6`) |
| `FP_PDN_CORE_RING_VWIDTH` | Defines the vertical width for the vertical layer used to create the core ring in the PDN. <br> (Example: `20`) |
| `FP_PDN_CORE_RING_HWIDTH` | Defines the horizontal width for the horizontal layer used to create the core ring in the PDN. <br> (Example: `20`) |
| `FP_PDN_CORE_RING_VSPACING` | Defines the spacing for the vertical layer used to create the core ring in the PDN. <br> (Example: `5`) |
| `FP_PDN_CORE_RING_HSPACING` | Defines the spacing for the horizontal layer used to create the core ring in the PDN. <br> (Example: `5`) |
| `FP_PDN_CORE_RING_VOFFSET` | Defines the offset for the vertical layer used to create the core ring in the PDN. <br> (Example: `20`) |
| `FP_PDN_CORE_RING_HOFFSET` | Defines the offset for the horizontal layer used to create the core ring in the PDN. <br> (Example: `20`) |
| `GRT_LAYER_ADJUSTMENTS` | Layer-specific reductions in the routing capacity of the edges between the cells in the global routing graph, delimited by commas. Values range from 0 to 1. <br> (Example: `0.99,0,0,0,0,0`) |
| `RT_MIN_LAYER`  | The lowest metal layer to route on. <br>(Example: `met1`) |
| `RT_MAX_LAYER`  | The highest metal layer to route on. <br> (Example: `met5`) |
| `WIRE_LENGTH_THRESHOLD` | A value in microns above which wire lengths generate warnings, and, if `QUIT_ON_LONG_WIRE` is set, the flow will error out. If a PDK does not set this value, the value is considered to be infinite. (Optional) |

## PDK-Static

These variables should really not be modified unless you absolutely know what
you're doing.

| Variable      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `DEF_UNITS_PER_MICRON` | Defines the unit distance microns. Used during floorplanning for proper def file generation. |
| `VDD_PIN` | Defines the power pin of the cells.  |
| `GND_PIN` | Defines the ground pin of the cells. |
| `TRACKS_INFO_FILE` | Points to the path of the tracks file. Used by the floorplanner to generate tracks |
| `TECH_LEF_MIN` | Points to the path of the tech lef used for minimum corner extraction. (Optional) |
| `TECH_LEF` | Points to the path of the tech lef used for nominal corner extraction. |
| `TECH_LEF_MAX` | Points to the path of the tech lef used for maximum corner extraction. (Optional) |
| `CELLS_LEF` | A list of paths to the cells lef views. Recommended to use wild card to catch all the files as follows: `[glob "$::env(PDK_ROOT)/sky130A/libs.ref/$::env(STD_CELL_LIBRARY)/lef/*.lef"]` |
| `GDS_FILES` | A list of paths to the cells GDSII views. Recommended to use wild card to catch all the files as follows: `[glob "$::env(PDK_ROOT)/sky130A/libs.ref/$::env(STD_CELL_LIBRARY)/gds/*.gds"]` |
| `MAGIC_TECH_FILE` | Points to the magic tech file which mainly has drc rules. |
| `KLAYOUT_TECH` | Points to the klayout tech file (.lyt). |
| `KLAYOUT_PROPERTIES` | Points to the klayout properties file (.lyp). |
| `KLAYOUT_DEF_LAYER_MAP` | Points to klayout deflef layer map file (.map). |
| `KLAYOUT_XOR_IGNORE_LAYERS` | A space separated layers list to ignore during klayout xor check. |
| `MAGIC_MAGICRC` | Points to the magicrc file that is sourced while running magic in the flow. |
| `GPIO_PADS_LEF` | A list of the pads lef views. For example:`[glob "$::env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_io/lef/sky130_fd_io.lef"]` |
| `GPIO_PADS_PREFIX` | A list of pad cells name prefixes. |
| `NETGEN_SETUP_FILE` | Points to the setup file for netgen(lvs), that can exclude certain cells etc.. |
| `FP_TAPCELL_DIST` | The distance between tapcell columns. Used in floorplanning in tapcell insertion. |
| `DATA_WIRE_RC_LAYER` | The metal layer used in estimate parastics `set_wire_rc`. <br> (Example: `met2`) |
| `CLOCK_WIRE_RC_LAYER` | The metal layer used in estimate parastics `set_wire_rc`. <br> (Example: `met5`) |
| `FP_IO_HLAYER`  | The metal layer on which to place the io pins horizontally (top and bottom of the die). <br>(Example: `met3`)|
| `FP_IO_VLAYER`  | The metal layer on which to place the io pins vertically (sides of the die) <br> (Example: `met2`)|
| `FP_TAPCELL_DIST`  | The horizontal distance between two tapcell columns <br> (Default: `14`) |
| `RCX_RULES_MIN` | OpenRCX rules at the minimum corner. (Optional) |
| `RCX_RULES` | OpenRCX rules at the nominal corner. |
| `RCX_RULES_MAX` | OpenRCX rules at the maximum corner. (Optional) |
| `WIRE_RC_LAYER` | **Deprecated: Use `DATA_WIRE_RC_LAYER` and `CLOCK_WIRE_RC_LAYER`** The metal layer used in estimate parastics `set_wire_rc`. |

## SCL-specific variables

This section defines the necessary variables to configure a standard cell library for use with OpenLane.

### User-modifiable

These values may be modified by the user configuration and the
included values should be considered "defaults."

| Variable      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `MAX_TRANSITION_CONSTRAINT` | Defines the maximum slew (transition) value in ns. |
| `MAX_FANOUT_CONSTRAINT` | Defines the maximum fanout for a single output in the design. |
| `OUTPUT_CAP_LOAD` | Defines the capacitive load on the output ports in fF. |
| `CTS_MAX_CAP` | Defines the maximum capacitance for clock tree synthesis in the design in pF. |
| `GPL_CELL_PADDING` | Cell padding value (in sites) for global placement. <br> (Example: `2`) |
| `DPL_CELL_PADDING` | Defines the number of sites to pad the cells with during detailed placement. This value should not be higher than `GPL_CELL_PADDING` unless you know what you're doing. <br> (Example: `2`) |
| `CELL_PAD_EXCLUDE` | Defines the cells to exclude from padding for both detailed placement. |
| `NO_SYNTH_CELL_LIST` | Specifies the file that contains the don't-use-cell-list to be excluded from the liberty file during synthesis. See [this section](#no-synthesis-cells-file) for more information. |
| `DRC_EXCLUDE_CELL_LIST` | Specifies the file that contains the don't-use-cell-list to be excluded from the liberty file during synthesis and timing optimizations. See [this section](#drc-exclude-cells-file) for more information. |
| `FP_PDN_HORIZONTAL_LAYER` | Defines the upper layer used in PDN. |
| `FP_PDN_VERTICAL_LAYER` | Defines the lower layer used in PDN. |
| `FP_PDN_RAIL_LAYER` | Defines the rail layer used in PDN. |
| `FP_PDN_RAIL_WIDTH` | Defines the rail width for the rail layer used in PDN. |
| `SYNTH_LATCH_MAP` | A pointer for the file containing the latch mapping for yosys. (Optional) |
| `TRISTATE_BUFFER_MAP` | A pointer for the file containing the tri-state buffer mapping for yosys. (Optional) |
| `CARRY_SELECT_ADDER_MAP` | A pointer for the file containing the carry-select adder mapping for Yosys. (Optional) |
| `RIPPLE_CARRY_ADDER_MAP` | A pointer for the file containing the ripple-carry adder mapping for Yosys. (Optional) |
| `FULL_ADDER_MAP` | A pointer for the file containing the full adder mapping for Yosys. (Optional) |
| `SYNTH_CAP_LOAD` | **Deprecated: Use `OUTPUT_CAP_LOAD`**: Defines the capacitive load on the output ports in fF. |
| `DEFAULT_MAX_TRAN` | **Removed: Use `MAX_TRANSITION_CONSTRAINT`**: Defines the maximum slew (transition) value in ns. |


### SCL-static

These variables should really not be modified unless you absolutely know what
you're doing.

| Variable      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `LIB_SYNTH` | Points to the lib file used during synthesis. |
| `LIB_SLOWEST` | Points to the lib file, corresponding to the slowest corner, for max delay calculation during STA. |
| `LIB_FASTEST` | Points to the lib file, corresponding to the fastest corner, for min delay calculation during STA. |
| `LIB_TYPICAL` | Points to the lib file for typical delay calculation during STA. |
| `DFF_LIB_SYNTH` | Points to the lib file for used for dff mapping. If not specified, `LIB_SYNTH` is used. (Optional) |
| `PLACE_SITE` | Defines the main site used by the cells. Used during floorplanning to generate the rows. |
| `PLACE_SITE_WIDTH` | Defines the main site width. Used during floorplanning to generate the rows. |
| `PLACE_SITE_HEIGHT` | Defines the main site height. Used during floorplanning to generate the rows. |
| `FP_WELLTAP_CELL` | Defines the tapcell to be used in tapcell insertion. <br> If this is not defined then tapcell insertion will be skipped but the flow will resume normally |
| `FP_ENDCAP_CELL` | Defines the decapcell. Inserted during floorplanning at the sides of the design. |
| `SYNTH_DRIVING_CELL`  | The cell to drive the input ports, used in synthesis and static timing analysis. <br>(Example: `sky130_fd_sc_hd__inv_1`)|
| `SYNTH_DRIVING_CELL_PIN`  | The name of the `SYNTH_DRIVING_CELL`'s output pin. <br>(Default: `Y`)|
| `SYNTH_CLK_DRIVING_CELL`  | An alternative cell with which to drive clock inputs. Can be left empty, where the SDC script will use `SYNTH_DRIVING_CELL` for clock inputs as well. |
| `SYNTH_CLK_DRIVING_CELL_PIN`  | The name of the SYNTH_CLK_DRIVING_CELL output pin. Can be left empty, where the SDC script will use `SYNTH_DRIVING_CELL_PIN`. |
| `SYNTH_MIN_BUF_PORT` | Defines the buffer, followed by its input port and output port to be used by `ins_buf` statements by yosys. It inserts buffer cells into the design for directly connected wires. <br> (Example: `sky130_fd_sc_hd__buf_2 A X`  )|
| `SYNTH_TIEHI_PORT` | Defines the tie high cell followed by the port that implements the tie high functionality. Used in synthesis. <br> (Example: `sky130_fd_sc_hd__conb_1 HI`)|
| `SYNTH_TIELO_PORT` | Defines the tie low cell followed by the port that implements the tie high functionality. Used in synthesis. <br> (Example: `sky130_fd_sc_hd__conb_1 LO`)|
| `TRISTATE_CELL_PREFIX` | Prefix of tristate cells. Used with SYNTH_CHECKS_ALLOW_TRISTATE. <br> Example `sky130_fd_sc_hd__ebuf` |
| `FILL_CELL` | Defines the fill cell. Used in fill insertion. Can use a wild card to define a class of cells. Example `sky130_fd_sc_hd__fill_*` |
| `DECAP_CELL` | Defines the decap cell used for fill insertion. Can use a wild card to define a class of cells. Example `sky130_fd_sc_hd__fill_*` |
| `DIODE_CELL_PIN` | Defines the `DIODE_CELL` pin. This is required if `DIODE_CELL` is defined |
| `DIODE_CELL` | Defines the diode cell to be used during antenna violations fix step. <br> If this is not defined then the no antenna violations fixes will be attempted |
| `CTS_ROOT_BUFFER` | Defines the cell inserted at the root of the clock tree. Used in CTS. |
| `CTS_CLK_BUFFER_LIST` | Defines the list of clock buffers to be used in CTS. |
| `STD_CELL_POWER_PINS` | Defines power pins of stdcells. Used in PDN. |
| `STD_CELL_GROUND_PINS` | Defines ground pins of stdcells. Used in PDN. |
| `CVC_SCRIPTS_DIR` | A directory of Circuit Validity Checker (CVC) scripts for the relevant PDK. Must contain the following set of files: `cvcrc`, an initialization file, `cdl.awk`, an awk script to remove black box definitions from SPICE files, `models`, cell models, and finally `power.awk`, an awk script that adds power information to the verilog netlists. |
| `STD_CELL_LIBRARY_CDL` | A pointer for the cdl view of the SCL. |
| `LAYERS_RC` | A comma separated list specifying capacitance and resistance per layer. Variable should be provided in the following format. `<layer_name> <capacitance> <resistance>, <layer_name> ...` ([warning](../configuration.md#on-comma-delimited-variables)) (Optional) |
| `VIAS_RC` | A comma separated list specifying capacitance -only- of vias. Variable should be provided in the following format. `<layer_name> <capacitance> , <layer_name> ...` ([warning](../configuration.md#on-comma-delimited-variables)) (Optional) |

## Tracks Info File

The tracks files defines the metal layers pitches and offsets. This information
should be extracted from the PDK's tech lef. The file should be an EOL-delimited
set of lines formatted as follows:

```
<layer name> X|Y <offset> <pitch>
```

## DRC Exclude Cells File

Some cells may be excluded from PnR entirely- due to hard-to-access pin shapes
and/or the cells simply being invalid (DRC violations.)

```{note}
For sky130, the "lpflow" cells were also excluded because the flow is unable
to handle them properly and create a keep-alive power (KAPWR) supply.
```

The file is formatted as an EOL-delimited list of cell names (wildcards and
the like not supported.)

## No Synthesis Cells File

Some cells may be furtherexcluded from synthesis, for reasons including but not
limited to the following:

* Excluded from PnR, i.e., part of the DRC Exclude Cells.
* Clock Buffers: They are balanced and may introduce too much of a delay when
  not used for clock trees as part of CTS.
* Cells without default mapping: Cannot be used by Yosys.
* Smaller cell sizes: Prevents under-estimating the required floorplan.
  The resizer may later choose to use them.

The file is formatted as an EOL-delimited list of cell names (wildcards and
the like not supported.)

All cells excluded from PnR are also excluded from Synthesis.
