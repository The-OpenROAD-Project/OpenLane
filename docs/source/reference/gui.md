# Viewing layouts graphically

You can use `gui.py` to view final layout from a specified run and from the major stages of the flow. 
Available viewers are OpenROAD and KLayout.

## Usage

To view the final layout using OpenROAD:

```bash
make mount
python3 gui.py --viewer openroad ./designs/spm/runs/RUN_2023.05.28_13.36.45
```

To view the layout from `floorplan` stage:

```bash
make mount
python3 gui.py --viewer openroad --stage floorplan ./designs/spm/runs/RUN_2023.05.28_13.36.45
```

Finally, you can chose to open `def` view instead of `odb` view:

```bash
make mount
python3 gui.py --format def --viewer openroad --stage floorplan ./designs/spm/runs/RUN_2023.05.28_13.36.45
```

:::{note}
KLayout only supports def format.
:::

## Command-line interface (CLI)

| Argument | Description |
| - | - |
| `--viewer <viewer>`<br>(Optional) | The layout viewer, or tool, to display the layout. Available viewers are OpenROAD and KLayout.<br>Default: OpenROAD. |
| `--format <layout_format>`<br>(Optional) | The layout format to use. Available are `def` and `odb`. For KLayout, only `def` can be used.<br>Default: `def`. |
| `--stage <stage>`<br>(Optional) | The flow stage to fetch the layout from. `cts`, `floorplan`, `placement`, `routing` and `signoff`.<br>Default: Latest layout produced by the flow. |

