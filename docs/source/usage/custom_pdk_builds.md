# Custom-Building PDKs
The pre-built version of the sky130 PDK variants included with OpenLane includes the following standard cell libraries:
* sky130_fd_io
* sky130_fd_pr
* sky130_fd_sc_hd
* sky130_fd_sc_hvl
* sky130 sram modules

If you need other libraries, you will have to resort to manual builds using [Ciel](https://github.com/fossi-foundation/ciel) as shown below. You will need Git 2.35+ and Docker.

Note that this will take a while, from 20 minutes to an hour depending on your internet speed and compute power.

Start a venv shell using `make start-build-env`. You should see a prompt looking kind of like this:

```bash
(venv) [user@host openlane]$ 
```

First of all, install ciel:

```bash
pip3 install --upgrade --no-cache-dir 'ciel>=2.0.1,<3'
```

Then, build the PDK as follows: The `-l` options are the libraries you want to include. For example, to also include `sky130_fd_sc_hs`, you can add `-l sky130_fd_sc_hs` to the default set of libraries using the following command:

```bash
ciel build -j$(nproc) --pdk sky130 --clear-build-artifacts --sram -l sky130_fd_io -l sky130_fd_pr -l sky130_fd_sc_hvl -l sky130_fd_sc_hd -l sky130_fd_sc_hs
```

You can also add `-l all` to just include all of them:

```bash
ciel build -j$(nproc) --pdk sky130 --clear-build-artifacts --sram -l all
```

Either way, go grab a smoothie. This will take a while.

After it is done, you can then enable the resulting PDK as such:

```bash
ciel enable
```

Et voila, your custom-built PDK is ready.
