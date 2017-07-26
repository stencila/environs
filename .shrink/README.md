# Shrink Docker

Usage: `shrink-docker.sh IN_IMAGE OUT_REPOSITORY[:TAG] COMMAND [ARG...]`

Shrinks `IN_IMAGE` down to just the files needed to run `COMMAND` and
saves result to `OUT_REPOISTORY`.

If you need to specify other command line options for `docker run`,
set the `DOCKER_FLAGS` environment variable.

## Intermediate Images Created

### `IN_IMAGE:strace` (or `IN_IAMGE:TAG-strace`)
In order to run `strace` a new image will be derived from `IN_IMAGE`
with `strace` installed. This is installed with `apt-get`.

### `OUT_REPOSITORY:shrinking` (or `OUT_REPOSITORY:TAG-shrinking`)
This image has all the unused files removed.
The `OUT_REPOSITORY[:TAG]` is a flattened version of this image.

## macOS
You may need to set the `SHRINK_TEMP` environment variable to point
to a subdirectory of a directory in your File Sharing list in the
Docker preferences.  The default location for temporary files in
macOS is not in this list by default.

## Warnings

### Different Commands or Input
Different commands or input may not work on the new image since the
may require different files.

### Nondeterminism
Even the same command may fail if some part of it is
nondeterministic (for instance if the set of files used from the
original docker image depends on the current time).