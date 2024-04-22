# Copyright 2024 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
{
  nixConfig = {
    extra-substituters = [
      "https://openlane.cachix.org"
    ];
    extra-trusted-public-keys = [
      "openlane.cachix.org-1:qqdwh+QMNGmZAuyeQJTH9ErW57OWSvdtuwfBKdS254E="
    ];
  };

  inputs = {
    openlane2.url = github:efabless/openlane2;
  };

  outputs = {
    self,
    openlane2,
    nix,
    ...
  }: let
    nixpkgs = openlane2.inputs.nixpkgs;
  in {
    # Helper functions
    forAllSystems = function:
      nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ] (
        system:
          function (import nixpkgs {
            inherit system;
            overlays = [];
          })
      );

    # Outputs
    packages = self.forAllSystems (pkgs: let
      callPackage = pkgs.lib.callPackageWith (pkgs // openlane2.packages."${pkgs.system}" // self.packages.${pkgs.system} );
      callPythonPackage = pkgs.lib.callPackageWith (pkgs // pkgs.python3.pkgs // openlane2.packages."${pkgs.system}" // openlane2.inputs.libparse.packages."${pkgs.system}" // self.packages.${pkgs.system});
    in
      rec {
        openlane1 = callPythonPackage ./default.nix {};
        default = openlane1;
      }
      // (pkgs.lib.optionalAttrs (pkgs.stdenv.isLinux) {openlane1-docker = callPackage ./docker/docker.nix {
        dockerImage = nix.dockerImage;
      };}));

    # devShells = self.forAllSystems (
    #   pkgs: let
    #     callPackage = pkgs.lib.callPackageWith (pkgs // self.packages.${pkgs.system});
    #     callPythonPackage = pkgs.lib.callPackageWith (pkgs // pkgs.python3.pkgs // self.packages.${pkgs.system});
    #   in rec {
    #   }
    # );
  };
}
