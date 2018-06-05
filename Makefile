usage:
	@echo "Usage: "

	@echo " Setup (e.g. install build and test tools)"
	@echo "   make setup"
	
	@echo " Generate Nix packages from NPM packages e.g"
	@echo "   make images/core/node/node2nix"

	@echo " Build an image (note trailing slash) e.g"
	@echo "   make images/core/py/"
	@echo "   make images/core/"
	
	@echo " Build all images (warning slow!)"
	@echo "   make images/all"

	@echo " Build docs"
	@echo "   make docs"

	@echo " Push images (e.g. to Docker hub) e.g"
	@echo "   make push IMAGE=core/py"
	@echo "   make push #all images"

	@echo " Clean up (e.g. remove images in /nix/store)"
	@echo "   make clean"

# Reduce verbosity when run on continuous integration servers
# If there is too little output Travis thinks the build has stalled
# So don't use --quiet option
ifeq ($(CI),true)
NIX_BUILD_OPTIONS := --no-build-output
endif

IMAGES := $(shell find images -mindepth 1 -maxdepth 2 -type d -printf '%P\n')

# Hacks for joining words separated by spaces into words separated by commas
SPACE :=
SPACE +=
COMMA := ,

setup:
	nix-env -f '<nixpkgs>' -iA nodePackages.node2nix
	mkdir -p tests/libs
	git clone --depth=1 https://github.com/sstephenson/bats tests/libs/bats
	git clone --depth=1 https://github.com/ztombol/bats-support tests/libs/bats-support
	git clone --depth=1 https://github.com/ztombol/bats-assert tests/libs/bats-assert

%/node/node2nix: %/node/packages.json
	cd $@ && node2nix -8 -i ../packages.json

%/: FORCE
	nix-build $(NIX_BUILD_OPTIONS) $*
	docker load -i result

images/all: $(patsubst %,%/,$(IMAGES))


# Manifest JSON for an image
docs/%/manifest.json: FORCE
	@mkdir -p $(dir $@)
	nix-shell images/$* --run stencila-manifest > $@

# Manifest JSON for all images plus a JSON array of images
docs: $(patsubst %,docs/%/manifest.json,$(IMAGES))
	echo '["$(subst $(SPACE),"$(COMMA)",$(IMAGES))"]' > docs/images.json


test:
	cd tests && ./test.sh

clean:
	rm -rf tests/libs
	nix-store --delete /nix/store/*-docker-image-{base,core,mega,node,py,r}.tar.gz
	nix-store --delete /nix/store/*-docker-layer-{base,core,mega,node,py,r}
	docker rmi -f $$(docker images | grep "^stencila/" | awk "{print \$$3}")

FORCE:
.PHONY: docs
