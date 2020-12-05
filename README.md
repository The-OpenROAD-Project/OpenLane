      ___   ____   ___  ____   _       ____  ____     ___
     /   \ |    \ /  _]|    \ | |     /    ||    \   /  _]
    |     ||  o  )  [_ |  _  || |    |  o  ||  _  | /  [_
    |  O  ||   _/    _]|  |  || |___ |     ||  |  ||    _]
    |     ||  | |   [_ |  |  ||     ||  _  ||  |  ||   [_
     \___/ |__| |_____||__|__||_____||__|__||__|__||_____|


# Table of contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Updating OpenLANE](#updating-openlane)
- [Setting up the PDK: skywater-pdk](#setting-up-the-pdk-skywater-pdk)
- [Setting up OpenLANE](#setting-up-openlane)
    - [Building the OpenLANE Docker](#building-the-openlane-docker)
    - [Running OpenLANE](#running-openlane)
    - [Command line arguments](#command-line-arguments)
    - [Adding a design](#adding-a-design)
- [OpenLANE Architecture](#openlane-architecture)
    - [OpenLANE Design Stages](#openlane-design-stages)
    - [OpenLANE Output](#openlane-output)
    - [Flow configuration](#flow-configuration)
- [Regression And Design Configurations Exploration](#regression-and-design-configurations-exploration)
- [Hardening Macros](#hardening-macros)
- [Chip Integration](#chip-integration)

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![Build Status](https://travis-ci.com/efabless/openlane.svg?branch=master)](https://travis-ci.com/efabless/openlane)

# Overview

OpenLANE is an automated RTL to GDSII flow based on several components including OpenROAD, Yosys, Magic, Netgen, Fault, OpenPhySyn, SPEF-Extractor and custom methodology scripts for design exploration and optimization. The flow performs full ASIC implementation steps from RTL all the way down to GDSII - this capability will be released in the coming weeks with completed SoC design examples that have been sent to SkyWater for fabrication.

Join the community on [slack](https://invite.skywater.tools)!

# Prerequisites

 - Docker (ensure docker daemon is running) -- tested with version 19.03.12, but any recent version should suffice
 - [Magic VLSI Layout Tool](http://opencircuitdesign.com/magic/index.html) is needed to run open_pdks -- version >= 8.3.60*

 > \* Note: You can avoid the need for the magic prerequisite by using the openlane docker to do the installation step in open_pdks. This [file](./travisCI/travisBuild.sh) shows how.

For more details about the docker container and its process, the [following instructions][1] walk you through the process of using docker containers to build the needed tools then integrate them into OpenLANE flow.


# Quick Start:

You can start setting up the skywater-pdk and openlane by running:

```bash
    git clone https://github.com/efabless/openlane.git --branch rc5
    cd openlane/
    export PDK_ROOT=<absolute path to where skywater-pdk and open_pdks will reside>
    make
    make test # This is to test that the flow and the pdk were properly installed
```

the Makefile should do the following when you run the above command:
- Clone Skywater-pdk and the specified STD_CELL_LIBRARY and build it.
- Clone open_pdks and set up the STD_CELL_LIBRARY for OpenLANE use.
- Build the OpenLANE docker.
- Test the whole setup with a complete run on a small design `spm`.

**Note**: the default STD_CELL_LIBRARY is sky130_fd_sc_hd. You can change that inside the [Makefile](./Makefile).

This should produce a clean run for the spm. The final layout will be generated here: [./designs/spm/runs/openlane_test/results/magic/spm.gds](./designs/spm/runs/openlane_test/results/magic/).

To run the regression test, which tests the flow against all available designs under [./designs/](./designs/) vs the the benchmark results, run the following command:

```bash
    make regression_test
```

Your results will be compared with: [sky130_fd_sc_hd](https://github.com/efabless/openlane/blob/master/regression_results/benchmark_results/SW_HD.csv).

After running you'll find a directory added under [./regression_results/](./regression_results) it will contain all the reports needed for you to know whether you've been successful or not. Check [this](./regression_results/README.md#output) for more details.

**Note**: if runtime is `-1`, that means the design failed. Any reported statistics from any run after the failure of the design is reported as `-1` as well.

# Updating OpenLANE

If you already have the repo locally, then no need to re-clone it. You can directly run the following:

```bash
    cd openlane/
    git checkout master
    git pull
    git checkout rc5
    export PDK_ROOT=<absolute path to where skywater-pdk and open_pdks will reside>
    make
    make test # This is to test that the flow and the pdk were properly installed
```

This should install the latest openlane docker, and re-install the pdk for the latest used version. If you want to only update the openlane docker check this [section](#building-the-openlane-docker) after updating the repo.

**DISCLAIMER: The following sections are to give you an understanding of what happens under the hood in the Makefile.**

# Setting up the PDK: skywater-pdk

- Clone and build at least one [skywater-pdk](https://github.com/google/skywater-pdk) standard cell Library inside the pdks directory:
    - To setup one standard cell library only

    ```bash
        export PDK_ROOT=<absolute path to where skywater-pdk and open_pdks will reside>
        cd  $PDK_ROOT
        git clone https://github.com/google/skywater-pdk.git
        cd skywater-pdk
        git checkout 3d7617a1acb92ea883539bcf22a632d6361a5de4
        git submodule update --init libraries/sky130_fd_sc_hd/latest
        git submodule update --init libraries/sky130_fd_sc_hvl/latest
        git submodule update --init libraries/sky130_fd_io/latest
        make timing
    ```
    - To setup other SCLs:
        - replace sky130_fd_sc_hd with any of the following list:
            - sky130_fd_sc_hs
            - sky130_fd_sc_ms
            - sky130_fd_sc_ls
            - sky130_fd_sc_hdll

- Setup the configurations and tech files for Magic, Netgen, OpenLANE using [open_pdks](https://github.com/RTimothyEdwards/open_pdks):

    ```bash
        cd $PDK_ROOT
	    git clone https://github.com/RTimothyEdwards/open_pdks.git
        cd open_pdks
        git checkout b184e85de7629b8c87087a46b79eb45e7f7cd383
        ./configure --with-sky130-source=$PDK_ROOT/skywater-pdk/libraries --with-sky130-local-path=$PDK_ROOT
		cd sky130
		make
		make install-local
    ```

**Note**: You can use different directories for sky130-source and local-path. However, in the instructions we are using $PDK_ROOT to facilitate the installation process

**WARNING**: Please, don't move `sk130A` from the installed directory because the generated .mag files contain absolute paths. Moving it will result in producing an invalid GDS.

 - To set the STD_CELL_LIBRARY (the default value is set to sky130_fd_sc_hd)
    - Open [configuration/general.tcl](./configuration/general.tcl)
    - set STD_CELL_LIBRARY to one of the following:

            - sky130_fd_sc_hs
            - sky130_fd_sc_ms
            - sky130_fd_sc_ls
            - sky130_fd_sc_hdll

Refer to [this][24] for more details on the structure.


# Setting up OpenLANE

## Building the OpenLANE Docker

### Building the Docker Image Locally

To setup openlane you can build the docker container locally following these instructions:

```bash
    git clone https://github.com/efabless/openlane.git --branch rc5
    cd openlane/docker_build
    make merge
    cd ..
```

### Pulling an Auto-Built Docker Image from Dockerhub

Alternatively, you can use the auto-built openlane docker images available through [dockerhub](https://hub.docker.com/r/efabless/openlane/tags).

**Note:** You may need to have an account on dockerhub to execute the following step.

```bash
    git clone https://github.com/efabless/openlane.git --branch rc5
    docker pull efabless/openlane:rc5
```

## Running OpenLANE

### Running the Locally Built Docker Image

Issue the following command to open the docker container from /path/to/openlane to ensure that the output files persist after exiting the container:

```bash
    docker run -it -v $(pwd):/openLANE_flow -v $PDK_ROOT:$PDK_ROOT -e PDK_ROOT=$PDK_ROOT -u $(id -u $USER):$(id -g $USER) openlane:rc5
```

### Running the Pulled Auto-Built Docker Image
If you pulled the docker image from dockerhub instead of building it locally, then run the following command:

```bash
    export IMAGE_NAME=efabless/openlane:rc5
    docker run -it -v $(pwd):/openLANE_flow -v $PDK_ROOT:$PDK_ROOT -e PDK_ROOT=$PDK_ROOT -u $(id -u $USER):$(id -g $USER) $IMAGE_NAME
```

**Note: this will mount the openlane directory inside the container.**


Use the following example to check the overall setup:

```bash
./flow.tcl -design spm
```

To run OpenLANE on multiple designs at the same time, check this [section](#regression-and-design-configurations-exploration).

Having trouble running the flow? check [FAQs](https://github.com/efabless/openlane/wiki)

## Command line arguments

The following are arguments that can be passed to `flow.tcl`

<table>
    <tr>
        <th width="196">
        Argument
        </th>
        <th >
        Description
        </th>
    </tr>
    <tr>
        <td align="center">
            <code>-design &lt;folder path&gt;</code> <br> (Required)
        </td>
        <td align="justify">
            Specifies the design folder. A design folder should contain a config.tcl defining the design parameters. <br> If the folder is not found, ./designs directory is searched
        </td>
    </tr>
    <tr>
        <td align="center">
            <code>-config_file &lt;file&gt;</code> <br> (Optional)
        </td>
        <td align="justify">
            Specifies the design's configuration file for running the flow. <br> For example, to run the flow using <code>/spm/config2.tcl</code> <br> Use run <code>./flow.tcl -design /spm -config_file /spm/config2.tcl</code> <br> By default <code>config.tcl</code> is used.
        </td>
    </tr>
        <tr>
        <td align="center">
            <code>-config_tag &lt;name&gt;</code> <br> (Optional)
        </td>
        <td align="justify">
            Specifies the design's configuration file for running the flow. <br> For example, to run the flow using <code>designs/spm/config2.tcl</code> <br> Use run <code>./flow.tcl -design spm -config_tag config2.tcl</code> <br> By default <code>config.tcl</code> is used.
        </td>
    </tr>
    <tr>
        </tr>
        <td align="center">
            <code>-tag &lt;name&gt;</code> <br> (Optional)
        </td>
        <td align="justify">
            Specifies a <code>name</code> for a specific run. If the tag is not specified, a timestamp is generated for identification of that run. <br> Can Specify the configuration file name in case of using <code>-init_design_config</code>
        </td>
    </tr>
        <tr>
        </tr>
        <td align="center">
            <code>-run_path &lt;path&gt;</code> <br> (Optional)
        </td>
        <td align="justify">
            Specifies a <code>path</code> to save the run in. By default the run is in <code>design_path/</code>, where the design path is the one passed to <code>-design</code>
        </td>
    </tr>
        <tr>
        </tr>
        <td align="center">
            <code>-save <br> (Optional)
        </td>
        <td align="justify">
            A flag to save a runs results like .mag and .lef in the design's folder
        </td>
    </tr>
        <tr>
        </tr>
        <td align="center">
            <code>-save_path &lt;path&gt;</code> <br> (Optional)
        </td>
        <td align="justify">
            Specifies a different path to save the design's result. This options is to be used with the <code>-save</code> flag
        </td>
    </tr>
    <tr>
        </tr>
        <td align="center">
            <code>-src &lt;verilog_source_file&gt; </code> <br> (Optional)
        </td>
        <td td align="justify">
            Sets the verilog source code file(s) in case of using `-init_design_config`. <br> The default is that the source code files are under <code>design_path/src/</code>, where the design path is the one passed to <code>-design</code>
        </td>
    </tr>
    <tr>
        </tr>
        <td align="center">
            <code>-init_design_config </code> <br> (Optional)
        </td>
        <td td align="justify">
            Creates a tcl configuration file for a design. <code>-tag &lt;name&gt;</code> can be added to rename the config file to <code>&lt;name&gt;.tcl</code>
        </td>
    </tr>
    <tr>
        </tr>
        <td align="center">
            <code>-overwrite</code> <br> (Optional)
        </td>
        <td align="justify">
            Flag to overwirte an existing run with the same tag
        </td>
    </tr>
    <tr>
        </tr>
        <td align="center">
            <code>-interactive</code> <br> (Optional)
        </td>
        <td align="justify">
            Flag to run openlane flow in interactive mode
        </td>
    </tr>
    <tr>
        </tr>
        <td align="center">
            <code>-file &lt;file_path&gt;</code> <br> (Optional)
        </td>
        <td align="justify">
            Passes a script of interactive commands in interactive mode
        </td>
    </tr>
</table>


## Adding a design

To add a new design, follow the instructions provided [here](./designs/README.md)

This [file](./designs/README.md) also includes useful information about the design configuration files. It also includes useful utilities for exploring and updating design configurations for each (PDK,STD_CELL_LIBRARY) pair.

# OpenLANE Architecture

<table>
  <tr>
    <td  align="center"><img src="./doc/openlane.flow.1.png" ></td>
  </tr>

</table>


## OpenLANE Design Stages

OpenLANE flow consists of several stages. By default all flow steps are run in sequence. Each stage may consist of multiple sub-stages. OpenLANE can also be run interactively as shown [here][25].

1. **Synthesis**
    1. `yosys` - Performs RTL synthesis
    2. `abc` - Performs technology mapping
    3. `OpenSTA` - Pefroms static timing analysis on the resulting netlist to generate timing reports
2. **Floorplan and PDN**
    1. `init_fp` - Defines the core area for the macro as well as the rows (used for placement) and the tracks (used for routing)
    2. `ioplacer` - Places the macro input and output ports
    3. `pdn` - Generates the power distribution network
    4. `tapcell` - Inserts welltap and decap cells in the floorplan
3. **Placement**
    1. `RePLace` - Performs global placement
    2. `Resizer` - Performs optional optimizations on the design
    3. `OpenPhySyn` - Performs timing optimizations on the design
    4. `OpenDP` - Perfroms detailed placement to legalize the globally placed components
4. **CTS**
    1. `TritonCTS` - Synthesizes the clock distribution network (the clock tree)
5. **Routing** *
    1. `FastRoute` - Performs global routing to generate a guide file for the detailed router
    2. `TritonRoute` - Performs detailed routing
    3. `SPEF-Extractor` - Performs SPEF extraction
6. **GDSII Generation**
    1. `Magic` - Streams out the final GDSII layout file from the routed def
7. **Checks**
    1. `Magic` - Performs DRC Checks & Antenna Checks
    2. `Netgen` - Performs LVS Checks

OpenLANE integrated several key open source tools over the execution stages:
- RTL Synthesis, Technology Mapping, and Formal Verification : [yosys + abc][4]
- Static Timing Analysis: [OpenSTA][8]
- Floor Planning: [init_fp][5], [ioPlacer][6], [pdn][16] and [tapcell][7]
- Placement: [RePLace][9] (Global), [Resizer][15] and [OpenPhySyn][28] (Optimizations), and [OpenDP][10] (Detailed)
- Clock Tree Synthesis: [TritonCTS][11]
- Fill Insertion: [OpenDP/filler_placement][10]
- Routing: [FastRoute][12] (Global) and [TritonRoute][13] (Detailed)
- SPEF Extraction: [SPEF-Extractor][27]
- GDSII Streaming out: [Magic][14]
- DRC Checks: [Magic][14]
- LVS check: [Netgen][22]
- Antenna Checks: [Magic][14]

## OpenLANE Output

All output run data is placed by default under ./designs/design_name/runs. Each flow cycle will output timestamp-marked foler containing the following file structure:

```
designs/<design_name>
├── config.tcl
├── runs
│   ├── <tag>
│   │   ├── config.tcl
│   │   ├── logs
│   │   │   ├── cts
│   │   │   ├── floorplan
│   │   │   ├── magic
│   │   │   ├── placement
│   │   │   ├── routing
│   │   │   └── synthesis
│   │   ├── reports
│   │   │   ├── cts
│   │   │   ├── floorplan
│   │   │   ├── magic
│   │   │   ├── placement
│   │   │   ├── routing
│   │   │   └── synthesis
│   │   ├── results
│   │   │   ├── cts
│   │   │   ├── floorplan
│   │   │   ├── magic
│   │   │   ├── placement
│   │   │   ├── routing
│   │   │   └── synthesis
│   │   └── tmp
│   │       ├── cts
│   │       ├── floorplan
│   │       ├── magic
│   │       ├── placement
│   │       ├── routing
│   │       └── synthesis
```

To delete all generated runs under all designs:
- inside the docker:
    ```bash
        ./clean_runs.tcl
    ```
- outside the docker:
    ```bash
        make clean_runs
    ```

## Flow configuration

1. PDK / technology specific
2. Flow specific
3. Design specific

- A PDK should define at least one standard cell library(SCL) for the PDK. A common configuration file for all SCLs is located in:

    ```
    $PDK_ROOT/$PDK/config.tcl
    ```

    - Sometimes the PDK comes with several standard cell libraries. Each has an own configuration file that defines extra variables specific to the SCL. It may also override variables in the common PDK configuration file which is located in:

        ```
        $PDK_ROOT/$PDK/$STD_CELL_LIBRARY/config.tcl
        ```
    - More on configuring a new PDK in this [section](#setting-up-the-pdk-skywater-pdk)

- Flow specific variables are related to the flow and are initialized with default values in:

    ```
    ./configuration/
    ```

- Finally, each design should have it's own configuration file with some required variables which are available in this [list][17]. A design configuration file may override any of the variables defined in PDK or flow configuration files. This is the global configurations for the design:

    ```
    ./designs/<design>/config.tcl
    ```
    - More on design configurations in [here](./designs/README.md)

A list of all available variables can be found [here][17].



# Regression And Design Configurations Exploration

As mentioned earlier, everytime a new design or a new (PDK,STD_CELL_LIBRARY) pair is added, or any update happens in the flow tools, a re-configuration for the designs is needed. The reconfiguration is methodical and so an exploration script was developed to aid the designer in reconfiguring his designs if needed.
As explained [here](#adding-a-design) that each design has multiple configuration files for each (PDK,STD_CELL_LIBRARY) pair.

## Overview
OpenLANE provides `run_designs.py`, a script that can do multiple runs in a parallel using different configurations. A run consists of a set of designs and a configuration file that contains the configuration values. It is useful to explore the design implementation using different configurations to figure out the best one(s).

Also, it can be used for testing the flow by running the flow against several designs using their best configurations. For example the following run: spm using its default configuration files `config.tcl.` :
```
python3 run_designs.py --designs spm xtea md5 aes256 --tag test --threads 3
```

For more information on how to run this script, refer to this [file][21]

For more information on design configurations, how to update them, and the need for an exploration for each design, refer to this [file](./designs/README.md)

# Hardening Macros:

This is discussed in more detail [here][29].

# Chip Integration

The first step of chip integration is hardening the macros. To learn more about this check this [file][29].

Using openlane, you can produce a GDSII from a chip RTL. This is done by applying a certain methodology that we follow using our custom scripts and the integrated tools.

To learn more about Chip Integration. Check this [file][26]


[1]: ./docker_build/README.md
[2]: ./configuration/README.md
[3]: ./doc/flow.png
[4]: https://github.com/YosysHQ/yosys
[5]: https://github.com/The-OpenROAD-Project/OpenROAD/tree/master/src/init_fp
[6]: https://github.com/The-OpenROAD-Project/OpenROAD/tree/openroad/src/ioPlacer
[7]: https://github.com/The-OpenROAD-Project/OpenROAD/tree/openroad/src/tapcell
[8]: https://github.com/The-OpenROAD-Project/OpenSTA
[9]: https://github.com/The-OpenROAD-Project/OpenROAD/tree/openroad/src/replace
[10]: https://github.com/The-OpenROAD-Project/OpenROAD/tree/openroad/src/opendp
[11]: https://github.com/The-OpenROAD-Project/OpenROAD/tree/master/src/TritonCTS
[12]: https://github.com/The-OpenROAD-Project/OpenROAD/tree/openroad/src/FastRoute
[13]: https://github.com/The-OpenROAD-Project/TritonRoute
[14]: https://github.com/RTimothyEdwards/magic
[15]: https://github.com/The-OpenROAD-Project/OpenROAD/tree/openroad/src/resizer
[16]: https://github.com/The-OpenROAD-Project/OpenROAD/tree/openroad/src/pdngen
[17]: ./configuration/README.md
[18]: https://github.com/RTimothyEdwards/qflow/blob/master/src/addspacers.c
[19]: https://github.com/The-OpenROAD-Project/
[20]: https://github.com/git-lfs/git-lfs/wiki/Installation
[21]: ./regression_results/README.md
[22]: https://github.com/RTimothyEdwards/netgen
[24]: ./doc/PDK_STRUCTURE.md
[25]: ./doc/advanced_readme.md
[26]: ./doc/chip_integration.md
[27]: https://github.com/HanyMoussa/SPEF_EXTRACTOR
[28]: https://github.com/scale-lab/OpenPhySyn
[29]: ./doc/hardening_macros.md
