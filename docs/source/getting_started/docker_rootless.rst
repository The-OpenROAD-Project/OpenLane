
Making Docker available without root
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. warning:: The steps below might be simply outdated, it is recommended to follow the link to the official Docker documentation

This is a **mandatory step**, without this all of OpenLane scripts will fail. Follow `instructions here <https://docs.docker.com/engine/install/linux-postinstall/>`_ or you can use a script below, but keep in mind that by the point you are reading this it might be outdated.


.. important::
    This is mandatory step. Without this most of OpenLane scripts will be confused and error out with permission issues. This step caused a lot of confusion because it needs to be done after the installation of the Docker. DO NOT SKIP!


.. code-block::

   sudo groupadd docker
   sudo usermod -aG docker $USER
   sudo reboot # REBOOT!

You **must restart your operating system** for the group permissions to apply.

.. code-block::

   sudo groupadd docker
   sudo usermod -aG docker $USER
   groupadd: group 'docker' already exists
