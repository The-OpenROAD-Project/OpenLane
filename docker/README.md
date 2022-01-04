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

To list the available tools, `python3 ../dependencies/tool.py --containerized`.

Be sure to `make openlane` after building any tool.