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
#--------------------------------------------------------
"""
  consoletext --- extends tkinter class Text
  with stdout and stderr redirection.
"""
#--------------------------------------------------------
# Written by Tim Edwards
# efabless, inc.
# September 11, 2016
# Version 0.1
#--------------------------------------------------------

import sys
import tkinter

class ConsoleText(tkinter.Text):
    linelimit = 500
    class IORedirector(object):
        '''A general class for redirecting I/O to this Text widget.'''
        def __init__(self,text_area):
            self.text_area = text_area

    class StdoutRedirector(IORedirector):
        '''A class for redirecting stdout to this Text widget.'''
        def write(self,str):
            self.text_area.write(str,False)

    class StderrRedirector(IORedirector):
        '''A class for redirecting stderr to this Text widget.'''
        def write(self,str):
            self.text_area.write(str,True)

    def __init__(self, master=None, cnf={}, **kw):
        '''See the __init__ for Tkinter.Text.'''

        tkinter.Text.__init__(self, master, cnf, **kw)

        self.tag_configure('stdout',background='white',foreground='black')
        self.tag_configure('stderr',background='white',foreground='red')
        # None of these works!  Cannot change selected text background!
        self.config(selectbackground='blue', selectforeground='white')
        self.tag_configure('sel',background='blue',foreground='white')

    def write(self, val, is_stderr=False):
        lines = int(self.index('end-1c').split('.')[0])
        if lines > self.linelimit:
            self.delete('1.0', str(lines - self.linelimit) + '.0')
        self.insert('end',val,'stderr' if is_stderr else 'stdout')
        self.see('end')

    def limit(self, val):
        self.linelimit = val
