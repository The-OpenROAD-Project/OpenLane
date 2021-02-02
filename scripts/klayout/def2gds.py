# From https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts

# The OpenROAD-flow repository (build and run scripts) has a BSD 3-Clause License with its text below.
# The flow relies on several tools, platforms and designs that each have their own licenses.
# 
# The license below applies ***only*** to the build and run scripts, not the OpenROAD tools.
# See the README.md file LICENSE section for details on the location of each components' individual license.
# 
# License for Build and Run scripts in the OpenROAD-flow repository only :
# 
# BSD 3-Clause License
# 
# Copyright (c) 2018, The Regents of the University of California
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# 
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# 
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
# 
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

import pya
import re
import json
import copy
import sys

# Expand layers in json
def expand_cfg_layers(cfg):
  layers = cfg['layers']
  expand = [layer for layer in layers if 'layers' in layers[layer]]
  for layer in expand:
    for i, (name, num) in enumerate(zip(layers[layer]['names'],
                                        layers[layer]['layers'])):
      new_layer = copy.deepcopy(layers[layer])
      del new_layer['names']
      new_layer['name'] = name
      del new_layer['layers']
      new_layer['layer'] = num
      layers[name] = new_layer
    del layers[layer]
    
def read_cfg():
  print('INFO: Reading config file: ' + config_file)
  with open(config_file, 'r') as f:
    cfg = json.load(f)

  expand_cfg_layers(cfg)
  cfg = cfg['layers'] # ignore the rest

  # Map gds layers & datatype to KLayout indices
  # These are arrays for the different mask numbers
  for layer, vals in cfg.items():
    layer = vals['layer']
    for key in ('opc', 'non-opc'):
      if key not in vals:
        continue
      data = vals[key]
      if isinstance(data['datatype'], int):
        data['datatype'] = [data['datatype']] # convert to array
      data['klayout'] = [main_layout.find_layer(layer, datatype)
                         for datatype in data['datatype']]

  return cfg

#match a line like:
# - LAYER M2 + MASK 2 + OPC RECT ( 3000 3000 ) ( 5000 5000 ) ;
rect_pat = re.compile(r'''
  \s*\-\ LAYER\ (?P<layer>\S+)  # The layer name
  (?:                           # Non-capturing group
  \s+\+\ MASK\ (?P<mask>\d+)    # Mask, None if absent
  )?
  (?P<opc>                      # OPC, None if absent
  \s+\+\ OPC
  )?
  \s+RECT\ 
   \(\ (?P<xlo>\d+)\ (?P<ylo>\d+)\ \)\   # rect lower-left pt
  \(\ (?P<xhi>\d+)\ (?P<yhi>\d+)\ \)\ ; # rect upper-right pt
  ''',
                      re.VERBOSE)

def read_fills(top):
  if config_file == '':
    print('WARNING: no fill config file specified')
    return
  # KLayout doesn't support FILL in DEF so we have to side load them :(
  cfg = read_cfg()
  in_fills = False
  units = None
  with open(in_def) as fp:
    for line in fp:
      if in_fills:
        if re.match('END FILLS', line):
          break # done with fills; don't care what follows
        m = re.match(rect_pat, line)
        if not m:
          raise Exception('Unrecognized fill: ' + line)
        opc_type = 'opc' if m.group('opc') else 'non-opc'
        mask = m.group('mask')
        if not mask: #uncolored just uses first entry
          mask = 0
        else:
          mask = int(mask) - 1 # DEF is 1-based indexing
        layer = cfg[m.group('layer')][opc_type]['klayout'][mask]
        xlo = int(m.group('xlo')) / units
        ylo = int(m.group('ylo')) / units
        xhi = int(m.group('xhi')) / units
        yhi = int(m.group('yhi')) / units
        top.shapes(layer).insert(pya.DBox(xlo, ylo, xhi, yhi))
      elif re.match('FILLS \d+ ;', line):
        in_fills = True
      elif not units:
        m = re.match('UNITS DISTANCE MICRONS (\d+)', line)
        if m:
          units = float(m.group(1))

# Load technology file
tech = pya.Technology()
tech.load(tech_file)
layoutOptions = tech.load_layout_options

# Load def file
main_layout = pya.Layout()
main_layout.read(in_def, layoutOptions)

# Clear cells
top_cell_index = main_layout.cell(design_name).cell_index()

print("[INFO] Clearing cells...")
for i in main_layout.each_cell():
  if i.cell_index() != top_cell_index:
    if not i.name.startswith("VIA"):
      #print("\t" + i.name)
      i.clear()

# Load in the gds to merge
print("[INFO] Merging GDS files...")
for gds in in_gds.split():
  print("\t{0}".format(gds))
  main_layout.read(gds)

# Copy the top level only to a new layout
print("[INFO] Copying toplevel cell '{0}'".format(design_name))
top_only_layout = pya.Layout()
top_only_layout.dbu = main_layout.dbu
top = top_only_layout.create_cell(design_name)
top.copy_tree(main_layout.cell(design_name))

read_fills(top)

print("[INFO] Checking for missing GDS...")
missing_gds = False
for i in top_only_layout.each_cell():
  if i.is_empty():
    missing_gds = True
    print("[ERROR] LEF Cell '{0}' has no matching GDS cell. Cell will be empty".format(i.name))

if not missing_gds:
  print("[INFO] All LEF cells have matching GDS cells")

if seal_gds:

  top_cell = top_only_layout.top_cell()

  print("[INFO] Reading seal GDS file...")
  print("\t{0}".format(seal_gds))
  top_only_layout.read(seal_gds)

  for cell in top_only_layout.top_cells():
    if cell != top_cell:
      print("[INFO] Merging '{0}' as child of '{1}'".format(cell.name, top_cell.name))
      top.insert(pya.CellInstArray(cell.cell_index(), pya.Trans()))

# Write out the GDS
print("[INFO] Writing out GDS '{0}'".format(out_gds))
top_only_layout.write(out_gds)
print("Done")
pya.Application.instance().exit(0)
