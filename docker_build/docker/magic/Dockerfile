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

# Common development tools and libraries (kitchen sink approach)
RUN yum groupinstall -y "Development Tools"
RUN yum -y install centos-release-scl && \
    yum -y install devtoolset-8 devtoolset-8-libatomic-devel

# python 3.6
RUN yum install -y https://repo.ius.io/ius-release-el7.rpm
RUN yum install -y python36u python36u-libs python36u-devel python36u-pip python36u-tkinter
RUN alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 60

# magic dependencies
RUN yum install -y mesa-libGLU-devel csh wget tcl-devel tk-devel libX11-devel cairo-devel ncurses-devel

# git clone magic components
# Upstream is git://opencircuitdesign.com/magic, but servers are not stable enough for CI.
ARG MAGIC_REPO=https://github.com/rtimothyedwards/magic
ARG MAGIC_COMMIT=39630ea710d85bddab8f43b94c4bd48f0256c2c9
RUN git clone ${MAGIC_REPO} magic_21012020

WORKDIR magic_21012020

RUN git checkout ${MAGIC_COMMIT}

# build
RUN ./configure --prefix=/build && \
    make -j$(nproc) && \
    make install

RUN mkdir -p /build/version/

RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/magic.version
RUN git rev-parse HEAD >> /build/version/magic.version
RUN tar -czf /build.tar.gz /build
