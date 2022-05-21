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

ARG PADRING_REPO
ARG PADRING_COMMIT
WORKDIR /padring

RUN curl -L ${PADRING_REPO}/tarball/${PADRING_COMMIT} | tar -xzC . --strip-components=1 && \
    ./bootstrap.sh && \
    cd build/ && \
    ninja-build && \
    mkdir /build/bin/ -p && \
    cp padring /build/bin

RUN mkdir -p /build/version
RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/padring.version
RUN echo ${PADRING_COMMIT} >> /build/version/padring.version
RUN tar -czf /build.tar.gz /build

# ---
ARG RUN_BASE_IMAGE=
FROM ${RUN_BASE_IMAGE} AS runnable
ENV PATH /build/bin:$PATH

COPY --from=builder /build /build
COPY --from=builder /build.tar.gz /build.tar.gz
