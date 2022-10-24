# Issue regression tests
Issue regression tests are used to test issues that happened in the past, that might return by changes introduced in the future. Regression testing also allows to extend the options/configs that is not covered currently. To run issue regression flow execute `make issue_regression_all` outside of docker image.

## Issue regression tests flow

Another type of checks is intentionally broken test cases which test the OpenLane's ability to warn user about possible issues. Example issue is: `issue_912_def_test_missaligned`. Entry point is `run_issue_regressions.py` which will run all designs matching `designs/issue_*` pattern. After the run was compeleted with or without errors or fails, then for that design `issue_regression.py` is ran in OpenROAD Python environment. If flow failed and `issue_regression.py` does not exist, then issue regression failed. As `-run_hooks` will run only after successful flow, but the `issue_regression.py` will be ran in both failed and successful case. OpenLane users may want to use `-run_hooks`, while issue_regression is designed to be used only by regression flow.

If `-run_hooks` is specified, after a successful flow run `hooks/post_run.py` script is run. Script may contain any checks required. Multiple issues can be covered by single script. As a reference `issue_892_def_test` can be used.
