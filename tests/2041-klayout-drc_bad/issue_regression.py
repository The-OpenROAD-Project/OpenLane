import os
import subprocess
import sys

args = sys.argv[1:]

exit_code = args[1]
run_folder = args[0]

log_path = os.path.join(run_folder, "openlane.log")
assert exit_code != 0, "OpenLane did not throw non zero exit code"
assert (
    subprocess.call(
        ["grep", "-i", "There are violations in the design after KLayout DRC", log_path]
    )
    == 0
), "OpenLane does not accurately report the existence of violations"

assert (
    subprocess.call(["grep", "-Pi", "Total Number of violations is \\d+", log_path])
    == 0
), "OpenLane does not accurately print the number of violations"
