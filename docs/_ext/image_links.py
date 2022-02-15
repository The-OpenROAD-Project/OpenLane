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
    app.connect("source-read", process_image_links)
    return {"version": "1.0", "parallel_read_safe": True}


def process_image_links(app, docname, source):
    """
    Converts image links in markdown files
    from ./..../imagename.png to _static/imagename.png
    This function is called by sphinx for each document.
    `source` is a 1-item list.
    """

    linkexp = r'<img src=".*"\s*>'

    for m in re.finditer(linkexp, source[0]):
        link = m.group(0).split('"')
        if len(link) == 3 and link[1].startswith("."):
            link[1] = "_static/" + link[1].rpartition("/")[2]
            link = '"'.join(link)
            debug(f"[IMG] {docname}: {link}")

            source[0] = source[0][: m.start()] + link + source[0][m.end() :]
