OpenLane uses Docker images that contain binaries,
libraries, and packages ready-to-use.
All of the flow tools are encapsulated inside the container image

Open source projects typically have to address the challenge of different user environments,
operating systems, virtual machines, cloud-based distribution etc.
Docker containers solve this problem.
The containers are easy to install and encapsulate a large amount of underlying complexity.

OpenLane uses `Docker <https://en.wikipedia.org/wiki/Docker_(software)>`_.
It was selected as the container engine to simplify the installation process
by including pre-built binaries and PDK within the container.
