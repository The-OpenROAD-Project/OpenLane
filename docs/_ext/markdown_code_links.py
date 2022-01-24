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
import os.path as path
from util import debug


def setup(app):
    app.add_config_value(
        "markdown_code_links_githubrepo", "https://github.com/name/repo", "html"
    )
    app.add_config_value("markdown_code_links_githubbranch", "blob/master", "html")
    app.add_config_value(
        "markdown_code_links_codefileextensions", [".c", ".cpp"], "html"
    )
    app.connect("source-read", process_image_links)
    return {"version": "1.0", "parallel_read_safe": False}


def local_link_to_github(link, docname, githublink):
    # get source document dir
    path = docname.rpartition("/")[0]
    # remove './'
    if link.startswith("./"):
        link = link[2:]
    # move up if necessary
    while link.startswith("../"):
        link = link.partition("/")[2]
        path = path.rpartition("/")[0]
    # combine with repo path
    if len(path):
        link = path.rstrip("/") + "/" + link.lstrip("/")
    # combine with repo link
    link = githublink.rstrip("/") + "/" + link.lstrip("/")
    return link


def process_image_links(app, docname, source):
    """
    Converts local code links (specific file types) in markdown files
    to github links to the same repo
    from: [link_name](./dir1/dir2.../file.ext)
    to:   [link_name(https:gihtub.com/repo/dir1/dir2.../file.ext)
    This function is called by sphinx for each document.
    `source` is a 1-item list.
    """

    githublink = app.config.markdown_code_links_githubrepo.rstrip("/") + "/"
    githublink += app.config.markdown_code_links_githubbranch.rstrip("/")
    codefileextensions = app.config.markdown_code_links_codefileextensions
    fulldocname = path.join(app.srcdir, docname)
    fulldocdir = path.dirname(fulldocname)

    # case 1 [name](./dir/file) or [name](../dir/file)
    linknameexp1 = r"\[[\/\.\w]*\]"
    linktargetexp1 = r"\(\.[\/\.\w]*{fileext}\)"

    # case 2 [tag]
    linknameexp2 = r"\[[0-9]*\]\:\s*"
    linktargetexp2 = r"\.[\/\.\w]*{fileext}\s*\n"

    # directory links don't need to end with '/', but will be verified as dirs
    if "/" in codefileextensions:
        codefileextensions.append("")

    for fileext in codefileextensions:
        if fileext.startswith(".") or fileext.startswith("/"):
            fileext = "\\" + fileext

        linkexp = linknameexp1 + linktargetexp1.format(fileext=fileext)
        for m in reversed(list(re.finditer(linkexp, source[0]))):
            debug(f"[CL] {docname}: {m.group(0)}")
            # strip link
            link = m.group(0).partition("(")[2].rpartition(")")[0]
            # dirs require verification
            if fileext not in ("\\/", "") or path.isdir(path.join(fulldocdir, link)):
                link = local_link_to_github(link, docname, githublink)
                # combine with rest of markdown link
                link = m.group(0).partition("(")[0] + "(" + link + ")"
                debug(link)
                source[0] = source[0][: m.start()] + link + source[0][m.end() :]

        linkexp = linknameexp2 + linktargetexp2.format(fileext=fileext)
        for m in reversed(list(re.finditer(linkexp, source[0]))):
            debug(f"[CL] {docname}: {m.group(0).strip()}")
            # strip link
            link = m.group(0).rpartition(":")[2].strip()
            # dirs require verification
            if fileext not in ("\\/", "") or path.isdir(path.join(fulldocdir, link)):
                link = local_link_to_github(link, docname, githublink)
                # combine with rest of markdown link
                link = m.group(0).partition(":")[0] + ": " + link.strip() + "\n"
                debug(link)
                source[0] = source[0][: m.start()] + link + source[0][m.end() :]
