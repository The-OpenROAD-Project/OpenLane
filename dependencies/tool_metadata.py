from typing import OrderedDict

class Tool(object):
    map: OrderedDict[str, 'Tool'] = {}

    def __init__(self, name, repo=None, commit=None, install_command="make && make install", skip=False, clone_depth=None):
        self.name = name
        self.repo = repo
        self.commit = commit
        self.install_command = install_command
        self.skip = skip
        self.clone_depth = str(clone_depth)
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
        python2.7 scripts/build.py -o release &&\
        cp run/iccad19gr $PREFIX/bin/cugr\
    ",
    skip=True
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
        python2.7 scripts/build.py -o release &&\
        cp run/ispd19dr $PREFIX/bin/drcu\
    ",
    skip=True
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
    "opendp",
    install_command="\
        mkdir -p ./build &&\
        cd ./build &&\
        cmake  -DCMAKE_INSTALL_PREFIX=$PREFIX .. &&\
        make -j$(nproc) &&\
        make install\
    "
)

Tool(
    # This is temporary until Openlane works with newer versions of OR.
    "opendbpy",
    install_command="\
        mkdir -p ./src/OpenDB/build &&\
        cd ./src/OpenDB/build &&\
        cmake -DCMAKE_CXX_FLAGS=-I/usr/include/tcl .. &&\
        make -j$(nproc) &&\
        cd ./src/swig/python &&\
        cp _opendbpy.so $PREFIX &&\
        cp opendbpy.py $PREFIX\
    ",
    clone_depth=1
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
    "opensta",
    install_command="\
        mkdir -p ./build &&\
        cd ./build &&\
        cmake -DCMAKE_INSTALL_PREFIX=$PREFIX/bin .. &&\
        make -j$(nproc) &&\
        cp ../app/sta $PREFIX/bin\
    "
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
    "tritonroute",
    install_command="\
        mkdir -p build &&\
        cd build &&\
        cmake .. &&\
        make -j$(nproc) &&\
        cp TritonRoute $PREFIX/bin\
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