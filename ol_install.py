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

import os
import re
import sys
import uuid
import glob
import argparse
import subprocess
from os.path import join, abspath, dirname, exists
from typing import Tuple, Union, List

from dependencies.tool import Tool

openlane_dir = dirname(abspath(__file__))
is_root = os.geteuid() == 0
        
class chdir(object):
    def __init__(self, path):
        self.path = path
        self.previous = None

    def __enter__(self):
        self.previous = os.getcwd()
        os.chdir(self.path)

    def __exit__(self, exc_type, exc_value, traceback):
        os.chdir(self.previous)
        if exc_type is not None:
            raise exc_value


envs = []
def input_options(env: str, msg: str, options: List[str]) -> str:
    global envs
    value = None
    env_value = os.getenv(env)
    if env_value is not None and env_value.lower() in options:
        value = env_value
    else:
        options_pretty = [] + options
        options_pretty[0] = f"{options[0].upper()}"
        value = input(f"{msg} [{'/'.join(options_pretty)}] > ")
        if value == "":
            value = options[0]
        while value.lower() not in options:
            value = input(f"Invalid input {value.lower()}, please retry: ")

    value = value.lower()
    envs.append((env, value))
    return value

def input_default(env: str, msg: str, default: str) -> str:
    global envs
    value = None
    env_value = os.getenv(env)
    if env_value is not None:
        value = env_value
    else:
        value = input(f"{msg} [{default}] > ")
        if value == "":
            value = default

    envs.append((env, value))
    return value

def sh(*args: Tuple[str], root: Union[bool, str] = False, **kwargs):
    """
    args: shell arguments to run
    root:
        if False, the command will be executed as-is
        if True, if the user is not root, "sudo" will be added to the command
        if "retry", the command will be executed as-is first, and if it fails,
            it is retried as root.
    """
    args = list(args)
    if root == True and not is_root:
        args = ["sudo"] + args
    try:
        subprocess.run(args, check=True, stderr=subprocess.PIPE if root == "retry" else None, **kwargs)
    except subprocess.CalledProcessError as e:
        if root == "retry":
            args = ["sudo"] + args
            subprocess.run(args, check=True, **kwargs)
        else:
            raise e

def download(url, ext):
    path = f"/tmp/{uuid.uuid4()}.{ext}"
    print(f"{url} -> {path}")
    target = open(path, "wb")
    sh("curl", "-L", url, stdout=target)
    target.close()
    return path

def run_installer():
    tools = Tool.from_metadata_yaml(open("./dependencies/tool_metadata.yml").read())
    if input_options("RISK_ACKNOWLEDGED", "I affirm that I have read LOCAL_INSTALL.md and agree to the outlined risks.", ["n", "y"]) != "y":
        return

    print(f"""\
    DO NOT USE THIS UTILITY BEFORE READING LOCAL_INSTALL.md.

OpenLane Local Installer ALPHA

    Copyright 2021 Efabless Corporation. Available under the Apache License,
    Version 2.0.

    Ctrl+C at any time to quit.

    Note that this installer does *not* handle:
    - Installing OpenROAD to PATH

    You'll have to do these on your own. We hope that you understand the implications of this.

    This version of OpenLane was tested with this version of OpenRoad:

        {tools["openroad_app"].version_string}
    """)

    os_pick = input_options("OS", "Which UNIX/Unix-like OS are you using?", ["ubuntu-20.04", "centos7", "macos", "other"])
    
    gcc_bin = os.getenv("CC") or "gcc"
    gxx_bin = os.getenv("CXX") or "g++"
    try:
        if not os_pick in ["centos7", "macos"]: # The reason we ignore centos7 and macos is that we're going to just use devtoolset-8/gcc anyway.            
            gcc_ver_output = subprocess.run([gcc_bin, "--version"], stdout=subprocess.PIPE)
            gx_ver_output = subprocess.run([gxx_bin, "--version"], stdout=subprocess.PIPE)
            if "clang" in gcc_ver_output.stdout.decode("utf-8") + gx_ver_output.stdout.decode("utf-8"):
                print(f"""
    We've detected that you're using Clang as your default C or C++ compiler.
    Unfortunately, Clang is not compatible with some of the tools being
    installed.

    You may continue this installation at your own risk, but we recommend
    installing GCC.

    You can specify a compiler to use explicitly by invoking this script as
    follows, for example:

        CC=/usr/local/bin/gcc-8 CXX=/usr/local/bin/g++-8 python3 {__file__}

            """)
                input("Press return if you understand the risk and wish to continue anyways >")
    except FileNotFoundError as e:
        print(e, "(set as either CC or CXX)")
        exit(os.EX_CONFIG)

    install_dir = input_default("INSTALL_DIR", "Where do you want to install Openlane?", "/opt/openlane")

    sh("mkdir", "-p", install_dir, root="retry")

    home_perms = os.stat(os.getenv("HOME"))
    sh("chown", "-R", "%i:%i" % (home_perms.st_uid, home_perms.st_gid), install_dir, root="retry")

    pip_action = input_options("PIP_DEPS", "Install PIP dependencies?", ["no", "system", "user"])
    if pip_action != "no":
        python_directory = join(openlane_dir, "dependencies", "python")
        requirements_files = [os.path.join(python_directory, file) for file in os.listdir(python_directory)]
        final_list = []
        for file in requirements_files:
            final_list.append("-r")
            final_list.append(file)

        sh(
            "python3",
            "-m",
            "pip",
            "install",
            *final_list,
            root=pip_action == "system"
        )
   
    install_packages = "no"
    if os_pick != "other":
        install_packages = input_options("INSTALL_PACKAGES", "Do you want to install packages for development?", ["no", "yes"])
    if install_packages != "no":
        def cat_all(dir):
            result = ""
            for file in os.listdir(dir):
                result += open(join(dir, file)).read()
                result += "\n"
            return result
        if os_pick == "macos":
            brew_packages = cat_all(join(openlane_dir, 'dependencies', 'macos')).strip().split("\n")

            sh("brew", "install", *brew_packages)
        if os_pick == "centos7":
            yum_packages = cat_all(join(openlane_dir, 'dependencies', 'centos7')).strip().split("\n") 

            sh("yum", "install", "-y", *yum_packages)
        if os_pick == "ubuntu-20.04":
            raw = cat_all(join(openlane_dir, 'dependencies', 'ubuntu-20.04')).strip().split("\n")

            apt_packages = []
            apt_debs = []

            for entry in raw:
                if entry.startswith("https://"):
                    apt_debs.append(entry)
                else:
                    apt_packages.append(entry)
            sh("apt-get", "update", root=True)
            sh("apt-get", "install", "-y", "curl", root=True)
            for deb in apt_debs:
                path = download(deb, "deb")
                sh("apt-get", "install", "-y", "-f", path, root=True)
            sh("apt-get", "install", "-y", *apt_packages, root=True)

    print("To re-run with the same options: ")
    print(f"{' '.join(['%s=%s' % env for env in envs])} python3 {__file__}")
    
    run_env = os.environ.copy()
    run_env["PREFIX"] = install_dir

    path_elements = ["$PATH", "$OL_DIR/bin"]

    if os_pick == "centos7":
        run_env["CC"] = "/opt/rh/devtoolset-8/root/usr/bin/gcc"
        run_env["CXX"] = "/opt/rh/devtoolset-8/root/usr/bin/g++"
        run_env["PATH"] = f"/opt/rh/devtoolset-8/root/usr/bin:{os.getenv('PATH')}"
        run_env["LD_LIBRARY_PATH"] = f"/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib:/opt/rh/devtoolset-8/root/usr/lib64/dyninst:/opt/rh/devtoolset-8/root/usr/lib/dyninst:/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib:{os.getenv('LD_LIBRARY_PATH')}"
        run_env["CMAKE_INCLUDE_PATH"] = f"/usr/include/boost169:{os.getenv('CMAKE_INCLUDE_PATH')}"
        run_env["CMAKE_LIBRARY_PATH"] = f"/lib64/boost169:{os.getenv('CMAKE_LIBRARY_PATH')}"
    elif os_pick == "macos":
        def get_prefix(tool):
            return subprocess.check_output([
                "brew", "--prefix", tool
            ]).decode('utf8').strip()

        klayout_app_path = input_default("KLAYOUT_MAC_APP", "Please input the path to klayout.app (0.27.3 or later): ", "/Applications/klayout.app")
        klayout_path_element = join(klayout_app_path, "Contents", "MacOS")

        run_env["CC"] = f"{get_prefix('gcc')}/bin/gcc-11"
        run_env["CXX"] = f"{get_prefix('gcc')}/bin/g++-11"
        run_env["PATH"] = f"{get_prefix('swig@3')}/bin:{get_prefix('bison')}/bin:{get_prefix('flex')}/bin:{get_prefix('gnu-which')}/bin:{os.getenv('PATH')}"
        run_env["MAGIC_CONFIG_OPTS"] = f"--with-tcl={get_prefix('tcl-tk')} --with-tk={get_prefix('tcl-tk')}"
        run_env["READLINE_CXXFLAGS"] = f"CXXFLAGS=-L{get_prefix('readline')}/lib"

        path_elements.append(f"{klayout_path_element}")
        path_elements.append(f"{get_prefix('gnu-sed')}/libexec/gnubin")
        path_elements.append(f"{get_prefix('bash')}/bin")
    else:
        run_env["CC"] = gcc_bin
        envs.append(("CC", gcc_bin))
        run_env["CXX"] = gxx_bin
        envs.append(("CXX", gxx_bin))

    def copy(f):
        sh("rm", "-rf", f)
        sh("cp", "-r", join(openlane_dir, f), f)

    def install():
        print("Copying files...")
        for folder in ["bin", "lib", "share", "build", "dependencies"]:
            sh("mkdir", "-p", folder)
        copy("configuration")
        copy("scripts")
        copy("flow.tcl")
        copy("report_generation_wrapper.py")
        copy("dependencies/")

        print("Installing dependencies...")
        with chdir("build"):
            for folder in ["repos", "versions"]:
                sh("mkdir", "-p", folder)
                
            skip_tools = (os.getenv("SKIP_TOOLS") or "").split(':')
            print(skip_tools)
            for tool in tools.values():
                if not tool.in_install:
                    continue
                if tool.name in skip_tools:
                    continue
                installed_version = ""
                version_path = f"versions/{tool.name}"
                try:
                    installed_version = open(version_path).read()
                except:
                    pass
                if installed_version == tool.version_string:
                    print(f"{tool.version_string} already installed, skipping...")
                    continue
                
                print(f"Installing {tool.name}...")
                
                with chdir("repos"):
                    if not exists(tool.name):
                        sh("git", "clone", tool.repo, tool.name)
                    
                    with chdir(tool.name):
                        sh("git", "fetch")
                        sh("git", "submodule", "update", "--init")
                        sh("git", "checkout", tool.commit)
                        subprocess.run([
                            "bash", "-c", tool.build_script
                        ], env=run_env, check=True)

                with open(version_path, "w") as f:
                    f.write(tool.version_string)

        path_elements.reverse()
        with open("openlane", "w") as f:
            f.write(f"""#!/bin/bash
            OL_DIR="$(dirname "$(test -L "$0" && readlink "$0" || echo "$0")")"

            export PATH={":".join(path_elements)}

            FLOW_TCL=${{FLOW_TCL:-$OL_DIR/flow.tcl}}
            FLOW_TCL=$(realpath $FLOW_TCL)

            tclsh $FLOW_TCL $@
            """)
        sh("chmod", "+x", "./openlane")

    with chdir(install_dir):
        install()

    print("Done.")
    print(f"To invoke Openlane from now on, invoke {install_dir}/openlane then pass on the same options you would flow.tcl.")

def main():
    parser = argparse.ArgumentParser(description="OpenLane Local Installer")
    parser.add_argument(
        "--list-tools",
        action='store_true',
        help="List the tools and exit."
    )
    args = parser.parse_args()
    if args.list_tools:
        tools = Tool.from_metadata_yaml(open("./dependencies/tool_metadata.yml").read())
        for tool in tools.values():
            print(f"{tool.name}: {tool.version_string}")
    else:
        run_installer()


if __name__ == "__main__":
    main()
