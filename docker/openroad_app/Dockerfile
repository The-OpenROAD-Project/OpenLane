# Copyright 2020-2021 Efabless Corporation
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

ARG RUN_BASE_IMAGE=
ARG BUILD_BASE_IMAGE=
FROM ${BUILD_BASE_IMAGE} AS builder

# Build Boost
WORKDIR /boost
RUN curl -L https://sourceforge.net/projects/boost/files/boost/1.76.0/boost_1_76_0.tar.bz2/download | tar --strip-components=1 -xjC . && \
    ./bootstrap.sh && \
    ./b2 install --with-iostreams --with-test --with-serialization --with-system --with-thread -j $(nproc)

# Build Eigen
WORKDIR /eigen
RUN curl -L https://gitlab.com/libeigen/eigen/-/archive/3.3/eigen-3.3.tar.gz | tar --strip-components=1 -xzC . && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j$(nproc) && \
    make install

# Build Lemon
WORKDIR /lemon
RUN curl -L http://lemon.cs.elte.hu/pub/sources/lemon-1.3.1.tar.gz | tar --strip-components=1 -xzC . && \
    cmake -B build . && \
    cmake --build build -j $(nproc) --target install

# Build Spdlog
WORKDIR /spdlog
RUN curl -L https://github.com/gabime/spdlog/archive/refs/tags/v1.8.1.tar.gz | tar --strip-components=1 -xzC . && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make install -j $(nproc)

# Build Swig
RUN yum remove -y swig3
WORKDIR /swig
RUN curl -L https://github.com/swig/swig/archive/refs/tags/v4.0.1.tar.gz | tar --strip-components=1 -xzC . && \
    ./autogen.sh && \
    ./configure --prefix=/usr && \
    make -j $(nproc) && \
    make install

# Set up OpenROAD Build Files
RUN localedef -c -f UTF-8 -i en_US en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8

ARG OPENROAD_APP_REPO
ARG OPENROAD_APP_COMMIT

WORKDIR /openroad
RUN curl -L ${OPENROAD_APP_REPO}/tarball/${OPENROAD_APP_COMMIT} | tar -xzC . --strip-components=1
COPY ./utils.py .
RUN python3 ./utils.py fetch-submodules-from-tarballs ${OPENROAD_APP_REPO} ${OPENROAD_APP_COMMIT}

# Build OpenROAD
RUN sed -i "s/GITDIR-NOTFOUND/${OPENROAD_APP_COMMIT}/" cmake/GetGitRevisionDescription.cmake
RUN sed -i "s/static char Cases/static signed char Cases/" third-party/abc/src/misc/extra/extraUtilMisc.c
RUN mkdir build && mkdir -p /build/version && mkdir install
RUN cd build && cmake -DCMAKE_INSTALL_PREFIX=$(pwd)/install ..
RUN cd build && make -j$(nproc)
RUN cd build && make install
RUN cp -r build/install/bin /build/

RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/openroad.version
RUN echo ${OPENROAD_APP_COMMIT} >> /build/version/openroad.version
RUN tar -czf /build.tar.gz /build

# ---
FROM ${RUN_BASE_IMAGE} AS runnable
ENV PATH /build/bin:$PATH

COPY --from=builder /build /build
COPY --from=builder /build.tar.gz /build.tar.gz
