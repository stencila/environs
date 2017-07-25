# Shrink Docker

Usage: `shrink-docker.sh IN_IMAGE OUT_REPOSITORY[:TAG] COMMAND [ARG...]`

Shrinks `IN_IMAGE` down to just the files needed to run `COMMAND` and
saves result to `OUT_REPOISTORY`.

In order to run `strace` a new image will be derived from `IN_IMAGE`
with `strace` installed. This is installed with `apt-get`.

If you need to specify other command line options for `docker run`,
set the `DOCKER_FLAGS` environment variable.

## macOS
Not working yet.

## Warnings

### Different Commands or Input
Different commands or input may not work on the new image since the
may require different files.

### Nondeterminism
Even the same command may fail if some part of it is
nondeterministic (for instance if the set of files used from the
original docker image depends on the current time).

### Disk space usage
To make the new image all the files in the existing image will be
unpacked to a temporary working directory.  This will use a lot of disk space
in your temporary directory (usually `/tmp`).  To create the working
directory somewhere else set the `SHRINK_TEMP` environment variable
to the parent directory you would like the working directory to be
created in.
