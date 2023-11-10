import os
from decimal import Decimal


assert Decimal(os.environ["TEST_FLOAT_REF"]) == 1
assert Decimal(os.environ["TEST_FLOAT_CALC"]) == 2
assert os.environ["TEST_MALICIOUS_VAR_0"] == "\t\\};puts hi;[puts hi];{\"\"\"''''"
assert os.environ["TEST_MALICIOUS_VAR_1"] == "\n\nputs hi;\n\npotato\n"
assert not os.environ["TEST_INTERNAL_GLOB"].endswith("*")
assert os.environ["TEST_EXTERNAL_GLOB"].endswith("*")
assert os.environ["TEST_REGEX"] == r"x\.y"
