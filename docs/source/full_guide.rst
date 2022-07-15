Full Guide
================================================================================

The end goal for OpenLane flow is to generate an `integrated circuit <https://en.wikipedia.org/wiki/Integrated_circuit>`_
that can be produced by the foundry.
OpenLane is one of the leading-edge Open-Source tools created exactly for this purpose.


.. note:: This guide assumes that you already have the `OpenLane installed using this guide <installation.html>`_ and you already successfully `completed the quickstart here <quickstart.html>`_.

.. todo:: Add a picture that is under CC or similar license.

.. todo:: Add links to the Wikipedia covering every word.

Multiple foundries exist and each of the foundries may have dozens of technologies supported.
Currently, OpenLane supports only sky130,
which was published by `Google in cooperation with Skywater <https://github.com/google/skywater-pdk>`_,
but there is active work to support `fictional technologies like ASAP7 <https://asap.asu.edu/>`_ and other PDKs. There is a guide on `porting new PDKs to OpenLane located here <pdk_structure.html>`_ .

The coolest part about sky130 is `Google funded Multi Project Wafer in partnership with Efabless <https://efabless.com/open_shuttle_program>`_.
Using OpenMPW you can produce your integrated circuit for free (some limitations apply).

This guide covers everything that you need to know in order to be able to create a final integrated circuit layout files, 
which if done correctly can be produced by the foundry. As part of this tutorial we will make a simple bottom-to-top design utilizing as many features of OpenLane as we can.

In this example we are going to create a simple memory macro, generate the layout files for it,
then use the generated memory to make a top level chip register file.
While the guide covers only digital blocks, the digital macro blocks can be replaced by analog macros.
Use `this guide to create the required files <custom_macros.html>`_.

Structure of integrated circuits
--------------------------------------------------------------------------------

Integrated circuits consist of three main components: die, connections between pin and die pads, pin itsalf, and package.
Two primary variants exist for packaging from standpoint of pads: Wire bond and Flip chip

.. todo:: Add the picture of an integrated circuits


The silicon die
--------------------------------------------------------------------------------

Inside the packaging is located the die.
The die is the heart of the integrated circuit.
It contains every transistor, capacitor, resistor, diode and many more things.
The metalic interconnect layer connects the separate components.

Dies are produced by foundries. Many foundries exist and each one of the foundries support specific technology.
For example company Skywater Technology owns the technology sky130 and the foundries for this technology.
But for foundry to be able to produce your chip, it has to follow a strict ruleset.
Usually this information is provided as part of `Process design kit <https://en.wikipedia.org/wiki/Process_design_kit>`_.

.. todo:: Add a picture of the die
.. todo:: replace PDK link with link to the local PDK section


Understanding CMOS transistors
--------------------------------------------------------------------------------
Silicon is the building block of the integrated circuit.
It consists of cubic (3D) grid of silicon atoms that are connected to their neihbours.
Dopant such as arsenic is integrated into the silicon grid to form a n-type semiconductor.
Similarly boron is used to form p-type semiconductor.

Diode
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
A junction between p-type and n-type silicon is called a diode.

.. todo:: Add picture of diode

When the voltage on the p-type semiconductor is raised above the n-type cathode,
the current flows through diode. Meanwhile if the voltage on n-type is higher or equal to p-type then the diode is closed and current does not flow.

MOS transistors
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The NMOS and PMOS transistors consists of the conducting gate, an insulating layer of silicon oxide, drain, source and bulk.

.. figure:: https://skywater-pdk.readthedocs.io/en/main/_images/cross-section-nfet_01v8.svg

    Cross section of an NFET.

.. todo:: edit the cross section of the NFET.

The gate voltage acts as control input.
The value of the gate controls the current between drain and source.

Let's take a look at nMOS transistor.
The body is connected to the ground so the p–n junctions of the source and drain to body are reverse-biased.

If the gate is also grounded, then no current flows. Therefore, we say the transistor is OFF.

If the gate voltage increases, then the the capacitor charges.
This creates electrons at bottom plate of the Si–SiO2 interface.
If the voltage is raised enough, the electrons outnumber the holes
and a thin region under the gate called the channel turns into an n-type semiconductor.
Hence, a conducting path of electron carriers is formed from
source to drain and current can flow. We say the transistor is ON.

The voltage where the electrons number is equal to the holes is called Vthreshold.

.. todo:: Add picture visualizing this

.. todo:: Add PMOS explainaion

Process design kit
--------------------------------------------------------------------------------

Process design kit is provided by foundry.
The PDK is specific to the technology and contains any combination of these files:

* Documentation
  
  * Design Rule Manual. For example, Documentation for `sky130 can be found here <https://skywater-pdk.readthedocs.io/en/main/>`_, meanwhile the `Design Rule Manual is scattered here <https://skywater-pdk.readthedocs.io/en/main/rules/periphery.html#x>`_

* Primitives
  
  * SPICE models. SPICE models were provided by skywater-pdk, however `Open_PDKs modified the SPICE files <http://opencircuitdesign.com/open_pdks/>`_ for compatability with NGSPICE.
  * Symbols. Original skywater-pdk did not contain any symbols, however symbols for XSCHEM are included in Open_PDKs installation. Also they are available as separate XSCHEM library here.


.. todo:: add the link to XSCHEM library


* Verification decks for:
  
  * Design Rule Checking (:ref:`DRC`)
  * Layout Versus Schematic (:ref:`LVS`)
  * Parasitics Extraction (:ref:`PEX`)
  * Antenna and Electrical rule check

* Tool depended tech files
* LEF tech file
* Usually it also includes one or more standard cell library:
  
  * Documentation for it
  * LEF (or other) abstract representation
  * LIB file that contains timings and power information for synthesis
  * Symbols
  * Layout files (Also called GDSII files)


Keep in mind that in some cases multiple standard cell libraries can be used together.
For example, sky130 High-Density and sky130 High-Density Low leakage. OpenLane currently does not support multiple libraries.

Die Manufacturing
--------------------------------------------------------------------------------

.. todo:: Add pictures epxplining the process

Multi Project Wafer
--------------------------------------------------------------------------------

Analog design flow
--------------------------------------------------------------------------------

.. todo:: Add the picture for the flow

Analog design flow allows to design any integrated circuits. This flexibility comes with a big cost.

In order to be able to actually design an analog component experience is a must have.
Usually there is multiple issues to the specific design.
For example, IO cells have to add ESD related testbenches, measure the Electromigration, account for IR drop and many more.


Tech Files
--------------------------------------------------------------------------------

DRC
^^^^^^^^^^^^^^^
Design Rule Checks is the step used to verify the layout to adhere the strict manufacturing rules.
If DRC fails then the layout cannot be manufactured.

.. todo:: add screenshot to DRC process

LVS
^^^^^^^^^^^^^^^
Layout versus schematic check extracts the primitives from the layout files,
after that the generated netlist is compared agains the reference netlist.
Usually the netlist is generated by schematic tool and the PDK contains configuration for the LVS for some tool.

.. todo:: add link to the files
sky130 supports Magic VLSI and KLayout DRC checks, the rulesets are provided by Open_PDKs installation.

.. todo:: Add a screenshot of LVS process

PEX
^^^^^^^^^^^^^^^

CVC

Circuit Validity Checker

https://github.com/d-m-bailey/cvc

Tech LEF
^^^^^^^^^^^^^^^

Standrad Cells Library
--------------------------------------------------------------------------------
LEF
^^^^^^^^^^^
GDS
^^^^^^^^^^^
LIB
^^^^^^^^^^^


PDK content
--------------------------------------------------------------------------------

OpenLane PDK vs Tech PDK vs Foundary PDK
--------------------------------------------------------------------------------



Analog design flow
--------------------------------------------------------------------------------

Let's install ``hpretl/iic-osic-tools`` which contains XSCHEM, NGSPICE, Netgen. KLayout will be ran from OpenLane docker image.

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

Introduction into the flow
--------------------------------------------------------------------------------

.. todo:: Make high level image showcasing the flow


Running the flow for simple memory macro design
--------------------------------------------------------------------------------

Step 1. Create the memory macro design
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Let's create the design. The following command will create a directory ``design/mem_1r1w/`` and one file ``config.tcl`` that will be mostly empty.

.. code-block:: console

    ./flow.tcl -design mem_1r1w -init_design_config


One of the common mistakes people make is copying existing designs,
like ``designs/inverter`` and then they face issues with their configuration.
Always create new designs using ``-init_design_config``.
It will ensure that your configuration is the absolute minimum.

Example of the common issues people face:
They copy ``inverter`` design, rename it. Then run the flow and the router crashes with ``error 10``.
This is caused by enabled "basic placement",
which works only for designs with a couple of dozen standard cells, not hundreds.
So when you change the basic inverter with a design containing many cells
router will not be able to route your design, therefore crashing with cryptic message.

Step 2. Create the RTL files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Then we need to create/copy the RTL files. The recommended location for files is ``design/mem_1r1w/src/``. Let's put a simple counter in there.

Create ``design/mem_1r1w/src/mem_1r1w.v`` file and put following content:

.. code-block:: verilog

    module mem_1r1w (clk, read_addr, read, read_data, write_addr, write, write_data);
        parameter DEPTH_LOG2 = 4;
        localparam ELEMENTS = 2**DEPTH_LOG2;
        parameter WIDTH = 32;

        input wire clk;

        input wire [DEPTH_LOG2-1:0] read_addr;
        input wire read;
        output reg [WIDTH-1:0] read_data;


        input wire [DEPTH_LOG2-1:0] write_addr;
        input wire write;
        input wire  [WIDTH-1:0] write_data;

    reg [WIDTH-1:0] storage [ELEMENTS-1:0];

    always @(posedge clk) begin
        if(write) begin
            storage[write_addr] <= write_data;
        end
        if(read)
            read_data <= storage[read_addr];
    end

    endmodule



.. note::
    Originally we used a very small macro block as an example,
    however there is known issue: Small macro blocks do not fit proper power grid,
    therefore you need to avoid making small macro blocks. Alternatively, set the ``FP_SIZING`` to ``absolute`` and configure ``DIE_AREA`` to be bigger than ``200um x 200um`` for sky130.

In your designs it might be beneficial to have macro level and chip level.
This separation allows you to reuse already generated macro blocks multiple times.

For example, the multi core processor.
If you just run OpenLane with multiple cores and only chip level,
all of the cores will be placed and routed together, resulting in significant runtime.

.. todo:: add visualization of this concept

In contrast, by running OpenLane first on single core module
then reusing the generated GDS means that the timing might not be as good,
but the runtime will be much faster.
The runtime is much faster since you are running one placement and route for only one core and then reusing it in the top level.

In your designs it might be beneficial to have macro level and chip level.
This separation allows you to reuse already generated macro blocks multiple times.

For example, the multi core processor.
If you just run OpenLane with multiple cores and only chip level,
all of the cores will be placed and routed together, resulting in significant runtime.

.. todo:: add visualization of this concept

In contrast, by running OpenLane first on single core module
then reusing the generated GDS means that the timing might not be as good,
but the runtime will be much faster,
since you are running one placement and route for only one core.

The benefit of doing RTL-to-GDS first for macro


Add following lines:

.. code-block:: tcl

    set ::env(DESIGN_IS_CORE) 0
    set ::env(FP_PDN_CORE_RING) 0
    set ::env(RT_MAX_LAYER) "met4"


.. todo:: explain why

Step 3. Run the flow on the macro block
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: console

    ./flow.tcl -design mem_1r1w -tag full_guide -overwrite

Step 4. Analyzing the flow generated files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Step 5. Create blackboxes
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Step 6. Integrate the macros
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

set ::env(VERILOG_FILES_BLACKBOX) [glob $::env(DESIGN_DIR)/bb/*.v]
set ::env(EXTRA_LEFS) $::env(DESIGN_DIR)/../mem_1r1w/runs/full_guide/results/final/lef/mem_1r1w.lef
set ::env(EXTRA_GDS_FILES) $::env(DESIGN_DIR)/../mem_1r1w/runs/full_guide/results/final/gds/mem_1r1w.gds


Step 7. Run the floe
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Troubleshooting Figure out why it does not fit
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

[ERROR]: during executing openroad script /openlane/scripts/openroad/replace.tcl
[ERROR]: Exit code: 1
[ERROR]: full log: designs/regfile_2r1w/runs/full_guide/logs/placement/9-global.log
[ERROR]: Last 10 lines:
[INFO GPL-0015] CoreAreaUxUy: 489440 495040
[INFO GPL-0016] CoreArea: 234294707200
[INFO GPL-0017] NonPlaceInstsArea: 124707104000
[INFO GPL-0018] PlaceInstsArea: 117229672450
[INFO GPL-0019] Util(%): 106.97
[INFO GPL-0020] StdInstsArea: 454185600
[INFO GPL-0021] MacroInstsArea: 116775486850
[ERROR GPL-0301] Utilization exceeds 100%.
Error: replace.tcl, 91 GPL-0301
child process exited abnormally

Solution: set ::env(FP_ASPECT_RATIO) 2


Troubleshooting:


[ERROR]: during executing openroad script /openlane/scripts/openroad/floorplan.tcl
[ERROR]: Exit code: 1
[ERROR]: full log: designs/regfile_2r1w/runs/full_guide/logs/floorplan/3-initial_fp.log
[ERROR]: Last 10 lines:
set_clock_uncertainty $::env(SYNTH_CLOCK_UNCERTAINITY) [get_clocks $::env(CLOCK_PORT)]
puts "\[INFO\]: Setting clock transition to: $::env(SYNTH_CLOCK_TRANSITION)"
[INFO]: Setting clock transition to: 0.15
set_clock_transition $::env(SYNTH_CLOCK_TRANSITION) [get_clocks $::env(CLOCK_PORT)]
puts "\[INFO\]: Setting timing derate to: [expr {$::env(SYNTH_TIMING_DERATE) * 10}] %"
[INFO]: Setting timing derate to: 0.5 %
set_timing_derate -early [expr {1-$::env(SYNTH_TIMING_DERATE)}]
set_timing_derate -late [expr {1+$::env(SYNTH_TIMING_DERATE)}]
Error: floorplan.tcl, 93 can't use empty string as operand of "-"
child process exited abnormally

Solution: Set DIE_AREA to correct value, see https://github.com/The-OpenROAD-Project/OpenLane/issues/1189



Include the RTL files in the design
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Understanding the synthesis
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This guide does not cover other tools. But if your design is written VHDL you can use. If you use SystemVerilog then you should use sv2v and surelog.

.. todo:: add the vhdl related info
.. todo:: add the sv2v/surelog related info

Exploring your designs
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^





Wirebond
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Wirebond places the die area in the plastics mold.
Then wire bond connection is soldered from the pad on die area to the pad on the package.

.. figure:: https://upload.wikimedia.org/wikipedia/commons/thumb/f/f7/071R01.jpg/640px-071R01.jpg

    Wirebond Integrated Circuit. Source: https://commons.wikimedia.org/wiki/File:071R01.jpg

Main downside of wirebond is parasitics of the wires.
In contrast to this, the length of Flip Chip connection is much shorter, therefore parasitics are lower.


Flip Chip
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Flip Chip is different from Wirebond by both the connection method and package pad structure.
Wirebond typically places the pads on the edges of the package,
meanwhile Flip Chip typically places the pads underneath the integrated circuit.
The die is placed upside-down, where metal layers are closer to the circuit board (PCB),
meanwhile in Wire bond die is typically placed with metal layers on the upper side of the integrated circuit, further from the circuit board.

.. figure:: https://upload.wikimedia.org/wikipedia/commons/thumb/e/ed/Flip_chip_side-view.svg/640px-Flip_chip_side-view.svg.png

    Flip Chip schematic representation. Note the balls, directly soldered to the pads of the die. Source: https://commons.wikimedia.org/wiki/File:Flip_chip_side-view.svg

Main advantage of Flip Chip is the increased pad density.
The big chips, like CPUs and GPUs, useFlip Chip because they have multiple thousands of pads.

Downside is the need to have a separate mask for layer called ``AP``. Tapeouts on OpenMPW of Google/Efabless uses Flip Chip and AP layer is fixed.

.. figure:: https://github.com/efabless/caravel/raw/main/docs/source/_static/caravel.png
    :scale: 50 %

    Caravel's AP layer. Note the connections to bottom metal layers and pad drivers on the edges
    You can also notice the connection between the pads and the pad drivers using AP layer. Source: https://caravel-harness.readthedocs.io/en/latest/supplementary-figures.html

Even though the location of the pads on the caravel user project is on the sides,
Flip Chip provides the benefit of improved pads density and smaller packages.

.. todo:: comparison between BGA and LQFP
