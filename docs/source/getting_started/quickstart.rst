Quick-Start Guide
=======================
Overview
------------------------------------

.. note:: This page assumes `OpenLane installation <installation.rst>`_ is done. If you have not yet installed OpenLane, please visit the link and follow the instructions there.

This guide covers running the flow on existing desings, adding new designs and quick overview of the design directory strucutre.

Starting the OpenLane Environment
------------------------------------------------------------------------
.. note:: If you installed OpenLane following `local installation <local_installs.html>`_ steps, these instructions will not entirely apply. We no longer actively support local installation.

OpenLane uses Docker to create a reproducible environment for your projects. You don't need any extra steps to run the Docker image, as the Makefile already takes care of it. Just run the following commands to enter the OpenLane environment:

.. code-block:: console

    cd OpenLane/
    make mount


Running the flow
------------------------------------------------------------------------

The entry point for OpenLane is the ``./flow.tcl`` script.

This script is used to run the flow, start interactive sessions,
select the configuration and create OpenLane design files.

In order to run the flow, you need to execute the following command:

.. code-block:: console

    ./flow.tcl -design <design_name>

For a design named ``gcd``, the invocation would look something like this:

.. code-block:: console

    ./flow.tcl -design gcd


Creating new designs
------------------------------------------------------------------------
The following command creates a new configuration file for your design:

.. code-block:: console

    ./flow.tcl -design <design_name> -init_design_config -add_to_designs

This will create the following directory structure:

.. code-block:: console

    designs/<design_name>
    ├── config.json

``config.json`` is a global configuration for all PDKs. For more information about design `configuration files please visit this page <configuration.html>`_. In the configuration file, you should edit the required variables and the optional variables, if needed.

The ``design_name`` could be replaced by the ``design_directory``, which will allow you to run designs from any folder in your machine.

It is recommended to place the design's Verilog files in a ``src`` directory inside the design's folder as following:

.. code-block:: console

    designs/<design_name>
    ├── config.json
    ├── src
    │   ├── design.v

However, you can also point to the source files while initializing the design and they will be pointed to automatically in the configuration file and will also be automatically copied to the src directory creating the same structure shown above.

.. code-block:: console

    ./flow.tcl -design <design_name> -init_design_config -src <list_verilog_files>


This is a typical structure for a design folder:

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

The main files are a configuration file and a ``src/`` folder that contains source code, as well as a ``runs`` folder that creates designs.

You can find more information `regarding the ./flow.tcl in the documentation here <designs.html>`_. And here is the `reference documentation regarding the configuration valirables <configuration.html>`_.

Advanced: Using custom PDK locations and OpenLane Docker images
---------------------------------------------------------------
.. warning::
    If you accidently use the wrong version of a PDK or the OpenLane Docker image,  then you may have *significant issues* down the line. If you don't know what you're doing, this section is not for you.

While this is not recommended, if you need to override the location of PDK, then set the environment variable ``PDK_ROOT`` before running ``make mount``.

Another environment variable is ``OPENLANE_IMAGE_NAME``. It can be used to override the Docker image that will be used but by default it's dynamically obtained using your current git version. Both ``PDK_ROOT`` and ``OPENLANE_IMAGE_NAME`` can be set independently. 

Here is an example for setting both variables:

.. code-block:: console

    export PDK_ROOT=$HOME/pdks
    export OPENLANE_IMAGE_NAME=efabless/openlane:ebad315d1def25d9d253eb2ec1c56d7b4e59d7ca
    make mount
