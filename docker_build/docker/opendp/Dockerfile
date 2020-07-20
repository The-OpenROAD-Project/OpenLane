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

RUN yum -y install wget zlib-devel

RUN wget https://cmake.org/files/v3.9/cmake-3.9.0-Linux-x86_64.sh && \
    chmod +x cmake-3.9.0-Linux-x86_64.sh  && \
    ./cmake-3.9.0-Linux-x86_64.sh --skip-license --prefix=/usr/local


# download public key for github.com
RUN mkdir -p -m 0600 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN git clone --recursive https://github.com/kareefardi/OpenDP

RUN mkdir /OpenDP/build
WORKDIR /OpenDP/build

RUN cmake ..

RUN make && \
    make install

RUN mkdir -p /build/bin/ && \
    cp opendp /build/bin

RUN mkdir -p /build/version
RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/opendp.version
RUN git rev-parse HEAD >> /build/version/opendp.version
RUN tar -czf /build.tar.gz /build

