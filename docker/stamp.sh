#!/bin/sh
mkdir -p /build/version/
date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/$1.version
git rev-parse HEAD >> /build/version/$1.version


