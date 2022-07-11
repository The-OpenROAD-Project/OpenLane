Flow Tutorial
=============

Introduction
------------

This document includes tutorials for running an entire OpenROAD-based
flow from RTL to GDSII.This tutorials includes GUI visualisation , EDA
tools,Design Explorations, and Different Design Experiments.
Additionally, a brief description of each step in the flow is provided,
facilitating the user’s comprehension and ease of usage.

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
    -  ``tap cell`` - Inserts well tap in the floor plan

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


Platform Configuration
----------------------

View the platform configuration file setup for default variable for sky130hd.

.. code-block:: shell

   ./platform/sky130hd/config.mk

The ``config.mk`` has all the required variable for the sky130hd platform and hence it is not recommended  to change any variable. View the ``sky130hd`` platform configuration `here <https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts/blob/master/flow/platforms/sky130hd/config.mk>`_.

The libraries cell information can found `here <https://antmicro-skywater-pdk-docs.readthedocs.io/en/test-submodules-in-rtd/contents/libraries.html>`_.

Design Configuration
--------------------

View the design configuration file of caravel_upw:

.. code-block:: shell

   cd OpenLane/design/caravel_upw/config.tcl

View the design configuration file `here <https://github.com/nimra471/OpenLane/tree/master/designs/caravel_upw/config.tcl>`_.

**Important**

The following design_specific Configuration are required to specify main design input such as platform, top-level design and timing constraints.

The required variables for design configuration is `here <OpenLane_Variable.html>`_.


Design Input Verilog
--------------------

The input Verilog files are located at this path:

.. code-block:: shell

   cd OpenLane/designs/caravel_upw/src/

The top-level module of design is ``user_project_wrapper.v`` available `here <https://github.com/nimra471/OpenLane/tree/master/designs/caravel_upw/src/>`_.

Running The Automatic RTL-to-GDS Flow
-------------------------------------
This section describe the complete RTL-to-GDS flow of the design. In this tutorial, user will learn both automated and interactive way to run the flow.

Design Goals:
------------

**Area**

.. code-block:: shell

   DIE_AREA= "0 0 2920 3520" (in microns)

**Timing**

.. code-block:: shell

   CLOCK_PERIOD= "10" (in ns)












