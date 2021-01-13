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
FROM centos:centos7 as build

# Common development tools and libraries (kitchen sink approach)
RUN yum groupinstall -y "Development Tools"
RUN yum -y install centos-release-scl && \
    yum -y install devtoolset-8 devtoolset-8-libatomic-devel && \
    yum clean -y all
ENV CC=/opt/rh/devtoolset-8/root/usr/bin/gcc \
    CPP=/opt/rh/devtoolset-8/root/usr/bin/cpp \
    CXX=/opt/rh/devtoolset-8/root/usr/bin/g++ \
    PATH=/opt/rh/devtoolset-8/root/usr/bin:$PATH \
    LD_LIBRARY_PATH=/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib:/opt/rh/devtoolset-8/root/usr/lib64/dyninst:/opt/rh/devtoolset-8/root/usr/lib/dyninst:/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib:$LD_LIBRARY_PATH

# python 3.6
RUN yum install -y https://repo.ius.io/ius-release-el7.rpm
RUN yum install -y python36u python36u-libs python36u-devel python36u-pip python36u-tkinter
RUN alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 60
RUN yum install -y qt4 qt4-devel && \
    yum clean -y all
#RUN yum install -y qt5-qtbase-devel
#RUN yum install -y qt5-qtbase qt5-qtbase-common qt5-qtbase-gui qt5-qtscript xcb-util-renderutil xcb-util-wm

#RUN yum install -y qt5-qtsvg
#RUN yum install -y qt5-qtsvg-devel
#RUN yum install -y qt5-qtmultimedia qt5-qtmultimedia-devel
# klayout
RUN git clone https://github.com/KLayout/klayout.git klayout_11012020

WORKDIR klayout_11012020

RUN mkdir -p /build_dir
RUN ./build.sh -noruby -without-qt -bin /build -options -j8

RUN mkdir -p /build/version/

RUN ls /build
#RUN ls /build_dir

#RUN rm -rf /build_dir
 
RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/klayout.version
RUN git rev-parse HEAD >> /build/version/klayout.version
RUN tar -czf /build.tar.gz /build

