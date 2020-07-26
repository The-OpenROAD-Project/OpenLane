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
FROM centos:centos6 as build


# install gcc 7
RUN yum -y install centos-release-scl && \
    yum -y install devtoolset-7 devtoolset-7-libatomic-devel
ENV CC=/opt/rh/devtoolset-7/root/usr/bin/gcc \
    CPP=/opt/rh/devtoolset-7/root/usr/bin/cpp \
    CXX=/opt/rh/devtoolset-7/root/usr/bin/g++ \
    PATH=/opt/rh/devtoolset-7/root/usr/bin:$PATH \
    LD_LIBRARY_PATH=/opt/rh/devtoolset-7/root/usr/lib64:/opt/rh/devtoolset-7/root/usr/lib:/opt/rh/devtoolset-7/root/usr/lib64/dyninst:/opt/rh/devtoolset-7/root/usr/lib/dyninst:/opt/rh/devtoolset-7/root/usr/lib64:/opt/rh/devtoolset-7/root/usr/lib:$LD_LIBRARY_PATH

# python 3.6
RUN yum -y install rh-python36
ENV PATH=/opt/rh/rh-python36/root/usr/bin:$PATH


# install other yosys dependencies
RUN yum install -y flex tcl tcl-devel libffi-devel git graphviz readline-devel glibc-static

# Updating new bison 3+
# https://github.com/YosysHQ/yosys/issues/332
RUN yum install -y wget autoconf && \
    wget https://ftp.gnu.org/gnu/bison/bison-3.0.1.tar.gz && \
    tar -xvzf bison-3.0.1.tar.gz && \
    cd bison-3.0.1 && \
    ./configure && \
    make -j$(nproc) && \
    make install

# download public key for github.com
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

# git clone yosys
RUN git clone https://github.com/The-OpenROAD-Project/yosys.git yosys

# build yosys
WORKDIR yosys

RUN make PREFIX=/build config-gcc-static-tcl-dynamic
RUN make PREFIX=/build -j$(nproc)
RUN make PREFIX=/build install

RUN mkdir /build/version

RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/yosys.version
RUN git rev-parse HEAD >> /build/version/yosys.version
RUN tar -czf /build.tar.gz /build
