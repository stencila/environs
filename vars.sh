# If necesary, set environment variables
# We allow these to be set exernally for consistency between build.sh and push.sh:
#  - $STENCILA_IMAGES : allows branches for single image to build only a single image
#  - $STENCILA_TAG : the date may change between build and push for long running builds
if [ -z "$STENCILA_IMAGES" ]; then
	STENCILA_IMAGES=$(find -mindepth 1 -maxdepth 1 -type d -not -name '\.*' -printf '%P\n')
fi
if [ -z "$STENCILA_TAG" ]; then
	STENCILA_TAG=$(date --utc --iso-8601)
fi
