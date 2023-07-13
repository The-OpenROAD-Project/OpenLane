# Hardening Macros
Using OpenLane, you can produce a GDSII from an RTL for macros, and then use these macros to create your chip. Check [this][4] for more details about chip integration.

In this document we will go through the hardening steps and discuss in some detail what considerations should be made when hardening your macro.

> **NOTE:** For all the configurations mentioned in this documentation and any other OpenLane configurations, you can use the exploration script `run_designs.py` to find the optimal value for each configuration for your design. Read more [here][6].

## Base Requirements

You should start by setting the basic configuration file for your design. Check [this][5] for how to add your new design.

The basic configuration `config.json` or `config.tcl` file should at least contain these variables:

| Key | Description |
|-|-|
| `DESIGN_NAME` | The Verilog module name of your design. |
| `VERILOG_FILES` | Space-delimited list of Verilog files used in your design*. |
| `CLOCK_PORT` | List of clock ports used in your design. If your design is purely combinational, you can set this value to `""` (Tcl) or `null` (JSON). |
| `DESIGN_IS_CORE` | `1/0` (Tcl), `true/false` (JSON): Whether your design is a core or a reusable macro: for macros, you want to set this to `0`/`false`<sup>**</sup>. |
> \* The ``` `include ``` directive is not supported.
>
> \** If you are hardening the chip core, check [this][4] for more details about chip integration.

So, for example:

<table>
<tr><th>JSON</th><th>Tcl</th></tr>
<tr>
<td>
    
```json
    "DESIGN_NAME": "spm",
    "VERILOG_FILES": "dir::src/*.v",
    "DESIGN_IS_CORE": false
```

</td>
<td>

```tcl
set ::env(DESIGN_NAME) {spm}

set ::env(VERILOG_FILES) [glob $::env(DESIGN_DIR)/src/*.v]
set ::env(CLOCK_PORT) {clk}
set ::env(DESIGN_IS_CORE) {0}
```

</td>
</tr>
</table>

These configurations should get you through the flow with the all other configurations using OpenLane default values, read about those [here][0]. However, in the coming sections we will take a closer look on how to determine the best values for most of the other configurations.

## Synthesis

The first decision in synthesis is determining the optimal synthesis strategy `SYNTH_STRATEGY` for your design. For that purpose there is a flag in the `flow.tcl` script, `-synth_explore` that runs a synthesis strategy exploration and reports the results in a table under `<run_path>/reports/`.

Then you need to consider the best values for the `MAX_FANOUT_CONSTRAINT`.

If your macro is huge (200k+ cells), then you might want to try setting `SYNTH_NO_FLAT` to `1` (Tcl)/`true` (JSON), which will postpone the flattening of the design during synthesis until the very end.

Other configurations like `SYNTH_SIZING`, `SYNTH_BUFFERING`, and other synthesis configurations do not have to be changed. However, the advanced user can check [this][0] documentation for more details about those configurations and their values.

## Static Timing Analysis

Static Timing Analysis happens multiple times during the flow. However, they all use the same base.sdc file. You can control the outcome of the static timing analysis by setting those values:

1. The clock ports in the design, explained in the base requirements section `CLOCK_PORT`.

2. The clock period that you prefer the design to run with. This could be set using `CLOCK_PERIOD` and the unit is ns. It is important to note that the flow will use this value to calculate the worst and total negative slack, also if timing optimizations are enabled, it will try to optimize for it and give suggested clock period at the end of the run in `<run-path>/reports/metrics.csv` This value should be used in the future to speed up the optimization process and it will be the estimated value at which the design should run.

3. The IO delay percentage from the clock period `IO_PCT`. More about that [here][0].

4. You may want to write a custom SDC file to be used in STA and CTS. The default SDC file in the flow is [this file][11]. However, you can change that by pointing to a new file with the environment variable `BASE_SDC_FILE`. More about that [here][0].

Other values are set based on the (PDK, STD_CELL_LIBRARY) used. You can read more about those configurations [here][0].

Static Timing Analysis are done after:

1. Synthesis using the verilog netlist.

2. Placement using OpenROAD's estimate_parasitics.

3. Timing optimizations using the verilog netlist.

4. Global Routing using OpenROAD's estimate_parasitics.

5. Detailed Routing using SPEF extraction and the verilog netlist.

For SPEF extraction, you can control the wire model and the edge capacitance factor through these variables `SPEF_WIRE_MODEL` and `SPEF_EDGE_CAP_FACTOR`.

More about that [here][0].

## Floorplan

During Floor plan, you have one of three options:

1. Let the tools determine the area relative to the size and number of cells. This is done by setting `FP_SIZING` to `relative` (the default value), and setting `FP_CORE_UTIL` as the core utilization percentage. Also, you can change the aspect ratio by changing `FP_ASPECT_RATIO`.

2. Set a specific DIE AREA by making `FP_SIZING` set to `absolute` and then giving the size as four coordinates to `DIE_AREA`.

3. Use a template DEF and apply the same DIE AREA and dimensions of that DEF. Note that this option will also force the flow to use the same PIN locations and PIN names (they are copied over from the template DEF). To use this option set: `FP_DEF_TEMPLATE` to point to that DEF file.

You can read more about how to control these variables [here][0].


## IO Placement

For IO placement, you currently have four options:

1. Using a template DEF file and applying the same PIN locations and PIN names (they are copied over from the template DEF). Note that this will force the flow to apply the same exact DIE AREA and dimensions of the template DEF. To use that option set: `FP_DEF_TEMPLATE` to point to that DEF file.

2. Manually setting the direction of each pin using a configuration file such as [this one][7]. Then you need to set `FP_PIN_ORDER_CFG` to point to that file.

3. Using contextualized pin placement, which will automatically optimize the placement of the pins based on their context in the larger design that includes them. This relevant for macros since they will be included inside a core, and also relevant for the core since it will be part of a bigger chip. For this to happen, you need to point to the LEF and DEF of the container/parent design using these two variables: `FP_CONTEXT_DEF` and `FP_CONTEXT_LEF`. Note that currently this script can only handle the existance of a single instance of that macro.

4. To let the tool randomly assign IOs using the random equidistant mode. This is the default way.

The options are prioritized based on the order mentioned above. This means that if you set a value for `FP_DEF_TEMPLATE` it will be used and the rest - if they exist - will be ignored.

You can read more about those configurations [here][0].

## Placement

Placement is done in three steps: Global Placement, Optimizations, and Detailed Placement.

### Global Placement

For Global Placement, the most important value would be `PL_TARGET_DENSITY` which should be easy to set.

- If your design is not a tiny design, then `PL_TARGET_DENSITY` should have a value that is `FP_CORE_UTIL` + 1~5%. Note that `FP_CORE_UTIL` has a value from 0 to 100, while `PL_TARGET_DENSITY` has a value from 0 to 1.0.

- If your design is a tiny design, then you may need to set `PL_RANDOM_GLB_PLACEMENT` to `1` or `PL_RANDOM_INITIAL_PLACEMENT` to 1. Also, `PL_TARGET_DENSITY` should have high value, while `FP_CORE_UTIL` should have a low value. (i.e `PL_TARGET_DENSITY` set to 0.5 and `FP_CORE_UTIL` set to 5). In very tiny designs (i.e. 1 std cell designs), the approximated DIE AREA in the floorplan stage may not leave enough room to insert tap cells in the design. Thus, it is recommended to use `FP_SIZING` as `absolute` and manually setting an appropriate `DIE_AREA`, check [the floorplan section](#floorplan) for more details. You may also want to reduce the values for `FP_PDN_HORIZONTAL_HALO` and `FP_PDN_VERTICAL_HALO`. You can read more about those [here][0].

Other values to be considered are `PL_BASIC_PLACEMENT` and `PL_SKIP_INITIAL_PLACEMENT`, you can read more about those [here][0].

### Optimizations

For this step we rely on Resizer and OpenPhySyn.

#### Resizer optimizations

The only optimization we use from resizer is the wire length optimization which is used to reduce the antenna violations. This is disabled by default since the diode insertion strategies should cover that purpose.

However, you can enable that by setting `PL_RESIZER_OVERBUFFER` to `1` and then determine the maximum wire length by setting this value `MAX_WIRE_LENGTH`.

### Detailed Placement

The only value to consider here is the `DPL_CELL_PADDING` which is usually selected for each (PDK,STD_CELL_LIBRARY) and should mostly be left as is. However, typically for the skywater libraries the value should be 4~6.

You can read more about that [here][0].

## Clock Tree Synthesis

Most of the values for clock tree synthesis are (PDK,STD_CELL_LIBRARY) specific and you can read more about those [here][8].

You can disable it by setting `RUN_CTS` to `0`.

If you do not want all the clock ports to be used in clock tree synthesis, then you can use set `CLOCK_NET` to specify those ports. Otherwise, `CLOCK_NET` will be defaulted to the value of `CLOCK_PORT`.

## Power Grid/Power Distribution Network
See [here][9].

## Diode Insertion

Here, you have four options to choose from and they are controlled by setting `DIODE_INSERTION_STRATEGY` to one of the following values: (0, 1, 2, 3, 4, 5)

0. No diode insertion is done.

1. A diode is inserted for each PIN and connected to it.

2. A fake diode is inserted for each PIN and connected to it, then after an antenna check is run and the fake diodes are replaced with real ones if the pin is violated.

3. Rely on OpenROAD:FastRoute antenna avoidance flow to insert the diodes during global routing by using the Antenna Rule Checker and fixing violations. You can execute this iteratively by setting `GRT_MAX_DIODE_INS_ITERS`, it is capable to detect any divergence, so, you will probably end up with the lowest # of Antenna violations possible.

4. A smarter version of strategy 1 that attempts to reduce the number of inserted diodes and places a diode at each design pin.

5. A variant of 2 utilizing the script used in strategy 4.

You can read more about those configurations [here][0].

## Routing

The configurations here were optimized based on a large design set and are best left as is, however the advanced user could refer to [this documentation][0] to learn more about each used configuration and how to change it.

You are advised to change `ROUTING_CORES` based on your CPU capacity to specify the number of threads that TritonRoute can run with to perform Detailed Routing in the least runtime possible.

## GDS Streaming

The configurations here were selected based on a large design test set and the consulation of the magic sources; therefore they are best left as is. However, for the curious user, refer to [this documentation][0] to learn more about each used configuration and how to change it.

## Final Reports and Checks

Finally, the flow ends with physical verification. This begins by streaming out the GDS followed by running DRC, LVS, and Antenna checks on the design. Then, it produces a final summary report in csv format to summarize all the reports.

You can control whether the magic DRC should be done on GDSII or on LEF/DEF abstract views. We recommend using GDSII on macros while using LEF/DEF on the chip level. This should speed up the run process and still give results as accurate as possible. This is controlled by `MAGIC_DRC_USE_GDS`.

You can run Antenna Checks using OpenROAD ARC or magic. This is controlled by `USE_ARC_ANTENNA_CHECK`. The magic antenna checker was more reliable at the time of writing this documentation but it comes with a huge runtime trade-off and the accuracy gain is not significant enough to accept that tradeoff; thus, the default is OpenROAD's ARC.

You can control whether LVS should be run down to the device level or the cell level based on the type of the extraction. If you perform extraction on GDSII then it is going to be down to the device/transistor level, otherwise using the LEF/DEF views then it is going to be down to the cell/block level. This is controlled by `MAGIC_EXT_USE_GDS`.

You can enable LEC on the different netlists by setting `LEC_ENABLE` to one, which should run logic verification after writing each intermediate netlist.

A final summary report is produced by default as `<run-path>/reports/metrics.csv`, for more details about the contents of the report check [this documentation][10].

A final manufacturability report is produced by default as `<run-path>/reports/manufacturability_report.csv`, this report contains the magic DRC, the LVS, and the antenna violations summaries.

The final GDSII file can be found under `<run-path>/results/final/gds`.

To integrate that macro into a core or a chip, check this [documentation on chip integration][4].

If you want to create further tweaks in the flow that the abundant configurations do not allow, make sure to check [this][2] for more details about the interactive mode of the OpenLane flow.

[0]: ../reference/configuration.md
[1]: ../reference/openlane_commands.md
[2]: ../reference/interactive_mode.md
[3]: https://github.com/The-OpenROAD-Project/OpenROAD/blob/master/src/pdn/doc/PDN.md
[4]: ./chip_integration.md
[5]: ./designs.md
[6]: ./exploration_script.md
[7]: https://github.com/The-OpenROAD-Project/openlane/blob/master/designs/spm/pin_order.cfg
[8]: ../for_developers/pdk_structure.md
[9]: ./advanced_power_grid_control.md
[10]: ../reference/datapoint_definitions.md
[11]: ./../../../scripts/base.sdc
