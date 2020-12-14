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

FROM centos:centos7 AS base-dependencies

# Install Development Environment
RUN yum groupinstall -y "Development Tools"
RUN yum install -y wget git

RUN yum -y install centos-release-scl && \
    yum -y install devtoolset-8 readline-devel \
    devtoolset-8-libatomic-devel tcl-devel tcl tk libstdc++ tk-devel pcre-devel \
    python36u python36u-libs python36u-devel python36u-pip && \
    yum clean -y all && \
    rm -rf /var/lib/apt/lists/*

ENV CC=/opt/rh/devtoolset-8/root/usr/bin/gcc \
    CPP=/opt/rh/devtoolset-8/root/usr/bin/cpp \
    CXX="/opt/rh/devtoolset-8/root/usr/bin/g++ -lrt" \
    PATH=/opt/rh/devtoolset-8/root/usr/bin:$PATH \
    LD_LIBRARY_PATH=/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib:/opt/rh/devtoolset-8/root/usr/lib64/dyninst:/opt/rh/devtoolset-8/root/usr/lib/dyninst:/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib:$LD_LIBRARY_PATH


# update bison
RUN yum -y remove bison
RUN wget https://ftp.gnu.org/gnu/bison/bison-3.0.5.tar.gz && \
    tar -xvzf bison-3.0.5.tar.gz
RUN cd bison-3.0.5 && \
    ./configure --prefix=/usr && \
    make -j$(nproc) && \
    make install

# Install epel repo
RUN wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum install -y epel-release-latest-7.noarch.rpm

# Install dev and runtime dependencies
# Tcl 8.5
RUN yum install -y tcl-devel tcl tk libstdc++ tk-devel 

# Install python dev
RUN yum install -y https://repo.ius.io/ius-release-el7.rpm
RUN yum install -y python36u python36u-libs python36u-devel python36u-pip
RUN alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 60

RUN pip3.6 install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir \
		pyinstaller

COPY cvc-1.0.0.tar.gz cvc-1.0.0.tar.gz
RUN tar -xvf cvc-1.0.0.tar.gz
# Build
WORKDIR cvc-1.0.0
RUN ./configure --disable-nls --prefix=/build && \
    make install

RUN tar -czf /build.tar.gz /build

