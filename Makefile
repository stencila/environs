usage:
	@echo "Usage: "

	@echo " Setup (e.g. install build and test tools)"
	@echo "   make setup"
	
	@echo " Generate Nix packages from NPM packages e.g"
	@echo "   make core/node/node2nix"

	@echo " Build an image (note trailing slash) e.g"
	@echo "   make core/py/"
	@echo "   make core/"
	
	@echo " Build all images (warning slow!)"
	@echo "   make all"

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

setup:
	nix-env -f '<nixpkgs>' -iA nodePackages.node2nix
	mkdir -p .test/libs
	git clone --depth=1 https://github.com/sstephenson/bats .test/libs/bats
	git clone --depth=1 https://github.com/ztombol/bats-support .test/libs/bats-support
	git clone --depth=1 https://github.com/ztombol/bats-assert .test/libs/bats-assert

%/node/node2nix: %/node/packages.json
	cd $@ && node2nix -6 -i ../packages.json

IMAGES := $(shell find -mindepth 1 -maxdepth 2 -type d -not -path '\./\.*' -printf '%P\n')

%/: FORCE
	nix-build $(NIX_BUILD_OPTIONS) $*
	docker load -i result
FORCE:

all: $(patsubst %,%/,$(IMAGES))

test:
	cd .test && ./test.sh

clean:
	rm -rf ./.test/libs
	nix-store --delete /nix/store/*-docker-image-{base,core,mega,node,py,r}.tar.gz
	nix-store --delete /nix/store/*-docker-layer-{base,core,mega,node,py,r}
	docker rmi -f $$(docker images | grep "^stencila/" | awk "{print \$$3}")
