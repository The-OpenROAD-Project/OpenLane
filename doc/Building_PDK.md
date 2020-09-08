# Manually Setting up the PDK: skywater-pdk

- Clone and build at least one skywater-pdk standard cell Library inside the pdks directory:
    - To setup one standard cell library only

    ```bash
        export PDK_BASE=<absolute path to where skywater-pdk and open_pdks will reside>
        cd  $PDK_BASE
        git clone git@github.com:google/skywater-pdk.git
        cd skywater-pdk
        git checkout 3f310bcc264df0194b9f7e65b83c59759bb27480
        git submodule update --init libraries/sky130_fd_sc_hd/latest
        make sky130_fd_sc_hd
    ```
    - To setup other SCLs:
        - replace sky130_fd_sc_hd with any of the following list:
            - sky130_fd_sc_hs
            - sky130_fd_sc_ms
            - sky130_fd_sc_ls
            - sky130_fd_sc_hdll

- Setup the configurations and tech files for Magic, Netgen, OpenLANE using [open_pdks](https://github.com/RTimothyEdwards/open_pdks):

    ```bash
        cd $PDK_BASE
	    git clone git@github.com:RTimothyEdwards/open_pdks.git
        cd open_pdks
        git checkout 52f78fa08f91503e0cff238979db4589e6187fdf
        ./configure --with-sky130-source=$PDK_BASE/skywater-pdk/libraries --with-sky130-local-path=$PDK_BASE
		cd sky130
		make
		make install-local
    ```

- Create a symbolic link to be accessible by the docker:

    ```bash
        ln -s $PDK_BASE /pdks
    ```

**Note**: You can use different directories for sky130-source and local-path. However, in the instructions we are using $PDK_ROOT to facilitate the installation process


Alternatively you can use [this repo](https://github.com/efabless/sky130A-prebuilt) and use the instructions there to reproduce the PDK on the same or a different commit/version.