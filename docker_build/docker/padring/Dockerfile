# syntax = docker/dockerfile:1.0-experimental
FROM centos:centos6 as build


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
	wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm && \
	yum install -y epel-release-latest-6.noarch.rpm && \
	yum -y install ninja-build

# Install CMake
RUN wget https://cmake.org/files/v3.14/cmake-3.14.0-Linux-x86_64.sh && \
    chmod +x cmake-3.14.0-Linux-x86_64.sh  && \
    ./cmake-3.14.0-Linux-x86_64.sh --skip-license --prefix=/usr/local

RUN git clone https://github.com/YosysHQ/padring \
	&& cd padring 


WORKDIR padring

RUN ./bootstrap.sh && cd build/ && ninja-build && mkdir /build/bin/ -p && cp padring /build/bin

RUN mkdir -p /build/version
RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/padring.version
RUN git rev-parse HEAD >> /build/version/padring.version
RUN tar -czf /build.tar.gz /build
