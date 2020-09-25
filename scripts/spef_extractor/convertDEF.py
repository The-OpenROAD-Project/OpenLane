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

def covnertToDef57(fileName):
    reachedNets = False
    reading = open(fileName, "r+")
    writing = open(fileName[:-4] + '_new.def', 'w+')
    
    for line in reading:
        splitted_line = line.split()
        if(len(splitted_line) > 0):
            if(splitted_line[0] == 'NETS'):
                reachedNets = True
            if(reachedNets == True):
                if(len(splitted_line) > 0):
                    if(splitted_line[0] == '-'):
                        line1 = splitted_line[0] + " " + splitted_line[1] + '\n'
                        writing.write(line1)
                        
                        line2 = ""
                        for i in range(len(splitted_line)):
                            if(i > 1):
                                line2 += splitted_line[i] + " "
                                
                        writing.write(line2 + '\n')
                    else:
                        writing.write(line)  
                
            else:
                writing.write(line)
                
            