#!/usr/bin/env python3

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

# Note to maintainers/contributors:
#
# Ensure you don't use f strings, non-comment type hints or any other features
# that wouldn't work on Python 3.3
#
# Inevitably, some people won't read the Readme and then complain that the issue
# survey doesn't work on their older Python versions. As long as it's compatible
# with Python 3.3, this script will tell them that their python version is
# below the minimum supported.

import io
import os
import sys
import getpass
import textwrap
import subprocess
from os.path import abspath, dirname

openlane_dir = dirname(abspath(__file__))
is_root = os.geteuid() == 0

# Commands
def tool_list():
    from dependencies.tool import Tool

    tools = Tool.from_metadata_yaml(open("./dependencies/tool_metadata.yml").read())
    for tool in tools.values():
        print("%s %s" % (tool.name, tool.version_string))


def local_install():
    from dependencies.installer import Installer

    installer = Installer()
    installer.run()


def docker_config():
    from dependencies.env_info import ContainerInfo

    cinfo = ContainerInfo.get()

    if cinfo.engine == "docker":
        if cinfo.rootless:
            print("-u 0", end="")
        else:
            uid = (
                subprocess.check_output(["id", "-u", getpass.getuser()])
                .decode("utf8")
                .strip()
            )
            gid = (
                subprocess.check_output(["id", "-g", getpass.getuser()])
                .decode("utf8")
                .strip()
            )
            print("--user %s:%s" % (uid, gid), end="")


def issue_survey():
    sys.path.append(os.path.dirname(__file__))
    from dependencies.env_info import OSInfo
    from dependencies.version import parse as vp

    alerts = open(os.devnull, "w")

    final_report = ""

    os_info = OSInfo.get()
    final_report += textwrap.dedent(
        """\
        Kernel: %s v%s
    """
        % (os_info.kernel, os_info.kernel_version)
    )

    if os_info.distro is not None:
        final_report += textwrap.dedent(
            """\
            Distribution: %s %s
        """
            % (os_info.distro, (os_info.distro_version or ""))
        )

    python_version = vp(os_info.python_version)
    minimum_python_version = vp("3.6")
    python_message = "OK"
    python_ok = True
    if python_version < minimum_python_version:
        python_message = "BELOW MINIMUM: UPDATE PYTHON"
        python_ok = False

    final_report += textwrap.dedent(
        """\
        Python: v%s (%s)
    """
        % (python_version, python_message)
    )

    if os_info.container_info is not None:
        container_version = vp(os_info.container_info.version)

        container_message = "UNSUPPORTED"
        if "docker" in os_info.container_info.engine:
            container_message = "OK"
            minimum_docker_version = vp("19.03.12")
            if container_version < minimum_docker_version:
                container_message = "BELOW MINIMUM: UPDATE DOCKER"

        final_report += textwrap.dedent(
            """\
            Container Engine: %s v%s (%s)
        """
            % (os_info.container_info.engine, container_version, container_message)
        )
    else:
        try:
            subprocess.check_output(
                ["systemd-detect-virt", "-c"]
            )  # Check if running inside container
            if not os.path.exists("/openlane"):
                raise Exception()
            alert = "Alert: Running in container."
            final_report += "%s\n" % alert
            print(alert, file=alerts)
        except Exception:
            alert = "Critical Alert: No Docker or Docker-compatible container engine was found: {e}."
            final_report += "%s\n" % alert
            print(alert, file=alerts)

    if python_ok:
        from dependencies.get_tag import get_tag

        final_report += textwrap.dedent(
            """\
            OpenLane Git Version: %s
        """
            % get_tag()
        )

    click_ok = True
    try:
        import click  # noqa F401
    except ImportError:
        click_ok = False

    alert = (
        "pip:click: " + "INSTALLED"
        if click_ok
        else "NOT FOUND: python3 -m pip install click"
    )
    final_report += "%s\n" % alert
    print(alert, file=alerts)

    yaml_ok = True
    try:
        import yaml  # noqa F401
    except ImportError:
        yaml_ok = False

    alert = (
        "pip:pyyaml: " + "INSTALLED"
        if yaml_ok
        else "NOT FOUND: python3 -m pip install pyyaml"
    )
    final_report += "%s\n" % alert
    print(alert, file=alerts)

    venv_ok = True
    try:
        import venv  # noqa F401
    except ImportError:
        venv_ok = False

    alert = (
        "pip:venv: " + "INSTALLED"
        if venv_ok
        else "NOT FOUND: needed for containerless installs"
    )
    final_report += "%s\n" % alert
    print(alert, file=alerts)

    if python_ok:
        from dependencies.verify_versions import verify_versions

        with io.StringIO() as f:
            status = "OK"
            try:
                mismatches = verify_versions(no_tools=True, report_file=f)
                if mismatches:
                    status = "MISMATCH"
            except Exception:
                status = "FAILED"
                f.write("Failed to compare PDKs.")
                f.write("\n")
            final_report += "---\nPDK Version Verification Status: %s\n%s" % (
                status,
                f.getvalue(),
            )

        try:
            git_log = subprocess.check_output(
                [
                    "git",
                    "log",
                    r"--format=%h %cI %s - %an - %gs (%D)",
                    "-n",
                    "3",
                ]
            ).decode("utf8")

            final_report += "---\nGit Log (Last 3 Commits)\n\n" + git_log
        except subprocess.CalledProcessError:
            pass

    print(final_report, end="")


# Entry Point
def main():
    args = sys.argv[1:]
    commands = {
        "tool-list": tool_list,
        "local-install": local_install,
        "docker-config": docker_config,
        "issue-survey": issue_survey,
    }

    if len(args) < 1 or args[0] not in commands.keys():
        print(
            "Usage: %s (%s)" % (sys.argv[0], "|".join(commands.keys())), file=sys.stderr
        )
        sys.exit(os.EX_USAGE)

    commands[args[0]]()


if __name__ == "__main__":
    main()
