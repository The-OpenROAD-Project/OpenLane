import os
from decimal import Decimal

assert Decimal(os.environ["TEST_FLOAT_REF"]) == 1
assert Decimal(os.environ["TEST_FLOAT_CALC"]) == 2
assert (
    os.environ["TEST_POTENTIALLY_MALICIOUS_VARIABLE"]
    == "\t\\\\\\};puts hi;\\{\"\"\"''''"
)
assert not os.environ["TEST_INTERNAL_GLOB"].endswith("*")
assert os.environ["TEST_EXTERNAL_GLOB"].endswith("*")
