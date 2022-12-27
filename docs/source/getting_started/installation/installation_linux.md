# Other Linux

```{include} installation_overview.md
```

## Installation steps

## Installation of Required Packages

For OpenLane you need a couple of tools installed:

* Docker 19.03.12+
    * Docker post-installation steps for running without root
* Git 2.35+
* Python 3.6+ with pip/venv
* GNU Make

Please install all of these dependencies using your package manager. Please
note that while alternative container services such as podman do work, they are not
supported.

## Docker Installation

First, install Docker following the steps provided [in this link](https://docs.docker.com/engine/install/).

Test if installation was successful:

```
sudo docker run hello-world
```

A sccessful installation of Docker looks like this:

```
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
```

```{include} docker_no_root.md
```
```{include} installation_common_section.md
```
