# Copyright 2020-2022 Efabless Corporation
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

ARG ARCH=
ARG RUN_BASE_IMAGE=
# <from>
FROM ${RUN_BASE_IMAGE}

# Environment Configuration
ENV OPENLANE_ROOT=/openlane
ENV OPENROAD_BIN openroad

ENV TCL8_5_TM_PATH=${OPENLANE_ROOT}/scripts
ENV OPENROAD=/build/
ENV PATH=$OPENLANE_ROOT:$OPENLANE_ROOT/scripts:$OPENROAD/bin:$OPENROAD/bin/Linux-x86_64:$OPENROAD/pdn/scripts:$PATH
ENV LD_LIBRARY_PATH=$OPENROAD/lib:$OPENROAD/lib/Linux-x86_64:$LD_LIBRARY_PATH
ENV MANPATH=$OPENROAD/share/man:$MANPATH
ENV PDK_ROOT /build/pdk

# Locale
RUN localedef -c -f UTF-8 -i en_US en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8

# Tools
## Graphical Applications
RUN dbus-uuidgen --ensure

## Copy manifest
ADD ./tool_metadata.yml /tool_metadata.yml

## Copy Version
ADD ./git_version /git_version
ADD ./git_version_short /git_version_short

## Scripts and Binaries
COPY ./openlane /openlane
# <copy>

## Tclsh RC
COPY ./.tclshrc /.tclshrc
COPY ./.tclshrc /root/.tclshrc

## Bash RC
COPY ./.bashrc /.bashrc
COPY ./.bashrc /root/.bashrc

WORKDIR $OPENLANE_ROOT

CMD /bin/bash
