# Hierarchical Chip Design (with Macros)

This guide covers the creation of a simple hierarchical chip-level macro. A memory macro is first hardened, and then the hardened design is used to demonstrate the integration flow within chip-level macros. 

## Hardening the `mem_1r1w` Macroblock

This section covers the process of hardening the `mem_1r1w` macroblock. As these macroblocks will be used in the top-level hierarchy, some configurations need to be made. 

```{warning}
These designs are not ready for production and are just used to showcase the capabilities of OpenLane.
```

### Create the Memory Macro Design
=======

To begin, create the design. The following command will create a directory named `designs/mem_1r1w/` and a file named `config.json` that will be mostly empty.

```console
$ ./flow.tcl -design ./designs/mem_1r1w -init_design_config -add_to_designs
```

```{warning}
Avoid copying existing design folders to create a new design.
```

### Create the RTL Files

Next, create or copy the RTL files. The recommended location for these files is `designs/mem_1r1w/src/`. For this example, let's add a simple counter.

Create the file `designs/mem_1r1w/src/mem_1r1w.v` and add the following content:

```{literalinclude} ../../../designs/ci/mem_1r1w/src/mem_1r1w.v
:language: verilog
```

```{note}
While originally we used a very small macroblock as an example, there's a known issue: small macroblocks don't fit the power grid. Therefore, avoid creating very small macroblocks.

For this example, set `FP_SIZING` to absolute and configure `DIE_AREA` to be larger than `200um x 200um` for sky130.
```

### Configure `mem_1r1w`

Modify the `config.json` file to include the following:

```{literalinclude} ../../../designs/ci/mem_1r1w/config.json
:language: json
```

* `FP_PDN_MULTILAYER` controls the metal levels used for power routing. Set it to `false` to use only lower levels.
* `FP_PDN_CORE_RING` is set to `false` to disable a power ring around the macroblock.
* `RT_MAX_LAYER` is set to `met4` to limit the allowed metal layers for routing.

More information about configuration can be found [here](../reference/configuration.md).

```{figure} ../../_static/digital_flow/ring_around_macro.png
**Left:** `"FP_PDN_CORE_RING": true`. **Right:** `"FP_PDN_CORE_RING": false`
```

### Run the Flow on the Macroblock

Finally, run OpenLane. `flow.tcl` is the entry point for OpenLane. Execute the command from within the OpenLane environment, as described in the quickstart guide.

```console
$ ./flow.tcl -design ./designs/mem_1r1w -tag full_guide -overwrite
```

### Analyzing the Flow-Generated Files

You can open the interactive view using the following commands:

```console
$ python3 gui.py --viewer openroad ./designs/mem_1r1w/runs/full_guide/
```

```{figure} ../../_static/digital_flow/mem_1r1w_def.png
```

## Chip-Level Integration

This section covers the integration of the previously hardened macroblock. Currently, OpenLane does not support cross-hierarchy timing analysis, so users should avoid multiple hierarchies.

### Create Chip Level

The top-level macroblock is called `regfile_2r1w`. To run the flow, we need to prepare the design first. Create a new design named `regfile_2r1w`, which will use the `mem_1r1w` macro.

```console
$ ./flow.tcl -design ./designs/regfile_2r1w -init_design_config -add_to_designs
```

### Integrate the Macros

Verilog blackboxes are used by the synthesis tool. They tell the synthesis tool the purpose and width of the input and output but do not carry timing information.

<!--
The [OpenRAM macro tutorial](../tutorials/openram.md) describes an alternative using Liberty files.
Liberty flow contains the timings; however, OpenLane does not generate Liberty output. This means that the only remaining option is the Verilog blackbox flow.
-->


```{warning}
Users should be careful when creating subcomponents or blackboxes with parameters, as this can cause behavior mismatches between the RTL and the final GDS.
```

Create the Verilog blackbox `./designs/regfile_2r1w/bb/mem_1r1w.bb.v`:

```{literalinclude} ../../../designs/ci/regfile_2r1w/bb/mem_1r1w.bb.v
:language: verilog
```

Then, add `VERILOG_FILES_BLACKBOX`, `EXTRA_LEFS`, and `EXTRA_GDS_FILES` to the `config.json` file within `regfile_2r1w`:

```{note}
For the sake of the tutorial, `FP_CORE_UTIL` is set to `60`.
```

```json
{
"DESIGN_NAME": "regfile_2r1w",
"VERILOG_FILES": "dir::src/*.v",
"CLOCK_PORT": "clk",
"CLOCK_PERIOD": 10.0,
"FP_PDN_MULTILAYER": true,
"FP_CORE_UTIL": 60,

"EXTRA_LEFS":      "dir::../mem_1r1w/runs/full_guide/results/final/lef/mem_1r1w.lef",
"EXTRA_GDS_FILES": "dir::../mem_1r1w/runs/full_guide/results/final/gds/mem_1r1w.gds",
"VERILOG_FILES_BLACKBOX": "dir::bb/*.v"
}
```

This will add the LEF abstract representation of the macroblock. This abstraction file contains only the layers required by the tools. In contrast, GDS contains all the layers and is used to generate the final GDS file. Mismatches between these files are not allowed. It is the user's responsibility to ensure that they match.

```{warning}
Check for name collisions between blackboxed macroblocks that have the same name but different parameters to avoid a behavioral mismatch. This is a [known issue documented here](https://github.com/The-OpenROAD-Project/OpenLane/issues/1291).
```

The PDN straps will be routed in opposite directions. In locations where the two routings cross, VIAs connecting the layers are added. When `FP_PDN_MULTILAYER` is set to `true`, higher layers (met5 in sky130) are used. If it is set to `false`, VIAs will be missing, and you will get LVS issues.

### Verilog Files

Create the RTL files for the `regfile_2r1w` macroblock. The file is located in the newly created design path `designs/regfile_2r1w/src/regfile_2r1w.v` and has the following content:

```{literalinclude} ../../../designs/ci/regfile_2r1w/src/regfile_2r1w.v
:language: verilog
```

### Macro Placement Configuration

When integerating macros, it is best to manually place the macros inside the design.
Create the following file `./designs/regfile_2r1w/macro.cfg`:
```
lane0 15 200 N
lane1 13 14 N
```

This tells the flow to place `lane0` at location (15, 200) in microns with North orientation
and `lane1` at location (13, 14) in microns with North orientation

Then change the JSON configuration to point to this file:

```json
{
"DESIGN_NAME": "regfile_2r1w",
"VERILOG_FILES": "dir::src/*.v",
"CLOCK_PORT": "clk",
"CLOCK_PERIOD": 10.0,
"FP_PDN_MULTILAYER": true,
"FP_CORE_UTIL": 60,

"EXTRA_LEFS":      "dir::../mem_1r1w/runs/full_guide/results/final/lef/mem_1r1w.lef",
"EXTRA_GDS_FILES": "dir::../mem_1r1w/runs/full_guide/results/final/gds/mem_1r1w.gds",
"VERILOG_FILES_BLACKBOX": "dir::bb/*.v"
"MACRO_PLACEMENT_CFG": "dir::macro.cfg"
}
```

### Run the Flow

Run the flow. It is expected for the flow to fail. An explanation is provided in the next step.

```console
$ ./flow.tcl -design regfile_2r1w -tag full_guide_broken_aspect_ratio -overwrite
```

### First Issue

The flow is expected to fail.

```
[ERROR]: during executing openroad script /openlane/scripts/openroad/pdn.tcl
[ERROR]: Log: designs/regfile_2r1w/runs/full_guide/logs/floorplan/7-pdn.log
[ERROR]: Last 10 lines:
[INFO]: Setting clock transition to: 0.15
[INFO]: Setting timing derate to: 5.0 %
[INFO PDN-0001] Inserting grid: stdcell_grid
[INFO PDN-0001] Inserting grid: macro - lane0
[INFO PDN-0001] Inserting grid: macro - lane1
[WARNING PDN-0232] macro - lane0 does not contain any shapes or vias.
[WARNING PDN-0232] macro - lane1 does not contain any shapes or vias.
[ERROR PDN-0233] Failed to generate full power grid.
PDN-0233
child process exited abnormally
```

To debug this issue, open the OpenROAD GUI:

```console 
$ python3 gui.py ./designs/regfile_2r1w/runs/full_guide_broken_aspect_ratio/
```

```{figure}
../../\_static/digital_flow/broken_aspect_ratio.png
```

As shown in the image, the placement of the `mem_1r1w` instances failed. The instances overlap
and the Flow was unable to create a PDN properly

Change the `FP_ASPECT_RATIO` value to `2`. This will make the floorplan a rectangle instead of a square, with the rectangle being twice as tall as it is wide.

More information about floorplanning is available in the [Hardening Macros guide](../usage/hardening_macros.md).

The `config.json` file should look like this:

```json
{
    "DESIGN_NAME": "regfile_2r1w",
    "VERILOG_FILES": "dir::src/*.v",
    "CLOCK_PORT": "clk",
    "CLOCK_PERIOD": 10.0,
    "FP_PDN_MULTILAYER": true,
    "FP_CORE_UTIL": 60,
    "FP_ASPECT_RATIO": 2,

    "EXTRA_LEFS": "dir::../mem_1r1w/runs/full_guide/results/final/lef/mem_1r1w.lef",
    "EXTRA_GDS_FILES": "dir::../mem_1r1w/runs/full_guide/results/final/gds/mem_1r1w.gds",
    "VERILOG_FILES_BLACKBOX": "dir::bb/*.v",
    "MACRO_PLACEMENT_CFG": "dir::macro.cfg"
}
```

The macroblock locations have to change as well. Edit `./designs/regfile_2r1w/macro.cfg`:
```
lane0 80.24 10.88 N
lane1 80.24 380.08 N
```

### Run the Flow Again

Run the flow again. This time, it should no longer fail.

```console
$ ./flow.tcl -design regfile_2r1w -tag full_guide -overwrite
```

### Analyzing the Results
Open the OpenROAD GUI to view the results of the flow.

```console
$ python3 gui.py --viewer openroad ./designs/mem_1r1w/runs/full_guide/
```

```{figure} ../../_static/digital_flow/final_def.png
OpenROAD GUI with loaded final DEF file
```

If you want to load a DEF/ODB file, at a different stage in the flow, run, for example:

```console
$ python3 gui.py --viewer openroad ./designs/mem_1r1w/runs/full_guide/ --stage cts
```

For more information, run `python3 gui.py --help` or visit <insert link>


```{figure} ../../_static/digital_flow/floorplan_def_loaded.png
```

Each run has the following structure:

```
├── logs OR reports OR results OR tmp
│   ├── cts
│   ├── floorplan
│   ├── placement
│   ├── routing
│   ├── signoff
│   └── synthesis
├── runtime.yaml
└── warnings.log
```

There are four directories: `logs`, `reports`, `results`, and `tmp`. Within each of these directories, there are multiple subdirectories named according to the stage they belong to.

The `results` directory contains the results (outputs) of each step. For example, the content of the `results/cts` directory:

```
designs/ci/regfile_2r1w/runs/full_guide/results/cts
├── regfile_2r1w.def
├── regfile_2r1w.odb
└── regfile_2r1w.sdc
```

DEF/ODB files can be loaded using the steps provided above.

Finally, the output of OpenLane can be found in `designs/ci/regfile_2r1w/runs/full_guide/results/final`:

```
designs/ci/regfile_2r1w/runs/full_guide/results/final
├── def
│   └── regfile_2r1w.def
├── gds
│   └── regfile_2r1w.gds
├── lef
│   └── regfile_2r1w.lef
├── mag
│   └── regfile_2r1w.mag
├── maglef
│   └── regfile_2r1w.mag
├── sdc
│   └── regfile_2r1w.sdc
├── sdf
│   └── regfile_2r1w.sdf
├── spef
│   └── regfile_2r1w.spef
├── spi
│   └── lvs
│       └── regfile_2r1w.spice
└── verilog
    └── gl
        └── regfile_2r1w.v
```

The `logs` directory contains log files from each step. Steps are enumerated. For example, the content of the `logs/` directory:

```
designs/ci/regfile_2r1w/runs/full_guide/logs
├── cts
│   ├── 14-cts.log
│   ├── 15-write_verilog.log
│   ├── 16-resizer.log
│   └── 17-write_verilog.log
├── floorplan
│   ├── 3-initial_fp.log
│   ├── 4-io.log
│   ├── 7-tap.log
│   └── 8-pdn.log
├── placement
│   ├── 10-resizer.log
│   ├── 11-write_verilog.log
│   ├── 12-remove_buffers_from_ports.log
│   ├── 13-detailed.log
│   ├── 5-global.log
│   ├── 6-basic_mp.log
│   └── 9-global.log
├── routing
│   ├── 18-resizer.log
│   ├── 19-write_verilog.log
│   ├── 20-diode_legalization.log
│   ├── 21-global.log
│   ├── 22-fill.log
│   ├── 23-write_verilog_global.log
│   ├── 24-detailed.log
│   └── 25-write_verilog_detailed.log
├── signoff
│   ├── 26-parasitics_extraction.min.log
│   ├── 27-parasitics_multi_corner_sta.min.log
│   ├── 28-parasitics_extraction.max.log
│   ├── 29-parasitics_multi_corner_sta.max.log
│   ├── 30-parasitics_extraction.nom.log
│   ├── 31-parasitics_sta.log
│   ├── 32-parasitics_multi_corner_sta.log
│   ├── 33-irdrop.log
│   ├── 34-gdsii.log
│   ├── 34-gds_ptrs.log
│   ├── 34-lef.log
│   ├── 34-maglef.log
│   ├── 35-gdsii-klayout.log
│   ├── 36-xor.log
│   ├── 37-spice.log
│   ├── 38-write_powered_def.log
│   ├── 40-lef.log
│   ├── 40-regfile_2r1w.lef.json
│   ├── 40-regfile_2r1w.lef.log
│   ├── 40-regfile_2r1w.lvs.lef.log
│   ├── 41-drc.log
│   └── 42-antenna.log
└── synthesis
    ├── 1-synthesis.log
    └── 2-sta.log
```

The `reports` directory contains all the reports from the corresponding stage.

It is recommended to check the reports for power, timings, etc. This provides a better understanding of the underlying flow.

Finally, open the final layout.

```console
$ python3 gui.py ./designs/regfile_2r1w/runs/full_guide --viewer klayout
```

```{figure} ../../_static/digital_flow/final_gds.png
```

### Exploring Your Designs

Examine some of the reports.

Here's an excerpt from `designs/ci/mem_1r1w_00/runs/full_guide/reports/signoff/##-rcx_sta.summary.rpt`:

```
===========================================================================
report_worst_slack -max (Setup)
============================================================================
worst slack 4.66

===========================================================================
report_worst_slack -min (Hold)
============================================================================
worst slack 0.03
```

Detailed setup (max) timing path reports. Content of `designs/ci/mem_1r1w/runs/full_guide/reports/signoff/##-rcx_sta.max.rpt`:

```
===========================================================================
report_checks -path_delay max (Setup)
============================================================================

======================= Slowest Corner ===================================

Startpoint: write_addr[1] (input port clocked by clk)
Endpoint: _3436_ (rising edge-triggered flip-flop clocked by clk)
Path Group: clk
Path Type: max
Corner: Slowest

Fanout     Cap    Slew   Delay    Time   Description
-----------------------------------------------------------------------------
                                0.00    0.00   clock clk (rise edge)
                                0.00    0.00   clock network delay (propagated)
                                2.00    2.00 v input external delay
                        0.02    0.01    2.01 v write_addr[1] (in)
        1    0.00                           write_addr[1] (net)
                        0.02    0.00    2.01 v input8/A (sky130_fd_sc_hd__dlymetal6s2s_1)
                        0.18    0.37    2.38 v input8/X (sky130_fd_sc_hd__dlymetal6s2s_1)
        4    0.02                           net8 (net)
                        0.18    0.00    2.38 v _2019_/A (sky130_fd_sc_hd__or3b_2)
                        0.23    1.29    3.67 v _2019_/X (sky130_fd_sc_hd__or3b_2)
        2    0.01                           _0833_ (net)
                        0.23    0.00    3.67 v _2020_/A (sky130_fd_sc_hd__inv_2)
                        0.09    0.17    3.84 ^ _2020_/Y (sky130_fd_sc_hd__inv_2)
        3    0.01                           _0834_ (net)
                        0.09    0.00    3.84 ^ _2432_/C (sky130_fd_sc_hd__and3_2)
                        0.24    0.56    4.39 ^ _2432_/X (sky130_fd_sc_hd__and3_2)
        5    0.03                           _1054_ (net)
                        0.24    0.00    4.39 ^ _2433_/A (sky130_fd_sc_hd__buf_4)
                        0.26    0.44    4.84 ^ _2433_/X (sky130_fd_sc_hd__buf_4)
        10    0.06                           _1055_ (net)
                        0.26    0.01    4.85 ^ _2450_/S (sky130_fd_sc_hd__mux2_1)
                        0.11    0.81    5.66 v _2450_/X (sky130_fd_sc_hd__mux2_1)
        1    0.00                           _1064_ (net)
                        0.11    0.00    5.66 v _2451_/A (sky130_fd_sc_hd__clkbuf_1)
                        0.05    0.18    5.84 v _2451_/X (sky130_fd_sc_hd__clkbuf_1)
        1    0.00                           _0424_ (net)
                        0.05    0.00    5.84 v _3436_/D (sky130_fd_sc_hd__dfxtp_1)
                                        5.84   data arrival time

                                10.00   10.00   clock clk (rise edge)
                                0.00   10.00   clock source latency
                        0.18    0.12   10.12 ^ clk (in)
        1    0.02                           clk (net)
                        0.18    0.00   10.12 ^ clkbuf_0_clk/A (sky130_fd_sc_hd__clkbuf_16)
                        0.12    0.31   10.43 ^ clkbuf_0_clk/X (sky130_fd_sc_hd__clkbuf_16)
        4    0.06                           clknet_0_clk (net)
                        0.12    0.00   10.43 ^ clkbuf_2_3__f_clk/A (sky130_fd_sc_hd__clkbuf_16)
                        0.18    0.33   10.76 ^ clkbuf_2_3__f_clk/X (sky130_fd_sc_hd__clkbuf_16)
        10    0.11                           clknet_2_3__leaf_clk (net)
                        0.18    0.00   10.76 ^ clkbuf_leaf_17_clk/A (sky130_fd_sc_hd__clkbuf_16)
                        0.08    0.27   11.03 ^ clkbuf_leaf_17_clk/X (sky130_fd_sc_hd__clkbuf_16)
        11    0.03                           clknet_leaf_17_clk (net)
                        0.08    0.00   11.03 ^ _3436_/CLK (sky130_fd_sc_hd__dfxtp_1)
                                -0.25   10.78   clock uncertainty
                                0.00   10.78   clock reconvergence pessimism
                                -0.26   10.52   library setup time
                                        10.52   data required time
        -----------------------------------------------------------------------------
                                        10.52   data required time
                                        -5.84   data arrival time
        -----------------------------------------------------------------------------
                                        4.68   slack (MET)
```

