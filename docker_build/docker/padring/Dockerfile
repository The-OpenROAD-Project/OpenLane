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


# install gcc 7
RUN yum -y install centos-release-scl && \
    yum -y install curl libffi-devel readline-devel tcl tcl-devel graphviz xdot && \
    yum -y install bison flex gawk gcc git glibc-static zlib-devel

# python
RUN yum -y install rh-python35
SHELL ["/usr/bin/scl", "enable", "rh-python35"]

RUN yum -y install devtoolset-7 devtoolset-7-libatomic-devel
ENV CC=/opt/rh/devtoolset-7/root/usr/bin/gcc \
    CPP=/opt/rh/devtoolset-7/root/usr/bin/cpp \
    CXX=/opt/rh/devtoolset-7/root/usr/bin/g++ \
    PATH=/opt/rh/devtoolset-7/root/usr/bin:$PATH \
    LD_LIBRARY_PATH=/opt/rh/devtoolset-7/root/usr/lib64:/opt/rh/devtoolset-7/root/usr/lib:/opt/rh/devtoolset-7/root/usr/lib64/dyninst:/opt/rh/devtoolset-7/root/usr/lib/dyninst:/opt/rh/devtoolset-7/root/usr/lib64:/opt/rh/devtoolset-7/root/usr/lib:$LD_LIBRARY_PATH


RUN yum install -y wget && \
	wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
	yum install -y epel-release-latest-7.noarch.rpm && \
	yum -y install ninja-build

# Install CMake
RUN wget https://cmake.org/files/v3.14/cmake-3.14.0-Linux-x86_64.sh && \
    chmod +x cmake-3.14.0-Linux-x86_64.sh  && \
    ./cmake-3.14.0-Linux-x86_64.sh --skip-license --prefix=/usr/local

RUN git clone https://github.com/ax3ghazy/padring \
	&& cd padring \
        && git checkout a88faf5a4faef75ff241276599fef81c3653cb70


WORKDIR padring

RUN ./bootstrap.sh && cd build/ && ninja-build && mkdir /build/bin/ -p && cp padring /build/bin

RUN mkdir -p /build/version
RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/padring.version
RUN git rev-parse HEAD >> /build/version/padring.version
RUN tar -czf /build.tar.gz /build
