#!/usr/bin/env sh

# Build the docker image
docker build . --tag test-shrink-alpha-documents

# Run it and do something with output
FULL=$(docker run test-shrink-alpha-documents)

# Try to shrink the docker image
../../.shrink/shrink-docker.sh test-shrink-alpha-documents test-shrink-alpha-documents-shrinked bash cmd.sh 


# Still not working 
docker run --rm -w /home/guest -u guest -w /home/guest -u guest -e "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" -e "DEBIAN_FRONTEND=noninteractive" test-shrink-alpha-documents-shrinked bash cmd.sh
