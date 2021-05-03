# Regression & Exploration




## Overview
OpenLane provides `run_designs.py`, a script that can do multiple runs in a parallel using different configurations. A run consists of a set of designs and a configuration file that contains the configuration values. It is useful to explore the design implementation using different configurations to figure out the best one(s). For examples, check the [Usage](#usage) section. 

Also, it can be used for testing the flow by running the flow against several designs using their best configurations. For example the following has two runs: spm and xtea using their default configuration files `config.tcl.` :
```
python3 run_designs.py --designs spm xtea des aes256 --tag test --threads 3
```
## Default Test Set Results:

You can view the results of the run against some designs (more [here](#usage)) against any of the 5 sky130 standard cell libraries through these sheets:

- [sky130_fd_sc_hd](https://htmlpreview.github.io/?https://github.com/efabless/openlane/blob/master/regression_results/benchmark_results/SW_HD.html)
- [sky130_fd_sc_hs](https://htmlpreview.github.io/?https://github.com/efabless/openlane/blob/master/regression_results/benchmark_results/SW_HS.html)
- [sky130_fd_sc_ms](https://htmlpreview.github.io/?https://github.com/efabless/openlane/blob/master/regression_results/benchmark_results/SW_MS.html)
- [sky130_fd_sc_ls](https://htmlpreview.github.io/?https://github.com/efabless/openlane/blob/master/regression_results/benchmark_results/SW_LS.html)
- [sky130_fd_sc_hdll](https://htmlpreview.github.io/?https://github.com/efabless/openlane/blob/master/regression_results/benchmark_results/SW_HDLL.html)

**Note**: `flow_failed` under `flow_status` implies that the run had failed.

To replicate these sheets, run the following command inside the docker after setting the proper standard cell library in [../configuration/general.tcl](../configuration/general.tcl):

```bash
    python3 run_design.py --defaultTestSet --htmlExtract
```

You can control the run by adding more of the flags in this [section](#command-line-arguments)

## Usage

- The list of flags that could be used with run_designs.py is described here [Command line arguments](#command-line-arguments). Check [columns_defintions.md][21] for more details on the reported configuration parameters.

The script can be used in two ways

1. Running one or more designs.
    
    ```bash
    python3 run_designs.py --designs spm xtea PPU APU
    ```

    You can run the defualt test set consisting of all designs under [./designs](../designs/) through running the following command along with any of the flags:
    
    ```bash
    python3 run_design.py --defaultTestSet
    ```

2. An exploration run that generates configuration files of all possible combinations of the passed regression file and runs them on the provided designs.
    
    ```bash
    python3 run_designs.py --designs spm xtea --regression ./scripts/config/regression.config
    ```

    These parameters must be provided in the file passed to `--regression`. Any file can be used. The file used above is just an example
    
    - Basic Regression Script:
    
        The parameters that have multiple values inside the brackets will form the combinations. So here all combinations of GLB_RT_ADJUSTMENT and FP_CORE_UTIL will be tried.

        ```
        GLB_RT_ADJUSTMENT=(0.1,0.15)
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
        PL_TARGET_DENSITY=(FP_CORE_UTIL/100-0.1,0.4)
    
        extra="
        set ::env(SYNTH_MAX_FANOUT) { $::env(FP_ASPECT_RATIO) * 5 }
        "
        ```

    - SCL-specific section

        You can use this section to specify information that you would like to be sourced before sourcing SCL-specific information:

        ```
        FP_CORE_UTIL=(40,50)
        PL_TARGET_DENSITY=(FP_CORE_UTIL/100-0.1,0.4)
    
        extra="
        set ::env(SYNTH_MAX_FANOUT) { $::env(FP_ASPECT_RATIO) * 5 }
        "
        
        std_cell_library="
        set ::env(STD_CELL_LIBRARY) sky130_fd_sc_hd
        set ::env(SYNTH_STRATEGY) 1
        "
        ```
        In the example above, SYNTH_STRATEGY and STD_CELL_LIBRARY will be set before sourcing the SCL-specific information, and thus if SYNTH_STRATGY is already specified under the configurations, the old value will override the value specified here.

        This can also be used to control the used PDK and its SCL, since it is set before sourcing the SCL-specific, so this will override the SCL set in general.tcl and allow for more control on different standard cell libraries under the same design.


    It's important to note that the used configuration in the expression should be assigned a value or a range of values preceding to its use in the file.


**Important Note:** *If you are going to launch two or more separate regression runs that include same design(s), make sure to set different tags for them using the `--tag` option. Also, put memory management into consideration while running multiple threads to avoid running out of memory to avoid any invalid pointer access.*

## Output
- In addition to files produced inside `designs/<design>/runs/config_<tag>_<timestamp>` for each run on a design, three files are produced:
    1. `regression_results/<tag>_<timestamp>/<tag>_<timestamp>.log` A log file that describes start and stopping time of a given run.
    2. `regression_results/<tag>_<timestamp>/<tag>_<timestamp>.csv` A report file that provides a summary of each run. The summary contains some metrics and the configuration of that run
    3. `regression_results/<tag>_<timestamp>/<tag>_<timestamp>_best.csv` A report file that selects the best configuration per design based on number of violations

- If the --htmlExtract flag is enabled, the following files will also be generated:

    4. `regression_results/<tag>_<timestamp>/<tag>_<timestamp>.html` A summary of the report file that provides a summary of each run. The summary contains the most important metrics and configuration of that run
    5. `regression_results/<tag>_<timestamp>/<tag>_<timestamp>_best.html` A summary of the report file that selects the best configuration per design based on number of violations. The summary contains the most important metrics and configuration of that run

- If a file is provided to the --benchmark flag, the following files will also be generated:

    6. `regression_results/<tag>_<timestamp>/<tag>_<timestamp>_design_test_report.csv` An incrementaly generated list of all designs in this run compared to the benchmark results and whether they PASSED or FAILED the regression test.
    7. `regression_results/<tag>_<timestamp>/<tag>_<timestamp>_benchmark_written_report.rpt` A detailed report pointing out the differences between this run of the test set and the benchmark results. It divides them into three categories: Critical, Note-worthy, and Configurations.
    8. `regression_results/<tag>_<timestamp>/<tag>_<timestamp>_benchmark_final_report.xlsx` A design to design comparison between benchmark results and this run of the test set. It includes whether or not a design failed or passed the test and it highlights the differences.


## Command line arguments
<table>
    <tr>
        <th>
        Argument
        </th>
        <th >
        Description
        </th>
    </tr>
    <tr>
        <td align="center">
            <code>--designs | -d design1 design2 design3 ...</code> <br> (Required)
        </td>
        <td align="justify">
            Specifies the designs to run. Similar to the argument of <code>./flow.tcl -design</code>
        </td>
    </tr>
    <tr>
        </tr>
        <td align="center">
            <code>--defaultTestSet | -dts </code> <br> (Boolean)
        </td>
        <td align="justify">
            Ignores the design flag, and runs the default design test set consisting of all designs under the ../designs/ directory. <br> Default: <code> False</code>
        </td>
    </tr>
    <tr>
        </tr>
        <td align="center">
            <code>--excluded_designs | -e  design1 design2 design3 ...</code> <br> (Optional)
        </td>
        <td align="justify">
            Specifies the designs to exclude from the run. Useful with <code>&lt;--defaultTestSet&gt;</code>.
        </td>
    </tr>
    <tr>
        </tr>
        <td align="center">
            <code>--regression | -r &lt;file&gt; </code> <br> (Optional)
        </td>
        <td align="justify">
            Creates configuration files using the parameters in <code>&lt;file&gt;</code> and runs the configuration files on each design <br>
            The generated configuration files are based on the default config file in each design <code>designs/&lt;design&gt;/config.tcl</code> and the passed parameters in <code>&lt;file&gt;</code>
            The regression/exploration/configuration script described above. If not specified then none will be used and the designs will run against defualt/specified configs 
        </td>
    </tr>
    <tr>
        <td align="center">
            <code>--tag | -t &lt;name&gt;</code> <br> (Optional)
        </td>
        <td align="justify">
            Appends a tag to the log files in <code>regression_results/</code> and the generated configuration files when passing <code>--regression</code> <br> Default value: <code>regression</code>
        </td>
    </tr>
    <tr>
        </tr>
        <td align="center">
            <code>--threads | -th &lt;number&gt;</code> <br> (Optional)
        </td>
        <td align="justify">
            Number of threads <br> Default value: <code>5</code>
        </td>
    </tr>
    <tr>
        </tr>
        <td align="center">
            <code>--config | -c &lt;config&gt;</code> <br> (Optional)
        </td>
        <td align="justify">
            Defines the configuration file to be used in NON regression mode<br> Default value: <code>config</code>
        </td>
    <tr>
        </tr>
        <td align="center">
            <code>--configuration_parameters | -cp &lt;file&gt;</code> <br> (Optional)
        </td>
        <td align="justify">
            <code> &lt;file&gt; </code> contains configuration parameters to be printed in the csv report. 
            Input must be file containing the names of the configurations comma separated. 
            If not specified the default configuration list will be used. 
            If this is followed by "all" all configurations will be reported
        </td>
    <tr>
        </tr>
        <td align="center">
            <code>--append_configurations | -app</code> <br> (Boolean)
        </td>
        <td align="justify">
            Specifies whether or not to print the added configuration_parameters as well as the default or not. <br> Default value: <code>False</code>
        </td>
    <tr>
        </tr>
        <td align="center">
            <code>--clean | -cl</code> <br> (Boolean)
        </td>
        <td align="justify">
            Specifies whether or not to delete the tmp directory of all designs and move merged_unpadded to the results directory.<br> Default value: <code>False</code>
        </td>
    <tr>
        </tr>
        <td align="center">
            <code>--tar | -tar &lt;list&gt;</code> <br> (Optional)
        </td>
        <td align="justify">
            List sub directories or files under the run directory, and they will be compressed into a {design}_{tag}.tar.gz under the runs dirctory. 
            If the flag is followed by "all" then the whole directory will be compressed. 
        </td>
    <tr>
        </tr>
        <td align="center">
            <code>--delete | -dl</code> <br> (Boolean)
        </td>
        <td align="justify">
            Specifies whether or not to delete the run directory after completion and reporting the results in the csv.
            If this flag is used with --tar, then the compressed files will not be deleted because they are placed outside of the run directory. <br> Default value: <code>False</code>
        </td>
    </tr>
    <tr>
        </tr>
        <td align="center">
            <code>--htmlExtract | -html</code> <br> (Boolean)
        </td>
        <td align="justify">
            Specifies whether or not to print an html summary of the report printed in the csv format with the most important configurations and metrics. <br> Default value: <code>False</code>
        </td>
    </tr>
    <tr>
        </tr>
        <td align="center">
            <code>--benchmark | -b &lt;file&gt;</code> <br> (Optional)
        </td>
        <td align="justify">
            If provided this run will be tested against (compared to) the given benchmark <code>&lt;file&gt;</code>. check the output section above for the details of the reported results.
        </td>
    </tr>
    <tr>
        </tr>
        <td align="center">
            <code>--print_rem | -p &lt;number&gt;</code> <br> (Optional)
        </td>
        <td align="justify">
            If a <code>&lt;number&gt;</code> greater than 0 is provided, a list of the remaining designs will be printed into the terminal every <code>&lt;number&gt;</code> seconds.
        </td>
    </tr>
    <tr>
        </tr>
        <td align="center">
            <code>--disable_timestamp | -dt </code> <br> (Boolean)
        </td>
        <td align="justify">
            If enabled, the output files and tags will not contain the appended timestamp. <br> Default value: <code>False</code>
        </td>
    </tr>
    <tr>
        </tr>
        <td align="center">
            <code>--show_output | -so </code> <br> (Boolean)
        </td>
        <td align="justify">
            If enabled, the full output log resulting from running ./flow.tcl will be displayed realtime in the terminal. However, if more than one design or more than one configuration is running at the same time, this flag will be ignored and no live output will be displayed. <br> Default value: <code>False</code>
        </td>
    </tr>

</table>

[21]: ./columns_defintions.md
