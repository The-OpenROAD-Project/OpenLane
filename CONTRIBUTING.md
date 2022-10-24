# Contributing Code
We'd love to accept your patches and contributions to this project. There are just a few small guidelines you need to follow.

## Branching
For various reasons, it's recommended to call working branches, even in your forks, something else other than `master` or `main`, as those two branch names do have some special behavior associated with them. 

## Testing and Code Standards
Before you submit your changes, it's prudent to perform some kind of smoke test. `make test` tests a simple spm design to ensure nothing has gone horribly wrong.

## Choice of Language
Try to write all major code in Python. Writing some Tcl is usually a necessity because this project's backbone is unfortunately written in Tcl, but just keep the Tcl to as close to a Python shim as possible.

Please do not write new shell scripts, no matter how trivial.

### Tcl
1TBS-indented, four spaces, `lower_snake_case` for local/global variables and `UPPER_SNAKE_CASE` for environment variables. Unfortunately it is impossible to add any other guidelines or standards to the Tcl code considering it is Tcl code. Please exercise your best judgment.

### Python
Python code should run on Python 3.6+.

You will need to ensure that your Python code passes linting with the tools and plugins in [`requirements_lint.txt`](https://github.com/The-OpenROAD-Project/OpenLane/tree/master/requirements_lint.txt). The commands are simply `black .` and `flake8 .`. Please fix all warnings.

For new code, please follow [PEP-8 naming conventions](https://peps.python.org/pep-0008/#naming-conventions). The linters do not enforce them just yet because of the corpus of existing code that does not do that, but they will in the future.

Do all arithmetic either in integers or using the Python [`decimal`](https://docs.python.org/3.6/library/decimal.html) library. All (numerous) existing uses of IEEE-754 are bugs we are interested in fixing.

## Yosys, OpenROAD and Magic Scripts
There are some special guidelines for scripts in `scripts/yosys`, `scripts/openroad`, and `scripts/magic`:

* The scripts for each tool are a self-contained ecosystem: do not `source` scripts from outside their directories.
    * You may duplicate functionality if you deem it necessary.
* Do not reference the following environment variables anywhere in this folder to avoid causing recursion when generating issue reproducibles:
    * $PWD
    * $RUN_DIR
    * $DESIGN_DIR


## Submissions
Make your changes and then submit them as a pull requests to the `master` branch.

Consult [GitHub Help](https://help.github.com/articles/about-pull-requests/) for more information on using pull requests.

### The Approval Process
For a PR to be merged, there are two requirements:

- There are two automated checks, one for linting and the other for functionality. Both must pass.
- An OpenLane team member must inspect and approve the PR.

## Licensing and Copyright
Please add you (or your employer's) copyright headers to any files to which you have made major edits.

Please note all code contributions must have the same license as OpenLane, i.e., the Apache License, version 2.0. 