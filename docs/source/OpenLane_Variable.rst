==================
OpenLane Variables
==================

Configuration file
-------------------

The variable information and their default value are given below:

Required variables
------------------

+-----------------------------------+-----------------------------------+
| Variable                          | Description                       |
+===================================+===================================+
| ``PLATFORM``                      |   Specifies Process design kit    |
|                                   |                                   |  
+-----------------------------------+-----------------------------------+
| ``DESIGN_NAME``                   | The name of the top level module  |
|                                   | of the design                     |
+-----------------------------------+-----------------------------------+
| ``VERILOG_FILES``                 | The path of the design’s verilog  |
|                                   | files, space-delimited.           |
+-----------------------------------+-----------------------------------+
| ``CLOCK_PERIOD``                  | The clock period for the design   |
|                                   | in nanoseconds.                   |
+-----------------------------------+-----------------------------------+
| ``CLOCK_NET``                     | The name of the net input to root |
|                                   | clock buffer used in Clock Tree   |
|                                   | Synthesis.                        |
+-----------------------------------+-----------------------------------+
| ``CLOCK_PORT``                    | The name of the design’s clock    |
|                                   | port used in Static Timing        |
|                                   | Analysis.                         |
+-----------------------------------+-----------------------------------+

Optional variables
------------------

These variables are optional that can be specified in the design
configuration file.

Synthesis
~~~~~~~~~

+-----------------------------------+-----------------------------------+
| Variable                          | Description                       |
+===================================+===================================+
| ``SYNTH_BIN``                     | The yosys binary used in the      |
|                                   | flow. (Default: ``yosys``)        |
+-----------------------------------+-----------------------------------+
| ``SYNTH_CAP_LOAD``                | The capacitive load on the output |
|                                   | ports in femtofarads. (Default:   |
|                                   | ``33.5`` ff)                      |
+-----------------------------------+-----------------------------------+
| ``SYNTH_MAX_FANOUT``              | The max load that the output      |
|                                   | ports can drive. (Default: ``5``  |
|                                   | cells)                            |
+-----------------------------------+-----------------------------------+
| ``SYNTH_MAX_TRAN``                | The max transition time (slew)    |
|                                   | from high to low or low to high   |
|                                   | on cell inputs in ns. Used in     |
|                                   | synthesis (Default: Calculated at |
|                                   | runtime as ``10%`` of the         |
|                                   | provided clock period, unless     |
|                                   | this exceeds a set                |
|                                   | DEFAULT_MAX_TRAN, in which case   |
|                                   | it will be used as is).           |
+-----------------------------------+-----------------------------------+
| ``SYNTH_CLOCK_UNCERTAINITY``      | Specifies a value for the clock   |
|                                   | uncertainity in the pre-CTS       |
|                                   | stages. (Default: ``0.25``)       |
+-----------------------------------+-----------------------------------+
| ``SYNTH_CLOCK_TRANSITION``        | Specifies a value for the clock   |
|                                   | transition in the pre-CTS stages. |
|                                   | (Default: ``0.15``)               |
+-----------------------------------+-----------------------------------+
| ``SYNTH_TIMING_DERATE``           | Specifies a derating factor to    |
|                                   | multiply the path delays with. It |
|                                   | specifies the upper and lower     |
|                                   | ranges of timing. (Default:       |
|                                   | ``+5%/-5%``)                      |
+-----------------------------------+-----------------------------------+
| ``SYNTH_STRATEGY``                | Strategies for abc logic          |
|                                   | synthesis and technology mapping  |
|                                   | Possible values are               |
|                                   | ``DELAY/AREA 0-4/0-3``; the first |
|                                   | part refers to the optimization   |
|                                   | target of the synthesis strategy  |
|                                   | (area vs. delay) and the second   |
|                                   | one is an index. (Default:        |
|                                   | ``AREA 0``)                       |
+-----------------------------------+-----------------------------------+
| ``SYNTH_BUFFERING``               | Enables abc cell buffering        |
|                                   | Enabled = 1, Disabled = 0         |
|                                   | (Default: ``1``)                  |
+-----------------------------------+-----------------------------------+
| ``SYNTH_SIZING``                  | Enables abc cell sizing (instead  |
|                                   | of buffering) Enabled = 1,        |
|                                   | Disabled = 0 (Default: ``0``)     |
+-----------------------------------+-----------------------------------+
| ``SYNTH_READ_BLACKBOX_LIB``       | A flag that enable reading the    |
|                                   | full(untrimmed) liberty file as a |
|                                   | blackbox for synthesis. Please    |
|                                   | note that this is not used in     |
|                                   | technology mapping. This should   |
|                                   | only be used when trying to       |
|                                   | preserve gate instances in the    |
|                                   | rtl of the design. Enabled = 1,   |
|                                   | Disabled = 0 (Default: ``0``)     |
+-----------------------------------+-----------------------------------+
| ``SYNTH_NO_FLAT``                 | A flag that disables flattening   |
|                                   | the hierarchy during synthesis,   |
|                                   | only flattening it after          |
|                                   | synthesis, mapping and            |
|                                   | optimizations. Enabled = 1,       |
|                                   | Disabled = 0 (Default: ``0``)     |
+-----------------------------------+-----------------------------------+
| ``SYNTH_SHARE_RESOURCES``         | A flag that enables yosys to      |
|                                   | reduce the number of cells by     |
|                                   | determining shareable resources   |
|                                   | and merging them. Enabled = 1,    |
|                                   | Disabled = 0 (Default: ``1``)     |
+-----------------------------------+-----------------------------------+
| ``SYNTH_ADDER_TYPE``              | Adder type to which the $add and  |
|                                   | :math:`sub operators are mapped t |
|                                   | o. <br> Possible values are `YOSY |
|                                   | S/FA/RCA/CSA`; where `YOSYS` refe |
|                                   | rs to using Yosys internal adder  |
|                                   | definition, `FA` refers to full-a |
|                                   | dder structure, `RCA` refers to r |
|                                   | ipple carry adder structure, and  |
|                                   | `CSA` refers to carry select adde |
|                                   | r. <br> (Default: `YOSYS`)| | `SY |
|                                   | NTH_EXTRA_MAPPING_FILE` | Points  |
|                                   | to extra techmap file for yosys t |
|                                   | hat runs right after yosys `synth |
|                                   | ` before generic techmap. <br> (D |
|                                   | efault: `""`)| | `SYNTH_PARAMETER |
|                                   | S` | Space-separated key value pa |
|                                   | irs to be `chparam`ed in Yosys. I |
|                                   | n the format `key1=value1 key2=va |
|                                   | lue2` <br> Default: None. | | `CL |
|                                   | OCK_BUFFER_FANOUT` | Fanout of cl |
|                                   | ock tree buffers. <br> (Default:  |
|                                   | `16`) | | `BASE_SDC_FILE` | Speci |
|                                   | fies the base sdc file to source  |
|                                   | before running Static Timing Anal |
|                                   | ysis. <br> (Default: ``::env(OPEN |
|                                   | LANE_ROOT)/scripts/base.sdc``) |  |
|                                   | |``\ VERILOG_INCLUDE_DIRS\ ``| Sp |
|                                   | ecifies the verilog includes dire |
|                                   | ctories. <br> Optional. | |``\ SY |
|                                   | NTH_FLAT_TOP\ ``| Specifies wheth |
|                                   | er or not the top level should be |
|                                   |  flattened during elaboration. 1  |
|                                   | = True, 0= False <br> Default:``\ |
|                                   |  0\ ``. | |``\ IO_PCT\ ``| Specif |
|                                   | ies the percentage of the clock p |
|                                   | eriod used in the input/output de |
|                                   | lays. Ranges from 0 to 1.0. <br>  |
|                                   | (Default:``\ 0.2\ ``) | |``\ VERI |
|                                   | LOG_FILES_BLACKBOX\`              |
+-----------------------------------+-----------------------------------+

Floorplanning
~~~~~~~~~~~~~

+-----------------------------------+-----------------------------------+
| Variable                          | Description                       |
+===================================+===================================+
| ``FP_CORE_UTIL``                  | The core utilization percentage.  |
|                                   | (Default: ``50`` percent)         |
+-----------------------------------+-----------------------------------+
| ``FP_ASPECT_RATIO``               | The core’s aspect ratio (height / |
|                                   | width). (Default: ``1``)          |
+-----------------------------------+-----------------------------------+
| ``FP_SIZING``                     | Whether to use relative sizing by |
|                                   | making use of ``FP_CORE_UTIL`` or |
|                                   | absolute one using ``DIE_AREA``.  |
|                                   | (Default: ``"relative"`` -        |
|                                   | accepts “absolute” as well)       |
+-----------------------------------+-----------------------------------+
| ``DIE_AREA``                      | Specific die area to be used in   |
|                                   | floorplanning. Specified as a     |
|                                   | 4-corner rectangle “x0 y0 x1 y1”. |
|                                   | Units in um (Default: unset)      |
+-----------------------------------+-----------------------------------+
| ``FP_IO_MODE``                    | Decides the mode of the random IO |
|                                   | placement option. 0=matching      |
|                                   | mode, 1=random equidistant mode   |
|                                   | (Default: ``1``)                  |
+-----------------------------------+-----------------------------------+
| ``FP_WELLTAP_CELL``               | The name of the welltap cell      |
|                                   | during welltap insertion.         |
+-----------------------------------+-----------------------------------+
| ``FP_ENDCAP_CELL``                | The name of the endcap cell       |
|                                   | during endcap insertion.          |
+-----------------------------------+-----------------------------------+
| ``FP_PDN_VOFFSET``                | The offset of the vertical power  |
|                                   | stripes on the metal layer 4 in   |
|                                   | the power distribution network    |
|                                   | (Default: ``16.32``)              |
+-----------------------------------+-----------------------------------+
| ``FP_PDN_VPITCH``                 | The pitch of the vertical power   |
|                                   | stripes on the metal layer 4 in   |
|                                   | the power distribution network    |
|                                   | (Default: ``153.6``)              |
+-----------------------------------+-----------------------------------+
| ``FP_PDN_HOFFSET``                | The offset of the horizontal      |
|                                   | power stripes on the metal layer  |
|                                   | 5 in the power distribution       |
|                                   | network (Default: ``16.65``)      |
+-----------------------------------+-----------------------------------+
| ``FP_PDN_HPITCH``                 | The pitch of the horizontal power |
|                                   | stripes on the metal layer 5 in   |
|                                   | the power distribution network    |
|                                   | (Default: ``153.18``)             |
+-----------------------------------+-----------------------------------+
| ``FP_PDN_AUTO_ADJUST``            | Decides whether or not the flow   |
|                                   | should attempt to re-adjust the   |
|                                   | power grid, in order for it to    |
|                                   | fit inside the core area of the   |
|                                   | design, if needed. 1=enabled, 0   |
|                                   | =disabled (Default: ``1``)        |
+-----------------------------------+-----------------------------------+
| ``FP_TAPCELL_DIST``               | The horizontal distance between   |
|                                   | two tapcell columns (Default:     |
|                                   | ``14``)                           |
+-----------------------------------+-----------------------------------+
| ``FP_IO_VEXTEND``                 | Extends the vertical io pins      |
|                                   | outside of the die by the         |
|                                   | specified units (Default: ``-1``  |
|                                   | Disabled)                         |
+-----------------------------------+-----------------------------------+
| ``FP_IO_HEXTEND``                 | Extends the horizontal io pins    |
|                                   | outside of the die by the         |
|                                   | specified units (Default: ``-1``  |
|                                   | Disabled)                         |
+-----------------------------------+-----------------------------------+
| ``FP_IO_VLENGTH``                 | The length of the vertical IOs in |
|                                   | microns. (Default: ``4``)         |
+-----------------------------------+-----------------------------------+
| ``FP_IO_HLENGTH``                 | The length of the horizontal IOs  |
|                                   | in microns. (Default: ``4``)      |
+-----------------------------------+-----------------------------------+
| ``FP_IO_VTHICKNESS_MULT``         | A multiplier for vertical pin     |
|                                   | thickness. Base thickness is the  |
|                                   | pins layer minwidth (Default:     |
|                                   | ``2``)                            |
+-----------------------------------+-----------------------------------+
| ``FP_IO_HTHICKNESS_MULT``         | A multiplier for horizontal pin   |
|                                   | thickness. Base thickness is the  |
|                                   | pins layer minwidth (Default:     |
|                                   | ``2``)                            |
+-----------------------------------+-----------------------------------+
| ``FP_IO_UNMATCHED_ERROR``         | Exit on unmatched pins in a       |
|                                   | provided ``FP_PIN_ORDER_CFG``     |
|                                   | file. 0=Disable 1=Enable.         |
|                                   | (Default: ``1`` Enabled)          |
+-----------------------------------+-----------------------------------+
| ``BOTTOM_MARGIN_MULT``            | The core margin, in multiples of  |
|                                   | site heights, from the bottom     |
|                                   | boundary. (Default: ``4``)        |
+-----------------------------------+-----------------------------------+
| ``TOP_MARGIN_MULT``               | The core margin, in multiples of  |
|                                   | site heights, from the top        |
|                                   | boundary. (Default: ``4``)        |
+-----------------------------------+-----------------------------------+
| ``LEFT_MARGIN_MULT``              | The core margin, in multiples of  |
|                                   | site widths, from the left        |
|                                   | boundary. (Default: ``12``)       |
+-----------------------------------+-----------------------------------+
| ``RIGHT_MARGIN_MULT``             | The core margin, in multiples of  |
|                                   | site widths, from the right       |
|                                   | boundary. (Default: ``12``)       |
+-----------------------------------+-----------------------------------+
| ``FP_PDN_CORE_RING``              | Enables adding a core ring around |
|                                   | the design. More details on the   |
|                                   | control variables in the pdk      |
|                                   | configurations documentation.     |
|                                   | 0=Disable 1=Enable. (Default:     |
|                                   | ``0``)                            |
+-----------------------------------+-----------------------------------+
| ``FP_PDN_ENABLE_RAILS``           | Enables the creation of rails in  |
|                                   | the power grid. 0=Disable         |
|                                   | 1=Enable. (Default: ``1``)        |
+-----------------------------------+-----------------------------------+
| ``FP_PDN_ENABLE_MACROS_GRID``     | Enables the connection of macros  |
|                                   | to the top level power grid.      |
|                                   | 0=Disable 1=Enable. (Default:     |
|                                   | ``1``)                            |
+-----------------------------------+-----------------------------------+
| ``FP_PDN_MACRO_HOOKS``            | Specifies explicit power          |
|                                   | connections of internal macros to |
|                                   | the top level power grid. Comma   |
|                                   | separated list of macro instance  |
|                                   | names, power domain vdd and       |
|                                   | ground net names, and macro vdd   |
|                                   | and ground pin names:             |
|                                   | ``<instance_name> <vdd_net> <gnd_ |
|                                   | net> <vdd_pin> <gnd_pin>``        |
+-----------------------------------+-----------------------------------+
| ``FP_PDN_CHECK_NODES``            | Enables checking for unconnected  |
|                                   | nodes in the power grid.          |
|                                   | 0=Disable 1=Enable. (Default:     |
|                                   | ``1``)                            |
+-----------------------------------+-----------------------------------+
| ``FP_TAP_HORIZONTAL_HALO``        | Specify the horizontal halo size  |
|                                   | around macros during tap          |
|                                   | insertion. The value provided is  |
|                                   | in microns. Default: ``10``       |
+-----------------------------------+-----------------------------------+
| ``FP_TAP_VERTICAL_HALO``          | Specify the vertical halo size    |
|                                   | around macros during tap          |
|                                   | insertion. The value provided is  |
|                                   | in microns. Default: set to the   |
|                                   | value of                          |
|                                   | ``FP_TAP_HORIZONTAL_HALO``        |
+-----------------------------------+-----------------------------------+
| ``FP_PDN_HORIZONTAL_HALO``        | Sets the horizontal halo around   |
|                                   | the macros during power grid      |
|                                   | insertion. The value provided is  |
|                                   | in microns. Default: ``10``       |
+-----------------------------------+-----------------------------------+
| ``FP_PDN_VERTICAL_HALO``          | Sets the vertical halo around the |
|                                   | macros during power grid          |
|                                   | insertion. The value provided is  |
|                                   | in microns. Default: set to the   |
|                                   | value of                          |
|                                   | ``FP_PDN_HORIZONTAL_HALO``        |
+-----------------------------------+-----------------------------------+
| ``DESIGN_IS_CORE``                | Controls the layers used in the   |
|                                   | power grid. Depending on whether  |
|                                   | the design is the core of the     |
|                                   | chip or a macro inside the core.  |
|                                   | 1=Is a Core, 0=Is a Macro         |
|                                   | (Default: ``1``)                  |
+-----------------------------------+-----------------------------------+
| ``FP_PIN_ORDER_CFG``              | Points to the pin order           |
|                                   | configuration file to set the     |
|                                   | pins in specific directions (S,   |
|                                   | W, E, N). Check this [file][0] as |
|                                   | an example. If not set, then the  |
|                                   | IO pins will be placed based on   |
|                                   | one of the other methods          |
|                                   | depending on the rest of the      |
|                                   | configurations. (Default: NONE)   |
+-----------------------------------+-----------------------------------+
| ``FP_CONTEXT_DEF``                | Points to the parent DEF file     |
|                                   | that includes this macro/design   |
|                                   | and uses this DEF file to         |
|                                   | determine the best locations for  |
|                                   | the pins. It must be used with    |
|                                   | ``FP_CONTEXT_LEF``, otherwise     |
|                                   | it’s considered non-existing. If  |
|                                   | not set, then the IO pins will be |
|                                   | placed based on one of the other  |
|                                   | methods depending on the rest of  |
|                                   | the configurations. (Default:     |
|                                   | NONE)                             |
+-----------------------------------+-----------------------------------+
| ``FP_CONTEXT_LEF``                | Points to the parent LEF file     |
|                                   | that includes this macro/design   |
|                                   | and uses this LEF file to         |
|                                   | determine the best locations for  |
|                                   | the pins. It must be used with    |
|                                   | ``FP_CONTEXT_DEF``, otherwise     |
|                                   | it’s considered non-existing. If  |
|                                   | not set, then the IO pins will be |
|                                   | placed based on one of the other  |
|                                   | methods depending on the rest of  |
|                                   | the configurations. (Default:     |
|                                   | NONE)                             |
+-----------------------------------+-----------------------------------+
| ``FP_DEF_TEMPLATE``               | Points to the DEF file to be used |
|                                   | as a template when running        |
|                                   | ``apply_def_template``. This will |
|                                   | be used to exctract pin names,    |
|                                   | locations, shapes -excluding      |
|                                   | power and ground pins- as well as |
|                                   | the die area and replicate all    |
|                                   | this information in the           |
|                                   | ``CURRENT_DEF``.                  |
+-----------------------------------+-----------------------------------+
| ``VDD_NETS``                      | Specifies the power nets/pins to  |
|                                   | be used when creating the power   |
|                                   | grid for the design.              |
+-----------------------------------+-----------------------------------+
| ``GND_NETS``                      | Specifies the ground nets/pins to |
|                                   | be used when creating the power   |
|                                   | grid for the design.              |
+-----------------------------------+-----------------------------------+
| ``SYNTH_USE_PG_PINS_DEFINES``     | Specifies the power guard used in |
|                                   | the verilog source code to        |
|                                   | specify the power and ground      |
|                                   | pins. This is used to             |
|                                   | automatically extract             |
|                                   | ``VDD_NETS`` and ``GND_NET``      |
|                                   | variables from the verilog, with  |
|                                   | the assumption that they will be  |
|                                   | order                             |
|                                   | ``inout vdd1, inout gnd1, inout v |
|                                   | dd2, inout gnd2, ...``.           |
+-----------------------------------+-----------------------------------+
| ``FP_PDN_IRDROP``                 | Enable calculation of power grid  |
|                                   | IR drop during PDN generation.    |
|                                   | (Default: ``1``)                  |
+-----------------------------------+-----------------------------------+
| ``FP_IO_MIN_DISTANCE``            | The minmimum distance between the |
|                                   | IOs in microns. (Default: ``3``)  |
+-----------------------------------+-----------------------------------+

Deprecated I/O Layer variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

These variables worked initially, but they were too sky130 specific and
will be removed. Currently, if you define them in your design, they’ll
be used, but it’s recommended to update your configuration to use
``FP_IO_HLAYER`` and ``FP_IO_VLAYER``, which are defined in the PDK.

+-----------------------------------+-----------------------------------+
| Variable                          | Description                       |
+===================================+===================================+
| ``FP_IO_HMETAL``                  | The metal layer on which to place |
|                                   | the io pins horizontally (top and |
|                                   | bottom of the die). (Default:     |
|                                   | ``4``)                            |
+-----------------------------------+-----------------------------------+
| ``FP_IO_VMETAL``                  | The metal layer on which to place |
|                                   | the io pins vertically (sides of  |
|                                   | the die) (Default: ``3``)         |
+-----------------------------------+-----------------------------------+

Placement
~~~~~~~~~

+-----------------------------------+-----------------------------------+
| Variable                          | Description                       |
+===================================+===================================+
| ``PL_TARGET_DENSITY``             | The desired placement density of  |
|                                   | cells. It reflects how spread the |
|                                   | cells would be on the core area.  |
|                                   | 1 = closely dense. 0 = widely     |
|                                   | spread (Default: ``0.55``)        |
+-----------------------------------+-----------------------------------+
| ``PL_TIME_DRIVEN``                | Specifies whether the placer      |
|                                   | should use time driven placement. |
|                                   | 0 = false, 1 = true (Default:     |
|                                   | ``1``)                            |
+-----------------------------------+-----------------------------------+
| ``PL_LIB``                        | Specifies the library for time    |
|                                   | driven placement (Default:        |
|                                   | ``LIB_TYPICAL``)                  |
+-----------------------------------+-----------------------------------+
| ``PL_BASIC_PLACEMENT``            | Specifies whether the placer      |
|                                   | should run basic placement or not |
|                                   | (by running initial placement,    |
|                                   | increasing the minimum overflow   |
|                                   | to 0.9, and limiting the number   |
|                                   | of iterations to 20). 0 = false,  |
|                                   | 1 = true (Default: ``0``)         |
+-----------------------------------+-----------------------------------+
| ``PL_SKIP_INITIAL_PLACEMENT``     | Specifies whether the placer      |
|                                   | should run initial placement or   |
|                                   | not. 0 = false, 1 = true          |
|                                   | (Default: ``0``)                  |
+-----------------------------------+-----------------------------------+
| ``PL_RANDOM_GLB_PLACEMENT``       | Specifies whether the placer      |
|                                   | should run random placement or    |
|                                   | not. This is useful if the design |
|                                   | is tiny (less than 100 cells). 0  |
|                                   | = false, 1 = true (Default:       |
|                                   | ``0``)                            |
+-----------------------------------+-----------------------------------+
| ``PL_RANDOM_INITIAL_PLACEMENT``   | Specifies whether the placer      |
|                                   | should run random placement or    |
|                                   | not followed by replace’s initial |
|                                   | placement. This is useful if the  |
|                                   | design is tiny (less than 100     |
|                                   | cells). 0 = false, 1 = true       |
|                                   | (Default: ``0``)                  |
+-----------------------------------+-----------------------------------+
| ``PL_ROUTABILITY_DRIVEN``         | Specifies whether the placer      |
|                                   | should use routability driven     |
|                                   | placement. 0 = false, 1 = true    |
|                                   | (Default: ``1``)                  |
+-----------------------------------+-----------------------------------+
| ``PL_RESIZER_DESIGN_OPTIMIZATIONS | Specifies whether resizer design  |
| ``                                | optimizations should be performed |
|                                   | or not. 0 = false, 1 = true       |
|                                   | (Default: ``1``)                  |
+-----------------------------------+-----------------------------------+
| ``PL_RESIZER_TIMING_OPTIMIZATIONS | Specifies whether resizer timing  |
| ``                                | optimizations should be performed |
|                                   | or not. 0 = false, 1 = true       |
|                                   | (Default: ``1``)                  |
+-----------------------------------+-----------------------------------+
| ``PL_RESIZER_MAX_WIRE_LENGTH``    | Specifies the maximum wire length |
|                                   | cap used by resizer to insert     |
|                                   | buffers. If set to 0, no buffers  |
|                                   | will be inserted. Value in        |
|                                   | microns. (Default: ``0``)         |
+-----------------------------------+-----------------------------------+
| ``PL_RESIZER_MAX_SLEW_MARGIN``    | Specifies a margin for the slews  |
|                                   | in percentage. (Default: ``20``)  |
+-----------------------------------+-----------------------------------+
| ``PL_RESIZER_MAX_CAP_MARGIN``     | Specifies a margin for the        |
|                                   | capacitances in percentage.       |
|                                   | (Default: ``20``)                 |
+-----------------------------------+-----------------------------------+
| ``PL_RESIZER_HOLD_SLACK_MARGIN``  | Specifies a time margin for the   |
|                                   | slack when fixing hold            |
|                                   | violations. Normally the resizer  |
|                                   | will stop when it reaches zero    |
|                                   | slack. This option allows you to  |
|                                   | overfix. (Default: ``0.1ns``.)    |
+-----------------------------------+-----------------------------------+
| ``PL_RESIZER_SETUP_SLACK_MARGIN`` | Specifies a time margin for the   |
|                                   | slack when fixing setup           |
|                                   | violations. (Default: ``0.05ns``) |
+-----------------------------------+-----------------------------------+
| ``PL_RESIZER_HOLD_MAX_BUFFER_PERC | Specifies a max number of buffers |
| ENT``                             | to insert to fix hold violations. |
|                                   | This number is calculated as a    |
|                                   | percentage of the number of       |
|                                   | instances in the design.          |
|                                   | (Default: ``50``)                 |
+-----------------------------------+-----------------------------------+
| ``PL_RESIZER_SETUP_MAX_BUFFER_PER | Specifies a max number of buffers |
| CENT``                            | to insert to fix setup            |
|                                   | violations. This number is        |
|                                   | calculated as a percentage of the |
|                                   | number of instances in the        |
|                                   | design. (Default: ``50``)         |
+-----------------------------------+-----------------------------------+
| ``PL_RESIZER_ALLOW_SETUP_VIOS``   | Allows setup violations when      |
|                                   | fixing hold. (Default: ``0``)     |
+-----------------------------------+-----------------------------------+
| ``LIB_RESIZER_OPT``               | Points to the lib file,           |
|                                   | corresponding to the typical      |
|                                   | corner, that is used during       |
|                                   | resizer optimizations. This is    |
|                                   | copy of ``LIB_SYNTH_COMPLETE``.   |
|                                   | Default:                          |
|                                   | ``$::env(synthesis_tmpfiles)/resi |
|                                   | zer_<library-name>.lib``          |
+-----------------------------------+-----------------------------------+
| ``DONT_USE_CELLS``                | The list of cells to not use      |
|                                   | during resizer optimizations.     |
|                                   | Default: the contents of          |
|                                   | ``DRC_EXCLUDE_CELL_LIST``.        |
+-----------------------------------+-----------------------------------+
| ``PL_ESTIMATE_PARASITICS``        | Specifies whether or not to run   |
|                                   | STA after global placement using  |
|                                   | OpenROAD’s estimate_parasitics    |
|                                   | -placement and generates reports  |
|                                   | under ``logs/placement``. 1 =     |
|                                   | Enabled, 0 = Disabled. (Default:  |
|                                   | ``1``)                            |
+-----------------------------------+-----------------------------------+
| ``PL_OPTIMIZE_MIRRORING``         | Specifies whether or not to run   |
|                                   | an optimize_mirroring pass        |
|                                   | whenever detailed placement       |
|                                   | happens. This pass will mirror    |
|                                   | the cells whenever possible to    |
|                                   | optimize the design. 1 = Enabled, |
|                                   | 0 = Disabled. (Default: ``1``)    |
+-----------------------------------+-----------------------------------+
| ``PL_RESIZER_BUFFER_INPUT_PORTS`` | Specifies whether or not to       |
|                                   | insert buffers on input ports     |
|                                   | whenever resizer optimizations    |
|                                   | are run. For this to be used,     |
|                                   | ``PL_RESIZER_DESIGN_OPTIMIZATIONS |
|                                   | ``                                |
|                                   | must be set to 1. 1 = Enabled, 0  |
|                                   | = Disabled. (Default: ``1``)      |
+-----------------------------------+-----------------------------------+
| ``PL_RESIZER_BUFFER_OUTPUT_PORTS` | Specifies whether or not to       |
| `                                 | insert buffers on output ports    |
|                                   | whenever resizer optimizations    |
|                                   | are run. For this to be used,     |
|                                   | ``PL_RESIZER_DESIGN_OPTIMIZATIONS |
|                                   | ``                                |
|                                   | must be set to 1. 1 = Enabled, 0  |
|                                   | = Disabled. (Default: ``1``)      |
+-----------------------------------+-----------------------------------+
| ``PL_RESIZER_REPAIR_TIE_FANOUT``  | Specifies whether or not to       |
|                                   | repair tie cells fanout whenever  |
|                                   | resizer optimizations are run.    |
|                                   | For this to be used,              |
|                                   | ``PL_RESIZER_DESIGN_OPTIMIZATIONS |
|                                   | ``                                |
|                                   | must be set to 1. 1 = Enabled, 0  |
|                                   | = Disabled. (Default: ``1``)      |
+-----------------------------------+-----------------------------------+
| ``PL_MAX_DISPLACEMENT_X``         | Specifies how far an instance can |
|                                   | be moved along the X-axis when    |
|                                   | finding a site where it can be    |
|                                   | placed during detailed placement. |
|                                   | (Default: ``500``\ um)            |
+-----------------------------------+-----------------------------------+
| ``PL_MAX_DISPLACEMENT_Y``         | Specifies how far an instance can |
|                                   | be moved along the Y-axis when    |
|                                   | finding a site where it can be    |
|                                   | placed during detailed placement. |
|                                   | (Default: ``100``\ um)            |
+-----------------------------------+-----------------------------------+
| ``PL_MACRO_HALO``                 | Macro placement halo. Format:     |
|                                   | ``{Horizontal} {Vertical}``       |
|                                   | (Default: ``0 0``\ um).           |
+-----------------------------------+-----------------------------------+
| ``PL_MACRO_CHANNEL``              | Channel widths between macros.    |
|                                   | Format:                           |
|                                   | ``{Horizontal} {Vertical}``       |
|                                   | (Default: ``0 0``\ um).           |
+-----------------------------------+-----------------------------------+
| ``MACRO_PLACEMENT_CFG``           | Specifies the path a file         |
|                                   | specifying how openlane should    |
|                                   | place certain macros              |
+-----------------------------------+-----------------------------------+

CTS
~~~

+-----------------------------------+-----------------------------------+
| Variable                          | Description                       |
+===================================+===================================+
| ``CTS_TARGET_SKEW``               | The target clock skew in          |
|                                   | picoseconds. (Default:            |
|                                   | ``200``\ ps)                      |
+-----------------------------------+-----------------------------------+
| ``CTS_ROOT_BUFFER``               | The name of cell inserted at the  |
|                                   | root of the clock tree.           |
+-----------------------------------+-----------------------------------+
| ``CLOCK_TREE_SYNTH``              | Enable clock tree synthesis.      |
|                                   | (Default: ``1``)                  |
+-----------------------------------+-----------------------------------+
| ``RUN_SIMPLE_CTS``                | Runs an alternative simple clock  |
|                                   | tree synthesis after synthesis    |
|                                   | instead of TritonCTS. 1 =         |
|                                   | Enabled, 0 = Disabled (Default:   |
|                                   | ``0``)                            |
+-----------------------------------+-----------------------------------+
| ``FILL_INSERTION``                | Enables fill cells insertion      |
|                                   | after cts (if enabled). 1 =       |
|                                   | Enabled, 0 = Disabled (Default:   |
|                                   | ``1``)                            |
+-----------------------------------+-----------------------------------+
| ``CTS_TOLERANCE``                 | An integer value that represents  |
|                                   | a tradeoff of QoR and runtime.    |
|                                   | Higher values will produce        |
|                                   | smaller runtime but worse QoR     |
|                                   | (Default: ``100``)                |
+-----------------------------------+-----------------------------------+
| ``CTS_SINK_CLUSTERING_SIZE``      | Specifies the maximum number of   |
|                                   | sinks per cluster. (Default:      |
|                                   | ``25``)                           |
+-----------------------------------+-----------------------------------+
| ``CTS_SINK_CLUSTERING_MAX_DIAMETE | Specifies maximum diameter (in    |
| R``                               | micron) of sink cluster.          |
|                                   | (Default: ``50``)                 |
+-----------------------------------+-----------------------------------+
| ``CTS_REPORT_TIMING``             | Specifies whether or not to run   |
|                                   | STA after clock tree synthesis    |
|                                   | using OpenROAD’s                  |
|                                   | estimate_parasitics -placement    |
|                                   | and generates reports under       |
|                                   | ``logs/cts``. 1 = Enabled, 0 =    |
|                                   | Disabled. (Default: ``1``)        |
+-----------------------------------+-----------------------------------+
| ``CTS_CLK_MAX_WIRE_LENGTH``       | Specifies the maximum wire length |
|                                   | on the clock net. Value in        |
|                                   | microns. (Default: ``0``)         |
+-----------------------------------+-----------------------------------+
| ``CTS_DISABLE_POST_PROCESSING``   | Specifies whether or not to       |
|                                   | disable post cts processing for   |
|                                   | outlier sinks. (Default: ``0``)   |
+-----------------------------------+-----------------------------------+
| ``CTS_DISTANCE_BETWEEN_BUFFERS``  | Specifies the distance (in        |
|                                   | microns) between buffers when     |
|                                   | creating the clock tree (Default: |
|                                   | ``0``)                            |
+-----------------------------------+-----------------------------------+
| ``LIB_CTS``                       | The liberty file used for CTS. By |
|                                   | default, this is the              |
|                                   | ``LIB_SYNTH_COMPLETE`` minus the  |
|                                   | cells with drc errors as          |
|                                   | specified by the drc exclude      |
|                                   | list. (Default:                   |
|                                   | ``$::env(cts_tmpfiles)/cts.lib``) |
+-----------------------------------+-----------------------------------+

Routing
~~~~~~~

+-----------------------------------+-----------------------------------+
| Variable                          | Description                       |
+===================================+===================================+
| ``GLOBAL_ROUTER``                 | Specifies which global router to  |
|                                   | use. Values: ``fastroute``.       |
|                                   | (``cugr`` is deprecated and       |
|                                   | fastroute will be used instead.)  |
|                                   | (Default: ``fastroute``)          |
+-----------------------------------+-----------------------------------+
| ``DETAILED_ROUTER``               | Specifies which detailed router   |
|                                   | to use. Values: ``tritonroute``.  |
|                                   | (``drcu``/``tritonroute_or`` are  |
|                                   | both deprecated and tritonroute   |
|                                   | will be used instead.) (Default:  |
|                                   | ``tritonroute``)                  |
+-----------------------------------+-----------------------------------+
| ``ROUTING_CORES``                 | Specifies the number of threads   |
|                                   | to be used in TritonRoute. Can be |
|                                   | overriden via environment         |
|                                   | variable. (Default: ``2``)        |
+-----------------------------------+-----------------------------------+
| ``RT_CLOCK_MIN_LAYER``            | The name of lowest layer to be    |
|                                   | used in routing the clock net.    |
|                                   | (Default: ``RT_MIN_LAYER``)       |
+-----------------------------------+-----------------------------------+
| ``RT_CLOCK_MAX_LAYER``            | The name of highest layer to be   |
|                                   | used in routing the clock net.    |
|                                   | (Default: ``RT_MAX_LAYER``)       |
+-----------------------------------+-----------------------------------+
| ``GLB_RT_ALLOW_CONGESTION``       | Allow congestion in the resulting |
|                                   | guides. 0 = false, 1 = true       |
|                                   | (Default: ``0``)                  |
+-----------------------------------+-----------------------------------+
| ``GLB_RT_OVERFLOW_ITERS``         | The maximum number of iterations  |
|                                   | waiting for the overflow to reach |
|                                   | the desired value. (Default:      |
|                                   | ``50``)                           |
+-----------------------------------+-----------------------------------+
| ``GLB_RT_ANT_ITERS``              | The maximum number of iterations  |
|                                   | for global router repair_antenna. |
|                                   | This option is only available in  |
|                                   | ``DIODE_INSERTION_STRATEGY`` =    |
|                                   | ``3``. (Default: ``3``)           |
+-----------------------------------+-----------------------------------+
| ``GLB_RT_ESTIMATE_PARASITICS``    | Specifies whether or not to run   |
|                                   | STA after global routing using    |
|                                   | OpenROAD’s estimate_parasitics    |
|                                   | -global_routing and generates     |
|                                   | reports under ``logs/routing``. 1 |
|                                   | = Enabled, 0 = Disabled.          |
|                                   | (Default: ``1``)                  |
+-----------------------------------+-----------------------------------+
| ``GLB_RT_MAX_DIODE_INS_ITERS``    | Controls the maximum number of    |
|                                   | iterations at which re-running    |
|                                   | Fastroute for diode insertion     |
|                                   | stops. Each iteration ARC detects |
|                                   | the violations and FastRoute      |
|                                   | fixes them by inserting diodes,   |
|                                   | then producing the new DEF. The   |
|                                   | number of antenna violations is   |
|                                   | compared with the previous        |
|                                   | iteration and if they are equal   |
|                                   | or the number is greater the      |
|                                   | iterations stop and the DEF from  |
|                                   | the previous iteration is used in |
|                                   | the rest of the flow. If the      |
|                                   | current antenna violations reach  |
|                                   | zero, the current def will be     |
|                                   | used and the iterations will not  |
|                                   | continue. This option is only     |
|                                   | available in                      |
|                                   | DIODE_INSERTION_STRATEGY = ``3``. |
|                                   | (Default: ``1``)                  |
+-----------------------------------+-----------------------------------+
| ``GLB_RT_OBS``                    | Specifies custom obstruction to   |
|                                   | be added prior to global routing. |
|                                   | Comma separated list of layer and |
|                                   | coordinates:                      |
|                                   | ``layer llx lly urx ury``.        |
|                                   | (Example:                         |
|                                   | ``li1 0 100 1000 300, met5 0 0 10 |
|                                   | 00 500``)                         |
|                                   | (Default: unset)                  |
+-----------------------------------+-----------------------------------+
| ``GLB_RESIZER_TIMING_OPTIMIZATION | Specifies whether resizer timing  |
| S``                               | optimizations should be performed |
|                                   | after global routing or not. 0 =  |
|                                   | false, 1 = true (Default: ``1``)  |
+-----------------------------------+-----------------------------------+
| ``GLB_RESIZER_MAX_WIRE_LENGTH``   | Specifies the maximum wire length |
|                                   | cap used by resizer to insert     |
|                                   | buffers. If set to 0, no buffers  |
|                                   | will be inserted. Value in        |
|                                   | microns. (Default: ``0``)         |
+-----------------------------------+-----------------------------------+
| ``GLB_RESIZER_MAX_SLEW_MARGIN``   | Specifies a margin for the slews. |
|                                   | (Default: ``10``)                 |
+-----------------------------------+-----------------------------------+
| ``GLB_RESIZER_MAX_CAP_MARGIN``    | Specifies a margin for the        |
|                                   | capacitances. (Default: ``10``)   |
+-----------------------------------+-----------------------------------+
| ``GLB_RESIZER_HOLD_SLACK_MARGIN`` | Specifies a time margin for the   |
|                                   | slack when fixing hold            |
|                                   | violations. Normally the resizer  |
|                                   | will stop when it reaches zero    |
|                                   | slack. This option allows you to  |
|                                   | overfix. (Default: ``0.1ns``)     |
+-----------------------------------+-----------------------------------+
| ``GLB_RESIZER_SETUP_SLACK_MARGIN` | Specifies a time margin for the   |
| `                                 | slack when fixing setup           |
|                                   | violations. (Default: ``0.05ns``) |
+-----------------------------------+-----------------------------------+
| ``GLB_RESIZER_HOLD_MAX_BUFFER_PER | Specifies a max number of buffers |
| CENT``                            | to insert to fix hold violations. |
|                                   | This number is calculated as a    |
|                                   | percentage of the number of       |
|                                   | instances in the design.          |
|                                   | (Default: ``50``)                 |
+-----------------------------------+-----------------------------------+
| ``GLB_RESIZER_SETUP_MAX_BUFFER_PE | Specifies a max number of buffers |
| RCENT``                           | to insert to fix setup            |
|                                   | violations. This number is        |
|                                   | calculated as a percentage of the |
|                                   | number of instances in the        |
|                                   | design. (Default: ``50``)         |
+-----------------------------------+-----------------------------------+
| ``GLB_RESIZER_ALLOW_SETUP_VIOS``  | Allows setup violations when      |
|                                   | fixing hold. (Default: ``0``)     |
+-----------------------------------+-----------------------------------+
| ``GLB_OPTIMIZE_MIRRORING``        | Specifies whether or not to run   |
|                                   | an optimize_mirroring pass        |
|                                   | whenever detailed placement       |
|                                   | happens after Routing timing      |
|                                   | optimization. This pass will      |
|                                   | mirror the cells whenever         |
|                                   | possible to optimize the design.  |
|                                   | 1 = Enabled, 0 = Disabled.        |
|                                   | (Default: ``1``)                  |
+-----------------------------------+-----------------------------------+
| ``GLB_RT_ADJUSTMENT``             | Reduction in the routing capacity |
|                                   | of the edges between the cells in |
|                                   | the global routing graph. Values  |
|                                   | range from 0 to 1. 1 = most       |
|                                   | reduction, 0 = least reduction    |
|                                   | (Default: ``0.3``)                |
+-----------------------------------+-----------------------------------+
| ``GLB_RT_MACRO_EXTENSION``        | Sets the number of GCells added   |
|                                   | to the blockages boundaries from  |
|                                   | macros. A GCell is typically      |
|                                   | defined in terms of Mx routing    |
|                                   | tracks. The default GCell size is |
|                                   | 15 M3 pitches. (Default: ``0``)   |
+-----------------------------------+-----------------------------------+
| ``DRT_MIN_LAYER``                 | An optional override to the       |
|                                   | lowest layer used in detailed     |
|                                   | routing. For example, in sky130,  |
|                                   | you may want global routing to    |
|                                   | avoid li1, but let detailed       |
|                                   | routing use li1 if it has to.     |
|                                   | (Default: ``RT_MIN_LAYER``)       |
+-----------------------------------+-----------------------------------+
| ``DRT_MAX_LAYER``                 | An optional override to the       |
|                                   | highest layer used in detailed    |
|                                   | routing. (Default:                |
|                                   | ``RT_MAX_LAYER``)                 |
+-----------------------------------+-----------------------------------+
| ``DRT_OPT_ITERS``                 | Specifies the maximum number of   |
|                                   | optimization iterations during    |
|                                   | Detailed Routing in TritonRoute.  |
|                                   | (Default: ``64``)                 |
+-----------------------------------+-----------------------------------+
| ``ROUTING_OPT_ITERS``             | **Deprecated: Use                 |
|                                   | DRT_OPT_ITERS**: Specifies the    |
|                                   | maximum number of optimization    |
|                                   | iterations during Detailed        |
|                                   | Routing in TritonRoute. (Default: |
|                                   | ``64``)                           |
+-----------------------------------+-----------------------------------+

Deprecated Layer Adjustment Variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

These variables worked initially, but they were too sky130 specific and
will be removed. Currently, if you define them in your design, they’ll
be concatenated into GLB_RT_LAYER_ADJUSTMENTS, but it’s recommended to
update your configuration to use ``GLB_RT_LAYER_ADJUSTMENTS``, which is
defined in the PDK.

+-----------------------------------+-----------------------------------+
| Variable                          | Description                       |
+===================================+===================================+
| ``GLB_RT_L1_ADJUSTMENT``          | **Deprecated**: Reduction in the  |
|                                   | routing capacity of the edges     |
|                                   | between the cells in the global   |
|                                   | routing graph but specific to li1 |
|                                   | layer in sky130A. Values range    |
|                                   | from 0 to 1 (Default: ``0.99``)   |
+-----------------------------------+-----------------------------------+
| ``GLB_RT_L2_ADJUSTMENT``          | **Deprecated**: Reduction in the  |
|                                   | routing capacity of the edges     |
|                                   | between the cells in the global   |
|                                   | routing graph but specific to     |
|                                   | met1 in sky130A. Values range     |
|                                   | from 0 to 1 (Default: ``0``)      |
+-----------------------------------+-----------------------------------+
| ``GLB_RT_L3_ADJUSTMENT``          | **Deprecated**: Reduction in the  |
|                                   | routing capacity of the edges     |
|                                   | between the cells in the global   |
|                                   | routing graph but specific to     |
|                                   | met2 in sky130A. Values range     |
|                                   | from 0 to 1 (Default: ``0``)      |
+-----------------------------------+-----------------------------------+
| ``GLB_RT_L4_ADJUSTMENT``          | **Deprecated**: Reduction in the  |
|                                   | routing capacity of the edges     |
|                                   | between the cells in the global   |
|                                   | routing graph but specific to     |
|                                   | met3 in sky130A. Values range     |
|                                   | from 0 to 1 (Default: ``0``)      |
+-----------------------------------+-----------------------------------+
| ``GLB_RT_L5_ADJUSTMENT``          | **Deprecated**: Reduction in the  |
|                                   | routing capacity of the edges     |
|                                   | between the cells in the global   |
|                                   | routing graph but specific to     |
|                                   | met4 in sky130A. Values range     |
|                                   | from 0 to 1 (Default: ``0``)      |
+-----------------------------------+-----------------------------------+
| ``GLB_RT_L6_ADJUSTMENT``          | **Deprecated**: Reduction in the  |
|                                   | routing capacity of the edges     |
|                                   | between the cells in the global   |
|                                   | routing graph but specific to     |
|                                   | met5 in sky130A. Values range     |
|                                   | from 0 to 1 (Default: ``0``)      |
+-----------------------------------+-----------------------------------+

Deprecated Min/Max Layer Variables
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

These variables worked initially, but they were too sky130 specific and
will be removed. Currently, if you define them in your design, they’ll
be translated to the correct variables, ``RT_{MIN/MAX}_LAYER`` and
``RT_CLOCK_{MIN/MAX}_LAYER``.

+-----------------------------------+-----------------------------------+
| Variable                          | Description                       |
+===================================+===================================+
| ``GLB_RT_MINLAYER``               | **Deprecated**: The number of     |
|                                   | lowest layer to be used in        |
|                                   | routing. (Default: ``1``)         |
+-----------------------------------+-----------------------------------+
| ``GLB_RT_MAXLAYER``               | **Deprecated**: The number of     |
|                                   | highest layer to be used in       |
|                                   | routing. (Default: ``6``)         |
+-----------------------------------+-----------------------------------+
| ``GLB_RT_CLOCK_MINLAYER``         | **Deprecated**: The number of     |
|                                   | lowest layer to be used in        |
|                                   | routing the clock net. (Default:  |
|                                   | ``GLB_RT_MINLAYER``)              |
+-----------------------------------+-----------------------------------+
| ``GLB_RT_CLOCK_MAXLAYER``         | **Deprecated**: The number of     |
|                                   | highest layer to be used in       |
|                                   | routing the clock net. (Default:  |
|                                   | ``GLB_RT_MAXLAYER``)              |
+-----------------------------------+-----------------------------------+

Removed
^^^^^^^

+-----------------------------------+-----------------------------------+
| Variable                          | Description                       |
+===================================+===================================+
| ``GLB_RT_UNIDIRECTIONAL``         | **Removed**: Allow unidirectional |
|                                   | routing. 0 = false, 1 = true      |
|                                   | (Default: ``1``)                  |
+-----------------------------------+-----------------------------------+
| ``GLB_RT_TILES``                  | **Removed**: The size of the      |
|                                   | GCELL used by Fastroute during    |
|                                   | global routing. (Default: ``15``) |
+-----------------------------------+-----------------------------------+

RC Extraction
~~~~~~~~~~~~~

+-----------------------------------+-----------------------------------+
| Variable                          | Description                       |
+===================================+===================================+
| ``SPEF_EXTRACTOR``                | Specifies which spef extractor to |
|                                   | use. Values: ``openrcx`` or       |
|                                   | (removed: ``def2spef``).          |
|                                   | (Default: ``openrcx``)            |
+-----------------------------------+-----------------------------------+
| ``RCX_MERGE_VIA_WIRE_RES``        | Specifies whether to merge the    |
|                                   | via resistance with the wire      |
|                                   | resistance or separate it from    |
|                                   | the wire resistance. 1 = Merge    |
|                                   | via resistance, 0 = Separate via  |
|                                   | resistance (Default: ``1``)       |
+-----------------------------------+-----------------------------------+
| ``SPEF_WIRE_MODEL``               | Specifies the wire model used in  |
|                                   | SPEF extraction. Options are      |
|                                   | ``L`` or ``Pi`` (Default: ``L``)  |
+-----------------------------------+-----------------------------------+
| ``SPEF_EDGE_CAP_FACTOR``          | Specifies the edge capacitance    |
|                                   | factor used in SPEF extraction.   |
|                                   | Ranges from 0 to 1 (Default:      |
|                                   | ``1``)                            |
+-----------------------------------+-----------------------------------+

Magic
~~~~~

+-----------------------------------+-----------------------------------+
| Variable                          | Description                       |
+===================================+===================================+
| ``MAGIC_PAD``                     | A flag to pad the views generated |
|                                   | by magic (.mag, .lef, .gds) with  |
|                                   | one site. 1 = Enabled, 0 =        |
|                                   | Disabled (Default: ``0`` )        |
+-----------------------------------+-----------------------------------+
| ``MAGIC_ZEROIZE_ORIGIN``          | A flag to move the layout such    |
|                                   | that it’s origin in the lef       |
|                                   | generated by magic is 0,0. 1 =    |
|                                   | Enabled, 0 = Disabled (Default:   |
|                                   | ``1`` )                           |
+-----------------------------------+-----------------------------------+
| ``MAGIC_GENERATE_GDS``            | A flag to generate gds view via   |
|                                   | magic . 1 = Enabled, 0 = Disabled |
|                                   | (Default: ``1`` )                 |
+-----------------------------------+-----------------------------------+
| ``MAGIC_GENERATE_LEF``            | A flag to generate lef view via   |
|                                   | magic . 1 = Enabled, 0 = Disabled |
|                                   | (Default: ``1`` )                 |
+-----------------------------------+-----------------------------------+
| ``MAGIC_GENERATE_MAGLEF``         | A flag to generate maglef view    |
|                                   | via magic . 1 = Enabled, 0 =      |
|                                   | Disabled (Default: ``1`` )        |
+-----------------------------------+-----------------------------------+
| ``MAGIC_WRITE_FULL_LEF``          | A flag to specify whether or not  |
|                                   | the output LEF should include all |
|                                   | shapes inside the macro or an     |
|                                   | abstracted view of the macro lef  |
|                                   | view via magic . 1 = Full View, 0 |
|                                   | = Abstracted View (Default: ``0`` |
|                                   | )                                 |
+-----------------------------------+-----------------------------------+
| ``MAGIC_DRC_USE_GDS``             | A flag to choose whether to run   |
|                                   | the magic DRC checks on GDS or    |
|                                   | not. If not, then the checks will |
|                                   | be done on the DEF/LEF. 1 = GDS,  |
|                                   | 0 = DEF/LEF (Default: ``1`` )     |
+-----------------------------------+-----------------------------------+
| ``MAGIC_EXT_USE_GDS``             | A flag to choose whether to run   |
|                                   | the magic extractions on GDS or   |
|                                   | DEF/LEF. If GDS was used Device   |
|                                   | Level LVS will be run. Otherwise, |
|                                   | blackbox LVS will be run. 1 =     |
|                                   | GDS, 0 = DEF/LEF (Default: ``0``  |
|                                   | )                                 |
+-----------------------------------+-----------------------------------+
| ``MAGIC_INCLUDE_GDS_POINTERS``    | A flag to choose whether to       |
|                                   | include GDS pointers in the       |
|                                   | generated mag files or not. 1 =   |
|                                   | Enabled, 0 = Disabled (Default:   |
|                                   | ``0`` )                           |
+-----------------------------------+-----------------------------------+
| ``MAGIC_DISABLE_HIER_GDS``        | A flag to disable cif hier and    |
|                                   | array during GDS-II writing.\*    |
|                                   | 1=Enabled                         |
|                                   | ``<so this hier gds will be disab |
|                                   | led>``,                           |
|                                   | 0=Disabled                        |
|                                   | ``<so this hier gds will be enabl |
|                                   | ed>``.                            |
|                                   | (Default: ``1`` )                 |
+-----------------------------------+-----------------------------------+

..

   -  Tim Edwards’s Explanation on disabling hier gds: The following is
      an explanation by Tim Edwards, provided in a slack thread, on how
      this affects the GDS writing process: “Magic can take a very long
      time writing out GDS while checking hierarchical interactions in a
      standard cell layout. If your design is all digital, I recommend
      using”gds \*hier write disable" before “gds write” so that it does
      not try to resolve hierarchical interactions (since by definition,
      standard cells are designed to just sit next to each other without
      creating DRC issues). That can actually make the difference
      between a 20 hour GDS write and a 2 minute GDS write. For a
      standard cell design that takes up the majority of the user space,
      a > 24 hour write time (without disabling the hierarchy checks)
      would not surprise me."

LVS
~~~

+-----------------------------------+-----------------------------------+
| Variable                          | Description                       |
+===================================+===================================+
| ``LVS_INSERT_POWER_PINS``         | Enables power pins insertion      |
|                                   | before running lvs. 1 = Enabled,  |
|                                   | 0 = Disabled (Default: ``1`` )    |
+-----------------------------------+-----------------------------------+
| ``LVS_CONNECT_BY_LABEL``          | Enables connections by label in   |
|                                   | LVS by skipping                   |
|                                   | ``extract unique`` in magic       |
|                                   | extractions. Default: ``0``       |
+-----------------------------------+-----------------------------------+
| ``YOSYS_REWRITE_VERILOG``         | Enables yosys to rewrite the      |
|                                   | verilog before LVS producing a    |
|                                   | canonical verilog netlist with    |
|                                   | verbose wire declarations. This   |
|                                   | flag will be ignored if           |
|                                   | ``LEC_ENABLE`` is 1, and it will  |
|                                   | be rewritten anyways. 1 =         |
|                                   | Enabled, 0 = Disabled (Default:   |
|                                   | ``0`` )                           |
+-----------------------------------+-----------------------------------+

Misc
~~~~

+-----------------------------------+-----------------------------------+
| Variable                          | Description                       |
+===================================+===================================+
| ``PDK``                           | Specifies the process design kit  |
|                                   | (PDK). (Default: ``sky130A`` )    |
+-----------------------------------+-----------------------------------+
| ``STD_CELL_LIBRARY``              | Specifies the standard cell       |
|                                   | library to be used under the      |
|                                   | specified PDK. (Default:          |
|                                   | ``sky130_fd_sc_hd`` )             |
+-----------------------------------+-----------------------------------+
| ``STD_CELL_LIBRARY_OPT``          | Specifies the standard cell       |
|                                   | library to be used during resizer |
|                                   | optimizations. (Default:          |
|                                   | ``$STD_CELL_LIBRARY`` )           |
+-----------------------------------+-----------------------------------+
| ``PDK_ROOT``                      | Specifies the folder path of the  |
|                                   | PDK. It searches for a            |
|                                   | ``config.tcl`` in                 |
|                                   | ``$PDK_ROOT/$PDK/libs.tech/openla |
|                                   | ne/``                             |
|                                   | directory and at least have one   |
|                                   | standard cell library config      |
|                                   | defined in                        |
|                                   | ``$PDK_ROOT/$PDK/libs.tech/openla |
|                                   | ne/$STD_CELL_LIBRARY``.           |
+-----------------------------------+-----------------------------------+
| ``CELL_PAD``                      | Cell padding; increases the width |
|                                   | of cells. (Default: ``4`` microns |
|                                   | – 4 sites)                        |
+-----------------------------------+-----------------------------------+
| ``DIODE_PADDING``                 | Diode cell padding; increases the |
|                                   | width of diode cells during       |
|                                   | placement checks. (Default: ``2`` |
|                                   | microns – 2 sites)                |
+-----------------------------------+-----------------------------------+
| ``MERGED_LEF_UNPADDED``           | Points to ``merged_unpadded.lef`` |
|                                   | by default. it contains the       |
|                                   | technology LEF for the used       |
|                                   | STD_CELL_LIBRARY merged with the  |
|                                   | LEF file for all the cells.       |
+-----------------------------------+-----------------------------------+
| ``MERGED_LEF``                    | points to ``merged.lef``, which   |
|                                   | is ``merged_unpadded.lef`` but    |
|                                   | with cell padding. This is        |
|                                   | controlled by CELL_PAD.           |
+-----------------------------------+-----------------------------------+
| ``NO_SYNTH_CELL_LIST``            | Specifies the file that contains  |
|                                   | the don’t-use-cell-list to be     |
|                                   | excluded from the liberty file    |
|                                   | during synthesis. If it’s not     |
|                                   | defined, this path is searched    |
|                                   | ``$::env(PDK_ROOT)/$::env(PDK)/li |
|                                   | bs.tech/openlane/$::env(STD_CELL_ |
|                                   | LIBRARY)/no_synth.cells``         |
|                                   | and if it’s not found, then the   |
|                                   | original liberty will be used as  |
|                                   | is.                               |
+-----------------------------------+-----------------------------------+
| ``DRC_EXCLUDE_CELL_LIST``         | Specifies the file that contains  |
|                                   | the don’t-use-cell-list to be     |
|                                   | excluded from the liberty file    |
|                                   | during synthesis and timing       |
|                                   | optimizations. If it’s not        |
|                                   | defined, this path is searched    |
|                                   | ``$::env(PDK_ROOT)/$::env(PDK)/li |
|                                   | bs.tech/openlane/$::env(STD_CELL_ |
|                                   | LIBRARY)/drc_exclude.cells``      |
|                                   | and if it’s not found, then the   |
|                                   | original liberty will be used as  |
|                                   | is. In other words,               |
|                                   | ``DRC_EXCLUDE_CELL_LIST`` contain |
|                                   | the only excluded cell list in    |
|                                   | timing optimizations.             |
+-----------------------------------+-----------------------------------+
| ``EXTRA_LEFS``                    | Specifies LEF files of            |
|                                   | pre-hardened macros to be merged  |
|                                   | in the design currently getting   |
|                                   | hardened                          |
+-----------------------------------+-----------------------------------+
| ``EXTRA_GDS_FILES``               | Specifies GDS files of            |
|                                   | pre-hardened macros to be merged  |
|                                   | in the design currently getting   |
|                                   | hardened                          |
+-----------------------------------+-----------------------------------+
| ``TEST_MISMATCHES``               | Test for mismatches between the   |
|                                   | OpenLane tool versions and the    |
|                                   | current environment. ``all``      |
|                                   | tests all mismatches. ``tools``   |
|                                   | tests all except the PDK. ``pdk`` |
|                                   | only tests the PDK. ``none``      |
|                                   | disables the check. (Default:     |
|                                   | ``all``)                          |
+-----------------------------------+-----------------------------------+
| ``QUIT_ON_MISMATCHES``            | Whether to halt the flow          |
|                                   | execution or not if mismatches    |
|                                   | are found. (Default: ``1``)       |
+-----------------------------------+-----------------------------------+

Flow control
~~~~~~~~~~~~

+-----------------------------------+-----------------------------------+
| Variable                          | Description                       |
+===================================+===================================+
| ``USE_GPIO_PADS``                 | Decides whether or not to use the |
|                                   | gpio pads in routing by merging   |
|                                   | their LEF file set in             |
|                                   | ``::env(USE_GPIO_ROUTING_LEF)``   |
|                                   | and blackboxing their verilog     |
|                                   | modules set in                    |
|                                   | ``::env(GPIO_PADS_VERILOG)``.     |
|                                   | 1=Enabled, 0=Disabled. (Default:  |
|                                   | ``0``)                            |
+-----------------------------------+-----------------------------------+
| ``LEC_ENABLE``                    | Enables logic verification using  |
|                                   | yosys, for comparing each netlist |
|                                   | at each stage of the flow with    |
|                                   | the previous netlist and          |
|                                   | verifying that they are logically |
|                                   | equivalent. Warning: this will    |
|                                   | increase the runtime              |
|                                   | significantly. 1 = Enabled, 0 =   |
|                                   | Disabled (Default: ``0``)         |
+-----------------------------------+-----------------------------------+
| ``RUN_ROUTING_DETAILED``          | Enables detailed routing. 1 =     |
|                                   | Enabled, 0 = Disabled (Default:   |
|                                   | ``1``)                            |
+-----------------------------------+-----------------------------------+
| ``RUN_LVS``                       | Enables running LVS. 1 = Enabled, |
|                                   | 0 = Disabled (Default: ``1``)     |
+-----------------------------------+-----------------------------------+
| ``PRIMARY_SIGNOFF_TOOL``          | Determines whether ``magic`` or   |
|                                   | ``klayout`` is the primary        |
|                                   | signoff tool. (Default:           |
|                                   | ``magic``)                        |
+-----------------------------------+-----------------------------------+
| ``RUN_MAGIC``                     | Enables running magic and GDSII   |
|                                   | streaming. 1 = Enabled, 0 =       |
|                                   | Disabled (Default: ``1``)         |
+-----------------------------------+-----------------------------------+
| ``RUN_MAGIC_DRC``                 | Enables running magic DRC on      |
|                                   | GDS-II produced by magic. 1 =     |
|                                   | Enabled, 0 = Disabled (Default:   |
|                                   | ``1``)                            |
+-----------------------------------+-----------------------------------+
| ``RUN_KLAYOUT``                   | Enables running Klayout and GDSII |
|                                   | streaming. 1 = Enabled, 0 =       |
|                                   | Disabled (Default: ``1``)         |
+-----------------------------------+-----------------------------------+
| ``RUN_KLAYOUT_DRC``               | Enables running Klayout DRC on    |
|                                   | GDS-II produced by magic. 1 =     |
|                                   | Enabled, 0 = Disabled (Default:   |
|                                   | ``0``)                            |
+-----------------------------------+-----------------------------------+
| ``KLAYOUT_DRC_KLAYOUT_GDS``       | Enables running Klayout DRC on    |
|                                   | GDS-II produced by Klayout. 1 =   |
|                                   | Enabled, 0 = Disabled (Default:   |
|                                   | ``0``)                            |
+-----------------------------------+-----------------------------------+
| ``RUN_KLAYOUT_XOR``               | Enables running Klayout XOR on 2  |
|                                   | GDS-IIs, the defaults are the one |
|                                   | produced by magic vs the one      |
|                                   | produced by klayout. 1 = Enabled, |
|                                   | 0 = Disabled (Default: ``1``)     |
+-----------------------------------+-----------------------------------+
| ``KLAYOUT_XOR_GDS``               | If ``RUN_KLAYOUT_XOR`` is         |
|                                   | enabled, this will enable         |
|                                   | producing a GDS output from the   |
|                                   | XOR along with it’s PNG export. 1 |
|                                   | = Enabled, 0 = Disabled (Default: |
|                                   | ``1``)                            |
+-----------------------------------+-----------------------------------+
| ``KLAYOUT_XOR_XML``               | If ``RUN_KLAYOUT_XOR`` is         |
|                                   | enabled, this will enable         |
|                                   | producing an XML output from the  |
|                                   | XOR. 1 = Enabled, 0 = Disabled    |
|                                   | (Default: ``1``)                  |
+-----------------------------------+-----------------------------------+
| ``TAKE_LAYOUT_SCROT``             | Enables running Klayout to take a |
|                                   | PNG screenshot of the produced    |
|                                   | layout (currently configured to   |
|                                   | run on the results of each        |
|                                   | stage).1 = Enabled, 0 = Disabled  |
|                                   | (Default: ``0``)                  |
+-----------------------------------+-----------------------------------+
| ``TAP_DECAP_INSERTION``           | Enables tap and decap cells       |
|                                   | insertion after floorplanning (if |
|                                   | enabled) .1 = Enabled, 0 =        |
|                                   | Disabled (Default: ``1``)         |
+-----------------------------------+-----------------------------------+
| ``DIODE_INSERTION_STRATEGY``      | Specifies the insertion strategy  |
|                                   | of diodes to be used in the flow. |
|                                   | 0 = No diode insertion, 1 = Spray |
|                                   | diodes, 2 = insert fake diodes    |
|                                   | and replace them with real diodes |
|                                   | if needed. 3= use FastRoute       |
|                                   | Antenna Avoidance flow, 4 = Use   |
|                                   | Sylvian’s Custom Script for diode |
|                                   | insertion on design pins and      |
|                                   | smartly inserting needed diodes   |
|                                   | inside the design, 5 = a mix of   |
|                                   | strategy 2 and 4. (Default:       |
|                                   | ``3``)                            |
+-----------------------------------+-----------------------------------+
| ``WIDEN_SITE``                    | Specifies the new virtual width   |
|                                   | of the site to be used in all     |
|                                   | stages up to diode insertion,     |
|                                   | then switched back to the         |
|                                   | original site width. It can be    |
|                                   | either a factor or an absolute    |
|                                   | value controlled by               |
|                                   | ``WIDEN_SITE_IS_FACTOR``          |
|                                   | (Default: ``1``)                  |
+-----------------------------------+-----------------------------------+
| ``WIDEN_SITE_IS_FACTOR``          | Specifies whether the given       |
|                                   | ``WIDEN_SITE`` should be treated  |
|                                   | as a factor or an absolute value. |
|                                   | 0 = absolute, 1 = factor          |
|                                   | (Default: ``1``)                  |
+-----------------------------------+-----------------------------------+
| ``USE_ARC_ANTENNA_CHECK``         | Specifies whether to use the      |
|                                   | openroad ARC antenna checker or   |
|                                   | magic antenna checker. 0=magic    |
|                                   | antenna checker, 1=ARC OR antenna |
|                                   | checker (Default: ``1``)          |
+-----------------------------------+-----------------------------------+
| ``RUN_SPEF_EXTRACTION``           | Specifies whether or not to run   |
|                                   | SPEF extraction on the routed     |
|                                   | DEF. 1=enabled 0=disabled         |
|                                   | Default: ``1``                    |
+-----------------------------------+-----------------------------------+
| ``GENERATE_FINAL_SUMMARY_REPORT`` | Specifies whether or not to       |
|                                   | generate a final summary report   |
|                                   | after the run is completed. Check |
|                                   | command                           |
|                                   | ``generate_final_summary_report`` |
|                                   | .                                 |
|                                   | 1=enabled 0=disabled Default:     |
|                                   | ``1``                             |
+-----------------------------------+-----------------------------------+
| ``RUN_CVC``                       | Runs CVC on the output spice,     |
|                                   | which is a Circuit Validity       |
|                                   | Checker. Voltage aware ERC        |
|                                   | checker for CDL netlists. Thus,   |
|                                   | it controls the command           |
|                                   | ``run_lef_cvc``. 1=Enabled,       |
|                                   | 0=Disabled. Default: ``1``        |
+-----------------------------------+-----------------------------------+
| ``MAGIC_CONVERT_DRC_TO_RDB``      | **Removed: Will always run**      |
|                                   | Specifies whether or not generate |
|                                   | a Calibre RDB out of the          |
|                                   | magic.drc report. Result is saved |
|                                   | in ``<run_path>/results/magic/``. |
|                                   | 1=enabled 0=disabled Default:     |
|                                   | ``1``                             |
+-----------------------------------+-----------------------------------+

Checkers
~~~~~~~~

+-----------------------------------+-----------------------------------+
| Variable                          | Description                       |
+===================================+===================================+
| ``CHECK_UNMAPPED_CELLS``          | Checks if there are unmapped      |
|                                   | cells after synthesis and aborts  |
|                                   | if any was found. 1 = Enabled, 0  |
|                                   | = Disabled (Default: ``1``)       |
+-----------------------------------+-----------------------------------+
| ``CHECK_ASSIGN_STATEMENTS``       | Checks for assign statement in    |
|                                   | the generated gate level netlist  |
|                                   | and aborts of any was found.1 =   |
|                                   | Enabled, 0 = Disabled (Default:   |
|                                   | ``0``)                            |
+-----------------------------------+-----------------------------------+
| ``QUIT_ON_TR_DRC``                | Checks for DRC violations after   |
|                                   | routing and exits the flow if any |
|                                   | was found. 1 = Enabled, 0 =       |
|                                   | Disabled (Default: ``1``)         |
+-----------------------------------+-----------------------------------+
| ``QUIT_ON_MAGIC_DRC``             | Checks for DRC violations after   |
|                                   | magic DRC is executed and exits   |
|                                   | the flow if any was found. 1 =    |
|                                   | Enabled, 0 = Disabled (Default:   |
|                                   | ``1``)                            |
+-----------------------------------+-----------------------------------+
| ``QUIT_ON_ILLEGAL_OVERLAPS``      | Checks for illegal overlaps       |
|                                   | during magic extraction. In some  |
|                                   | cases, these imply existing       |
|                                   | undetected shorts in the design.  |
|                                   | It also exits the flow if any was |
|                                   | found. 1 = Enabled, 0 = Disabled  |
|                                   | (Default: ``1``)                  |
+-----------------------------------+-----------------------------------+
| ``QUIT_ON_LVS_ERROR``             | Checks for LVS errors after       |
|                                   | netgen LVS is executed and exits  |
|                                   | the flow if any was found. 1 =    |
|                                   | Enabled, 0 = Disabled (Default:   |
|                                   | ``1``)                            |
+-----------------------------------+-----------------------------------+
