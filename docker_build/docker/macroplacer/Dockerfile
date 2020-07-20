# syntax = docker/dockerfile:1.0-experimental
FROM centos:centos6 as build

# Mostly copied from https://github.com/abk-openroad/RePlAce/blob/master/Dockerfile

# install gcc 6
RUN yum -y install centos-release-scl && \
    yum -y install devtoolset-6 devtoolset-6-libatomic-devel
ENV CC=/opt/rh/devtoolset-6/root/usr/bin/gcc \
    CPP=/opt/rh/devtoolset-6/root/usr/bin/cpp \
    CXX=/opt/rh/devtoolset-6/root/usr/bin/g++ \
    PATH=/opt/rh/devtoolset-6/root/usr/bin:$PATH \
    LD_LIBRARY_PATH=/opt/rh/devtoolset-6/root/usr/lib64:/opt/rh/devtoolset-6/root/usr/lib:/opt/rh/devtoolset-6/root/usr/lib64/dyninst:/opt/rh/devtoolset-6/root/usr/lib/dyninst:/opt/rh/devtoolset-6/root/usr/lib64:/opt/rh/devtoolset-6/root/usr/lib:$LD_LIBRARY_PATH

# install dependencies
RUN yum install -y wget git zlib-devel tcl-devel tk-devel swig bison flex

RUN yum install -y wget rh-mongodb32-boost-devel rh-mongodb32-boost-static
ENV PATH=/opt/rh/rh-mongodb32/root/usr/bin:$PATH \
    LD_LIBRARY_PATH=/opt/rh/rh-mongodb32/root/usr/lib64:/opt/rh/rh-mongodb32/root/usr/lib:/opt/rh/rh-mongodb32/root/usr/lib64/dyninst:/opt/rh/rh-mongodb32/root/usr/lib/dyninst:/opt/rh/rh-mongodb32/root/usr/lib64:/opt/rh/rh-mongodb32/root/usr/lib:$LD_LIBRARY_PATH \
    C_INCLUDE_PATH=/opt/rh/rh-mongodb32/root/usr/include \
    CPLUS_INCLUDE_PATH=/opt/rh/rh-mongodb32/root/usr/include

# download public key for github.com
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

# Installing cmake for build dependency
RUN wget https://cmake.org/files/v3.9/cmake-3.9.0-Linux-x86_64.sh && \
    chmod +x cmake-3.9.0-Linux-x86_64.sh  && \
    ./cmake-3.9.0-Linux-x86_64.sh --skip-license --prefix=/usr/local

# get TritonMacroPlacer
RUN git clone --recursive https://github.com/abk-openroad/TritonMacroPlace

WORKDIR TritonMacroPlace

RUN mkdir build
WORKDIR build
RUN cmake -DCMAKE_INSTALL_PREFIX=/build -DBOOST_ROOT=/opt/rh/rh-mongodb32/root/usr ..

RUN make

RUN mkdir -p /build/bin/ && \
    cp fplan /build/bin

RUN mkdir -p /build/version

RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/macroplacer.version
RUN git rev-parse HEAD >> /build/version/macroplacer.version
RUN tar -czf /build.tar.gz /build
