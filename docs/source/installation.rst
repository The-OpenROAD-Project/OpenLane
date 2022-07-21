
Installation
================================================================================
OpenLane uses Docker images that contain binaries, libraries and packages ready-to-use.
All of the flow tools are encapsulated inside the container image

Many open-source projects in the space are struggling with reproducibility.
It is practically **impossible to create perfectly same environment**
across many Operating Systems and distributions.
The reasonable suggestion would be to use virtual machines,
however virtual machines are heavy, hard to build and take up a lot of space.

Docker containers make things much easier and lightweight.
They run on top of your existing kernel
but libraries and binaries are isolated from the rest of the system.

For this specific reason, it was decided to use containers and `Docker <https://en.wikipedia.org/wiki/Docker_(software)>`_ was selected as container engine.
It saves you the struggle of installation,
since the **prebuilt binaries are included in an isolated environment** inside the container.

Installation steps
--------------------------------------------------------------------------------

Step 1. Installation of required packages
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For OpenLane you need a couple of tools installed:

   * Linux or macOS
   * Docker 19.03.12+
   * Git 2.35+
   * Python 3.6+  
      * pip  
      * venv
   * GNU Make

After installing all of the above, proceed to :ref:`step2`.


Installation of required packages under Ubuntu
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

You need at least Ubuntu 20.04 and above. All of the required packages are included in the Docker image, so the installation list is slim.

.. code-block:: bash

   sudo apt install -y build-essential python3 python3-venv python3-pip make git


Installation of Docker under Ubuntu
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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

Proceed to :ref:`step2`


Installation of required packages under macOS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

First install `Homebrew <https://brew.sh/>`_ then run script below to install the required packages:

.. code-block:: console

   brew install python make
   brew install --cask docker

Proceed to :ref:`step2`

Requirements in Containerless/Local Installations
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

.. warning::
   OpenLane encourages you to avoid using Containerless/Local installation method. As the version of the packages can affect the performance and reproducibility. Most of the documentation assumes that you are using Docker based flow, but if you choose to use containerless installation, then you are on your own.

Please see `local installation <local_installs.html>`_

.. _step2:
Step 2. Making Docker available without root
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. warning:: The steps below might be simply outdated, it is recommended to follow the link to the official Docker documentation

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
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

After that you can run Docker Hello World without root. To test it use following command:

.. code-block:: shell

   # After reboot
   docker run hello-world

You will get a little happy message of Hello world, once again, but this time without root.

.. code-block::

   Hello from Docker!
   This message shows that your installation appears to be working correctly.

   To generate this message, Docker took the following steps:
   1. The Docker client contacted the Docker daemon.
   2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
      (amd64)
   3. The Docker daemon created a new container from that image which runs the
      executable that produces the output you are currently reading.
   4. The Docker daemon streamed that output to the Docker client, which sent it
      to your terminal.

   To try something more ambitious, you can run an Ubuntu container with:
   $ docker run -it ubuntu bash

   Share images, automate workflows, and more with a free Docker ID:
   https://hub.docker.com/

   For more examples and ideas, visit:
   https://docs.docker.com/get-started/


Troubleshooting of Step 3.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

If you get Docker permission error when running any Docker images:

.. code-block:: console

   OpenLane> docker run hello-world
   docker: Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Post "http://%2Fvar%2Frun%2Fdocker.sock/v1.24/containers/create": dial unix /var/run/docker.sock: connect: permission denied.
   See 'docker run --help'.
   OpenLane> 

Then you skipped a step or two. You forgot to follow :ref:`step2` or `restart your Operating System`.

Step 4. Checking the requirements
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In order to check installation, you can use following commands:

.. code-block:: console

   git --version
   docker --version
   python3 --version
   python3 -m pip --version
   make --version
   python -m venv -h

.. image:: ../_static/installation/version_check.png

Step 5. Building and validating OpenLane installation
--------------------------------------------------------------------------------

In order to download and validate OpenLane installation run the following commands,
explanation of each step is provided below:

.. code-block:: console

   git clone --depth 1 https://github.com/The-OpenROAD-Project/OpenLane.git
   cd OpenLane/
   make # Building sky130 PDK
   make test # This a ~5 minute test that verifies that the flow and the pdk were properly installed

First step downloads shallow (small) copy of the OpenLane `cd`s into it.
Second step actually installs sky130 PDK,
but for proprietary PDKs you need to follow the steps in the integration guide of that specific PDK.
Last step runs ``spm`` design using the sky130 PDK.

.. image:: ../_static/installation/git_clone_openlane.png


This installs the latest, stable version of OpenLane. Then ``make test`` ensures that PDK and flow are installed correctly. THe command runs the flow on a small design called ``spm``.


.. image:: ../_static/installation/successful_make_test.png


This should produce a clean run for the ``spm``. The final layout can be found here: ``designs/spm/runs/openlane_test/results/final/gds/spm.gds``.

.. code-block:: console

   # Enter a Docker session:
   make mount

   # Open the spm.gds using KLayout with sky130 PDK
   klayout -e -nn $PDK_ROOT/sky130A/libs.tech/klayout/sky130A.lyt \
      -l $PDK_ROOT/sky130A/libs.tech/klayout/sky130A.lyp \
      ./designs/spm/runs/openlane_test/results/final/gds/spm.gds

   # Leave the Docker
   exit
This will open the window of KLayout in editing mode ``-e`` with sky130 technology.

.. image:: ../_static/installation/spm.png


Updating OpenLane
--------------------------------------------------------------------------------

To update the OpenLane, run following commands:

.. code-block:: console

   cd OpenLane/
   git pull --depth 1 https://github.com/The-OpenROAD-Project/OpenLane.git master
   make
   make test # This is to test that the flow and the pdk were properly updated

It is very similar to installation, one difference is
that we pull the changes instead of creating a new workspace.
Git pull will not remove your files inside workspace by default.
