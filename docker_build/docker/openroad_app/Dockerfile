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

FROM centos:centos7 AS base-dependencies

# Install Development Environment
RUN yum groupinstall -y "Development Tools"
RUN yum group install -y "Development Tools" \
    && yum install -y https://repo.ius.io/ius-release-el7.rpm \
    && yum install -y centos-release-scl \
    && yum install -y wget devtoolset-8 \
    devtoolset-8-libatomic-devel tcl-devel tcl tk libstdc++ tk-devel pcre-devel \
    python36u python36u-libs python36u-devel python36u-pip && \
    yum clean -y all && \
    rm -rf /var/lib/apt/lists/*

# centos7 doesn't set the PATH automatically for the installed gcc from dev tools
ENV CC=/opt/rh/devtoolset-8/root/usr/bin/gcc \
    CPP=/opt/rh/devtoolset-8/root/usr/bin/cpp \
    CXX=/opt/rh/devtoolset-8/root/usr/bin/g++ \
    PATH=/opt/rh/devtoolset-8/root/usr/bin:$PATH \
    LD_LIBRARY_PATH=/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib:/opt/rh/devtoolset-8/root/usr/lib64/dyninst:/opt/rh/devtoolset-8/root/usr/lib/dyninst:/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib:$LD_LIBRARY_PATH

# install cmake
RUN wget https://cmake.org/files/v3.14/cmake-3.14.0-Linux-x86_64.sh && \
    chmod +x cmake-3.14.0-Linux-x86_64.sh  && \
    ./cmake-3.14.0-Linux-x86_64.sh --skip-license --prefix=/usr/local && rm -rf cmake-3.14.0-Linux-x86_64.sh \
    && yum clean -y all

# update bison
RUN yum -y remove bison
RUN wget https://ftp.gnu.org/gnu/bison/bison-3.0.5.tar.gz && \
    tar -xvzf bison-3.0.5.tar.gz
RUN cd bison-3.0.5 && \
    ./configure --prefix=/usr && \
    make -j$(nproc) && \
    make install


# install epel repo
RUN wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum install -y epel-release-latest-7.noarch.rpm && rm -rf epel-release-latest-7.noarch.rpm  \
    && yum clean -y all

# Install dev and runtime dependencies
# Tcl 8.5
RUN yum install -y tcl-devel tcl tk libstdc++ tk-devel

# build boost
RUN wget https://sourceforge.net/projects/boost/files/boost/1.72.0/boost_1_72_0.tar.bz2/download && \
    tar -xf download && \
    cd boost_1_72_0 && \
    ./bootstrap.sh && \
    ./b2 install --with-iostreams --with-test -j $(nproc)

# Install SWIG
RUN yum remove -y swig \
    && yum install -y pcre-devel \
    && wget https://github.com/swig/swig/archive/rel-4.0.1.tar.gz \
    && tar xfz rel-4.0.1.tar.gz \
    && rm -rf rel-4.0.1.tar.gz \
    && cd swig-rel-4.0.1 \
    && ./autogen.sh && ./configure --prefix=/usr && make -j $(nproc) && make install \
    && cd .. \
    && rm -rf swig-rel-4.0.1

RUN yum -y install zlib-devel



# eigen required by replace, TritonMacroPlace
RUN git clone https://gitlab.com/libeigen/eigen.git --branch=3.3 \
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


RUN yum install -y gettext-devel help2man texinfo \
    && git clone https://github.com/westes/flex \
    && cd flex \
    && git checkout v2.6.4 \
    && ./autogen.sh \
    && ./configure \
    && make -j $(nproc) \
    && yum remove -y flex \
    && make install -j $(nproc) \
    && cd - \
    && rm -rf flex

# spdlog required by OpenDB
RUN git clone -b v1.8.1 https://github.com/gabime/spdlog.git \
    && cd spdlog \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make install -j

ARG OPENROAD_APP_REPO=https://github.com/The-OpenROAD-Project/OpenROAD
ARG OPENROAD_APP_COMMIT=1415572a73d43dfc91ba4501170fe6a245729e87
RUN git clone --recursive ${OPENROAD_APP_REPO} OpenROAD_10012020
WORKDIR /OpenROAD_10012020/
RUN git checkout ${OPENROAD_APP_COMMIT}
RUN git submodule update --init --recursive

COPY rails.patch /OpenROAD_10012020/
RUN git apply rails.patch

COPY setup_local.patch /OpenROAD_10012020/src/OpenDB/src/swig/python
RUN cd /OpenROAD_10012020/src/OpenDB/src/swig/python && git apply setup_local.patch

COPY pdngen_export_subst.patch /OpenROAD_10012020/
RUN git apply pdngen_export_subst.patch

COPY ignore_obs_outside.patch /OpenROAD_10012020/
RUN git apply ignore_obs_outside.patch

COPY opendp-diamond-search.patch /OpenROAD_10012020/
RUN git apply opendp-diamond-search.patch

# Build OpenROAD
RUN mkdir build && mkdir -p /build/version && mkdir install
RUN cd build && cmake -DCMAKE_INSTALL_PREFIX=$(pwd)/install .. && make -j$(nproc)
RUN cd build && make install
RUN cp -r build/install/bin /build/

# OpenDB Python interface
WORKDIR src/OpenDB
RUN mkdir build && mkdir -p /build/version && mkdir install
RUN cd build && cmake -DCMAKE_CXX_STANDARD=17 -DCMAKE_INSTALL_PREFIX=$(pwd)/install .. && make -j$(nproc) opendbpy
RUN cp -r build/src/swig/python /build/OpenDB_python
WORKDIR /OpenROAD_10012020/

RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/openroad.version
RUN git rev-parse HEAD >> /build/version/openroad.version
RUN tar -czf /build.tar.gz /build
