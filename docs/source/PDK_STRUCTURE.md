# Porting a PDK

This readme describes how to port a PDK to openlane.

## Folder structure
This is the expected folder structure for a PDK:

- <pdk_name>
	- libs.tech
		- openlane
			- config.tcl
			- common_pdn.tcl
			- `<standard cell library>`
				- config.tcl
				- tracks.info
				- no_synth.cells
				- drc_exclude.cells
	- libs.ref
		- lef
		- techLEF
		- lib

## Configuration files
- `config.tcl` PDK configuration file contains common information for all standard cell libraries under this PDK
- `common_pdn.tcl` Pdn configuration file. Refer to PDN configuration [section](#pdn-configuration-file).
- `<standard cell library>/config.tcl` standard cell library configuration file which contains information specific to that SCL. It can override PDK configuration file.
- `<standard cell library>/tracks.info` Contains information about the metal layers offsets and pitches. Refer to tracks configuration file [section](#tracks-info-file)
- `<standard cell library>/no_synth.cells` that should contain the list of newline-separated cell names to trim during synthesis (to not use them in synthesis). More in this [section](#no-synthesis-cells-file).


## PDK Variables

This section defines the neccessary variables for PDK configuration file

| Variable      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `DEF_UNITS_PER_MICRON` | Defines the unit distance microns. Used during floorplanning for proper def file generation. |
| `VDD_PIN` | Defines the power pin of the cells.  |
| `GND_PIN` | Defines the ground pin of the cells. |
| `TRACKS_INFO_FILE` | Points to the path of the tracks file. Used by the floorplanner to generate tracks |
| `TECH_LEF` | Points to the path of the tech lef. |
| `CELLS_LEF` | A list of paths to the cells lef views. Recommended to use wild card to catch all the files as follows: `[glob "$::env(PDK_ROOT)/sky130A/libs.ref/$::env(STD_CELL_LIBRARY)/lef/*.lef"]` |
| `GDS_FILES` | A list of paths to the cells GDS-II views. Recommended to use wild card to catch all the files as follows: `[glob "$::env(PDK_ROOT)/sky130A/libs.ref/$::env(STD_CELL_LIBRARY)/gds/*.gds"]` |
| `MAGIC_TECH_FILE` | Points to the magic tech file which mainly has drc rules. |
| `KLAYOUT_TECH` | Points to the klayout tech file (.lyt). |
| `KLAYOUT_PROPERTIES` | Points to the klayout properties file (.lyp). |
| `MAGIC_MAGICRC` | Points to the magicrc file that is sourced while running magic in the flow. |
| `GPIO_PADS_LEF` | A list of the pads lef views. For example:`[glob "$::env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_io/lef/sky130_fd_io.lef"]` |
| `NETGEN_SETUP_FILE` | Points to the setup file for netgen(lvs), that can exclude certain cells etc.. |
| `FP_TAPCELL_DIST` | The distance between tapcell columns. Used in floorplanning in tapcell insertion. |
| `GLB_RT_L1_ADJUSTMENT` | Reduction in the routing capacity of the edges between the cells in the global routing graph but specific to li1 layer in sky130A. Values range from 0 to 1 <br> (Default: `0`) |
| `CTS_SQR_CAP` | Defines the capacitance per square micron, used in CTS. |
| `CTS_SQR_RES` | Defines the resistance per square micron, used in CTS. |
| `DEFAULT_MAX_TRAN` | Defines the default maximum transition value, used in CTS & synthesis. |
| `FP_PDN_RAIL_OFFSET` | Defines the rail offset for met1 used in PDN. <br> Default: `0`. |
| `FP_PDN_VWIDTH` | Defines the strap width for the vertical layer used in PDN. <br> Default: `1.6`. |
| `FP_PDN_HWIDTH` | Defines the strap width for the horizontal layer used in PDN. <br> Default: `1.6`. |
| `FP_PDN_CORE_RING_VWIDTH` | Defines the vertical width for the vertical layer used to create the core ring in the PDN. <br> Default: `20`. |
| `FP_PDN_CORE_RING_HWIDTH` | Defines the horizontal width for the horizontal layer used to create the core ring in the PDN. <br> Default: `20`. |
| `FP_PDN_CORE_RING_VSPACING` | Defines the spacing for the vertical layer used to create the core ring in the PDN. <br> Default: `5`. |
| `FP_PDN_CORE_RING_HSPACING` | Defines the spacing for the horizontal layer used to create the core ring in the PDN. <br> Default: `5`. |
| `FP_PDN_CORE_RING_VOFFSET` | Defines the offset for the vertical layer used to create the core ring in the PDN. <br> Default: `20`. |
| `FP_PDN_CORE_RING_HOFFSET` | Defines the offset for the horizontal layer used to create the core ring in the PDN. <br> Default: `20`. |
| `WIRE_RC_LAYER` | The metal layer used in estimate parastics `set_wire_rc`. <br> Default: `met1`.|

## Standard cell library-specific variables

This section defines the necessary variables to configure a standard cell library for use with OpenLane:

| Variable      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `LIB_SYNTH` | Points to the lib file used during synthesis. |
| `LIB_SLOWEST` | Points to the lib file, corresponding to the slowest corner, for max delay calculation during STA. |
| `LIB_FASTEST` | Points to the lib file, corresponding to the fastest corner, for min delay calculation during STA. |
| `LIB_TYPICAL` | Points to the lib file for typical delay calculation during STA. |
| `NO_SYNTH_LIST` | Specifies the file that contains the don't-use-cell-list to be excluded from the liberty file during synthesis and timing optimizations. If it's not defined, this path is searched `$::env(PDK_ROOT)/$::env(PDK)/libs.tech/openlane/$::env(STD_CELL_LIBRARY)/no_synth.cells` and if it's not found, then the original liberty will be used as is. |
| `PLACE_SITE` | Defines the main site used by the cells. Used during floorplanning to generate the rows. |
| `PLACE_SITE_WIDTH` | Defines the main site width.Used during floorplanning to generate the rows. |
| `PLACE_SITE_HEIGHT` | Defines the main site height.Used during floorplanning to generate the rows. |
| `FP_WELLTAP_CELL` | Defines the tapcell to be used in tapcell insertion. <br> If this is not defiend then tapcell insertion will be skipped but the flow will resume normally |
| `FP_ENDCAP_CELL` | Defines the decapcell. Inserted during floorplanning at the sides of the design. |
| `SYNTH_DRIVING_CELL` | Defines the cell to drive the input ports. Used in synthesis |
| `SYNTH_DRIVING_CELL_PIN` | Defines the driving cell output pin. Used in synthesis |
| `SYNTH_CAP_LOAD` | Defines the capacitive load on the output ports in femtofarads. Used in synthesis |
| `SYNTH_MIN_BUF_PORT` | Defines the buffer, followed by its input port and output port to be used by `ins_buf` statements by yosys. It insert buffer cells into the design for directly connected wires. Example: `sky130_fd_sc_hd__buf_2 A X`  |
| `SYNTH_TIEHI_PORT` | Defines the tie high cell followed by the port that implements the tie high functionality. Used in synthesis. Example: `sky130_fd_sc_hd__conb_1 HI` |
| `SYNTH_TIELO_PORT` | Defines the tie low cell followed by the port that implements the tie high functionality. Used in synthesis. Example: `sky130_fd_sc_hd__conb_1 LO` |
| `CELL_CLK_PORT` | Defines the name of clk port of the flip flops and other cells. Used in CTS. |
| `PL_LIB` | Points to the lib view used in time driven placement.  |
| `FILL_CELL` | Defines the fill cell. Used in fill insertion. Can use a wild card to define a class of cells. Example `sky130_fd_sc_hd__fill_*` |
| `DECAP_CELL` | Defines the decap cell used for fill insertion. Can use a wild card to define a class of cells. Example `sky130_fd_sc_hd__fill_*` |
| `CELL_PAD` | Defines the number of sites to pad the cells lef views with. |
| `CELL_PAD_EXCLUDE` | Defines the cells to exclude from padding. |
| `CTS_ROOT_BUFFER` | Defines the cell inserted at the root of the clock tree. Used in CTS. |
| `CLK_BUFFER` | Defines the clock buffer cell. Used in CTS. |
| `CLK_BUFFER_INPUT` | Defines the clock buffer cell input port. Used in CTS. |
| `CLK_BUFFER_OUTPUT` | Defines the clock buffer cell output port. Used in CTS. |
| `CTS_CLK_BUFFER_LIST` | Defines the list of clock buffers to be used in CTS. |
| `CTS_MAX_CAP` | Defines the maximum capacitance, used in CTS. |
| `FP_PDN_RAIL_WIDTH` | Defines the rail width for met1 used in PDN. |
| `SYNTH_LATCH_MAP` | A pointer for the file contianing the latch mapping for yosys. |
| `TRISTATE_BUFFER_MAP` | A pointer for the file contianing the tri-state buffer mapping for yosys. |
| `NO_SYNTH_CELL_LIST` | Specifies the file that contains the don't-use-cell-list to be excluded from the liberty file during synthesis. If it's not defined, this path is searched `$::env(PDK_ROOT)/$::env(PDK)/libs.tech/openlane/$::env(STD_CELL_LIBRARY)/no_synth.cells` and if it's not found, then the original liberty will be used as is. |
| `DRC_EXCLUDE_CELL_LIST` | Specifies the file that contains the don't-use-cell-list to be excluded from the liberty file during synthesis and timing optimizations. If it's not defined, this path is searched `$::env(PDK_ROOT)/$::env(PDK)/libs.tech/openlane/$::env(STD_CELL_LIBRARY)/drc_exclude.cells` and if it's not found, then the original liberty will be used as is. In other words, `DRC_EXCLUDE_CELL_LIST` contain the only excluded cell list in timing optimizations. |

## Tracks Info File

The tracks files defines the metal layers pitches and offsets. This information should be extracted from the PDK's tech lef. The following is the format of the files

```
<layer name> X|Y <offset> <pitch>
```


## PDN Configuration File

A sample PDN configuration file exists [here](https://github.com/RTimothyEdwards/open_pdks/blob/master/sky130/openlane/common_pdn.tcl).

More on the structure of the file [here](https://github.com/The-OpenROAD-Project/OpenROAD/blob/master/src/pdngen/doc/PDN.md)

## No Synthesis Cells File

There are some cell types that you don't want to use in synthesis like, for example, delay cells and clock buffers (since CTS is a separate step that would insert the clock buffers).

Also, other cells don't have a default mapping in yosys, so they were excluded to reduce the liberty file size until we add a tech mapping file for each.

The smallest sizes of the cells were also removed to prevent the synthesizer from using them, which allows for a larger floorplan. These cells however are accessible by the optimizer which will in turn replace the bigger cells with these smaller sizes when needed. Eventually, this process will produce clean routing without forcing the users of OpenLane to re-configure their designs with smaller `FP_CORE_UTIL` and `PL_TARGET_DENSITY` values. Nonetheless, this change will come some time in the future.

However, this list is likely over-constraining, and if you have done experiments allowing smaller sizes incrementally and still got clean routed layouts, please let us know your findings, or better yet, submit a pull request at [open_pdks](https://github.com/RTimothyEdwards/open_pdks) with a suggested no_synth list.


This list is only used during synthesis.

You can also point your custom no_synth.cells by setting the value for `NO_SYNTH_CELL_LIST` to point to it.


## DRC Exclude Cells File

Some of the cells, back when this list was created, had hard-to-access pin shapes, so the detailed router didn't manage to do routing cleanly.

Others had DRC violations within the cell definitions.

We excluded all cells of size _0 for the same reasons explained in the previous section.

The lpflow cells were also excluded because the flow is still unable to deal with them and connect a KAPWR supply.

This list is used for both synthesis and timing optimizations.

You can also point your custom no_synth.cells by setting the value for `DRC_EXCLUDE_CELL_LIST` to point to it.
