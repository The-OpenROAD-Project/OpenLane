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

# Upstream is git://opencircuitdesign.com/netgen, but servers are not stable enough for CI.
ARG NETGEN_REPO=https://github.com/rtimothyedwards/netgen
ARG NETGEN_COMMIT=738c1f7b3705bca2f1cc66fbc1cfb20f12d49a06

WORKDIR /netgen

RUN curl -L ${NETGEN_REPO}/tarball/${NETGEN_COMMIT} | tar -xzC . --strip-components=1 && \
    ./configure CFLAGS="-O2 -g" --prefix=/build && \
    make -j$(nproc) && \
    make install

RUN mkdir -p /build/version/
RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/netgen.version
RUN echo ${NETGEN_COMMIT} >> /build/version/netgen.version
RUN tar -czf /build.tar.gz /build
