all:
	@echo "Usage examples: "
	
	@echo " Build single language image"
	@echo "   make core-py"
	
	@echo " Build multi-language image"
	@echo "   make base-node"
	@echo "   make core-"

	@echo " Clean up:"
	@echo "   make clean"

clean:
	rm -rf ./*/node/node2nix/

%/node/node2nix: %/node/packages.json
	mkdir -p $@ && \
	cd $@ && \
	node2nix -6 -i ../packages.json

%-node: %/node/node2nix
	nix-build $*/node

%-r:
	nix-build $*/r

%-py:
	nix-build $*/py

%-:
	$(MAKE) $*/node/node2nix
	nix-build $*
