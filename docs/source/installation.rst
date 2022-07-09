============
Installation
============

Prerequisites
-------------
   
    * GNU Make

    * Python 3.6+ with pip and venv

    * Git 2.35+

    * Docker 19.03.12+

Installing Packages in Ubuntu
-----------------------------
.. code-block:: shell

    sudo apt install -y build-essential python3 python3-venv python3-pip



Installing Docker
-------------------
Install docker follows the instruction provided in the below link.

* `Docker installation instruction <https://docs.docker.com/engine/install/ubuntu/>`_

After installing Docker restart your Machine

Checking Docker Installation
----------------------------
Run the below commands

.. code-block:: shell

    $ group
    user_name adm cdrom sudo dip plugdev lpadmin lxd sambashare docker    #Docker installed properly


Installation in macOS
------------------------
First get `Homebrew <https://brew.sh/>`_ then install the required packages:

.. code-block:: shell

     brew install python make
     brew install --cask docker

    


Containerless/local Installation
--------------------------------

.. important::
    Run the OpenLane without docker , you must set up all the tool in your machine using the instruction link below:

Please click `local installation <local_installs.html>`_



Setting up OpenLane
---------------------
first clone the repository:

.. code-block:: shell

    git clone  https://github.com/The-OpenROAD-Project/OpenLane.git


Set up Sky130-PDK and OpenLane by running:


.. code-block:: shell

    cd OpenLane/
    make OpenLane
    make pdk
    make test # This is to test the flow and pdk run properly.


By Default [PDK_ROOT] ``$pwd/pdks``. If it need to installed it in a different directory set the following variable before running ``make pdk``:

.. code-block:: console

    export PDK_ROOT=<absolute path to where skyWater-pdk, open-pdk and sky130A reside>


The above variable could be set in the `.bashrc file <https://cloudzy.com/knowledge-base/linux-bashrc/>`_ to set the PDK path. 



Updating OpenLane
-----------------
if you clone the repository locally, don't need to reclone it 

.. code-block:: shell

    cd OpenLane
    git checkout master
    git pull
    make 
    make test

    






