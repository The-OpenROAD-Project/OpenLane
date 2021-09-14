**NOTE: It is far more complex to set up OpenLane without a Docker container. If you are a novice user, it is recommended to use the Docker container.**

# Using OpenLane without Docker
At its core, OpenLane is a set of scripts working with a set of tools. If you'd like to avoid using a Docker container, you can, but you will have to set up all of the tools required by OpenLane on your computer. We do provide a script to assist you with that.

# Base Requirements
* Python 3.6+ with PIP
* pyyaml: `python3 -m pip install pyyaml`

# Tool Library
You can run `python3 ./install.py --list-tools` for a list. There are at least a dozen tools to install here. Luckily, you don't have to install them all one-by-one: There is an installation script that installs most of them.

You can invoke `python3 ./install.py`. This tool copies the skeleton and installs all the tools to a directory of your choice, which is by default, `/usr/local/opt/openlane`. Furthermore, if you are on CentOS 7, macOS or Ubuntu 20.04, the installer will offer to install all the required apt or yum packages for you.

On macOS, it may be prudent to invoke it as `SKIP_TOOLS=drcu:cugr python3 ./ol_install.py` instead, as these tools are a nightmare to compile on macOS.

The tools will all be installed with `/opt/openlane` as a prefix. You'll find all the repos in `/opt/openlane/build/repos` and a list of versions in `/opt/openlane/build/versions`.

**DO NOTE:** We expect you to bring your own OpenROAD. This installer will make no attempt to install OpenROAD.

After the installer is done, you can invoke `sh /opt/openlane/openlane <args>` to use OpenLane, where args are the same arguments you'd pass on to `flow.tcl`.

# More about how this works
OpenLane can work as a skeleton with this file structure:

* configuration/
* scripts/
* flow.tcl
* generate_reports.py

You can copy them into any folder, then invoke `tclsh /path/to/flow.tcl` and go to town. The scripts are pretty light on requirements too: You only need Python 3.6+, Perl 5 and Tclsh. Unfortunately, OpenLane cannot accomplish much without its library of open source EDA tooling. 