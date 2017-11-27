all:
	@echo "Usage examples: "
	
	@echo " Build single language image"
	@echo "   make core/py-image"
	
	@echo " Build multi-language image"
	@echo "   make core-image"

	@echo " Clean up images"
	@echo "   make clean"

clean:
	nix-store --delete /nix/store/*-docker-image-stencila-*.tar.gz
	docker rmi -f $$(docker images | grep "^stencila/" | awk "{print \$$3}") 

%/node/node2nix: %/node/packages.json
	cd $@ && \
	node2nix -6 -i ../packages.json

%-image:
	nix-build $*
	docker load -i result

%-push:
	docker push stencila/$*:latest
