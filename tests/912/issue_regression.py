# Copyright 2022 Arman Avetisyan
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import sys


with open(sys.argv[1] + "/openlane.log") as f:
    content = f.read()
    print(content)
    if (
        content.find(
            "Pin manufacturing_grid_missaligned_pin's coordinate 9861 does not lie on the manufacturing grid."
        )
        is not -1
    ) and (
        content.find(
            "Pin manufacturing_grid_missaligned_pin's coordinate 10141 does not lie on the manufacturing grid."
        )
        is not -1
    ):
        sys.exit(0)
    else:
        sys.exit("Didn't match the log")
