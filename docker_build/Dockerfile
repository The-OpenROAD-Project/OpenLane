# syntax = docker/dockerfile:1.0-experimental
FROM centos:centos6 as build

# RUN useradd -m openlane
# RUN usermod -aG wheel openlane
# USER openlane

# install base dependencies
RUN yum install -y git tcl tk libjpeg libgomp libXext libSM libXft libffi cairo gettext Xvfb

# python 3.6
RUN yum install -y https://repo.ius.io/ius-release-el6.rpm
RUN yum install -y python36u python36u-pip python36u-tkinter
RUN alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 60

# Install python dependencies
RUN pip3.6 install --upgrade pip && \
    pip install matplotlib && \
    pip install jinja2 && \
    pip install pandas

RUN yum install -y tcllib

ENV OPENLANE_ROOT=/openLANE_flow
ENV OPENROAD=/build/
ENV OPENROADOS=Linux-x86_64

ENV PATH=$OPENLANE_ROOT:$OPENLANE_ROOT/scripts:$OPENROAD/bin:$OPENROAD/bin/Linux-x86_64:$OPENROAD/pdn/scripts:$PATH
ENV LD_LIBRARY_PATH=$OPENROAD/lib:$OPENROAD/lib/Linux-x86_64:$LD_LIBRARY_PATH
ENV MANPATH=$OPENROAD/share/man:$MANPATH


COPY ./openroad_tools.tar.gz /
COPY ./.tclshrc /root
RUN tar -xzf openroad_tools.tar.gz && \
    rm -rf openroad_tools.tar.gz

COPY ./openLANE_flow.tar.gz /
RUN mkdir /openLANE_flow
RUN tar -xzf openLANE_flow.tar.gz -C openLANE_flow&& \
    rm -rf openLANE_flow.tar.gz

# install opendb python
RUN cd $OPENROAD/OpenDB_python/&& python3 setup.py install
RUN rm -rf $OPENROAD/OpenDB_python

WORKDIR /openLANE_flow
