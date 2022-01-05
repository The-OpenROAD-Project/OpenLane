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

FROM openlane-run-base

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
ENV PDK_ROOT /build/pdk

# Tools
ARG CACHE_INVALIDATOR=1
RUN echo "$CACHE_INVALIDATOR"

## Qt Thing
RUN dbus-uuidgen --ensure

## Copy manifest
ADD ./tool_metadata.yml /tool_metadata.yml

## Copy Version
ADD ./git_version /git_version

## Artifacts
COPY ./build /build
COPY ./openlane /openlane

## Tclsh RC
COPY ./.tclshrc /.tclshrc
COPY ./.tclshrc /root/.tclshrc

## Bash RC
COPY ./.bashrc /.bashrc
COPY ./.bashrc /root/.bashrc

WORKDIR $OPENLANE_ROOT

CMD /bin/bash
