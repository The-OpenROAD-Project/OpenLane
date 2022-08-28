OpenRAM macro usage guide in sky130
--------------------------------------------------------------------------------

.. todo:: Explain above

.. code-block:: console

    ./flow.tcl -design test_sram_macro -init_design_config -add_to_designs

.. todo:: Explain above

./flow.tcl -design test_sram_macro -tag full_guide -overwrite

.. todo:: Explain above

    "EXTRA_LEFS":      "dir::../pdks/sky130B/libs.ref/sky130_sram_macros/lef/sky130_sram_1kbyte_1rw1r_32x256_8.lef",
    "EXTRA_GDS_FILES": "dir::../pdks/sky130B/libs.ref/sky130_sram_macros/gds/sky130_sram_1kbyte_1rw1r_32x256_8.gds",
    "VERILOG_FILES_BLACKBOX": "../pdks/sky130B/libs.ref/sky130_sram_macros/verilog/sky130_sram_1kbyte_1rw1r_32x256_8.v"


.. todo:: Explain above

We set the following floorplan parameters:

    "FP_SIZING": "absolute",
    "DIE_AREA": "0 0 750 1250",
    "PL_TARGET_DENSITY": 0.5,

``FP_SIZING`` is set to ``absolute`` and it will tell the floorplan to use ``DIE_AREA`` as final macro block's size.
The we set the ``DIE_AREA``. This value is carefully constructed.
If it is set to high value then you are going to have routing/placement/timing issues.
On the other hand 

.. todo:: Explain above

    "VDD_NETS": "vccd1",
    "GND_NETS": "vssd1",

.. todo:: Explain above


"SYNTH_USE_PG_PINS_DEFINES": "USE_POWER_PINS",
    
.. todo:: Explain above w/ Example


"FP_PDN_MACRO_HOOKS": "sram0 vccd1 vssd1 vccd1 vssd1, sram1 vccd1 vssd1 vccd1 vssd1",

.. todo:: Explain above
.. todo:: Explain how to get sram0/sram1 names


"MACRO_PLACEMENT_CFG": "dir::macro_placement.cfg",

.. todo:: Explain above
.. todo:: Explain how to get sram0/sram1 names


    "EXTRA_LEFS":      "/openlane/pdks/sky130B/libs.ref/sky130_sram_macros/lef/sky130_sram_1kbyte_1rw1r_32x256_8.lef",
    "EXTRA_GDS_FILES": "/openlane/pdks/sky130B/libs.ref/sky130_sram_macros/gds/sky130_sram_1kbyte_1rw1r_32x256_8.gds",
    "VERILOG_FILES_BLACKBOX": "dir::sky130_sram_1kbyte_1rw1r_32x256_8.bb.v",

.. todo:: Explain above

"MAGIC_DRC_USE_GDS": false

.. todo:: Explain above





    "RUN_KLAYOUT_XOR": false,
    "RUN_MAGIC_DRC": false

.. todo:: Explain above

./flow.tcl -design test_sram_macro -tag full_guide_use_deflef_drc -overwrite

.. todo:: Explain why the placement might fail (Because not enough space/ because too much space)
.. todo:: Explain the PDN connections
.. todo:: Explain the power pins/nets connections
