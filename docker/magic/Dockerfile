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

# Upstream is git://opencircuitdesign.com/magic, but servers are not stable enough for CI.
ARG MAGIC_REPO
ARG MAGIC_COMMIT

WORKDIR /magic
RUN curl -L ${MAGIC_REPO}/tarball/${MAGIC_COMMIT} | tar -xzC . --strip-components=1 && \
    ./configure --prefix=/build && \
    make -j$(nproc) && \
    make install

RUN mkdir -p /build/version/
RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/magic.version
RUN echo ${MAGIC_COMMIT} >> /build/version/magic.version
RUN tar -czf /build.tar.gz /build

# ---
FROM ${RUN_BASE_IMAGE} AS runnable
ENV PATH /build/bin:$PATH

COPY --from=builder /build /build
COPY --from=builder /build.tar.gz /build.tar.gz