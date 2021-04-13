# vim: et:sw=4:sts=4
# Copyright 2020 Efabless Corporation
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

# syntax = docker/dockerfile:1.0-experimental

FROM centos:centos8 as base

RUN yum -y install dnf-plugins-core centos-release-stream
RUN yum config-manager --set-enabled powertools
RUN yum install -y epel-release

RUN yum -y install \
        autoconf \
        automake \
        binutils \
        bison \
        byacc \
        bzip2 \
        cairo-devel \
        cmake \
        csh \
        curl \
	diffutils \
        gcc-8.3.1-5.1.el8 \
        gcc-c++-8.3.1-5.1.el8 \
        flex \
        gawk \
        gdb \
        gettext \
        git \
        graphviz \
        libtool-ltdl \
	libstdc++-static \
        make \
        ninja-build \
        libX11-devel \
	libarchive \
        libffi-devel \
        ncurses-devel \
        pcre-devel \
        python36 \
        python36-devel \
        readline-devel \
        strace \
        swig \
        tcl \
        tcl-devel \
        tk \
        tk-devel \
        wget \
        which \
        zlib-devel
RUN yum -y clean all

COPY docker/stamp.sh /


################# Boost and SWIG ###################
FROM base AS boost_base

RUN wget https://dl.bintray.com/boostorg/release/1.72.0/source/boost_1_72_0.tar.bz2
RUN tar -xf /boost_1_72_0.tar.bz2 && \
    cd boost_1_72_0 && \
    ./bootstrap.sh && \
    ./b2 install --with-iostreams --with-test --with-system --with-filesystem --with-program_options --link=shared -j $(nproc) && \
    cd .. && \
    rm -rf boost_1_72.0

#RUN wget https://github.com/swig/swig/archive/rel-4.0.1.tar.gz
#RUN tar xfz rel-4.0.1.tar.gz \
#    && rm -rf rel-4.0.1.tar.gz \
#    && cd swig-rel-4.0.1 \
#    && ./autogen.sh \
#    && ./configure --prefix=/usr && make -j $(nproc) \
#    && make install \
#    && cd .. \
#    && rm -rf swig-rel-4.0.1


######### Antmicro's Yosys staging tree ###########

FROM base as antmicro_yosys
RUN git clone https://github.com/antmicro/yosys yosys && \
    cd yosys && \
    git checkout fe58e937ef87fdb157dd89c365bb6a570fe616ea

WORKDIR yosys
RUN make PREFIX=/build/antmicro config-gcc && \
    make PREFIX=/build/antmicro -j 2  && \
    make PREFIX=/build/antmicro install

RUN /stamp.sh antmicro_yosys


####################### static libdef, liblef and spdlog ########################
FROM boost_base AS deflef
RUN yum -y install vim-common glibc-static spdlog-devel

#Dependencies - libdef, liblef
RUN git clone https://github.com/The-OpenROAD-Project/OpenDB.git && \
    cd OpenDB && \
    git checkout 32c13c6cd6894066b086356a7ff1f97894cafefb
WORKDIR OpenDB
RUN mkdir build && \
    mkdir /build

RUN cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=release && \
    make -j $(nproc) && \
    make install 

####################### CUGR ########################
FROM deflef as cugr
RUN git clone https://github.com/ax3ghazy/cu-gr cugr \
       && cd cugr \
       && git checkout 1632b4b450cbd3e5b6bdc9bf92c96cadde6a01b9

WORKDIR cugr

RUN python3 scripts/build.py -o release --cmake_options="-DBoost_NO_BOOST_CMAKE=ON"

RUN mkdir -p /build/bin/ && \
    cp run/iccad19gr /build/bin/cugr

RUN /stamp.sh cugr


####################### CVC ########################
FROM base AS cvc

RUN git clone https://github.com/pyinstaller/pyinstaller.git pyinstaller
WORKDIR pyinstaller/bootloader
RUN python3 ./waf all
WORKDIR /pyinstaller
RUN python3 setup.py install

COPY docker/cvc/cvc-1.0.0.tar.gz cvc-1.0.0.tar.gz
RUN tar -xvf cvc-1.0.0.tar.gz
WORKDIR cvc-1.0.0
RUN ./configure --disable-nls --prefix=/build && \
    make install

####################### DRCU ########################
FROM deflef AS drcu

RUN yum -y install glibc-static spdlog-devel

RUN git clone https://github.com/cuhk-eda/dr-cu drcu_18012021

WORKDIR drcu_18012021

RUN git checkout 427b4a4f03bb98d8a78b1712fe9e52cfb83a8347

RUN python3 scripts/build.py -o release

RUN mkdir -p /build/bin/ && \
    cp run/ispd19dr /build/bin/drcu

RUN /stamp.sh drcu


############### Oh oh oh, its Magic ################
FROM base AS magic
RUN yum install -y mesa-libGLU-devel cairo-devel
ARG MAGIC_REPO=git://opencircuitdesign.com/magic
ARG MAGIC_COMMIT=f7820ed960a0d8a891ba4040d3b37086cd0879f8
RUN git clone git://opencircuitdesign.com/magic magic

WORKDIR magic
RUN git checkout $MAGIC_COMMIT

RUN ./configure --prefix=/build && \
    make -j$(nproc) && \
    make install

RUN /stamp.sh magic


##################### Netgen #######################
FROM base AS netgen
ARG NETGEN_REPO=git://opencircuitdesign.com/netgen
ARG NETGEN_COMMIT=402e1f0f254c6c0cf36c90ff5d6a09134b9196ba
RUN git clone $NETGEN_REPO netgen
WORKDIR netgen
RUN git checkout $NETGEN_COMMIT

RUN ./configure CFLAGS="-O2 -g" --prefix=/build
RUN make clean && \
    make && \
    make install

RUN /stamp.sh netgen


##################### OpenDP #######################
FROM base AS opendp

RUN git clone --recursive https://github.com/kareefardi/OpenDP
RUN mkdir /OpenDP/build
WORKDIR /OpenDP/build

RUN cmake .. && \
    make && \
    make install && \
    mkdir -p /build/bin/ && \
    cp opendp /build/bin

RUN /stamp.sh opendp


##################### OpenPhySyn #######################
FROM boost_base AS openphysyn

RUN git clone https://github.com/scale-lab/OpenPhySyn.git && \
    cd OpenPhySyn && \
    git checkout 6bb80c5f9312a302b7c29cf1a4ddb93ace47d122 && \
    git submodule update --init --recursive

WORKDIR OpenPhySyn
COPY docker/openphysyn/*.patch .
RUN cd external/OpenDB && git apply ../../opendb.cmake.patch
RUN cd external/OpenSTA/ && git apply ../../opensta.cmake.patch


RUN mkdir build && \
    mkdir /build

RUN cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=release && \
    make -j $(nproc) && \
    make install 

RUN mkdir /build/bin && \
    cp /usr/local/bin/Psn /build/bin/

RUN /stamp.sh openphysyn


##################### OpenROAD #######################
FROM boost_base AS openroad_app

RUN yum -y install spdlog-devel

RUN git clone https://gitlab.com/libeigen/eigen.git \
    && cd eigen \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make install

RUN cd / && wget http://lemon.cs.elte.hu/pub/sources/lemon-1.3.1.tar.gz \
    && tar -xf lemon-1.3.1.tar.gz \
    && cd lemon-1.3.1 \
    && cmake -B build . \
    && cmake --build build -j $(nproc) --target install

ARG OPENROAD_APP_REPO=https://github.com/The-OpenROAD-Project/OpenROAD
ARG OPENROAD_APP_COMMIT=1415572a73d43dfc91ba4501170fe6a245729e87
RUN git clone $OPENROAD_APP_REPO
WORKDIR /OpenROAD/
RUN git checkout $OPENROAD_APP_COMMIT && \
    git submodule update --init --recursive

COPY docker/openroad_app/rails.patch /OpenROAD/
RUN git apply rails.patch

COPY docker/openroad_app/setup_local.patch /OpenROAD/src/OpenDB/src/swig/python
RUN cd /OpenROAD/src/OpenDB/src/swig/python && git apply setup_local.patch

COPY docker/openroad_app/pdngen_export_subst.patch /OpenROAD/
RUN git apply pdngen_export_subst.patch

COPY docker/openroad_app/ignore_obs_outside.patch /OpenROAD/
RUN git apply ignore_obs_outside.patch

# Build OpenROAD
RUN mkdir build && mkdir -p /build/version && mkdir install
RUN cd build && cmake -DCMAKE_INSTALL_PREFIX=$(pwd)/install .. && make -j$(nproc)
RUN cd build && make install
RUN cp -r build/install/bin /build/

# OpenDB Python interface
WORKDIR src/OpenDB
RUN mkdir build && mkdir -p /build/version && mkdir install
RUN cd build && cmake -DCMAKE_INSTALL_PREFIX=$(pwd)/install .. && make -j$(nproc) opendbpy
RUN cp -r build/src/swig/python /build/OpenDB_python
RUN cd /build/OpenDB_python && \
    python3 setup.py install --prefix=/build && \
    rm -rf /build/OpenDB_python
WORKDIR /OpenROAD/

RUN /stamp.sh openroad_app


##################### OpenSTA #######################
FROM boost_base AS opensta

# download CUDD
RUN wget https://www.davidkebo.com/source/cudd_versions/cudd-3.0.0.tar.gz && \
    tar -xvf cudd-3.0.0.tar.gz && \
    cd cudd-3.0.0 && \
    ./configure && \
    make && \
    make install

RUN git clone https://github.com/The-OpenROAD-Project/OpenSTA
WORKDIR OpenSTA
RUN git checkout 6deaf6d8fcabc884063941c3046eb8bdb80061b5

RUN mkdir /build
RUN mkdir build
WORKDIR build
RUN cmake -DCMAKE_INSTALL_PREFIX=/build -DCUDD=/usr/local .. && \
    make -j$(nproc) && \
    mkdir -p /build/bin/ && \
    cp ../app/sta /build/bin

RUN /stamp.sh opensta


##################### padring #######################
FROM base as padring

RUN git clone https://github.com/ax3ghazy/padring && \
    cd padring && \
    git checkout a88faf5a4faef75ff241276599fef81c3653cb70


WORKDIR padring

RUN ./bootstrap.sh && \
    cd build/ && \
    ninja-build && \
    mkdir -p /build/bin/ && \
    cp padring /build/bin

RUN /stamp.sh padring


##################### RePlAce #######################
FROM boost_base AS replace

RUN yum install -y \
        ImageMagick \
        ImageMagick-devel \
        ctags \
        glibc-static \
        gmp-devel \
        libjpeg-turbo-static \
        libmpc-devel \
        libtool-ltdl \
        mpfr-devel \
        zlib-static
RUN yum -y clean all

RUN git clone https://github.com/The-OpenROAD-Project/RePlAce && \
    cd RePlAce && \
    git checkout 950b5df4ea6a70fcfb1d496e85cfa63bdd172499 && \
    git submodule update --init --recursive

RUN mkdir RePlAce/build
WORKDIR RePlAce/build

RUN cmake .. && \
    make -j$(nproc) && \
    mkdir -p /build/bin/ && \
    cp /RePlAce/build/replace /build/bin/replace

RUN /stamp.sh replace


##################### TritonRoute #######################
FROM boost_base as route

RUN git clone https://github.com/The-OpenROAD-Project/TritonRoute.git TritonRoute \
    && cd TritonRoute\
    && git checkout a639a8b8c99fb078057d8449aa57333952b06309

RUN mkdir TritonRoute/build

WORKDIR TritonRoute/build

RUN cmake ../ && \
    make && \
    mkdir -p /build/bin/ && \
    cp TritonRoute /build/bin/TritonRoute


RUN /stamp.sh route


##################### vlog2Verilog #######################
FROM base AS vlog2verilog

RUN git clone https://github.com/RTimothyEdwards/qflow
WORKDIR qflow
RUN git checkout a550469b63e910ede6e3022e2886bca96462c540

RUN ./configure && \
    cd src && \
    make vlog2Verilog && \
    mkdir -p /build/bin && \
    cp /qflow/src/vlog2Verilog /build/bin/

RUN /stamp.sh vlog2Verilog


##################### yosys #######################
FROM base AS yosys

ARG YOSYS_REPO=https://github.com/YosysHQ/yosys
ARG YOSYS_COMMIT=84e9fa764803e93c59aff9f10bcc1a5ae2f9f120
RUN git clone $YOSYS_REPO yosys && \
    cd yosys && \
    git checkout $YOSYS_COMMIT

WORKDIR yosys

RUN make PREFIX=/build config-gcc \
 && make PREFIX=/build -j 2 \
 && make PREFIX=/build install

RUN /stamp.sh yosys
RUN ls -lR /build

##################### klayout #######################
FROM base AS klayout

# install klayout
RUN yum install -y qt5-devel ccache
RUN git config --global http.postBuffer 524288000
RUN git clone https://github.com/KLayout/klayout.git && \
    cd klayout && \
    git checkout v0.26.9-2

WORKDIR klayout
RUN mkdir -p /build/lib /build/bin
RUN QMAKE_CCACHE=1 ./build.sh -rpath /usr/local/lib/ -bin /build/bin -option "-j$(nproc)" 
RUN mv /build/bin/lib*.so* /build/lib

RUN /stamp.sh klayout


############## combined tools image #################
FROM base AS tools

RUN yum -y install stow
RUN mkdir -p /usr/local/stow
WORKDIR /usr/local/stow
COPY --from=replace         /build /usr/local/stow/replace
COPY --from=opendp          /build /usr/local/stow/opendp
COPY --from=route           /build /usr/local/stow/route
COPY --from=opensta         /build /usr/local/stow/opensta
COPY --from=yosys           /build /usr/local/stow/yosys
COPY --from=antmicro_yosys  /build /usr/local/stow/antmicro_yosys
COPY --from=magic           /build /usr/local/stow/magic
COPY --from=openroad_app    /build /usr/local/stow/openroad_app
COPY --from=padring         /build /usr/local/stow/padring
COPY --from=netgen          /build /usr/local/stow/netgen
COPY --from=vlog2verilog    /build /usr/local/stow/vlog2verilog
COPY --from=openphysyn      /build /usr/local/stow/openphysyn
COPY --from=cvc             /build /usr/local/stow/cvc
COPY --from=cugr            /build /usr/local/stow/cugr
COPY --from=klayout         /build /usr/local/stow/klayout
COPY --from=drcu            /build /usr/local/stow/drcu
RUN stow --override='.*' replace
RUN stow --override='.*' opendp
RUN stow --override='.*' route
RUN stow --override='.*' opensta
RUN stow --override='.*' yosys
RUN stow --override='.*' antmicro_yosys
RUN stow --override='.*' magic
RUN stow --override='.*' openroad_app
RUN stow --override='.*' padring
RUN stow --override='.*' netgen
RUN stow --override='.*' vlog2verilog
RUN stow --override='.*' openphysyn
RUN stow --override='.*' cvc
RUN stow --override='.*' cugr
RUN stow --override='.*' klayout
RUN stow --override='.*' drcu

##################### openlane #######################

FROM tools as openlane

RUN yum install -y \
        Xvfb \
        libXext \
        libXft \
        libjpeg-devel \
        libgomp-8.3.1-5.1.el8 \
        mesa-libGLU-devel \
        spdlog \
        tcllib \
        patch \
        qt5-qttools-libs-designer \
        qt5-qtmultimedia \
        qt5-qtsvg \
        qt5-qtxmlpatterns

RUN yum -y clean all

RUN pip3 install --no-cache-dir Cython
RUN pip3 install --no-cache-dir numpy==1.19.3
RUN pip3 install --no-cache-dir \
        install \
        jinja2 \
        matplotlib \
        pandas \
        XlsxWriter

ENV OPENLANE_ROOT=/openLANE_flow
ENV OPENROAD=/build

ENV PATH=$OPENLANE_ROOT:$OPENLANE_ROOT/scripts:$OPENROAD/bin:$OPENROAD/bin/Linux-x86_64:$OPENROAD/pdn/scripts:$PATH
ENV LD_LIBRARY_PATH=$OPENROAD/lib:$LD_LIBRARY_PATH
ENV MANPATH=$OPENROAD/share/man:$MANPATH

COPY docker/tclshrc /.tclshrc
COPY docker/tclshrc /root/.tclshrc
COPY . $OPENLANE_ROOT

WORKDIR $OPENLANE_ROOT


