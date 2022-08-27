# Top Module Generator

This program takes a chip core verilog file as well as a json description for the full chip with the desired IO pads connections, and auto generates the top level module of the chip including all the io pads and their connections, as well as automatically adding the power/corner pads.

## Command Line Arguments

The following are arguments that can be passed to `src/TopModuleGen.py`

<table>
    <tr>
        <th width="196">
        Argument
        </th>
        <th >
        Description
        </th>
    </tr>
    <tr>
        <td align="center">
            <code>--design | -d  &lt;JSON file&gt; </code> <br> (Required)
        </td>
        <td align="justify">
            Specifies The JSON description of the design.
        </td>
    </tr>
    <tr>
        <td align="center">
            <code>--padsLibs | -p &lt;JSON file&gt;</code> <br> (Required)
        </td>
        <td align="justify">
            Specifies the pad libraries JSON description.
        </td>
    </tr>
        <tr>
        <td align="center">
            <code>--verilog | -v &lt;verilog file&gt;</code> <br> (Required)
        </td>
        <td align="justify">
            The input verilog file containing the core module header definition.
        </td>
    </tr>
    <tr>
        </tr>
        <td align="center">
            <code>--output | -o &lt;file&gt;</code> <br> (Required)
        </td>
        <td align="justify">
            Specifies The verilog output file. 
        </td>
    </tr>
</table>

## The Design JSON description

### The Full Description

The json description of the design goes as follows:
```json
    {
    "design_name": <name of the top module>,
    "pads_library": <name of the io library to use>,
    "defines": <Any defines/macros to add>,
    "includes": <Any includes to add>,
    "module":{
        "name": <name of the chip core>,
        "pads": <list of the IO pads and their sources>
    },
    "extra_verilog: <any extra verilog lines that the user would like to be put as is in the top module>
    }
```

### Using Guards:
You can use guards in the defines or includes sections by following this format for the object. For example, below we provide a description for a guard block inside the includes section:
```json
{
    "inlcudes": [{...},
                {
                    "condition":{
                        "name": <The name of the guard>,
                        "def": [{ //This will be translated to the `ifdef
                            "name": <name of the first include>
                        },
                        {
                            "name": <name of the second include>
                        }
                        ],
                        "ndef":[ //This will be translated to the `ifndef
                            {
                                "name": <name of the first include>
                            },
                            {
                                "name":<name of the second include>
                            }
                        ]

                    }
                },
                {...},
                ....
    ]
}
```
The `def` and `ndef` sections are optional. But, at least on of them should exist inside a condition block.

Nested guards are supported. by starting an object in the list of objects under either `def` or `ndef` and starting it with `condition`, and following the same format.

### defines Block
It expects a list of objects that could either contain a `name: <name of the define>` or a [guard block](#using-guards)

```json
    {
        "defines":[
            {
                "name": <name of the define>
            },
            {<guard block>}
        ]

    }
```



### includes Block

It expects a list of objects that could either contain a `name: <name of the include>` or a [guard block](#using-guards)

```json
    {
        "includes":[
            {
                "name": <name of the include>
            },
            {<guard block>}

        ]
    }
```

### pads Block

The pads description is simply listing objects, each of them describes one pad as follows:

```json
    {
        "pads":[
            {...},
            {
                "name":<name of the interface/pad>,
                "size":<number>,
                "type":"DIGITAL_OUTPUT",//The type
                "output":< the connections from the core module to the pad>
            },
            {...},
            ...
        ]
    }
```

**Note:** The pad name and its connection must have different names in order to produce valid verilog code.

**Note:** If the `"type"` is `DIGITAL_OUTPUT` or `ANALOG_OUTPUT` then `"output":` should be used to describe the source connection from the core module. If it's a `DIGITAL_INPUT` or `ANALOG_OUTPUT`, then `"input":` should be used instead, and so on.

There are optional fields that you can specify for each pad. To know those fields and their mapping, run the `padHelper.py` script under [src](./src). Run it first with `-h` flag to know the options.


### size Block:

The size block used in the pad section or the macros section could be represented in one of the following forms:

1. Doesn't exist: The size is considered implicit in case of connection and `1` in case of declaration.
2. `"size": <number>` The number is used as the size.
3. `"size": {"start": <the start bit>, "offset": the offset}` The object description is to create a bus `[start+offset-1:start]`.

### Source Block:

The source (input/output) block could be described in any of the following ways:

1. `"input":["","",""]` list of string(s)
2. `"input":[{"name":<name of the connection>,"size": <size of the connection>},...]` list of objects that describe the name and size of the connections. Please check this [section](#size-block) to know the different size representations.

### Supported Pad Types

To show a list of supported pad types in a given PADs libraries json use the script `padHelper` under [./src](./src). Use the `-h` flag for the possible options.