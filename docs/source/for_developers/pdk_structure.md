# Porting a PDK
This readme describes how to structure a PDK for use with OpenLane.

In general, a PDK is expected to define all variables not marked optional in
the [PDK configuration variable list](../reference/pdk_configuration.md).

## Folder structure
This is the expected folder structure for a PDK:

- <pdk_name>
	- libs.tech
		- openlane
			- config.tcl
			- `<standard cell library>`
				- config.tcl
				- tracks.info
				- no_synth.cells
				- drc_exclude.cells
	- libs.ref
		- lef
		- techlef
		- lib
		- ...

## Configuration Files
- `config.tcl`: the PDK configuration file contains common information for all standard cell libraries under this PDK.
- `<standard cell library>/config.tcl`: Standard cell library configuration file which contains information specific to that SCL. Variables in this file may override the general PDK variables.
- `<standard cell library>/tracks.info`: Contains information about the metal layers offsets and pitches. Refer to tracks configuration file [section](../reference/pdk_configuration.md#tracks-info-file).
- `<standard cell library>/drc_exclude.cells` that should contain the list of newline-separated cell names to exclude during synthesis and PnR. More in this [section](../reference/pdk_configuration.md#drc-exclude-cells-file).
- `<standard cell library>/no_synth.cells` that should contain the list of newline-separated cell names to exclude during synthesis. More in this [section](../reference/pdk_configuration.md#no-synthesis-cells-file).
