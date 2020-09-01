import json
import argparse
import os

parser = argparse.ArgumentParser(
        description="top module generation helper to show the optional fields of a given pad")

parser.add_argument('--padType', '-t', action='store', required=False,
                help="The pad type to show the mapping for")

parser.add_argument('--showPadTypes', '-s', action='store_true', default=False,
                help="A flag to list all the available pad types in a given library.")

parser.add_argument('--padsLibs', '-p', action='store', required=True,
                help="The pad libraries json description")

parser.add_argument('--padsLibName', '-n', action='store', required=True,
                help="The name of the pad library to use from the given padsLibs")


args = parser.parse_args()
padType = args.padType
padsLibs = args.padsLibs
showPadTypes = args.showPadTypes
padsLibName = args.padsLibName



if padType is None and showPadTypes == False:
        print("Please either specify a pad type to show the mapping for, or use the showPadTypes flag to list all possible types in the library")
else:
        #description of the libraries parsed into a dict
        if not os.path.exists(padsLibs): raise IOError("file not found: " + padsLibs)
        padsLibsJSONOpener = open(padsLibs, 'r')
        padsLibs_json = json.load(padsLibsJSONOpener)
        padsLibsJSONOpener.close()

        #Finding the used pads library
        padsLib_json = dict()
        for padsLib in padsLibs_json:
                if padsLib["library_name"] == padsLibName:
                        padsLib_json = padsLib
                        break
        
        if len(padsLib_json) == 0:
                raise Exception("Used Pad Lib is not found in the given Pad Libraries JSON") 

        if showPadTypes:
                for pad in padsLib_json["pads"]:
                        if "mapping" in pad:
                                print(pad["type"])
        if padType is not None:
                for pad in padsLib_json["pads"]:
                        if padType == pad["type"]:
                                print("print mapping for pad", padType)
                                print("key : mapped_to")
                                for mapping in pad["mapping"].keys():
                                        print(mapping, " : ", pad["mapping"][mapping])
                                break
