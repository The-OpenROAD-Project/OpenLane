# Copyright 2020 Efabless Corporation
#
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

with open(sys.argv[1], "r") as log:
    with open(sys.argv[2], "w") as rep:
        if sys.argv[3] == "wns_report":
            content = log.read()
            try:
                start_point = content.index("wns")
                log.seek(start_point)
                data = log.readline(start_point)
                rep.write(data)
            except:
                rep.write("SKIPPED!")
            
        elif sys.argv[3] == "tns_report":
            content = log.read()
            try:
                start_point = content.index("tns")
                log.seek(start_point)
                data = log.readline(start_point)
                rep.write(data)
            except:
                rep.write("SKIPPED!")
        else:
            content = log.read()
            try:
                start_point = content.index(sys.argv[3])
                end_point = content.index(sys.argv[4])
                log.seek(start_point)
                data = log.read(end_point - start_point)
                rep.write(data)
            except:
                rep.write("SKIPPED!")

rep.close()
log.close()


