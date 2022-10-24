# Design Configuration Files
Each OpenLane-compatible design must come with a configuration file. These configuration files can be written in one of two grammars: JSON or Tcl.

Tcl offers more flexibility at the detriment of security, while JSON is more straightforward at the cost of flexbility. While Tcl allows you to do all manners of computation on your variables, JSON has a limited expression engine that will be detailed later in this document. Nevertheless, for security (and future-proofing), we recommend you use the JSON format.

By default, `config.tcl` is used. If `config.tcl` is ***not*** found, `config.json` is looked for as a fallback. If neither is found, OpenLane will throw an error and quit.

The folder containing your `config.tcl`/`config.json` is known  as the **Design Directory**. The design directory is special in that paths in the JSON configuration files can be resolved relative to this directory and that in TCL configuration files, it can be referenced via the environment variable `DESIGN_DIR`. This will be explained in detail in later sections.

## Initializing a design for use with OpenLane
There are two ways to use a design with OpenLane: by adding it to the `designs` folder in the OpenLane root directory, or by adding an OpenLane configuration folder to your existing design.
> Adding a design to the root folder is covered inside the `README.md` of the `designs` folder, so it won't be covered in this document. It is, however, the most straightforward of the two options if you're using a dockerized setup, so it is recommended for beginners.

Let's assume you have a simple SuccessiveApproximationRegister with set of two Verilog files:
```
project/
├── src
│   ├── sar.v
│   ├── edge_detector.v
```

You can initialize a configuration file as follows:
```bash
<openlane-root>/flow.tcl -design SuccessiveApproximationRegister -init_design_config -src "src/*.v"
```

New files will be created, resulting in the following project structure:

```
project/
├── src/
│   ├── sar.v
│   ├── edge_detector.v
├── openlane/SuccessiveApproximationRegister/
│   ├── .gitignore
│   ├── config.json
```

You can also initialize a `config.tcl` file instead:

```bash
<openlane-root>/flow.tcl -design SuccessiveApproximationRegister -init_design_config -src "src/*.v" -config_file config.tcl
```

You can then run the designs by moving into the directory `openlane/SuccessiveApproximationRegister` and running `flow.tcl`:

```bash
cd ./openlane/SuccessiveApproximationRegister
<openlane-root>/flow.tcl
```

## JSON
The JSON files are simple key value pairs. The values can be scalars (strings, numbers, booleans, and `null`s), *one-dimensional lists of scalars*, and, in special cases, a dictionary.

An minimal demonstrative configuration file would look as follows:

```json
{
    "DESIGN_NAME": "spm",
    "VERILOG_FILES": "dir::src/*.v",
    "CLOCK_PORT": "clk",
    "CLOCK_PERIOD": 100,
    "pdk::sky130A": {
        "SYNTH_MAX_FANOUT": 6,
        "FP_CORE_UTIL": 40,
        "PL_TARGET_DENSITY": "expr::($FP_CORE_UTIL + 5.0) / 100.0",
        "scl::sky130_fd_sc_hd": {
            "CLOCK_PERIOD": 15
        }
    }
}
```

### Processing
The JSON files are processed at runtime to conditional execution, a way to reference the design directory, other variables, and a basic ***mathematical*** expression engine.

#### Conditional Execution

The JSON configuration files support conditional execution based on PDK or standard cell library (or, by nesting as shown above, a combination thereof.) You can do this using the `pdk::` or `scl::` key prefixes.

The value for this key would be a `dict` that is only evaluated if the PDK or SCL matches those in the key, i.e., for `pdk::sky130A` as shown above, this particular `dict` will be evaluated and its values used if and only if the PDK is set to `sky130A`, meanwhile with say, `asap7`, it will not be evaluated.

The match is evaluated using [`fnmatch`](https://docs.python.org/3.6/library/fnmatch.html), giving it limited wildcard support: meaning that `pdk::sky130*` would match both `sky130A` and `sky130B`.

Note that ***the order of declarations matter here***: as seen in the following example, despite a more specific value for a PDK existing, the unconditionally declared value later in the code would end up overwriting it:

```json
{
    "pdk::sky130A": {
        "A": 40
    },
    "A": 4
}

{
    "A": 4,
    "pdk::sky130A": {
        "A": 40
    }
}
```
> In the first example, the final value for A would always be 4 given the order of declarations. In the second example, it would be 40 is the PDK is sky130A and 4 otherwise.

#### Variable Reference

If a string's value starts with `ref::`, you can interpolate exactly one variable at the beginning of your string.

Like conditional execution, the order of declarations matter: i.e., you cannot reference a variable that is declared after the current expression.

```json
{
    "A": "ref::$B",
    "B": "vdd gnd"
}

{
    "B": "vdd gnd",
    "A": "ref::$B"
}
```
> In this example, the first configuration is invalid, as B is referenced before it is declared, but the latter is OK, where the value will be "vdd gnd" as well.

Unlike Tcl config files, environment variables (other than `DESIGN_DIR`, `PDK`, `PDKPATH`, `STD_CELL_LIBRARY` and `SCLPATH`) are not exposed to `config.json` by default. You can expose an environment variable to `config.json` files by adding a `-expose_env` flag to your `flow.tcl` invocation, e.g.:

```sh
export CARAVEL_ROOT=/caravel
./flow.tcl -design user_project_wrapper -expose_env CARAVEL_ROOT
```

Which you can then use as follows:

```json
{
    "DEFINES_FILE": "ref::$CARAVEL_ROOT/verilog/rtl/defines.v"
}
```

...which then would evaluate to `/caravel/verilog/rtl/defines.v`.

Another feature this has is if the files you choose lie **inside** an exposed directory, this prefix supports non-recursive globs, i.e., you can use an asterisk as a wildcard to pick multiple files in a specific folder. Outside the design directory, this is disabled for security reasons, and the final path will continue to include the asterisk. As shown below, `ref::$DESIGN_DIR/src/*.v` would find all files ending with `.v` in the `src` folder inside the design directory.

```json
{
    "VERILOG_FILES": "ref::$DESIGN_DIR/src/*.v"
}
```

There are some shorthands for the exposed default variables:
* `dir::` is equivalent to `ref::$DESIGN_DIR/`
* `pdk_dir::` is equivalent to `ref::$PDKPATH/`
* `scl_dir::` is equivalent to `ref::$SCLPATH/`


#### Expression Engine

By adding `expr::` to the beginning of a string, you can write basic infix mathematical expressions. Binary operators supported are `**`, `*`, `/`, `+`, and `-`, while operands can be any floating-point value, and previously evaluated numeric variables prefixed with a dollar sign. Unary operators are not supported, though negative numbers with the - sign stuck to them are. Parentheses (`()`) are also supported to prioritize certain operations.

Your expressions must return exactly one value: multiple expressions in the same `expr::`-prefixed value are considered invalid and so are empty expressions.

It is important to note that, like variable referencing and conditional execution, the order of declarations matter: i.e., you cannot reference a variable that is declared after the current expression.

```json
{
    "A": "expr::$B * 2",
    "B": 4
}

{
    "B": 4,
    "A": "expr::$B * 2"
}
```
> In this example, the first configuration is invalid, as B is used in a mathematical expression before declaration, but the latter is OK, evaluating to 8.

## Tcl
These configuration files are simple Tcl scripts with environment variables that are sourced by the OpenLane flow. Again, Tcl config files are not recommended for newer designs, but is still maintained and supported at the moment.

Each design using the Tcl format has a global config.tcl and other config files one for each PDK:

```
designs/<design_name>
├── config.tcl
├── sky130A_sky130_fd_sc_hs_config.tcl
├── sky130A_sky130_fd_sc_hd_config.tcl
├── src
│   ├── design.v
```

You can see `designs/xtea` for an example of a design that still uses the Tcl format.

To support the technology-specific config files, the global `config.tcl` files, including ones generated by `-init_design_config`, should end with these lines:

```tcl
set filename $::env(DESIGN_DIR)/$::env(PDK)_$::env(STD_CELL_LIBRARY)_config.tcl
if { [file exists $filename] == 1} {
	source $filename
}
```

This implies that if the `{PDK}_{STD_CELL_LIBRARY}_config.tcl` doesn't exist for a specific technology combination the flow would resume normally with only the global config.tcl.

This structure allows for storing the best configurations for a given design on all different PDKs and their STD_CELL_LIBRARYs. The best configuration for a given design differ from one PDK and STD_CELL_LIBRARY to another.
For this reason, upon installing a new PDK/STD_CELL_LIBRARY or a new design, an exploration should be run on different configuration parameters to reach the best configuration. The script that enables this is documented [here][exploration_script]. 
After running the exploration, you will find in the logs two .csv newly generated files: `{tag}_{timestamp}.csv` and `{tag}_{timestamp}_best.csv`. The configuration name reported in the _best.csv file contains the best added configurations to the current run of the given design using the specified PDK/STD_CELL_LIBRARY.

Two scripts were created for this purpose:
 - A script to create a new configuration file for a given (PDK, STD_CELL_LIBRARY) pair, or replicate the configuration of a (PDK, STD_CELL_LIBRARY) to another (PDK, STD_CELL_LIBRARY).
 - A script to update the configuration of a given (PDK, STD_CELL_LIBRARY) according to an exploration result provided by a {tag}_best.csv file.

### Replicate/Create Design Configs for a (PDK,STD_CELL_LIBRARY) Pair:

To run the script to create new (empty) configurations for a (PDK,STD_CELL_LIBRARY) pair:
```bash
    python3 ./scripts/config/replicate.py --to-pdk PDK --to-std-cell-lib STD_CELL_LIBRARY
```

To run the script to replicate configurations from one (PDK,STD_CELL_LIBRARY) pair to another:
```bash
    python3 ./scripts/config/replicate.py --from-pdk PDK_FROM --from-std-cell-lib STD_CELL_LIBRARY_FROM --to-pdk PDK --to-std-cell-lib STD_CELL_LIBRARY
```

For more detailed information, run `python3 ./scripts/config/replicate.py --help`.

### Update Design Configs for a (PDK,STD_CELL_LIBRARY) Pair after an Exploration:

To run the script to update configurations for a (PDK,STD_CELL_LIBRARY) pair after an exploration:
```bash
    python3 ./scripts/config/update.py --pdk PDK --std-cell-lib STD_CELL_LIBRARY --best_results SW_exploration_best.csv
```

You can invoke `python3 ./scripts/config/update.py` for a full list of options.

Check [this][exploration_script] for more details on the log files.

> **Note 1:** `update.py` skips designs that fail during the exploration, which means their `flow_status` is not `flow_completed`.
>
> **Note 2:** The `update.py` script only copies new configuration to the file. The new configurations are marked with a preceeding `# Regression` comment that is automatically written before them by the exploration script. However, the `replicate.py` script copies the whole file.

[exploration_script]: ../usage/exploration_script.md
