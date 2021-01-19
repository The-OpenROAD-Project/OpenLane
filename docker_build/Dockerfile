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

# syntax = docker/dockerfile:1.0-experimental
FROM centos:centos7 as build

# RUN useradd -m openlane
# RUN usermod -aG wheel openlane
# USER openlane

# install base dependencies
# including python 3.6
RUN yum install -y https://repo.ius.io/ius-release-el$(rpm -E '%{rhel}').rpm && \
	yum install -y \
		make \
		cairo \
		gettext \
		gdb \
		git \
		libffi \
		libgomp \
		libjpeg \
		libSM \
		libXext \
		libXft \
		python36u \
		python36u-pip \
		python36u-tkinter \
		strace \
		tcl \
		tcllib \
		tk \
		wget \
		Xvfb && \
	yum clean all && \
	rm -rf /var/cache/yum

RUN alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 60

# Install python dependencies
RUN pip3.6 install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir \
		matplotlib \
		jinja2 \
		pandas \
		install \
		XlsxWriter

# for magic
RUN yum install -y mesa-libGLU-devel


ENV OPENLANE_ROOT=/openLANE_flow
ENV OPENROAD=/build/
ENV OPENROADOS=Linux-x86_64

ENV PATH=$OPENLANE_ROOT:$OPENLANE_ROOT/scripts:$OPENROAD/bin:$OPENROAD/bin/Linux-x86_64:$OPENROAD/pdn/scripts:$PATH
ENV LD_LIBRARY_PATH=$OPENROAD/lib:$OPENROAD/lib/Linux-x86_64:$LD_LIBRARY_PATH
ENV MANPATH=$OPENROAD/share/man:$MANPATH

# install klayout
RUN yum install -y which patch
ADD ./klayout.tar.gz /
RUN yum localinstall -y /build/klayout-*.rpm

ARG CACHE_INVALIDATOR=1
RUN echo "$CACHE_INVALIDATOR"

ADD ./openroad_tools.tar.gz /
COPY ./.tclshrc /
COPY ./.tclshrc /root

ADD ./openLANE_flow.tar.gz $OPENLANE_ROOT


# install opendb python
RUN cd $OPENROAD/OpenDB_python/ && \
	python3 setup.py install && \
	rm -rf $OPENROAD/OpenDB_python

WORKDIR $OPENLANE_ROOT

CMD /bin/bash
