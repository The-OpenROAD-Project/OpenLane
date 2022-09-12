ARG RUN_BASE_IMAGE=
ARG BUILD_BASE_IMAGE=
FROM swift:5.6-centos7 AS swift

FROM ${BUILD_BASE_IMAGE} AS builder

ARG FAULT_REPO
ARG FAULT_COMMIT

# Setup Build Environment
RUN yum install -y --setopt=skip_missing_names_on_install=False https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm centos-release-scl
RUN yum install -y --setopt=skip_missing_names_on_install=False git gettext curl devtoolset-8 devtoolset-8-libatomic-devel 

ENV CC=/opt/rh/devtoolset-8/root/usr/bin/gcc \
    CPP=/opt/rh/devtoolset-8/root/usr/bin/cpp \
    CXX=/opt/rh/devtoolset-8/root/usr/bin/g++ \
    PATH=/opt/rh/devtoolset-8/root/usr/bin:$PATH \
    LD_LIBRARY_PATH=/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib/gcc/x86_64-redhat-linux/8:/opt/rh/devtoolset-8/root/usr/lib64/dyninst:/opt/rh/devtoolset-8/root/usr/lib/gcc/x86_64-redhat-linux/8/dyninst:/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib/gcc/x86_64-redhat-linux/8:$LD_LIBRARY_PATH

# Install Other Dependencies
RUN yum install -y flex bison autoconf libtool gperf tcl-devel libcurl-devel openssl-devel zlib-devel

WORKDIR /

COPY --from=swift /usr /build

# Install Git (Build-only dependency)
WORKDIR /git
RUN curl -L https://github.com/git/git/tarball/e9d7761bb94f20acc98824275e317fa82436c25d/ |\
    tar -xzC . --strip-components=1 &&\
    make configure &&\
    ./configure --prefix=/usr &&\
    make -j$(nproc) &&\
    make install &&\
    rm -rf *

# Install IcarusVerilog 11
# WORKDIR /iverilog
# RUN curl -L https://github.com/steveicarus/iverilog/archive/refs/tags/v11_0.tar.gz |\
#     tar --strip-components=1 -xzC . &&\
#     aclocal &&\
#     autoconf &&\
#     ./configure --prefix=/build &&\
#     make -j$(nproc) &&\
#     make install &&\
#     rm -rf *

# RUN mkdir -p /usr/local/lib/ivl/

# RUN ln -s /build/lib/ivl/ivlpp /usr/local/lib/ivl/ivlpp
# RUN ln -s /build/lib/ivl/ivl /usr/local/lib/ivl/ivl

WORKDIR /Fault
RUN curl -L ${FAULT_REPO}/tarball/${FAULT_COMMIT} | tar -xzC . --strip-components=1

RUN python3 -m pip install --target /build/lib/pythonpath --upgrade -r ./requirements.txt

WORKDIR /

# Copy Libraries for AppImage
RUN cp /lib64/libtinfo.so.5 /build/lib
RUN cp /lib64/libffi.so.6 /build/lib
RUN cp /lib64/libz.so.1 /build/lib
RUN cp /lib64/libreadline.so.6 /build/lib
RUN cp /lib64/libtcl8.5.so /build/lib
# RUN cp /lib64/libstdc++.so.6 /build/lib
# RUN cp /lib64/libm.so /build/lib

# ENV PATH /build/bin:$PATH
# ENV PATH /usr/bin:$PATH

WORKDIR /Fault
COPY . .
# RUN /build/bin/swift ./atalanta_podem_build.swift
# RUN INSTALL_DIR=/build/bin /build/bin/swift ./install.swift
RUN /build/bin/swift build --static-swift-stdlib -c release
RUN cp /Fault/.build/x86_64-unknown-linux-gnu/release/Fault /build/bin/fault

RUN ln -s /build/lib64/libpython3.6m.so.1.0 /build/lib/libpython3.6m.so

RUN echo "/build/lib/pythonpath/" > /build/lib64/python3.6/site-packages/usrlocal.pth

RUN mkdir -p /build/version/
RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/Fault.version
RUN echo ${FAULT_COMMIT} >> /build/version/Fault.version
RUN tar -czf /build.tar.gz /build

# ---
FROM ${RUN_BASE_IMAGE} AS runnable
ENV PATH /build/bin:$PATH

ENV PYTHON_LIBRARY=/build/lib/libpython3.6m.so\
    PYTHONPATH=/build/lib/pythonpath\
    LD_LIBRARY_PATH=/build/lib\
    FAULT_IVL_BASE=/build/lib/ivl\
    FAULT_IVERILOG=/build/bin/iverilog\
    FAULT_VVP=/build/bin/v

COPY --from=builder /build /build
COPY --from=builder /build.tar.gz /build.tar.gz