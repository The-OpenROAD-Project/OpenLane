# Containerless/Local

:::{warning}
The local installer is no longer actively supported. Unless you ***absolutely*** know what you're doing, please use the Docker image.
:::

At its core, OpenLane is a set of scripts working with a set of tools. If you'd like to avoid using a Docker container, you can, but you will have to set up all of the tools required by OpenLane on your computer.

## Base Requirements
* Python 3.6+
    - pip
    - venv
    - pyyaml (`python3 -m pip install pyyaml`)
    
## Tool Library
You can run `python3 ./env.py tool-list` for a list. There are at least a dozen tools to install here.
