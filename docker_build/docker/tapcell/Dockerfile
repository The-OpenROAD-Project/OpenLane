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

# # install gcc 8
RUN yum -y install centos-release-scl && \
    yum -y install devtoolset-8 devtoolset-8-libatomic-devel
ENV CC=/opt/rh/devtoolset-8/root/usr/bin/gcc \
    CPP=/opt/rh/devtoolset-8/root/usr/bin/cpp \
    CXX=/opt/rh/devtoolset-8/root/usr/bin/g++ \
    PATH=/opt/rh/devtoolset-8/root/usr/bin:$PATH \
    LD_LIBRARY_PATH=/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib:/opt/rh/devtoolset-8/root/usr/lib64/dyninst:/opt/rh/devtoolset-8/root/usr/lib/dyninst:/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib:$LD_LIBRARY_PATH

RUN yum install -y wget git pcre-devel tcl-devel tk-devel vim

RUN wget http://prdownloads.sourceforge.net/swig/swig-4.0.0.tar.gz && \
    tar -xf swig-4.0.0.tar.gz && \
    cd swig-4.0.0 && \
    ./configure && \
    make -j$(nproc) && \
    make install


# download public key for github.com
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN git clone https://github.com/The-OpenROAD-Project/tapcell.git \
	&& cd tapcell \
	&& git checkout 40b174ecdcbf67a6adebda0eb86e22db22e21e77

WORKDIR tapcell

RUN make release

RUN mkdir -p /build/bin/ && \
    cp /tapcell/bin/tapcell /build/bin/

RUN mkdir -p /build/version
RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/tapcell.version
RUN git rev-parse HEAD >> /build/version/tapcell.version
RUN tar -czf /build.tar.gz /build

