#!/usr/bin/python3
# Copyright 2020-2022 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import re
import os
import sys
import json
import glob
import fnmatch
from enum import Enum
from io import TextIOWrapper
from typing import Any, Dict, List, Tuple, Union

import click

PDK_VAR = "PDK"
PDKPATH_VAR = "PDKPATH"
SCL_VAR = "STD_CELL_LIBRARY"
SCLPATH_VAR = "SCLPATH"
DESIGN_DIR_VAR = "DESIGN_DIR"
PROCESS_INFO_ALLOWLIST = [PDK_VAR, SCL_VAR, "STD_CELL_LIBRARY_OPT"]


Scalar = Union[str, int, float, bool, None]


class InvalidConfig(Exception):
    pass


class State(object):
    pdk: str
    scl: str
    vars: Dict[str, str]

    def __init__(self, exposed_variables: Dict[str, str]) -> None:
        self.vars = exposed_variables.copy()


class Expr(object):
    class SyntaxError(Exception):
        pass

    class Token(object):
        class Type(Enum):
            VAR = 0
            NUMBER = 1
            OP = 2
            LPAREN = 3
            RPAREN = 4

        def __init__(self, type: "Expr.Token.Type", value: str) -> None:
            self.type: Expr.Token.Type = type
            self.value: str = value

        def __repr__(self):
            return f"<Token:{self.type} '{self.value}'>"

        def prec_assoc(self) -> Tuple[int, bool]:
            """
            Returns (precedence, is_left_assoc)
            """

            if self.value in ["**"]:
                return (20, False)
            elif self.value in ["*", "/"]:
                return (10, True)
            elif self.value in ["+", "-"]:
                return (0, True)
            else:
                return (None, None)

    @staticmethod
    def tokenize(expr: str) -> List["Expr.Token"]:
        rx_list = [
            (re.compile(r"^\$(\w+)"), Expr.Token.Type.VAR),
            (re.compile(r"^(-?\d+\.?\d*)"), Expr.Token.Type.NUMBER),
            (re.compile(r"^(\*\*)"), Expr.Token.Type.OP),
            (re.compile(r"^(\+|\-|\*|\/)"), Expr.Token.Type.OP),
            (re.compile(r"^(\()"), Expr.Token.Type.LPAREN),
            (re.compile(r"^(\))"), Expr.Token.Type.RPAREN),
            (re.compile(r"^\s+"), None),
        ]
        tokens = []
        str_so_far = expr
        while not str_so_far.strip() == "":
            found = False

            for element in rx_list:
                rx, type = element
                m = rx.match(str_so_far)
                if m is None:
                    continue
                found = True
                if type is not None:
                    tokens.append(Expr.Token(type, m[1]))
                str_so_far = str_so_far[len(m[0]) :]
                break

            if not found:
                raise SyntaxError(
                    f"Unexpected token at the start of the following string '{str_so_far}'."
                )
        return tokens

    @staticmethod
    def evaluate(expression: str, vars: Dict[str, float]) -> float:
        tokens: List["Expr.Token"] = Expr.tokenize(expression)
        ETT = Expr.Token.Type

        # Infix to Postfix
        postfix = []
        opstack = []
        for token in tokens:
            if token.type == ETT.OP:
                prec, assoc = token.prec_assoc()

                top_prec = None
                try:
                    top_prec, _ = opstack[-1].prec_assoc()
                except IndexError:
                    pass

                while top_prec is not None and (
                    (assoc and prec <= top_prec) or (not assoc and prec < top_prec)
                ):
                    postfix.append(opstack.pop())
                    top_prec = None
                    try:
                        top_prec, _ = opstack[-1].prec_assoc()
                    except IndexError:
                        pass
                opstack.append(token)
            elif token.type == ETT.LPAREN:
                opstack.append(token)
            elif token.type == ETT.RPAREN:
                top = opstack[-1]
                while top.type != ETT.LPAREN:
                    postfix.append(top)
                    opstack.pop()
                    top = opstack[-1]
                opstack.pop()  # drop the LPAREN
            else:
                postfix.append(token)

        while len(opstack):
            postfix.append(opstack[-1])
            opstack.pop()

        # Evaluate
        eval_stack = []
        for token in postfix:
            if token.type == ETT.NUMBER:
                eval_stack.append(float(token.value))
            elif token.type == ETT.VAR:
                try:
                    value = vars[token.value]
                    eval_stack.append(float(value))
                except KeyError:
                    raise SyntaxError(
                        f"Configuration variable '{token.value}' not found."
                    )
                except Exception:
                    raise SyntaxError(
                        f"Invalid non-numeric value '{value}' for variable ${token.value}."
                    )
            elif token.type == ETT.OP:
                try:
                    number1 = eval_stack[-2]
                    number2 = eval_stack[-1]
                    eval_stack.pop()
                    eval_stack.pop()

                    result = 0.0
                    if token.value == "**":
                        result = number1**number2
                    elif token.value == "*":
                        result = number1 * number2
                    elif token.value == "/":
                        result = number1 / number2
                    elif token.value == "+":
                        result = number1 + number2
                    elif token.value == "-":
                        result = number1 + number2

                    eval_stack.append(result)
                except IndexError:
                    raise SyntaxError(
                        f"Not enough operands for operator '{token.value}'."
                    )

        if len(eval_stack) > 1:
            raise SyntaxError("Expression does not reduce to one value.")
        elif len(eval_stack) == 0:
            raise SyntaxError("Expression is empty.")

        return eval_stack[0]


ref_rx = re.compile(r"^\$([A-Za-z_][A-Za-z0-9_]*)")


def process_string(value: str, state: State) -> str:
    global ref_rx
    EXPR_PREFIX = "expr::"
    REF_PREFIX = "ref::"

    DIR_PREFIX = "dir::"
    PDK_DIR_PREFIX = "pdk_dir::"
    SCL_DIR_PREFIX = "scl_dir::"

    if value.startswith(DIR_PREFIX):
        value = value.replace(DIR_PREFIX, f"ref::${DESIGN_DIR_VAR}/")
    elif value.startswith(PDK_DIR_PREFIX):
        value = value.replace(DIR_PREFIX, f"ref::${PDKPATH_VAR}/")
    elif value.startswith(SCL_DIR_PREFIX):
        value = value.replace(DIR_PREFIX, f"ref::${SCLPATH_VAR}/")

    if value.startswith(EXPR_PREFIX):
        try:
            value = f"{Expr.evaluate(value[len(EXPR_PREFIX):], state.vars)}"
        except SyntaxError as e:
            raise InvalidConfig(f"Invalid expression '{value}': {e}")
    elif value.startswith(REF_PREFIX):
        reference = value[len(REF_PREFIX) :]
        match = ref_rx.match(reference)
        if match is None:
            raise InvalidConfig(f"Invalid reference string '{reference}'")
        reference_variable = match[1]
        try:
            found = state.vars[reference_variable]
            value = reference.replace(match[0], found)
            full_abspath = os.path.abspath(value)

            # Resolve globs for paths that are inside the exposed directory
            if value.startswith("/") and full_abspath.startswith(found):
                files = glob.glob(full_abspath)
                files_escaped = [file.replace("$", r"\$") for file in files]
                value = " ".join(files_escaped)
        except KeyError:
            raise InvalidConfig(
                f"Referenced variable '{reference_variable}' not found."
            )
    return value


def process_scalar(key: str, value: Scalar, state: State) -> Scalar:
    if isinstance(value, str):
        value = process_string(value, state)
    elif isinstance(value, bool):
        if value:
            value = 1
        else:
            value = 0
    elif value is None:
        value = ""
    elif not (isinstance(value, int) or isinstance(value, float)):
        raise InvalidConfig(f"Invalid value type {type(value)} for key '{key}'.")

    return value


def process_config_dict_recursive(config_in: Dict[str, Any], state: State):
    PDK_PREFIX = "pdk::"
    SCL_PREFIX = "scl::"

    for key, value in config_in.items():
        withhold = False
        if not isinstance(key, str):
            raise InvalidConfig(f"Invalid key {key}: must be a string.")
        if isinstance(value, dict):
            withhold = True
            if key.startswith(PDK_PREFIX):
                pdk_match = key[len(PDK_PREFIX) :]
                if fnmatch.fnmatch(state.vars[PDK_VAR], pdk_match):
                    process_config_dict_recursive(value, state)
            elif key.startswith(SCL_PREFIX):
                scl_match = key[len(SCL_PREFIX) :]
                if state.vars[SCL_VAR] is not None and fnmatch.fnmatch(
                    state.vars[SCL_VAR], scl_match
                ):
                    process_config_dict_recursive(value, state)
            else:
                raise InvalidConfig(
                    f"Invalid value type {type(value)} for key '{key}'."
                )
        elif isinstance(value, list):
            valid = True
            processed = []
            for (i, item) in enumerate(value):
                current_key = f"{key}[{i}]"
                processed.append(f"{process_scalar(current_key, item, state)}")

            if not valid:
                raise InvalidConfig(
                    f"Invalid value for key '{key}': Arrays must consist only of strings."
                )
            value = " ".join(processed)
        else:
            value = process_scalar(key, value, state)

        if not withhold:
            state.vars[key] = value


def process_config_dict(config_in: dict, exposed_variables: Dict[str, str]):
    state = State(exposed_variables)
    process_config_dict_recursive(config_in, state)
    return state.vars


def read_tcl_env(config_path: str, input_env: Dict[str, str] = {}) -> Dict[str, str]:
    rx = re.compile(r"\s*set\s*::env\((.+?)\)\s*(.+)")
    env = input_env.copy()
    string_data = ""
    try:
        string_data = open(config_path).read()
    except FileNotFoundError:
        print(
            f"[ERR] File {config_path} not found.",
            file=sys.stderr,
        )
        exit(os.EX_NOINPUT)

    # Process \ at ends of lines, remove semicolons
    entries = string_data.split("\n")
    i = 0
    while i < len(entries):
        if not entries[i].endswith("\\"):
            if entries[i].endswith(";"):
                entries[i] = entries[i][:-1]
            i += 1
            continue
        entries[i] = entries[i][:-1] + entries[i + 1]
        del entries[i + 1]

    for entry in entries:
        match = rx.match(entry)
        if match is None:
            continue
        name = match[1]
        value = match[2]
        # remove double quotes/{}
        value = value.strip('"')
        value = value.strip("{}")
        env[name] = value

    return env


def write_key_value_pairs(file_in: TextIOWrapper, key_value_pairs: Dict[str, str]):
    character_rx = re.compile(r"([{}])")
    for key, value in key_value_pairs.items():
        if value is None:
            continue
        if isinstance(value, str):
            value = character_rx.sub(r"\\\1", value)
        print(f"set ::env({key}) {{{value}}}", file=file_in)


def extract_process_vars(config_in: Dict[str, str]) -> Dict[str, str]:
    return {
        key: config_in.get(key)
        for key in PROCESS_INFO_ALLOWLIST
        if config_in.get(key) != ""
    }


@click.group()
def cli():
    pass


@click.command()
@click.argument("input")
def read_tcl(input):
    import json

    print(json.dumps(read_tcl_env(input)))


cli.add_command(read_tcl)


@click.command()
@click.option("-o", "--output", required=True, help="Output Tcl File")
@click.argument("input")
def extract_process_info(output, input):
    process_info = extract_process_vars(read_tcl_env(input))
    with open(output, "w") as f:
        write_key_value_pairs(f, process_info)


cli.add_command(extract_process_info)


@click.command()
@click.option("-o", "--output", default="/dev/stdout", help="File to output the Tcl to")
@click.option(
    "-e",
    "--expose",
    "exposed",
    multiple=True,
    help="Expose this environment variable to the config file as a configuration variable. PDK and STD_CELL_LIBRARY are exposed implicitly.",
)
@click.option(
    "-x",
    "--extract-process-info",
    is_flag=True,
    default=None,
    help="Extract PDK, SCL and optimization SCL only.",
)
@click.argument("config_json")
def from_json(output, exposed, extract_process_info, config_json):
    config_json_str = open(config_json).read()
    config_dict = json.loads(config_json_str)

    exposed_dict = {}

    implicitly_exposed = [PDK_VAR, PDKPATH_VAR, SCL_VAR, SCLPATH_VAR, DESIGN_DIR_VAR]
    if extract_process_info:
        implicitly_exposed = [DESIGN_DIR_VAR]

        # So we don't crash on conditional processing:
        if os.getenv(PDK_VAR) is not None:
            implicitly_exposed += [PDK_VAR]
        else:
            exposed_dict[PDK_VAR] = ""
        if os.getenv(SCL_VAR) is not None:
            implicitly_exposed += [SCL_VAR]
        else:
            exposed_dict[SCL_VAR] = ""

    exposed = list(exposed) + implicitly_exposed
    for key in exposed:
        exposed_dict[key] = os.getenv(key)

    for key in implicitly_exposed:
        if exposed_dict.get(key) is None:
            print(
                f"{key} environment variable must be set.",
                file=sys.stderr,
            )
            exit(os.EX_USAGE)

    try:
        resolved = process_config_dict(config_dict, exposed_dict)
        if extract_process_info:
            resolved = extract_process_vars(resolved)
        with open(output, "w") as f:
            write_key_value_pairs(f, resolved)
    except InvalidConfig as e:
        relpath = os.path.relpath(config_json, ".")
        print(f"{relpath}: {e}", file=sys.stderr)
        exit(os.EX_DATAERR)


cli.add_command(from_json)

if __name__ == "__main__":
    cli()
