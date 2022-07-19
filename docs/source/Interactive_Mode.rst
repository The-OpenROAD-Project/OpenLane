================
Interactive Mode 
================

OpenLane run in a interactive mode by using ``-interactive`` where every steps of a design run by the user.

.. code-block:: shell

    ./flow.tcl -interactive

A tcl shell will be opened where the OpenLane package is automatically sourced:

.. code-block:: shell 

    % package required openlane

Then, able to run the following main commands:

.. code-block:: shell

     prep -design <design_name> -tag <tag>
     run_synthesis
     run_floorplan
     run_placement
     run_cts
     run_routing
     write_powered_verilog
     run_magic
     run_magic_spice_export 
     run_magic_drc
     run_lvs
     run_antenna_check

The above commands can also be written in a file and passed to ``flow.tcl``:

.. code-block:: shell

    ./flow.tcl -interactive -file <file_name>


.. important::
    
    1. Run the ``prep`` command before running the any other command, in order to have necessary files and configuration loaded.
    2. Run the above commands in the same flow sequence and no step should be skipped.






