#!/bin/bash

set -eu

# The IIC (IntelliJ IDEA Community) product code is no longer maintained
# in the JetBrains releases API - it has been returning the same
# 2025.3 release since late 2025. The IIU code now reports the current
# stable IntelliJ IDEA version (the Linux tarball is shared between
# Community and Ultimate, so this is the version we want to package).
data=$(curl --fail -s 'https://data.services.jetbrains.com/products/releases?code=IIU&latest=true&type=release&build=linux')
version=$(echo "${data}" | sed -nr 's/.*"version":"(.*?)","majorVersion.*/\1/p')

echo "${version}"