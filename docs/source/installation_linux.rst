
Installation on Linux
================================================================================
OpenLane uses Docker images that contain binaries,
libraries and packages ready-to-use.
All of the flow tools are encapsulated inside the container image

Open source projects typically have to address the challenge of variable user environments,
operating systems, virtual machines, cloud based distribution etc.
Docker containers alleviate this problem; they are easy to install and encapsulate a large amount of underlying complexity.

OpenLane uses `Docker <https://en.wikipedia.org/wiki/Docker_(software)>`_. It was selected as container engine to simplify the installation process by including pre-built binaries and PDK within the container.

Installation steps
--------------------------------------------------------------------------------

Installation of Required Packages
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For OpenLane you need a couple of tools installed:

   * Linux or macOS
   * Docker 19.03.12+
      * Docker post install for running without root access
   * Git 2.35+
   * Python 3.6+  
      * pip  
      * venv
   * GNU Make

Docker Installation
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
First `install Docker following steps provided here <https://docs.docker.com/engine/install/>`_.

Test if installation was successful:

.. code-block::

   sudo docker run hello-world


Successful installation of Docker looks like this:

.. code-block::

   Hello from Docker!
   This message shows that your installation appears to be working correctly.

   To generate this message, Docker took the following steps:
   1. The Docker client contacted the Docker daemon.
   2. The Docker daemon pulled the "hello-world" image from the Docker Hub. (amd64)
   3. The Docker daemon created a new container from that image which runs the executable that produces the output you are currently reading.
   4. The Docker daemon streamed that output to the Docker client, which sent it to your terminal.

   To try something more ambitious, you can run an Ubuntu container with:
   $ docker run -it ubuntu bash

   Share images, automate workflows, and more with a free Docker ID:
   https://hub.docker.com/

   For more examples and ideas, visit:
   https://docs.docker.com/get-started/

.. include:: docker_rootless.rst
.. include:: installation_common_section.rst
