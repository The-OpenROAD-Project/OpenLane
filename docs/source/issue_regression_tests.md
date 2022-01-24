# Issue regression tests
Issue regression tests are used to test issues that happened in the past, that might return. Regression testing also allows to extend the options/configs that is not covered currently.

# Issue regression tests flow
If -run_hooks is specified, after a successful flow run hooks/post_run.py script is run. Script may contain any checks required. Multiple issues can be convered by single script. As a reference def_test design can be used. It's a simple inverter, with pins locations specified in DEF. Script just checks for pins to be in locations in tempalte DEF.
