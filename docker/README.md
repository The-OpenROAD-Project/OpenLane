# The OpenLane Docker Image
## Structure
There are two "families" of images: one is for building tools, and the other is the final OpenLane image.

The final OpenLane image contains all the tools necessary, meanwhile, the build family has a base image that contains all build dependencies and then a number of subimages tasked with building each tool.

```
openlane-build-base
L cugr
L cvc
L openroad_app
L [...]

openlane
```

## Building the OpenLane Image
```bash
make # or make openlane # or make merge
```

## Updating a Tool Binary
You can update a tool binary as follows:

```
make build-<tool_name>
```

The following are the available tools:

```bash
cugr drcu yosys magic openroad_app padring netgen vlogtoverilog cvc git
```

Be sure to make openlane after.