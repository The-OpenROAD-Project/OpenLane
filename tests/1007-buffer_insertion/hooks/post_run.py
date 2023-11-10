# Copyright 2022 Efabless Corporation
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

import os
import odb

db = odb.dbDatabase.create()
odb.read_db(db, os.getenv("CURRENT_ODB"))
instances = db.getChip().getBlock().getInsts()
buffers = [
    instance for instance in instances if instance.getName() == "inserted_buffer"
]
assert len(buffers) == 1
buffer = buffers[0]

connected_terminals = [
    iterm for iterm in buffer.getITerms() if iterm.getNet() is not None
]

names = [iterm.getNet().getName() for iterm in connected_terminals]

assert "inserted_net" in names
assert "in" in names
