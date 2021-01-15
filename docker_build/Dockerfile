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
FROM swift:5.3.2-bionic

# RUN useradd -m openlane
# RUN usermod -aG wheel openlane
# USER openlane

# install base dependencies
# including python 3.6
RUN apt-get update
RUN apt-get install -y apt-utils

RUN	apt-get install -y \
		make \
		libcairo2-dev libjpeg-dev libpango1.0-dev libreadline-dev libgif-dev build-essential \
		gettext \
		gdb \
		git \
		libffi-dev \
		libgomp1 \
		libjpeg-dev \
		libsm-dev \
		libxext-dev\
		libxft-dev \
		python python-dev python-pip \
        python3 python3-dev python3-pip \
		python-tk \
		strace \
		tcl-dev \
		tcllib \
		tk \
		libtcl8.5 \ 
		libtk8.5 \
		libglu1-mesa \
		libgl1-mesa-glx \
		wget \
		vim \
		curl \
		xvfb && \
	 apt-get clean

# Install python dependencies
RUN pip3.6 install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir \
		matplotlib \
		jinja2 \
		pandas \
		install \
		XlsxWriter

# for magic
#RUN apt-get install mesa-libGLU-devel


ENV OPENLANE_ROOT=/openLANE_flow
ENV OPENROAD=/build/
ENV OPENROADOS=Linux-x86_64

ENV PATH=$OPENLANE_ROOT:$OPENLANE_ROOT/scripts:$OPENROAD/bin:$OPENROAD/bin/Linux-x86_64:$OPENROAD/pdn/scripts:$PATH
ENV LD_LIBRARY_PATH=$OPENROAD/lib:$OPENROAD/lib/Linux-x86_64:$LD_LIBRARY_PATH
ENV MANPATH=$OPENROAD/share/man:$MANPATH

# install klayout
# RUN yum install -y which
# ADD ./klayout.tar.gz /
# RUN yum localinstall -y /build/klayout-*.rpm

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
