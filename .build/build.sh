#!/usr/bin/env sh

# Error the build on any error in this script
set -e

# Build each image
for image in $STENCILA_IMAGES; do
	docker build --no-cache=true --tag "stencila/$image:latest" --tag "stencila/$image:$STENCILA_TAG" "$image"
done
