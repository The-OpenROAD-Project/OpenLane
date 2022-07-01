============
Installation
============

Prerequisites
-------------
   
    * GNU Make

    * Python 3.6+ with pip and virtualenv

    * Git 2.35+

    * Docker 19.03.12+

Installing Packages in Ubuntu 20.04 +
---------------------------------------
.. code-block:: console
    sudo apt install -y build-essential python3 python3-venv python3-pip


Installing Docker
-------------------
Install docker follows the instruction provided in the below link.

* `Docker installation instruction<https://docs.docker.com/engine/install/ubuntu/>`_

After installing Docker restart your Machine

Checking Docker Installation
----------------------------
Run the below commands
.. code-block:: console
    $ group
    
    user_name adm cdrom sudo dip plugdev lpadmin lxd sambashare docker    #Docker installed properly

Installation in macOS
------------------------
First get `Homebrew<https://brew.sh/>`_ then install the required packages:

.. code-block:: console
     brew install python make
     brew install --cask docker
    


Containerless/local Installation
--------------------------------

.. note::
    Run the OpenLane without docker , you must set up all the tool in your machine using the instruction link below:

Please click `local installation <local_installs.html>`_



Setting up OpenLane
---------------------
first clone the repository:
.. code-block:: console
    git clone https://github.com/The-OpenROAD-Project/OpenLane.git

Set up Sky130-PDK and OpenLane by running:


.. code-block:: console
    cd OpenLane/
    make Openlane
    make pdk
    make test # This is to test the flow and pdk run properly.
    

Updating OpenLane
-----------------
if you clone the repository locally , don't need to reclone it 

.. code-block:: console
    cd Openlane
    git checkout master
    git pull
    make 
    make test
    






