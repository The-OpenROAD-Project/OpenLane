Quick start guide
--------------------

Overview
==================
OpenLane is an automated RTL to GDSII flow based on several components including OpenROAD, Yosys, Magic, Netgen, CVC, SPEF-Extractor, CU-GR, Klayout and a number of custom scripts for design exploration and optimization.
The flow performs full ASIC implementation steps from RTL all the way down to GDSII.

The tool encapsulates the underlying tools to allow engineers to configure them all in one place: ``config.tcl``. This file contains assignments to the variables that flow uses. 

The rest of the tutorial assumes :ref:`_installation_label` has been complete.

Entering the OpenLane environment
====================================
.. note::
    If you installed OpenLane following local installation steps, then you are on your own.

OpenLane uses Docker to create reproducible environment for your projects. You don't need any extra steps to run the Docker image, as Makefile already takes care of it. Just run following command to enter OpenLane environment:

.. code-block::

    make mount




Creating new designs
====================================


Advanced: Using custom PDK locations and Docker images
===========================
.. warning::
    If you accidently used wrong version of PDK or OpenLane docker image then you might have *significant issues* down the line. *Avoid overwriting PDK on your own or using different OpenLane images*, if you don't know what are you doing then do not set any of those variable.

While this is not recommended, if you need to overwrite the location of PDK, then set the environment variable ``PDK_ROOT`` before running ``make mount``.

Another environment variable is ``OPENLANE_IMAGE_NAME``, but by default it's dynamically obtained using your current git version. Example:

.. code-block::

    export PDK_ROOT=/opt/pdks
    export OPENLANE_IMAGE_NAME=efabless/openlane:ebad315d1def25d9d253eb2ec1c56d7b4e59d7ca-amd64
    make mount

Keep in mind, that if tool is unable to recognize the git commit, you might want to update the git, not set ``OPENLANE_IMAGE_NAME`` variable.

Advanced: Installing other Standard Cell Libraries
========================================================

Understanding general digital design flow
------------------------------------------------------

RTL
==================
RTL stands for Register Transfer Level. RTL is accepted by Yosys + abc.

Testbenches
==================

Synthesis
==================

Static timing analysis
====================================

Floorplanning
==================

IO Placement
^^^^^^^^^^^^^^

Macro placement
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Power grid
^^^^^^^^^^^^^^

Currently OpenLane does not have integrated Electromigration flow. However, the Sky130's tech LEF files have the required parameters like DCCURRENTDENSITY.

Placement
==================

Understanding the placement issues
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Clock Tree Synthesis
====================================

Understanding the CTS, skew, etc
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Optimization
==================

Global routing
==================

Troubleshooting global routing
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Memory usage
^^^^^^^^^^^^^^

Detailed routing
====================================

Troubleshooting detailed routing
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Randomly crashing
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Memory usage by detailed router
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Final Static Timing Analysis
========================================