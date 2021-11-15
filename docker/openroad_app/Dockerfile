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

FROM openlane-build-base

# Build Boost
RUN wget https://sourceforge.net/projects/boost/files/boost/1.72.0/boost_1_72_0.tar.bz2/download && \
    tar -xf download && \
    cd boost_1_72_0 && \
    ./bootstrap.sh && \
    ./b2 install --with-iostreams --with-test -j $(nproc)

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
RUN curl -L http://lemon.cs.elte.hu/pub/sources/lemon-1.3.1.tar.gz | tar --strip-components=1 -xzC . \
    && cmake -B build . \
    && cmake --build build -j $(nproc) --target install

# Build Spdlog
RUN git clone -b v1.8.1 https://github.com/gabime/spdlog \
    && cd spdlog \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make install -j $(nproc)

ARG OPENROAD_APP_REPO
ARG OPENROAD_APP_COMMIT

WORKDIR /openroad
RUN curl -L ${OPENROAD_APP_REPO}/tarball/${OPENROAD_APP_COMMIT} | tar -xzC . --strip-components=1
COPY ./fetch_submodules_from_tarballs.py .
RUN python3 ./fetch_submodules_from_tarballs.py ${OPENROAD_APP_REPO} ${OPENROAD_APP_COMMIT}

# Build OpenROAD
RUN mkdir build && mkdir -p /build/version && mkdir install
RUN cd build && cmake -DCMAKE_INSTALL_PREFIX=$(pwd)/install .. && make -j$(nproc)
RUN cd build && make install
RUN cp -r build/install/bin /build/

RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/openroad.version
RUN echo ${OPENROAD_APP_COMMIT} >> /build/version/openroad.version
RUN tar -czf /build.tar.gz /build
