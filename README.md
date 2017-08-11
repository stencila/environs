## `stencila/images` : Stencila in containers

[![experimental](http://badges.github.io/stability-badges/dist/experimental.svg)](http://github.com/badges/stability-badges)
[![Build status](https://travis-ci.org/stencila/images.svg?branch=master)](https://travis-ci.org/stencila/images)
[![Community](https://img.shields.io/badge/join-community-green.svg)](https://community.stenci.la)
[![Chat](https://badges.gitter.im/stencila/stencila.svg)](https://gitter.im/stencila/stencila)

This repository provides images and tools for using Stencila within Docker containers. Use cases include:

- using Stencila packages for R, Python and Node.js without having to install them individually

- collaborating on a Stencila document using an identical computing environment

- publishing a Stencila document as a self-contained, reproducible, computational bundle

### Images

Our "comprehensive" images have a large number of packages installed and are intended to be sufficient for most data analysis tasks without having to install more packages. Out "minimal" images have just the bare essentials necessary for running a Stencila Host (the thing that provides execution contexts and other resources for each language).

Image                        | Summary
:----------------------------| :-----------------------------------------------------------------
[alpha (α)](alpha/README.md) | Comprehensive image for Python, R and/or Node.js
[iota (ι)](iota/README.md)   | Minimal image for Node.js
[rho (ρ)](rho/README.md)     | Comprehensive image for R

To use these images simply run them with the container's port 2000 bound to a port on the host (use a value in the range 2010-2100 so that it will be automatically be detected by the Stencila Desktop without clashing):

```bash
docker run -p 2100:2000 stencila/alpha
```

Each image is built each day, tagged with the date and pushed to the Docker Hub. This allows you to "pin" your Stencila document to a particular date's image, or to rollback to a particular date's image.

### Tools

Some of these images are large (i.e. ~1GB compressed). The [shrink-docker.sh](.shrink/shrink-docker.sh) script provides a way to shrink an image down to the minimum size necessary to reproduce your document.


### Contributions

Contributions are welcome!

#### Contributing a change

If you find yourself having to customize an image a lot, particularly if you need to add missing packages, chances are someone else is also having to do the same customization! That's a perfect time to contribute a change to the base image.

1. Create a fork of this repo repository

2. Edit the image's `Dockerfile`. For example, add a new R package,

	```sh
	RUN Rscript -e "\
	    install.packages(strsplit(' \
	      ...
	      awesome_package
	      ...
	```

3. Build the image

	```sh
	docker build images/alpha --tag stencila/alpha
	```

3. Test that your changes worked. e.g.

	```sh
	# Run a container using the image
	docker run -it stencila/alpha bash
	# Now, inside the container, open R
	R
	# Check that the package is available
	library(awesome_package)
	```

4. Create a Pull Request!


#### Contributing a new image

In some circumstances it may be better to contribute a new base image.

1. Choose a name for the image. We are currently using the names of Greek letters as a naming convention (although that means names are not descriptive, it keeps them short and consistent).

2. Create a new directory for your image under `images`

3. Write you own `Dockerfile` guided by the existing base images

4. Write a `README.md` which describes your container

5. Create a Pull Request!

