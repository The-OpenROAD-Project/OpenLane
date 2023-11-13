import os
import subprocess
import sys

args = sys.argv[1:]
exit_code = args[1]
run_folder = args[0]

assert exit_code != 0, "OpenLane did not throw non zero exit code"
log_path = os.path.join(run_folder, "openlane.log")
assert (
    subprocess.call(
        [
            "grep",
            "-i",
            "There are assign statements in the netlist",
            log_path,
        ]
    )
    == 0
), "OpenLane did not report the existence of assign statments correctly"
