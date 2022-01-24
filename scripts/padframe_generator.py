#!/usr/bin/env python3
# flake8: noqa
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

#
# --------------------------------------------------------
# Padframe Editor and Core Floorplanner
#
# --------------------------------------------------------
# Written by Tim Edwards
# efabless, inc.
# April 24, 2019
# Version 0.5
# Based on https://github.com/YosysHQ/padring (requirement)
# Update: May 9, 2019 to add console message window
# Update: May 10, 2019 to incorporate core floorplanning
# Update: Jan 31, 2020 to allow batch operation
# --------------------------------------------------------

import os
import re
import sys
import glob
import json
import math
import shutil
import signal
import select
import subprocess
import faulthandler

import tkinter
from tkinter import ttk

# User preferences file (if it exists)
prefsfile = "~/design/.profile/prefs.json"

# ------------------------------------------------------
# Dialog for entering a pad
# ------------------------------------------------------


class ConsoleText(tkinter.Text):
    linelimit = 500

    class IORedirector(object):
        """A general class for redirecting I/O to this Text widget."""

        def __init__(self, text_area):
            self.text_area = text_area

    class StdoutRedirector(IORedirector):
        """A class for redirecting stdout to this Text widget."""

        def write(self, str):
            self.text_area.write(str, False)

    class StderrRedirector(IORedirector):
        """A class for redirecting stderr to this Text widget."""

        def write(self, str):
            self.text_area.write(str, True)

    def __init__(self, master=None, cnf={}, **kw):
        """See the __init__ for Tkinter.Text."""

        tkinter.Text.__init__(self, master, cnf, **kw)

        self.tag_configure("stdout", background="white", foreground="black")
        self.tag_configure("stderr", background="white", foreground="red")
        # None of these works!  Cannot change selected text background!
        self.config(selectbackground="blue", selectforeground="white")
        self.tag_configure("sel", background="blue", foreground="white")

    def write(self, val, is_stderr=False):
        lines = int(self.index("end-1c").split(".")[0])
        if lines > self.linelimit:
            self.delete("1.0", str(lines - self.linelimit) + ".0")
        self.insert("end", val, "stderr" if is_stderr else "stdout")
        self.see("end")

    def limit(self, val):
        self.linelimit = val


class Dialog(tkinter.Toplevel):
    def __init__(
        self, parent, message=None, title=None, seed=None, border="blue", **kwargs
    ):

        tkinter.Toplevel.__init__(self, parent)
        self.transient(parent)

        if title:
            self.title(title)

        self.configure(background=border, padx=2, pady=2)
        self.obox = ttk.Frame(self)
        self.obox.pack(side="left", fill="both", expand="true")

        self.parent = parent
        self.result = None
        body = ttk.Frame(self.obox)
        self.initial_focus = self.body(body, message, seed, **kwargs)
        body.pack(padx=5, pady=5)
        self.buttonbox()
        self.grab_set()

        if not self.initial_focus:
            self.initial_focus = self

        self.protocol("WM_DELETE_WINDOW", self.cancel)
        self.geometry("+%d+%d" % (parent.winfo_rootx() + 50, parent.winfo_rooty() + 50))

        self.initial_focus.focus_set()
        self.wait_window(self)

    # Construction hooks

    def body(self, master, **kwargs):
        # Create dialog body.  Return widget that should have
        # initial focus.  This method should be overridden
        pass

    def buttonbox(self):
        # Add standard button box.  Override if you don't want the
        # standard buttons

        box = ttk.Frame(self.obox)

        self.okb = ttk.Button(
            box, text="OK", width=10, command=self.ok, default="active"
        )
        self.okb.pack(side="left", padx=5, pady=5)
        w = ttk.Button(box, text="Cancel", width=10, command=self.cancel)
        w.pack(side="left", padx=5, pady=5)

        self.bind("<Return>", self.ok)
        self.bind("<Escape>", self.cancel)
        box.pack(fill="x", expand="true")

    # Standard button semantics

    def ok(self, event=None):

        if not self.validate():
            self.initial_focus.focus_set()  # put focus back
            return

        self.withdraw()
        self.update_idletasks()
        self.result = self.apply()
        self.cancel()

    def cancel(self, event=None):

        # Put focus back to the parent window
        self.parent.focus_set()
        self.destroy()

    def validate(self):
        return 1  # Override this

    def apply(self):
        return None  # Override this


class PadNameDialog(Dialog):
    def body(self, master, warning=None, seed=None):
        if warning:
            ttk.Label(master, text=warning).grid(row=0, columnspan=2, sticky="wns")
        ttk.Label(master, text="Enter new group name:").grid(
            row=1, column=0, sticky="wns"
        )
        self.nentry = ttk.Entry(master)
        self.nentry.grid(row=1, column=1, sticky="ewns")
        if seed:
            self.nentry.insert(0, seed)
        return self.nentry  # initial focus

    def apply(self):
        return self.nentry.get()


# ------------------------------------------------------
# Dialog for entering core dimensions
# ------------------------------------------------------


class CoreSizeDialog(Dialog):
    def body(self, master, warning="Chip core dimensions", seed=None):
        if warning:
            ttk.Label(master, text=warning).grid(row=0, columnspan=2, sticky="wns")
        ttk.Label(master, text="Enter core width x height (microns):").grid(
            row=1, column=0, sticky="wns"
        )
        self.nentry = ttk.Entry(master)
        self.nentry.grid(row=1, column=1, sticky="ewns")

        if seed:
            self.nentry.insert(0, seed)
        return self.nentry  # initial focus

    def apply(self):
        return self.nentry.get()


# ------------------------------------------------
# SoC Floorplanner and Padframe Generator GUI
# ------------------------------------------------


class SoCFloorplanner(ttk.Frame):
    """Open Galaxy Pad Frame Generator."""

    def __init__(self, parent=None, *args, **kwargs):
        """See the __init__ for Tkinter.Toplevel."""
        ttk.Frame.__init__(self, parent, *args[1:], **kwargs)
        self.root = parent
        self.init_data()
        if args[0] == True:
            self.do_gui = True
            self.init_gui()
        else:
            self.do_gui = False
            self.use_console = False

    def on_quit(self):
        """Exits program."""
        quit()

    def init_gui(self):
        """Builds GUI."""
        global prefsfile

        message = []
        fontsize = 11

        # Read user preferences file, get default font size from it.
        prefspath = os.path.expanduser(prefsfile)
        if os.path.exists(prefspath):
            with open(prefspath, "r") as f:
                self.prefs = json.load(f)
            if "fontsize" in self.prefs:
                fontsize = self.prefs["fontsize"]
        else:
            self.prefs = {}

        s = ttk.Style()

        available_themes = s.theme_names()
        s.theme_use(available_themes[0])

        s.configure(
            "normal.TButton", font=("Helvetica", fontsize), border=3, relief="raised"
        )
        s.configure(
            "title.TLabel",
            font=("Helvetica", fontsize, "bold italic"),
            foreground="brown",
            anchor="center",
        )
        s.configure("blue.TLabel", font=("Helvetica", fontsize), foreground="blue")
        s.configure("normal.TLabel", font=("Helvetica", fontsize))
        s.configure("normal.TCheckbutton", font=("Helvetica", fontsize))
        s.configure("normal.TMenubutton", font=("Helvetica", fontsize))
        s.configure("normal.TEntry", font=("Helvetica", fontsize), background="white")
        s.configure(
            "pad.TLabel", font=("Helvetica", fontsize), foreground="blue", relief="flat"
        )
        s.configure(
            "select.TLabel",
            font=("Helvetica", fontsize, "bold"),
            foreground="white",
            background="blue",
            relief="flat",
        )

        # parent.withdraw()
        self.root.title("Padframe Generator and Core Floorplanner")
        self.root.option_add("*tearOff", "FALSE")
        self.pack(side="top", fill="both", expand="true")
        self.root.protocol("WM_DELETE_WINDOW", self.on_quit)

        pane = tkinter.PanedWindow(
            self, orient="vertical", sashrelief="groove", sashwidth=6
        )
        pane.pack(side="top", fill="both", expand="true")

        self.toppane = ttk.Frame(pane)
        self.botpane = ttk.Frame(pane)

        self.toppane.columnconfigure(0, weight=1)
        self.toppane.rowconfigure(0, weight=1)
        self.botpane.columnconfigure(0, weight=1)
        self.botpane.rowconfigure(0, weight=1)

        # Scrolled frame using canvas widget
        self.pframe = tkinter.Frame(self.toppane)
        self.pframe.grid(row=0, column=0, sticky="news")
        self.pframe.rowconfigure(0, weight=1)
        self.pframe.columnconfigure(0, weight=1)

        # Add column on the left, listing all groups and the pads they belong to.
        # This starts as just a frame to be filled.  Use a canvas to create a
        # scrolled frame.

        # The primary frame holds the canvas
        self.canvas = tkinter.Canvas(self.pframe, background="white")
        self.canvas.grid(row=0, column=0, sticky="news")

        # Add Y scrollbar to pad list window
        xscrollbar = ttk.Scrollbar(self.pframe, orient="horizontal")
        xscrollbar.grid(row=1, column=0, sticky="news")
        yscrollbar = ttk.Scrollbar(self.pframe, orient="vertical")
        yscrollbar.grid(row=0, column=1, sticky="news")

        self.canvas.config(xscrollcommand=xscrollbar.set)
        xscrollbar.config(command=self.canvas.xview)
        self.canvas.config(yscrollcommand=yscrollbar.set)
        yscrollbar.config(command=self.canvas.yview)

        self.canvas.bind("<Button-4>", self.on_scrollwheel)
        self.canvas.bind("<Button-5>", self.on_scrollwheel)

        # Configure callback
        self.canvas.bind("<Configure>", self.frame_configure)

        # Add a text window to capture output.  Redirect print statements to it.
        self.console = ttk.Frame(self.botpane)
        self.console.grid(column=0, row=0, sticky="news")
        self.text_box = ConsoleText(self.console, wrap="word", height=4)
        self.text_box.pack(side="left", fill="both", expand="true")
        console_scrollbar = ttk.Scrollbar(self.console)
        console_scrollbar.pack(side="right", fill="y")
        # Attach console to scrollbar
        self.text_box.config(yscrollcommand=console_scrollbar.set)
        console_scrollbar.config(command=self.text_box.yview)

        # Add the bottom bar with buttons
        self.bbar = ttk.Frame(self.botpane)
        self.bbar.grid(column=0, row=1, sticky="news")

        self.bbar.import_button = ttk.Button(
            self.bbar, text="Import", command=self.vlogimport, style="normal.TButton"
        )
        self.bbar.import_button.grid(column=0, row=0, padx=5)

        self.bbar.generate_button = ttk.Button(
            self.bbar, text="Generate", command=self.generate, style="normal.TButton"
        )
        self.bbar.generate_button.grid(column=1, row=0, padx=5)

        self.bbar.save_button = ttk.Button(
            self.bbar, text="Save", command=self.save, style="normal.TButton"
        )
        self.bbar.save_button.grid(column=2, row=0, padx=5)

        self.bbar.cancel_button = ttk.Button(
            self.bbar, text="Quit", command=self.on_quit, style="normal.TButton"
        )
        self.bbar.cancel_button.grid(column=3, row=0, padx=5)

        pane.add(self.toppane)
        pane.add(self.botpane)
        pane.paneconfig(self.toppane, stretch="first")

    def init_data(self):

        self.vlogpads = []
        self.corecells = []
        self.Npads = []
        self.Spads = []
        self.Epads = []
        self.Wpads = []
        self.NEpad = []
        self.NWpad = []
        self.SEpad = []
        self.SWpad = []
        self.coregroup = []

        self.celldefs = []
        self.coredefs = []
        self.selected = []
        self.ioleflibs = []
        self.llx = 0
        self.lly = 0
        self.urx = 0
        self.ury = 0

        self.event_data = {}
        self.event_data["x0"] = 0
        self.event_data["y0"] = 0
        self.event_data["x"] = 0
        self.event_data["y"] = 0
        self.event_data["tag"] = None
        self.scale = 1.0
        self.margin = 100
        self.pad_rotation = 0

        self.init_messages = []
        self.stdout = None
        self.stderr = None

        self.keep_cfg = False
        self.ef_format = False
        self.use_console = False

    def init_padframe(self):
        self.set_project()
        self.vlogimport()
        self.readplacement(precheck=True)
        self.resolve()
        self.generate(0)

    # Local routines for handling printing to the text console

    def print(self, message, file=None, end="\n", flush=True):
        if not file:
            if not self.use_console:
                file = sys.stdout
            else:
                file = ConsoleText.StdoutRedirector(self.text_box)
        if self.stdout:
            print(message, file=file, end=end)
            if flush:
                self.stdout.flush()
                self.update_idletasks()
        else:
            self.init_messages.append(message)

    def text_to_console(self):
        # Redirect stdout and stderr to the console as the last thing to do. . .
        # Otherwise errors in the GUI get sucked into the void.

        self.stdout = sys.stdout
        self.stderr = sys.stderr
        if self.use_console:
            sys.stdout = ConsoleText.StdoutRedirector(self.text_box)
            sys.stderr = ConsoleText.StderrRedirector(self.text_box)

        if len(self.init_messages) > 0:
            for message in self.init_messages:
                self.print(message)
            self.init_messages = []

    # Set the project name(s).  This is the name of the top-level verilog.
    # The standard protocol is that the project directory contains a file
    # project.json that defines a name 'ip-name' that is the same as the
    # layout name, the verilog module name, etc.

    def set_project(self):
        # Check pwd
        pwdname = self.projectpath if self.projectpath else os.getcwd()

        subdir = os.path.split(pwdname)[1]
        if subdir == "mag" or subdir == "verilog":
            projectpath = os.path.split(pwdname)[0]
        else:
            projectpath = pwdname

        projectroot = os.path.split(projectpath)[0]
        projectdirname = os.path.split(projectpath)[1]

        # Check for project.json

        jsonname = None
        if os.path.isfile(projectpath + "/project.json"):
            jsonname = projectpath + "/project.json"
        elif os.path.isfile(projectroot + "/" + projectdirname + ".json"):
            jsonname = projectroot + "/" + projectdirname + ".json"
        if os.path.isfile(projectroot + "/project.json"):
            # Just in case this was started from some other subdirectory
            projectpath = projectroot
            jsonname = projectroot + "/project.json"

        if jsonname:
            self.print("Reading project JSON file " + jsonname)
            with open(jsonname, "r") as ifile:
                topdata = json.load(ifile)
                if "data-sheet" in topdata:
                    dsheet = topdata["data-sheet"]
                    if "ip-name" in dsheet:
                        self.project = dsheet["ip-name"]
                        self.projectpath = projectpath
        else:
            self.print(
                "No project JSON file; using directory name as the project name."
            )
            self.project = os.path.split(projectpath)[1]
            self.projectpath = projectpath

        self.print("Project name is " + self.project + " (" + self.projectpath + ")")

    # Functions for drag-and-drop capability
    def add_draggable(self, tag):
        self.canvas.tag_bind(tag, "<ButtonPress-1>", self.on_button_press)
        self.canvas.tag_bind(tag, "<ButtonRelease-1>", self.on_button_release)
        self.canvas.tag_bind(tag, "<B1-Motion>", self.on_button_motion)
        self.canvas.tag_bind(tag, "<ButtonPress-2>", self.on_button2_press)
        self.canvas.tag_bind(tag, "<ButtonPress-3>", self.on_button3_press)

    def on_button_press(self, event):
        """Begining drag of an object"""
        # Find the closest item, then record its tag.
        locx = event.x + self.canvas.canvasx(0)
        locy = event.y + self.canvas.canvasy(0)
        item = self.canvas.find_closest(locx, locy)[0]
        self.event_data["tag"] = self.canvas.gettags(item)[0]
        self.event_data["x0"] = event.x
        self.event_data["y0"] = event.y
        self.event_data["x"] = event.x
        self.event_data["y"] = event.y

    def on_button2_press(self, event):
        """Flip an object (excluding corners)"""
        locx = event.x + self.canvas.canvasx(0)
        locy = event.y + self.canvas.canvasy(0)
        item = self.canvas.find_closest(locx, locy)[0]
        tag = self.canvas.gettags(item)[0]

        try:
            corecell = next(item for item in self.coregroup if item["name"] == tag)
        except Exception:
            try:
                pad = next(item for item in self.Npads if item["name"] == tag)
            except Exception:
                pad = None
            if not pad:
                try:
                    pad = next(item for item in self.Epads if item["name"] == tag)
                except Exception:
                    pad = None
            if not pad:
                try:
                    pad = next(item for item in self.Spads if item["name"] == tag)
                except Exception:
                    pad = None
            if not pad:
                try:
                    pad = next(item for item in self.Wpads if item["name"] == tag)
                except Exception:
                    pad = None
            if not pad:
                self.print("Error: Object cannot be flipped.")
            else:
                # Flip the pad (in the only way meaningful for the pad).
                orient = pad["o"]
                if orient == "N":
                    pad["o"] = "FN"
                elif orient == "E":
                    pad["o"] = "FW"
                elif orient == "S":
                    pad["o"] = "FS"
                elif orient == "W":
                    pad["o"] = "FE"
                elif orient == "FN":
                    pad["o"] = "N"
                elif orient == "FE":
                    pad["o"] = "W"
                elif orient == "FS":
                    pad["o"] = "S"
                elif orient == "FW":
                    pad["o"] = "E"
        else:
            # Flip the cell.  Use the DEF meaning of flip, which is to
            # add or subtract 'F' from the orientation.
            orient = corecell["o"]
            if not "F" in orient:
                corecell["o"] = "F" + orient
            else:
                corecell["o"] = orient[1:]

        # Redraw
        self.populate(0)

    def on_button3_press(self, event):
        """Rotate a core object (no pads)"""
        locx = event.x + self.canvas.canvasx(0)
        locy = event.y + self.canvas.canvasy(0)
        item = self.canvas.find_closest(locx, locy)[0]
        tag = self.canvas.gettags(item)[0]

        try:
            corecell = next(item for item in self.coregroup if item["name"] == tag)
        except Exception:
            self.print("Error: Object cannot be rotated.")
        else:
            # Modify its orientation
            orient = corecell["o"]
            if orient == "N":
                corecell["o"] = "E"
            elif orient == "E":
                corecell["o"] = "S"
            elif orient == "S":
                corecell["o"] = "W"
            elif orient == "W":
                corecell["o"] = "N"
            elif orient == "FN":
                corecell["o"] = "FW"
            elif orient == "FW":
                corecell["o"] = "FS"
            elif orient == "FS":
                corecell["o"] = "FE"
            elif orient == "FE":
                corecell["o"] = "FN"

            # rewrite the core DEF file
            self.write_core_def()

        # Redraw
        self.populate(0)

    def on_button_motion(self, event):
        """Handle dragging of an object"""
        # compute how much the mouse has moved
        delta_x = event.x - self.event_data["x"]
        delta_y = event.y - self.event_data["y"]
        # move the object the appropriate amount
        self.canvas.move(self.event_data["tag"], delta_x, delta_y)
        # record the new position
        self.event_data["x"] = event.x
        self.event_data["y"] = event.y

    def on_button_release(self, event):
        """End drag of an object"""

        # Find the pad associated with the tag and update its position information
        tag = self.event_data["tag"]

        # Collect pads in clockwise order.  Note that E and S rows are not clockwise
        allpads = []
        allpads.extend(self.Npads)
        allpads.extend(self.NEpad)
        allpads.extend(reversed(self.Epads))
        allpads.extend(self.SEpad)
        allpads.extend(reversed(self.Spads))
        allpads.extend(self.SWpad)
        allpads.extend(self.Wpads)
        allpads.extend(self.NWpad)

        # Create a list of row references (also in clockwise order, but no reversing)
        padrows = [
            self.Npads,
            self.NEpad,
            self.Epads,
            self.SEpad,
            self.Spads,
            self.SWpad,
            self.Wpads,
            self.NWpad,
        ]

        # Record the row or corner where this pad was located before the move
        for row in padrows:
            try:
                pad = next(item for item in row if item["name"] == tag)
            except Exception:
                pass
            else:
                padrow = row
                break

        # Currently there is no procedure to move a pad out of the corner
        # position;  corners are fixed by definition.
        if (
            padrow == self.NEpad
            or padrow == self.SEpad
            or padrow == self.SWpad
            or padrow == self.NWpad
        ):
            # Easier to run generate() than to put the pad back. . .
            self.generate(0)
            return

        # Find the original center point of the pad being moved

        padllx = pad["x"]
        padlly = pad["y"]
        if pad["o"] == "N" or pad["o"] == "S":
            padurx = padllx + pad["width"]
            padury = padlly + pad["height"]
        else:
            padurx = padllx + pad["height"]
            padury = padlly + pad["width"]
        padcx = (padllx + padurx) / 2
        padcy = (padlly + padury) / 2

        # Add distance from drag information (note that drag position in y
        # is negative relative to the chip dimensions)
        padcx += (self.event_data["x"] - self.event_data["x0"]) / self.scale
        padcy -= (self.event_data["y"] - self.event_data["y0"]) / self.scale

        # reset the drag information
        self.event_data["tag"] = None
        self.event_data["x"] = 0
        self.event_data["y"] = 0
        self.event_data["x0"] = 0
        self.event_data["y0"] = 0

        # Find the distance from the pad to all other pads, and get the two
        # closest entries.

        wwidth = self.urx - self.llx
        dist0 = wwidth
        dist1 = wwidth
        pad0 = None
        pad1 = None

        for npad in allpads:
            if npad == pad:
                continue

            npadllx = npad["x"]
            npadlly = npad["y"]
            if npad["o"] == "N" or npad["o"] == "S":
                npadurx = npadllx + npad["width"]
                npadury = npadlly + npad["height"]
            else:
                npadurx = npadllx + npad["height"]
                npadury = npadlly + npad["width"]
            npadcx = (npadllx + npadurx) / 2
            npadcy = (npadlly + npadury) / 2

            deltx = npadcx - padcx
            delty = npadcy - padcy
            pdist = math.sqrt(deltx * deltx + delty * delty)
            if pdist < dist0:
                dist1 = dist0
                pad1 = pad0
                dist0 = pdist
                pad0 = npad

            elif pdist < dist1:
                dist1 = pdist
                pad1 = npad

        # Diagnostic
        # self.print('Two closest pads to pad ' + pad['name'] + ' (' + pad['cell'] + '): ')
        # self.print(pad0['name'] + ' (' + pad0['cell'] + ') dist = ' + str(dist0))
        # self.print(pad1['name'] + ' (' + pad1['cell'] + ') dist = ' + str(dist1))

        # Record the row or corner where these pads are
        for row in padrows:
            try:
                testpad = next(item for item in row if item["name"] == pad0["name"])
            except Exception:
                pass
            else:
                padrow0 = row
                break

        for row in padrows:
            try:
                testpad = next(item for item in row if item["name"] == pad1["name"])
            except Exception:
                pass
            else:
                padrow1 = row
                break

        # Remove pad from its own row
        padrow.remove(pad)

        # Insert pad into new row.  Watch for wraparound from the last entry to the first
        padidx0 = allpads.index(pad0)
        padidx1 = allpads.index(pad1)
        if padidx0 == 0 and padidx1 > 2:
            padidx1 = -1

        if padidx1 > padidx0:
            padafter = pad1
            rowafter = padrow1
            padbefore = pad0
            rowbefore = padrow0
        else:
            padafter = pad0
            rowafter = padrow0
            padbefore = pad1
            rowbefore = padrow1

        # Do not replace corner positions (? may be necessary ?)
        if rowafter == self.NWpad:
            self.Wpads.append(pad)
        elif rowafter == self.NWpad:
            self.Npads.append(pad)
        elif rowafter == self.SEpad:
            self.Epads.insert(0, pad)
        elif rowafter == self.SWpad:
            self.Spads.insert(0, pad)
        elif rowafter == self.Wpads or rowafter == self.Npads:
            idx = rowafter.index(padafter)
            rowafter.insert(idx, pad)
        elif rowbefore == self.NEpad:
            self.Epads.append(pad)
        elif rowbefore == self.SEpad:
            self.Spads.append(pad)
        else:
            # rows E and S are ordered counterclockwise
            idx = rowbefore.index(padbefore)
            rowbefore.insert(idx, pad)

        # Re-run padring
        self.generate(0)

    def on_scrollwheel(self, event):
        if event.num == 4:
            zoomval = 1.1
        elif event.num == 5:
            zoomval = 0.9
        else:
            zoomval = 1.0

        self.scale *= zoomval
        self.canvas.scale("all", -15 * zoomval, -15 * zoomval, zoomval, zoomval)
        self.event_data["x"] *= zoomval
        self.event_data["y"] *= zoomval
        self.event_data["x0"] *= zoomval
        self.event_data["y0"] *= zoomval
        self.frame_configure(event)

    # Callback functions similar to the pad event callbacks above, but for
    # core cells.  Unlike pad cells, core cells can be rotated and flipped
    # arbitrarily, and they do not force a recomputation of the padframe
    # unless their position forces the padframe to expand

    def add_core_draggable(self, tag):
        self.canvas.tag_bind(tag, "<ButtonPress-1>", self.on_button_press)
        self.canvas.tag_bind(tag, "<ButtonRelease-1>", self.core_on_button_release)
        self.canvas.tag_bind(tag, "<B1-Motion>", self.on_button_motion)
        self.canvas.tag_bind(tag, "<ButtonPress-2>", self.on_button2_press)
        self.canvas.tag_bind(tag, "<ButtonPress-3>", self.on_button3_press)

    def core_on_button_release(self, event):
        """End drag of a core cell"""

        # Find the pad associated with the tag and update its position information
        tag = self.event_data["tag"]

        try:
            corecell = next(item for item in self.coregroup if item["name"] == tag)
        except Exception:
            self.print("Error: cell " + item["name"] + " is not in coregroup!")
        else:
            # Modify its position values
            corex = corecell["x"]
            corey = corecell["y"]

            # Add distance from drag information (note that drag position in y
            # is negative relative to the chip dimensions)
            deltax = (self.event_data["x"] - self.event_data["x0"]) / self.scale
            deltay = (self.event_data["y"] - self.event_data["y0"]) / self.scale

            corecell["x"] = corex + deltax
            corecell["y"] = corey - deltay

            # rewrite the core DEF file
            self.write_core_def()

        # reset the drag information
        self.event_data["tag"] = None
        self.event_data["x"] = 0
        self.event_data["y"] = 0
        self.event_data["x0"] = 0
        self.event_data["y0"] = 0

    # Critically needed or else frame does not resize to scrollbars!
    def grid_configure(self, padx, pady):
        pass

    # Redraw the chip frame view in response to changes in the pad list
    def redraw_frame(self):
        self.canvas.coords("boundary", self.llx, self.urx, self.lly, self.ury)

    # Update the canvas scrollregion to incorporate all the interior windows
    def frame_configure(self, event):
        if self.do_gui == False:
            return
        self.update_idletasks()
        bbox = self.canvas.bbox("all")
        try:
            newbbox = (-15, -15, bbox[2] + 15, bbox[3] + 15)
        except Exception:
            pass
        else:
            self.canvas.configure(scrollregion=newbbox)

    # Fill the GUI entries with resident data
    def populate(self, level):
        if self.do_gui == False:
            return

        if level > 1:
            self.print("Recursion error:  Returning now.")
            return

        self.print("Populating floorplan view.")

        # Remove all entries from the canvas
        self.canvas.delete("all")

        allpads = (
            self.Npads
            + self.NEpad
            + self.Epads
            + self.SEpad
            + self.Spads
            + self.SWpad
            + self.Wpads
            + self.NWpad
        )

        notfoundlist = []

        for pad in allpads:
            if "x" not in pad:
                self.print(
                    "Error:  Pad " + pad["name"] + " has no placement information."
                )
                continue
            llx = int(pad["x"])
            lly = int(pad["y"])
            pado = pad["o"]
            try:
                padcell = next(
                    item for item in self.celldefs if item["name"] == pad["cell"]
                )
            except Exception:
                # This should not happen (failsafe)
                if pad["cell"] not in notfoundlist:
                    self.print(
                        "Warning:  there is no cell named "
                        + pad["cell"]
                        + " in the libraries."
                    )
                notfoundlist.append(pad["cell"])
                continue
            padw = padcell["width"]
            padh = padcell["height"]
            if "N" in pado or "S" in pado:
                urx = int(llx + padw)
                ury = int(lly + padh)
            else:
                urx = int(llx + padh)
                ury = int(lly + padw)

            pad["llx"] = llx
            pad["lly"] = lly
            pad["urx"] = urx
            pad["ury"] = ury

        # Note that the DEF coordinate system is reversed in Y from the canvas. . .

        height = self.ury - self.lly
        for pad in allpads:

            llx = pad["llx"]
            lly = height - pad["lly"]
            urx = pad["urx"]
            ury = height - pad["ury"]

            tag_id = pad["name"]
            if "subclass" in pad:
                if pad["subclass"] == "POWER":
                    pad_color = "orange2"
                elif pad["subclass"] == "INOUT":
                    pad_color = "yellow"
                elif pad["subclass"] == "OUTPUT":
                    pad_color = "powder blue"
                elif pad["subclass"] == "INPUT":
                    pad_color = "goldenrod1"
                elif pad["subclass"] == "SPACER":
                    pad_color = "green yellow"
                elif pad["class"] == "ENDCAP":
                    pad_color = "green yellow"
                elif pad["subclass"] == "" or pad["class"] == ";":
                    pad_color = "khaki1"
                else:
                    self.print("Unhandled pad class " + pad["class"])
                    pad_color = "gray"
            else:
                pad_color = "gray"

            sllx = self.scale * llx
            slly = self.scale * lly
            surx = self.scale * urx
            sury = self.scale * ury

            self.canvas.create_rectangle(
                (sllx, slly), (surx, sury), fill=pad_color, tags=[tag_id]
            )
            cx = (sllx + surx) / 2
            cy = (slly + sury) / 2

            s = 10 if pad["width"] >= 10 else pad["width"]
            if pad["height"] < s:
                s = pad["height"]

            # Create an indicator line at the bottom left corner of the cell
            if pad["o"] == "N":
                allx = sllx
                ally = slly - s
                aurx = sllx + s
                aury = slly
            elif pad["o"] == "E":
                allx = sllx
                ally = sury + s
                aurx = sllx + s
                aury = sury
            elif pad["o"] == "S":
                allx = surx
                ally = sury + s
                aurx = surx - s
                aury = sury
            elif pad["o"] == "W":
                allx = surx
                ally = slly - s
                aurx = surx - s
                aury = slly
            elif pad["o"] == "FN":
                allx = surx
                ally = slly - s
                aurx = surx - s
                aury = slly
            elif pad["o"] == "FE":
                allx = surx
                ally = sury + s
                aurx = surx - s
                aury = sury
            elif pad["o"] == "FS":
                allx = sllx
                ally = sury + s
                aurx = sllx + s
                aury = sury
            elif pad["o"] == "FW":
                allx = sllx
                ally = slly - s
                aurx = sllx + s
                aury = slly
            self.canvas.create_line((allx, ally), (aurx, aury), tags=[tag_id])

            # Rotate text on top and bottom rows if the tkinter version allows it.
            if tkinter.TclVersion >= 8.6:
                if pad["o"] == "N" or pad["o"] == "S":
                    angle = 90
                else:
                    angle = 0
                self.canvas.create_text(
                    (cx, cy), text=pad["name"], angle=angle, tags=[tag_id]
                )
            else:
                self.canvas.create_text((cx, cy), text=pad["name"], tags=[tag_id])

            # Make the pad draggable
            self.add_draggable(tag_id)

        # Now add the core cells
        for cell in self.coregroup:
            if "x" not in cell:
                self.print(
                    "Error:  Core cell "
                    + cell["name"]
                    + " has no placement information."
                )
                continue
            # else:
            #     self.print('Diagnostic:  Creating object for core cell ' + cell['name'])
            llx = int(cell["x"])
            lly = int(cell["y"])
            cello = cell["o"]
            try:
                corecell = next(
                    item for item in self.coredefs if item["name"] == cell["cell"]
                )
            except Exception:
                # This should not happen (failsafe)
                if cell["cell"] not in notfoundlist:
                    self.print(
                        "Warning:  there is no cell named "
                        + cell["cell"]
                        + " in the libraries."
                    )
                notfoundlist.append(cell["cell"])
                continue
            cellw = corecell["width"]
            cellh = corecell["height"]
            if "N" in cello or "S" in cello:
                urx = int(llx + cellw)
                ury = int(lly + cellh)
            else:
                urx = int(llx + cellh)
                ury = int(lly + cellw)
                print(
                    "NOTE: cell "
                    + corecell["name"]
                    + " is rotated, w = "
                    + str(urx - llx)
                    + "; h = "
                    + str(ury - lly)
                )

            cell["llx"] = llx
            cell["lly"] = lly
            cell["urx"] = urx
            cell["ury"] = ury

        # Watch for out-of-window position in core cells.
        corellx = self.llx
        corelly = self.lly
        coreurx = self.urx
        coreury = self.ury

        for cell in self.coregroup:

            if "llx" not in cell:
                # Error message for this was handled above
                continue

            llx = cell["llx"]
            lly = height - cell["lly"]
            urx = cell["urx"]
            ury = height - cell["ury"]

            # Check for out-of-window cell
            if llx < corellx:
                corellx = llx
            if lly < corelly:
                corelly = lly
            if urx > coreurx:
                coreurx = urx
            if ury > coreury:
                coreury = ury

            tag_id = cell["name"]
            cell_color = "gray40"

            sllx = self.scale * llx
            slly = self.scale * lly
            surx = self.scale * urx
            sury = self.scale * ury

            self.canvas.create_rectangle(
                (sllx, slly), (surx, sury), fill=cell_color, tags=[tag_id]
            )
            cx = (sllx + surx) / 2
            cy = (slly + sury) / 2

            s = 10 if cell["width"] >= 10 else cell["width"]
            if cell["height"] < s:
                s = cell["height"]

            # Create an indicator line at the bottom left corner of the cell
            if cell["o"] == "N":
                allx = sllx
                ally = slly - s
                aurx = sllx + s
                aury = slly
            elif cell["o"] == "E":
                allx = sllx
                ally = sury + s
                aurx = sllx + s
                aury = sury
            elif cell["o"] == "S":
                allx = surx
                ally = sury + s
                aurx = surx - s
                aury = sury
            elif cell["o"] == "W":
                allx = surx
                ally = slly - s
                aurx = surx - s
                aury = slly
            elif cell["o"] == "FN":
                allx = surx
                ally = slly - s
                aurx = surx - s
                aury = slly
            elif cell["o"] == "FE":
                allx = surx
                ally = sury + s
                aurx = surx - s
                aury = sury
            elif cell["o"] == "FS":
                allx = sllx
                ally = sury + s
                aurx = sllx + s
                aury = sury
            elif cell["o"] == "FW":
                allx = sllx
                ally = slly - s
                aurx = sllx + s
                aury = slly
            self.canvas.create_line((allx, ally), (aurx, aury), tags=[tag_id])

            # self.print('Created entry for cell ' + cell['name'] + ' at {0:g}, {1:g}'.format(cx, cy))

            # Rotate text on top and bottom rows if the tkinter version allows it.
            if tkinter.TclVersion >= 8.6:
                if "N" in cell["o"] or "S" in cell["o"]:
                    angle = 90
                else:
                    angle = 0
                self.canvas.create_text(
                    (cx, cy), text=cell["name"], angle=angle, tags=[tag_id]
                )
            else:
                self.canvas.create_text((cx, cy), text=cell["name"], tags=[tag_id])

            # Make the core cell draggable
            self.add_core_draggable(tag_id)

        # Is there a boundary size defined?
        if self.urx > self.llx and self.ury > self.lly:
            self.create_boundary()

        # Did the core extend into negative X or Y?  If so, adjust all canvas
        # coordinates to fit in the window, or else objects cannot be reached
        # even by zooming out (since zooming is pinned on the top corner).

        offsetx = 0
        offsety = 0

        # NOTE:  Probably want to check if the core exceeds the inner
        # dimension of the pad ring, not the outer (to check and to do).

        if corellx < self.llx:
            offsetx = self.llx - corellx
        if corelly < self.lly:
            offsety = self.lly - corelly
        if offsetx > 0 or offsety > 0:
            self.canvas.move("all", offsetx, offsety)
            # An offset implies that the chip is core limited, and the
            # padframe requires additional space.  This can be accomplished
            # simply by running "Generate".  NOTE:  Since generate() calls
            # populate(), be VERY SURE that this does not infinitely recurse!
            self.generate(level)

    # Generate a DEF file of the core area

    def write_core_def(self):
        self.print('Writing core placementment information in DEF file "core.def".')

        mag_path = self.projectpath + "/mag"

        # The core cells must always clear the I/O pads on the left and
        # bottom (with the ad-hoc margin of self.margin).  If core cells have
        # been moved to the left or down past the padframe edge, then the
        # entire core needs to be repositioned.

        # To be done:  draw a boundary around the core, let the edges of that
        # boundary be draggable, and let the difference between the boundary
        # and the core area define the margin.

        if self.SWpad != []:
            corellx = self.SWpad[0]["x"] + self.SWpad[0]["width"] + self.margin
            corelly = self.SWpad[0]["y"] + self.SWpad[0]["height"] + self.margin
        else:
            corellx = self.Wpads[0]["x"] + self.Wpads[0]["height"] + self.margin
            corelly = self.Spads[0]["x"] + self.Spads[0]["height"] + self.margin

        offsetx = 0
        offsety = 0
        for corecell in self.coregroup:
            if corecell["x"] < corellx:
                if corellx - corecell["x"] > offsetx:
                    offsetx = corellx - corecell["x"]
            if corecell["y"] < corelly:
                if corelly - corecell["y"] > offsety:
                    offsety = corelly - corecell["y"]
        if offsetx > 0 or offsety > 0:
            for corecell in self.coregroup:
                corecell["x"] += offsetx
                corecell["y"] += offsety

        # Now write the core DEF file

        with open(mag_path + "/core.def", "w") as ofile:
            print("DESIGN CORE ;", file=ofile)
            print("UNITS DISTANCE MICRONS 1000 ;", file=ofile)
            print("COMPONENTS {0:d} ;".format(len(self.coregroup)), file=ofile)
            for corecell in self.coregroup:
                print(
                    "  - " + corecell["name"] + " " + corecell["cell"],
                    file=ofile,
                    end="",
                )
                print(
                    " + PLACED ( {0:d} {1:d} ) {2:s} ;".format(
                        int(corecell["x"] * 1000),
                        int(corecell["y"] * 1000),
                        corecell["o"],
                    ),
                    file=ofile,
                )
            print("END COMPONENTS", file=ofile)
            print("END DESIGN", file=ofile)

    # Create the chip boundary area

    def create_boundary(self):
        scale = self.scale
        llx = (self.llx - 10) * scale
        lly = (self.lly - 10) * scale
        urx = (self.urx + 10) * scale
        ury = (self.ury + 10) * scale

        pad_color = "plum1"
        tag_id = "boundary"
        self.canvas.create_rectangle(
            (llx, lly), (urx, ury), outline=pad_color, width=2, tags=[tag_id]
        )
        # Add text to the middle representing the chip and core areas
        cx = ((self.llx + self.urx) / 2) * scale
        cy = ((self.lly + self.ury) / 2) * scale
        width = self.urx - self.llx
        height = self.ury - self.lly
        areatext = "Chip dimensions (um): {0:g} x {1:g}".format(width, height)
        tag_id = "chiparea"
        self.canvas.create_text((cx, cy), text=areatext, tags=[tag_id])

    # Rotate orientation according to self.pad_rotation.

    def rotate_orientation(self, orient_in):
        orient_v = ["N", "E", "S", "W", "N", "E", "S", "W"]
        idxadd = int(self.pad_rotation / 90)
        idx = orient_v.index(orient_in)
        return orient_v[idx + idxadd]

    # Read a list of cell macros (name, size, class) from a LEF library

    def read_lef_macros(self, libpath, libname=None, libtype="iolib"):
        if libtype == "iolib":
            libtext = "I/O "
        elif libtype == "celllib":
            libtext = "core "
        else:
            libtext = ""

        macros = []

        if libname:
            if os.path.splitext(libname)[1] == "":
                libname += ".lef"
            leffiles = glob.glob(libpath + "/" + libname)
        else:
            leffiles = glob.glob(libpath + "/*.lef")
        if leffiles == []:
            if libname:
                self.print("WARNING:  No file " + libpath + "/" + libname + ".lef")
            else:
                self.print("WARNING:  No files " + libpath + "/*.lef")
        for leffile in leffiles:
            libpath = os.path.split(leffile)[0]
            libname = os.path.split(libpath)[1]
            self.print("Reading LEF " + libtext + "library " + leffile)
            with open(leffile, "r") as ifile:
                ilines = ifile.read().splitlines()
                in_macro = False
                for iline in ilines:
                    iparse = iline.split()
                    if iparse == []:
                        continue
                    elif iparse[0] == "MACRO":
                        in_macro = True
                        newmacro = {}
                        newmacro["name"] = iparse[1]
                        newmacro[libtype] = leffile
                        macros.append(newmacro)
                    elif in_macro:
                        if iparse[0] == "END":
                            if len(iparse) > 1 and iparse[1] == newmacro["name"]:
                                in_macro = False
                        elif iparse[0] == "CLASS":
                            newmacro["class"] = iparse[1]
                            if len(iparse) > 2:
                                newmacro["subclass"] = iparse[2]

                                # Use the 'ENDCAP' class to identify pad rotations
                                # other than BOTTOMLEFT.  This is somewhat ad-hoc
                                # depending on the foundry;  may not be generally
                                # applicable.

                                if newmacro["class"] == "ENDCAP":
                                    if newmacro["subclass"] == "TOPLEFT":
                                        self.pad_rotation = 90
                                    elif newmacro["subclass"] == "TOPRIGHT":
                                        self.pad_rotation = 180
                                    elif newmacro["subclass"] == "BOTTOMRIGHT":
                                        self.pad_rotation = 270
                            else:
                                newmacro["subclass"] = None
                        elif iparse[0] == "SIZE":
                            newmacro["width"] = float(iparse[1])
                            newmacro["height"] = float(iparse[3])
                        elif iparse[0] == "ORIGIN":
                            newmacro["x"] = float(iparse[1])
                            newmacro["y"] = float(iparse[2])
        return macros

    # Read a list of cell names from a verilog file
    # If filename is relative, then check in the same directory as the verilog
    # top-level netlist (vlogpath) and in the subdirectory 'source/' of the top-
    # level directory.  Also check in the ~/design/ip/ directory.  These are
    # common include paths for the simulation.

    def read_verilog_lib(self, incpath, vlogpath):
        iocells = []
        if not os.path.isfile(incpath) and incpath[0] != "/":
            locincpath = vlogpath + "/" + incpath
            if not os.path.isfile(locincpath):
                locincpath = vlogpath + "/source/" + incpath
            if not os.path.isfile(locincpath):
                projectpath = os.path.split(vlogpath)[0]
                designpath = os.path.split(projectpath)[0]
                locincpath = designpath + "/ip/" + incpath
        else:
            locincpath = incpath

        if not os.path.isfile(locincpath):
            self.print("File " + incpath + " not found (at " + locincpath + ")!")
        else:
            self.print("Reading verilog library " + locincpath)
            with open(locincpath, "r") as ifile:
                ilines = ifile.read().splitlines()
                for iline in ilines:
                    iparse = re.split("[\t ()]", iline)
                    while "" in iparse:
                        iparse.remove("")
                    if iparse == []:
                        continue
                    elif iparse[0] == "module":
                        iocells.append(iparse[1])
        return iocells

    # Generate a LEF abstract view from a magic layout.  If "outpath" is not
    # "None", then write output to outputpath (this is required if the input
    # file is in a read-only directory).

    def write_lef_file(self, magfile, outpath=None):
        mag_path = os.path.split(magfile)[0]
        magfullname = os.path.split(magfile)[1]
        module = os.path.splitext(magfullname)[0]

        if outpath:
            write_path = outpath
        else:
            write_path = mag_path

        self.print("Generating LEF view from layout for module " + module)

        with open(write_path + "/pfg_write_lef.tcl", "w") as ofile:
            print("drc off", file=ofile)
            print("box 0 0 0 0", file=ofile)
            # NOTE:  Using "-force" option in case an IP with a different but
            # compatible tech is used (e.g., EFHX035A IP inside EFXH035C).  This
            # is not checked for legality!
            if outpath:
                print("load " + magfile + " -force", file=ofile)
            else:
                print("load " + module + " -force", file=ofile)
            print("lef write", file=ofile)
            print("quit", file=ofile)

        magicexec = self.magic_path if self.magic_path else "magic"
        mproc = subprocess.Popen(
            [magicexec, "-dnull", "-noconsole", "pfg_write_lef.tcl"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            cwd=write_path,
            universal_newlines=True,
        )

        self.watch(mproc)
        os.remove(write_path + "/pfg_write_lef.tcl")

    # Watch a running process, polling for output and updating the GUI message
    # window as output arrives.  Return only when the process has exited.
    # Note that this process cannot handle stdin(), so any input to the process
    # must be passed from a file.

    def watch(self, process):
        if process == None:
            return

        while True:
            status = process.poll()
            if status != None:
                try:
                    outputpair = process.communicate(timeout=1)
                except ValueError:
                    self.print("Process forced stop, status " + str(status))
                else:
                    for line in outputpair[0].splitlines():
                        self.print(line)
                    for line in outputpair[1].splitlines():
                        self.print(line, file=sys.stderr)
                break
            else:
                sresult = select.select([process.stdout, process.stderr], [], [], 0)[0]
                if process.stdout in sresult:
                    outputline = process.stdout.readline().strip()
                    self.print(outputline)
                elif process.stderr in sresult:
                    outputline = process.stderr.readline().strip()
                    self.print(outputline, file=sys.stderr)
                else:
                    self.update_idletasks()

    # Reimport the pad list by reading the top-level verilog netlist.  Determine
    # what pads are listed in the file, and check against the existing pad list.

    # The verilog/ directory should have a .v file containing a module of the
    # same name as self.project (ip-name).  The .v filename should have the
    # same name as well (but not necessarily).  To do:  Handle import of
    # projects having a top-level schematic instead of a verilog netlist.

    def vlogimport(self):
        self.print("Importing verilog sources.")

        # First find the process PDK name for this project.  Read the nodeinfo.json
        # file and find the list of I/O cell libraries.

        techpath = self.techpath if self.techpath else self.projectpath
        if os.path.exists(techpath + "/.config"):
            config_dir = "/.config"
        else:
            config_dir = "/.ef-config"
            if os.path.exists(techpath + config_dir):
                self.ef_format = True

        pdkpath = (
            self.techpath
            if self.techpath
            else os.path.realpath(self.projectpath + config_dir + "/techdir")
        )
        nodeinfopath = pdkpath + config_dir + "/nodeinfo.json"
        ioleflist = []
        if os.path.exists(nodeinfopath):
            self.print("Reading known I/O cell libraries from " + nodeinfopath)
            with open(nodeinfopath, "r") as ifile:
                itop = json.load(ifile)
                if "iocells" in itop:
                    ioleflist = []
                    for iolib in itop["iocells"]:
                        if "/" in iolib:
                            # Entries <lib>/<cell> refer to specific files
                            libcell = iolib.split("/")
                            if self.ef_format:
                                iolibpath = pdkpath + "/libs.ref/lef/" + libcell[0]
                            else:
                                iolibpath = (
                                    pdkpath + "/libs.ref/" + libcell[0] + "/lef/"
                                )
                            ioleflist.extend(
                                glob.glob(iolibpath + "/" + libcell[1] + ".lef")
                            )
                        else:
                            # All other entries refer to everything in the directory.
                            if self.ef_format:
                                iolibpath = pdkpath + "/libs.ref/lef/" + iolib
                            else:
                                iolibpath = pdkpath + "/libs.ref/" + iolib + "/lef/"
                            print(iolibpath)
                            ioleflist.extend(glob.glob(iolibpath + "/*.lef"))
        else:
            # Diagnostic
            print("Cannot read PDK information file " + nodeinfopath)

        # Fallback behavior:  List everything in libs.ref/lef/ beginning with "IO"
        if len(ioleflist) == 0:
            if self.ef_format:
                ioleflist = glob.glob(pdkpath + "/libs.ref/lef/IO*/*.lef")
            else:
                ioleflist = glob.glob(pdkpath + "/libs.ref/IO*/lef/*.lef")

        if len(ioleflist) == 0:
            self.print("Cannot find any I/O cell libraries for this technology")
            return

        # Read the LEF libraries to get a list of all available cells.  Keep
        # this list of cells in "celldefs".

        celldefs = []
        ioliblist = []
        ioleflibs = []
        for iolib in ioleflist:
            iolibpath = os.path.split(iolib)[0]
            iolibfile = os.path.split(iolib)[1]
            ioliblist.append(os.path.split(iolibpath)[1])
            celldefs.extend(self.read_lef_macros(iolibpath, iolibfile, "iolib"))

        verilogcells = []
        newpadlist = []
        coredefs = []
        corecells = []
        corecelllist = []
        lefprocessed = []

        busrex = re.compile(".*\[[ \t]*([0-9]+)[ \t]*:[ \t]*([0-9]+)[ \t]*\]")

        vlogpath = self.projectpath + "/verilog"
        vlogfile = vlogpath + "/" + self.project + ".v"
        if os.path.isfile(vlogfile):
            with open(vlogfile, "r") as ifile:
                vloglines = ifile.read().splitlines()
                for vlogline in vloglines:
                    vlogparse = re.split("[\t ()]", vlogline)
                    while "" in vlogparse:
                        vlogparse.remove("")
                    if vlogparse == []:
                        continue
                    elif vlogparse[0] == "//":
                        continue
                    elif vlogparse[0] == "`include":
                        incpath = vlogparse[1].strip('"')
                        libpath = os.path.split(incpath)[0]
                        libname = os.path.split(libpath)[1]
                        libfile = os.path.split(incpath)[1]

                        # Read the verilog library for module names to match
                        # against macro names in celldefs.
                        modulelist = self.read_verilog_lib(incpath, vlogpath)
                        matching = list(
                            item for item in celldefs if item["name"] in modulelist
                        )
                        for imatch in matching:
                            verilogcells.append(imatch["name"])
                            leffile = imatch["iolib"]
                            if leffile not in ioleflibs:
                                ioleflibs.append(leffile)

                        # Read a corresponding LEF file entry for non-I/O macros, if one
                        # can be found (this handles files in the PDK).
                        if len(matching) == 0:
                            if libname != "":
                                # (NOTE:  Assumes full path starting with '/')
                                lefpath = libpath.replace("verilog", "lef")
                                lefname = libfile.replace(".v", ".lef")
                                if not os.path.exists(lefpath + "/" + lefname):
                                    leffiles = glob.glob(lefpath + "/*.lef")
                                else:
                                    leffiles = [lefpath + "/" + lefname]

                                for leffile in leffiles:
                                    if leffile in ioleflibs:
                                        continue
                                    elif leffile in lefprocessed:
                                        continue
                                    else:
                                        lefprocessed.append(leffile)

                                    lefname = os.path.split(leffile)[1]

                                    newcoredefs = self.read_lef_macros(
                                        lefpath, lefname, "celllib"
                                    )
                                    coredefs.extend(newcoredefs)
                                    corecells.extend(
                                        list(item["name"] for item in newcoredefs)
                                    )

                                if leffiles == []:
                                    maglefname = libfile.replace(".v", ".mag")

                                    # Handle PDK files with a maglef/ view but no LEF file.
                                    maglefpath = libpath.replace("verilog", "maglef")
                                    if not os.path.exists(
                                        maglefpath + "/" + maglefname
                                    ):
                                        magleffiles = glob.glob(maglefpath + "/*.mag")
                                    else:
                                        magleffiles = [maglefpath + "/" + maglefname]

                                    if magleffiles == []:
                                        # Handle user ip/ files with a maglef/ view but
                                        # no LEF file.
                                        maglefpath = libpath.replace(
                                            "verilog", "maglef"
                                        )
                                        designpath = os.path.split(self.projectpath)[0]
                                        maglefpath = designpath + "/ip/" + maglefpath

                                        if not os.path.exists(
                                            maglefpath + "/" + maglefname
                                        ):
                                            magleffiles = glob.glob(
                                                maglefpath + "/*.mag"
                                            )
                                        else:
                                            magleffiles = [
                                                maglefpath + "/" + maglefname
                                            ]

                                    for magleffile in magleffiles:
                                        # Generate LEF file.  Since PDK and ip/ entries
                                        # are not writeable, write into the project mag/
                                        # directory.
                                        magpath = self.projectpath + "/mag"
                                        magname = os.path.split(magleffile)[1]
                                        magroot = os.path.splitext(magname)[0]
                                        leffile = magpath + "/" + magroot + ".lef"
                                        if not os.path.isfile(leffile):
                                            self.write_lef_file(magleffile, magpath)

                                        if leffile in ioleflibs:
                                            continue
                                        elif leffile in lefprocessed:
                                            continue
                                        else:
                                            lefprocessed.append(leffile)

                                        lefname = os.path.split(leffile)[1]

                                        newcoredefs = self.read_lef_macros(
                                            magpath, lefname, "celllib"
                                        )
                                        coredefs.extend(newcoredefs)
                                        corecells.extend(
                                            list(item["name"] for item in newcoredefs)
                                        )
                                        # LEF files generated on-the-fly are not needed
                                        # after they have been parsed.
                                        # os.remove(leffile)

                            # Check if all modules in modulelist are represented by
                            # corresponding LEF macros.  If not, then go looking for a LEF
                            # file in the mag/ or maglef/ directory.  Then, go looking for
                            # a .mag file in the mag/ or maglef/ directory, and build a
                            # LEF macro from it.

                            matching = list(
                                item["name"]
                                for item in coredefs
                                if item["name"] in modulelist
                            )
                            for module in modulelist:
                                if module not in matching:
                                    lefpath = self.projectpath + "/lef"
                                    magpath = self.projectpath + "/mag"
                                    maglefpath = self.projectpath + "/mag"
                                    lefname = libfile.replace(".v", ".lef")

                                    # If the verilog file root name is not the same as
                                    # the module name, then make a quick check for a
                                    # LEF file with the same root name as the verilog.
                                    # That indicates that the module does not exist in
                                    # the LEF file, probably because it is a primary
                                    # module that does not correspond to any layout.

                                    leffile = lefpath + "/" + lefname
                                    if os.path.exists(leffile):
                                        self.print(
                                            "Diagnostic: module "
                                            + module
                                            + " is not in "
                                            + leffile
                                            + " (probably a primary module)"
                                        )
                                        continue

                                    leffile = magpath + "/" + lefname
                                    istemp = False
                                    if not os.path.exists(leffile):
                                        magname = libfile.replace(".v", ".mag")
                                        magfile = magpath + "/" + magname
                                        if os.path.exists(magfile):
                                            self.print(
                                                "Diagnostic: Found a .mag file for "
                                                + module
                                                + " in "
                                                + magfile
                                            )
                                            self.write_lef_file(magfile)
                                            istemp = True
                                        else:
                                            magleffile = maglefpath + "/" + lefname
                                            if not os.path.exists(magleffile):
                                                self.print(
                                                    "Diagnostic: (module "
                                                    + module
                                                    + ") has no LEF file "
                                                    + leffile
                                                    + " or "
                                                    + magleffile
                                                )
                                                magleffile = maglefpath + "/" + magname
                                                if os.path.exists(magleffile):
                                                    self.print(
                                                        "Diagnostic: Found a .mag file for "
                                                        + module
                                                        + " in "
                                                        + magleffile
                                                    )
                                                    if os.access(maglefpath, os.W_OK):
                                                        self.write_lef_file(magleffile)
                                                        leffile = magleffile
                                                        istemp = True
                                                    else:
                                                        self.write_lef_file(
                                                            magleffile, magpath
                                                        )
                                                else:
                                                    self.print(
                                                        "Did not find a file " + magfile
                                                    )
                                                    # self.print('Warning: module ' + module + ' has no LEF or .mag views')
                                                    pass
                                            else:
                                                self.print(
                                                    "Diagnostic: Found a LEF file for "
                                                    + module
                                                    + " in "
                                                    + magleffile
                                                )
                                                leffile = magleffile
                                    else:
                                        self.print(
                                            "Diagnostic: Found a LEF file for "
                                            + module
                                            + " in "
                                            + leffile
                                        )

                                    if os.path.exists(leffile):
                                        if leffile in lefprocessed:
                                            continue
                                        else:
                                            lefprocessed.append(leffile)

                                        newcoredefs = self.read_lef_macros(
                                            magpath, lefname, "celllib"
                                        )
                                        # The LEF file generated on-the-fly is not needed
                                        # any more after parsing the macro(s).
                                        # if istemp:
                                        #     os.remove(leffile)
                                        coredefs.extend(newcoredefs)
                                        corecells.extend(
                                            list(item["name"] for item in newcoredefs)
                                        )
                                    else:
                                        # self.print('Failed to find a LEF view for module ' + module)
                                        pass

                    elif vlogparse[0] in verilogcells:
                        # Check for array of pads
                        bushigh = buslow = -1
                        if len(vlogparse) >= 3:
                            bmatch = busrex.match(vlogline)
                            if bmatch:
                                bushigh = int(bmatch.group(1))
                                buslow = int(bmatch.group(2))

                        for i in range(buslow, bushigh + 1):
                            newpad = {}
                            if i >= 0:
                                newpad["name"] = vlogparse[1] + "[" + str(i) + "]"
                            else:
                                newpad["name"] = vlogparse[1]
                            # hack
                            newpad["name"] = newpad["name"].replace("\\", "")
                            newpad["cell"] = vlogparse[0]
                            padcell = next(
                                item
                                for item in celldefs
                                if item["name"] == vlogparse[0]
                            )
                            newpad["iolib"] = padcell["iolib"]
                            newpad["class"] = padcell["class"]
                            newpad["subclass"] = padcell["subclass"]
                            newpad["width"] = padcell["width"]
                            newpad["height"] = padcell["height"]
                            newpadlist.append(newpad)

                    elif vlogparse[0] in corecells:
                        # Check for array of cells
                        bushigh = buslow = -1
                        if len(vlogparse) >= 3:
                            bmatch = busrex.match(vlogline)
                            if bmatch:
                                bushigh = int(bmatch.group(1))
                                buslow = int(bmatch.group(2))

                        for i in range(buslow, bushigh + 1):
                            newcorecell = {}
                            if i >= 0:
                                newcorecell["name"] = vlogparse[1] + "[" + str(i) + "]"
                            else:
                                newcorecell["name"] = vlogparse[1]
                            newcorecell["cell"] = vlogparse[0]
                            corecell = next(
                                item
                                for item in coredefs
                                if item["name"] == vlogparse[0]
                            )
                            newcorecell["celllib"] = corecell["celllib"]
                            newcorecell["class"] = corecell["class"]
                            newcorecell["subclass"] = corecell["subclass"]
                            newcorecell["width"] = corecell["width"]
                            newcorecell["height"] = corecell["height"]
                            corecelllist.append(newcorecell)

        self.print("")
        self.print("Source file information:")
        self.print("Source filename: " + vlogfile)
        self.print("Number of I/O libraries is " + str(len(ioleflibs)))
        self.print(
            "Number of library cells in I/O libraries used: " + str(len(verilogcells))
        )
        self.print("Number of core celldefs is " + str(len(coredefs)))
        self.print("")
        self.print("Number of I/O cells in design: " + str(len(newpadlist)))
        self.print("Number of core cells in design: " + str(len(corecelllist)))
        self.print("")

        # Save the results
        self.celldefs = celldefs
        self.coredefs = coredefs
        self.vlogpads = newpadlist
        self.corecells = corecelllist
        self.ioleflibs = ioleflibs

    # Check self.vlogpads, which was created during import (above) against
    # self.(N,S,W,E)pads, which was read from the DEF file (if there was one)
    # Also check self.corecells, which was created during import against
    # self.coregroup, which was read from the DEF file.

    def resolve(self):
        self.print("Resolve differences in verilog and LEF views.")

        samepads = []
        addedpads = []
        removedpads = []

        # (1) Create list of entries that are in both self.vlogpads and self.()pads
        # (2) Create list of entries that are in self.vlogpads but not in self.()pads

        allpads = (
            self.Npads
            + self.NEpad
            + self.Epads
            + self.SEpad
            + self.Spads
            + self.SWpad
            + self.Wpads
            + self.NWpad
        )

        for pad in self.vlogpads:
            newpadname = pad["name"]
            try:
                lpad = next(item for item in allpads if item["name"] == newpadname)
            except Exception:
                addedpads.append(pad)
            else:
                samepads.append(lpad)

        # (3) Create list of entries that are in allpads but not in self.vlogpads
        for pad in allpads:
            newpadname = pad["name"]
            try:
                lpad = next(
                    item for item in self.vlogpads if item["name"] == newpadname
                )
            except Exception:
                removedpads.append(pad)

        # Print results
        if len(addedpads) > 0:
            self.print("Added pads:")
            for pad in addedpads:
                self.print(pad["name"] + " (" + pad["cell"] + ")")

        if len(removedpads) > 0:
            plist = []
            nspacers = 0
            for pad in removedpads:
                if "subclass" in pad:
                    if pad["subclass"] != "SPACER":
                        plist.append(pad)
                    else:
                        nspacers += 1

            if nspacers > 0:
                self.print(str(nspacers) + " spacer cells ignored.")
            if len(plist) > 0:
                self.print("Removed pads:")
                for pad in removedpads:
                    self.print(pad["name"] + " (" + pad["cell"] + ")")

        if len(addedpads) + len(removedpads) == 0:
            self.print("Pad list has not changed.")

        # Remove all cells from the "removed" list, with comment

        allpads = [
            self.Npads,
            self.NEpad,
            self.Epads,
            self.SEpad,
            self.Spads,
            self.SWpad,
            self.Wpads,
            self.NWpad,
        ]

        for pad in removedpads:
            rname = pad["name"]
            for row in allpads:
                try:
                    rpad = next(item for item in row if item["name"] == rname)
                except Exception:
                    rpad = None
                else:
                    row.remove(rpad)

        # Now the verilog file has no placement information, so the old padlist
        # entries (if they exist) are preferred.  Add to these the new padlist
        # entries

        # First pass for unassigned pads:  Use of "CLASS ENDCAP" is preferred
        # for identifying corner pads.  Otherwise, if 'CORNER' or 'corner' is
        # in the pad name, then make sure there is one per row in the first
        # position.  This is not foolproof and depends on the cell library
        # using the text 'corner' in the name of the corner cell.  However,
        # if the ad hoc methods fail, the user can still manually move the
        # corner cells to the right place (to be done:  Identify if library
        # uses ENDCAP designation for corner cells up front;  don't go
        # looking for 'corner' text if the cells are easily identifiable by
        # LEF class).

        for pad in addedpads[:]:
            iscorner = False
            if "class" in pad and pad["class"] == "ENDCAP":
                iscorner = True
            elif "CORNER" in pad["cell"].upper():
                iscorner = True

            if iscorner:
                if self.NWpad == []:
                    self.NWpad.append(pad)
                    pad["o"] = "E"
                    addedpads.remove(pad)
                elif self.NEpad == []:
                    self.NEpad.append(pad)
                    pad["o"] = "S"
                    addedpads.remove(pad)
                elif self.SEpad == []:
                    self.SEpad.append(pad)
                    pad["o"] = "W"
                    addedpads.remove(pad)
                elif self.SWpad == []:
                    self.SWpad.append(pad)
                    pad["o"] = "N"
                    addedpads.remove(pad)

        numN = len(self.Npads)
        numS = len(self.Spads)
        numE = len(self.Epads)
        numW = len(self.Wpads)

        minnum = min(numN, numS, numE, numW)
        minnum = max(minnum, int(len(addedpads) / 4))

        # Add pads in clockwise order.  Note that S and E pads are defined counterclockwise
        for pad in addedpads:
            if numN < minnum:
                self.Npads.append(pad)
                numN += 1
                pad["o"] = "S"
                self.print("Adding pad " + pad["name"] + " to Npads")
            elif numE < minnum:
                self.Epads.insert(0, pad)
                numE += 1
                pad["o"] = "W"
                self.print("Adding pad " + pad["name"] + " to Epads")
            elif numS < minnum:
                self.Spads.insert(0, pad)
                numS += 1
                pad["o"] = "N"
                self.print("Adding pad " + pad["name"] + " to Spads")
            # elif numW < minnum:
            else:
                self.Wpads.append(pad)
                numW += 1
                pad["o"] = "E"
                self.print("Adding pad " + pad["name"] + " to Wpads")

            minnum = min(numN, numS, numE, numW)
            minnum = max(minnum, int(len(addedpads) / 4))

        # Make sure all pads have included information from the cell definition

        allpads = (
            self.Npads
            + self.NEpad
            + self.Epads
            + self.SEpad
            + self.Spads
            + self.SWpad
            + self.Wpads
            + self.NWpad
        )

        for pad in allpads:
            if "width" not in pad:
                try:
                    celldef = next(
                        item for item in celldefs if item["name"] == pad["cell"]
                    )
                except Exception:
                    self.print("Cell " + pad["cell"] + " not found!")
                else:
                    pad["width"] = celldef["width"]
                    pad["height"] = celldef["height"]
                    pad["class"] = celldef["class"]
                    pad["subclass"] = celldef["subclass"]

        # Now treat the core cells in the same way (resolve list parsed from verilog
        # against the list parsed from DEF)

        # self.print('Diagnostic: ')
        # self.print('self.corecells = ' + str(self.corecells))
        # self.print('self.coregroup = ' + str(self.coregroup))

        samecore = []
        addedcore = []
        removedcore = []

        # (1) Create list of entries that are in both self.corecells and self.coregroup
        # (2) Create list of entries that are in self.corecells but not in self.coregroup

        for cell in self.corecells:
            newcellname = cell["name"]
            try:
                lcore = next(
                    item for item in self.coregroup if item["name"] == newcellname
                )
            except Exception:
                addedcore.append(cell)
            else:
                samecore.append(lcore)

        # (3) Create list of entries that are in self.coregroup but not in self.corecells
        for cell in self.coregroup:
            newcellname = cell["name"]
            try:
                lcore = next(
                    item for item in self.corecells if item["name"] == newcellname
                )
            except Exception:
                removedcore.append(cell)

        # Print results
        if len(addedcore) > 0:
            self.print("Added core cells:")
            for cell in addedcore:
                self.print(cell["name"] + " (" + cell["cell"] + ")")

        if len(removedcore) > 0:
            clist = []
            for cell in removedcore:
                clist.append(cell)

            if len(clist) > 0:
                self.print("Removed core cells:")
                for cell in removedcore:
                    self.print(cell["name"] + " (" + cell["cell"] + ")")

        if len(addedcore) + len(removedcore) == 0:
            self.print("Core cell list has not changed.")

        # Remove all cells from the "removed" list

        coregroup = self.coregroup
        for cell in removedcore:
            rname = cell["name"]
            try:
                rcell = next(item for item in coregroup if item["name"] == rname)
            except Exception:
                rcell = None
            else:
                coregroup.remove(rcell)

        # Add all cells from the "added" list to coregroup

        for cell in addedcore:
            rname = cell["name"]
            try:
                rcell = next(item for item in coregroup if item["name"] == rname)
            except Exception:
                coregroup.append(cell)
                if not "o" in cell:
                    cell["o"] = "N"
                if not "x" in cell:
                    if len(self.Wpads) > 0:
                        pad = self.Wpads[0]
                        padx = pad["x"] if "x" in pad else 0
                        cell["x"] = padx + pad["height"] + self.margin
                    else:
                        cell["x"] = self.margin
                if not "y" in cell:
                    if len(self.Spads) > 0:
                        pad = self.Spads[0]
                        pady = pad["y"] if "y" in pad else 0
                        cell["y"] = pady + pad["height"] + self.margin
                    else:
                        cell["y"] = self.margin
            else:
                rcell = None

        # Make sure all core cells have included information from the cell definition

        for cell in coregroup:
            if "width" not in cell:
                try:
                    coredef = next(
                        item for item in coredefs if item["name"] == cell["cell"]
                    )
                except Exception:
                    self.print("Cell " + cell["cell"] + " not found!")
                else:
                    cell["width"] = coredef["width"]
                    cell["height"] = coredef["height"]
                    cell["class"] = coredef["class"]
                    cell["subclass"] = coredef["subclass"]

    # Generate a new padframe by writing the configuration file, running
    # padring, reading back the DEF file, and (re)poplulating the workspace

    def generate(self, level):
        self.print("Generate legal padframe using padring")

        # Write out the configuration file
        self.writeconfig()
        # Run the padring app
        self.runpadring()
        # Rotate pads in the output if pad orientations are different from
        # padring's expectations
        self.rotate_pads_in_def()
        # Read the placement information back from the generated DEF file
        self.readplacement()
        # Resolve differences (e.g., remove spacers)
        self.resolve()
        # Recreate and draw the padframe view on the canvas
        self.populate(level + 1)
        self.frame_configure(None)

    # Write a new configuration file

    def writeconfig(self):
        mag_path = self.projectpath + "/mag"

        self.print("Writing padring configuration file.")

        # Determine cell width and height from pad sizes.
        # NOTE:  This compresses the chip to the minimum dimensions
        # allowed by the arrangement of pads.  Use a "core" block to
        # force the area larger than minimum (not yet implemented)

        topwidth = 0
        for pad in self.Npads:
            if "width" not in pad:
                self.print("No width: pad = " + str(pad))
            topwidth += pad["width"]

        # Add in the corner cells
        if self.NWpad != []:
            topwidth += self.NWpad[0]["height"]
        if self.NEpad != []:
            topwidth += self.NEpad[0]["width"]

        botwidth = 0
        for pad in self.Spads:
            botwidth += pad["width"]

        # Add in the corner cells
        if self.SWpad != []:
            botwidth += self.SWpad[0]["width"]
        if self.SEpad != []:
            botwidth += self.SEpad[0]["height"]

        width = max(botwidth, topwidth)

        # if width < self.urx - self.llx:
        #     width = self.urx - self.llx

        leftheight = 0
        for pad in self.Wpads:
            leftheight += pad["width"]

        # Add in the corner cells
        if self.NWpad != []:
            leftheight += self.NWpad[0]["height"]
        if self.SWpad != []:
            leftheight += self.SWpad[0]["width"]

        rightheight = 0
        for pad in self.Epads:
            rightheight += pad["width"]

        # Add in the corner cells
        if self.NEpad != []:
            rightheight += self.NEpad[0]["width"]
        if self.SEpad != []:
            rightheight += self.SEpad[0]["height"]

        height = max(leftheight, rightheight)

        # Check the dimensions of the core cells.  If they exceed the available
        # padframe area, then expand the padframe to accomodate the core.

        corellx = coreurx = (self.llx + self.urx) / 2
        corelly = coreury = (self.lly + self.ury) / 2

        for corecell in self.coregroup:
            corient = corecell["o"]
            if "S" in corient or "N" in corient:
                cwidth = corecell["width"]
                cheight = corecell["height"]
            else:
                cwidth = corecell["height"]
                cheight = corecell["width"]

            if corecell["x"] < corellx:
                corellx = corecell["x"]
            if corecell["x"] + cwidth > coreurx:
                coreurx = corecell["x"] + cwidth
            if corecell["y"] < corelly:
                corelly = corecell["y"]
            if corecell["y"] + cheight > coreury:
                coreury = corecell["y"] + cheight

        coreheight = coreury - corelly
        corewidth = coreurx - corellx

        # Ignoring the possibility of overlaps with nonstandard-sized pads,
        # assuming that the user has visually separated them.  Only check
        # the core bounds against the standard padframe inside edge.

        if self.SWpad != [] and self.SEpad != []:
            if corewidth > width - self.SWpad[0]["width"] - self.SEpad[0]["width"]:
                width = corewidth + self.SWpad[0]["width"] + self.SEpad[0]["width"]
        if self.NWpad != [] and self.SWpad != []:
            if coreheight > height - self.NWpad[0]["height"] - self.SWpad[0]["height"]:
                height = coreheight + self.NWpad[0]["height"] + self.SWpad[0]["height"]

        # Core cells are given a margin of self.margin from the pad inside edge, so the
        # core area passed to the padring app is 2 * self.margin larger than the
        # measured size of the core area.
        width += 2 * self.margin
        height += 2 * self.margin

        # SCALE UP
        # width *= 1.4
        # height *= 1.4

        if self.keep_cfg == False or not os.path.exists(mag_path + "/padframe.cfg"):

            if os.path.exists(mag_path + "/padframe.cfg"):
                # Copy the previous padframe.cfg file to a backup.  In case something
                # goes badly wrong, this should be the only file overwritten, and can
                # be recovered from the backup.
                shutil.copy(mag_path + "/padframe.cfg", mag_path + "/padframe.cfg.bak")

            with open(mag_path + "/padframe.cfg", "w") as ofile:
                print(
                    "AREA " + str(int(width)) + " " + str(int(height)) + " ;",
                    file=ofile,
                )
                print("", file=ofile)
                for pad in self.NEpad:
                    print(
                        "CORNER " + pad["name"] + " SW " + pad["cell"] + " ;",
                        file=ofile,
                    )
                for pad in self.SEpad:
                    print(
                        "CORNER " + pad["name"] + " NW " + pad["cell"] + " ;",
                        file=ofile,
                    )
                for pad in self.SWpad:
                    print(
                        "CORNER " + pad["name"] + " NE " + pad["cell"] + " ;",
                        file=ofile,
                    )
                for pad in self.NWpad:
                    print(
                        "CORNER " + pad["name"] + " SE " + pad["cell"] + " ;",
                        file=ofile,
                    )
                for pad in self.Npads:
                    flip = "F " if "F" in pad["o"] else ""
                    print(
                        "PAD " + pad["name"] + " N " + flip + pad["cell"] + " ;",
                        file=ofile,
                    )
                for pad in self.Epads:
                    flip = "F " if "F" in pad["o"] else ""
                    print(
                        "PAD " + pad["name"] + " E " + flip + pad["cell"] + " ;",
                        file=ofile,
                    )
                for pad in self.Spads:
                    flip = "F " if "F" in pad["o"] else ""
                    print(
                        "PAD " + pad["name"] + " S " + flip + pad["cell"] + " ;",
                        file=ofile,
                    )
                for pad in self.Wpads:
                    flip = "F " if "F" in pad["o"] else ""
                    print(
                        "PAD " + pad["name"] + " W " + flip + pad["cell"] + " ;",
                        file=ofile,
                    )

    # Run the padring app.

    def runpadring(self):
        self.print("Running padring")

        mag_path = self.projectpath + "/mag"
        if self.padring_path:
            padringopts = [self.padring_path]
        else:
            padringopts = ["padring"]

        # Diagnostic
        # self.print('Used libraries (self.ioleflibs) = ' + str(self.ioleflibs))

        for iolib in self.ioleflibs:
            padringopts.append("-L")
            padringopts.append(iolib)
        padringopts.append("--def")
        padringopts.append("padframe.def")
        padringopts.append("padframe.cfg")

        self.print("Running " + str(padringopts))

        p = subprocess.Popen(
            padringopts, stdout=subprocess.PIPE, stderr=subprocess.PIPE, cwd=mag_path
        )
        self.watch(p)

    # Read placement information from the DEF file generated by padring.

    def readplacement(self, precheck=False):
        self.print("Reading placement information from DEF file")

        mag_path = self.projectpath + "/mag"
        if not os.path.isfile(mag_path + "/padframe.def"):
            if not precheck:
                self.print("No file padframe.def:  pad frame was not generated.")
            return False

        # Very simple DEF file parsing.  The placement DEF only contains a
        # COMPONENTS section.  Certain assumptions are made about the syntax
        # that depends on the way 'padring' writes its output.  This is not
        # a rigorous DEF parser!

        units = 1000
        in_components = False
        Npadlist = []
        Spadlist = []
        Epadlist = []
        Wpadlist = []
        NEpad = []
        NWpad = []
        SEpad = []
        SWpad = []
        coregroup = []

        # Reset bounds
        self.llx = self.lly = self.urx = self.ury = 0
        corners = 0

        with open(mag_path + "/padframe.def", "r") as ifile:
            deflines = ifile.read().splitlines()
            for line in deflines:
                if "UNITS DISTANCE MICRONS" in line:
                    units = line.split()[3]
                elif in_components:
                    lparse = line.split()
                    if lparse[0] == "-":
                        instname = lparse[1]
                        cellname = lparse[2]

                    elif lparse[0] == "+":
                        if lparse[1] == "FIXED":
                            placex = lparse[3]
                            placey = lparse[4]
                            placeo = lparse[6]

                            newpad = {}
                            newpad["name"] = instname
                            newpad["cell"] = cellname

                            try:
                                celldef = next(
                                    item
                                    for item in self.celldefs
                                    if item["name"] == cellname
                                )
                            except Exception:
                                celldef = None
                            else:
                                newpad["iolib"] = celldef["iolib"]
                                newpad["width"] = celldef["width"]
                                newpad["height"] = celldef["height"]
                                newpad["class"] = celldef["class"]
                                newpad["subclass"] = celldef["subclass"]

                            newpad["x"] = float(placex) / float(units)
                            newpad["y"] = float(placey) / float(units)
                            newpad["o"] = placeo

                            # Adjust bounds
                            if celldef:
                                if newpad["x"] < self.llx:
                                    self.llx = newpad["x"]
                                if newpad["y"] < self.lly:
                                    self.lly = newpad["y"]

                                if newpad["o"] == "N" or newpad["o"] == "S":
                                    padurx = newpad["x"] + celldef["width"]
                                    padury = newpad["y"] + celldef["height"]
                                else:
                                    padurx = newpad["x"] + celldef["height"]
                                    padury = newpad["y"] + celldef["width"]

                                if padurx > self.urx:
                                    self.urx = padurx
                                if padury > self.ury:
                                    self.ury = padury

                            # First four entries in the DEF file are corners
                            # padring puts the lower left corner at zero, so
                            # use the zero coordinates to determine which pads
                            # are which.  Note that padring assumes the corner
                            # pad is drawn in the SW corner position!

                            if corners < 4:
                                if newpad["x"] == 0 and newpad["y"] == 0:
                                    SWpad.append(newpad)
                                elif newpad["x"] == 0:
                                    NWpad.append(newpad)
                                elif newpad["y"] == 0:
                                    SEpad.append(newpad)
                                else:
                                    NEpad.append(newpad)
                                corners += 1
                            else:
                                # Place according to orientation.  If orientation
                                # is not standard, be sure to make it standard!
                                placeo = self.rotate_orientation(placeo)
                                if placeo == "N":
                                    Spadlist.append(newpad)
                                elif placeo == "E":
                                    Wpadlist.append(newpad)
                                elif placeo == "S":
                                    Npadlist.append(newpad)
                                else:
                                    Epadlist.append(newpad)

                    elif "END COMPONENTS" in line:
                        in_components = False
                elif "COMPONENTS" in line:
                    in_components = True

            self.Npads = Npadlist
            self.Wpads = Wpadlist
            self.Spads = Spadlist
            self.Epads = Epadlist

            self.NWpad = NWpad
            self.NEpad = NEpad
            self.SWpad = SWpad
            self.SEpad = SEpad

        # The padframe has its own DEF file from the padring app, but the core
        # does not.  The core needs to be floorplanned in a very similar manner.
        # This will be done by searching for a DEF file of the project top-level
        # layout.  If none exists, it is created by generating it from the layout.
        # If the top-level layout does not exist, then all core cells are placed
        # at the origin, and the origin placed at the padframe inside corner.

        mag_path = self.projectpath + "/mag"
        if not os.path.isfile(mag_path + "/" + self.project + ".def"):
            if os.path.isfile(mag_path + "/" + self.project + ".mag"):

                # Create a DEF file from the layout
                with open(mag_path + "/pfg_write_def.tcl", "w") as ofile:
                    print("drc off", file=ofile)
                    print("box 0 0 0 0", file=ofile)
                    print("load " + self.project, file=ofile)
                    print("def write", file=ofile)
                    print("quit", file=ofile)

                magicexec = self.magic_path if self.magic_path else "magic"
                mproc = subprocess.Popen(
                    [magicexec, "-dnull", "-noconsole", "pfg_write_def.tcl"],
                    stdin=subprocess.PIPE,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    cwd=mag_path,
                    universal_newlines=True,
                )

                self.watch(mproc)
                os.remove(mag_path + "/pfg_write_def.tcl")

            elif not os.path.isfile(mag_path + "/core.def"):

                # With no other information available, copy the corecells
                # (from the verilog file) into the coregroup list.
                # Position all core cells starting at the padframe top left
                # inside corner, and arranging in rows without overlapping.
                # Note that no attempt is made to organize the cells or
                # otherwise produce an efficient layout.  Any dimension larger
                # than the current padframe overruns to the right or bottom.

                if self.SWpad != []:
                    corellx = SWpad[0]["x"] + SWpad[0]["width"] + self.margin
                    corelly = SWpad[0]["y"] + SWpad[0]["height"] + self.margin
                else:
                    corellx = Wpadlist[0]["x"] + Wpadlist[0]["height"] + self.margin
                    corelly = Spadlist[0]["x"] + Spadlist[0]["height"] + self.margin
                if self.NEpad != []:
                    coreurx = NEpad[0]["x"] - self.margin
                    coreury = NEpad[0]["y"] - self.margin
                else:
                    coreurx = Epadlist[0]["x"] - self.margin
                    coreury = Npadlist[0]["x"] - self.margin
                locllx = corellx
                testllx = corellx
                loclly = corelly
                testlly = corelly
                nextlly = corelly

                for cell in self.corecells:

                    testllx = locllx + cell["width"]
                    if testllx > coreurx:
                        locllx = corellx
                        corelly = nextlly
                        loclly = nextlly

                    newcore = cell
                    newcore["x"] = locllx
                    newcore["y"] = loclly
                    newcore["o"] = "N"

                    locllx += cell["width"] + self.margin

                    testlly = corelly + cell["height"] + self.margin
                    if testlly > nextlly:
                        nextlly = testlly

                    coregroup.append(newcore)

                self.coregroup = coregroup

        if os.path.isfile(mag_path + "/" + self.project + ".def"):
            # Read the top-level DEF, and use it to position the core cells.
            self.print("Reading the top-level cell DEF for core cell placement.")

            units = 1000
            in_components = False
            with open(mag_path + "/" + self.project + ".def", "r") as ifile:
                deflines = ifile.read().splitlines()
                for line in deflines:
                    if "UNITS DISTANCE MICRONS" in line:
                        units = line.split()[3]
                    elif in_components:
                        lparse = line.split()
                        if lparse[0] == "-":
                            instname = lparse[1]
                            # NOTE: Magic should not drop the entire path to the
                            # cell for the cellname;  this needs to be fixed!  To
                            # work around it, remove any path components.
                            cellpath = lparse[2]
                            cellname = os.path.split(cellpath)[1]

                        elif lparse[0] == "+":
                            if lparse[1] == "PLACED":
                                placex = lparse[3]
                                placey = lparse[4]
                                placeo = lparse[6]

                                newcore = {}
                                newcore["name"] = instname
                                newcore["cell"] = cellname

                                try:
                                    celldef = next(
                                        item
                                        for item in self.coredefs
                                        if item["name"] == cellname
                                    )
                                except Exception:
                                    celldef = None
                                else:
                                    newcore["celllib"] = celldef["celllib"]
                                    newcore["width"] = celldef["width"]
                                    newcore["height"] = celldef["height"]
                                    newcore["class"] = celldef["class"]
                                    newcore["subclass"] = celldef["subclass"]

                                newcore["x"] = float(placex) / float(units)
                                newcore["y"] = float(placey) / float(units)
                                newcore["o"] = placeo
                                coregroup.append(newcore)

                        elif "END COMPONENTS" in line:
                            in_components = False
                    elif "COMPONENTS" in line:
                        in_components = True

            self.coregroup = coregroup

        elif os.path.isfile(mag_path + "/core.def"):
            # No DEF or .mag file, so fallback position is the last core.def
            # file generated by this script.
            self.read_core_def(precheck=precheck)

        return True

    # Read placement information from the "padframe.def" file and rotate
    # all cells according to self.pad_rotation.  This accounts for the
    # problem that the default orientation of pads is arbitrarily defined
    # by the foundry, while padring assumes that the corner pad is drawn
    # in the lower-left position and other pads are drawn with the pad at
    # the bottom and the buses at the top.

    def rotate_pads_in_def(self):
        if self.pad_rotation == 0:
            return

        self.print("Rotating pads in padframe DEF file.")
        mag_path = self.projectpath + "/mag"

        if not os.path.isfile(mag_path + "/padframe.def"):
            self.print("No file padframe.def:  Cannot modify pad rotations.")
            return

        deflines = []
        with open(mag_path + "/padframe.def", "r") as ifile:
            deflines = ifile.read().splitlines()

        outlines = []
        in_components = False
        for line in deflines:
            if in_components:
                lparse = line.split()
                if lparse[0] == "+":
                    if lparse[1] == "PLACED":
                        lparse[1] = "FIXED"
                        neworient = lparse[6]
                        lparse[6] = neworient
                        line = " ".join(lparse)

                elif "END COMPONENTS" in line:
                    in_components = False
            elif "COMPONENTS" in line:
                in_components = True
            outlines.append(line)

        with open(mag_path + "/padframe.def", "w") as ofile:
            for line in outlines:
                print(line, file=ofile)

    # Read placement information from the DEF file for the core (created by
    # a previous run of this script)

    def read_core_def(self, precheck=False):
        self.print("Reading placement information from core DEF file.")

        mag_path = self.projectpath + "/mag"

        if not os.path.isfile(mag_path + "/core.def"):
            if not precheck:
                self.print("No file core.def:  core placement was not generated.")
            return False

        # Very simple DEF file parsing, similar to the padframe.def reading
        # routine above.

        units = 1000
        in_components = False

        coregroup = []

        with open(mag_path + "/core.def", "r") as ifile:
            deflines = ifile.read().splitlines()
            for line in deflines:
                if "UNITS DISTANCE MICRONS" in line:
                    units = line.split()[3]
                elif in_components:
                    lparse = line.split()
                    if lparse[0] == "-":
                        instname = lparse[1]
                        cellname = lparse[2]

                    elif lparse[0] == "+":
                        if lparse[1] == "PLACED":
                            placex = lparse[3]
                            placey = lparse[4]
                            placeo = lparse[6]

                            newcore = {}
                            newcore["name"] = instname
                            newcore["cell"] = cellname

                            try:
                                celldef = next(
                                    item
                                    for item in self.coredefs
                                    if item["name"] == cellname
                                )
                            except Exception:
                                celldef = None
                            else:
                                newcore["celllib"] = celldef["celllib"]
                                newcore["width"] = celldef["width"]
                                newcore["height"] = celldef["height"]
                                newcore["class"] = celldef["class"]
                                newcore["subclass"] = celldef["subclass"]

                            newcore["x"] = float(placex) / float(units)
                            newcore["y"] = float(placey) / float(units)
                            newcore["o"] = placeo
                            coregroup.append(newcore)

                    elif "END COMPONENTS" in line:
                        in_components = False
                elif "COMPONENTS" in line:
                    in_components = True

            self.coregroup = coregroup

        return True

    # Save the layout to a Magic database file (to be completed)

    def save(self):
        self.print("Saving results in a magic layout database.")

        # Generate a list of (unique) LEF libraries for all padframe and core cells
        leflist = []
        for pad in self.celldefs:
            if pad["iolib"] not in leflist:
                leflist.append(pad["iolib"])

        for core in self.coredefs:
            if core["celllib"] not in leflist:
                leflist.append(core["celllib"])

        # Run magic, and generate the padframe with a series of commands
        mag_path = self.projectpath + "/mag"

        with open(mag_path + "/pfg_write_mag.tcl", "w") as ofile:
            print("drc off", file=ofile)
            print("box 0 0 0 0", file=ofile)
            for leffile in leflist:
                print("lef read " + leffile, file=ofile)
            print("def read padframe", file=ofile)
            print("select top cell", file=ofile)
            print("select area", file=ofile)
            print("select save padframe", file=ofile)
            print("delete", file=ofile)
            print("def read core", file=ofile)
            print("getcell padframe", file=ofile)
            print("save " + self.project, file=ofile)
            print("writeall force " + self.project, file=ofile)
            print("quit", file=ofile)

        magicexec = self.magic_path if self.magic_path else "magic"
        mproc = subprocess.Popen(
            [magicexec, "-dnull", "-noconsole", "pfg_write_mag.tcl"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            cwd=mag_path,
            universal_newlines=True,
        )
        self.watch(mproc)
        os.remove(mag_path + "/pfg_write_mag.tcl")
        self.print("Done writing layout " + self.project + ".mag")

        # Write the core DEF file if it does not exist yet.
        if not os.path.isfile(mag_path + "/core.def"):
            self.write_core_def()


if __name__ == "__main__":
    faulthandler.register(signal.SIGUSR2)
    options = []
    arguments = []
    for item in sys.argv[1:]:
        if item.find("-", 0) == 0:
            options.append(item)
        else:
            arguments.append(item)

    if "-help" in options:
        print(sys.argv[0] + " [options]")
        print("")
        print("options:")
        print("   -noc    Print output to terminal, not the gui window")
        print("   -nog    No graphics, run in batch mode")
        print("   -cfg    Use existing padframe.cfg, do not regenerate")
        print("   -padring-path=<path>	path to padring executable")
        print("   -magic-path=<path>	path to magic executable")
        print("   -tech-path=<path>	path to tech root folder")
        print("   -project-path=<path>	path to project root folder")
        print("   -help   Print this usage information")
        print("")
        sys.exit(0)

    root = tkinter.Tk()
    do_gui = False if ("-nog" in options or "-nogui" in options) else True
    app = SoCFloorplanner(root, do_gui)

    # Allow option -noc to bypass the text-to-console redirection, so crash
    # information doesn't disappear with the app.

    app.use_console = False if ("-noc" in options or "-noconsole" in options) else True
    if do_gui == False:
        app.use_console = False

    # efabless format can be specified on the command line, but note that it
    # is otherwise auto-detected by checking for .config vs. .ef-config in
    # the project space.

    app.ef_format = True if "-ef_format" in options else False
    app.keep_cfg = True if "-cfg" in options else False

    app.padring_path = None
    app.magic_path = None
    app.techpath = None
    app.projectpath = None

    for option in options:
        if option.split("=")[0] == "-padring-path":
            app.padring_path = option.split("=")[1]
        elif option.split("=")[0] == "-magic-path":
            app.magic_path = option.split("=")[1]
        elif option.split("=")[0] == "-tech-path":
            app.techpath = option.split("=")[1]
        elif option.split("=")[0] == "-project-path":
            app.projectpath = option.split("=")[1]
            app.projectpath = (
                app.projectpath[:-1] if app.projectpath[-1] == "/" else app.projectpath
            )

    app.text_to_console()
    app.init_padframe()
    if app.do_gui:
        root.mainloop()
    else:
        # Run 'save' in non-GUI mode
        app.save()
        sys.exit(0)
