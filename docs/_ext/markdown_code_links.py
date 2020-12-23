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

def setup(app):
    app.add_config_value('markdown_code_links_githubrepo', 'https://github.com/name/repo', 'html')
    app.add_config_value('markdown_code_links_githubbranch', 'blob/master', 'html')
    app.add_config_value('markdown_code_links_codefileextensions', ['.c','.cpp'], 'html')
    app.connect('source-read', process_image_links)
    return {'version': '1.0',
            'parallel_read_safe': True}


def local_link_to_github (link, docname, githublink):
    # get source document dir
    path = docname.rpartition('/')[0]
    # remove './'
    if link.startswith('./'):
       link = link[2:]
    # move up if necessary
    while link.startswith('../'):
       link = link.partition('/')[2]
       path = path.rpartition('/')[0]
    # combine with repo path
    if len(path): 
       link = path.rstrip('/') + '/' + link.lstrip('/')
    # combine with repo link
    link = githublink.rstrip('/') + '/' + link.lstrip('/')
    return link
    
def printv (verb, lvl, arg):
    ''' Print depending on verbose level '''
    if verb >= lvl: print (arg)

def process_image_links(app, docname, source):
    """
    Converts local code links (specific file types) in markdown files
    to github links to the same repo
    from: [link_name](./dir1/dir2.../file.ext)
    to:   [link_name(https:gihtub.com/repo/dir1/dir2.../file.ext)
    This function is called by sphinx for each document. 
    `source` is a 1-item list. 
    """
    verb = 1 # verbosity level (debug)

    githublink          =  app.config.markdown_code_links_githubrepo.rstrip('/') + '/'
    githublink          += app.config.markdown_code_links_githubbranch.rstrip('/')
    codefileextensions  =  app.config.markdown_code_links_codefileextensions

    # case 1 [name](./dir/file) or [name](../dir/file)
    linknameexp1    = '\[[\/\.\w]*\]'
    linktargetexp1  = '\(\.[\/\.\w]*{fileext}\)'

    # case 2 [tag] 
    linknameexp2    = '\[[0-9]*\]\:\s*'
    linktargetexp2  = '\.[\/\.\w]*{fileext}\s*\n'

    for fileext in codefileextensions:
        if fileext.startswith('.') or fileext.startswith('/'):
            fileext = '\\' + fileext

        linkexp = linknameexp1 + linktargetexp1.format(fileext=fileext)
        for m in reversed(list( re.finditer( linkexp, source[0]) )):
                printv (verb, 1, f"Code link conv {docname} : {m.group(0)}")
                # strip link
                link = m.group(0).partition('(')[2].rpartition(')')[0]
                link = local_link_to_github (link, docname, githublink)               
                # combine with rest of markdown link
                link = m.group(0).partition('(')[0] + '(' + link + ')'
                printv (verb, 2, link)
                source[0] = source[0][:m.start()] + link + source[0][m.end():]

        linkexp = linknameexp2 + linktargetexp2.format(fileext=fileext)
        for m in reversed(list( re.finditer(linkexp, source[0]) )):
                printv (verb, 1, f"Code link conv {docname} : {m.group(0).strip()}")
                # strip link
                link = m.group(0).rpartition(':')[2].lstrip()
                link = local_link_to_github (link, docname, githublink)               
                # combine with rest of markdown link
                link = m.group(0).partition(':')[0] + ': ' + link
                printv (verb, 2, link)
                source[0] = source[0][:m.start()] + link + source[0][m.end():]
 

