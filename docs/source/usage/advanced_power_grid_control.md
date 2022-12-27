> Note: Information in this document may be out of date. It is always a good idea to take a look at the canonical documentation for OpenROAD's pdngen utility: https://openroad.readthedocs.io/en/latest/main/src/pdn/README.html

# Power Grid/Power Distribution Network

In this document we will discuss the advanced controls for power grid, and how to utilize the default PDN script to automatically power a complex design without the need to write a custom `pdn.tcl` script or learning `pdngen` tool syntax.

The power decision flow in this document will go top to bottom, meaning that we will start at the chip level and then go down to the internal macros.

An example utilizing the controls and logic provided in this documentation is [caravel](https://github.com/efabless/caravel).

> **Note**: When we say "your configurations" in this documentation we are refering to the `config.json` or `config.tcl` for that specific block.

## Chip Level

According to the current methodology of [OpenLane Chip Integration][0], the process goes as follows:
1. Hardening the hard/internal macros.
2. Hardening the core with the hard macros inside it.
3. Hardening the full chip with the padframe and the chip core.

Therefore at the top level typically you only have the core block. All you need to do in that step is to verify that the power pads are in the middle of each padframe side, and then add this line to your interactive script: `power_routing` After legalization and before signal routing. However, this only supports a single power domain. Otherwise, you need to manually connect the power pads to the core ring of your core module.

## Core Level

Let us clarify here, before delving into details, that with each hierarchy level you lose one routing metal layer. For example, in the skywater pdk the metal stack has 5 layers, thus for the core level you can use all layers up to met5; however, if you have another macro inside your core, that macro can only use up to met4, and so forth.

The first decision to make at the core level is the core ring. So first, you need to know how many power domains do you need to use, and so how many core rings do you require. This can be easily set by the following configurations:

<table>
<tr><th>JSON</th><th>Tcl</th></tr>
<tr>
<td>
    
```json
    "DESIGN_IS_CORE": true,
    "FP_PDN_CORE_RING": true,
    "VDD_NETS": "vccd1 vccd2 vdda1 cdda2",
    "GND_NETS": "vssd1 vssd2 vssa1 vssa2",
    "SYNTH_USE_PG_PINS_DEFINES": "USE_POWER_PINS"

```


</td>
<td>

```tcl
set ::env(DESIGN_IS_CORE) 1
set ::env(FP_PDN_CORE_RING) 1
set ::env(VDD_NETS) [list {vccd1} {vccd2} {vdda1} {vdda2}]
set ::env(GND_NETS) [list {vssd1} {vssd2} {vssa1} {vssa2}]
set ::env(SYNTH_USE_PG_PINS_DEFINES) "USE_POWER_PINS"
```

</td>
</tr>
</table>

Here we are requiring 4 power domains. For each `VDD_NETS` there is a corresponding `GND_NETS`. Those net names must also exist in the RTL and must be connected to each hard macro inside your core explicitly in the RTL, and those must be guarded with the value given to `SYNTH_USE_PG_PINS_DEFINES`. If the internal modules are going to be flattened, then there is no need to reflect this connection in the RTL for those modules that will be flattened with the core module. For the example above, Here is the required RTL reflection:

```verilog
`ifdef USE_POWER_PINS
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground
`endif
```

Then for the hard macro instatiations:

```verilog
`ifdef USE_POWER_PINS
	.vdda1(vdda1),	// User area 1 3.3V power
	.vdda2(vdda2),	// User area 2 3.3V power
	.vssa1(vssa1),	// User area 1 analog ground
	.vssa2(vssa2),	// User area 2 analog ground
	.vccd1(vccd1),	// User area 1 1.8V power
	.vccd2(vccd2),	// User area 2 1.8V power
	.vssd1(vssd1),	// User area 1 digital ground
	.vssd2(vssd2),	// User area 2 digital ground
    `endif
```
Note that net and pin names must be matching.

By simply adding these you should now have 8 core rings, 4 for power and 4 for ground. To control the spacing and the power grid for these by changing the following:

<table>
<tr><th>JSON</th><th>Tcl</th></tr>
<tr>
<td>
    
```json
    "FP_PDN_CORE_RING_VWIDTH": 3,
    "FP_PDN_CORE_RING_HWIDTH": "expr::$FP_PDN_CORE_RING_VWIDTH",
    "FP_PDN_CORE_RING_VOFFSET": 14,
    "FP_PDN_CORE_RING_HOFFSET" "expr::$FP_PDN_CORE_RING_VOFFSET",
    "FP_PDN_CORE_RING_VSPACING": 1.7,
    "FP_PDN_CORE_RING_HSPACING": "expr::$FP_PDN_CORE_RING_VSPACING"
```


</td>
<td>

```tcl
set ::env(FP_PDN_CORE_RING_VWIDTH) 3 # The vertical sides width of the core rings
set ::env(FP_PDN_CORE_RING_HWIDTH) $::env(FP_PDN_CORE_RING_VWIDTH) # The horizontal sides width of the core rings
set ::env(FP_PDN_CORE_RING_VOFFSET) 14 # The vertical sides offset from the design boundaries for the core rings
set ::env(FP_PDN_CORE_RING_HOFFSET) $::env(FP_PDN_CORE_RING_VOFFSET) # The horizontal sides offset from the design boundaries for the core rings
set ::env(FP_PDN_CORE_RING_VSPACING) 1.7 # The vertical spacing between the core ring straps
set ::env(FP_PDN_CORE_RING_HSPACING) $::env(FP_PDN_CORE_RING_VSPACING) # The horizontal spacing between the core ring straps
```

</td>
</tr>
</table>



The next values should be added as-is to control the starting point for looping over the core rings and recalculating the new offset for each core ring:

<table>
<tr><th>JSON</th><th>Tcl</th></tr>
<tr>
<td>
    
```json
    "FP_PDN_VSPACING": "expr::5*$FP_PDN_CORE_RING_VWIDTH",
    "FP_PDN_HSPACING": "expr::5*$FP_PDN_CORE_RING_HWIDTH",
```


</td>
<td>

```tcl
set ::env(FP_PDN_VSPACING) [expr 5*$::env(FP_PDN_CORE_RING_VWIDTH)]
set ::env(FP_PDN_HSPACING) [expr 5*$::env(FP_PDN_CORE_RING_HWIDTH)]
```

</td>
</tr>
</table>


The next step is to control the internal power grid by changing the following variables:

<table>
<tr><th>JSON</th><th>Tcl</th></tr>
<tr>
<td>
    
```json
    "FP_PDN_VWIDTH": 3,
    "FP_PDN_HWIDTH": 3,
    "FP_PDN_VOFFSET": 0,
    "FP_PDN_HOFFSET": "expr::$FP_PDN_VOFFSET",
    "FP_PDN_VPITCH": 180,
    "FP_PDN_HPITCH": "expr::$FP_PDN_VPITCH"

```


</td>
<td>

```tcl
set ::env(FP_PDN_VWIDTH) 3 # The width of the vertical straps
set ::env(FP_PDN_HWIDTH) 3 # The width of the horizontal straps
set ::env(FP_PDN_VOFFSET) 0 # The vertical offset for the straps
set ::env(FP_PDN_HOFFSET) $::env(FP_PDN_VOFFSET) # The horizontal offset for the straps
set ::env(FP_PDN_VPITCH) 180 # The pitch between the vertical straps
set ::env(FP_PDN_HPITCH) $::env(FP_PDN_VPITCH) # The pitch between the horizontal straps
```

</td>
</tr>
</table>

All values above are given in microns.

At this stage you have automated the power grid generation for the Core Module.


## Macro Level

For the skywater libraries the hierarchy typically can go one level down at most otherwise you will only have two routing layers, which is usually not recommended. Therefore, although it is supported, your macros will typically have no nested macros inside them.

To begin the configurations for your macro, you want to announce that the design is a macro inside the core, and that it does not have a core ring. Also, prohibit the router from using metal layer 5 by setting the maximum routing layer to metal layer 4. This is done by setting the following configs:

<table>
<tr><th>JSON</th><th>Tcl</th></tr>
<tr>
<td>
    
```json
    "DESIGN_IS_CORE": false,
    "FP_PDN_CORE_RING": false,
    "RT_MAX_LAYER": "met4"
```


</td>
<td>

```tcl
set ::env(DESIGN_IS_CORE) 0
set ::env(FP_PDN_CORE_RING) 0
set ::env(RT_MAX_LAYER) "met4"
```

</td>
</tr>
</table>

Then, you should use the same `VDD_NETS` and `GND_NETS` set in the core level by adding these two lines to your configuration file:

<table>
<tr><th>JSON</th><th>Tcl</th></tr>
<tr>
<td>
    
```json
    "VDD_NETS": "vccd1 vccd2 vdda1 cdda2",
    "GND_NETS": "vssd1 vssd2 vssa1 vssa2"
```


</td>
<td>

```tcl
    set ::env(VDD_NETS) [list {vccd1} {vccd2} {vdda1} {vdda2}]
    set ::env(GND_NETS) [list {vssd1} {vssd2} {vssa1} {vssa2}]
```
</td>
</tr>
</table>


This should also reflected in the module declaration in the RTL of that macro in the same manner as follows:

```verilog
`ifdef USE_POWER_PINS
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground
`endif
```

These should match the names used in your core level. You do not need to use all the nets, the first two nets are used by default to power the digital cells. So you may want to only include a subset of these connections, this should be reflected in the configuration files as well as the RTL.

- The height of each macro must be greater than or equal to the value of `$::env(FP_PDN_HPITCH)` to allow at least two metal 5 straps on the core level to cross it and all the dropping of a via from met5 to met4 connecting the vertical straps of the macro to the horizontal straps of the core and so connect the power grid of the macro to the outer core ring.



At this stage, hardening the macros first, followed by the core, and finally connecting the core rings to the power pads, your power grids and connections should be complete.


[0]: ./chip_integration.md
