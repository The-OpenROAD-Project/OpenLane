Introduction
============

This document includes tutorials for running an entire OpenROAD-based
flow from RTL to GDSII.This tutorials includes GUI visualisation , EDA
tools,Design Explorations, and Different Design Experiments.
Additionally, a brief description of each step in the flow is provided,
facilitating the user’s comprehension and ease of usage.

Overview Of OpenLane Flow
=========================

.. figure:: https://user-images.githubusercontent.com/81620928/176864059-abbe30c5-034e-419a-9a4e-da068d1d1a12.png
   :alt: image

   image

PDK Support
===========

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

OpenLane with Google-SKY130-PDK
-------------------------------

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

1. **Synthesis**

   -  ``yosys`` - Performs RTL synthesis
   -  ``abc`` - Performs technology mapping
   -  ``OpenSTA`` - Performs static timing analysis on the resulting
      netlist to generate timing reports

2. **Floor planning**

   -  ``init_fp`` - Defines the core area for the macro as well as the
      rows (used for placement) and the tracks (used for routing)
   -  ``ioplacer`` - Places the macro input and output ports
   -  ``pdn`` - Generates the power distribution network
   -  ``tap cell`` - Inserts well tap in the floorplan

3. **Placement**

   -  ``RePLace`` - Performs global placement
   -  ``Resizer`` - Performs optional optimizations on the design
   -  ``OpenDP`` - Performs detailed placement to legalize the globally
      placed components

4. **Clock Tree Synthesis**

   -  ``TritonCTS`` - Synthesizes the clock distribution network (the
      clock tree)

5. **Routing**

   -  ``FastRoute`` - Performs global routing to generate a guide file
      for the detailed router
   -  ``CU-GR`` - Another option for performing global routing.
   -  ``TritonRoute`` - Performs detailed routing
   -  ``SPEF-Extractor`` - Performs SPEF extraction

6. **GDSII Generation**

   -  ``Magic`` - Streams out the final GDSII layout file from the
      routed def
   -  ``Klayout`` - Streams out the final GDSII layout file from the
      routed def as a back-up

7. **Checks**

   -  ``Magic``- Performs DRC Checks & Antenna Checks
   -  ``Klayout`` - Performs DRC Checks
   -  ``Netgen`` - Performs LVS Checks
