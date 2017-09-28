#!/usr/bin/env sh

# Run a Stencila Host in the background and ignore startup message
node -e "require('stencila-node').run()" > /dev/null &

# Sleep for a bit to allow Host to startup before prodding it for execution contexts
sleep 5

# Execute a document using the above Host to provide execution contexts etc
# In the future there will be no need to run separate processes jus something like:
#    node -e "require('stencila-node').execute('document.md')" 
# Currently disabled until an equivalent of `runner.js` is available again
#STENCILA_PEERS=http://localhost:2000 node node_modules/stencila/tools/runner.js document.md

sleep 50
kill $(pgrep node)
