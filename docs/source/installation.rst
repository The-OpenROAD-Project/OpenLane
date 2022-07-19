============
Installation
============

Prerequisites
=============
    * GNU Make

    * Python 3.6+ with pip and venv

    * Git 2.35+

    * Docker 19.03.12+

Installation of Required Packages in Ubuntu
-------------------------------------------------

.. code-block:: shell

    sudo apt install -y build-essential python3 python3-venv python3-pip



Installation of Docker
---------------------------
Install docker follows the instruction provided in the below link.

* `Docker installation instruction <https://docs.docker.com/engine/install/ubuntu/>`_

After installing Docker restart your machine.

Checking Docker Installation
-------------------------------------

After running ``sudo docker run hello-world`` the output is :

.. code-block:: shell

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

Troubleshooting
----------------------
if you get docker permission denied error when running docker image:

.. code-block:: shell

   docker: Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Post "http://%2Fvar%2Frun%2Fdocker.sock/v1.24/containers/create": dial unix /var/run/docker.sock: connect: permission denied.
   See 'docker run --help'.


check the user added to the docker group:

.. code-block:: shell

    groups   # to check docker installed and added to the docker group

if the output does not contain docker then the user must be added to the docker group by running the command:
 
.. code-block:: shell

    sudo usermod -aG docker <user_name>


After running the above command restart your machine and follow the above steps
    

Installation of Required Packages in macOS
-------------------------------------------------
First get `Homebrew <https://brew.sh/>`_ then install the required packages:

.. code-block:: shell

     brew install python make
     brew install --cask docker

    


Containerless/local Installation
================================


.. important::
    Run the OpenLane without docker , you must set up all the tool in your machine using the instruction link below:

Please click `local installation <local_installs.html>`_



Setting up OpenLane
===================
first clone the repository:

.. code-block:: shell

    git clone  https://github.com/The-OpenROAD-Project/OpenLane.git


Set up Sky130-PDK and OpenLane by running:


.. code-block:: shell

    cd OpenLane/
    make OpenLane
    make pdk
    make test # This is to test the flow and pdk run properly.

``make test`` will run the complete flow RTL to GDS of spm to test tools setup and pdk.
The final layout will generated at ``.design/spm/result/final/spm.gds``.

PDK location
=============

By Default [PDK_ROOT] ``$pwd/pdks``. If it need to installed it in a different directory set the following variable before running ``make pdk``:

.. code-block:: shell

    export PDK_ROOT=<absolute path to where skyWater-pdk, open-pdk and sky130A reside>

Updating OpenLane
===================
if you clone the repository locally, don't need to reclone it 

.. code-block:: shell

    cd OpenLane
    git checkout master
    git pull
    make 
    make test

    






