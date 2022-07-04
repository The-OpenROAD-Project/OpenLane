Flow Tutorial
=============

Introduction
------------

This document includes tutorials for running an entire OpenROAD-based
flow from RTL to GDSII.This tutorials includes GUI visualisation , EDA
tools,Design Explorations, and Different Design Experiments.
Additionally, a brief description of each step in the flow is provided,
facilitating the user’s comprehension and ease of usage.

Overview Of OpenLane Flow
-------------------------

.. image:: ../_static/OpenLane flow.png

PDK Support
-----------

The major component of physical design is PDK (Process Design Kit). The
OpenROAD application is PDK independent. However it is tested and
validated with specific PDKs in the context of various flow controllers.

The OpenROAD supports both public and private PDKs including:

Open Source PDK
---------------

-  Skywater 130 nm
-  Nangate45
-  ASAP7 - Predictive FinFET 7nm

Proprietary PDKs
----------------

These PDKS are supported in OpenROAD-flow-scripts only. They are used to
test and calibrate OpenROAD against commercial platforms and ensure good
QoR. The PDKs and platform-specific files for these kits cannot be
provided due to NDA restrictions. However, if you are able to access
these platforms independently, you can create the necessary
platform-specific files yourself. - GF55 - 55nm - GF12 - 12nm - GF180 -
180nm - Intel22 - 22nm - Intel16 - 16nm - TSMC65 - 65nm

OpenLane with SkyWater Sky130-PDK
---------------------------------

The SkyWater Open Source PDK is a collaboration between Google and
SkyWater Technology Foundry to provide a fully open source Process
Design Kit and related resources, which can be used to create
manufacturable designs at SkyWater’s facility.

The SkyWater Open Source PDK documentation can be found at
`SkyWater <https://skywater-pdk.rtfd.io>`__

Open Source Tools:
------------------

The OpenRoad Openlane is a automated RTL to GDSII flow build around open
source tool. The flow perform the auto place and route of an ASIC design
-in 24 hours with no human in the loop. Tool used in OpenLane are listed
below:

1.  **Synthesis**

    -  ``yosys`` - Performs RTL synthesis
    -  ``abc`` - Performs technology mapping
    -  ``OpenSTA`` - Performs static timing analysis on the resulting
       netlist to generate timing reports

2.  **Floor planning**

    -  ``init_fp`` - Defines the core area for the macro as well as the
       rows (used for placement) and the tracks (used for routing)
    -  ``ioplacer`` - Places the macro input and output ports
    -  ``pdn`` - Generates the power distribution network
    -  ``tap cell`` - Inserts well tap in the floorplan

3.  **Placement**

    -  ``RePLace`` - Performs global placement
    -  ``Resizer`` - Performs optional optimizations on the design
    -  ``OpenDP`` - Performs detailed placement to legalize the globally
       placed components

4.  **Clock Tree Synthesis**

    -  ``TritonCTS`` - Synthesizes the clock distribution network (the
       clock tree)

5.  **Routing**

    -  ``FastRoute`` - Performs global routing to generate a guide file
       for the detailed router
    -  ``CU-GR`` - Another option for performing global routing.
    -  ``TritonRoute`` - Performs detailed routing
    -  ``SPEF-Extractor`` - Performs SPEF extraction

6.  **GDSII Generation**

    -  ``Magic`` - Streams out the final GDSII layout file from the
       routed def
    -  ``Klayout`` - Streams out the final GDSII layout file from the
       routed def as a back-up

7.  **Checks**

    -  ``Magic``- Performs DRC Checks & Antenna Checks
    -  ``Klayout`` - Performs DRC Checks
    -  ``Netgen`` - Performs LVS Checks 

Setting Up New Design
---------------------

To setup the design, follow the instructions given below:

1.  Make a directtory of your design in openlane/design/ using the
    command: 
.. code-block:: console

   mkdir design_name

2.  Go in the OpenLane Directory and run command

.. code-block:: console

   make mount


3. To Generate the config.tcl file in the docker using command

.. code-block:: console

   ./flow.tcl -design ”your design name” -init_design_config


4.  Exit and Go to the directory to check generate the config.tcl

The OpenLane flow RTL to GDSII run in two mode defined below:

**Interactive Mode** will run the OpenLane in a interactive mode where
every steps of a design run by the user .

using command to enter in a interactive mode

::

     ./flow.tcl -interactive
      %prep -design <design_name> # will configure the selected cell for a design by merging LEF file
      run_synthesis
      run_floorplan
      run_placement
      run_cts
      run_routing
      write_powered_verilog
      run_magic
      run_magic_spice_export 
      run_magic_drc      

**Non Interactive Mode** automatically run every steps of flow

using command to enter in a non interactive mode

::

   ./flow.tcl  -design <design_name>  -tag <tag>

OpenLane Structure
------------------

::

   designs/<spm>
   ├── config.tcl
   ├── runs
   │── src
   │   ├──spm.v
   Configuration
   ├──general.tcl
   ├──Synthesis.tcl
   ├──Floorplan.tcl
   ├──Placement.tcl
   ├──Cts.tcl
   │──Routing.tcl
   Script
   │   ├── tcl_command
   │   │   │   ├──general.tcl
   │   │   │   ├──synthesis.tcl
   │   │   │   ├── floorplan.tcl
   │   │   │   ├── placement.tcl
   │   │   │   ├── cts.tcl
   │   │   │   └── routing.tcl

Runs Structure
--------------

::


   designs/spm
   ├── config.tcl
   ├── src
   ├── runs
   │   ├── run1
   │   │   ├── config.tcl
   │   │   ├── logs
   │   │   │   ├── cts
   │   │   │   ├── cvc
   │   │   │   ├── floorplan
   │   │   │   ├── klayout
   │   │   │   ├── magic
   │   │   │   ├── placement
   │   │   │   ├── routing
   │   │   │   └── synthesis
   │   │   ├── reports
   │   │   │   ├── cts
   │   │   │   ├── cvc
   │   │   │   ├── floorplan
   │   │   │   ├── klayout
   │   │   │   ├── magic
   │   │   │   ├── placement
   │   │   │   ├── routing
   │   │   │   └── synthesis
   │   │   ├── results
   │   │   │   ├── cts
   │   │   │   ├── cvc
   │   │   │   ├── floorplan
   │   │   │   ├── klayout
   │   │   │   ├── magic
   │   │   │   ├── placement
   │   │   │   ├── routing
   │   │   │   └── synthesis
   │   │   └── tmp
   │   │       ├── cts
   │   │       ├── cvc
   │   │       ├── floorplan
   │   │       ├── klayout
   │   │       ├── magic
   │   │       ├── placement
   │   │       ├── routing
   │   │       └── synthesis


Platform Configuration
----------------------

Design Configuration
--------------------

Design Input Verilog
--------------------
