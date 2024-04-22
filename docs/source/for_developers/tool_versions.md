# Updating Tool Versions

As a rule, tool versions match those of
[OpenLane 2](https://github.com/efabless/openlane2). A certain commit of
OpenLane 2 is pinned in `flake.lock`. The OpenLane 2 repo lists the tools under
`nix/`, where the commits for all tools are pinned within the requisite
derivations.

The pin of OpenLane 2 may be updated by running `nix flake lock --update-input`
at the root of the repo. This will set it to the latest commit in main.

<!--

## Overrides

The top-level `flake.nix` file may include overrides to the tool derivations
from OpenLane 2.

OpenROAD is included both as an example and as it is the one most people will
want to override anyway.

To update OpenROAD's revision, first run the command:

```sh
nix run nixpkgs#nix-prefetch -- fetchFromGitHub\
    --owner the-openroad-project --repo openroad --rev <REVISION>
```

At the end of execution, there should be a hash. Write it down (if you're
automating this, the hash is the only thing printed to stdout.)

Afterwards, in the top-level `flake.nix`, find this section:

```nix
openroad = openlane2.packages."${pkgs.system}".openroad.overrideAttrs(self: super: rec {
    rev = "0889970d1790a2617e69f253221b8bd7626e51dc";
    src = pkgs.fetchFromGitHub {
        owner = "The-OpenROAD-Project";
        repo = "OpenROAD";
        inherit rev;
        sha256 = "sha256-o8fwh+d1mpLvB3c1hVQFz3aqgstBvr1/sptKf+mh8Vc=";
    };
}); 
```

You will want to update the string for `rev =` to match your desired revision;
and `sha256 =` with the hash you wrote down earlier. (You can `sed` those in if
you're automating it for a CI or similar.)
-->
