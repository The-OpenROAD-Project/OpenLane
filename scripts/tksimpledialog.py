#!/ef/efabless/opengalaxy/venv/bin/python3
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
# Dialog class for tkinter

import os
import tkinter
from tkinter import ttk

class Dialog(tkinter.Toplevel):

    def __init__(self, parent, message = None, title = None, seed = None, border = 'blue', **kwargs):

        tkinter.Toplevel.__init__(self, parent)
        self.transient(parent)

        if title:
            self.title(title)

        self.configure(background=border, padx=2, pady=2)
        self.obox = ttk.Frame(self)
        self.obox.pack(side = 'left', fill = 'both', expand = 'true')

        self.parent = parent
        self.result = None
        body = ttk.Frame(self.obox)
        self.initial_focus = self.body(body, message, seed, **kwargs)
        body.pack(padx = 5, pady = 5)
        self.buttonbox()
        self.grab_set()

        if not self.initial_focus:
            self.initial_focus = self

        self.protocol("WM_DELETE_WINDOW", self.cancel)
        self.geometry("+%d+%d" % (parent.winfo_rootx() + 50,
                                  parent.winfo_rooty() + 50))

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

        self.okb = ttk.Button(box, text="OK", width=10, command=self.ok, default='active')
        self.okb.pack(side='left', padx=5, pady=5)
        w = ttk.Button(box, text="Cancel", width=10, command=self.cancel)
        w.pack(side='left', padx=5, pady=5)

        self.bind("<Return>", self.ok)
        self.bind("<Escape>", self.cancel)
        box.pack(fill='x', expand='true')

    # Standard button semantics

    def ok(self, event=None):

        if not self.validate():
            self.initial_focus.focus_set() # put focus back
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
        return 1 # Override this

    def apply(self):
        return None # Override this
