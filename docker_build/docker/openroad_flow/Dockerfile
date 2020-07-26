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

FROM centos:centos6 AS base-dependencies

# Install Development Environment
RUN yum groupinstall -y "Development Tools"
RUN yum install -y wget git
RUN yum -y install centos-release-scl && \
    yum -y install devtoolset-8 devtoolset-8-libatomic-devel
RUN wget https://cmake.org/files/v3.14/cmake-3.14.0-Linux-x86_64.sh && \
    chmod +x cmake-3.14.0-Linux-x86_64.sh  && \
    ./cmake-3.14.0-Linux-x86_64.sh --skip-license --prefix=/usr/local

# Install epel repo
RUN wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
RUN yum install -y epel-release-latest-6.noarch.rpm

# Install dev and runtime dependencies
RUN yum install -y tcl-devel tcl tk libstdc++ tk-devel 

ENV CC=/opt/rh/devtoolset-8/root/usr/bin/gcc \
    CPP=/opt/rh/devtoolset-8/root/usr/bin/cpp \
    CXX=/opt/rh/devtoolset-8/root/usr/bin/g++ \
    PATH=/opt/rh/devtoolset-8/root/usr/bin:$PATH \
    LD_LIBRARY_PATH=/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib:/opt/rh/devtoolset-8/root/usr/lib64/dyninst:/opt/rh/devtoolset-8/root/usr/lib/dyninst:/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib:$LD_LIBRARY_PATH

# build boost
RUN wget http://downloads.sourceforge.net/project/boost/boost/1.67.0/boost_1_67_0.tar.gz \
    && tar xfz boost_1_67_0.tar.gz \
    && rm -f boost_1_67_0.tar.gz \
    && cd boost_1_67_0 \
    && ./bootstrap.sh --prefix=/usr --with-libraries=program_options,log,filesystem \
    && ./b2 install -j $(nproc) 

# Install python dev
RUN yum install -y https://repo.ius.io/ius-release-el6.rpm
RUN yum install -y python36u python36u-libs python36u-devel python36u-pip
RUN alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 60

RUN yum remove -y swig \
    && yum install -y pcre-devel \
    && wget https://github.com/swig/swig/archive/rel-3.0.12.tar.gz \
    && tar xfz rel-3.0.12.tar.gz \
    && rm -rf rel-3.0.12.tar.gz \
    && cd swig-rel-3.0.12 \
    && ./autogen.sh && ./configure --prefix=/usr && make -j $(nproc) && make install 

RUN yum install -y http://opensource.wandisco.com/centos/6/git/x86_64/wandisco-git-release-6-1.noarch.rpm
RUN yum install -y git 
RUN git clone https://gitlab.com/libeigen/eigen.git /eigen \
    && cd /eigen \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make install
RUN cd / && wget http://lemon.cs.elte.hu/pub/sources/lemon-1.3.1.tar.gz \
    && tar -xf lemon-1.3.1.tar.gz \
    && cd lemon-1.3.1 \
    && cmake -B build . \ 
    && cmake --build build -j $(nproc) --target install

RUN git clone --recursive --branch openroad https://github.com/The-OpenROAD-Project/OpenROAD OpenROAD_14072020
WORKDIR /OpenROAD_14072020/
RUN git checkout d6e0844670b4f8c8cd654258853eb868945c7665 \
	&& git submodule update --init

COPY rails.patch /OpenROAD_14072020/
RUN git apply rails.patch

COPY setup_local.patch /OpenROAD_14072020/src/OpenDB/src/swig/python
RUN cd /OpenROAD_14072020/src/OpenDB/src/swig/python && git apply setup_local.patch

COPY pdn_export_pin.patch /OpenROAD_26052020/
RUN git apply pdn_export_pin.patch

# Build
RUN mkdir build && mkdir -p /build/version && mkdir install
RUN cd build && cmake -DCMAKE_INSTALL_PREFIX=$(pwd)/install .. && make -j$(nproc)
RUN cd build && make install
RUN cp -r build/install/bin /build/


# OpenDB Python interface
WORKDIR src/OpenDB
RUN mkdir build && mkdir -p /build/version && mkdir install
RUN cd build && cmake -DCMAKE_INSTALL_PREFIX=$(pwd)/install .. && make -j$(nproc) opendbpy
RUN cp -r build/src/swig/python /build/OpenDB_python
WORKDIR /OpenROAD_14072020/

RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/openroad.version
RUN git rev-parse HEAD >> /build/version/openroad.version
RUN tar -czf /build.tar.gz /build
