# Contributing
We'd love to accept your patches and contributions to this project. There are
just a few small guidelines you need to follow.

## Branching
For various reasons, it's recommended to call working branches, even in your forks, something else other than `master` or `main`, as those two branch names do have some special behavior associated with them. 

## Testing and Code Standards
Before you submit your changes, it's prudent to perform some kind of smoke test. `make test` tests a simple spm design to ensure nothing has gone horribly wrong.

You will also need to ensure that your Python code passes linting with two tools: `black` and `flake8`. The commands are simply `black .` and `flake8 .`. Please fix all warnings.

Try to write all major code in Python. Writing some Tcl is usually a necessity because this project's backbone is unfortunately written in Tcl, but just keep the Tcl to as close to a Python shim as possible.

Please do not write new shell scripts.

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