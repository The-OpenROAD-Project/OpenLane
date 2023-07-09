# Report Data Definitions
***NOTE:** The value `-1`, if not meaningful, indicates that the report/log from which the information is extracted wasn't found (the stage responsible for it was skipped or failed).

## Default Printed Information Variables

| Variable      | Description                                           |
|---------------|-------------------------------------------------------|
| `design`   | The directory of the design        |
| `design_name`   | The name of the top level module of the design        |
| `config`   | The name of the configurations file of the design        |
| `flow_status`   | The status of the flow at the end of the run. Extracted from total_runtime.txt       |
| `total_runtime`   | The total runtime of running the process on the design. Extracted from total_runtime.txt       |
| `routed_runtime`   | The runtime of running the process up to (including) detailed routing on the design. Extracted from routed_runtime.txt       |
| `DIEAREA_mm^2`   | The diearea in mm<sup>2</sup> as reported from the def file.        |
| `CellPer_mm^2`   | The number of cells in the design as reported by yosys divided by the diearea in mm<sup>2</sup>.      |
| `(Cell/mm^2)/Core_Util`   | The number of cells in the design as reported by yosys divided by the diearea in mm<sup>2</sup>, all divided by the FP_CORE_UTIL configuration parameter.     |
| `OpenDP_Util`   | The core utilization of the design. Extracted from openDP logs.        |
| `Peak_Memory_Usage_MB`   | The peak memory usage of Tritonroute during optimization iterations. Extracted from tritonRoute logs.        |
| `cell_count`   | The number of cells in the design. Extracted from yosys logs.        |
| `tritonRoute_Violations`   | The total number of violations from running TritonRoute. Extracted from tritonRoute logs.        |
| `Short_Violations`   | The total number of shorts violations from running TritonRoute. Extracted from tritonRoute drc.        |
| `MetSpc_violations`   | The total number of MetSpc violations from running TritonRoute. Extracted from tritonRoute drc.        |
| `OffGrid_violations`   | The total number of off-grid violations from running TritonRoute. Extracted from tritonRoute drc.        |
| `MinHole_violations`   | The total number of MinHole violations from running TritonRoute. Extracted from tritonRoute drc.        |
| `Other_violations`   | The total number of other types of violations from running TritonRoute. Extracted from tritonRoute drc.        |
| `Magic_violations`   | The total number of magic drc violations in the design. Extracted from Magic drc.        |
| `antenna_violations`   | The total number of antenna violations in the design. Extracted from Magic antenna check or OpenROAD ARC.        |
| `lvs_total_errors`   | The total number of mismatches and differences between the final layout and the netlist of the design. Extracted from Netgen LVS report.        |
| `cvc_total_errors`   | The total number of electric errors detected by CVC. Extracted from CVC report.        |
| `klayout_violations`   | The total number of klayout drc violations in the design. Extracted from klayout drc report ran on the magic generated GDSII.        |
| `wire_length`   | The total wire length in the design. Extracted from tritonRoute logs.        |
| `vias`   | The number of vias in the final design. Extracted from tritonRoute logs.        |
| `wns`   | Worst Negative Slack. Reported after Synthesis. Extracted from OpenSTA.        |
| `pl_wns`   | Worst Negative Slack. Reported after global placement and before optimizations using estimate parasitics. Extracted from RePlAce/OpenSTA. If the report wasn't found, the value from the previous STA report is used.       |
| `opt_wns`   | Worst Negative Slack. Extracted from OpenSTA. If the report wasn't found, the value from the previous STA report is used.        |
| `fastroute_tns`   | Worst Negative Slack. Reported after global routing using estimate parasitics. Extracted from FastRoute/OpenSTA. If the report wasn't found, the value from the previous STA report is used.        |
| `spef_wns`   | Worst Negative Slack. Reported after routing and spef extraction. Extracted from OpenSTA. If the report wasn't found, the value from the previous STA report is used.        |
| `tns`   | Total Negative Slack. Reported after Synthesis. Extracted from OpenSTA.        |
| `pl_tns`   | Total Negative Slack. Reported after global placement and before optimizations using estimate parasitics. Extracted from RePlAce/OpenSTA. If the report wasn't found, the value from the previous STA report is used.       |
| `opt_tns`   | Total Negative Slack. Reported after OpenPhySyn optimizations. Extracted from OpenSTA. If the report wasn't found, the value from the previous STA report is used.       |
| `fastroute_tns`   | Total Negative Slack. Reported after global routing using estimate parasitics. Extracted from FastRoute/OpenSTA. If the report wasn't found, the value from the previous STA report is used.       |
| `spef_tns`   | Total Negative Slack. Reported after routing and spef extraction. Extracted from OpenSTA. If the report wasn't found, the value from the previous STA report is used.        |
| `HPWL`   | Final value for the half-perimeter wire length. Extracted from RePlace logs.       |
| `routing_layer1_pct` | The percentage usage of routing resources on layer 1 in global routing. Extracted from fastroute log. |
| `routing_layer2_pct` | The percentage usage of routing resources on layer 2 in global routing. Extracted from fastroute log. |
| `routing_layer3_pct` | The percentage usage of routing resources on layer 3 in global routing. Extracted from fastroute log. |
| `routing_layer4_pct` | The percentage usage of routing resources on layer 4 in global routing. Extracted from fastroute log. |
| `routing_layer5_pct` | The percentage usage of routing resources on layer 5 in global routing. Extracted from fastroute log. |
| `routing_layer6_pct` | The percentage usage of routing resources on layer 6 in global routing. Extracted from fastroute log. |
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
| `Diodes`   | The number of diodes in the final design. Extracted from diode logs or Fastroute log based on the used diode insertion strategy.        |
| `Total_Physical_Cells`   | The sum of endcaps, tapcells, and diodes in the final design.        |
| `suggested_clock_frequency`   | The suggested clock frequency to be used with the design. Calculated based on the value of `spef_wns`, and reported in `MHz`.       |
| `suggested_clock_period`   | The suggested clock period to be used with the design. Calculated based on the value of `spef_wns`, and reported in `ns`.        |
| `CoreArea_um^2`   | The area of the core, in μm<sup>2</sup>. Extracted from the initial floorplan. |
| `power_slowest_internal_uW`   | Total internal (within cell) power use at the slowest corner, in uW. Extracted from the post-parasitics multi-corner power usage report. |
| `power_slowest_switching_uW`   | Total switching power use at the slowest corner, in uW. Extracted from the post-parasitics multi-corner power usage report. |
| `power_slowest_leakage_uW`   | Total leakage power use at the slowest corner, in uW. Extracted from the post-parasitics multi-corner power usage report. |
| `power_typical_internal_uW`   | Total internal (within cell) power use at the typical corner, in uW. Extracted from the post-parasitics multi-corner power usage report. |
| `power_typical_switching_uW`   | Total switching power use at the typical corner, in uW. Extracted from the post-parasitics multi-corner power usage report. |
| `power_typical_leakage_uW`   | Total leakage power use at the typical corner, in uW. Extracted from the post-parasitics multi-corner power usage report. |
| `power_fastest_internal_uW`   | Total internal (within cell) power use at the fastest corner, in uW. Extracted from the post-parasitics multi-corner power usage report. |
| `power_fastest_switching_uW`   | Total switching power use at the fastest corner, in uW. Extracted from the post-parasitics multi-corner power usage report. |
| `power_fastest_leakage_uW`   | Total leakage power use at the fastest corner, in uW. Extracted from the post-parasitics multi-corner power usage report. |
| `critical_path_ns`   | Delay of the longest path, in ns, reported by multi-corner post-parasitics STA. |

## Default Printed Configuration Variables

| Variable      | Description                                           |
|---------------|-------------------------------------------------------|
| `CLOCK_PERIOD`  | The clock period for the design in ns       |
| `SYNTH_STRATEGY` | Strategies for abc logic synthesis and technology mapping <br> Possible values are "DELAY|AREA 0-3|0-2"; the first part refers to the optimization target of the synthesis strategy (area vs. delay) and the second one is an index. <br> (Default: `AREA 0`)|
| `MAX_FANOUT_CONSTRAINT`  | The max load that the output ports can drive. <br> (Default: `10` cells) |
| `FP_CORE_UTIL`  | The core utilization percentage. <br> (Default: `50` percent)|
| `FP_ASPECT_RATIO`  | The core's aspect ratio (height / width). <br> (Default: `1`)|
| `FP_PDN_VPITCH`  | The pitch of the vertical power stripes on the metal layer 4 in the power distribution network <br> (Default: `153.6`) |
| `FP_PDN_HPITCH`  | The pitch of the horizontal power stripes on the metal layer 5 in the power distribution network <br> (Default: `153.18`) |
| `PL_TARGET_DENSITY` | The desired placement density of cells. It reflects how spread the cells would be on the core area. 1 = closely dense. 0 = widely spread <br> (Default: `($::env(FP_CORE_UTIL) + 10 + (5 * $::env(GPL_CELL_PADDING)) ) / 100.0`) |
| `GRT_ADJUSTMENT` | Reduction in the routing capacity of the edges between the cells in the global routing graph. Values range from 0 to 1. <br> 1 = most reduction, 0 = least reduction  <br> (Default: `0.2`)|
| `STD_CELL_LIBRARY` | Specifies the standard cell library used. <br> (Default: `sky130_fd_sc_hd`) |

## Optional variables

These variables are optional that can be specified in the configuration parameters file. Please refere to this [file](./configuration.md) for the full list of configurations.
