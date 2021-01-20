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

# # install gcc 8
RUN yum -y install centos-release-scl && \
    yum -y install devtoolset-8 devtoolset-8-libatomic-devel
ENV CC=/opt/rh/devtoolset-8/root/usr/bin/gcc \
    CPP=/opt/rh/devtoolset-8/root/usr/bin/cpp \
    CXX=/opt/rh/devtoolset-8/root/usr/bin/g++ \
    PATH=/opt/rh/devtoolset-8/root/usr/bin:$PATH \
    LD_LIBRARY_PATH=/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib:/opt/rh/devtoolset-8/root/usr/lib64/dyninst:/opt/rh/devtoolset-8/root/usr/lib/dyninst:/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib:$LD_LIBRARY_PATH

RUN yum install -y git python-devel glibc-static wget bzip2

# Installing cmake for build dependency
RUN wget https://cmake.org/files/v3.14/cmake-3.14.0-Linux-x86_64.sh && \
    chmod +x cmake-3.14.0-Linux-x86_64.sh  && \
    ./cmake-3.14.0-Linux-x86_64.sh --skip-license --prefix=/usr/local

# Installing boost for build dependency
RUN wget https://sourceforge.net/projects/boost/files/boost/1.72.0/boost_1_72_0.tar.bz2/download && \
    tar -xf download
RUN cd boost_1_72_0 && \
    ./bootstrap.sh && \
    ./b2 install --with-system --with-filesystem --with-program_options link=static -j $(nproc)

RUN git clone https://github.com/cuhk-eda/dr-cu drcu_18012021

WORKDIR drcu_18012021

RUN git checkout 427b4a4f03bb98d8a78b1712fe9e52cfb83a8347

RUN python scripts/build.py -o release

RUN mkdir -p /build/bin/ && \
    cp run/ispd19dr /build/bin/drcu

RUN mkdir -p /build/version
RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/drcu.version
RUN git rev-parse HEAD >> /build/version/drcu.version
RUN tar -czf /build.tar.gz /build
