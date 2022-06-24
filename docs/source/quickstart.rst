Quick start
=======================

Overview
------------------------------------
OpenLane is an automated RTL to GDSII flow based on several components including OpenROAD, Yosys, Magic, Netgen, CVC, SPEF-Extractor, CU-GR, Klayout and a number of custom scripts for design exploration and optimization.
The flow performs full ASIC implementation steps from RTL all the way down to GDSII.

The tool encapsulates the underlying tools to allow engineers to configure them all in one place: ``config.tcl``. This file contains assignments to the variables that flow uses. 

The rest of the tutorial assumes `OpenLane installation <installation.html>`_ has been complete.

Entering the OpenLane environment
------------------------------------------------------------------------
.. note::
    If you installed OpenLane following `local installation <local_installs.html>`_ steps, then you are on your own.

OpenLane uses Docker to create reproducible environment for your projects. You don't need any extra steps to run the Docker image, as Makefile already takes care of it. Just run following command to enter OpenLane environment:

.. code-block::

    make mount


Creating new designs
------------------------------------------------------------------------

.. warning:: This guide assumes that you are running inside ``make mount`` Docker image. If you are not running inside docker that run ``make mount`` before following steps below

The ``./flow.tcl`` is the entry point for OpenLane.
This script is used to run the interactive sessions,
select the configuration and create OpenLane design files.

To add a new design, the following command creates a configuration file for your design:

.. code-block:: console

    ./flow.tcl -design <design_name> -init_design_config

This will create the following directory structure:

.. code-block:: console

    designs/<design_name>
    ├── config.tcl

``config.tcl`` is a global configuration for all PDKs. For more information about design `configuration files please visit this page <configuration.html>`_. In the configuration file, you should edit the required variables and the optional variables, if needed.

The ``design_name`` could be  replaced by the ``design_directory``, which will allow you to run any design on your machine.

It is recommended to place the design's verilog files in a ``src`` directory inside the design's folder as following:

.. code-block:: console

    designs/<design_name>
    ├── config.tcl
    ├── src
    │   ├── design.v

However, you can point to the source files while initializing the design and they will be pointed to automatically in the configuration file and will also be automatically copied to the src directory creating the same structure shown above.

.. code-block:: console

    ./flow.tcl -design <design_name> -init_design_config -src <list_verilog_files>

.. todo:: Add proper screenshot showcasing how source is copied and the directory structure using ``tree command``

You can find more information regarding the `./flow.tcl` in the documentation here. And here is the `reference documentation regarding the configuration valirables <configuration.html>`_.

Running the flow
------------------------------------------------------------------------

In order to run the flow you need to execute following commands:

.. code-block:: console

    ./flow.tcl -design <design_name>

This will run the flow for design ``<design_name>``.

Now that you know how to run the flow for your design, let's actually take a deep dive into real life example. Take a look `at the full guide here <full_guide.html>`_.

.. todo:: Add a screenshot or log

.. todo:: Add links to the follow up guide

Advanced: Using custom PDK locations and Docker images
-----------------------------------------------------------
.. warning::
    If you accidently used wrong version of PDK or OpenLane docker image then you might have *significant issues* down the line. *Avoid overwriting PDK on your own or using different OpenLane images*, if you don't know what are you doing then do not set any of those variable.

While this is not recommended, if you need to overwrite the location of PDK, then set the environment variable ``PDK_ROOT`` before running ``make mount``.
Another environment variable is ``OPENLANE_IMAGE_NAME``. It can be used to overwrite the Docker image that will be used but by default it's dynamically obtained using your current git version. Both ``PDK_ROOT`` and ``OPENLANE_IMAGE_NAME`` can be set independently. Example for setting both variables:

.. code-block::

    export PDK_ROOT=/opt/pdks
    export OPENLANE_IMAGE_NAME=efabless/openlane:ebad315d1def25d9d253eb2ec1c56d7b4e59d7ca
    make mount

Keep in mind, that if tool is unable to recognize the git commit, you might want to update the git, not set ``OPENLANE_IMAGE_NAME`` variable.

Advanced: Installing other Standard Cell Libraries
------------------------------------------------------------------------------------------------------------

