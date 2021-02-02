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
FROM centos:centos7 as build

RUN yum groupinstall -y "Development Tools"
RUN yum -y install centos-release-scl && \
    yum -y install curl libffi-devel readline-devel tcl tcl-devel graphviz xdot

RUN yum -y install bison flex gawk git zlib-devel

# Install dev and runtime dependencies
RUN yum -y install devtoolset-8 devtoolset-8-libatomic-devel

ENV CC=/opt/rh/devtoolset-8/root/usr/bin/gcc \
    CPP=/opt/rh/devtoolset-8/root/usr/bin/cpp \
    CXX=/opt/rh/devtoolset-8/root/usr/bin/g++ \
    PATH=/opt/rh/devtoolset-8/root/usr/bin:$PATH \
    LD_LIBRARY_PATH=/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib:/opt/rh/devtoolset-8/root/usr/lib64/dyninst:/opt/rh/devtoolset-8/root/usr/lib/dyninst:/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib:$LD_LIBRARY_PATH





RUN yum install -y https://repo.ius.io/ius-release-el7.rpm
RUN yum install -y python36u python36u-pip
RUN alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 60


# https://github.com/YosysHQ/yosys/issues/332
RUN yum install -y wget autoconf && \
    wget https://ftp.gnu.org/gnu/bison/bison-3.0.1.tar.gz && \
    tar -xvzf bison-3.0.1.tar.gz && \
    cd bison-3.0.1 && \
    ./configure && \
    make -j$(nproc) && \
    make install

# git clone yosys
ARG YOSYS_REPO=https://github.com/YosysHQ/yosys
ARG YOSYS_COMMIT=84e9fa764803e93c59aff9f10bcc1a5ae2f9f120
RUN git clone ${YOSYS_REPO} yosys
WORKDIR yosys
RUN git checkout ${YOSYS_COMMIT}


RUN make PREFIX=/build config-gcc \
 && make PREFIX=/build -j$(nproc) \
 && make PREFIX=/build install


RUN mkdir -p /build/version
RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/yosys.version
RUN git rev-parse HEAD >> /build/version/yosys.version
RUN tar -czf /build.tar.gz /build
