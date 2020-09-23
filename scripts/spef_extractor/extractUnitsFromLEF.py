# -*- coding: utf-8 -*-
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
    