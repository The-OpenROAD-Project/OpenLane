---
name: Bug Report
about: If OpenLane is not behaving as expected, please report here.
title: ''
labels: ''
assignees: ''

---

<!-- NOTE: This template is NOT a suggestion. Issues not using this template will be marked invalid. -->

### Description
A clear and concise description of what the bug is.

### Environment
```
Please run the following set of commands in the OpenLane folder:

make survey || python3 ./env.py issue-survey

And copy and paste the ENTIRE output between the triple-backticks. Please do not gzip and upload the output.

If neither command succeeds, you are using an out of date version of OpenLane and should probably update. 
```

### Reproduction Material
* Upload a tarball containing the relevant design.
* List the commands used to run the design.

If you see a message like `Reproducible packaged: Please tarball and upload <PATH> if you're going to submit an issue` in your logs, please also tarball and include that path. This will greatly speed up the fixing process.

### Expected behavior
A clear and concise description of what you expected to happen.

### Logs
```
Add any relevant logs here. Please do ensure they're enclosed by the triple-backticks.
```

