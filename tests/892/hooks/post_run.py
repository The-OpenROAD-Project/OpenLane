# export TECH_LEF=/home/armleo/Desktop/OpenLane/pdks/sky130A/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd.tlef
# export MERGED_LEF=/openlane/designs/def_test/runs/RUN_2022.01.23_17.23.46/tmp/merged.lef
# export HOOK_OUTPUT_PATH=/openlane/designs/def_test/runs/RUN_2022.01.23_17.23.46/results/final
# export DESIGN_DIR=/openlane/designs/def_test
# openroad -exit -python designs/def_test/hooks/post_run.py

import odb

import os
import sys


def extract_pins(db, def_file):
    odb.read_lef(db, os.environ["TECH_LEF"])
    odb.read_lef(db, os.environ["MERGED_LEF"])
    odb.read_def(db, def_file)
    chip = db.getChip()
    block = chip.getBlock()
    nets = block.getNets()
    # tech = db.getTech() # Not needed

    result_data = {}
    for net in nets:
        net_name = net.getName()
        # BTerms = PINS, if it has a pin we need to keep the net
        bterms = net.getBTerms()
        if len(bterms) > 0:
            for port in bterms:
                if (port.getSigType() == "POWER") or (port.getSigType() == "GROUND"):
                    # Ignore power pins
                    continue
                name = port.getName()

                bbox = port.getBBox()
                result_data[name] = bbox
                print(
                    "Net:",
                    net_name,
                    "Port:",
                    name,
                    "ll: ",
                    " ".join(str(e) for e in bbox.ll()),
                    "ur: ",
                    " ".join(str(e) for e in bbox.ur()),
                )
    return result_data


result_db = odb.dbDatabase.create()
ref_db = odb.dbDatabase.create()

print("TECH_LEF ", os.environ["TECH_LEF"])
print("MERGED_LEF ", os.environ["MERGED_LEF"])
print("HOOK_OUTPUT_PATH ", os.environ["HOOK_OUTPUT_PATH"])
print("DESIGN_DIR ", os.environ["DESIGN_DIR"])


result_data = extract_pins(
    result_db, os.environ["HOOK_OUTPUT_PATH"] + "/def/def_test.def"
)

# result_data = extract_pins(result_db, os.environ["DESIGN_DIR"] + "/def_test.def")
ref_data = extract_pins(ref_db, os.environ["DESIGN_DIR"] + "/def_test.def")

# print(result_data)
# print(ref_data)

for k, v in ref_data.items():
    assert (
        v.ll() == result_data[k].ll()
    ), f"For pin {k} lower left rectangle point {result_data[k].ll()} does not match {v.ll()}"
    assert (
        v.ur() == result_data[k].ur()
    ), f"For pin {k} upper right rectangle point {result_data[k].ur()} does not match {v.ur()}"

assert (
    result_db.getTech().getManufacturingGrid()
    == ref_db.getTech().getManufacturingGrid()
)
assert (
    result_db.getTech().getDbUnitsPerMicron() == ref_db.getTech().getDbUnitsPerMicron()
)
assert (
    result_db.getChip().getBlock().getDieArea().ur()
    == ref_db.getChip().getBlock().getDieArea().ur()
)
assert (
    result_db.getChip().getBlock().getDieArea().ll()
    == ref_db.getChip().getBlock().getDieArea().ll()
)

sys.exit(0)
