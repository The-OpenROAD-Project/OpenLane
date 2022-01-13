#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

import re
from util import debug


def setup(app):
    app.connect("source-read", process_markdown_crosslinks)
    return {"version": "1.0", "parallel_read_safe": True}


def process_markdown_crosslinks(app, docname, source):
    """
    Converts markdown links to another doc's section:
        [link name](./path/doc.md#section)
    which are not supported by recommonmark
    to a format recognized by autosectionlabel:
        [link name](<path/doc:section>)
    Requires:
      recommonmark
      sphinx.ext.autosectionlabel
      autosectionlabel_prefix_document = True
    """

    # MD cross-section tag [tag](./dir/file.md#section)
    linknameexp = r"\[[\/\.\w]*\]"
    linktargetexp = r"\(\.[\/\.\w]*\.md#\w*\)"
    linkexp = linknameexp + linktargetexp

    for m in reversed(list(re.finditer(linkexp, source[0]))):
        link = m.group(0)
        link = link.replace("(./", "(")  # remove './' if present
        link = link.replace("(", "(<")  # change parenthesis
        link = link.replace(")", ">)")  # change parenthesis
        link = link.replace(".md#", ":")  # change section symbol
        debug(f"[CDL] {docname}: {m.group(0)} to {link}")
        source[0] = source[0][: m.start()] + link + source[0][m.end() :]
