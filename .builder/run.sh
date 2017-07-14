#!/usr/bin/env sh

# Login to Docker hub to 
docker login --username=sibyl --password=$DOCKER_PASS

# Download the repo to get lastest versions of Dockerfiles
rm -rf stencila-images*
curl --location "https://github.com/stencila/images/tarball/master" > stencila-images.tar.gz
tar -xzf stencila-images.tar.gz

# Build, push and remove each image
cd stencila-images-*
images=$(find -mindepth 1 -maxdepth 1 -type d -not -name '.builder' -printf '%P\n')
tag=$(date -u -I)
for name in $images; do
	docker build --no-cache=true --tag "stencila/$name:latest" --tag "stencila/$name:$tag" "$name"
	docker push "stencila/$name:latest"
	docker rmi "stencila/$name:latest"
	docker push "stencila/$name:$tag"
	docker rmi "stencila/$name:$tag"
done
