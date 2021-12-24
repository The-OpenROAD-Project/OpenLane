# This file is unused. Building Klayout simply takes too damn long.

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

# git clone yosys
ARG KLAYOUT_REPO
ARG KLAYOUT_COMMIT

RUN mkdir -p /build

RUN yum install -y ruby-devel\
	qt5-qtmultimedia-devel\
	qt5-qtxmlpatterns-devel\
	qt5-qtsvg-devel\
	qt5-qttools-devel

WORKDIR /klayout
RUN curl -L ${KLAYOUT_REPO}/tarball/${KLAYOUT_COMMIT} | tar -xzC . --strip-components=1 && \
    ./build.sh -prefix /build -j$(nproc)

RUN mkdir -p /build/version/

RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/klayout.version
RUN echo "klayout-${KLAYOUT_VERSION}.x86_64" >> /build/version/klayout.version
RUN tar -czf /build.tar.gz /build

