import sys
import os
import subprocess

technologyName = sys.argv[1]

gdsInfo = sys.argv[2]
gdsName = os.path.basename(gdsInfo).split(".gds")[0]
gdsDir = os.path.dirname(gdsInfo)

lefInfo = sys.argv[3]
lefName = os.path.basename(lefInfo).split(".lef")[0]
lefDir = os.path.dirname(lefInfo)

ROOT_DIR = os.path.abspath(os.curdir)

magic_gds_to_lef_cmd = "magic -noconsole -dnull -rcfile {ROOT_DIR}/pdks/{technologyName}/libs.tech/magic/current/{technologyName}.magicrc {ROOT_DIR}/scripts/magic_gds_to_lef.tcl {ROOT_DIR}/{gdsDir}/ {gdsName} {ROOT_DIR}/{lefDir}/ {lefName} </dev/null".format(
        ROOT_DIR=ROOT_DIR,
        technologyName=technologyName,
        gdsDir=gdsDir,
        gdsName=gdsName,
        lefDir=lefDir,
        lefName=lefName
        )

os.system(magic_gds_to_lef_cmd)