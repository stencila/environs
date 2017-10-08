#!/usr/bin/env sh

# Error the build on any error in this script
set -e

# Build each image
for image in $STENCILA_IMAGES; do
	if [ -f "$image/.collect.sh" ]; then
		cd "$image" && sh ".collect.sh"
	fi
	docker build --no-cache=true --tag "stencila/$image:latest" --tag "stencila/$image:$STENCILA_TAG" "$image"
done
