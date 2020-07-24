# Porting a pdk

This readme describes how to port a pdk to openlane.

## Folder structure
This is the expected folder structure for a pdk:

- <pdk_name>
	- libs.tech
		- openlane
			- config.tcl
			- common_pdn.tcl
			- <variant_name>
				- config.tcl
				- tracks.info
				- no_synth.cells
	- libs.ref
		- lef
		- techLEF
		- lib

## Configuration files
- `config.tcl` Pdk configuration file contains common information for all the variants
- `common_pdn.tcl` Pdn configuration file. Refer to pdn configuration [section](#pdn-configuration-file).
- `<variant_name>/config.tcl` Variant configuration file which contains information specific to that variant It can overwrite pdk configuration file.
- `<variant_name>/tracks.info` Conatins information about the metal layers offesets and pitches. Refer to tracks configuration file [section](#tracks-info-file)
- `<variant_name>/no_synth.cells` that should contain the list of endline-separated cell names to trim during synthesis (to not use them in synthesis)


## Pdk Variables 

This section defines the neccessary variables for pdk configuration file

| Variable      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `DEF_UNITS_PER_MICRON` | Defines the unit distance microns. Used during floorplanning for proper def file generation. |
| `PLACE_SITE` | Defines the main site used by the cells. Used during floorplanning to generate the rows. |
| `PLACE_SITE_WIDTH` | Defines the main site width.Used during floorplanning to generate the rows. |
| `PLACE_SITE_HEIGHT` | Defines the main site height.Used during floorplanning to generate the rows. |
| `VDD_PIN` | Defines the power pin of the cells.  |
| `GND_PIN` | Defines the ground pin of the cells. |
| `TRACKS_INFO_FILE` | Points to the path of the tracks file. Used by the floorplanner to generate tracks |
| `TECH_LEF` | Points to the path of the techlef. |
| `CELLS_LEF` | A list of paths to the cells lef views. Recommended to use wild card to catch all the files as follows: `[glob "$::env(PDK_ROOT)/sky130A/libs.ref/$::env(PDK_VARIANT)/lef/*.lef"]` |
| `MAGIC_TECH_FILE` | Points to the magic tech file which mainly has drc rules. |
| `MAGIC_MAGICRC` | Points to the magicrc file that is sourced while running magic in the flow. |
| `GPIO_PADS_LEF` | A list of the pads lef views. For example:`[glob "$::env(PDK_ROOT)/sky130A/libs.ref/sky130_fd_io/lef/sky130_fd_io.lef"]` |
| `NETGEN_SETUP_FILE` | Points to the setup file for netgen(lvs), that can exclude certain cells etc.. |
| `FP_TAPCELL_DIST` | The distance between tapcell columns. Used in floorplanning in tapcell insertion. |

## Pdk variant variables

This section defines the neccessary variables for pdk variant configuration file

| Variable      | Description                                                   |
|---------------|---------------------------------------------------------------|
| `LIB_SYNTH` | Points to the lib file used during synthesis. |
| `LIB_MAX` | Points to the lib file for max delay calculation during STA. |
| `LIB_MIN` | Points to the lib file for min delay calculation during STA. |
| `LIB_TYPICAL` | Points to the lib file for typical delay calculation during STA. |
| `FP_WELLTAP_CELL` | Defines the tapcell to be used in tapcell insertion. <br> If this is not defiend then tapcell insertion will be skipped but the flow will resume normally |
| `FP_ENDCAP_CELL` | Defines the decapcell. Inserted during floorplanning at the sides of the design. |
| `SYNTH_DRIVING_CELL` | Defines the cell to drive the input ports. Used in synthesis |
| `SYNTH_DRIVING_CELL_PIN` | Defines the driving cell output pin. Used in synthesis |
| `SYNTH_CAP_LOAD` | Defines the capacitive load on the output ports in femtofarads. Used in synthesis |
| `SYNTH_MIN_BUF_PORT` | Defines the buffer, followed by its input port and output port to be used by `ins_buf` statmement by yosys. It insert buffer cells into the design for directly connected wires. Example: `sky130_fd_sc_hd__buf_2 A X`  |
| `SYNTH_TIEHI_PORT` | Defines the tie high cell followed by the port that implements the tie high functionality. Usined in synthesis. Example: `sky130_fd_sc_hd__conb_1 HI` |
| `SYNTH_TIELO_PORT` | Defines the tie low cell followed by the port that implements the tie high functionality. Usined in synthesis. Example: `sky130_fd_sc_hd__conb_1 LO` |
| `CELL_CLK_PORT` | Defines the name of clk port of the flip flops and other cells. Used in CTS. |
| `PL_LIB` | Points to the lib view used in time driven placment.  |
| `FILL_CELL` | Defines the fill cell. Used in fill insertion. Can use a wild card to define a class of cells. Example `sky130_fd_sc_hd__fill_*` |
| `DECAP_CELL` | Defines the decap cell used for fill insertion. Can use a wild card to define a class of cells. Example `sky130_fd_sc_hd__fill_*` |
| `CELL_PAD` | Defines the number of sites to pad the cells lef views with. |
| `CELL_PAD_EXECLUDE` | Defines the cells to execlude from pading. |
| `CTS_ROOT_BUFFER` | Defines the cell inserted at the root of the clock tree. Used in CTS. |
| `CLK_BUFFER` | Defines the clock buffer cell. Used in CTS. |
| `CLK_BUFFER_INPUT` | Defines the clock buffer cell input port. Used in CTS. |
| `CLK_BUFFER_OUTPUT` | Defines the clock buffer cell output port. Used in CTS. |
| `CTS_SQR_CAP` | Defines the squared capacitance for the pdk variant. Used in CTS. |
| `CTS_SQR_RES` | Defines the squared resistance for the pdk variant. Used in CTS. |
| `CTS_MAX_CAP` | Defines the maximum capacitance for the pdk variant. Used in CTS. |

## Tracks info file

The tracks files defines the metal layers pitches and offests. This information should be extracted from the pdk's tech lef. The following is the format of the files

```
<layer name> X|Y <offset> <pitch>
```



## pdn configuration file

A sample pdn configuration file exists [here](https://github.com/RTimothyEdwards/open_pdks/blob/master/sky130/openlane/common_pdn.tcl).

## Additional self notes

- Core margin should be pdk specific at least, as it is related to the routing grid
- io layers should be pdk specific, they are related to the metal stack of a pdk

