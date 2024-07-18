# OpenLane Architecture

![A diagram showing the general stages of the OpenLane flow as a series of blocks](../_static/flow.png)

## OpenLane Flow Stages

OpenLane flow consists of several stages. By default all flow steps are run in sequence. Each stage may consist of multiple sub-stages. OpenLane can also be run interactively as shown [here][25].

1. **Synthesis**
    1. [Yosys](https://github.com/yosyshq/yosys) - Perform RTL synthesis and technology mapping.
    2. [OpenSTA](https://github.com/the-openroad-project/opensta) - Performs static timing analysis on the resulting netlist to generate timing reports
2. **Floorplaning**
    1. [OpenROAD/Initialize Floorplan](https://github.com/the-openroad-project/openroad/tree/master/src/ifp) - Defines the core area for the macro as well as the rows (used for placement) and the tracks (used for routing)
    2. OpenLane IO Placer - Places the macro input and output ports
    3. [OpenROAD/PDN Generator](https://github.com/the-openroad-project/openroad/tree/master/src/pdn) - Generates the power distribution network
    4. [OpenROAD/Tapcell](https://github.com/the-openroad-project/openroad/tree/master/src/tap)  - Inserts welltap and endcap cells in the floorplan
3. **Placement**
    1. [OpenROAD/RePlace](https://github.com/the-openroad-project/openroad/tree/master/src/gpl) - Performs global placement
    2. [OpenROAD/Resizer](https://github.com/the-openroad-project/openroad/tree/master/src/rsz)  - Performs optional optimizations on the design
    3. [OpenROAD/OpenDP](https://github.com/the-openroad-project/openroad/tree/master/src/dpl)  - Performs detailed placement to legalize the globally placed components
4. **CTS**
    1. [OpenROAD/TritonCTS](https://github.com/the-openroad-project/openroad/tree/master/src/cts)  - Synthesizes the clock distribution network (the clock tree)
5. **Routing**
    1. [OpenROAD/FastRoute](https://github.com/the-openroad-project/openroad/tree/master/src/grt) - Performs global routing to generate a guide file for the detailed router
    2. [OpenROAD/TritonRoute](https://github.com/the-openroad-project/openroad/tree/master/src/drt) - Performs detailed routing
    3. [OpenROAD/OpenRCX](https://github.com/the-openroad-project/openroad/tree/master/src/rcx) - Performs SPEF extraction
6. **Tapeout**
    1. [Magic](https://github.com/rtimothyedwards/magic) - Streams out the final GDSII layout file from the routed def
    2. [KLayout](https://github.com/klayout/klayout) - Streams out the final GDSII layout file from the routed def as a back-up
7. **Signoff**
    1. [Magic](https://github.com/rtimothyedwards/magic) - Performs DRC Checks & Antenna Checks
    2. [Magic](https://github.com/klayout/klayout) - Performs DRC Checks & an XOR sanity-check between the two generated GDS-II files
    3. [Netgen](https://github.com/rtimothyedwards/netgen) - Performs LVS Checks
    
All tools in the OpenLane flow are free, libre and open-source software. While
OpenLane itself as a script (and its associated build scripts) are under the
Apache License, version 2.0, tools may fall under stricter licenses.
    
> Everything in Floorplanning through Routing is done using
> [OpenROAD](https://github.com/The-OpenROAD-Project/OpenROAD) and its various
> sub-utilities, hence the name "OpenLane."

## OpenLane Output

All output run data is placed by default under ./designs/design_name/runs. Each flow cycle will output a timestamp-marked folder containing the following file structure:

```
<design_name>
├── config.json/config.tcl
├── runs
│   ├── <tag>
│   │   ├── config.tcl
│   │   ├── {logs, reports, tmp}
│   │   │   ├── cts
│   │   │   ├── signoff
│   │   │   ├── floorplan
│   │   │   ├── placement
│   │   │   ├── routing
│   │   │   └── synthesis
│   │   ├── results
│   │   │   ├── final
│   │   │   ├── cts
│   │   │   ├── signoff
│   │   │   ├── floorplan
│   │   │   ├── placement
│   │   │   ├── routing
│   │   │   └── synthesis
```

To delete all generated runs under all designs:
`make clean_runs`.
