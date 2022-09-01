Installation on Ubuntu
================================================================================

OpenLane uses Docker images that contain binaries,
libraries and packages ready-to-use.
All of the flow tools are encapsulated inside the container image

Open source projects typically have to address the challenge of variable user environments,
operating systems, virtual machines, cloud based distribution etc.
Docker containers alleviate this problem; they are easy to install and encapsulate a large amount of underlying complexity.

OpenLane uses `Docker <https://en.wikipedia.org/wiki/Docker_(software)>`_. It was selected as container engine to simplify the installation process by including pre-built binaries and PDK within the container.

Only Ubuntu 20.04 and above are supported.

.. include:: wsl_ubuntu_packages.rst

Docker Installation
--------------------------------------------------------------------------------
Next install Docker.
Follow `instructions provided in documentation of the Docker  here <https://docs.docker.com/engine/install/ubuntu/>`_ as steps provided below might be outdated.

.. warning::
    The steps below might be simply outdated, it is encouraged to follow the link to the official Docker documentation


.. code-block::

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