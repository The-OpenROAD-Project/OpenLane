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
FROM centos:centos6 AS build

# Install Development Environment
RUN yum groupinstall -y "Development Tools"
RUN yum install -y wget git
RUN yum -y install centos-release-scl && \
    yum -y install devtoolset-8 devtoolset-8-libatomic-devel

ENV CC=/opt/rh/devtoolset-8/root/usr/bin/gcc \
    CPP=/opt/rh/devtoolset-8/root/usr/bin/cpp \
    CXX="/opt/rh/devtoolset-8/root/usr/bin/g++ -lrt" \
    PATH=/opt/rh/devtoolset-8/root/usr/bin:$PATH \
    LD_LIBRARY_PATH=/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib:/opt/rh/devtoolset-8/root/usr/lib64/dyninst:/opt/rh/devtoolset-8/root/usr/lib/dyninst:/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib:$LD_LIBRARY_PATH
# Install CMake
RUN wget https://cmake.org/files/v3.14/cmake-3.14.0-Linux-x86_64.sh && \
    chmod +x cmake-3.14.0-Linux-x86_64.sh  && \
    ./cmake-3.14.0-Linux-x86_64.sh --skip-license --prefix=/usr/local

# Install epel repo
#RUN wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
#RUN yum install -y epel-release-latest-6.noarch.rpm


# Install dev and runtime dependencies
RUN yum install -y tcl-devel tcl tk libstdc++ tk-devel pcre-devel


# Install SWIG
RUN wget http://prdownloads.sourceforge.net/swig/swig-4.0.0.tar.gz && \
    tar -xf swig-4.0.0.tar.gz && \
    cd swig-4.0.0 && \
    ./configure && \
    make && \
    make install

# Install python dev
#RUN yum install -y https://centos6.iuscommunity.org/ius-release.rpm && \
#    yum update -y && \
#    yum install -y python36u python36u-libs python36u-devel python36u-pip


RUN yum install -y git 

# download CUDD
RUN wget https://www.davidkebo.com/source/cudd_versions/cudd-3.0.0.tar.gz && \
    tar -xvf cudd-3.0.0.tar.gz && \
    cd cudd-3.0.0 && \
    ./configure && \
    make -j$(nproc) && \
    make install
    
RUN git clone --recursive https://github.com/scale-lab/OpenPhySyn.git && \
    cd OpenPhySyn && \
    git checkout 6bb80c5f9312a302b7c29cf1a4ddb93ace47d122 
    

# Build
WORKDIR OpenPhySyn
RUN mkdir build && mkdir /build
RUN cd build && cmake -DCMAKE_BUILD_TYPE=release \
	-DCMAKE_INSTALL_PREFIX=/build/ .. 
RUN make -j4 && Psn 
RUN make -j4 test
RUN mkdir /build/bin && cp build/Psn /build/bin/ && cp -r build/transforms /build/



RUN mkdir -p /build/version
RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/openphysyn.version
RUN git rev-parse HEAD >> /build/version/openphysyn.version
RUN tar -czf /build.tar.gz /build
