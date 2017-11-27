all:
	@echo "Usage examples: "
	
	@echo " Build single language image"
	@echo "   make core/py-image"
	
	@echo " Build multi-language image"
	@echo "   make core-image"

	@echo " Clean up images"
	@echo "   make clean"

clean:
	nix-store --delete /nix/store/*-docker-image-{base,core,mega,node,py,r}.tar.gz
	nix-store --delete /nix/store/*-docker-layer-{base,core,mega,node,py,r}
	docker rmi -f $$(docker images | grep "^stencila/" | awk "{print \$$3}") 

%/node/node2nix: %/node/packages.json
	cd $@ && \
	node2nix -6 -i ../packages.json

%-image:
	nix-build $*
	docker load -i result

%-push:
	docker push stencila/$*:latest
