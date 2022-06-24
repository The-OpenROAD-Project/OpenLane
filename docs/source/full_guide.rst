Full Guide
================================================================================

The end goal for OpenLane flow is to generate an `integrated circuit <https://en.wikipedia.org/wiki/Integrated_circuit>`_
that can be produced by the foundry.
OpenLane is one of the leading-edge Open-Source tools created exactly for this purpose.


.. note:: This guide assumes that you already have the `OpenLane installed using this guide <installation.html>`_ and you already successfully `completed the quickstart here <quickstart.html>`_.

.. todo:: Add a picture that is under CC or similar license.

.. todo:: Add links to the Wikipedia covering every word.

Multiple foundries exist and each of the foundries may have dozens of technologies supported.
Currently, OpenLane supports only Skywater130,
which was published by `Google in cooperation with Skywater <https://github.com/google/skywater-pdk>`_,
but there is active work to support `fictional technologies like ASAP7 <https://asap.asu.edu/>`_ and other PDKs. There is a guide on `porting new PDKs to OpenLane located here <pdk_structure.html>`_ .

The coolest part about Skywater130 is `Google funded Multi Project Wafer in partnership with Efabless <https://efabless.com/open_shuttle_program>`_.
Using OpenMPW you can produce your integrated circuit for free (some limitations apply).

This guide covers everything that you need to know in order to be able to create a final integrated circuit layout files, 
which if done correctly can be produced by the foundry. As part of this tutorial we will make a simple bottom-to-top design utilizing as many features of OpenLane as we can.

In this example we are going to create a simple memory macro, generate the layout files for it,
then use the generated memory to make a top level chip register file.
While the guide covers only digital blocks, the digital macro blocks can be replaced by analog macros.
Use `this guide to create the required files <custom_macros.html>`_.

Introduction into the flow
--------------------------------------------------------------------------------

.. todo:: Make high level image showcasing the flow

Step 1. Create the memory macro design
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Let's create the design. The following command will create a directory ``design/mem_1r1w/`` and one file ``config.tcl`` that will be mostly empty.
.. code-block:: console

    ./flow.tcl -design mem_1r1w -init_design_config


Step 2. Create the RTL files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Then we need to create/copy the RTL files. The recommended location for files is ``design/mem_1r1w/src/``. Let's put a simple counter in there.

Create ``design/mem_1r1w/src/mem_1r1w.v`` file and put following content:

.. code-block:: verilog

    module mem_1r1w (clk, read_addr, read, read_data, write_addr, write, write_data);
        parameter DEPTH_LOG2 = 5;
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
    therefore you need to avoid making small macro blocks.


Add following lines:

set ::env(DESIGN_IS_CORE) 0
set ::env(FP_PDN_CORE_RING) 0
set ::env(RT_MAX_LAYER) "met4"

.. todo:: explain why

Include the RTL files in the design
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Understanding the synthesis
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This guide does not cover other tools. But if your design is written VHDL you can use. If you use SystemVerilog then you should use sv2v and surelog.

.. todo:: add the vhdl related info
.. todo:: add the sv2v/surelog related info

Exploring your designs
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
