OpenRAM macro usage guide in sky130
--------------------------------------------------------------------------------

Create a new design.

.. code-block:: console

    ./flow.tcl -design test_sram_macro -init_design_config -add_to_designs

Create the Blackbox
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Create blackbox declaration of ``sky130_sram_1kbyte_1rw1r_32x256_8``
in file ``designs/test_sram_macro/sky130_sram_1kbyte_1rw1r_32x256_8.bb.v``.

Copy the relevant sections from ``pdks/sky130B/libs.ref/sky130_sram_macros/verilog/sky130_sram_1kbyte_1rw1r_32x256_8.v``.
``(*blackbox*)`` attribute is specified, to let the synthesis tool know that this module is a blackbox.
If the module is empty it is assumed to be blackbox anyway, but specifying the attribute makes it more clear.

.. code-block:: verilog

    // OpenRAM SRAM model
    // Words: 256
    // Word size: 32
    // Write size: 8

    (*blackbox*)
    module sky130_sram_1kbyte_1rw1r_32x256_8(
    `ifdef USE_POWER_PINS
        vccd1,
        vssd1,
    `endif
    // Port 0: RW
        clk0,csb0,web0,wmask0,addr0,din0,dout0,
    // Port 1: R
        clk1,csb1,addr1,dout1
    );

    parameter NUM_WMASKS = 4 ;
    parameter DATA_WIDTH = 32 ;
    parameter ADDR_WIDTH = 8 ;
    parameter RAM_DEPTH = 1 << ADDR_WIDTH;
    // FIXME: This delay is arbitrary.
    parameter DELAY = 3 ;
    parameter VERBOSE = 1 ; //Set to 0 to only display warnings
    parameter T_HOLD = 1 ; //Delay to hold dout value after posedge. Value is arbitrary

    `ifdef USE_POWER_PINS
        inout vccd1;
        inout vssd1;
    `endif
    input  clk0; // clock
    input   csb0; // active low chip select
    input  web0; // active low write control
    input [NUM_WMASKS-1:0]   wmask0; // write mask
    input [ADDR_WIDTH-1:0]  addr0;
    input [DATA_WIDTH-1:0]  din0;
    output [DATA_WIDTH-1:0] dout0;
    input  clk1; // clock
    input   csb1; // active low chip select
    input [ADDR_WIDTH-1:0]  addr1;
    output [DATA_WIDTH-1:0] dout1;

    endmodule

Finally, connect the blackbox declaration verilog file using ``VERILOG_FILES_BLACKBOX``.

.. code-block:: json

    "VERILOG_FILES_BLACKBOX": "dir::sky130_sram_1kbyte_1rw1r_32x256_8.bb.v",

In the future ``liberty`` with proper power/ground pins support will be added,
so the creation of blackbox is no longer required. See `issue 1273 <https://github.com/The-OpenROAD-Project/OpenLane/issues/1273>`.

It is also users responsibility to avoid name collisions between the blackbox macro blocks.
If two blackbox modules with the same module name, but different set of parameters exist,
then it is possible to get RTL behavor missmatch without any warning. See `issue 1291 <https://github.com/The-OpenROAD-Project/OpenLane/issues/1291>`.

Create the Verilog files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


.. todo:: Create the verilog file

Connect the Layout pins
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


Connect LEF files using ``EXTRA_LEFS``.
In this case absolute path is used, if the PDK location is different then path needs to be changed.
This files contains lightweight abstract representation of the cell.
LEF contains only metal layers and layers that can connect between cells (met1, via2, nwell, pwell, etc).

Connect GDS files with the subcomponent.
The GDS from ``EXTRA_GDS_FILES`` that will be used to generate the final GDS file.
For analog cells it is users responsibility to make sure that GDS matches LEF files.

.. code-block:: json

    "EXTRA_LEFS":      "/openlane/pdks/sky130B/libs.ref/sky130_sram_macros/lef/sky130_sram_1kbyte_1rw1r_32x256_8.lef",
    "EXTRA_GDS_FILES": "/openlane/pdks/sky130B/libs.ref/sky130_sram_macros/gds/sky130_sram_1kbyte_1rw1r_32x256_8.gds",
    
Floorplanning
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Set the following floorplan parameters:

.. code-block:: json

    "FP_SIZING": "absolute",
    "DIE_AREA": "0 0 750 1250",
    "PL_TARGET_DENSITY": 0.5,

``FP_SIZING`` is set to ``absolute`` and it will tell the floorplan to use ``DIE_AREA`` as final macro block's size.
The we set the ``DIE_AREA``. This value is carefully constructed.
If it is set to big value then you are going to have routing/placement/timing issues.
On the other hand setting the value too low will cause placement and routing congestion issues.

To obtain perfect ``DIE_AREA`` the 50% utilization was used,
then aspect ratio and area was manually adjusted to keep the utilization around 45% and the final density about 50%.

`PL_TARGET_DENSITY` is set to 0.5 to reflect the target final density of 50%.


Power/Ground nets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Create the power/ground nets.
First net in the list will be used for standard cell power connections.

.. code-block:: json

    "VDD_NETS": "vccd1",
    "GND_NETS": "vssd1",

If you need more power/ground nets add the nets to the list:

.. code-block:: json

    "VDD_NETS": "vccd1 vccd2",
    "GND_NETS": "vssd1 vssd2",

The sky130 caravel template has 4 power domains.
If this variable does not have the power domains properly declared then you will have issues with the PDN in caravel template.

Use ``SYNTH_USE_PG_PINS_DEFINES`` to allow automatic parsing of the power/ground nets.

.. code-block:: json

    "SYNTH_USE_PG_PINS_DEFINES": "USE_POWER_PINS",
    
This will run synthesis without USE_POWER_PINS to generate the final verilog
and then another synthesis with USE_POWER_PINS defined to generate the powered verilog netlist.

Power/Ground PDN connections
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Add the PDN connections between sram cells and the power/ground nets.
Syntax: ``<instance_name> <vdd_net> <gnd_net> <vdd_pin> <gnd_pin>``.
More information is available in `configuration variables documentation <configuration>`_.
Each macro hook is separated using comma, for example:

.. code-block:: json

    "FP_PDN_MACRO_HOOKS": "submodule.sram0 vccd1 vssd1 vccd1 vssd1, submodule.sram1 vccd1 vssd1 vccd1 vssd1",

The instance names need to be fetched from synthesis netlist.
For this purpose run the design until synthesis stage using following command:

.. code-block:: console

    ./flow.tcl -design test_sram_macro -tag synthesis_only -to synthesis -overwrite

Open following file ``designs/test_sram_macro/runs/synthesis_only/results/synthesis/test_sram_macro.v``.


.. code-block:: verilog

    /* Generated by Yosys 0.12+45 (git sha1 UNKNOWN, gcc 8.3.1 -fPIC -Os) */

    module test_sram_macro(rst_n, clk, cs, we, addr, write_allow, datain, dataout);
    wire _000_;
    wire _001_;
    wire _002_;
    ...
    sky130_sram_1kbyte_1rw1r_32x256_8 \submodule.sram0  (
        .addr0(addr),
        ...
        .wmask0(write_allow[3:0])
    );
    sky130_sram_1kbyte_1rw1r_32x256_8 \submodule.sram1  (
        .addr0(addr),
        ...
        .wmask0(write_allow[7:4])
    );


If the cell is referenced in the submodule then it has the prefix with the submodule name and escaped slash ``\``.
As can be seen there is two cells ``sky130_sram_1kbyte_1rw1r_32x256_8`` with instance names ``\submodule.sram0``, ``\submodule.sram1``.
Directly copy the instance names without the prefix escape symbol: ``submodule.sram0``, ``submodule.sram1``, avoid guessing it.


Then the ``FP_PDN_MACRO_HOOKS`` will look like this (note that there is no backslash in front of the name):

.. code-block:: json

    "FP_PDN_MACRO_HOOKS": "submodule.sram0 vccd1 vssd1 vccd1 vssd1, submodule.sram1 vccd1 vssd1 vccd1 vssd1",


The cells need to be placed inside the ``DIE_AREA``,
however the automatic placement does not account the I/O placement when selecting sram placement.

It is causing the SRAM component to be placed on the edge of the macro.
As a result the I/O power usage is going to be increased,
because there is a long net that goes over the subcomponents.

Instead choose the locations of these cells manually.
The size of the cells can be taken from the LEF file ``pdks/sky130B/libs.ref/sky130_sram_macros/lef/sky130_sram_1kbyte_1rw1r_32x256_8.lef``.
While it is not required to know the size of the cell,
it is useful for the purpose of to making sure that the subcomponents do not overlap.

For example:

.. code-block::

    UNITS
    DATABASE MICRONS 1000 ;
    END UNITS
    MACRO sky130_sram_1kbyte_1rw1r_32x256_8
    CLASS BLOCK ;
    SIZE 479.78 BY 397.5 ;
    SYMMETRY X Y R90 ;

To specify the cell placement create file ``designs/test_sram_macro/macro_placement.cfg``:

.. code-block::

    submodule.sram0 125 125 N
    submodule.sram1 125 700 S

The syntax is ``<instance name> <x> <y> <direction>``.
The instance name needs to be taken directly from synthesis netlist without escape symbol at the beggining.

Then modify the ``config.json`` to reference this file.

.. code-block:: json

    "MACRO_PLACEMENT_CFG": "dir::macro_placement.cfg",

Resolving issues
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Memory footprint
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

While running the flow it may use significant amount of memory.
You can temporary disable KLayout XOR check to reduce the memory footprint, while experimenting.
But for the final GDS submission make sure that XOR check is enabled.

.. code-block:: json

    "RUN_KLAYOUT_XOR": false,

DRCs inside SRAM macros
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

The sky130 uses optical proximity to reduce the size of the SRAM transistors.
The SRAM blocks in sky130 generated by OpenRAM use different DRC ruleset to accomodate for this size reduction.
Therefore when running the Magic VLSI it is expected to have many DRC violations.

The ``MAGIC_DRC_USE_GDS`` can be set to false, forcing the Magic VLSI to run DRC on DEF/LEF instead of GDS.
However, you will still get DRCs.

.. code-block:: json

    "MAGIC_DRC_USE_GDS": false

For this example we can just disable the DRC check.
However, this is very dangerous and needs to be approved by the foundry.

.. code-block:: json

    "RUN_MAGIC_DRC": false

JSON syntax error regarding the comma
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

The last field of the object in JSON must not have any commas, otherwise you will have a syntax issue:

.. code-block::

    [INFO]: Using configuration in 'designs/test_sram_macro/config.json'...
    [ERROR]: Traceback (most recent call last):
    File "/openlane/scripts/config/to_tcl.py", line 351, in <module>
        cli()
    File "/usr/local/lib/python3.6/site-packages/click/core.py", line 1128, in __call__
        return self.main(*args, **kwargs)
    File "/usr/local/lib/python3.6/site-packages/click/core.py", line 1053, in main
        rv = self.invoke(ctx)
    File "/usr/local/lib/python3.6/site-packages/click/core.py", line 1659, in invoke
        return _process_result(sub_ctx.command.invoke(sub_ctx))
    File "/usr/local/lib/python3.6/site-packages/click/core.py", line 1395, in invoke
        return ctx.invoke(self.callback, **ctx.params)
    File "/usr/local/lib/python3.6/site-packages/click/core.py", line 754, in invoke
        return __callback(*args, **kwargs)
    File "/openlane/scripts/config/to_tcl.py", line 337, in config_json_to_tcl
        config_dict = json.loads(config_json_str)
    File "/usr/lib64/python3.6/json/__init__.py", line 354, in loads
        return _default_decoder.decode(s)
    File "/usr/lib64/python3.6/json/decoder.py", line 339, in decode
        obj, end = self.raw_decode(s, idx=_w(s, 0).end())
    File "/usr/lib64/python3.6/json/decoder.py", line 355, in raw_decode
        obj, end = self.scan_once(s, idx)
    json.decoder.JSONDecodeError: Expecting property name enclosed in double quotes: line 27 column 1 (char 901)


Right way:

.. code-block::

    {
        ...
        "RUN_MAGIC_DRC": false
    }

Wrong way:

.. code-block::

    {
        ...
        "RUN_MAGIC_DRC": false,
    }

Running the flow
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Final ``config.json`` looks like this:

.. code-block::

    {
        "DESIGN_NAME": "test_sram_macro",
        "VERILOG_FILES": "dir::src/*.v",
        "CLOCK_PORT": "clk",
        "CLOCK_PERIOD": 10.0,
        "DESIGN_IS_CORE": true,

        "FP_SIZING": "absolute",
        "DIE_AREA": "0 0 750 1250",
        "PL_TARGET_DENSITY": 0.5,

        "VDD_NETS": "vccd1",
        "GND_NETS": "vssd1",

        "SYNTH_USE_PG_PINS_DEFINES": "USE_POWER_PINS",
        
        "FP_PDN_MACRO_HOOKS": "submodule.sram0 vccd1 vssd1 vccd1 vssd1, submodule.sram1 vccd1 vssd1 vccd1 vssd1",
        
        "MACRO_PLACEMENT_CFG": "dir::macro_placement.cfg",

        "EXTRA_LEFS":      "/openlane/pdks/sky130B/libs.ref/sky130_sram_macros/lef/sky130_sram_1kbyte_1rw1r_32x256_8.lef",
        "EXTRA_GDS_FILES": "/openlane/pdks/sky130B/libs.ref/sky130_sram_macros/gds/sky130_sram_1kbyte_1rw1r_32x256_8.gds",
        "VERILOG_FILES_BLACKBOX": "dir::sky130_sram_1kbyte_1rw1r_32x256_8.bb.v",

        "RUN_KLAYOUT_XOR": false,
        "RUN_MAGIC_DRC": false
    }



.. todo:: Add pictures of the macro placement in floorplan


.. todo:: Add pictures of final result


.. todo:: Explain above

./flow.tcl -design test_sram_macro -tag full_guide_use_deflef_drc -overwrite

.. todo:: Explain above

./flow.tcl -design test_sram_macro -tag full_guide -overwrite


.. todo:: Explain why the placement might fail (Because not enough space/ because too much space)
.. todo:: Explain the PDN connections
.. todo:: Explain the power pins/nets connections
