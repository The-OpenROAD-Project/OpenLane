import os
import subprocess
import sys

args = sys.argv[1:]

run_folder = args[0]

log_path = os.path.join(run_folder, "openlane.log")
assert (
    subprocess.call(
        ["grep", "-i", "No KLayout DRC violations after GDS streaming out", log_path]
    )
    == 0
), "OpenLane did not report the lack of DRC violations properly"
