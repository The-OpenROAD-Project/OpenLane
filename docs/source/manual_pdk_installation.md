**DISCLAIMER: The following sections are to give you an understanding of what happens under the hood in the Makefile.**

# Prerequisites

 - [Magic VLSI Layout Tool](http://opencircuitdesign.com/magic/index.html) is needed to run open_pdks -- version >= 8.3.60*

# Setting up the PDK: skywater-pdk

- Clone and build at least one [skywater-pdk](https://github.com/google/skywater-pdk) standard cell Library inside the pdks directory:
    - To setup one standard cell library only

    ```bash
        export PDK_ROOT=<absolute path to where skywater-pdk and open_pdks will reside>
        cd  $PDK_ROOT
        git clone https://github.com/google/skywater-pdk.git
        cd skywater-pdk
        git checkout 00bdbcf4a3aa922cc1f4a0d0cd8b80dbd73149d3
        git submodule update --init libraries/sky130_fd_sc_hd/latest
        git submodule update --init libraries/sky130_fd_sc_hvl/latest
        git submodule update --init libraries/sky130_fd_io/latest
        make timing
    ```
    - To setup other SCLs:
        - replace sky130_fd_sc_hd with any of the following list:
            - sky130_fd_sc_hs
            - sky130_fd_sc_ms
            - sky130_fd_sc_ls
            - sky130_fd_sc_hdll

- Setup the configurations and tech files for Magic, Netgen, OpenLane using [open_pdks](https://github.com/RTimothyEdwards/open_pdks):

    ```bash
        cd $PDK_ROOT
        git clone git://opencircuitdesign.com/open_pdks
        cd open_pdks
        git checkout d8c159536699c9b4a08b650bddf791a9d48152f9
        ./configure --enable-sky130-pdk=$PDK_ROOT/skywater-pdk/libraries --with-sky130-local-path=$PDK_ROOT --enable-sram-sky130=disabled
        cd sky130
        make
        make install-local
    ```

**Note**: You can use different directories for sky130-source and local-path. However, in the instructions we are using $PDK_ROOT to facilitate the installation process

**WARNING**: Please, don't move `sky130A` from the installed directory because the generated .mag files contain absolute paths. Moving it will result in producing an invalid GDS.

 - To set the STD_CELL_LIBRARY (the default value is set to sky130_fd_sc_hd)
    - Open [configuration/general.tcl](../../configuration/general.tcl)
    - set STD_CELL_LIBRARY to one of the following:

            - sky130_fd_sc_hs
            - sky130_fd_sc_ms
            - sky130_fd_sc_ls
            - sky130_fd_sc_hdll

Refer to [this][1] for more details on the structure.

[1]: ./PDK_STRUCTURE.md
