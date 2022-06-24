============
Installation
============

Prerequisites
-------------
   
    * GNU Make

    * Python 3.6+ with pip and virtualenv

    * Git 2.35+

    * Docker 19.03.12+

1.Installing Packages in Ubuntu 20.04 +
---------------------------------------
.. code-block:: console
    sudo apt install -y build-essential python3 python3-venv python3-pip


Installing Docker
-------------------
Install docker follows the instruction provided in the below link.

* _`Docker installation instruction<https://docs.docker.com/engine/install/ubuntu/>`_

After installing Docker restart your Machine

Checking Docker Installation
----------------------------
Run the below commands
.. code-block:: console
    $ group
    
    user_name adm cdrom sudo dip plugdev lpadmin lxd sambashare docker    #Docker installed properly

Installation in Mac OS X
------------------------
First get _`Homebrew<https://brew.sh/>`_ then install the required packages:

.. code-block:: console
     brew install python make
     brew install --cask docker
    


Containerless/local Installation
--------------------------------

.. note::
    Run the OpenLane without docker , you must set up all the tool in your machine using the instruction link below:

Please see `local installation <local_installs.html>`_



2.Setting up OpenLane
---------------------
first clone the repository:
.. code-block:: console
    git clone https://github.com/The-OpenROAD-Project/OpenLane.git

Set up Sky130-PDK and OpenLane by running:
.. code-block:: console
    cd OpenLane/ 
    make openlane # This will pull Openlane docker image. 
    make pdk # Default PDK_ROOT is $(pwd)/pdks. If you want to install the PDK at a differnt location, uncomment the next line. #export PDK_ROOT=<absolute path to where skywater-pdk and open_pdks will reside>
    make test # This is to test that the flow and the pdk were properly inst #This test run the design spm. Check the final generated layout at this path ../designs/spm/runs/openlane_test/results/magic/spm.gds.

Updating OpenLane
-----------------
If you already have the repo locally, then there is no need to re-clone it. You can run the following:

.. code-block:: console
     cd OpenLane/
     git checkout master
     git pull
     make 
     make test # This is to test that the flow and the pdk were properly updated





