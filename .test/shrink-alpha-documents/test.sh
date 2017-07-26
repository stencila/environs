#!/usr/bin/env sh

# Build the docker image
docker build . --tag test-shrink-alpha-documents

# Run it and do something with output
FULL=$(docker run test-shrink-alpha-documents)

# Try to shrink the docker image
../../.shrink/shrink-docker.sh test-shrink-alpha-documents test-shrink-alpha-documents-shrinked bash cmd.sh 


# Still not working 
SHRINKED=$(docker run test-shrink-alpha-documents-shrinked bash cmd.sh)
