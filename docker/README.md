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

Follow the instructions at <https://openlane2.readthedocs.io/en/latest/getting_started/common/nix_installation/index.html>.

After everything is set up, from the repository's root directory,
`make openlane` as usual.

## Overriding tool versions

As `tool_metadata.yml` no longer lists tools (only the PDK so Volare continues
to work,) overriding tool versions locally is done differently.

Tools included with OpenLane are listed in
https://github.com/efabless/openlane2/tree/overridable/nix. We've standardized
the function header to easily allow you to override the versions of tools.

Let's say, for instance, you'd like to override the revision for `magic`. First,
you'll check the `magic.nix` file for OpenLane 2: You'll find that the header
lists a `sha256` field in addition to either a `rev` (a git revision) or a
`version` (the version of the tool, minus any prefix `v`):

```nix
{
  …
  rev ? "bfd938b5e2321cf9a6c15f398fbc987b56fcc179",
  sha256 ? "sha256-xNhPnNGoJ8YiG6NFeFhOuKTB56rQvggJugIvukao6U8=",
}:
```

First, you'll open `flake.nix` and find a comment that says
`# ADD OVERRIDES HERE`. Below it, you'll add this override, with your desired
`rev` or `version` and sha256 equal to an empty string:

```nix
magic = openlane2.packages."${pkgs.system}".magic.override {
  rev = "ca99d0b76a82bc19a8b3213020ce3c135a28456e";
  sha256 = "";
};
```

Afterwards, invoke `nix build .#magic`. This will shortly fail with a message
that looks like this:

```log
error: hash mismatch in fixed-output derivation '/nix/store/i5pp79zmr4dngkr41z9ax75javz5456v-source.drv':
         specified: sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
            got:    sha256-aFFKbSqIgpkYjFZfpW3C52N1yQc5+KiLyf5jC16K5UU=
```

You'll want to go ahead and update the override with the `got` value as follows:


```nix
magic = openlane2.packages."${pkgs.system}".magic.override {
  rev = "ca99d0b76a82bc19a8b3213020ce3c135a28456e";
  sha256 = "sha256-aFFKbSqIgpkYjFZfpW3C52N1yQc5+KiLyf5jC16K5UU=";
};
```

And then invoke `nix build .#magic` again. Assuming the tool's build
instructions and dependencies have not changed, the build will be successful.
If the build instructions *have* changed, you will likely need to write a custom
Nix derivation for the tool in place of a simple override.

But anyway, that's it. Afterwards, `make openlane` will create a Docker image
with your new utility.

### Overriding versions for tools with dependencies

Magic is a straightforward example, but some tools have dependencies on other
tools, chiefly, `openroad`, which depends on `openroad-abc` and `opensta`.

In short, you will need to add overrides for all three tools as follows:

```nix
opensta = openlane2.packages."${pkgs.system}".opensta.override {
  rev = "a7f34210b403fe399c170296d54258f10f92885f";
  sha256 = "sha256-2R+ox0kcjXX5Kc6dtH/OEOccU/m8FjW1qnb0kxM/ahE=";
};
openroad-abc = openlane2.packages."${pkgs.system}".openroad-abc.override {
  rev = "d3916ac0337d599b30aeaf94e82b13338530ced3";
  sha256 = "sha256-osJzeOb0bgvbPGJjcpcfQzwcRJTZh1DYJ7RpFgw1NKg=";
};
openroad = openlane2.packages."${pkgs.system}".openroad.override {
  rev = "d423155d69de7f683a23f6916ead418a615ad4ad";
  sha256 = "sha256-RrJYdvzxD64TeNAlPs6G4BKxflpQO6ED78SqQVH7EUE=";
  opensta = self.packages."${pkgs.system}".opensta;
  openroad-abc = self.packages."${pkgs.system}".openroad-abc;
};
```

Do note:
  * You will need to do the whole `sha256` song and dance with all three.
  * You need to list the dependencies explicitly in the overrides of the 
    dependent using the syntax shown for `openroad`.

---

We understand this is more complex than the previous system; however
the benefits of using a build system and language designed specifically for 
use-cases similar to ours far outweighs the added complexity: including better
caching and reproducibility.

If you require any help overriding a tool, please feel free to open an issue.
