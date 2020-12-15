#!/usr/bin/env python3
#
# Copyright (C) 2020  Sylvain Munaut <tnt@246tNt.com>
# SPDX-License-Identifier: Apache-2.0
#

import argparse
import random
import sys

import opendbpy as odb


class DiodeInserter:

	def __init__(self, block, diode_cell, diode_pin, fake_diode_cell=None, side_strategy='source', short_span=0, port_protect=[], verbose=False):
		self.block = block
		self.verbose = verbose

		self.diode_cell = diode_cell
		self.diode_pin = diode_pin
		self.fake_diode_cell = fake_diode_cell
		self.side_strategy = side_strategy
		self.short_span = short_span
		self.port_protect = port_protect

		self.true_diode_master = block.getDataBase().findMaster(diode_cell)
		self.fake_diode_master = block.getDataBase().findMaster(fake_diode_cell) if (fake_diode_cell is not None) else None
		if not self.check():
			raise RuntimeError('True and Fake diodes are inconsistent')

		self.diode_master = self.fake_diode_master or self.true_diode_master
		self.diode_site   = self.true_diode_master.getSite().getConstName()

		self.inserted = {}

	def check(self):
		if self.fake_diode_master is None:
			return True

		tm = self.true_diode_master
		fm = self.fake_diode_master

		if fm.getSite() is None:
			self.error("[!] Fake diode cell missing SITE attribute");x
		else:
			if fm.getSite().getConstName() != tm.getSite().getConstName():
				return False

		if fm.getWidth() != tm.getWidth():
			return False
		if fm.getHeight() != tm.getHeight():
			return False

		return True

	def debug(self, msg):
		if self.verbose:
			print(msg, file=sys.stderr)

	def error(self, msg):
		print(msg, file=sys.stderr)

	def net_source(self, net):
		# See if it's an input pad
		for bt in net.getBTerms():
			if bt.getIoType() != 'INPUT':
				continue
			good, x, y = bt.getFirstPinLocation()
			if good:
				return (x, y)

		# Or maybe output of a cell
		x = odb.new_int(0)
		y = odb.new_int(0)

		for it in net.getITerms():
			if not it.isOutputSignal():
				continue
			if it.getAvgXY(x,y):
				return ( odb.get_int(x), odb.get_int(y) )

		# Nothing found
		return None

	def net_from_pin(self, net, io_types=None):
		for bt in net.getBTerms():
			if (io_types is None) or (bt.getIoType() in io_types):
				return True
		return False

	def net_has_diode(self, net):
		for it in net.getITerms():
			cell_type = it.getInst().getMaster().getConstName()
			cell_pin  = it.getMTerm().getConstName()
			if (cell_type == self.diode_cell) and (cell_pin == self.diode_pin):
				return True
		else:
			return False

	def net_span(self, net):
		xs = []
		ys = []

		for bt in net.getBTerms():
			good, x, y = bt.getFirstPinLocation()
			if good:
				xs.append(x)
				ys.append(y)

		for it in net.getITerms():
			x, y = self.pin_position(it)
			xs.append(x)
			ys.append(y)

		if len(xs) == 0:
			return 0

		return (max(ys) - min(ys)) + (max(xs) - min(xs))

	def pin_position(self, it):
		px = odb.new_int(0)
		py = odb.new_int(0)

		if it.getAvgXY(px,py):
			# Got it
			return odb.get_int(px), odb.get_int(py)
		else:
			# Failed, use the center coordinate of the instance as fall back
			return it.getInst().getLocation()

	def place_diode_stdcell(self, it, px, py, src_pos=None):
		# Get information about the instance
		inst_name  = it.getInst().getConstName()
		inst_width = it.getInst().getMaster().getWidth()
		inst_pos   = it.getInst().getLocation()
		inst_ori   = it.getInst().getOrient()

		# Is the pin left-ish, center-ish or right-ish ?
		pos = None

		if self.side_strategy == 'source':
			# Always be on the side of the source
			if src_pos is not None:
				pos = 'l' if (src_pos[0] < inst_pos[0]) else 'r'

		elif self.side_strategy == 'pin':
			# Always be on the side of the pin
			pos = 'l' if (px < (inst_pos[0] + inst_width // 2)) else 'r'

		elif self.side_strategy == 'balanced':
			# If pin is really on the side, use that, else use source side
			th_left  = int(inst_pos[0] + inst_width * 0.25)
			th_right = int(inst_pos[0] + inst_width * 0.75)

			if px < th_left:
				pos = 'l'
			elif px > th_right:
				pos = 'r'
			elif src_pos is not None:
				# Sort of middle, so put it on the side where signal is coming from
				pos = 'l' if (src_pos[0] < inst_pos[0]) else 'r'

		if pos is None:
			# Coin toss ...
			pos = 'l' if (random.random() > 0.5) else 'r'

		# X position
		dw = self.diode_master.getWidth()

		if pos == 'l':
			dx = inst_pos[0] - dw * (1 + self.inserted.get((inst_name, 'l'), 0))
		else:
			dx = inst_pos[0] + inst_width + dw * self.inserted.get((inst_name, 'r'), 0)

		# Record insertion
		self.inserted[(inst_name, pos)] = self.inserted.get((inst_name, pos), 0) + 1

		# Done
		return dx, inst_pos[1], inst_ori

	def place_diode_macro(self, it, px, py, src_pos=None):
		# Scan all rows to see how close we can get to the point
		best = None

		for row in self.block.getRows():
			rbb = row.getBBox()

			dx = max(min(rbb.xMax(), px), rbb.xMin())
			dy = rbb.yMin()
			do = row.getOrient()

			d = abs(px - dx) + abs(py - dy)

			if (best is None) or (best[0] > d):
				best = (d, dx, dy, do)

		return best[1:]

	def insert_diode(self, it, src_pos, force_true=False):
		# Get information about the instance
		inst       = it.getInst()
		inst_cell  = inst.getMaster().getConstName()
		inst_name  = inst.getConstName()
		inst_pos   = inst.getLocation()
		inst_site  = inst.getMaster().getSite().getConstName() if (inst.getMaster().getSite() is not None) else None

		# Find where the pin is
		px, py = self.pin_position(it)

		# Apply standard cell or macro placement ?
		if inst_site == self.diode_site:
			dx, dy, do = self.place_diode_stdcell(it, px, py, src_pos)
		else:
			dx, dy, do = self.place_diode_macro(it, px, py, src_pos)

		# Insert instance and wire it up
		diode_inst_name = 'ANTENNA_' + inst_name + '_' + it.getMTerm().getConstName()
		diode_master = self.true_diode_master if force_true else self.diode_master

		diode_inst = odb.dbInst_create(self.block, diode_master, diode_inst_name)

		diode_inst.setOrient(do)
		diode_inst.setLocation(dx, dy)
		diode_inst.setPlacementStatus('PLACED')

		ait = diode_inst.findITerm(self.diode_pin)
		odb.dbITerm_connect(ait, it.getNet())

	def execute(self):
		# Scan all nets
		for net in self.block.getNets():
			# Skip special nets
			if net.isSpecial():
				self.debug(f"[d] Skipping special net {net.getConstName():s}")
				continue

			# Check if we already have diode on the net
			# if yes, then we assume that the user took care of that net manually
			if self.net_has_diode(net):
				self.debug(f"[d] Skipping manually protected net {net.getConstName():s}")
				continue

			# Find signal source (first one found ...)
			src_pos = self.net_source(net)

			# Is this an IO we need to protect
			io_protect = self.net_from_pin(net, io_types=self.port_protect)
			if io_protect:
				self.debug(f"[d] Forcing protection diode on net  {net.getConstName():s}")

			# Determine the span of the signal and skip small internal nets
			span = self.net_span(net)
			if (span < self.short_span) and not io_protect:
				self.debug(f"[d] Skipping small net {net.getConstName():s} ({span:d})")
				continue

			# Scan all internal terminals
			for it in net.getITerms():
				if it.isInputSignal():
					self.insert_diode(it, src_pos, force_true=io_protect)


# Arguments
parser = argparse.ArgumentParser(
		description='Diode Insertion script')

parser.add_argument('--lef', '-l',
		nargs='+',
		type=str,
		default=None,
		required=True,
		help='Input LEF file(s)')

parser.add_argument('--input-def', '-id', required=True,
		help='DEF view of the design that needs to have diodes inserted')

parser.add_argument('--output-def', '-o', required=True,
		help='Output DEF file')

parser.add_argument('--verbose', '-v', action="store_true", default=False,
		help='Enable verbose debug output')

parser.add_argument('--diode-cell', '-c', default='sky130_fd_sc_hd__diode_2',
		help='Name of the cell to use as diode')

parser.add_argument('--fake-diode-cell', '-f',
		help='Name of the cell to use as fake diode')

parser.add_argument('--diode-pin', '-p', default='DIODE',
		help='Name of the pin to use on diode cells')

parser.add_argument('--side-strategy', choices=['source', 'pin', 'balanced', 'random'], default='source',
		help='Strategy to select if placing diode left/right of the cell')

parser.add_argument('--short-span', '-s', default=90000, type=int,
		help='Maximum span of a net to be considered "short" and not needing a diode')

parser.add_argument('--port-protect', choices=['none', 'in', 'out', 'both'], default='in',
		help='Always place a true diode on nets connected to selected ports')



args = parser.parse_args()
input_lef_file_names = args.lef
input_def_file_name = args.input_def
output_def_file_name = args.output_def

# Load
db_design = odb.dbDatabase.create()

for lef in input_lef_file_names:
    odb.read_lef(db_design, lef)
odb.read_def(db_design, input_def_file_name)

chip_design = db_design.getChip()
block_design = chip_design.getBlock()
top_design_name = block_design.getConstName()
print("Design name:", top_design_name)


pp_val = {
	'none': [],
	'in': ['INPUT'],
	'out': ['OUTPUT'],
	'both': ['INPUT', 'OUTPUT'],
}

di = DiodeInserter(block_design,
	diode_cell = args.diode_cell,
	diode_pin = args.diode_pin,
	fake_diode_cell = args.fake_diode_cell,
	side_strategy = args.side_strategy,
	short_span = args.short_span,
	port_protect = pp_val[args.port_protect],
	verbose = args.verbose
)
di.execute()

print("Inserted", len(di.inserted), "diodes.")

# Write result
odb.write_def(block_design, output_def_file_name)
