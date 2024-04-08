set -x
set -e
TARBALL=$(nix build\
	--no-link\
	--print-out-paths\
	--accept-flake-config\
	--accept-flake-config\
	--option system $NIX_SYSTEM\
	--extra-platforms $NIX_SYSTEM\
	..#packages.$NIX_SYSTEM.openlane1-docker)
cat $TARBALL | docker load
nix store delete $TARBALL
if [ "$BUILD_ARCH" = "amd64" ]; then
	PLATFORM_STRING="linux/amd64"	
fi
if [ "$BUILD_ARCH" = "arm64v8" ]; then
	PLATFORM_STRING="linux/arm64/v8"
fi
docker build --platform=$PLATFORM_STRING --build-arg="PLATFORM=$BUILD_ARCH" -t efabless/openlane:current-$BUILD_ARCH .
