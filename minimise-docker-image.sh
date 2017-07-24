#!/bin/sh
set -e

if [ $# -lt 3 ]; then
  echo "Strips IN_IMAGE down to just the files needed to run COMMAND."
  echo "Saves result to OUT_REPOISTORY and runs the command again to check."
  echo 
  echo "WARNING: If different commands or input may not work on the new image."
  echo  	
  echo "  Usage: $0 IN_IMAGE OUT_REPOSITORY[:TAG] COMMAND [ARG...]"
  exit 1
fi

function cleanup {
  if [ -n "$TEMPDIR" -a -d "$TEMPDIR" ]; then
    chmod +w -R "$TEMPDIR"
    rm -fR "$TEMPDIR"
  fi
}

trap cleanup EXIT

TEMPDIR=$(mktemp -d)

IN_IMAGE=$1
shift
OUT_REPOSITORY=$1
shift

# Make sure stripdoc/strace.out is not created by docker (since then we may not have permission to delete it)
touch "$TEMPDIR"/strace.out
docker run --rm -v "$TEMPDIR":/mnt/strace -v `pwd`:/code -v `pwd`/input:/input -v `pwd`/output:/output -v `pwd`/publish:/publish -w /code/talk-mpi-seven-by-seven-2017 --memory 1000000000b --memory-swap 1000000000b --cpu-period 25000 --cpu-quota 25000 -e PARAMETERS='{"env":null,"refresh":null,"memory":null,"docker":null,"cpus":null,"databases":null,"publish":null}' -e OUTPUTDIR=/output/ -e INPUTDIR=/input/ $IN_IMAGE strace -f -o /mnt/strace/strace.out "$@"
#docker run --rm -v "$TEMPDIR":/mnt/strace $IN_IMAGE strace -f -o /mnt/strace/strace.out "$@"

# Unpack all the files in the image
mkdir "$TEMPDIR"/files
CONTAINER_ID=$(docker create $IN_IMAGE)
(cd "$TEMPDIR"/files && (docker export $CONTAINER_ID | tar -x --warning=all))
docker rm $CONTAINER_ID

# Make a sorted list of all the files (not symlinks since we want to keep them)
(cd "$TEMPDIR"/files && (find . -type f | sort > "$TEMPDIR"/all.txt))

# Make a sorted list of the files we need to keep based on the strace output
KEEP=$(egrep '^[0-9]* *(access|open|execve|stat)\(\"' "$TEMPDIR"/strace.out | sed 's/^[0-9]* *\(access\|open\|execve\|stat\)("\([^"]*\)".*$/\2/' | sort -u)
while read -r k; do
  LAST=""
  TARGET="$k"
  while [ "$LAST" != "$TARGET" ]; do
    echo ".$TARGET"
    LAST="$TARGET"
    TARGET="$(readlink "$TEMPDIR"/files/"$TARGET" || echo "$TARGET")"
    TARGET="$(realpath -s --relative-to="$TEMPDIR"/files/"$LAST" "$TARGET")
    TARGET="${TARGET##$TEMPDIR/files}"
  done
done <<< "$KEEP" | sort -u > "$TEMPDIR"/keep.txt

# Find files to exclude from the new image
comm "$TEMPDIR"/all.txt "$TEMPDIR"/keep.txt -2 -3 | grep -v '/ld-[0-9.]*.so' | grep -v '/bin/bash$' > "$TEMPDIR"/exclude.txt

echo Importing
# Import the files back into the new repository (excluding those we want to leave out)
(cd "$TEMPDIR"/files && (tar -c --exclude-from="$TEMPDIR"/exclude.txt . | docker import - $OUT_REPOSITORY))

echo Running
# Check the command still runs
#docker run --rm -v "$TEMPDIR":/mnt/strace $IN_IMAGE -v `pwd`:/code -v `pwd`/input:/input -v `pwd`/output:/output -v `pwd`/publish:/publish -w /code/talk-mpi-seven-by-seven-2017 --memory 1000000000b --memory-swap 1000000000b --cpu-period 25000 --cpu-quota 25000 -e PARAMETERS='{"env":null,"refresh":null,"memory":null,"docker":null,"cpus":null,"databases":null,"publish":null}' -e OUTPUTDIR=/output/ -e INPUTDIR=/input/ strace -f -o /mnt/strace/strace.out "$@"
#docker run --rm $OUT_REPOSITORY "$@"

echo
echo "New image imported as '$OUT_REPOSITORY'."

