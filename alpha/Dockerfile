# Base for the Stencila `alpha` channel of Docker images

# Currently this is optimised for development (rebuild times) and not
# for images sizes (will refactor for that later)

FROM stencila/nix

# Setup working environment.
# This needs to be done before any node packages are installed so that they are
# available form `~/node_modules/` to be `require()`d (global modules cannot be)

USER guest

COPY default.nix default.nix
COPY node node

RUN nix-env . -i . && nix-collect-garbage
RUN nix-env -i bash && nix-collect-garbage

RUN nix-shell -j 4 --command 'nix-collect-garbage'
RUN nix-shell --command 'exit 0'

# Copy environment reflection script
COPY environ.sh .environ.sh
USER root
RUN chmod +x .environ.sh
USER guest

# Copy README.md
COPY README.md .

# Install Stencila packages as guest user so that the
# host files are in home directory
RUN nix-shell --command "node -e 'require(\"stencila-node\").install()'"
RUN nix-shell --command "python -c 'import stencila; stencila.install()'"
RUN nix-shell --command "Rscript -e 'stencila:::install()'"

# Turn off authorization for all Stencila hosts
ENV STENCILA_AUTHORIZATION false

CMD ["nix-shell", "--command", "node -e 'require(\"stencila-node\").run(\"0.0.0.0\", 2000)'"]
