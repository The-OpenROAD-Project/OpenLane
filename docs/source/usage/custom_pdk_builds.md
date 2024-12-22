# Custom PDK Installations

The sky130 PDK variants pulled using `make pdk` include the following standard cell libraries:

* sky130_fd_io
* sky130_fd_pr
* sky130_fd_sc_hd
* sky130_fd_sc_hvl
* sky130 sram modules

If you need other libraries (including the ReRAM library for `sky130B`), you will have to download them using [Volare](https://github.com/efabless/volare) as shown below.

Start a venv shell using `make start-build-env`. You should see a prompt looking kind of like this:

```bash
(venv) [user@host openlane]$ 
```

Then, download the libraries as follows: The `-l` options are the libraries you want to include. For example, to download `sky130_fd_sc_hs`, you can add `-l sky130_fd_sc_hs` to your current set of libraries using the following command:

```bash
volare enable --pdk sky130 -l sky130_fd_sc_hs
```

You can also add `-l all` to just include all of them:

```bash
volare enable --pdk sky130 -l all
```

After it is done, your new SCLs are ready to use.
