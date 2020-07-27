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
| `ROUTING_STRATEGY` | Specifies the optimization mode to be used in TritonRoute. Values range from 0 to 3. If set to 14 TritonRoute14 will be used. <br> (Default: `0`) |



## Optional variables

These variables are optional that can be specified in the configuration parameters file. Please refere to this [file](../configuration/README.md) for the full list of configurations.