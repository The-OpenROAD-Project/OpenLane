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
import re
import os
import sys
import json
import click
import shutil
import pathlib
import tempfile
import subprocess
import urllib.error
import urllib.parse
import urllib.request

SUPPORTED_ARCHITECTURES = {"amd64", "arm64v8", "ppc64le"}
CI_ARCHITECTURES = {"amd64", "arm64v8"}
SUPPORTED_OPERATING_SYSTEMS = {"centos-7"}


def test_manifest_exists(repository: str, tag: str) -> bool:
    try:
        result = subprocess.call(
            ["docker", "manifest", "inspect", f"{repository}:{tag}"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
    except FileNotFoundError as e:
        print(f"docker doesn't appear to be installed: {e}", file=sys.stderr)
        exit(-1)
    return result == 0


@click.group()
def cli():
    pass


@click.command()
@click.option(
    "-r", "--repository", default="ghcr.io/the-openroad-project/openlane-tools"
)
@click.option(
    "-o",
    "--os",
    "operating_system",
    required=True,
    type=click.Choice(SUPPORTED_OPERATING_SYSTEMS),
)
@click.option(
    "-m",
    "--architecture",
    required=True,
    type=click.Choice(SUPPORTED_ARCHITECTURES),
)
@click.argument("tool")
def pull_if_doesnt_exist(repository, operating_system, architecture, tool):
    """
    Requires *actual* Docker. Podman won't cut it.
    """

    def get_tag_for(os, arch=None):
        return (
            subprocess.check_output(
                [
                    "python3",
                    "../dependencies/tool.py",
                    tool,
                    f"--docker-tag-for-os={os}",
                ]
                + ([f"--docker-arch={arch}"] if arch is not None else [])
            )
            .decode("utf8")
            .rstrip()
        )

    image_tag = None
    skip_manifest = None
    if tool == "build-base":
        image_tag = os.getenv("BUILD_BASE_TAG")
        skip_manifest = True
    elif tool == "run-base":
        image_tag = os.getenv("RUN_BASE_TAG")
        skip_manifest = True
    else:
        image_tag = get_tag_for(operating_system, architecture)
        skip_manifest = False

    image = f"{repository}:{image_tag}"
    images = (
        subprocess.check_output(["docker", "images", image])
        .decode("utf8")
        .rstrip()
        .split("\n")[1:]
    )
    if len(images) >= 1:
        print(f"[*] Found {image}.")
        return

    print(f"[*] {image} not found, pulling...")

    if test_manifest_exists(repository, image_tag):
        subprocess.call(["docker", "pull", image])
        print(f"[*] Pulled {image}.")
    else:
        if os.getenv("BUILD_IF_CANT_PULL") != "1":
            print(f"[*] {image} not found in the repository.")
            exit(os.EX_UNAVAILABLE)
        else:
            print(f"[*] {image} not found in the repository, building...")
            env = os.environ.copy()
            env["BUILD_ARCH"] = architecture
            subprocess.check_call(["make", f"build-{tool}"], env=env)
            print(f"Built {image}.")

    if os.getenv("BUILD_IF_CANT_PULL_THEN_PUSH") != "1":
        return

    # Not needed for buildx, but won't hurt
    print(f"[*] Pushing {image} to the container repository...")
    subprocess.check_call(["docker", "push", image])
    print(f"[*] Pushed {image}.")

    if skip_manifest:
        return

    manifest_tag = get_tag_for(operating_system)
    manifest_name = f"{repository}:{manifest_tag}"

    print(f"[*] Trying to create multi-arch manifest {manifest_name}...")
    arch_images = []
    for arch in CI_ARCHITECTURES:
        print(f"[*] Verifying if the image for {arch} has been pushed...")
        arch_image_tag = get_tag_for(operating_system, arch)
        arch_image = f"{repository}:{arch_image_tag}"
        if not test_manifest_exists(repository, arch_image_tag):
            print(f"[*] {arch_image} not yet pushed. Aborting multi-arch manifest.")
            exit(os.EX_OK)
        arch_images.append(arch_image)

    print("[*] All images verified, creating and pushing manifest...")

    subprocess.call(["docker", "manifest", "rm", manifest_name])
    subprocess.check_call(["docker", "manifest", "create", manifest_name, *arch_images])
    subprocess.check_call(
        [
            "docker",
            "manifest",
            "push",
            manifest_name,
        ]
    )

    print("[*] Done.")


cli.add_command(pull_if_doesnt_exist)


@click.command()
@click.option("-r", "--repository", required=True)
@click.option(
    "-o",
    "--os",
    "operating_system",
    required=True,
    type=click.Choice(SUPPORTED_OPERATING_SYSTEMS),
)
@click.argument("tools", nargs=-1)
def process_dockerfile_tpl(repository, operating_system, tools):
    image_tags = [
        (
            subprocess.check_output(
                [
                    "python3",
                    "../dependencies/tool.py",
                    f"--docker-tag-for-os={operating_system}",
                    tool,
                ]
            )
            .decode("utf8")
            .rstrip()
        )
        for tool in tools
    ]

    image_names = [f"{repository}:{tag}" for tag in image_tags]

    from_lines = [
        f"FROM {name}-${{ARCH}} as container{i}" for i, name in enumerate(image_names)
    ]

    copy_lines = [
        f"COPY --from=container{i} /build /build" for i, _ in enumerate(image_names)
    ]

    template = open("./openlane/Dockerfile.tpl").read()

    parts = template.split("# <from>")
    parts.insert(1, "\n".join(from_lines))

    from_filled = "\n".join(parts)

    parts = from_filled.split("# <copy>")
    parts.insert(1, "\n".join(copy_lines))

    final = "\n".join(parts)
    print(final)


cli.add_command(process_dockerfile_tpl)


@click.command()
@click.option(
    "--filter", default=".", help="regular expression to match submodule paths"
)
@click.argument("repository")
@click.argument("commit")
def fetch_submodules_from_tarballs(filter, repository, commit):
    """
    Must be run from inside an extracted repository tarball.

    Given the repository's URL and commit, which are available, a table of the
    git submodules with their repositories, commits and paths is constructed and
    then promptly downloaded and extracted using only the GitHub APIs (and curl),
    no git involved.

    This makes things much faster than having to clone an repo's entire history then
    its submodule's entire history.
    """

    repository_path_info: urllib.parse.SplitResult = urllib.parse.urlsplit(repository)

    # 1. Get Commits Of Submodules
    api_result = None

    try:
        api_result = subprocess.check_output(
            [
                "curl",
                "--fail",
                "-s",
                "-L",
                "-H",
                "Accept: application/vnd.github.v3+json",
                f"https://api.github.com/repos{repository_path_info.path}/git/trees/{commit}?recursive=True",
            ]
        )
    except Exception as e:
        print(e, file=sys.stderr)
        sys.exit(os.EX_DATAERR)

    api_result_parsed = json.loads(api_result)
    api_result_tree = api_result_parsed["tree"]
    submodules = [element for element in api_result_tree if element["type"] == "commit"]
    shas_by_path = {submodule["path"]: submodule["sha"] for submodule in submodules}

    # 2. Get Submodule Manifest
    api_result = None

    try:
        api_result = subprocess.check_output(
            [
                "curl",
                "--fail",
                "-s",
                "-L",
                f"https://raw.githubusercontent.com/{repository_path_info.path}/{commit}/.gitmodules",
            ]
        )
    except Exception as e:
        print(e, file=sys.stderr)
        sys.exit(os.EX_DATAERR)

    gitmodules = api_result.decode("utf8")

    section_line_rx = re.compile(r"\[\s*submodule\s+\"([\w\-\.\/]+)\"\]")
    key_value_line_rx = re.compile(r"(\w+)\s*=\s*(.+)")

    submodules_by_name = {}
    current = {}  # First one is discarded
    for line in gitmodules.split("\n"):
        section_match = section_line_rx.search(line)
        if section_match is not None:
            name = section_match[1]
            submodules_by_name[name] = {}
            current = submodules_by_name[name]

        kvl_match = key_value_line_rx.search(line)
        if kvl_match is not None:
            key, value = kvl_match[1], kvl_match[2]
            current[key] = value

    for name, submodule in submodules_by_name.items():
        submodule["commit"] = shas_by_path.get(submodule["path"])
        if submodule["url"].endswith(".git"):
            submodule["url"] = submodule["url"][:-4]

    # 3. Extract Submodules
    temp_dir = tempfile.gettempdir()
    filter_rx = re.compile(filter, flags=re.I)
    for name, values in submodules_by_name.items():
        path = values["path"]

        if filter_rx.match(path) is None:
            print(f"Skipping {path}...", flush=True)
            continue
        else:
            print(f"Expanding {path}...", flush=True)

        name_fs = re.sub(r"\/", "_", name)
        tarball = os.path.join(temp_dir, f"{name_fs}.tar.gz")

        url = values["url"]
        commit = values["commit"]

        url = os.path.join(url, "tarball", commit)

        print(f"Downloading {url} to {path}...", file=sys.stderr)
        subprocess.check_call(["curl", "-sL", "-o", tarball, url])

        shutil.rmtree(path, ignore_errors=True)

        pathlib.Path(path).mkdir(parents=True, exist_ok=True)

        subprocess.check_call(
            ["tar", "-xzf", tarball, "--strip-components=1", "-C", path]
        )


cli.add_command(fetch_submodules_from_tarballs)


@click.command()
@click.option("-i", "--ignoring", type=str, multiple=True)
@click.argument("sources", nargs=-1)
@click.argument("destination", nargs=1)
def copy_tree(ignoring, sources, destination):
    patterns = shutil.ignore_patterns(*ignoring)
    for source in list(sources):
        if os.path.isfile(source):
            shutil.copy(source, destination)
        elif os.path.isdir(source):
            shutil.copytree(source, destination, ignore=patterns)
        else:
            raise FileNotFoundError(source)


cli.add_command(copy_tree)


if __name__ == "__main__":
    cli()
