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

FROM centos:centos7

# Install Yum Dependencies
COPY ./yum_dependencies.txt /yum_dependencies.txt
RUN yum install -y https://repo.ius.io/ius-release-el$(rpm -E '%{rhel}').rpm && \
	yum install -y $(cat /yum_dependencies.txt) && \
	yum clean all && \
	rm -rf /var/cache/yum

RUN alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 60

## Update and Configure Git
RUN yum install -y https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.7-1.x86_64.rpm && \
	yum install -y git

RUN git config --global user.name "OpenLane User" 
RUN git config --global user.email "openlane.user@localhost"

# Install Python Dependencies
## Wheel Build Dependencies
RUN python3 -m pip install --no-cache-dir --upgrade pip
COPY ./pip_dependencies.txt /pip_dependencies.txt
RUN python3 -m pip install --no-cache-dir -r /pip_dependencies.txt

# Environment Configuration
ENV OPENLANE_ROOT=/openlane
ENV OPENROAD_BIN openroad

ENV OPENROAD=/build/
ENV PATH=$OPENLANE_ROOT:$OPENLANE_ROOT/scripts:$OPENROAD/bin:$OPENROAD/bin/Linux-x86_64:$OPENROAD/pdn/scripts:$PATH
ENV LD_LIBRARY_PATH=$OPENROAD/lib:$OPENROAD/lib/Linux-x86_64:$LD_LIBRARY_PATH
ENV MANPATH=$OPENROAD/share/man:$MANPATH
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8

# Tools
ARG CACHE_INVALIDATOR=1
RUN echo "$CACHE_INVALIDATOR"

## Qt Thing
RUN dbus-uuidgen --ensure

## Copy manifest
ADD ./tool_metadata.yml /tool_metadata.yml

## Copy Version
ADD ./git_version /git_version

## Tarballs
ADD ./openroad_tools.tar.gz /
ADD ./openlane.tar.gz $OPENLANE_ROOT

## Tclsh RC
COPY ./.tclshrc /.tclshrc
COPY ./.tclshrc /root/.tclshrc

## Bash RC
COPY ./.bashrc /.bashrc
COPY ./.bashrc /root/.bashrc

WORKDIR $OPENLANE_ROOT

CMD /bin/bash
