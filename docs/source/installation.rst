
Installation
================================================================================

Step 1. System Requirements
--------------------------------------------------------------------------------

   * Docker 19.03.12+
   * Git 2.35+
   * Python 3.6+  
      * pip  
      * venv
   * GNU Make

After installing all of the above, proceed to make Docker
available without sudo command.

Docker images and their purpose
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Many open-source projects in the space are struggling with reproducibility.
It is practically **impossible to create perfectly same environment**
across many Operating Systems and distributions.
The reasonable suggestion would be to use virtual machines,
however virtual machines are heavy, hard to build and take up a lot of space.

As a better alternative the concept of containers is introduced.
They run on top of your existing kernel, however everything on top of it,
like ``libc`` and system libraries are under control of the container.

For this specific reason, it was decided to use containers and `Docker <https://en.wikipedia.org/wiki/Docker_(software)>`_ was selected as container engine.
It saves you the struggle of installation,
since the **prebuilt binaries are included in an isolated environment** inside the container.

Installation of requirements on Ubuntu
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You need at least Ubuntu 20.04 and above. All of the required packages are included in the Docker image, so the installation list is slim.

.. code-block:: console

   sudo apt install -y build-essential python3 python3-venv python3-pip make git



.. image:: ../_static/installation/successful_package_requirements_installation.png

Second you need to install Docker. Follow `instructions provided in documentation of the Docker  here <https://docs.docker.com/engine/install/ubuntu/>`_ as steps provided below might be outdated.

.. warning::
    The steps below might be simply outdated, it is encouraged to follow the link to the official Docker documentation


.. code-block:: console

   # Remove old installations
   sudo apt-get remove docker docker-engine docker.io containerd runc
   # Installation of requirements
   sudo apt-get update
   sudo apt-get install \
      ca-certificates \
      curl \
      gnupg \
      lsb-release
   # Add the keyrings of docker
   sudo mkdir -p /etc/apt/keyrings
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
   # Add the package repository
   echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   # Update the package repository
   sudo apt-get update

   # Install Docker
   sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

   # Check for installation
   sudo docker run hello-world

After installation you will get Hello World of Docker:

.. image:: ../_static/installation/docker_installation_hello_world.png

Now follow step 2.


Installation of requirements under macOS
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

First install `Homebrew <https://brew.sh/>`_ then run script below to install the required packages:

.. code-block:: console

   brew install python make
   brew install --cask docker

Proceed to Step 2.

Requirements in Containerless/Local Installations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. warning::
   OpenLane encourages you to avoid using Containerless/Local installation method. As the version of the packages can affect the performance and reproducibility. Most of the documentation assumes that you are using Docker based flow, but if you choose to use containerless installation, then you are on your own.

Please see `local installation <local_installs.html>`_

Step 2. Making Docker available without root
--------------------------------------------------------------------------------

.. warning::
    The steps below might be simply outdated, it is recommended to follow the link to the official Docker documentation

This is a **mandatory step**, without this all of OpenLane scripts will fail. Follow `instructions here <https://docs.docker.com/engine/install/linux-postinstall/>`_ or you can use a script below, but keep in mind that by the point you are reading this it might be outdated.


.. important::
    This is mandatory step. Without this most of OpenLane scripts will be confused and error out with permission issues. This step caused a lot of confusion because it needs to be done after the installation of the Docker. DO NOT SKIP!


.. code-block:: console

   sudo groupadd docker
   sudo usermod -aG docker $USER
   sudo reboot # REBOOT!

You **must restart your operating system** for the group permissions to apply.

.. image:: ../_static/installation/docker_permission.png


Step 3. Checking the docker installation
--------------------------------------------------------------------------------

After that you can run Docker Hello World without root. To test it use following command:

.. code-block:: console

   # After reboot
   docker run hello-world

You will get a little happy message of Hello world, once again, but this time without root.

.. image:: ../_static/installation/docker_without_sudo_done.png

Troubleshooting of Step 3.
--------------------------------------------------------------------------------

If you get permission error then you skipped a step or two. Did you forget to reboot?

.. image:: ../_static/installation/docker_permission_issue.png


Step 4. Checking the requirements
--------------------------------------------------------------------------------

In order to check installation, you can use following commands:

.. code-block:: console

   git --version
   docker --version
   python3 --version
   python3 -m pip --version
   make --version
   python -m venv -h

.. image:: ../_static/installation/version_check.png

Step 5. Installing OpenLane
--------------------------------------------------------------------------------

Clone OpenLane repository and change directory into it. Then install the sky130 PDK and run flow on the test design.

.. code-block:: console

   git clone --depth 1 https://github.com/The-OpenROAD-Project/OpenLane.git
   cd OpenLane/
   make
   make test # This a ~5 minute test that verifies that the flow and the pdk were properly installed

.. image:: ../_static/installation/git_clone_openlane.png

After the above script downloads OpenLane and installs it, the ``make test`` command will test the installation of PDK and OpenLane

.. image:: ../_static/installation/successful_make_test.png


Updating OpenLane
--------------------------------------------------------------------------------

To update the OpenLane, run following commands:

.. code-block:: console

   cd OpenLane/
   git pull --depth 1 https://github.com/The-OpenROAD-Project/OpenLane.git master
   make
   make test # This is to test that the flow and the pdk were properly updated


