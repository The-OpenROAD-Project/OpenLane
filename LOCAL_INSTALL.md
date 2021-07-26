**NOTE: It is far more complex to set up OpenLane without a Docker container. Unless you absolutely have to avoid Docker, go back to the [Readme](./README.md).**

**NOTE 2: This use case is in alpha. There can and will be bugs and other unexpected behavior as OpenLane is exposed to unknown configurations.**

# Using OpenLane without Docker
At its core, OpenLane is a set of scripts working with a set of tools. If you'd like to avoid using a Docker container, you can, but you will have to set up all of your tools manually.

# The OpenLane Scripts
OpenLane can work as a skeleton with just these fiels:

* configuration/
* scripts/
* flow.tcl
* report_generation_wrapper.py

You can copy them into any folder, then invoke `tclsh /path/to/flow.tcl` and go to town. The scripts are pretty light on requirements too: You only need Python 3.6+, Perl 5 and Tclsh. Unfortunately, OpenLane cannot accomplish much without its library of open source EDA tooling. 

# Tool Library
You can run `python3 ./ol_install.py --list-tools` for a list. There are at least a dozen tools to install here. Luckily, you don't have to install them all one-by-one: There is an installation script that installs most of them.

You can invoke `python3 ./ol_install.py`. This tool copies the skeleton and installs all the tools to a directory of your choice, which is by default, `/opt/openlane`. Furthermore, if you are on CentOS 7 or Ubuntu 20.04, the installer will offer to install all the required apt or yum packages for you. This tool is only really supported on Ubuntu 20.04 or CentOS 7: you can try your best with Arch or macOS but we have not tested it and we cannot guarantee it will work.

The tools will all be installed with `/opt/openlane` as a prefix. You'll find all the repos in `/opt/openlane/build/repos` and a list of versions in `/opt/openlane/build/versions`.

**DO NOTE:** We expect you to bring your own OpenROAD.

After the installer is done, you can invoke `sh /opt/openlane/openlane <args>` to use OpenLane, where args are the same arguments you'd pass on to `flow.tcl`.
