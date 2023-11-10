import os
import subprocess
import sys

args = sys.argv[1:]

run_folder = args[0]

log_path = os.path.join(run_folder, "openlane.log")
assert (
    subprocess.call(["grep", "-i", "There are LVS errors in the design", log_path]) == 0
), "OpenLane did not report the existence of LVS errors correctly"
