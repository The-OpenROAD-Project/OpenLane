# How to Contribute

We'd love to accept your patches and contributions to this project. There are
just a few small guidelines you need to follow.

## Submission and Testing Process

- Submit a Pull Request to the [master](https://github.com/efabless/openlane/tree/master) branch only. <br> Check [Code Reviews](#code_reviews) for more details.
- Our CI that would test your PR once submitted, yet it would be nice for you to run a couple of tests from your end to shorten the cycle of reviews. For that purpose, you can use:
    - `make fastest_test_set`: to run the same test set that the basic CI uses, which will be used to evaluate your Pull Request.
    - [This](./regression_results/README.md) for custom test sets. (check the `-b` flag).
    - `make test`: tests the flow against one design `$TEST_DESIGN`. The default is `spm`.
    - `make regression_test`: tests the flow against all available designs and compares the resulting statistics with benchmark results and produces a human readable report and summary. 

## Code reviews

All submissions, including submissions by project members, require review. We
use GitHub pull requests for this purpose. Consult
[GitHub Help](https://help.github.com/articles/about-pull-requests/) for more
information on using pull requests.
