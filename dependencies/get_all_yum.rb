#!/usr/bin/env ruby
require 'set'

dockerfiles = `find docker_build | grep Dockerfile`.split("\n")

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