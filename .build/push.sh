#!/usr/bin/env sh

# Login to Docker Hub
docker login --username="$DOCKER_USERNAME" --password="$DOCKER_PASSWORD"

# Ensure env vars
. "./vars.sh"

# Push each image
for image in $STENCILA_IMAGES; do
	docker push "stencila/$image:latest"
	docker push "stencila/$image:$STENCILA_TAG"
done
