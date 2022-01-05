# Copyright 2022 Efabless Corporation
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

# WIP, probably will never make it to the image because it's taking forever to build

FROM openlane-build-base AS builder

ARG SKY130_REPO
ARG SKY130_COMMIT

ENV PDK_ROOT /build/pdk
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8

WORKDIR ${PDK_ROOT}
RUN git clone ${SKY130_REPO}    
WORKDIR ${PDK_ROOT}/skywater-pdk
RUN git checkout main &&\
    git submodule init &&\
    git pull --no-recurse-submodules &&\
	git checkout -qf ${SKY130_COMMIT}
RUN git submodule update --init libraries/sky130_fd_sc_hd/latest &&\
    git submodule update --init libraries/sky130_fd_sc_hs/latest &&\
    git submodule update --init libraries/sky130_fd_sc_hdll/latest &&\
    git submodule update --init libraries/sky130_fd_sc_ms/latest &&\
    git submodule update --init libraries/sky130_fd_sc_ls/latest &&\
    git submodule update --init libraries/sky130_fd_sc_hvl/latest &&\
    git submodule update --init libraries/sky130_fd_io/latest &&\
    git submodule update --init libraries/sky130_fd_pr/latest
RUN python3 -m pip install -e scripts/python-skywater-pdk
RUN python3 -m skywater_pdk.liberty libraries/sky130_fd_sc_hd/latest
RUN python3 -m skywater_pdk.liberty libraries/sky130_fd_sc_hd/latest all
RUN python3 -m skywater_pdk.liberty libraries/sky130_fd_sc_hd/latest all --ccsnoise
RUN python3 -m skywater_pdk.liberty libraries/sky130_fd_sc_hdll/latest
RUN python3 -m skywater_pdk.liberty libraries/sky130_fd_sc_hdll/latest all
RUN python3 -m skywater_pdk.liberty libraries/sky130_fd_sc_hdll/latest all --ccsnoise
RUN python3 -m skywater_pdk.liberty libraries/sky130_fd_sc_hs/latest
RUN python3 -m skywater_pdk.liberty libraries/sky130_fd_sc_hs/latest all
RUN python3 -m skywater_pdk.liberty libraries/sky130_fd_sc_hs/latest all --ccsnoise
RUN python3 -m skywater_pdk.liberty libraries/sky130_fd_sc_hvl/latest
RUN python3 -m skywater_pdk.liberty libraries/sky130_fd_sc_hvl/latest all
RUN python3 -m skywater_pdk.liberty libraries/sky130_fd_sc_hvl/latest all --ccsnoise
RUN python3 -m skywater_pdk.liberty libraries/sky130_fd_sc_ls/latest
RUN python3 -m skywater_pdk.liberty libraries/sky130_fd_sc_ls/latest all
RUN python3 -m skywater_pdk.liberty libraries/sky130_fd_sc_ls/latest all --ccsnoise
RUN python3 -m skywater_pdk.liberty libraries/sky130_fd_sc_ms/latest all --leakage
RUN python3 -m skywater_pdk.liberty libraries/sky130_fd_sc_ms/latest
RUN python3 -m skywater_pdk.liberty libraries/sky130_fd_sc_ms/latest all
RUN python3 -m skywater_pdk.liberty libraries/sky130_fd_sc_ms/latest all --ccsnoise

ARG MAGIC_REPO
ARG MAGIC_COMMIT

WORKDIR /magic
RUN curl -L ${MAGIC_REPO}/tarball/${MAGIC_COMMIT} | tar -xzC . --strip-components=1 && \
    ./configure --prefix=/usr && \
    make -j$(nproc) && \
    make install

ARG OPEN_PDKS_REPO
ARG OPEN_PDKS_COMMIT

WORKDIR ${PDK_ROOT}
RUN git clone ${OPEN_PDKS_REPO}
WORKDIR ${PDK_ROOT}/open_pdks
RUN git checkout master &&\
	git checkout -qf ${OPEN_PDKS_COMMIT}
RUN ./configure --enable-sky130-pdk=${PDK_ROOT}/skywater-pdk/libraries --enable-sram-sky130
WORKDIR ${PDK_ROOT}/open_pdks/sky130
RUN make alpha-repo xschem-repo sram-repo 2>&1 | tee /build/pdk_prereq.log
RUN make 2>&1 | tee /build/pdk.log
RUN make SHARED_PDKS_PATH=${PDK_ROOT} install

RUN printf "skywater-pdk ${SKY130_COMMIT}" > ${PDK_ROOT}/sky130A/SOURCES
RUN printf "magic ${MAGIC_COMMIT}" >> ${PDK_ROOT}/sky130A/SOURCES
RUN printf "open_pdks ${OPEN_PDKS_COMMIT}" >> ${PDK_ROOT}/sky130A/SOURCES

RUN rm -rf ${PDK_ROOT}/skywater-pdk
RUN rm -rf ${PDK_ROOT}/open_pdks


RUN tar -c /build | gzip -1 > /build.tar.gz

# ---
# pdk can't really be runnable, might as well shed a few layers
FROM centos:centos7 as runnable

COPY --from=builder /build.tar.gz /build.tar.gz


