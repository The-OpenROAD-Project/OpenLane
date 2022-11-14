## Making Docker available without root (Linux)

:::{warning}
The steps below might become outdated. It is recommended to follow the link to the official Docker documentation here: [instructions here](https://docs.docker.com/engine/install/linux-postinstall/).
:::

:::{important}
This is a mandatory step. Without this, most OpenLane scripts will error out with permission issues. A majority of installation issues from users come from people skipping this so, once again, DO NOT SKIP!
:::

```sh
sudo groupadd docker
sudo usermod -aG docker $USER
sudo reboot # REBOOT!
```

You **must restart your operating system** for the group permissions to apply.