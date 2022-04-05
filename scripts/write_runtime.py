# Copyright 2021 Efabless Corporation
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
import os
import re
import sys
import yaml
import click
from typing import List, Optional


def timestamp_to_seconds(runtime: str) -> Optional[float]:
    pattern = re.compile(r"\s*([\d+]+)h([\d+]+)m([\d+]+)s(?:([\d+]+)+ms)?")
    m = pattern.match(runtime)
    if m is None:
        return None
    time = (
        int(m.group(1)) * 60 * 60
        + int(m.group(2)) * 60
        + int(m.group(3))
        + int(m.group(4) or 0) / 1000.0
    )
    return time


def seconds_to_timestamp(runtime: float) -> str:
    hours = int(runtime // 3600)
    minutes_and_seconds_and_milliseconds = runtime % 3600
    minutes = int(minutes_and_seconds_and_milliseconds // 60)
    seconds_and_milliseconds = minutes_and_seconds_and_milliseconds % 60
    seconds = int(seconds_and_milliseconds // 1)
    milliseconds = int((seconds_and_milliseconds % 1) * 1000)
    return f"{hours}h{minutes}m{seconds}s{milliseconds}ms"


runtime_file_path: str = os.path.join(os.environ["RUN_DIR"], "runtime.yaml")


def read_runtime_yaml():
    runtime_data_str: str = "[]"
    try:
        runtime_data_str = open(runtime_file_path).read()
    except FileNotFoundError:
        pass

    yaml_docs: List[List] = list(yaml.safe_load_all(runtime_data_str))

    return yaml_docs[0]


def write_runtime(status: str, time_in: float):
    runtime_data = read_runtime_yaml()

    obj = {}
    obj["status"] = f"{os.environ['CURRENT_INDEX']} - {status}"
    obj["runtime_s"] = round(time_in, 2)
    obj["runtime_ts"] = seconds_to_timestamp(time_in)

    runtime_data.append(obj)

    with open(runtime_file_path, "w") as f:
        f.write(yaml.safe_dump(runtime_data, sort_keys=False))


def conclude_run(status: str, time_in: float):
    runtime_data = read_runtime_yaml()

    final_runtime_data = []

    timer_start = os.getenv("timer_start")
    if timer_start is None:
        raise Exception(
            "Attempted to conclude a run without timer_start environment variable set"
        )
    timer_start = float(timer_start)

    timer_routed = os.getenv("timer_routed")
    routed_s = -1
    routed_ts = "-1"
    if timer_routed is not None:
        timer_routed = float(timer_routed)
        routed_s = timer_routed - timer_start
        routed_ts = seconds_to_timestamp(routed_s)

    obj = {}
    obj["status"] = "routed"
    obj["runtime_s"] = routed_s
    obj["runtime_ts"] = routed_ts
    final_runtime_data.append(obj)

    done_s = time_in - timer_start
    done_ts = seconds_to_timestamp(done_s)

    obj = {}
    obj["status"] = status
    obj["runtime_s"] = done_s
    obj["runtime_ts"] = done_ts
    final_runtime_data.append(obj)

    with open(runtime_file_path, "w") as f:
        f.write(yaml.safe_dump_all([runtime_data, final_runtime_data], sort_keys=False))


@click.command("write_runtime")
@click.option("--conclude/--no-conclude", default=False)
@click.option(
    "--seconds/--timestamp",
    "seconds",
    default=False,
    help="Process the input string either as a timestamp or a floating point second value",
)
@click.option(
    "--time-in",
    default=None,
    help="If this argument is not specified, time is read from stdin.",
)
@click.argument("status")
def cli(seconds, conclude, time_in, status):
    if time_in is None:
        time_in = sys.stdin.read().rstrip()

    if seconds:
        time_in = float(time_in)
    else:
        temp = timestamp_to_seconds(time_in)
        if temp is None:
            raise Exception(f"Invalid timestamp {time_in}")
        time_in = temp

    if conclude:
        conclude_run(status, time_in)
    else:
        write_runtime(status, time_in)


if __name__ == "__main__":
    cli()
