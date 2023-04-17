# `or_issue.py`
This script creates a reproducible, self-contained package of files to demonstrate Magic or OpenROAD behavior in a vaccum, suitable for filing issues.

It creates a folder with all the needed files that you can inspect, then zip or tarball and pass on to https://github.com/RTimothyEdwards/magic or https://github.com/The-OpenROAD-Project/OpenROAD.

## Warning about proprietary files
When working with a proprietary PDK, also inspect the folder and ensure no proprietary data resulting ends up in there. This is *critical*, if something leaks, this scripts' authors take no responsibility and you are very much on your own. We will try our best to output warnings for your own good if something looks like a part of a proprietary PDK, but the absence of this message does not necessarily indicate that your folder is free of confidential material. 

## Usage
### Failures
If you're using OpenLane 2022.06.21 or later, chances are, `or_issue.py` will **automatically** be run for you if Magic or OpenROAD exit with a non-zero code. 

You'll find a message in the log that says something along the lines of: `Reproducible packaged: Please tarball and upload <PATH> if you're going to submit an issue.` The path will be under the current run_path, i.e., `./designs/<design>/runs/<run_tag>/issue_reproducible`. You can then tarball/zip and upload that file.

### Odd Behavior
If the Tcl-based script doesn't fail outright, but simply exhibits weird behavior, starting OpenLane 2022.07.20, you can have the flow simply stop execution and package a reproducible instead.

If you know the name of the script causing the issue, you can set the environment variable `CREATE_REPRODUCIBLE_FROM_SCRIPT` to the name of the script. For example, to quit on Magic's DRC script, you can set the variable as follows:

```bash
export CREATE_REPRODUCIBLE_FROM_SCRIPT=magic/drc.tcl
./flow.tcl [...]
```

The flow will automatically quit right before executing any script matching `CREATE_REPRODUCIBLE_FROM_SCRIPT`. The last message printed will be something among the lines of `[INFO]: Reproducible packaged at '<PATH>'.`

### Manually
If neither option above works for you for some reason, there's always the hard way, and the hard way involves invoking the script manually.

You'll have to extract three key elements from the **verbose** logs (i.e. ./flow.tcl must be run with `-verbose`):
* The Script Where The Failure Occurred -> script
* The Final Layout Before The Failure Occurred -> input
* The Run Path -> run_path
    * The run path can be derived from the input, so typically, you do not have to explicitly specify it.

***You must run or_issue.py from the same filesystem you've run OpenLane with. i.e., if you ran it inside the Docker container, you need to `make mount` first.***

As a practical example, for this log from openlane.log:

```
[INFO]: Changing layout to designs/spm/runs/RUN_2022.03.01_19.21.10/tmp/routing/17-fill.odb
[...]
[INFO]: Running Detailed Routing...
[INFO]: Running OpenROAD script scripts/openroad/droute.tcl...
```

The three elements would be:
* input:    `designs/spm/runs/RUN_2022.03.01_19.21.10/tmp/routing/17-fill.odb`
* script:   `scripts/openroad/droute.tcl`
* run_path: `designs/spm/runs/RUN_2022.03.01_19.21.10`

Then you'd want to run this script as follows, from the root of the OpenLane Repo:
```sh
    python3 ./scripts/or_issue.py\
        --tool openroad\
        --script ./scripts/openroad/droute.tcl\
        designs/spm/runs/RUN_2022.03.01_19.21.10/tmp/routing/17-fill.odb
        # run path is implicitly specified by input odb
```

Which will create a folder called `_build`, with a single subfolder. Ensure that you inspect this folder manually and the output of this script. This script only attempts a best effort, and it is very likely that it might miss something, in which case, feel free to file an issue.

You can then verify that the script worked by running:
```sh
    cd _build/<name of folder>
    sh ./run.sh
```

You can override the Magic/OpenROAD binary used as follows:

```sh
    cd _build/config_TEST_fastestTestSet1_or_groute_packaged
    TOOL_BIN=/usr/local/bin/whatever sh ./run.sh
```
