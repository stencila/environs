#!/bin/bash
set -e

if [ $# -lt 3 ]; then
  echo "Strips IN_IMAGE down to just the files needed to run COMMAND."
  echo "Saves result to OUT_REPOISTORY and runs the command again to check."
  echo 
  echo "If you need to specify other command line options for 'docker run'"
  echo "set the DOCKER_FLAGS environment variable."
  echo 
  echo "WARNING: If different commands or input may not work on the new image."
  echo  	
  echo "  Usage: $0 IN_IMAGE OUT_REPOSITORY[:TAG] [COMMAND ARG...]"
  exit 1
fi

function cleanup {
  if [ -n "$TEMPDIR" -a -d "$TEMPDIR" ]; then
    chmod -R +w "$TEMPDIR"
    rm -fR "$TEMPDIR"
  fi
}

trap cleanup EXIT


# Create temporary directory
if [ "$SHRINK_TEMP" == "" ]; then
  TEMPDIR=$(mktemp -d)
else
  TEMPDIR=$(mktemp -d "$SHRINK_TEMP/shrink-docker.XXXXXX")
fi

IN_IMAGE=$1
shift
OUT_REPOSITORY=$1
shift


# Build docker image with strace
if [[ "$IN_IMAGE" == *:* ]]; then
  STRACE_TAG="$IN_IMAGE-strace"
else
  STRACE_TAG="$IN_IMAGE:strace"
fi


# Get the docker's user if is defined
DOCKERUSER=$(docker inspect --format='{{.Config.User}}' $IN_IMAGE)
if [ -z "$DOCKERUSER" ]; then
    DOCKERUSER=root
fi
cd "$TEMPDIR"
cat >Dockerfile <<HERE	
FROM $IN_IMAGE

USER root

RUN apt-get update && \\
    apt-get -y --no-install-recommends install strace && \\
    rm -rf /var/lib/apt/lists/*

USER $DOCKERUSER
HERE

docker build . -t $STRACE_TAG

# Make sure stripdoc/strace.out is not created by docker (since then we may not have permission to delete it)
touch "$TEMPDIR"/strace.out
chmod 777 "$TEMPDIR"
chmod 666 "$TEMPDIR"/strace.out
docker run --rm --cap-add SYS_PTRACE -v "$TEMPDIR":/mnt/strace $DOCKER_FLAGS $STRACE_TAG strace -f -o /mnt/strace/strace.out "$@"

# Make a sorted list of the files we need to keep based on the strace output
read -r -d '' READLINKS <<-'HERE' || true
    KEEP=$(egrep '^[0-9]* *([a-z0-9A-Z]*)\(\"' /mnt/strace/strace.out | sed 's/^[0-9]* *\([a-z0-9A-Z]*\)("\([^"]*\)".*$/\2/' | sort -u)
    while read -r k; do
      LAST=""
      TARGET="$k"
      while [ "$LAST" != "$TARGET" ]; do
        echo "$TARGET"
        LAST="$TARGET"
        TARGET="$(readlink -f "$TARGET" || echo "$TARGET")"
      done
    done <<< "$KEEP"
HERE

docker run --rm --user root -v "$TEMPDIR":/mnt/strace $IN_IMAGE bash -c "$READLINKS" | sort -u > "$TEMPDIR"/keep.txt

# Make a sorted list of all the files in the image
docker run --rm --user root -v "$TEMPDIR":/mnt/strace -w /mnt/strace/ $IN_IMAGE \
  find / -path /proc -prune \
      -o -path /sys -prune \
      -o -path /mnt/strace -prune \
      -o -type f | sort -u > "$TEMPDIR"/all.txt

# Find files to exclude from the new image
comm -23 "$TEMPDIR"/all.txt "$TEMPDIR"/keep.txt | grep -v '/ld-[0-9.]*\.so' | grep -v '/ld\.so\.conf' | grep -v '/bin/bash$' > "$TEMPDIR"/exclude.txt

# Create a shrunken image by removing the files in the list
if [[ "$OUT_REPOSITORY" == *:* ]]; then
  SHRINK_TAG="$OUT_REPOSITORY-shrinking"
else
  SHRINK_TAG="$OUT_REPOSITORY:shrinking"
fi

cat >Dockerfile <<HERE	
FROM $IN_IMAGE

USER root

COPY exclude.txt /
RUN (cat /exclude.txt | grep -v "$(which rm)" | tr "\n" "\0" | xargs -0 rm -f | true) && \
    rm /exclude.txt

USER $DOCKERUSER
HERE

docker build . -t $SHRINK_TAG

# Make a flattened version of the image
CONTAINER_ID=$(docker create $SHRINK_TAG)
docker export $CONTAINER_ID | docker import - $OUT_REPOSITORY
docker rm $CONTAINER_ID

echo
echo "New image imported as '$OUT_REPOSITORY'."
echo "To run it use: docker run --rm $DOCKER_FLAGS $OUT_REPOSITORY $@"

