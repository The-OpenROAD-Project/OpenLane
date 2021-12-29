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
FROM openlane-build-base AS builder

# Installing boost for build dependency
RUN curl -L https://sourceforge.net/projects/boost/files/boost/1.72.0/boost_1_72_0.tar.bz2/download | tar --strip-components=1 -xjC . && \
    ./bootstrap.sh && \
    ./b2 install --with-iostreams --with-test --with-serialization --with-system --with-filesystem --with-thread --with-program_options link=static -j $(nproc)

# needed to get the xxd binaries needed to package the *.dat files
# into C arrays to be linked directly into the executable
RUN yum -y install vim-common

ARG DRCU_REPO
ARG DRCU_COMMIT

WORKDIR /drcu
RUN curl -L ${DRCU_REPO}/tarball/${DRCU_COMMIT} | tar -xzC . --strip-components=1

RUN python scripts/build.py -o release -t ispd19dr

RUN mkdir -p /build/bin/ && \
    cp run/ispd19dr /build/bin/drcu

RUN mkdir -p /build/version
RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/drcu.version
RUN echo ${DRCU_COMMIT} >> /build/version/drcu.version
RUN tar -czf /build.tar.gz /build

# ---
FROM openlane-run-base AS runnable

ENV PATH /build/bin:$PATH

COPY --from=builder /build /build
COPY --from=builder /build.tar.gz /build.tar.gz
