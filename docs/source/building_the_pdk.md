# Building the PDK
The pre-built version of the sky130 PDK variants included with OpenLane includes the following standard cell libraries:
* sky130_fd_io
* sky130_fd_pr
* sky130_fd_sc_hd
* sky130_fd_sc_hvl
* sky130 sram modules

If you need other libraries, you will have to resort to manual builds as shown below. There are two methods. You will need Git 2.35+ and Docker for either method.

Note that either method will take a while, from 20 minutes to an hour depending on your internet speed and compute power.

## Volare Method
Start a venv shell using `make start-build-env`. You should see a prompt looking kind of like this:

```bash
(venv) [user@host openlane]$ 
```

Install the [volare](https://github.com/efabless/volare) PDK builder and version manager:

```bash
pip3 install --upgrade --no-cache-dir volare
```

Then, build the PDK as follows: The `-l` options are the libraries you want to include. For example, you can add `sky130_fd_sc_hs` to the default set of libraries using the following command:

```bash
volare build -j$(nproc) --pdk sky130 --clear-build-artifacts --sram -l sky130_fd_io -l sky130_fd_pr -l sky130_fd_sc_hvl -l sky130_fd_sc_hd -l sky130_fd_sc_hs
```

You can then enable the resulting PDK as such:

```bash
volare enable
```

Et voila, your custom-build PDK is ready.

## Conda/Make Method (Legacy)
```bash
    <configuration variables: see notes below>
    make build-pdk-conda
```
* The default pdk installation directory is $PWD/pdks. If you want to install the PDK at a different location, you'll need add this configuration variable:
    * `export PDK_ROOT=<absolute path to where skywater-pdk and open_pdks will reside>`
        * Be sure to add this to your shell's profile for future use.
* The default SCL to be installed is `sky130_fd_sc_hd`.
    * To change that, you can add this configuration variable: `export STD_CELL_LIBRARY=<Library name, i.e. sky130_fd_sc_ls>`, where the library name is one of:
        - sky130_fd_sc_hd
        - sky130_fd_sc_hs
        - sky130_fd_sc_ms
        - sky130_fd_sc_ls
        - sky130_fd_sc_hdll
    * You can install all Sky130 SCLs by invoking `FULL_PDK=1 make build-pdk-conda`.
    * You can install the PDK manually, outside of the Makefile, by following the instructions provided [here][30].
    * Refer to [this][24] for more details on OpenLane-compatible PDK structures.
