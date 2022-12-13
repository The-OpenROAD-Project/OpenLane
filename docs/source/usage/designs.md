# Adding Your Designs
To add a new design, the following command creates a configuration file for your design:

```bash
# JSON Configuration File
./flow.tcl -design <design_name> -init_design_config -add_to_designs

# Tcl Configuration File
./flow.tcl -design <design_name> -init_design_config -add_to_designs -config_file config.tcl
```

This will create the following directory structure:

```bash
designs/<design_name>
├── config.json (or config.tcl)
```
In the configuration file (`config.json`), you should edit the required variables and the optional variables, if needed. Further information about the variables can be found [here](../reference/configuration.md).
> Note: config.json/config.tcl is a global configuration for all PDKs and SCLs. For more information about design configuration files, including how to set up PDK/SCL-specific variables, please see [this file](../reference/configuration_files.md).

It is recommended to place the verilog files of the design in a `src` directory inside the folder of the design as following:

```bash
designs/<design_name>
├── config.tcl
├── src
│   ├── design.v
```

However, you can point to the src files (space-delimited) while initializing the design and they will be pointed to automatically in the configuration file and will also be automatically copied to the src directory creating the same structure shown above.

```bash
./flow.tcl -design <design_name> -init_design_config -add_to_designs -src "<list_verilog_files>"
```

Optionally, you can specify the configuration file name by using:

```bash
./flow.tcl -design <design_name> -init_design_config -add_to_designs -config_file <custom_name.tcl/custom_name.json>
```

After adding the design, you can run the design using a `-design` argument:

```bash
./flow.tcl -design <design_name>
```

Finally, you can specify the configuration file (belonging to that design) the flow should use:

```bash
./flow.tcl -design <design_name> -config_file <path_to_config_file>
```
