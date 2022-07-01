OpenLane
========

|License| |Documentation Status| |CI| |Slack Invite| |Python code style:
black|

OpenLane is an automated RTL to GDSII flow based on several components
including OpenROAD, Yosys, Magic, Netgen, CVC, SPEF-Extractor, CU-GR,
Klayout and a number of custom scripts for design exploration and
optimization. The flow performs full ASIC implementation steps from RTL
all the way down to GDSII.

You can find the latest release of OpenLane
`here <https://github.com/The-OpenROAD-Project/OpenLane/releases>`__.

This documentation is also available at
`ReadTheDocs <https://openlane.readthedocs.io/>`__.

Table of contents
=================

-  `Prerequisites <#prerequisites>`__
-  `Setting up OpenLane <#setting-up-openlane>`__

   -  `Installation Notes <#installation-notes>`__
   -  `Updating OpenLane <#updating-openlane>`__
   -  `Pulling or Building the OpenLane Docker
      Container <#pulling-or-building-the-openlane-docker-container>`__

-  `Running OpenLane <#running-openlane>`__

   -  `Command line arguments <#command-line-arguments>`__
   -  `Adding a design <#adding-a-design>`__

-  `OpenLane Architecture <#openlane-architecture>`__

   -  `OpenLane Design Stages <#openlane-design-stages>`__
   -  `OpenLane Output <#openlane-output>`__
   -  `Flow configuration <#flow-configuration>`__

-  `Regression And Design Configurations
   Exploration <#regression-and-design-configurations-exploration>`__
-  `Hardening Macros <#hardening-macros>`__
-  `Chip Integration <#chip-integration>`__
-  `Commands and Configurations <#commands-and-configurations>`__
-  `How To Contribute <#how-to-contribute>`__
-  `Authors <#authors>`__
-  `Additional Material <#additional-material>`__

   -  `Papers <#papers>`__
   -  `Videos And Tutorials <#videos-and-tutorials>`__

Prerequisites
=============

At a minimum:

-  GNU Make
-  Python 3.6+ with pip and virtualenv
-  Git 2.35+
-  Docker 19.03.12+

On Ubuntu, that’s…
------------------

``apt install -y build-essential python3 python3-venv python3-pip``

-  `Docker Installation
   Instructions <https://docs.docker.com/engine/install/ubuntu/>`__

On macOS, that’s…
-----------------

Get `Homebrew <https://brew.sh/>`__, then:

``brew install python make`` ``brew install --cask docker``

Containerless/Local Installations
---------------------------------

Please see `here <./docs/source/local_installs.md>`__.

Setting Up OpenLane
===================

You can set up the Sky130 PDK and OpenLane by running:

.. code:: bash

       git clone https://github.com/The-OpenROAD-Project/OpenLane.git
       cd OpenLane/
       make
       make test # This a ~5 minute test that verifies that the flow and the pdk were properly installed

-  The Makefile should do the following when you run the above:

   -  Pulls the OpenLane Docker image.
   -  Pulls and updates the PDK
   -  Test the whole setup with a complete run on a small design,
      ``spm``.

This should produce a clean run for the spm. The final layout will be
generated at this path:
``./designs/spm/runs/openlane_test/results/magic/spm.gds``.

If everything is okay, you can skip forward to `running
OpenLane <#running-openlane>`__.

Updating OpenLane
-----------------

If you already have the repo locally, then there is no need to re-clone
it. You can run the following:

.. code:: bash

       cd OpenLane/
       git checkout master
       git pull
       make 
       make test # This is to test that the flow and the pdk were properly updated

Pulling or Building the OpenLane Docker Container
-------------------------------------------------

**DISCLAIMER: This sub-section is to give you an understanding of what
happens under the hood in the Makefile. You don’t need to run the
instructions here, if you already ran ``make pull-openlane``.**

For curious users: For more details about the docker container and its
process, the `following instructions <./docker/README.md>`__ walk you
through the process of using docker containers to build the needed tools
then integrate them into OpenLane flow. **You Don’t Need To Re-Build
It.**

Building the PDK Manually
-------------------------

You don’t have to build the PDK yourself anymore. But, if you insist, or
require SCLs that are not installed by default, you can try the follow

.. code:: bash

       <configuration variables: see notes below>
       make build-pdk-conda

-  The default pdk installation directory is $PWD/pdks. If you want to
   install the PDK at a different location, you’ll need add this
   configuration variable:

   -  ``export PDK_ROOT=<absolute path to where skywater-pdk and open_pdks will reside>``

      -  Be sure to add this to your shell’s profile for future use.

-  The default SCL to be installed is ``sky130_fd_sc_hd``.

   -  To change that, you can add this configuration variable:
      ``export STD_CELL_LIBRARY=<Library name, i.e. sky130_fd_sc_ls>``,
      where the library name is one of:

      -  sky130_fd_sc_hd
      -  sky130_fd_sc_hs
      -  sky130_fd_sc_ms
      -  sky130_fd_sc_ls
      -  sky130_fd_sc_hdll

   -  You can install all Sky130 SCLs by invoking
      ``FULL_PDK=1 make build-pdk-conda``.
   -  You can install the PDK manually, outside of the Makefile, by
      following the instructions provided
      `here <./docs/source/manual_pdk_installation.md>`__.
   -  Refer to `this <./docs/source/pdk_structure.md>`__ for more
      details on OpenLane-compatible PDK structures.

Running OpenLane
================

You need to start the Docker container with proper paths mounted. There
are two ways to do this.

The easiest way to mount the proper directories into the docker
container would be to rely on the Makefile:

.. code:: bash

       make mount

-  **Note:**

   -  Default PDK_ROOT is ``$(pwd)/pdks``. If you have installed the PDK
      at a different location, run the following before ``make mount``:
      ``bash   export PDK_ROOT=<absolute path to where skywater-pdk, open_pdks, and sky130A reside>``
   -  Default OPENLANE_IMAGE_NAME is dynamically obtained using your
      current git version. If you want to use a specific image, run the
      following before ``make mount``:
      ``bash   export OPENLANE_IMAGE_NAME=<docker image name>``

The following is roughly what happens under the hood when you run
``make mount`` + the required exports:

.. code:: bash

       export PDK_ROOT=<absolute path to where skywater-pdk and open_pdks will reside>
       export OPENLANE_IMAGE_NAME=<docker image name>
       docker run -it -v $(pwd):/openlane -v $PDK_ROOT:$PDK_ROOT -e PDK_ROOT=$PDK_ROOT -u $(id -u $USER):$(id -g $USER) $OPENLANE_IMAGE_NAME

**Note: this will mount the OpenLane directory and the PDK_ROOT
directory inside the container.**

You can use the following example to check the overall setup:

.. code:: bash

   ./flow.tcl -design spm

To run OpenLane on multiple designs at the same time, check this
`section <#regression-and-design-configurations-exploration>`__.

Having trouble running the flow? check
`FAQs <https://github.com/The-OpenROAD-Project/OpenLane/wiki>`__

Command line arguments
----------------------

The following are arguments that can be passed to ``flow.tcl``

+-----------------------------------+-----------------------------------+
| Argument                          | Description                       |
+===================================+===================================+
| ``-design <folder path>``         | Specifies the design folder. A    |
| (Required)                        | design folder should contain a    |
|                                   | config.tcl defining the design    |
|                                   | parameters. If the folder is not  |
|                                   | found, ./designs directory is     |
|                                   | searched                          |
+-----------------------------------+-----------------------------------+
| ``-from <stage>`` (Optional)      | Specifies stage to start flow     |
|                                   | execution from                    |
+-----------------------------------+-----------------------------------+
| ``-to <stage>`` (Optional)        | Specifies stage to stop flow      |
|                                   | execution at (included)           |
+-----------------------------------+-----------------------------------+
| ``-config_file <file>``           | Specifies the design’s            |
| (Optional)                        | configuration file for running    |
|                                   | the flow. For example, to run the |
|                                   | flow using ``/spm/config2.tcl``   |
|                                   | Use run                           |
|                                   | ``./flow.tcl -design /spm -config |
|                                   | _file /spm/config2.tcl``          |
|                                   | By default ``config.tcl`` is      |
|                                   | used.                             |
+-----------------------------------+-----------------------------------+
| ``-override_env`` Optional        | Allows you to override certain    |
|                                   | configuration environment         |
|                                   | variables for this run. Format:   |
|                                   | ``KEY1=VALUE1,KEY2=VALUE2``       |
+-----------------------------------+-----------------------------------+
| ``-config_tag <name>`` (Optional) | Specifies the design’s            |
|                                   | configuration file for running    |
|                                   | the flow. For example, to run the |
|                                   | flow using                        |
|                                   | ``designs/spm/config2.tcl`` Use   |
|                                   | run                               |
|                                   | ``./flow.tcl -design spm -config_ |
|                                   | tag config2``                     |
|                                   | By default ``config`` is used.    |
+-----------------------------------+-----------------------------------+
| ``-tag <name>`` (Optional)        | Specifies a ``name`` for a        |
|                                   | specific run. If the tag is not   |
|                                   | specified, a timestamp is         |
|                                   | generated for identification of   |
|                                   | that run. Can Specify the         |
|                                   | configuration file name in case   |
|                                   | of using ``-init_design_config``  |
+-----------------------------------+-----------------------------------+
| ``-run_path <path>`` (Optional)   | Specifies a ``path`` to save the  |
|                                   | run in. By default the run is in  |
|                                   | ``design_path/``, where the       |
|                                   | design path is the one passed to  |
|                                   | ``-design``                       |
+-----------------------------------+-----------------------------------+
| ``-src <verilog_source_file>``    | Sets the verilog source code      |
| (Optional)                        | file(s) in case of using          |
|                                   | ``-init\_design\_config``. The    |
|                                   | default is that the source code   |
|                                   | files are under                   |
|                                   | ``design_path/src/``, where the   |
|                                   | design path is the one passed to  |
|                                   | ``-design``                       |
+-----------------------------------+-----------------------------------+
| ``-init_design_config``           | Creates a tcl configuration file  |
| (Optional)                        | for a design. ``-tag <name>`` can |
|                                   | be added to rename the config     |
|                                   | file to ``<name>.tcl``            |
+-----------------------------------+-----------------------------------+
| ``-overwrite`` (Optional)         | Flag to overwirte an existing run |
|                                   | with the same tag                 |
+-----------------------------------+-----------------------------------+
| ``-interactive`` (Optional)       | Flag to run openlane flow in      |
|                                   | interactive mode                  |
+-----------------------------------+-----------------------------------+
| ``-file <file_path>`` (Optional)  | Passes a script of interactive    |
|                                   | commands in interactive mode      |
+-----------------------------------+-----------------------------------+
| ``-synth_explore`` (Boolean)      | If enabled, synthesis exploration |
|                                   | will be run (only synthesis       |
|                                   | exploration), which will try out  |
|                                   | the available synthesis           |
|                                   | strategies against the input      |
|                                   | design. The output will be the    |
|                                   | four possible gate level netlists |
|                                   | under                             |
|                                   | <run_path/results/synthesis> and  |
|                                   | a summary report under reports    |
|                                   | that compares the 4 outputs.      |
+-----------------------------------+-----------------------------------+
| ``-lvs`` (Boolean)                | If enabled, only LVS will be run  |
|                                   | on the design. in which case the  |
|                                   | user must also pass: -design      |
|                                   | DESIGN_DIR -gds DESIGN_GDS -net   |
|                                   | DESIGN_NETLIST.                   |
+-----------------------------------+-----------------------------------+
| ``-drc`` (Boolean)                | If enabled, only DRC will be run  |
|                                   | on the design. in which case the  |
|                                   | user must also pass: -design      |
|                                   | DESIGN_DIR -gds DESIGN_GDS        |
|                                   | -report OUTPUT_REPORT_PATH        |
|                                   | -magicrc MAGICRC.                 |
+-----------------------------------+-----------------------------------+
| ``-save`` (Optional)              | A flag to save a runs results     |
|                                   | like .mag and .lef in the         |
|                                   | design’s folder.                  |
+-----------------------------------+-----------------------------------+
| ``-save_path <path>`` (Optional)  | Specifies a different path to     |
|                                   | save the design’s result. This    |
|                                   | option is to be used with the     |
|                                   | ``-save`` flag.                   |
+-----------------------------------+-----------------------------------+

Adding a design
---------------

To add a new design, follow the instructions provided
`here <./designs/README.md>`__

This `file <./designs/README.md>`__ also includes useful information
about the design configuration files. It also includes useful utilities
for exploring and updating design configurations for each
(PDK,STD_CELL_LIBRARY) pair.

OpenLane Architecture
=====================

.. raw:: html

   <table>

.. raw:: html

   <tr>

.. raw:: html

   <td align="center">

.. raw:: html

   </td>

.. raw:: html

   </tr>

.. raw:: html

   </table>

OpenLane Design Stages
----------------------

OpenLane flow consists of several stages. By default all flow steps are
run in sequence. Each stage may consist of multiple sub-stages. OpenLane
can also be run interactively as shown
`here <./docs/source/advanced_readme.md>`__.

1. **Synthesis**

   1. ``yosys`` - Performs RTL synthesis
   2. ``abc`` - Performs technology mapping
   3. ``OpenSTA`` - Performs static timing analysis on the resulting
      netlist to generate timing reports

2. **Floorplan and PDN**

   1. ``init_fp`` - Defines the core area for the macro as well as the
      rows (used for placement) and the tracks (used for routing)
   2. ``ioplacer`` - Places the macro input and output ports
   3. ``pdn`` - Generates the power distribution network
   4. ``tapcell`` - Inserts welltap and decap cells in the floorplan

3. **Placement**

   1. ``RePLace`` - Performs global placement
   2. ``Resizer`` - Performs optional optimizations on the design
   3. ``OpenDP`` - Perfroms detailed placement to legalize the globally
      placed components

4. **CTS**

   1. ``TritonCTS`` - Synthesizes the clock distribution network (the
      clock tree)

5. **Routing**

   1. ``FastRoute`` - Performs global routing to generate a guide file
      for the detailed router
   2. ``CU-GR`` - Another option for performing global routing.
   3. ``TritonRoute`` - Performs detailed routing
   4. ``SPEF-Extractor`` - Performs SPEF extraction

6. **GDSII Generation**

   1. ``Magic`` - Streams out the final GDSII layout file from the
      routed def
   2. ``Klayout`` - Streams out the final GDSII layout file from the
      routed def as a back-up

7. **Checks**

   1. ``Magic`` - Performs DRC Checks & Antenna Checks
   2. ``Klayout`` - Performs DRC Checks
   3. ``Netgen`` - Performs LVS Checks
   4. ``CVC`` - Performs Circuit Validity Checks

OpenLane integrated several key open source tools over the execution
stages: - RTL Synthesis, Technology Mapping, and Formal Verification :
`yosys + abc <https://github.com/YosysHQ/yosys>`__ - Static Timing
Analysis: `OpenSTA <https://github.com/The-OpenROAD-Project/OpenSTA>`__
- Floor Planning:
`init_fp <https://github.com/The-OpenROAD-Project/OpenROAD/tree/master/src/ifp>`__,
`ioPlacer <https://github.com/The-OpenROAD-Project/OpenROAD/tree/master/src/ppl>`__,
`pdn <https://github.com/The-OpenROAD-Project/OpenROAD/tree/master/src/pdn>`__
and
`tapcell <https://github.com/The-OpenROAD-Project/OpenROAD/tree/master/src/tap>`__
- Placement:
`RePLace <https://github.com/The-OpenROAD-Project/OpenROAD/tree/master/src/replace>`__
(Global),
`Resizer <https://github.com/The-OpenROAD-Project/OpenROAD/tree/master/src/rsz>`__
and `OpenPhySyn <https://github.com/scale-lab/OpenPhySyn>`__ (formerly),
and
`OpenDP <https://github.com/The-OpenROAD-Project/OpenROAD/tree/master/src/dpl>`__
(Detailed) - Clock Tree Synthesis:
`TritonCTS <https://github.com/The-OpenROAD-Project/OpenROAD/tree/master/src/cts>`__
- Fill Insertion:
`OpenDP/filler_placement <https://github.com/The-OpenROAD-Project/OpenROAD/tree/master/src/dpl>`__
- Routing:
`FastRoute <https://github.com/The-OpenROAD-Project/OpenROAD/tree/master/src/grt>`__
or `CU-GR <https://github.com/cuhk-eda/cu-gr>`__ (Global) and
`TritonRoute <https://github.com/The-OpenROAD-Project/OpenROAD/tree/master/src/TritonRoute>`__
(Detailed) - SPEF Extraction:
`SPEF-Extractor <https://github.com/HanyMoussa/SPEF_EXTRACTOR>`__
(formerly),
`OpenRCX <https://github.com/The-OpenROAD-Project/OpenROAD/tree/master/src/rcx>`__
- GDSII Streaming out:
`Magic <https://github.com/RTimothyEdwards/magic>`__ and
`Klayout <https://github.com/KLayout/klayout>`__ - DRC Checks:
`Magic <https://github.com/RTimothyEdwards/magic>`__ and
`Klayout <https://github.com/KLayout/klayout>`__ - LVS check:
`Netgen <https://github.com/RTimothyEdwards/netgen>`__ - Antenna Checks:
`Magic <https://github.com/RTimothyEdwards/magic>`__ - Circuit Validity
Checker: `CVC <https://github.com/d-m-bailey/cvc>`__

OpenLane Output
---------------

All output run data is placed by default under
./designs/design_name/runs. Each flow cycle will output a
timestamp-marked folder containing the following file structure:

::

   designs/<design_name>
   ├── config.tcl
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

To delete all generated runs under all designs: ``make clean_runs``

Flow configuration
------------------

1. PDK / technology specific
2. Flow specific
3. Design specific

-  A PDK should define at least one standard cell library(SCL) for the
   PDK. A common configuration file for all SCLs is located in:

   ::

      $PDK_ROOT/$PDK/config.tcl

   -  Sometimes the PDK comes with several standard cell libraries. Each
      has an own configuration file that defines extra variables
      specific to the SCL. It may also override variables in the common
      PDK configuration file which is located in:

      ::

         $PDK_ROOT/$PDK/$STD_CELL_LIBRARY/config.tcl

   -  More on configuring a new PDK in this
      `section <#setting-up-OpenLane>`__

-  Flow specific variables are related to the flow and are initialized
   with default values in:

   ::

      ./configuration/

-  Finally, each design should have it’s own configuration file with
   some required variables which are available in this
   `list <./configuration/README.md>`__. A design configuration file may
   override any of the variables defined in PDK or flow configuration
   files. This is the global configurations for the design:

   ::

      ./designs/<design>/config.tcl

   -  More on design configurations in `here <./designs/README.md>`__

A list of all available variables can be found
`here <./configuration/README.md>`__.

Regression And Design Configurations Exploration
================================================

As mentioned earlier, everytime a new design or a new
(PDK,STD_CELL_LIBRARY) pair is added, or any update happens in the flow
tools, a re-configuration for the designs is needed. The reconfiguration
is methodical and so an exploration script was developed to aid the
designer in reconfiguring his designs if needed. As explained
`here <#adding-a-design>`__ that each design has multiple configuration
files for each (PDK,STD_CELL_LIBRARY) pair.

OpenLane provides ``run_designs.py``, a script that can do multiple runs
in a parallel using different configurations. A run consists of a set of
designs and a configuration file that contains the configuration values.
It is useful to explore the design implementation using different
configurations to figure out the best one(s).

Also, it can be used for testing the flow by running the flow against
several designs using their best configurations. For example the
following run: spm using its default configuration files ``config.tcl.``
:

::

   python3 run_designs.py --tag test --threads 3 spm xtea md5 aes256 

For more information on how to run this script, refer to this
`file <./regression_results/README.md>`__

OpenLane also has flow for issue regression testing. Refer to this
`document <./docs/source/issue_regression_tests.md>`__.

For more information on design configurations, how to update them, and
the need for an exploration for each design, refer to this
`file <./designs/README.md>`__

Hardening Macros
================

This is discussed in more detail
`here <./docs/source/hardening_macros.md>`__.

Chip Integration
================

The first step of chip integration is hardening the macros. To learn
more about this check this `file <./docs/source/hardening_macros.md>`__.

Using OpenLane, you can produce a GDSII from a chip RTL. This is done by
applying a certain methodology that we follow using our custom scripts
and the integrated tools.

To learn more about Chip Integration. Check this
`file <./docs/source/chip_integration.md>`__

Commands and Configurations
===========================

To get a full list of the OpenLane commands, first introduce yourself to
the interactive mode of OpenLane
`here <./docs/source/advanced_readme.md>`__. Then check the full
documentation of the OpenLane commands
`here <./docs/source/openlane_commands.md>`__.

The full documentation of OpenLane run configurations could be found
`here <./configuration/README.md>`__.

How To Contribute
=================

We discuss the details of how to contribute to OpenLane in `this
documentation <./CONTRIBUTING.md>`__.

Authors
=======

To check the original author list of OpenLane, check
`this <./AUTHORS.md>`__.

Additional Material
===================

Papers
------

-  Ahmed Ghazy and Mohamed Shalan, “OpenLANE: The Open-Source Digital
   ASIC Implementation Flow”, Article No.21, Workshop on Open-Source EDA
   Technology (WOSET), 2020.
   `Paper <https://github.com/woset-workshop/woset-workshop.github.io/blob/master/PDFs/2020/a21.pdf>`__
-  M. Shalan and T. Edwards, “Building OpenLANE: A 130nm OpenROAD-based
   Tapeout- Proven Flow : Invited Paper,” 2020 IEEE/ACM International
   Conference On Computer Aided Design (ICCAD), San Diego, CA, USA,
   2020, pp. 1-6.
   `Paper <https://ieeexplore.ieee.org/document/9256623/>`__
-  R. Timothy Edwards, M. Shalan and M. Kassem, “Real Silicon using Open
   Source EDA,” in IEEE Design & Test, doi: 10.1109/MDAT.2021.3050000.
   `Paper <https://ieeexplore.ieee.org/document/9336682>`__

Videos and Tutorials
--------------------

OpenLane Specific
~~~~~~~~~~~~~~~~~

-  `FOSSi Dial-Up - OpenLane, A Digital ASIC Flow for SkyWater 130nm
   Open PDK, Mohamed
   Shalan <https://www.youtube.com/watch?v=Vhyv0eq_mLU>`__
-  `Openlane Overview, Ahmed
   Ghazy <https://www.youtube.com/watch?v=d0hPdkYg5QI>`__
-  `Free VLSI Tutorial - VSD - A complete guide to install Openlane and
   Sky130nm
   PDK <https://www.udemy.com/course/vsd-a-complete-guide-to-install-openlane-and-sky130nm-pdk>`__
-  `Sky130 - Exploring OpenLANE and OpenDB to create a register file ,
   Sylvain Munaut <https://www.youtube.com/watch?v=AT_LcmaCZmw>`__
-  `VLSI SoC EDA openLANE with Skywater 130 PDK, Gary
   Huang <https://www.youtube.com/watch?v=QnJzoJjC7RQ>`__

Caravel & SkyWater PDK
~~~~~~~~~~~~~~~~~~~~~~

-  `Aboard Caravel, Ahmed
   Ghazy <https://www.youtube.com/watch?v=9QV8SDelURk>`__
-  `FOSSi Dial-Up - Skywater PDK: Fully open source manufacturable PDK
   for a 130nm process, Tim
   Ansell <https://www.youtube.com/watch?v=EczW2IWdnOM&>`__
-  `Skywater 130nm PDK - Initial Discovery, Sylvain
   Munaut <https://www.youtube.com/watch?v=gRYBdTXbxiU>`__

.. |License| image:: https://img.shields.io/badge/License-Apache%202.0-blue.svg
   :target: https://opensource.org/licenses/Apache-2.0
.. |Documentation Status| image:: https://readthedocs.org/projects/openlane/badge/?version=latest
   :target: https://openlane.readthedocs.io/
.. |CI| image:: https://github.com/The-OpenROAD-Project/OpenLane/workflows/CI/badge.svg?branch=master
   :target: #
.. |Slack Invite| image:: https://img.shields.io/badge/Community-Skywater%20PDK%20Slack-ff69b4?logo=slack
   :target: https://invite.skywater.tools
.. |Python code style: black| image:: https://img.shields.io/badge/python%20code%20style-black-000000.svg
   :target: https://github.com/psf/black
