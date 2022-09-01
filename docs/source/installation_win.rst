Installation on Windows 10/11 using WSL
================================================================================

1. Follow `official Microsoft documentation for WSL located here <https://docs.microsoft.com/en-us/windows/wsl/install>`_ to install the WSL 2. Make sure your OS version supports WSL 2.
2. Follow `official steps to Install Docker Desktop on Windows located here <https://docs.docker.com/desktop/install/windows-install/>`_.
3. Install Ubuntu using wsl ``wsl --install -d Ubuntu``
4. Press Start and select Ubuntu and follow steps below

.. figure:: ../_static/installation/wsl.png

.. include:: wsl_ubuntu_packages.rst
.. include:: installation_common_section.rst