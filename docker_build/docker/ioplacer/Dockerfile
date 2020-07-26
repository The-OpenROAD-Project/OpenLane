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

# Common development tools and libraries (kitchen sink approach)
RUN yum groupinstall -y "Development Tools" "Development Libraries"

RUN yum install -y wget rh-mongodb32-boost-devel rh-mongodb32-boost-static
ENV PATH=/opt/rh/rh-mongodb32/root/usr/bin:$PATH \
    LD_LIBRARY_PATH=/opt/rh/rh-mongodb32/root/usr/lib64:/opt/rh/rh-mongodb32/root/usr/lib:/opt/rh/rh-mongodb32/root/usr/lib64/dyninst:/opt/rh/rh-mongodb32/root/usr/lib/dyninst:/opt/rh/rh-mongodb32/root/usr/lib64:/opt/rh/rh-mongodb32/root/usr/lib:$LD_LIBRARY_PATH \
    C_INCLUDE_PATH=/opt/rh/rh-mongodb32/root/usr/include \
    CPLUS_INCLUDE_PATH=/opt/rh/rh-mongodb32/root/usr/include


RUN wget https://cmake.org/files/v3.9/cmake-3.9.0-Linux-x86_64.sh && \
    chmod +x cmake-3.9.0-Linux-x86_64.sh  && \
    ./cmake-3.9.0-Linux-x86_64.sh --skip-license --prefix=/usr/local

RUN yum install -y zlib-devel

RUN yum install -y http://opensource.wandisco.com/centos/6/git/x86_64/wandisco-git-release-6-1.noarch.rpm
RUN yum install -y git 


# download public key for github.com
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN git clone --recursive https://github.com/The-OpenROAD-Project/ioPlacer \
	&& cd ioPlacer \
	&& git checkout a7e0b0b4200c6b34a6c93bbafdf72027284e588a \
	&& git submodule update --init --recursive --remote


RUN yum install -y zlib-devel pcre-devel tcl-devel

RUN yum remove -y swig \
     && wget https://github.com/swig/swig/archive/rel-3.0.12.tar.gz \
     && tar xfz rel-3.0.12.tar.gz \
     && rm -rf rel-3.0.12.tar.gz \
     && cd swig-rel-3.0.12 \
     && ./autogen.sh && ./configure --prefix=/usr && make -j$(nproc) && make install


# RUN make release
# RUN make install

RUN mkdir /ioPlacer/build
WORKDIR /ioPlacer/build

RUN cmake -DCMAKE_BUILD_TYPE=Release -DBOOST_ROOT=/opt/rh/rh-mongodb32/root/usr ..  && \
    make -j$(nproc)

RUN mkdir -p /build/bin/ && \
    cp /ioPlacer/build/ioPlacer /build/bin  && \
    cp /ioPlacer/scripts/replace_ioplace_loop.sh /build/bin

RUN mkdir -p /build/version
RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/ioplacer.version
RUN git rev-parse HEAD >> /build/version/ioplacer.version
RUN tar -czf /build.tar.gz /build
