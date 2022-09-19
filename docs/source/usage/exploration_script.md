# Regression & Exploration
## Overview
OpenLane provides `run_designs.py`, a script that can do multiple runs in a parallel using different configurations. A run consists of a set of designs and a configuration file that contains the configuration values. It is useful to explore the design implementation using different configurations to figure out the best one(s). For examples, check the [Usage](#usage) section. 

Also, it can be used for testing the flow by running the flow against several designs using their best configurations. For example the following has two runs: spm and xtea using their default configuration files `config.tcl.` :
```
python3 run_designs.py --tag test --threads 3 spm xtea des aes256 
```
## Default Test Set Results

You can view the results of the run against some designs (more [here](#usage)) against any of the 5 sky130 standard cell libraries through these sheets:

- [sky130_fd_sc_hd](https://github.com/The-OpenROAD-Project/openlane/blob/master/regression_results/benchmark_results/SW_HD.csv)
- [sky130_fd_sc_hs](https://github.com/The-OpenROAD-Project/openlane/blob/master/regression_results/benchmark_results/SW_HS.csv)
- [sky130_fd_sc_ms](https://github.com/The-OpenROAD-Project/openlane/blob/master/regression_results/benchmark_results/SW_MS.csv)
- [sky130_fd_sc_ls](https://github.com/The-OpenROAD-Project/openlane/blob/master/regression_results/benchmark_results/SW_LS.csv)
- [sky130_fd_sc_hdll](https://github.com/The-OpenROAD-Project/openlane/blob/master/regression_results/benchmark_results/SW_HDLL.csv)

**Note**: `flow_failed` under `flow_status` implies that the run had failed.

## Usage

- The list of flags that could be used with run_designs.py is described here [Command line arguments](#command-line-arguments). Check [columns_defintions.md](../reference/datapoint_definitions.md) for more details on the reported configuration parameters.

The script can be used in two ways

1. Running one or more designs.
    
    ```bash
    python3 run_designs.py --threads 4 spm xtea PPU APU
    ```

    You can run the default test set consisting of all designs under [designs](../../../designs/) through running the following command along with any of the flags:
    
    ```bash
    python3 run_design.py --defaultTestSet
    ```

2. An exploration run that generates configuration files of all possible combinations of the passed regression file and runs them on the provided designs.
    
    ```bash
    python3 run_designs.py --regression ./scripts/config/regression.config --threads 2 spm xtea
    ```

    These parameters must be provided in the file passed to `--regression`. Any file can be used. The file used above is just an example
    
    - Basic Regression Script:
    
        The parameters that have multiple values inside the brackets will form the combinations. So here all combinations of GRT_ADJUSTMENT and FP_CORE_UTIL will be tried.

        ```
        GRT_ADJUSTMENT=(0.1,0.15)
        FP_CORE_UTIL=(40,50)
        PL_TARGET_DENSITY=(0.4)
        SYNTH_STRATEGY=(1,3)
        FP_PDN_VPITCH=(153.6)
        FP_PDN_HPITCH=(153.18)
        FP_ASPECT_RATIO=(1)
        SYNTH_MAX_FANOUT=(5)

        ```
    
    - Complex Expressions:

        In addition, `extra` is appended to every configuration file generated. So it is used to add some configurations specific to this regression run. The file could also contain non-white-space-separated expressions of one or more configuration variables or alternatively this could be specified in the extra section:
        
        ```
        FP_CORE_UTIL=(40,50)
        PL_TARGET_DENSITY=(FP_CORE_UTIL*0.01-0.1,0.4)
    
        extra="
        set ::env(SYNTH_MAX_FANOUT) { $::env(FP_ASPECT_RATIO) * 5 }
        "
        ```

    - SCL-specific section

        You can use this section to specify information that you would like to be sourced before sourcing SCL-specific information:

        ```
        FP_CORE_UTIL=(40,50)
        PL_TARGET_DENSITY=(FP_CORE_UTIL*0.01-0.1,0.4)
    
        extra="
        set ::env(SYNTH_MAX_FANOUT) { $::env(FP_ASPECT_RATIO) * 5 }
        "
        
        std_cell_library="
        set ::env(STD_CELL_LIBRARY) sky130_fd_sc_hd
        set ::env(SYNTH_STRATEGY) 1
        "
        ```
        In the example above, SYNTH_STRATEGY and STD_CELL_LIBRARY will be set before sourcing the SCL-specific information, and thus if SYNTH_STRATEGY is already specified under the configurations, the old value will override the value specified here.

        This can also be used to control the used PDK and its SCL, since it is set before sourcing the SCL-specific information, so this will override the SCL set in general.tcl and allow for more control on different standard cell libraries under the same design.


    It's important to note that the used configuration in the expression should be assigned a value or a range of values preceding its use in the file.


**Important Note:** *If you are going to launch two or more separate regression runs that include same design(s), make sure to set different tags for them using the `--tag` option. Also, put memory management into consideration while running multiple threads to avoid running out of memory to avoid any invalid pointer access.*

## Output
- In addition to files produced inside `designs/<design>/runs/config_<tag>_<timestamp>` for each run on a design, three files are produced:
    1. `regression_results/<tag>_<timestamp>/<tag>_<timestamp>.log` A log file that describes start and stopping time of a given run.
    2. `regression_results/<tag>_<timestamp>/<tag>_<timestamp>.csv` A report file that provides a summary of each run. The summary contains some metrics and the configuration of that run
    3. `regression_results/<tag>_<timestamp>/<tag>_<timestamp>_best.csv` A report file that selects the best configuration per design based on number of violations

- If a file is provided to the --benchmark flag, the following files will also be generated:

    6. `regression_results/<tag>_<timestamp>/<tag>_<timestamp>.rpt.yml` An incrementaly generated list of all designs in this run compared to the benchmark results and whether they PASSED or FAILED the regression test.
    7. `regression_results/<tag>_<timestamp>/<tag>_<timestamp>.rpt` A detailed report pointing out the differences between this run of the test set and the benchmark results. It divides them into three categories: Critical, Note-worthy, and Configurations.
    8. `regression_results/<tag>_<timestamp>/<tag>_<timestamp>.rpt.xlsx` A design to design comparison between benchmark results and this run of the test set. It includes whether or not a design failed or passed the test and it highlights the differences.


## Command line arguments
`python3 ./run_designs.py --help`