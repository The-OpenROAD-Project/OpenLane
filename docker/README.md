# OpenLane Docker Image

Since April 2024, the OpenLane build infrastructure has migrated to
[Nix](https://nixos.org), a declarative and reproducible build system. This was
done to streamline maintenance load.

This change has no bearing on the end-user experience, as it still
ultimately produces a Docker image. There are some minor adjustments, however:

* Individual tools are no longer cached as a Docker image, instead residing in
  [Cachix](https://cachix.org).
* The build scripts for the tools themselves reside in the OpenLane 2 repository
  at <https://github.com/efabless/openlane2>.
* Support for `ppc64le`, which was never actively tested, has been dropped.

## For developers - Getting Nix

Follow the instructions at <https://openlane.cachix.org>.

After everything is set up, from the repository's root directory, `make openlane`
as usual.
