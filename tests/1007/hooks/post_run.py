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


class OdbReader(object):
    def __init__(self, lef_in, def_in):
        self.db = odb.dbDatabase.create()
        self.lef = odb.read_lef(self.db, lef_in)
        self.df = odb.read_def(self.db, def_in)
        self.block = self.db.getChip().getBlock()
        self.insts = self.block.getInsts()


reader = OdbReader(os.getenv("MERGED_LEF"), os.getenv("CURRENT_DEF"))
buffers = [
    instance for instance in reader.insts if instance.getName() == "inserted_buffer"
]
assert len(buffers) == 1
buffer = buffers[0]

connected_terminals = [
    iterm for iterm in buffer.getITerms() if iterm.getNet() is not None
]

names = [iterm.getNet().getName() for iterm in connected_terminals]

assert "inserted_net" in names
assert "in" in names
