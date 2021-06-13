#!/usr/bin/env ruby

# Copyright 2021 Efabless Corporation
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

# This is a simple script that looks for all the yum packages installed by the
# Docker images. It's finicky and will likely require human cleanup for the results.

# The ubuntu list was manually translated from the results for centos7.

require 'set'

dockerfiles = `find ../docker_build | grep Dockerfile`.split("\n")

yum_packages_set = Set.new

for file in dockerfiles
    str = File.read(file)

    entries = str.split("\n")
    i = 0
    while i < entries.count
        if not entries[i].end_with?("\\")
            i += 1
            next
        end
        eil = entries[i].length
        entries[i] = entries[i][...eil - 1] + entries[i + 1]
        entries.delete_at(i + 1)
    end
    
    
    for entry in entries

        yum_rx = /\s*yum\s+(?:\-y\s+)?install\s+([^&]+)/
        matches = entry.scan(yum_rx)
        if matches.count == 0
            next
        end
        for match in matches
            packages = match[0].split(/\s+/)
            yum_packages_set.merge(packages)
        end
    end
end

yum_package_list_raw = Array(yum_packages_set).sort
yum_package_list = yum_package_list_raw.filter { |p|
    not p.start_with?("-") and
    not p.include?("/") and
    not p.include?(".")
}
puts yum_package_list