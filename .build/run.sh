#!/usr/bin/env sh

# Download the repo to get lastest versions of Dockerfiles
rm -rf stencila-images*
curl --location "https://github.com/stencila/images/tarball/master" > stencila-images.tar.gz
tar -xzf stencila-images.tar.gz
cd stencila-images-*

# Set env vars
. vars.sh

# Build images
. build.sh

# Push images
. push.sh
