# Copyright 2020 Efabless Corporation
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
# Common development tools and libraries (kitchen sink approach)
FROM centos:centos7 as build

# wget
RUN yum install -y wget && \
	yum clean all && \
	rm -rf /var/cache/yum

# klayout
RUN mkdir /build
WORKDIR /build
RUN wget https://www.klayout.org/downloads/CentOS_7/klayout-0.26.9-0.x86_64.rpm


RUN mkdir -p /build/version/

RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/klayout.version
RUN echo "klayout-0.26.9-0.x86_64" >> /build/version/klayout.version
RUN tar -czf /build.tar.gz /build

