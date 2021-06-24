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

from typing import Dict

class Tool(object):
    map: Dict[str, 'Tool'] = {}

    def __init__(self, name, repo=None, commit=None, install_command="make && make install", skip=False, clone_depth=None):
        self.name = name
        self.repo = repo
        self.commit = commit
        self.install_command = install_command
        self.skip = skip
        self.clone_depth = str(clone_depth) if clone_depth is not None else None
        Tool.map[self.name] = self

    @property
    def repo_pretty(self):
        gh_prefix = "https://github.com/"
        repo = self.repo
        if repo is not None and repo.startswith(gh_prefix):
            return repo[len(gh_prefix):]
        return repo

    @property
    def version_string(self):
        return f"{self.repo or 'None'}:{self.commit or 'None'}"

    def __repr__(self) -> str:
        return f"<Tool {self.name} (using {self.repo_pretty or 'None'}@{self.commit or 'None'})>"


Tool(
    "antmicro_yosys",
    install_command="\
        make PREFIX=$PREFIX/antmicro config-gcc &&\
        make PREFIX=$PREFIX/antmicro -j$(nproc) &&\
        make PREFIX=$PREFIX/antmicro install\
    ",
    skip=True
)

Tool(
    "cugr",
    install_command="\
        xxd -i src/flute/POST9.dat > src/flute/POST9.c &&\
        xxd -i src/flute/POWV9.dat > src/flute/POWV9.c &&\
        rm -rf build/ &&\
        mkdir -p build/ &&\
        cd build &&\
        cmake ../src &&\
        make -j$(nproc) &&\
        cp iccad19gr $PREFIX/bin/cugr\
    "
)

Tool(
    "cvc",
    install_command="\
        autoreconf -i &&\
        autoconf &&\
        ./configure --disable-nls --prefix=$PREFIX &&\
        make install\
    "
)

Tool(
    "drcu",
    install_command="\
        rm -rf build/ &&\
        mkdir -p build/ &&\
        cd build &&\
        cmake ../src &&\
        make -j$(nproc) &&\
        cp ispd19dr $PREFIX/bin/drcu\
    "
)

Tool(
    "magic",
    install_command="\
        ./configure --prefix=$PREFIX &&\
        make -j$(nproc) &&\
        make install\
    "
)

Tool(
    "netgen",
    install_command="\
        ./configure --prefix=$PREFIX &&\
        make -j$(nproc) &&\
        make install\
    "
)

Tool(
    "openphysyn",
    install_command="\
        mkdir -p ./build &&\
        cd ./build &&\
        cmake .. &&\
        make -DCMAKE_BUILD_TYPE=release -j$(nproc)&&\
        cp Psn $PREFIX/bin/Psn\
    ",
    skip=True
)

Tool(
    "openroad_app",
    install_command="\
        mkdir -p ./build &&\
        cd ./build &&\
        cmake -DCMAKE_INSTALL_PREFIX=$PREFIX/bin .. &&\
        make -j$(nproc)\
    ",
    skip=True
)

Tool(
    "padring",
    install_command="\
        bash ./bootstrap.sh &&\
        cd build &&\
        ninja &&\
        cp padring $PREFIX/bin\
    "
)

Tool(
    "qflow", # We just want vlog_to_verilog though
    install_command="\
        ./configure &&\
        cd src &&\
        make -j$(nproc) vlog2Verilog &&\
        cp vlog2Verilog $PREFIX/bin\
    "
)

Tool(
    "yosys",
    install_command="\
        make PREFIX=$PREFIX config-gcc &&\
        make PREFIX=$PREFIX -j$(nproc) &&\
        make PREFIX=$PREFIX install\
    "
)