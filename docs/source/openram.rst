


.. todo:: Create design using the openram cells
.. todo:: Tutorial it

.. code-block:: console

    ./flow.tcl -design test_sram_macro -init_design_config -add_to_designs


./flow.tcl -design test_sram_macro -tag full_guide -overwrite

    "EXTRA_LEFS":      "dir::../pdks/sky130B/libs.ref/sky130_sram_macros/lef/sky130_sram_1kbyte_1rw1r_32x256_8.lef",
    "EXTRA_GDS_FILES": "dir::../pdks/sky130B/libs.ref/sky130_sram_macros/gds/sky130_sram_1kbyte_1rw1r_32x256_8.gds",
    "VERILOG_FILES_BLACKBOX": "../pdks/sky130B/libs.ref/sky130_sram_macros/verilog/sky130_sram_1kbyte_1rw1r_32x256_8.v"


.. todo:: Explain why the placement might fail (Because not enough space/ because too much space)
.. todo:: Explain the PDN connections
.. todo:: Explain the power pins/nets connections
