# The OpenLane Docker Image
## Structure

There are two "families" of images: one is for building tools, and the other is for running tools.

The build family has a base image that contains all build dependencies and then a number of subimages named **builders** tasked with downloading all tools from source and building them.

The run family has a base image that contains all the running dependencies. There are a number of subimages named **runnables**, which copy the results from the builders and allows them to be runnable- those images are pushed to Docker Hub in the repository efabless/openlane-tools. Another image in the run family is the final OpenLane image, which has *all* the tools.

```
openlane-build-base
L cugr **builder**
L cvc **builder**
L openroad_app **builder**
L [...]

openlane-run-base
L openlane
L cugr **runnable**
L cvc **runnable**
L openroad_app **runnable**
```

## Building the OpenLane Image
```bash
make # or make openlane # or make merge
```

## Updating a Tool Binary

You can build a tool runnable using the following command: `make build-<tool_name>`.

When you are doing that, presumably you want to build a different version of the
tool than is shipped by default with the OpenLane docker image. For example, 
suppose we would like to include OpenRoad's version of Yosys rather than one
from https://github.com/yosyshq/yosys. We need to modify the file `tool_metadata.yml`
that is located in `OpenLane/dependencies`. Here is an example of that

```
- name: yosys
  repo: https://github.com/The-OpenROAD-Project/yosys
  commit: bc027b2cae9a85b887684930705762fac720b529
  build: |
    make clean
    make PREFIX=$PREFIX config-gcc
    make PREFIX=$PREFIX -j$(nproc)
    make PREFIX=$PREFIX install
```

Be alert to the fact that if you mix and match different tool versions
(ie different git commit hashes), you can possibly run into compatibility
issues.

To list the available tools, `python3 ../dependencies/tool.py --containerized`,
which is just essentially listing the contents of `tool_metadata.yml`

Be sure to `make openlane` after building any tool. This will create a new docker
image with a repository of `efabless/openlane`. What is important here is the
Image ID of the new image. This can be found by running the `docker image ls` command.
Here is an example:

```
macd@macd-NUC9:~/dbm/OpenLane$ docker image ls
REPOSITORY                TAG                                                               IMAGE ID       CREATED        SIZE
efabless/openlane         current                                                           6935c38e7386   8 hours ago    1.54GB
efabless/openlane-tools   yosys-bc027b2cae9a85b887684930705762fac720b529-centos-7           a39c26f693df   8 hours ago    793MB
<none>                    <none>                                                            8c6c1fc1d5a7   8 hours ago    3.62GB
openlane-run-base         latest                                                            205b284cb2d3   8 hours ago    749MB
openlane-build-base       latest                                                            80342e290ca1   8 hours ago    2.24GB
...
```

## Running the newly created Docker image

The OpenRoad tools and the OpenLane scripts depend upon a variety of different shell
environment variables in order to run correctly. They are all conveniently set by 
using the `make mount` command. However, if you just do that, it will spin up the
original image and not the one you just created. In order to use your new Docker
image, first set the shell varialble `OPENLANE_IMAGE_NAME` to the newly created
image id. For the example image created above, that would look like: (Replace
the image id with the one you get from `docker image ls`)

```
    export OPENLANE_IMAGE_NAME=6935c38e7386
```

## Running as root

By default `make mount` logs into the image with the user ID that is
currently active. If you are running as an unprivledged user, you can
use `make mount` to log in as root to the docker image, but you will
need to use `sudo` to do this. But, if you are depending on shell
environment variables that you may have set during the current session
they will be dropped by the `sudo` command. One way to pass those on
to the sudo shell is to use the `-E` option. The following shows how

```
    sudo -E make mount
```
