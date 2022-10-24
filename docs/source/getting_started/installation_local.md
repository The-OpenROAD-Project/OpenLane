# Installation (Containerless/Local)

:::{warning}
The local installer is no longer actively supported. Unless you ***absolutely*** know what you're doing, please use the Docker image.
:::

At its core, OpenLane is a set of scripts working with a set of tools. If you'd like to avoid using a Docker container, you can, but you will have to set up all of the tools required by OpenLane on your computer. We do provide a best-effort script to assist you with that.

## Base Requirements
* Python 3.6+
    - pip
    - venv
    - pyyaml (`python3 -m pip install pyyaml`)
    
## Tool Library
You can run `python3 ./env.py tool-list` for a list. There are at least a dozen tools to install here. Luckily, you don't have to install them all one-by-one: There is an installation script that installs most of them.

You can invoke `python3 ./env.py local-install`. This tool copies the skeleton and installs all the tools to `$OPENLANE_ROOT_DIR/install`. Furthermore, if you are on CentOS 7, macOS, Ubuntu 20.04 or Arch Linux, the installer will offer to install all the required apt, yum or brew packages for you.

The tools will all be installed with `./install` as a prefix. You'll find all the repos in `./install/build/repos` and a list of versions in `./install/build/versions`.

**DO NOTE:** We expect you to get some tools on your own, because said tools are too complex to build in an automated fashion. Namely:
* OpenROAD
* KLayout
* Git 2.34+

After the installer is done, you can simply invoke `./flow.tcl` outside of Docker and it should work okay.

## How this works
`flow.tcl` looks for a file called `./install/env.tcl` before it does anything. If it finds it, it sources it. The `./install` directory is aliased in Docker environments, which already have the proper tools installed.

`./install/env.tcl` contains the necessary environment variables to add the installed tools to PATH and activate the Python virtual environment.