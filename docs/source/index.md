# The OpenLane Documentation
OpenLane is an automated RTL to GDSII flow based on several components including OpenROAD, Yosys, Magic, Netgen, CVC, SPEF-Extractor, KLayout and a number of custom scripts for design exploration and optimization. It also provides a number of custom scripts for design exploration, optimization and ECO.

The flow performs all ASIC implementation steps from RTL all the way down to GDSII. Currently, it supports both A and B variants of the sky130 PDK, but support for the newly released GF180MCU PDK is in the works, and instructions to add support for other (including proprietary) PDKs are documented.

OpenLane abstracts the underlying open source utilities, and allows users to configure all their behavior with just a single configuration file.

Check the sidebar to the left to get started.

```{toctree}
getting_started/index
flow_overview
usage/index
for_developers/index
reference/index
additional_material
authors
```
