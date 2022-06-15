
Step 1. Installation of Requirements
------------


Step 1.1. Installation of packages in Ubuntu
===========
All of the required packages are included in the Docker image, so the list of packages is slim.

.. code-block:: console

   sudo apt install -y build-essential python3 python3-venv python3-pip make git

Note: It is known issue that the git verison in Ubuntu before 21.04 does not satisfy the requirements.

Step 2. Installation of Docker
------------

First you need to install Docker. Follow `instructions provided in Docker's documentation here <https://docs.docker.com/engine/install/ubuntu/>`_ as steps provided below might be outdated.

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

After installation you will get docker's Hello World:

.. image:: ../_static/docker_installation_hello_world.png

Step 3. Making Docker available without root
------------

This is a **mandatory step**, without this all of the OpenLane scripts will fail. Follow `instructions here <https://docs.docker.com/engine/install/linux-postinstall/>`_ or you can use a script below, but keep in mind that by the point you are reading this it might be outdated.

.. code-block::

   sudo groupadd docker
   sudo usermod -aG docker $USER

Then you have to restart your operating system for the group permissions to apply. 

.. image:: ../_static/docker_permission.png

After that you can run Docker Hello World without root. Let's try it out:
.. code-block::

   # After reboot
   docker run hello-world

If you get permission error then you skipped a step or two. Did you forget to reboot?

.. image:: ../_static/installation_docker_permission_issue.png

Otherwise you will get a little happy message of Hello world, once again, but this time without root.


.. image:: ../_static/docker_without_sudo_done.png

Step 3. Checking the requirements
------------

