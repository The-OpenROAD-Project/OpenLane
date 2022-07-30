Analog component design practice
--------------------------------------------------------------------------------
Introduction
^^^^^^^^^^^^^^^
This guide covers design process of analog components for sky130.
While this guide is different for most technlogies and tools it gives enough practical experience.

As part of this guide NAND cell will be designed. It is recommended to read theoretical chapter located here first.

.. todo:: Add link to theoretical

Step 1. Installing tools
^^^^^^^^^^^^^^^
Let's install ``hpretl/iic-osic-tools`` Docker image which contains XSCHEM, NGSPICE, Netgen, KLayout.

.. code-block:: shell

    https://github.com/hpretl/iic-osic-tools.git
    cd iic-osic-tools/

    ./start_x.sh

This tool uses Docker image with prebuilt binaries. The ``./start_x.sh`` runs an Docker instance in a new window.
Make sure you have at least 12GB.

By default ``$HOME/eda/designs`` can be found inside the container path ``/foss/designs``.

To open the xschem run following:

.. code-block:: shell

    xschem

It will open the xschem window:

.. image:: ../_static/analog_flow/xschem_window.png

Step 2. Schematic
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In this step start building the simple schematic for a NAND. For this purpose use ``File -> New Schematic``

.. image:: ../_static/analog_flow/new_schematic.png

Next, draw the NAND unit. For this purpose, create transistors.
Click on the ``Tools -> Insert Symbol`` to create new componets.

.. image::  ../_static/analog_flow/tools_insert.png

In the opened window there three sections: Selection of the library, selection of the cell in the library and control bar at the bottom:

.. image::  ../_static/analog_flow/choose_symbol_window.png

Pressing Home button brings you to the list of libraries.
Left bar is used to select the library or it shows the current directory.
In the screenshot you can see three libraries: XSCHEM standard library, our workspace library and sky130A xschem library.

From sky130A xschem library open the ``sky130_fd_pr`` folder. The name stands for: sky130 foundry primitive cells.
From there pick ``nfet_01v8``.
Be careful. This is the most common mistake, you need to create the ``nfet_01v8``, not any other transistor.
Then click on the workspace to actually create the instance.

.. figure:: ../_static/analog_flow/nfet_01v8.png

Repeat the same step to create another ``nfet_01v8`` and two ``pfet_01v8``.
Or use click to select the transistor, then use Ctrl + C and Ctrl + V to copy the instance.

.. figure:: ../_static/analog_flow/4_transistors_schematic.png

Transistor types
"""""""""""""""""""""""""""""""""""""""
How do we know what transistors to use?
According to `sky130_fd_sc_hd documentation provided here <https://skywater-pdk.readthedocs.io/en/main/contents/libraries/foundry-provided.html>`_
it is clear that the library we are targeting uses this transistors.

Transistor choice in the library is always deliberate:
For example:

* High Vthreshold transistors will use less power, but will be slower and bigger => sky130_fd_sc_lp
* Low Vthreshold transistors will be faster, but more power consuming and will take more area => sky130_fd_sc_hs
* High Density grid will provide better area utilization at the cost of speed => sky130_fd_sc_hd
* Low leakage library will have reduced static leakage, at the cost of area and power  => sky130_fd_sc_hdll

If we want, we can use different type of transistors at a certain cost.
Since the layers to implement these transistors might have stricter spacing requirements,
the cells with different type of transistor than rest of the library will utilize bigger area.

The process of integrated circuit design is always about picking and choosing the tradeoffs.
One of the most common ones are: Cost, Power and Speed.

Ports
"""""""""""""""""""""""""""""""""""""""

Create four Input/Output pins ``Tools -> Insert symbol -> xschem_devices -> iopin.sym``.

.. figure:: ../_static/analog_flow/my_nand_iopin.png

Repeat the same to create two input ports ``Tools -> Insert symbol -> xschem_devices -> ipin.sym``.

.. figure:: ../_static/analog_flow/my_nand_ipin.png

Create the output port: ``Tools -> Insert symbol -> xschem_devices -> opin.sym``.

.. figure:: ../_static/analog_flow/my_nand_opin.png

Name the ports. Follow the same pattern as the sky130_fd_sc_hd:

.. figure:: ../_static/analog_flow/nand2_spice.png

Therefore:
   Inputs for Data: A, B  

   Outputs for Data: Y  


   I/O Power: VPWR  

   I/O Ground: VGND  

   I/O PMOS bulk: VPB  

   I/O NMOS bulk: VNB  


``Right click -> edit attributes`` on them to edit the label. Or you can select using ``left click`` and then press ``Q``.

.. figure:: ../_static/analog_flow/my_nand_ports.png

Logical question arises: Why are the VPWR and VPB separate pins if they are typically connected to the same power?
See :ref:`floorplan_taps_dcaps_fillers_sites` for answers.

Connections
"""""""""""""""""""""""""""""""""""""""

Next step is the connections.
Point to the terminals of the transistors then press W to start drawing the wire under the mouse.
After, click on the next terminal of the second transistor. Repeat for all of the connections.
Use ``devices/lab_pin.sym`` to assign nets to the connections.

.. figure:: ../_static/analog_flow/my_nand_connections.png

Save the schematic as ``my_nand.sch``.

.. todo:: Upload and link the schematic

Step 3. Symbol
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Click on ``Symbol -> Make symbol from schematic``. This will create ``my_nand.sym`` in the same folder as the schematic.
Default save location is ``~/eda/designs`` which is mounted in Docker image as ``/foss/designs``.


Click on ``File -> Open`` and select the ``my_nand.sym`` to see the generated symbol.

.. figure:: ../_static/analog_flow/my_nand.sym.png

.. todo:: Upload and link the symbol

Step 4. Testbench
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Make testbench to verify the functionality of the cell and collect information about characteristics of the component.

Create new schematic using ``File -> New schematic``.

Components
"""""""""""""""""""""""""""""""""""""""

First, create instance of ``/foss/eda/my_nand.sym``.

Second, create voltage source ``devices/vsource.sym`` for powering the ``my_nand`` instance. 

Third, create two voltage sources ``devices/vsource.sym`` for simulating the inputs of the nand cell.

Then, create capacitor ``devices/capa.sym`` to simulate the effect of gates connected at the output of the cell.

Finally, create ground instance ``devices/gnd.sym``.

.. figure:: ../_static/analog_flow/my_nand_tb_components.png


Connections
"""""""""""""""""""""""""""""""""""""""
Connect everything as shown in the figure.

.. figure:: ../_static/analog_flow/my_nand_tb_connections.png


Configure the components and the simulation
"""""""""""""""""""""""""""""""""""""""
Configure the components.
Right click on the capacitor and select ``edit attributes``. Set capacitor value to ``16f`` (FemtoFarad).

.. figure:: ../_static/analog_flow/my_nand_cap_load.png

Create parameters that contain VPWR voltage value. For this purpose create instance of ``devices/code_shown.sym`` and fill  ``value`` field with following:

.. code-block::

  .param vpwr_value=1.65

It will look like this:

.. figure:: ../_static/analog_flow/vpwr_value.png

Set name and value of the voltage source for powering the circuit. Name should be ``Vpwr`` and the value should be ``vpwr_value``:

.. figure:: ../_static/analog_flow/vpwr_vsource.png

Next, configure the input voltage values. Documentation regarding the syntax can be found in the `NGSPICE documentation <https://ngspice.sourceforge.io/docs.html>`_.

Here is the list of PULSE parameters: PULSE ( V1 V2 TD TR TF PW PER PHASE ).

.. figure:: ../_static/analog_flow/PULSE.png

  Taken from NGSPICE documentation. Read the docs, this is provided as a reference for the reader.

Visualization of the pulse.

.. figure:: ../_static/analog_flow/nand_input_waveview_1.png

  Visualization of the pulse: PULSE(0 1.65 5ns 1ns 1ns 4ns 10ns)



.. todo:: A picture of the input voltages
.. todo:: Explain the logic of the values of PULSE

.. todo:: Let's include the 


.. todo:: Create the instance of sky130 xschem library ``corner.sym`` and choose ``ss`` corner.

From sky130A xschem library open the ``sky130_fd_pr`` folder then pick ``corner.sym``. Then change ``corner`` attribute to ``ss``.
.. todo:: Add picture of corner attribute

It will add a ``.lib`` line that points to the sky130 library. If you do not include this component you will get an error about transistor models missing:

.. todo:: Add picture of transistors missing.



.. todo:: Create labels

.. todo:: Add the simulation mode
.. todo:: Temperature
.. todo:: Justification for voltage

.. todo:: Netlist, simulate

.. todo:: Open the "waves" Look at plots



.. todo:: Upload and link the testbench


Measurements
"""""""""""""""""""""""""""""""""""""""
.. todo:: Add measurements



Troubleshooting
"""""""""""""""""""""""""""""""""""""""
.. todo:: Add troubleshooting PDK issues
.. todo:: Add troubleshooting Symbol path issues

.. todo:: Add XSCHEM building the Testbench half
.. todo:: Add XSCHEM netlisting half
.. todo:: Add XSCHEM simulation half
.. todo:: Add XSCHEM making sure the saved files reference right symbols half

.. todo:: Add opening the KLayout quarter
.. todo:: Add copying the cell
.. todo:: Add removing everything but the power rails and NWELL/PSDM/NSDM
.. todo:: Add drawing new shapes.
.. todo:: Add the final result

.. todo:: Common question about sky130A vs sky130B