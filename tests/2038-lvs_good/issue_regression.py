import os
import sys
import glob
import subprocess

args = sys.argv[1:]

run_folder = args[0]

log_path = glob.glob(
    os.path.join(run_folder, "reports", "signoff", "*-inverter.lvs.rpt")
)
assert len(log_path) != 0, "LVS report file not found"
assert len(log_path) == 1, "Multiple LVS report files found"
assert (
    subprocess.call(
        [
            "grep",
            "-i",
            "Total errors = 0",
            log_path[0],
        ]
    )
    == 0
), "Unexpected LVS error count"
