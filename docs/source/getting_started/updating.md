# Updating OpenLane

Run following commands to update the OpenLane:

```
cd OpenLane/
git pull --depth 1 https://github.com/The-OpenROAD-Project/OpenLane.git master
make
make test # This is to test that the flow and the pdk were properly updated
```

It is very similar to installation, one difference is
that we pull the changes instead of creating a new workspace.
Git pull by default will not remove your files inside workspace.
