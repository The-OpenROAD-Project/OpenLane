Installation on Windows
================================================================================

.. include:: installation_overview.rst

OpenLane in Windows uses WSL 2 and Docker Destop on Windows.
Recent version of Windows 10 or Windows 11 is required, for more information consult Microsoft's documentation.
It is the recommended installation method under Windows. Other variants like Virtual Machines are not supported.


1. Follow `official Microsoft documentation for WSL located here <https://docs.microsoft.com/en-us/windows/wsl/install>`_ to install the WSL 2. Make sure your OS version supports WSL 2.
2. Follow `official steps to Install Docker Desktop on Windows located here <https://docs.docker.com/desktop/install/windows-install/>`_.
3. Make sure that ``WSL 2 Docker engine`` is enabled
4. Make sure that option ``Start Docker Desktop when you login`` is enabled in ``Docker Desktop`` -> ``Settings``

.. figure:: ../../_static/installation/wsl_docker_settings.png

5. Click Windows icon, type in "Windows PowerShell" and open it.

.. figure:: ../../_static/installation/powershell.png

6. Install Ubuntu using wsl command: ``wsl --install -d Ubuntu``
7. Check the verison of WSL using following command: ``wsl --list --verbose``


It should produce following output:

.. code-block::

    PS C:\Users\user> wsl --list --verbose
    NAME                   STATE           VERSION
    * Ubuntu                 Running         2
    docker-desktop         Running         2
    docker-desktop-data    Running         2

If you get following output, then you need to start the `Docker Desktop on Windows`.

.. code-block::

    PS C:\Users\user> wsl --list --verbose
    NAME                   STATE           VERSION
    * Ubuntu                 Running         2
    docker-desktop         Stopped         2
    docker-desktop-data    Stopped         2

Or if you get this error similar to below, then you need to start the `Docker Desktop on Windows`.

.. code-block::

    ~/OpenLane$ docker run hello-world

    The command 'docker' could not be found in this WSL 2 distro.
    We recommend to activate the WSL integration in Docker Desktop settings.

    For details about using Docker Desktop with WSL 2, visit:

    https://docs.docker.com/go/wsl2/


8. Press Start and open Ubuntu
9. Follow steps below

.. figure:: ../../_static/installation/wsl.png

.. include:: wsl_ubuntu_packages.rst
.. include:: installation_common_section.rst