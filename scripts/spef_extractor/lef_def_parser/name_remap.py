# MIT License
# 
# Copyright (c) 2020 Tri Minh Cao
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

from def_parser import *
from lef_parser import *




lef_parser = LefParser("def_lef_files/osu035.lef")
lef_parser.parse()

def_parser = DefParser("def_lef_files/uart.def")
def_parser.parse()

#List that contains old name, new name

def remap_names():
    name_counter = 0
    map_of_names = []
    for key in def_parser.nets.net_dict:
        new_name = []
        new_name.append(def_parser.nets.net_dict[key].name)
        def_parser.nets.net_dict[key].name = "*" + str(name_counter)
        new_name.append(def_parser.nets.net_dict[key].name)
        name_counter += 1
        map_of_names.append(new_name)
    return(map_of_names)
    

map_of_names = remap_names()
    
print(map_of_names)
