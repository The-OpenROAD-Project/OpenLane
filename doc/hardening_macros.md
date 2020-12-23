# Hardening Macros

Using openlane, you can produce a GDSII from an RTL for macros, and then use these macros to create your chip. Check [this][4] for more details about chip integration.

In this document we will go through the hardening steps and discuss in some detail what considerations should be made when hardening your macro.

**NOTE:** For all the configurations mentioned in this documentation and any other openlane documentation, you can use the exploration script `run_designs.py` to find the optimal value for each configuration. Read more [here][6].

## Base Requirements:

You should start by setting the basic configuration file for your design. Check [this][5] for how to add your new design.

The basic configurations `config.tcl` should at least contain:
```tcl
set ::env(DESIGN_NAME) <the name of the design>

set ::env(VERILOG_FILES) <pointer to the verilog source(s) of the design>
set ::env(CLOCK_PORT) <list of clock ports in the design rtl>
set ::env(DESIGN_IS_CORE) 0 # Since you are hardening a macro.
```

If you are hardening the chip core. Then make sure to set `::env(DESIGN_IS_CORE)` to `1` and check [this][4] for more details about chip integration.

In case your design doesn't have a clock port, then you can either omit ::env(CLOCK_PORT) or give it an empty string.

These configurations should get you through the flow with the all other configurations using openlane default values, read about those [here][0]. However, in the coming sections we will take a closer look on how to determine the best values for most of the other configurations.

## Synthesis

The first decision in synthesis is determining the optimal synthesis strategy `::env(SYNTH_STRATEGY)` for your design. For that purpose there is a flag in the `flow.tcl` script, `-synth_explore` that runs a synthesis strategy exploration and reports the results in a table under `<run_path>/reports/`.

Then you need to consider the best values for the `SYNTH_MAX_FANOUT`.

If your macro is huge (200k+ cells), then you might want to try setting `SYNTH_NO_FLAT` to `1`.

Other configurations like `SYNTH_SIZING`, `SYNTH_BUFFERING`, and other synthesis configurations don't have to be changed. However, the advanced user can check [this][0] documentation for more details about those configurations and their values.

## Static Timing Analysis

Static Timing Analysis happens multiple times during the flow. However, they all use the same base.sdc file. You can control the outcome of the static timing analysis by setting those values:

1. The clock ports in the design, explained in the base requirements section `CLOCK_PORT`.

2. The clock period that you prefer the design to run with. This could be set using `::env(CLOCK_PERIOD)` and the unit is ns. It's important to note that the flow will use this value to calculate the worst and total negative slack, also if timing optimizations are enabled, it will try to optimize for it and give suggested clock period at the end of the run in `<run-path>/reports/final_summary_report.csv` This value should be used in the future to speed up the optimization process and it will be the estimated value at which the design should run.

3. The IO delay percentage from the clock period `IO_PCT`. More about that [here][0].

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

During Floor plan, you have one of two options:

1. Let the tools determine the area relative to the size and number of cells. This is done by setting `FP_SIZING` to `relative` (the default value), and setting `FP_CORE_UTIL` as the core utilization percentage. Also, you can change the aspect ratio by changing `FP_ASPECT_RATIO`.

2. Set a specific DIE AREA by making `FP_SIZING` set to `absolute` and then giving the size as four coordinates to `DIE_AREA`.

You can read more about how to control these variables [here][0].

## IO Placement

For IO placement, you currently have 3 options:

1. Manually setting the direction of each pin using a configuration file such as [this one][7]. Then you need to set `::env(FP_PIN_ORDER_CFG)` to point to that file.

2. Using contextualized pin placement, which will automatically optimize the placement of the pins based on their context in the larger design that includes them. This relevant for macros since they will be included inside a core, and also relevant for the core since it will be part of a bigger chip. For this to happen, you need to point to the LEF and DEF of the container/parent design using these two variables: `FP_CONTEXT_DEF` and `FP_CONTEXT_LEF`. Note that currently this script can only handle the existance of a single instance of that macro.

3. To let the tool randomly assign IOs using the random equidistant mode. This is the default way.

The options are prioritized based on the order mentioned above. This means that if you set a value for `FP_PIN_ORDER_CFG`, the manual placement will be used regardless of the values of the other configurations.

You can read more about those configurations [here][0].

## Placement

Placement is done in three steps: Global Placement, Optimizations, and Detailed Placement.

### Global Placement:

For Global Placement, the most important value would be `PL_TARGET_DENSITY` which should be easy to set.

- If your design is not a tiny design, then `PL_TARGET_DENSITY` should have a value that is `FP_CORE_UTIL` + 1~5%. Note that `FP_CORE_UTIL` has a value from 0 to 100, while `PL_TARGET_DENSITY` has a value from 0 to 1.0.

- If your design is a tiny design, then set `PL_RANDOM_GLB_PLACEMENT` to `1`. You may need to also set `PL_TARGET_DENSITY` should have high value, while `FP_CORE_UTIL` should have a low value. (i.e `PL_TARGET_DENSITY` set to 0.5 and `FP_CORE_UTIL` set to 5).

Other values to be considered are `PL_BASIC_PLACEMENT` and `PL_SKIP_INITIAL_PLACEMENT`, you can read more about those [here][0].

### Optimizations:

For this step we rely on Resizer and OpenPhySyn.

#### Resizer optimizations:

The only optimization we use from resizer is the wire length optimization which is used to reduce the antenna violations. This is disabled by default since the diode insertion strategies should cover that purpose.

However, you can enable that by setting `PL_RESIZER_OVERBUFFER` to `1` and then determine the maximum wire length by setting this value `MAX_WIRE_LENGTH`.

#### OpenPhySyn optimizations:

The timing OpenPhySyn optimizations are enabled by default and you can control that using this flag `PL_OPENPHYSYN_OPTIMIZATIONS`.

You can also control resizing and pin swapping using these flags: `PSN_ENABLE_RESIZING` and `PSN_ENABLE_PIN_SWAP`.

You can read more about those configurations [here][0].

### Detailed Placement:

The only value to consider here is the `CELL_PAD` which is usually selected for each (PDK,STD_CELL_LIBRARY) and should mostly be left as is.

You can read more about that [here][0].

## Clock Tree Synthesis

Most of the values for clock tree synthesis are (PDK, STD_CELL_LIBRARY) specific and you can read more about those [here][8].

You can disable it by setting `CLOCK_TREE_SYNTH` to `0`.

If you don't want all the clock ports to be used in clock tree synthesis, then you can use set `CLOCK_NET` to specify those ports. Otherwise, `CLOCK_NET` will be defaulted to the value of `CLOCK_PORT`.

## Power Grid (pdn)

Each macro in your design should configure the `common_pdn.tcl` for it's use. Generally, you want to announce that the design is a macro inside the core, and that it doesn't have a core ring. Also, prohibit the router from using metal 5 by setting the maximum routing layer to met4 (layer 5). This is done by setting the following configs:

```tcl
set ::env(DESIGN_IS_CORE) 0
set ::env(FP_PDN_CORE_RING) 0
set ::env(GLB_RT_MAXLAYER) 5
```

Pdngen configs for macros contain a special stdcell section, instead of the one used for the core in the `common_pdn.tcl`. The purpose of this is to prohibit the use of metal 5 in the power grid of the macros and use it exclusively for the core and top level.

If your macro contains other macros inside it. Then make sure to check the `macro` section and see if it requires any modifications for each them depending on their special configs. The following example is using default `connect` section and a different `straps` section:
```tcl
pdngen::specify_grid macro {
    orient {R0 R180 MX MY R90 R270 MXR90 MYR90}
    power_pins "vpwr"
    ground_pins "vgnd"
    straps {
	    met1 {width 0.74 pitch 3.56 offset 0}
	    met4 {width $::env(FP_PDN_VWIDTH) pitch $::env(FP_PDN_VPITCH) offset $::env(FP_PDN_VOFFSET)}
    }
    connect {{met1 met4}}
}
```

**WARNING:** only use met1 and met4 for rails and straps.

Refer to [this][3] for more details about the syntax in case you needed to create your own `pdn.tcl` and then point to it using `::env(PDN_CFG)`.

- The height of each macro must be greater than or eaqual to the value of `$::env(FP_PDN_HPITCH)` to allow at least two metal 5 straps on the core level to cross it and all the dropping of a via from met5 to met4 connecting the vertical straps of the macro to the horizontal straps of the core and so connect the power grid of the macro to the outer core ring.

If your design is a core, then check the power routing section in the [chip integration documentation][4]. However, the basic thing you'll need to do is to announce that your design is a chip core and that it should have a core ring. This is done by setting the following values:

```tcl
set ::env(DESIGN_IS_CORE) 1
set ::env(FP_PDN_CORE_RING) 1
```

## Diode Insertion

Here, you have four options to choose from and they are controlled by setting `DIODE_INSERTION_STRATEGY` to one of the following values: (0, 1, 2, 3)

0. No diode insertion is done.

1. A diode is inserted for each PIN and connected to it.

2. A fake diode is inserted for each PIN and connected to it, then after an antenna check is run and the fake diodes are replaced with real ones if the pin is violated.

3. Rely on OpenROAD:FastRoute antenna avoidance flow to insert the diodes during global routing by using the Antenna Rule Checker and fixing violations. You can execute this iteratively by setting `GLB_RT_MAX_DIODE_INS_ITERS`, it is capable to detect any divergence, so, you'll probably end up with the lowest # of Antenna violations possible.

You can read more about those configurations [here][0].

## Routing

The configurations here were optimized based on a large design set and are best left as is, however the advanced user could refer to [this documentation][0] to learn more about each used configuration and how to change it.

You are advised to change `ROUTING_CORES` based on your CPU capacity to specify the number of threads that TritonRoute can run with to perform Detailed Routing in the least runtime possible.

## Final Reports and Checks

Finally, the flow ends with physical verification. This begins by streaming out the GDS followed by running DRC, LVS, and Antenna checks on the design. Then, it produced a final summary reports in csv format to summaries all the reports.

You can control whether the magic DRC should be done on GDS-II or on LEF/DEF abstract views. We recommend using GDS-II on macros while using LEF/DEF on the chip level. This should speed up the run process and still give as accurate as possible results. This is controlled by `MAGIC_DRC_USE_GDS`.

You can run Antenna Checks using OpenROAD ARC or magic. This is controlled by `USE_ARC_ANTENNA_CHECK`.

You can enable LEC on the different netlists by setting `LEC_ENABLE` to one, which should run logic verification after writing each intermediate netlist.

A final summary report is produced by default as `<run-path>/reports/final_summary_report.csv`.

The final GDS-II should be found under `<run-path>/results/magic/`.

To integrate that macro into a core or a chip, check this [documentation on chip integration][4].

If you want to create further tweaks in the flow that the abundant configurations doesn't allow, make sure to check [this][2] for more details about the interactive mode of the OpenLANE flow.

[0]: ./../configuration/README.md
[1]: ./OpenLANE_commands.md
[2]: ./advanced_readme.md
[3]: https://github.com/The-OpenROAD-Project/OpenROAD/blob/master/src/pdngen/doc/PDN.md
[4]: ./chip_integration.md
[5]: ./../designs/README.md
[6]: ./../regression_results/README.md
[7]: ./../designs/spm/pin_order.cfg
[8]: ./PDK_STRUCTURE.md
