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
COPY ./yum_dependencies.txt /yum_dependencies.txt
COPY ./yum_repos.txt /yum_repos.txt
RUN yum install --setopt=skip_missing_names_on_install=False -y $(cat /yum_repos.txt) && \
	yum install --setopt=skip_missing_names_on_install=False -y $(cat /yum_dependencies.txt) && \
	yum clean all && \
	rm -rf /var/cache/yum

RUN alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 60

# Configure Git
RUN git config --global user.name "OpenLane User" 
RUN git config --global user.email "openlane.user@localhost"

# Install Python Dependencies
## Wheel Build Dependencies
RUN python3 -m pip install --no-cache-dir --upgrade pip
COPY ./pip_dependencies.txt /pip_dependencies.txt
RUN python3 -m pip install --no-cache-dir -r /pip_dependencies.txt