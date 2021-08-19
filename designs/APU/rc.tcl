# From OpenROAD Flow Scripts

# BSD 3-Clause License

# Copyright (c) 2018, The Regents of the University of California
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.

# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.

# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# sync from openroad repo test/sky130hd/sky130hd.rc
set_layer_rc -layer li1 -capacitance 1.499e-04 -resistance 7.176e-02
set_layer_rc -layer met1 -capacitance 1.449e-04 -resistance 8.929e-04
set_layer_rc -layer met2 -capacitance 1.331e-04 -resistance 8.929e-04
set_layer_rc -layer met3 -capacitance 1.464e-04 -resistance 1.567e-04
set_layer_rc -layer met4 -capacitance 1.297e-04 -resistance 1.567e-04
set_layer_rc -layer met5 -capacitance 1.501e-04 -resistance 1.781e-05
# end sync

set_layer_rc -via mcon -resistance 9.249146E-3
set_layer_rc -via via -resistance 4.5E-3
set_layer_rc -via via2 -resistance 3.368786E-3
set_layer_rc -via via3 -resistance 0.376635E-3
set_layer_rc -via via4 -resistance 0.00580E-3

set_wire_rc -signal -layer met2
set_wire_rc -clock -layer met5
