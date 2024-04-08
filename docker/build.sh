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
cat $TARBALL | docker load --platform=$BUILD_ARCH
nix store delete $TARBALL
docker build --platform=$BUILD_ARCH -t efabless/openlane:current-$BUILD_ARCH .
