# Using PDKs

Process Design Kits, or PDKs, are files provided by a foundry that enables chips
to be implemented for a specific foundry process.

OpenLane supports multiple process design kits, so long that an OpenLane PDK
configuration file is made for them.

## Specifying your PDK

To specify your PDK in OpenLane 1, set the `PDK` environment variable as
follows:

```console
export PDK=gf180mcuD
```

Note that the PDK provided must be a fully qualified PDK variant, i.e.

* `sky130` ❌
* `sky130A` ⭕

## Standard Cell Libraries

Standard cells are small silicon patterns that are used to implement basic
functionality throughout your design that have already been designed and
analyzed for timing and other physical information. For example, the standard
cell `sky130_fd_sc_hd__and1` implements a logical AND.

Each PDK comes bundled with collections of standard cells known as "standard
cell libraries" or SCLs for short, some of which are foundry-provided and some
of which are third-party. Each OpenLane PDK configuration specifies a default
standard cell library, so you don't have to worry about picking one- but if you
want to anyway, use the `STD_CELL_LIBRARY` variable as follows:

```console
export STD_CELL_LIBRARY=sky130_fd_sc_hd
```

## Downloading PDKs

Most open-source PDKs are not usable in their default formats. This is the
reason we rely on Open PDKs to build the PDK, which will not only place it an
OpenLane-friendly layout but also generate views of the PDK that are usable by
the aforementioned tools.

Because of the extended build times, the two PDKs supported by Efabless, i.e.,
the [Skywater/Google 130nm PDK](https://github.com/google/skywater-pdk) and the
[GlobalFoundries/Google GF180MCU PDK](https://github.com/google/gf180mcu-pdk),
are built and cached using [Volare](https://github.com/efabless/volare), a
version manager by the OpenLane team built on top of Open PDKs.

To download the PDK using Volare, simply invoke `make pdk`. OpenLane is tested
with a specific revision of Open PDKs which is the one `make pdk` will pull.

## PDK Variants

There are multiple variants of each PDK (reflecting different metal stack
configurations):

* `sky130`
  * `sky130A`: The default. 5 metal layers and a local interconnect.
  * `sky130B`: Similar to `sky130A`, but also includes a Resistive RAM (ReRAM)
    layer between `metal1` and `metal2`. See
    [here](https://sky130-fd-pr-reram.readthedocs.io/en/latest/background.html)
    for more information. This affects timing as, for example, `via1` between
    `metal1` and `metal2` is twice as high.

Both variants are supported by OpenLane.

```{tip}
The variants are identical on the
[front end of line](https://en.wikipedia.org/wiki/Front_end_of_line),
and Efabless shuttles are "split-lot", i.e., two identical wafers come out of
FEOL are then subjected to different
[back end of line](https://en.wikipedia.org/wiki/Back_end_of_line) processes,
one for `A` and one for `B`.

Designs targeting a specific variant are packaged only from the appropriate
wafer, with its "twin" on the other wafer, which has timing issues at best and
is a dead chip at worst, is discarded.

All this to say: you can use either variant on any Efabless `sky130` shuttle
(but not within the same design.)
```

* `gf180mcu`
  * `gf180mcuA`: 3 metal layers.
  * `gf180mcuB`: 4 metal layers.
  * `gf180mcuC`: 5 metal layers.
  * `gf180mcuD`: 5 metal layers, with a slightly thicker top metal layer. The
    thinner top metal layer has issues with delamination on the pads according
    to GlobalFoundries.

[GFMPW0](https://platform.efabless.com/shuttles/GFMPW-0) was run on `C`, but any
and all future shuttles by Efabless will require `gf180mcuD` as per
GlobalFoundry's recommendation. `A` and `B` were never used and are not
supported by OpenLane.

## The PDK Root

The PDK root is a directory containing all of your open-source PDKs. OpenLane is
configured to use the PDK root at the following options (from highest to lowest
priority)"

* The `PDK_ROOT` environment variable
* A folder named `.volare` in your home directory.

The PDK root stores downloaded versions of the PDK as well as the Volare
metadata information.

Each PDK family, e.g., `sky130` or `gf180mcu`, has one active version at a time.
Versions of the PDKs are exactly equal to the `open_pdks` revision they were
built with.

### Using non-Volare PDKs

If you want to use PDKs without Volare (built manually), you will need to pass
this flag:

`--manual-pdk`

This will bypassing checking and attempting to download the PDK using Volare, so
you can add custom PDKs to the PDK root.

The PDKs must provide the following:

* An OpenLane PDK configuration file at the path
  `{pdk_root}/{pdk}/libs.tech/openlane/config.tcl`.

This Tcl-based config file must include default values for all variables listed
in the "User-Modifiable" and "Static" sections of
{doc}`/reference/pdk_configuration`.

* An standard cell library configuration file at the path
  `{pdk_root}/{pdk}/libs.tech/{scl}/openlane/config.tcl`.

This Tcl-based config file must include values for all non-optional variables in
the SCL-specific variables section of {doc}`/reference/pdk_configuration`.

It may be prudent to just copy these files from `sky130A` and use that as a
starting point, replacing files and values as you go.
