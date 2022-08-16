Quick start
=======================
Overview
------------------------------------
OpenLane is an automated RTL-to-GDSII flow that uses open-source tools like OpenROAD,
Yosys, Magic, Netgen, CVC, OpenRCX, CU-GR, KLayout.
It also provides a number of custom scripts for design exploration, optimization and ECO.

The flow performs a complete synthesis, floorplanning, placement and routing of your designs.
Currently it supports sky130 PDK but adding custom PDKs is fairly simple.

The tool encapsulates the underlying tools to allow users to configure them all in one place: ``config.json/tcl``. This file contains assignments to the variables that flow uses. 

The rest of the tutorial assumes `OpenLane installation <installation.rst>`_ is done.
This guide covers running the flow on existing desings, adding new designs and quick overview of the design directory strucutre.

Starting OpenLane
------------------------------------------------------------------------
**Note**
    If you installed OpenLane following `local installation <local_installs.html>`_ steps, then you are on your own.

OpenLane uses Docker to create reproducible environment for your projects. You don't need any extra steps to run the Docker image, as Makefile already takes care of it. Just run following command to enter OpenLane environment:

.. code-block:: console

    cd OpenLane/
    make mount


Running the flow
------------------------------------------------------------------------


In order to run the flow you need to execute following command:

.. code-block:: console

    ./flow.tcl -design <design_name>

For design named ``gcd`` the command looks like this:

.. code-block:: console

    ./flow.tcl -design gcd


Creating new designs
------------------------------------------------------------------------

**!!warning!!** This guide assumes that you are running inside Docker image. Dockerless installation is not supported.

First, start OpenLane Docker image using following command:

.. code-block:: console

    cd OpenLane/
    make mount


The ``./flow.tcl`` is the entry point for OpenLane.
This script is used to run the flow, run the interactive sessions,
select the configuration and create OpenLane design files.

To add a new design, the following command creates a configuration file for your design:

.. code-block:: console

    ./flow.tcl -design <design_name> -init_design_config -add_to_designs

This will create the following directory structure:

.. code-block:: console

    designs/<design_name>
    ├── config.json

``config.json`` is a global configuration for all PDKs. For more information about design `configuration files please visit this page <configuration.md>`_. In the configuration file, you should edit the required variables and the optional variables, if needed.

The ``design_name`` could be  replaced by the ``design_directory``, which will allow you to run any design on your machine.

It is recommended to place the design's verilog files in a ``src`` directory inside the design's folder as following:

.. code-block:: console

    designs/<design_name>
    ├── config.json
    ├── src
    │   ├── design.v

However, you can point to the source files while initializing the design and they will be pointed to automatically in the configuration file and will also be automatically copied to the src directory creating the same structure shown above.

.. code-block:: console

    ./flow.tcl -design <design_name> -init_design_config -src <list_verilog_files>


This is typical structure of the design folder:

.. code-block:: console

    .
    ├── config.json
    ├── runs
    │   └── RUN_2022.06.24_16.52.13
    │       ├── cmds.log
    │       ├── config.json
    │       ├── logs
    │       ├── openlane.log
    │       ├── OPENLANE_VERSION
    │       ├── PDK_SOURCES
    │       ├── reports
    │       ├── results
    │       ├── runtime.yaml
    │       ├── tmp
    │       └── warnings.log
    └── src
        └── mem_1r1w.v

Main files are ``config.json`` and ``src/`` folder that contains source code.

You can find more information `regarding the ./flow.tcl in the documentation here <designs.md>`_. And here is the `reference documentation regarding the configuration valirables <configuration.md>`_.

Running the flow
------------------------------------------------------------------------

In order to run the flow you need to execute following commands:

.. code-block:: console

    ./flow.tcl -design <design_name>

This will run the flow for design ``<design_name>``.

Advanced: Using custom PDK locations and Docker images
-----------------------------------------------------------
.. warning::
    If you accidently used wrong version of PDK or OpenLane docker image then you might have *significant issues* down the line. *Avoid overwriting PDK on your own or using different OpenLane images*, if you don't know what are you doing then do not set any of those variable.

While this is not recommended, if you need to overwrite the location of PDK, then set the environment variable ``PDK_ROOT`` before running ``make mount``.
Another environment variable is ``OPENLANE_IMAGE_NAME``. It can be used to overwrite the Docker image that will be used but by default it's dynamically obtained using your current git version. Both ``PDK_ROOT`` and ``OPENLANE_IMAGE_NAME`` can be set independently. Example for setting both variables:

.. code-block:: console

    export PDK_ROOT=/opt/pdks
    export OPENLANE_IMAGE_NAME=efabless/openlane:ebad315d1def25d9d253eb2ec1c56d7b4e59d7ca
    make mount

Keep in mind, that if tool is unable to recognize the git commit, you might want to update the git, not set ``OPENLANE_IMAGE_NAME`` variable.
