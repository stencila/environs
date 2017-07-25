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
  echo "  Usage: $0 IN_IMAGE OUT_REPOSITORY[:TAG] COMMAND [ARG...]"
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

cd "$TEMPDIR"
cat >Dockerfile <<HERE	
FROM $IN_IMAGE

RUN apt-get update && \\
    apt-get -y --no-install-recommends install strace && \\
    rm -rf /var/lib/apt/lists/*
HERE

docker build . -t $STRACE_TAG

# Make sure stripdoc/strace.out is not created by docker (since then we may not have permission to delete it)
touch "$TEMPDIR"/strace.out
docker run --rm -v "$TEMPDIR":/mnt/strace $DOCKER_FLAGS $STRACE_TAG strace -f -o /mnt/strace/strace.out "$@"

# Make a sorted list of the files we need to keep based on the strace output
read -r -d '' READLINKS <<-'HERE' || true
    KEEP=$(egrep '^[0-9]* *(access|open|execve|stat)\(\"' /mnt/strace/strace.out | sed 's/^[0-9]* *\(access\|open\|execve\|stat\)("\([^"]*\)".*$/\2/' | sort -u)
    while read -r k; do
      LAST=""
      TARGET="$k"
      while [ "$LAST" != "$TARGET" ]; do
        echo ".$TARGET"
        LAST="$TARGET"
        TARGET="$(readlink -f "$TARGET" || echo "$TARGET")"
      done
    done <<< "$KEEP"
HERE

docker run --rm --cap-add SYS_PTRACE -v "$TEMPDIR":/mnt/strace -w /mnt/strace/ $IN_IMAGE bash -c "$READLINKS" | sort -u > "$TEMPDIR"/keep.txt

# Unpack all the files in the image
mkdir "$TEMPDIR"/files
CONTAINER_ID=$(docker create $IN_IMAGE)
(cd "$TEMPDIR"/files && (docker export $CONTAINER_ID | tar -x))
docker rm $CONTAINER_ID

# Make a sorted list of all the files (not symlinks since we want to keep them)
(cd "$TEMPDIR"/files && (find . -type f | sort > "$TEMPDIR"/all.txt))

# Find files to exclude from the new image
comm "$TEMPDIR"/all.txt "$TEMPDIR"/keep.txt -2 -3 | grep -v '/ld-[0-9.]*\.so' | grep -v '/ld\.so\.conf' | grep -v '/bin/bash$' > "$TEMPDIR"/exclude.txt

echo Importing
cat "$TEMPDIR"/exclude.txt > "$TEMPDIR"/exclude2.txt
# Import the files back into the new repository (excluding those we want to leave out)
(cd "$TEMPDIR"/files && (tar -c --exclude-from="$TEMPDIR"/exclude2.txt . | docker import - $OUT_REPOSITORY))

echo
echo "New image imported as '$OUT_REPOSITORY'."
echo "To run it use: docker run --rm $DOCKER_FLAGS $OUT_REPOSITORY $@"

