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

# install gcc 6
RUN yum -y install centos-release-scl && \
    yum -y install devtoolset-6 devtoolset-6-libatomic-devel
ENV CC=/opt/rh/devtoolset-6/root/usr/bin/gcc \
    CPP=/opt/rh/devtoolset-6/root/usr/bin/cpp \
    CXX=/opt/rh/devtoolset-6/root/usr/bin/g++ \
    PATH=/opt/rh/devtoolset-6/root/usr/bin:$PATH \
    LD_LIBRARY_PATH=/opt/rh/devtoolset-6/root/usr/lib64:/opt/rh/devtoolset-6/root/usr/lib:/opt/rh/devtoolset-6/root/usr/lib64/dyninst:/opt/rh/devtoolset-6/root/usr/lib/dyninst:/opt/rh/devtoolset-6/root/usr/lib64:/opt/rh/devtoolset-6/root/usr/lib:$LD_LIBRARY_PATH

# install dependencies
RUN yum install -y wget libstdc++-devel libstdc++-static libX11-devel \
    boost-devel zlib-devel tcl-devel tk-devel autoconf automake swig flex libtool \
    libtool-ltdl gmp-devel mpfr-devel libmpc-devel bison byacc ctags \
    ImageMagick ImageMagick-devel git glibc-static zlib-static libjpeg-turbo-static

# install Intel MKL and IPP
RUN yum install -y yum-utils
RUN yum-config-manager --add-repo https://yum.repos.intel.com/setup/intelproducts.repo && \
    rpm --import https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB && \
    yum install -y intel-mkl-2018.2-046 

# download public key for github.com
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN git clone --recursive https://github.com/The-OpenROAD-Project/RePlAce \
	&& cd RePlAce \
	&& git checkout 950b5df4ea6a70fcfb1d496e85cfa63bdd172499

# Updating new bison 3+
RUN yum remove -y bison
RUN wget https://ftp.gnu.org/gnu/bison/bison-3.0.1.tar.gz && \
    tar -xvzf bison-3.0.1.tar.gz && \
    cd bison-3.0.1 && \
    ./configure && \
    make -j$(nproc) && \
    make install

# Installing cmake for build dependency
RUN wget https://cmake.org/files/v3.9/cmake-3.9.0-Linux-x86_64.sh && \
    chmod +x cmake-3.9.0-Linux-x86_64.sh  && \
    ./cmake-3.9.0-Linux-x86_64.sh --skip-license --prefix=/usr/local


RUN mkdir RePlAce/build
WORKDIR RePlAce/build

RUN cmake ..

RUN make -j$(nproc)

RUN mkdir -p /build/bin/ && \
    cp /RePlAce/build/replace /build/bin/replace

RUN mkdir -p /build/version
RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/replace.version
RUN git rev-parse HEAD >> /build/version/replace.version
RUN tar -czf /build.tar.gz /build

