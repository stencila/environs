#!/usr/bin/env sh

# Build the docker image
docker build . --tag test-shrink-alpha-documents

# Run it and do something with output
docker run test-shrink-alpha-documents
