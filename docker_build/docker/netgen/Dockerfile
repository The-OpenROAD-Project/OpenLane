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

# Common development tools and libraries (kitchen sink approach)
RUN yum groupinstall -y "Development Tools" "Development Libraries"
RUN yum -y install centos-release-scl && \
    yum -y install devtoolset-8 devtoolset-8-libatomic-devel

ENV CC=/opt/rh/devtoolset-8/root/usr/bin/gcc \
    CPP=/opt/rh/devtoolset-8/root/usr/bin/cpp \
    CXX="/opt/rh/devtoolset-8/root/usr/bin/g++" \
    PATH=/opt/rh/devtoolset-8/root/usr/bin:$PATH \
    LD_LIBRARY_PATH=/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib:/opt/rh/devtoolset-8/root/usr/lib64/dyninst:/opt/rh/devtoolset-8/root/usr/lib/dyninst:/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib:$LD_LIBRARY_PATH
#

# netgen dependencies
RUN yum install -y csh wget tcl-devel tk-devel libX11-devel cairo-devel ncurses-devel

# git clone netgen components
# RUN git clone https://github.com/RTimothyEdwards/netgen
RUN git clone git://opencircuitdesign.com/netgen netgen_07072020

WORKDIR netgen_07072020

RUN git checkout 18739235a9a1ae901c1bbfed206a9b44ca6a2e97


# build
RUN ./configure --prefix=/build && \
    make -j4 && \
    make install

RUN mkdir -p /build/version/

RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/netgen.version
RUN git rev-parse HEAD >> /build/version/netgen.version
RUN tar -czf /build.tar.gz /build

