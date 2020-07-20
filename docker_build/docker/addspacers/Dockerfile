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

RUN yum install -y git 

RUN git clone https://github.com/RTimothyEdwards/qflow

WORKDIR qflow
RUN git checkout ad92e709bcd6c8604816a6c98cef2e35a841de85

RUN ./configure && cd src && make addspacers

RUN mkdir -p /build/bin && cp /qflow/src/addspacers /build/bin/

RUN mkdir -p /build/version/
RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/addspacers.version
RUN git rev-parse HEAD >> /build/version/addspacers.version
RUN tar -czf /build.tar.gz /build

