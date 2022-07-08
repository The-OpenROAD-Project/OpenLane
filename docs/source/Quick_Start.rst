============
Quick Start
============

Overview of OpenLane flow
-------------------------
The OpenRoad OpenLane is a automated RTL to GDSII flow build around open source tool. The flow perform the auto place and route of an ASIC design -in 24 hours with no human in the loop.

.. image:: ../_static/OpenLane_flow.png

Running OpenLane
----------------

OpenLane uses Docker to run a design. You need to start the Docker Container with proper path mounted.
To mount the proper directories into the Docker container would rely on Makefile:

.. code-block:: console

    cd OpenLane
    make mount

The sample design configuration is available in the design directory. To run a simple design using the command:

.. code-block:: console

    ./flow.tcl -design <design_name> -tag run1


The ``flow.tcl`` script is to run the flow both in interactive mode and non-interactive mode.

The resulting GDS will be available in result ``design/design_name/run1/result/final/gds/design_name.gds``.

Adding New design
-----------------
To add a new design, 

1. Generate a configuration file ``config.tcl`` for a design using the command in Docker

.. code-block:: console

    ./flow.tcl -design <design_name> -init_design_config

2. Exit the Docker using the command:

.. code-block:: console

    exit

3.  Go to your design directory and check if the config.tcl has been generated successfully. The global config.tcl file should end with:
    
.. code-block:: console

        set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
        if { [file exists $filename] == 1} {
        source $filename
        }


4. A directory with the name ``src`` should also has been created. Copy your verilog file in that directory.

This will create a design directory structure:

.. code-block:: console

    design/design_name
    ├── config.tcl
    └── src
           ├── design.v

The ``config.tcl`` is a global configuration for all PDKs. In the ``config.tcl`` file edit the `required variables <OpenLane_variable.html>`_ and optional variables if needed. 










    


