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

import json
import argparse
import copy
import re
import os
from pyverilog.vparser.parser import parse

# import StringIO
try:
    from StringIO import StringIO
except ImportError:
    from io import StringIO
parser = argparse.ArgumentParser(
    description="top module generation for a given (core design, pads library) pair"
)


parser.add_argument(
    "--design",
    "-d",
    action="store",
    required=True,
    help="The json description of the design",
)

parser.add_argument(
    "--padsLibs",
    "-p",
    action="store",
    required=True,
    help="The pad libraries json description",
)

parser.add_argument(
    "--verilog",
    "-v",
    action="store",
    required=True,
    help="The input verilog file containing the core module header definition",
)

parser.add_argument(
    "--output",
    "-o",
    action="store",
    required=True,
    help="The verilog file to output to",
)


args = parser.parse_args()
design = args.design
padsLibs = args.padsLibs
output = args.output
verilog_file = args.verilog

# description of the design parsed into a dict
if not os.path.exists(design):
    raise IOError("file not found: " + design)
designJSONOpener = open(design, "r")
design_json_complete = json.load(designJSONOpener)
designJSONOpener.close()


# description of the libraries parsed into a dict
if not os.path.exists(padsLibs):
    raise IOError("file not found: " + padsLibs)
padsLibsJSONOpener = open(padsLibs, "r")
padsLibs_json = json.load(padsLibsJSONOpener)
padsLibsJSONOpener.close()

# Finding the used pads library
padsLib_json = dict()
for padsLib in padsLibs_json:
    if padsLib["library_name"] == design_json_complete["pads_library"]:
        padsLib_json = padsLib
        break

if len(padsLib_json) == 0:
    raise Exception("Used Pad Lib is not found in the given Pad Libraries JSON")

# extracting the core module needed pads
design_json = design_json_complete["module"]

# Necessary intermediate containers
written_macros = list()
wiresToDeclare = dict()
headerSignalsToDeclare = dict()

# Segments of the final written verilog code
topModuleHeader = "module " + design_json_complete["design_name"] + "(\n"
topModuleDeclarations = ""
topModuleDefines = (
    "`timescale 1 ns / 1 ps\n\n`define USE_PG_PIN\n`define functional\n\n"
)
topModuleIncludes = ""
topModuleBody = ""
topModuleMacros = ""
designDeclaration = ""
topModuleExtra = ""
padFrameModule = ""
padFrameHeader = "chip_io padframe(\n"
padFrameHeaderDefinition = "module chip_io(\n"
padFrameWires = ""


# parsePads is responsible for parsing the pads except for power/corner pads
def parsePads():
    global topModuleHeader
    for user_pad in design_json["pads"]:
        # find pad direction
        padType = user_pad["type"]

        padUsed = dict()

        # extract pad
        for library_pad in padsLib["pads"]:
            if library_pad["type"] == padType:
                padUsed = library_pad
                break
        if len(padUsed) == 0:
            raise Exception("Used Pad is not of a defined type")
        writePad(padUsed, user_pad)
    topModuleHeader = topModuleHeader[:-2] + ");\n"


# writePad is responsible for adding a non-power/non-corner pad to the output verilog
def writePad(padUsed, user_info):
    global topModuleHeader
    global padFrameModule
    global padFrameHeaderDefinition
    global padFrameHeader

    v = user_info["size"] > 1
    macro_name = ""
    if v:
        macro_name += padUsed["type"] + "_V"
    else:
        macro_name += padUsed["type"]
    writePadMacro(padUsed, v, macro_name)
    instType = resolveInterfaceType(user_info["type"])
    instSize = resolveSize(user_info["size"])
    topModuleHeader += instType + " "
    topModuleHeader += instSize + " "
    topModuleHeader += user_info["name"] + ",\n"

    if instType == "input":
        instType = "inout"
    padFrameHeaderDefinition += instType + " "
    padFrameHeaderDefinition += instSize + " "
    padFrameHeaderDefinition += user_info["name"] + ",\n"

    padFrameHeader += "." + user_info["name"] + "(" + user_info["name"] + "),\n"

    inst_body = "`" + macro_name + " ("
    if v:
        inst_body += str(user_info["size"]) + ","

    for key in padUsed["mapping"].keys():
        res = None

        if key == "name":
            res = [user_info]
        elif key in user_info.keys():
            res = user_info[key]
        else:
            for port in padUsed["ports"]:
                if "condition" in port.keys():
                    continue
                if port["name"] == padUsed["mapping"][key]:
                    res = port["connection"]
                    break
        if res is not None:
            if isinstance(res, dict) and "name" not in res.keys():
                wire_name = padUsed["type"] + "_" + user_info["name"] + "_" + key
                createDictWireForPads(wire_name, res, user_info["size"])
                inst_body += wire_name + ","
            elif len(res) > 1 and key != "name":
                wire_name = padUsed["type"] + "_" + user_info["name"] + "_" + key
                createWireForPads(wire_name, res)
                inst_body += wire_name + ","
            else:
                if isinstance(res[0], dict):
                    inst_body += res[0]["name"] + " "
                    if "size" in res[0].keys() and key != "name":
                        inst_body += resolveSize(res[0]["size"])
                else:
                    inst_body += res[0] + " "
                inst_body += ","
        else:
            inst_body += "  , "
    inst_body = inst_body[:-1] + ");\n"

    padFrameModule += inst_body


# createDictWireForPads creates the wire for a pad macro parameter if it has a complex object description. The description is parsed into an assign to that wire. i.e. "mode":{"bit_0":{}, "bit_1":{}, "bit_2":{}}
def createDictWireForPads(wire_name, wire_info, size):
    global padFrameWires
    wire_body = (
        "wire ["
        + str(size * len(wire_info.keys()) - 1)
        + ":0] "
        + wire_name
        + " = {\n\t\t"
    )
    for i in reversed(range(size)):
        for key in wire_info.keys():
            wire_body += wire_info[key] + "[" + str(i) + "],"
        wire_body += "\n\t\t"
    wire_body = wire_body[:-4] + "};\n"
    padFrameWires += wire_body


# createWireForPads creates the wire for a pad macro parameter if it has a list description.
def createWireForPads(wire_name, wire_info):
    global padFrameWires
    wire_body = (
        "wire [" + str(getConcatSize(wire_info) - 1) + ":0] " + wire_name + " = {"
    )
    for con in wire_info:
        if isinstance(con, dict):
            wire_body += con["name"] + " "
            if "size" in con.keys():
                wire_body += resolveSize(con["size"])
        else:
            wire_body += con + " "
        wire_body += ", "
    wire_body = wire_body[:-2] + "};\n"
    padFrameWires += wire_body


# getConcatSize gets the total size of a concatenation
def getConcatSize(concatentation):
    tot_size = 0

    for signal in concatentation:
        if isinstance(signal, dict):
            if "size" in signal.keys():
                if isinstance(signal["size"], int):
                    tot_size += signal["size"]
                else:
                    tot_size += signal["size"]["offset"]
            else:
                tot_size += 1
        else:
            tot_size += 1
    return tot_size


# writePadMacro is responsible for writing the macro definition of the pads except for power/corner pads
def writePadMacro(pad_macro, v, macro_name):
    if macro_name in written_macros:
        return
    pad_macro_copy = copy.deepcopy(pad_macro)
    written_macros.append(macro_name)
    global topModuleMacros
    macro_body = ""
    if v:
        macro_body += "`define " + macro_name + "(V,"
    else:
        macro_body += "`define " + macro_name + "("

    for key in pad_macro_copy["mapping"].keys():
        macro_body += key.upper() + ","

    pad_macro_copy["ports"] = resolvePortMapping(
        pad_macro_copy["mapping"], pad_macro_copy["ports"]
    )
    macro_body = macro_body[:-1] + ") \\\n"

    for wire in pad_macro_copy["wire_declaration_info"]:
        macro_body += "wire "
        if v:
            macro_body += "[V-1:0] "
        macro_body += resolveConnectionName(wire["name"]) + "; \\\n"

    macro_body += pad_macro_copy["pad_name"] + " NAME``_pad "
    if v:
        macro_body += "[V-1:0] ( \\\n"
    else:
        macro_body += "( \\\n"

    if "defines" in pad_macro_copy.keys():
        macro_body += addPadDefines(pad_macro_copy["defines"], True)

    for port in pad_macro_copy["ports"]:
        if "condition" in port.keys():
            hasElse = False
            if "def" in port["condition"].keys():
                portd = port["condition"]["def"]
                macro_body += "`ifdef " + port["condition"]["name"] + " \\\n"
                macro_body += "\t." + portd["name"] + "( "
                if portd["connection"] is not None:
                    if len(portd["connection"]) > 1:
                        macro_body += "{"
                        for connection in portd["connection"]:
                            macro_body += resolveConnectionName(connection) + ","
                        macro_body = macro_body[:-1] + "},"
                    else:
                        macro_body += (
                            resolveConnectionName(portd["connection"][0]) + ","
                        )
                macro_body = macro_body[:-1] + "), \\\n"
                hasElse = True
            if "ndef" in port["condition"].keys():
                portd = port["condition"]["ndef"]
                if hasElse:
                    macro_body += "`else \\\n"
                else:
                    macro_body += "`ifndef " + port["condition"]["name"] + " \\\n"
                macro_body += "\t." + portd["name"] + "( "
                if portd["connection"] is not None:
                    if len(portd["connection"]) > 1:
                        macro_body += "{"
                        for connection in portd["connection"]:
                            macro_body += resolveConnectionName(connection) + ","
                        macro_body = macro_body[:-1] + "},"
                    else:
                        macro_body += (
                            resolveConnectionName(portd["connection"][0]) + ","
                        )
                macro_body = macro_body[:-1] + "), \\\n"
            macro_body += "`endif \\\n"

        else:
            macro_body += "." + port["name"] + "( "
            if port["connection"] is not None:
                if len(port["connection"]) > 1:
                    macro_body += "{"
                    for connection in port["connection"]:
                        macro_body += resolveConnectionName(connection) + ","
                    macro_body = macro_body[:-1] + "},"
                else:
                    macro_body += resolveConnectionName(port["connection"][0]) + ","
            macro_body = macro_body[:-1] + "), \\\n"

    macro_body = macro_body[:-4] + ")\n\n"

    topModuleMacros += macro_body


# resolveConnectionName to replace any references to $name with the proper ``NAME or NAME``
def resolveConnectionName(connection):
    if connection.find("$name") == 0:
        return connection.replace("$name", "NAME``")
    else:
        return connection.replace("$name", "``NAME")


# resolvePortMapping to resolve the value of defined port with the user defined value or retrieve it from the the default values defined in the PADs library
def resolvePortMapping(mapping, ports):
    for key in mapping.keys():
        for portIdx in range(len(ports)):
            port = ports[portIdx]
            if "condition" in port.keys():
                if "def" in port["condition"].keys():
                    if port["condition"]["def"]["name"] == mapping[key]:
                        port["condition"]["def"]["connection"] = [key.upper()]

                if "ndef" in port["condition"].keys():
                    if port["condition"]["ndef"]["name"] == mapping[key]:
                        port["condition"]["ndef"]["connection"] = [key.upper()]
            elif port["name"] == mapping[key]:
                port["connection"] = [key.upper()]
            ports[portIdx] = port
    return ports


# resolveSize to resolve the size whether its defined as 1, [size-1:0], or [offset-start+1:start]
def resolveSize(size):
    if isinstance(size, int):
        if int(size) > 1:
            return "[" + str(size - 1) + ":0] "
        else:
            return ""
    else:
        return (
            "["
            + str(size["offset"] + size["start"] - 1)
            + ":"
            + str(size["start"])
            + "] "
        )


# resolveInterfaceType to resolve type of interface to input, output, or inout
def resolveInterfaceType(padType):
    if padType in ["DIGITAL_INPUT", "ANALOG_INPUT", "DIGITAL_INPUT_TV2", "XRES"]:
        return "input"
    if padType in ["DIGITAL_OUTPUT", "ANALOG_OUTPUT", "DIGITAL_OUTPUT_TV2"]:
        return "output"
    if padType in ["DIGITAL_INOUT", "ANALOG_INOUT"]:
        return "inout"

    raise Exception("Used Pad is not of a defined type")


# parsePowerCornerPads is responsible for parsing the power/corner pads
def parsePowerCornerPads():
    # Handle Case of user give power/corner pads
    for pad in padsLib["pads"]:
        if "count" in pad.keys():
            global padFrameModule
            if "powerCornerPads" in design_json_complete.keys():
                for new_pad in design_json_complete["powerCornerPads"]:
                    if pad["type"] == new_pad["type"]:
                        if "count" in new_pad.keys():
                            pad["count"] = new_pad["count"]

                        if "ports" in new_pad.keys():
                            for p_new in new_pad["ports"]:
                                for p_default_idx in range(len(pad["ports"])):
                                    if (
                                        p_new["name"]
                                        == pad["ports"][p_default_idx]["name"]
                                    ):
                                        pad["ports"][p_default_idx] = p_new
                                        break
                        break
            if "condition" in pad.keys():
                if pad["condition"]["def"]:
                    padFrameModule += "`ifdef " + pad["condition"]["name"] + "\n"
                else:
                    padFrameModule += "`ifndef " + pad["condition"]["name"] + "\n"
                padFrameModule += writePowerCornerPad(pad)
                padFrameModule += "`endif\n"
            else:
                padFrameModule += writePowerCornerPad(pad) + "\n"


# writePowerCornerPad is responsible for adding a power/corner pad to the output verilog
def writePowerCornerPad(padUsed):
    padBody = str(padUsed["pad_name"]) + " " + str(padUsed["type"])
    if int(padUsed["count"]) > 1:
        padBody += " [" + str(int(padUsed["count"]) - 1) + ":0] (\n"
    else:
        padBody += " (\n"

    if "defines" in padUsed.keys():
        padBody += addPadDefines(padUsed["defines"], False)

    ports = padUsed["ports"]

    # add wires to the declaration plan
    if "wire_declaration_info" in padUsed.keys():
        if padUsed["wire_declaration_info"] is not None:
            for wire in padUsed["wire_declaration_info"]:
                wiresToDeclare[wire["name"]] = wire

    # add header signals to the declaration plan
    if "interface_declaration_info" in padUsed.keys():
        if padUsed["interface_declaration_info"] is not None:
            for signal in padUsed["interface_declaration_info"]:
                headerSignalsToDeclare[signal["name"]] = signal

    for port in ports:
        if "condition" in port.keys():
            hasElse = False
            if "def" in port["condition"].keys():
                portd = port["condition"]["def"]
                padBody += "`ifdef " + port["condition"]["name"] + " \n"
                padBody += "\t." + portd["name"] + "( "
                if portd["connection"] is not None:
                    if len(portd["connection"]) > 1:
                        padBody += "{"
                        for con in portd["connection"]:
                            padBody += con + ", "
                        padBody = padBody[:-2] + "},"
                    else:
                        padBody += portd["connection"][0] + ","

                padBody = padBody[:-1] + "),\n"
                hasElse = True
            if "ndef" in port["condition"].keys():
                portd = port["condition"]["ndef"]
                if hasElse:
                    padBody += "`else \n"
                else:
                    padBody += "`ifndef " + port["condition"]["name"] + " \n"
                padBody += "\t." + portd["name"] + "( "
                if portd["connection"] is not None:
                    padBody += "{"
                    if len(portd["connection"]) > 1:
                        for con in portd["connection"]:
                            padBody += con + ", "
                        padBody = padBody[:-2] + "},"
                    else:
                        padBody += portd["connection"][0] + ","
                padBody = padBody[:-1] + "),\n"
            padBody += "`endif \n"
        else:
            padBody += "." + port["name"] + "( "
            if port["connection"] is not None:
                if len(port["connection"]) > 1:
                    padBody += "{"
                    for con in port["connection"]:
                        padBody += con + ", "
                    padBody = padBody[:-2] + "},"
                else:
                    padBody += port["connection"][0] + ","
            padBody = padBody[:-1] + "),\n"

    padBody = padBody[:-2] + ");\n"
    return padBody


# addPadDefines adds the defines inside the pads i.e. `ABUTMENT_PINS
def addPadDefines(defines, isMacro):
    ret = ""
    for define in defines:
        if "condition" in define.keys():
            hasElse = False
            if "def" in define["condition"]:
                hasElse = True
                ret += "`ifdef " + define["condition"]["name"]
                if isMacro:
                    ret += " \\\n"
                else:
                    ret += " \n"
                for single_define in define["condition"]["def"]:
                    ret += "`" + single_define["name"]
                    if isMacro:
                        ret += " \\\n"
                    else:
                        ret += " \n"

            if "ndef" in define["condition"]:
                if hasElse:
                    ret += "`else"
                    if isMacro:
                        ret += " \\\n"
                    else:
                        ret += " \n"
                else:
                    ret += "`ifndef " + define["condition"]["name"]
                    if isMacro:
                        ret += " \\\n"
                    else:
                        ret += " \n"
                for single_define in define["condition"]["ndef"]:
                    ret += "`" + single_define["name"]
                    if isMacro:
                        ret += " \\\n"
                    else:
                        ret += " \n"
            ret += "`endif"
            if isMacro:
                ret += " \\\n"
            else:
                ret += " \n"
        else:
            ret += "`" + define["name"]
            if isMacro:
                ret += " \\\n"
            else:
                ret += " \n"
    return ret


# parseMacros parses user defines or pad library defines
def parseMacros(defines):
    global topModuleDefines
    for define in defines:
        # add wires to the declaration plan
        if "wire_declaration_info" in define.keys():
            if define["wire_declaration_info"] is not None:
                for wire in define["wire_declaration_info"]:
                    wiresToDeclare[wire["name"]] = wire

        # add header signals to the declaration plan
        if "interface_declaration_info" in define.keys():
            if define["interface_declaration_info"] is not None:
                for signal in define["interface_declaration_info"]:
                    headerSignalsToDeclare[signal["name"]] = signal

        topModuleDefines += writeMacro(define)[:-2] + "\n\n"


# writeMacro writes the macro to the final verilog output
def writeMacro(define):
    macro_body = ""
    if "condition" in define.keys():
        hasElse = False
        if "def" in define["condition"]:
            hasElse = True
            macro_body += "`ifdef " + define["condition"]["name"] + " \n"
            macro_body += writeMacro(define["condition"]["def"])

        if "ndef" in define["condition"]:
            if hasElse:
                macro_body = macro_body[:-2] + "\n`else \n"
            else:
                macro_body += "`ifndef " + define["condition"]["name"] + " \n"
            macro_body += writeMacro(define["condition"]["ndef"])
        macro_body = macro_body[:-2] + "\n`endif \n"
    else:
        macro_body += "`define " + define["name"] + " \\\n"
        if "ports" in define.keys():
            for port in define["ports"]:
                if "condition" in port.keys():
                    hasElse = False
                    if "def" in port["condition"]:
                        hasElse = True
                        portd = port["condition"]["def"]
                        macro_body += "`ifdef " + port["condition"]["name"] + " \\\n"
                        macro_body += "\t." + portd["name"] + "( "
                        if portd["connection"] is not None:
                            if len(portd["connection"]) > 1:
                                macro_body += "{"
                                for con in portd["connection"]:
                                    macro_body += con + ", "
                                macro_body = macro_body[:-2] + "},"
                            else:
                                macro_body += portd["connection"][0] + ","
                        macro_body = macro_body[:-1] + "), \\\n"
                    if "ndef" in define["condition"]:
                        portd = port["condition"]["ndef"]
                        if hasElse:
                            macro_body += "`else \\\n"
                        else:
                            macro_body += (
                                "`ifndef " + define["condition"]["name"] + " \\\n"
                            )
                        macro_body += "\t." + portd["name"] + "( "
                        if portd["connection"] is not None:
                            if len(portd["connection"]) > 1:
                                macro_body += "{"
                                for con in portd["connection"]:
                                    macro_body += con + ", "
                                macro_body = macro_body[:-2] + "},"
                            else:
                                macro_body += portd["connection"][0] + ","
                        macro_body = macro_body[:-1] + "), \\\n"
                    macro_body += "`endif \\\n"
                else:
                    macro_body += "\t." + port["name"] + "( "
                    if port["connection"] is not None:
                        if len(port["connection"]) > 1:
                            macro_body += "{"
                            for con in port["connection"]:
                                macro_body += con + ", "
                            macro_body = macro_body[:-2] + "},"
                        else:
                            macro_body += port["connection"][0] + ","
                    macro_body = macro_body[:-1] + "), \\\n"
    return macro_body


# addTopModuleWires writes the wires required by the pads/user in the top module
def addPadFrameWires():
    global padFrameWires
    for wire in wiresToDeclare:
        if wire in headerSignalsToDeclare:
            continue
        else:
            decl = "\nwire "
            if "size" in wiresToDeclare[wire]:
                decl += resolveSize(wiresToDeclare[wire]["size"])
            decl += wire + ";"
            padFrameWires += decl


# Add the module interface required by the pads: i.e. vss, vdd1v8, vdd
def addTopModulePadsInterface():
    global topModuleHeader
    global padFrameHeaderDefinition
    global padFrameHeader

    if len(headerSignalsToDeclare):
        topModuleHeader = topModuleHeader[:-3] + ",\n"
        for signal in headerSignalsToDeclare:
            decl = resolveInterfaceType(headerSignalsToDeclare[signal]["type"]) + " "
            if "size" in headerSignalsToDeclare[signal]:
                decl += resolveSize(headerSignalsToDeclare[signal]["size"]) + " "
            decl += signal + ",\n"
            topModuleHeader += decl
            padFrameHeaderDefinition += decl
            padFrameHeader += "." + signal + "(" + signal + "),\n"
        topModuleHeader = topModuleHeader[:-2] + ");\n"
        padFrameHeaderDefinition = padFrameHeaderDefinition[:-2] + ");\n"
        padFrameHeader = padFrameHeader[:-2] + ");\n"


# parseDesignHeader parses the verilog module header of the core module  and creates its wires and connections
def parseDesignHeader(verilog_file):
    global padFrameHeaderDefinition
    global padFrameHeader
    global topModuleDeclarations
    global topModuleBody
    module_header = design_json["name"] + "  core_inst(\n"
    wiresDeclarations = ""
    ast, x = parse([verilog_file])
    # output = StringIO()
    out = StringIO()
    ast.show(buf=out)
    rlst = out.getvalue()
    # print(rlst)
    startString = "ModuleDef: " + design_json["name"]
    startPoint = rlst.find(startString)
    startPoint = rlst.find("Portlist:", startPoint)
    declIdx = rlst.find("Decl:", startPoint)
    instanceListIdx = rlst.find("InstanceList:", startPoint)
    moduleDefIdx = rlst.find("ModuleDef:", startPoint)
    if declIdx == -1:
        declIdx = 0x0FFFFFFF
    if instanceListIdx == -1:
        instanceListIdx = 0x0FFFFFFF
    if moduleDefIdx == -1:
        moduleDefIdx = 0x0FFFFFFF
    endIdx = min(declIdx, instanceListIdx, moduleDefIdx)
    if endIdx != 0x0FFFFFFF:
        rlst = rlst[:endIdx]
    portList = rlst[startPoint:].split("Ioport:")
    # print(portList)
    # print(portList)
    for port in portList[1:]:
        port_split = port.split("\n")
        for idx in range(len(port_split)):
            line = port_split[idx]
            if line.find("Input") != -1:
                signalName = getSignalName(line)
                signalSize = extractSizeFromVerilog(port_split, idx)
                module_header += "." + signalName + "(" + signalName + "),\n"
                wiresDeclarations += "wire " + signalSize + " " + signalName + ";\n"
                padFrameHeader += "." + signalName + "(" + signalName + "),\n"
                padFrameHeaderDefinition += (
                    "output " + signalSize + " " + signalName + ",\n"
                )
                break
            elif line.find("Output") != -1:
                signalName = getSignalName(line)
                signalSize = extractSizeFromVerilog(port_split, idx)
                module_header += "." + signalName + "(" + signalName + "),\n"
                wiresDeclarations += "wire " + signalSize + " " + signalName + ";\n"
                padFrameHeader += "." + signalName + "(" + signalName + "),\n"
                padFrameHeaderDefinition += (
                    "input " + signalSize + " " + signalName + ",\n"
                )
                break
            elif line.find("Inout") != -1:
                signalName = getSignalName(line).strip()
                signalSize = extractSizeFromVerilog(port_split, idx)
                module_header += "." + signalName + "(" + signalName + "),\n"
                wiresDeclarations += "wire " + signalSize + " " + signalName + ";\n"
                padFrameHeader += "." + signalName + "(" + signalName + "),\n"
                padFrameHeaderDefinition += (
                    "inout " + signalSize + " " + signalName + ",\n"
                )
                break
    module_header = module_header[:-2] + ");\n"
    topModuleDeclarations += wiresDeclarations
    topModuleBody += module_header


def getSignalName(line):
    pattern = re.compile(r"\s*?[\S+]+\,")
    for signal in re.findall(pattern, line):
        return signal[1:-1]


def extractSizeFromVerilog(port_split, start_idx):
    size = ""
    end_idx = min(start_idx + 3, len(port_split))
    for idx in range(start_idx, end_idx):
        line = port_split[idx]
        if line.find("Width") != -1:
            pattern = re.compile(r"\s*?\d+\s")
            size += "["
            for s in re.findall(pattern, port_split[idx + 1]):
                size += s + ":"
                break
            for s in re.findall(pattern, port_split[idx + 2]):
                size += s + "]"
                break
    return size


# parseIncludes parses the includes of a given json
def parseIncludes(includes):
    global topModuleIncludes
    for include in includes:
        topModuleIncludes += writeInclude(include) + "\n\n"


# writeInclude writes the includes into the final verilog output
def writeInclude(include):
    include_body = ""
    if isinstance(include, dict) and "condition" in include.keys():
        hasElse = False
        if "def" in include["condition"]:
            hasElse = True
            include_body += "`ifdef " + include["condition"]["name"] + " \n"
            if isinstance(include["condition"]["def"], list):
                for i in include["condition"]["def"]:
                    include_body += writeInclude(i)
            else:
                include_body += writeInclude(include["condition"]["def"])

        if "ndef" in include["condition"]:
            if hasElse:
                include_body = include_body + "`else \n"
            else:
                include_body += "`ifndef " + include["condition"]["name"] + " \n"
            include_body += writeInclude(include["condition"]["ndef"])
            if isinstance(include["condition"]["ndef"], list):
                for i in include["condition"]["ndef"]:
                    include_body += writeInclude(i)
            else:
                include_body += writeInclude(include["condition"]["ndef"])
        include_body = include_body + "`endif \n"
    else:
        include_body += '\t`include "' + include["name"] + '"\n'
    return include_body


# If defines/macros section exists in the descriptions, write those defines
if "defines" in padsLib.keys() and len(padsLib["defines"]):
    topModuleDefines += "\n//PADs Library defines/macros\n"
    parseMacros(padsLib["defines"])
if "defines" in design_json_complete.keys() and len(design_json_complete["defines"]):
    topModuleDefines += "\n//User defines/macros\n"
    parseMacros(design_json_complete["defines"])

# If the includes section exists in the description, write those includes
if "includes" in padsLib_json.keys() and len(padsLib_json["includes"]):
    topModuleIncludes += "\n//PADs Library includes\n"
    parseIncludes(padsLib_json["includes"])
if "includes" in design_json_complete.keys() and len(design_json_complete["includes"]):
    topModuleIncludes += "\n//User includes\n"
    parseIncludes(design_json_complete["includes"])

# Parse the pads
padFrameModule += "\n//Input/Output PADs\n"
parsePads()
padFrameModule += "\n//Power/Corner PADs\n"
parsePowerCornerPads()


# if section extra_verilog exists, write append the extra_verilog to the module
if "extra_verilog" in design_json_complete.keys():
    if isinstance(design_json_complete["extra_verilog"], list):
        for ex in design_json_complete["extra_verilog"]:
            topModuleExtra += ex + "\n"
    else:
        topModuleExtra = design_json_complete["extra_verilog"]

# Read the user verilog file and parse the top module header
if not os.path.exists(verilog_file):
    raise IOError("file not found: " + verilog_file)
"""verilogFileOpener = open(verilog_file, 'r')
verilogFileData = verilogFileOpener.read()
verilogFileOpener.close()"""
topModuleBody += "\n\n//Core Module Instantiation\n"
parseDesignHeader(verilog_file)


# add the module interface
addTopModulePadsInterface()

# add the used wires
addPadFrameWires()


# write endmodule
topModuleBody += "\n\n//PadFrame Instantiation\n" + padFrameHeader
topModuleBody += "\n\nendmodule"

# join padframe module sections
padFrameModule = (
    padFrameHeaderDefinition
    + "\n\n"
    + padFrameWires
    + "\n\n"
    + padFrameModule
    + "\n\nendmodule"
)

# join the code segments
topModule = (
    topModuleDefines
    + "\n\n\n"
    + topModuleIncludes
    + "\n\n\n"
    + topModuleMacros
    + "\n\n\n"
    + topModuleHeader
    + "\n\n\n"
    + topModuleDeclarations
    + "\n\n\n"
    + topModuleExtra
    + topModuleBody
    + "\n\n"
    + padFrameModule
    + "\n\n"
)

# write the code
outputFileOpener = open(output, "w+")
outputFileOpener.write(topModule)
outputFileOpener.close()
