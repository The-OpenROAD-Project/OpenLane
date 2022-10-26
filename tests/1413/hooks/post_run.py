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
nets = db.getChip().getBlock().getNets()
pins = db.getChip().getBlock().getBTerms()
instances = db.getChip().getBlock().getInsts()

assert [instance.getName() for instance in instances] == []
assert [pin.getName() for pin in pins] == []
assert [net.getName() for net in nets] == ["out"]
