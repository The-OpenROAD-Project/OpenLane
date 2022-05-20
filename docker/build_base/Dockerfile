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
ARG OS_IMAGE=
FROM ${OS_IMAGE}

# Install Yum Dependencies
COPY ./yum_precompile_dependencies.txt /yum_precompile_dependencies.txt
COPY ./yum_compile_dependencies.txt /yum_compile_dependencies.txt
COPY ./yum_dependencies.txt /yum_dependencies.txt
RUN yum install --setopt=skip_missing_names_on_install=False -y $(cat /yum_precompile_dependencies.txt | tr '\n' ' ') && \
	yum install --setopt=skip_missing_names_on_install=False -y $(cat /yum_compile_dependencies.txt | tr '\n' ' ') && \
	yum install --setopt=skip_missing_names_on_install=False -y $(cat /yum_dependencies.txt | tr '\n' ' ') && \
	yum clean all && \
	rm -rf /var/cache/yum

RUN alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 60

# Configure Git
RUN git config --global user.name "OpenLane User"
RUN git config --global user.email "openlane.user@localhost"

# Install Python Dependencies
## Wheel Build Dependencies
RUN python3 -m pip install --no-cache-dir --upgrade pip
COPY ./pip_compile_dependencies.txt /pip_compile_dependencies.txt
COPY ./pip_dependencies.txt /pip_dependencies.txt
RUN python3 -m pip install --no-cache-dir -r /pip_compile_dependencies.txt
RUN python3 -m pip install --no-cache-dir -r /pip_dependencies.txt

# Update Certs
RUN yum update -y ca-certificates

# Environment Configuration
ENV CC=/opt/rh/devtoolset-8/root/usr/bin/gcc \
    CPP=/opt/rh/devtoolset-8/root/usr/bin/cpp \
    CXX=/opt/rh/devtoolset-8/root/usr/bin/g++ \
    PATH=/opt/rh/devtoolset-8/root/usr/bin:$PATH \
    LD_LIBRARY_PATH=/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib:/opt/rh/devtoolset-8/root/usr/lib64/dyninst:/opt/rh/devtoolset-8/root/usr/lib/dyninst:/opt/rh/devtoolset-8/root/usr/lib64:/opt/rh/devtoolset-8/root/usr/lib:$LD_LIBRARY_PATH

ENV LD_LIBRARY_PATH=/opt/rh/llvm-toolset-7.0/root/usr/lib64:/opt/rh/llvm-toolset-7.0/root/usr/lib:/opt/rh/llvm-toolset-7.0/root/usr/lib64/dyninst:/opt/rh/llvm-toolset-7.0/root/usr/lib/dyninst:/opt/rh/llvm-toolset-7.0/root/usr/lib64:/opt/rh/llvm-toolset-7.0/root/usr/lib:$LD_LIBRARY_PATH
