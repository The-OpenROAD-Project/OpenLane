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
