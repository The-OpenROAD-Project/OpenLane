
.. todo:: Rename the steps

Digital Design Flow
--------------------------------------------------------------------------------
This example covers creation of simple memory macro. This guide uses generated layout files for it,
then use the generated memory to make a top level chip register file.

Create the memory macro design
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Let's create the design. The following command will create a directory ``design/mem_1r1w/`` and one file ``config.json`` that will be mostly empty.

.. code-block:: console

    ./flow.tcl -design mem_1r1w -init_design_config -add_to_designs


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

Create the RTL files
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
    therefore you need to avoid making small macro blocks. For this, set the ``FP_SIZING`` to ``absolute`` and configure ``DIE_AREA`` to be bigger than ``200um x 200um`` for sky130.

Configure mem_1r1w
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Modify the ``config.json`` to include following:

.. code-block::json

    "DESIGN_IS_CORE": false,
    "FP_PDN_CORE_RING": false,
    "RT_MAX_LAYER": "met4"

 
``DESIGN_IS_CORE`` controls the metal levels used for power routing, set it to ``false`` to use only lower levels.

``FP_PDN_CORE_RING`` is set to ``false`` to disable a ring around the macro block.

``RT_MAX_LAYER`` set to ``met4`` to limit metal layers allowed for routing.

More information on `configuration can be found here <configuration>`_. 

.. todo:: explain why

.. todo:: PDN

Run the flow on the macro block
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: console

    ./flow.tcl -design mem_1r1w -tag full_guide -overwrite

Step 4. Analyzing the flow generated files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Step 5. Create chip level
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

./flow.tcl -design regfile_2r1w -init_design_config -add_to_designs

Step X. Integrate the macros
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Copy the macro blocks related stuff

.. code-block:: console

    mkdir designs/regfile_2r1w/lef/
    cp designs/mem_1r1w/runs/full_guide/results/final/lef/mem_1r1w.lef designs/regfile_2r1w/lef/

    mkdir designs/regfile_2r1w/gds/
    cp designs/mem_1r1w/runs/full_guide/results/final/gds/mem_1r1w.gds designs/regfile_2r1w/gds/

Then add links to the macro blocks in ``config.json``:

.. code-block:: json

    "EXTRA_LEFS":      "dir::lef/*.lef",
    "EXTRA_GDS_FILES": "dir::gds/*.gds",
    "VERILOG_FILES_BLACKBOX": "dir::bb/*.v"

Step X. Run the flow
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Run the flow. It is expected for the flow to fail. In next step, explaination is provided.

.. code-block:: console

    ./flow.tcl -design regfile_2r1w -tag full_guide_broken_aspect_ratio -overwrite


Step X. First issue
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Flow is expected to fail.

.. code-block:: console

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

To debug this issue, open an OpenROAD GUI:

.. code-block:: console

    openroad -gui

    read_lef $::env(PDK_ROOT)/sky130B/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef
    read_lef designs/regfile_2r1w/runs/full_guide_broken_aspect_ratio/tmp/merged.nom.lef

    read_def designs/regfile_2r1w/runs/full_guide_broken_aspect_ratio/tmp/placement/5-global.macro_placement.def


.. figure:: ../_static/digital_flow/broken_aspect_ratio.png

Issue is noticed. As can be observed in the image, placement of the mem_1r1w instanced failed.
It was unable to place the macro blocks inside the ``DIE_AREA``.
While the area is enough, there is no combination of placement for this cells that fits.

Change the ``FP_ASPECT_RATIO`` value to ``2``.
This will make the flooplan a rectange instead of square and the rectangle will be double in height compared to width.

``config.json`` should look like this:

.. code-block:: json

    {
        "DESIGN_NAME": "regfile_2r1w",
        "VERILOG_FILES": "dir::src/*.v",
        "CLOCK_PORT": "clk",
        "CLOCK_PERIOD": 10.0,
        "DESIGN_IS_CORE": true,
        "EXTRA_LEFS":      "dir::lef/*.lef",
        "EXTRA_GDS_FILES": "dir::gds/*.gds",
        "VERILOG_FILES_BLACKBOX": "dir::bb/*.v",
        "FP_ASPECT_RATIO": 2
    }


Step X. Run the flow again
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Run the flow again. This time it should no longer fail.

.. code-block:: console

    ./flow.tcl -design regfile_2r1w -tag full_guide -overwrite




Step X. Analyzing the results
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Open OpenROAD GUI to view the results of the flow.

.. code-block:: console

    openroad -gui

    read_lef $::env(PDK_ROOT)/sky130B/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd__nom.tlef
    read_lef designs/regfile_2r1w/runs/full_guide/tmp/merged.nom.lef

    read_def designs/regfile_2r1w/runs/full_guide/results/final/def/regfile_2r1w.def





Viewing final GDS

   klayout -e -nn $PDK_ROOT/sky130A/libs.tech/klayout/tech/sky130A.lyt \
      -l $PDK_ROOT/sky130A/libs.tech/klayout/tech/sky130A.lyp \
      ./designs/regfile_2r1w/runs/full_guide/results/final/gds/regfile_2r1w.gds


Troubleshooting:

.. code-block:: console

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


Exploring your designs
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


.. todo:: LVS, DRC, etc, debugging

.. todo:: Updated 
