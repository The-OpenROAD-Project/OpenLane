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

# netgen dependencies
RUN yum install -y csh wget tcl-devel tk-devel libX11-devel cairo-devel ncurses-devel

# git clone netgen components
# Upstream is git://opencircuitdesign.com/netgen, but servers are not stable enough for CI.
ARG NETGEN_REPO=https://github.com/rtimothyedwards/netgen
ARG NETGEN_COMMIT=dfabdaa36795bdc55ea604575bb73cf6bc6a8b0e
RUN git clone ${NETGEN_REPO} netgen_21012021

WORKDIR netgen_21012021

RUN git checkout ${NETGEN_COMMIT}


# build
RUN ./configure CFLAGS="-O2 -g" --prefix=/build

RUN make clean && \
    make && \
    make install

RUN mkdir -p /build/version/

RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/netgen.version
RUN git rev-parse HEAD >> /build/version/netgen.version
RUN tar -czf /build.tar.gz /build
