# syntax = docker/dockerfile:1.0-experimental
FROM centos:centos6 as build

# Common development tools and libraries (kitchen sink approach)
RUN yum groupinstall -y "Development Tools" "Development Libraries"
RUN yum -y install centos-release-scl && \
    yum -y install devtoolset-8 devtoolset-8-libatomic-devel

# python 3.6
RUN yum install -y https://repo.ius.io/ius-release-el6.rpm
RUN yum install -y python36u python36u-libs python36u-devel python36u-pip python36u-tkinter
RUN alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 60

# magic dependencies
RUN yum install -y csh wget tcl-devel tk-devel libX11-devel cairo-devel ncurses-devel

# git clone magic components
RUN git clone git://opencircuitdesign.com/magic magic_20072020

WORKDIR magic_20072020

RUN git checkout e453f130eee28f8b1d0a0e22f1eef5d4663751fd

# build
RUN ./configure --prefix=/build && \
    make -j4 && \
    make install

RUN mkdir -p /build/version/

RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/magic.version
RUN git rev-parse HEAD >> /build/version/magic.version
RUN tar -czf /build.tar.gz /build
