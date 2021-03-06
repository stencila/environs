## `stencila/environs` : Stencila within reproducible execution environments

[![experimental](http://badges.github.io/stability-badges/dist/experimental.svg)](http://github.com/badges/stability-badges)
[![Build status](https://travis-ci.org/stencila/environs.svg?branch=master)](https://travis-ci.org/stencila/environs)
[![Community](https://img.shields.io/badge/join-community-green.svg)](https://community.stenci.la)
[![Chat](https://badges.gitter.im/stencila/stencila.svg)](https://gitter.im/stencila/stencila)

This repository provides environs and tools for using Stencila within containers. Use cases include:

- using Stencila packages for R, Python and Node.js without having to install them individually

- collaborating on a Stencila document using an identical computing environment

- publishing a Stencila document as a self-contained, reproducible, computational bundle

### Images

The minimal base images have just the bare essentials necessary for running a Stencila Host (the thing that provides execution contexts and other resources for each language). The "comprehensive" images have a large number of packages installed and are intended to be sufficient for most data analysis tasks without having to install more packages. 

Image                        | Summary
:----------------------------| :-----------------------------------------------------------------
[base](base)                 | A base image with Stencila packages for Python, R and/or Node.js
[core](core)                 | An image with commonly used packages for data analysis in each language
[mega](mega)                 | Comprehensive images with _a lot_ of packages for each language

To use these images simply run them with the container's port 2000 bound to a port on the host. Use a value in the range 2010-2100 so that it will be automatically be detected by the Stencila client (e.g. Stencila Desktop) without clashing:

```bash
docker run -it --rm -p 2100:2000 stencila/core
```

### Tools

Some of these images are large (i.e. ~1GB compressed). The [shrink-docker.sh](.shrink/shrink-docker.sh) script provides a way to shrink an image down to the minimum size necessary to reproduce your document.


### Develop

### Updating Node.js packages

Node.js environments, such as `nix/core/node`, are built using [`node2nix`](https://github.com/svanderburg/node2nix). You can install `node2nix` using:

```bash
nix-env -f '<nixpkgs>' -iA nodePackages.node2nix
```

`node2nix` generates the files `node2nix/default.nix`, `node2nix/node-packages.nix` and `node2nix/node-env.nix` from `packages.json`. If you update a `packages.json` then re-generate these files using `node2nix` directly:

```bash
cd nix/core/node/node2nix
node2nix -6 -i ../packages.json
```

or using the `Makefile` recipe:

```bash
make nix/core/node/node2nix
```

### Adding package fetched from git

Use `nix-prefetch-git` to get the `sha256` when specifying a package using `nixpkgs.fetchgit` e.g.

```bash
nix-prefetch-git https://github.com/stencila/r 4ebd3a8106294060316574eb340c7108542f722a
```

## Run Stencila in a Nix shell

On NixOS or other linux with Nix installed run:

```
nix-shell core
```

To 

```
nix-shell core/r
```

Within the Nix shell, three Stencila scripts are available

- `stencila-manifest`: display a JSON manifest of the Stencila hosts and the packages installed within each
- `stencila-register`: register the Stencila hosts so that they can discover each another within the environment
- `stencila-run`: run the primary Stencila host in the environment


## Run Stencila in a Docker Container

On NixOS, or Linux with Nix installed, run:

```bash
nix-build core/r
````

This will create a tar archived Docker container in your Nix store e.g. `/nix/store/ci3k7fwnza75r9hg3wv0ab9c8544hmj8-docker-image-core-r.tar.gz` and a symlink to that file in the current directory called `result`.

Load that tar archive as a Docker image using:

```bash
docker load -i result
```

Then run the image:

```bash
docker run -it --rm -p 2100:2000 stencila/core/r
```

To recover space you can clean up the Docker tar archive with:

```bash
nix-store --delete /nix/store/*-docker-image-stencila-*.tar.gz
```