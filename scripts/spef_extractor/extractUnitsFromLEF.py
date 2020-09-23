# -*- coding: utf-8 -*-
# MIT License
# 
# Copyright (c) 2019 HanyMoussa
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
"""
Created on Fri Jul 31 16:08:56 2020

@author: Ramez Moussa
"""
lef_file_name = 'sample-designs/cpu6502/merged_unpadded.lef'


def extractLefUnits(lef_file_name):
    
    unitsDict = {}
    f = open(lef_file_name, "r+")
    while(1):
        line = f.readline()
        data = line.split()
        if(len(data) > 0):
            if(data[0] == "UNITS"):
                extractUnits(f, unitsDict)
                f.close()
                return unitsDict
  
    
def extractUnits(f, unitsDict):
    # the maximum number of units defined in LEF is 8
    for i in range(10):
        line = f.readline()
        data = line.split()
        if(len(data) > 0):
            if(data[0] != "END"):
                unitsDict[data[0]] = data[1]
            else:
                return unitsDict
    