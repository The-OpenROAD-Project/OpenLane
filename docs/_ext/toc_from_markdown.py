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
import os
import os.path as path

cleanup_on_finish_files = []

def setup(app):
    app.add_event("create_index_softlink")
    app.connect('create_index_softlink', index_softlink)
    app.add_event("toc_from_markdown")
    app.connect('toc_from_markdown', auto_generate_toc)
    app.connect('build-finished', after_build_cleanup)
    return {'version': '1.0',
            'parallel_read_safe': True}

def after_build_cleanup (app, exception):
    for f in cleanup_on_finish_files:
        os.remove (path.join (app.srcdir, f))
        print (f'Deleted {f}')

def extract_markdown_links (file):
    ''' Extracts list of local markdown links from markdown file'''
    # two formats for local markdown file links
    linknameexp1    = '\[[\/\.\w]*\]'
    linktargetexp1  = '\(\.[\/\.\w]*{fileext}\)'
    linkexp1        = linknameexp1 + linktargetexp1.format(fileext='\.md')

    # case 2 [tag] link
    linknameexp2    = '\[[0-9]*\]\:\s*'
    linktargetexp2  = '\.[\/\.\w]*{fileext}\s*\n'
    linkexp2       = linknameexp2 + linktargetexp2.format(fileext='\.md')

    links =[]
    try:
       with open (file,'r') as f:
          block = f.read()
          for m in re.finditer( linkexp1, block ):
            link = m.group(0).partition('(')[2].rpartition(')')[0].strip()
            links.append (link)
          for m in re.finditer( linkexp2, block ):
             link = m.group(0).rpartition(':')[2].strip()
             links.append (link)
    except:
          print (f"Warning: Cannot process {file}")

    return links

def auto_generate_toc (app, master, tocname, cleanup = False, hidden = True, maxdepth=3):
    """
    Automaticaly generate rst file with hidden toc'
    """
    global cleanup_on_finish_files

    if cleanup:
       cleanup_on_finish_files.append(tocname)

    master  = path.join (app.srcdir, master)
    tocname = path.join (app.srcdir, path.basename (tocname))
    links = [master]

    while maxdepth:
        newlinks = []
        for file in links:
            fromfile = extract_markdown_links(file)
            newlinks += [ path.normpath( path.join (os.path.dirname(file),l)) for l in fromfile ]
        newlinks = [ l for l in set(newlinks) if l not in links ]
        if not len( newlinks ):
            break
        links += newlinks
        maxdepth -= 1

    links = [ os.path.relpath(l, os.path.dirname(tocname)) for l in links ]
    links.sort()

    with open (tocname,'w') as f:
        indent = '   '
        f.write (':orphan:\n\n')
        f.write ('.. toctree::\n')
        if (hidden):
            f.write( indent + ':hidden:\n' )
        f.write('\n')
        for l in links:
            f.write( indent + l + '\n' )

def index_softlink (app, master, cleanup = False):
    global cleanup_on_finish_files

    softlink = 'index.' + master.rpartition('.')[2]
    if cleanup:
       cleanup_on_finish_files.append(softlink)

    master  = path.join (app.srcdir, master)
    softlink = path.join (app.srcdir, softlink)

    try:
        os.symlink (master, softlink)
    except FileExistsError:
        os.remove  (softlink)
        os.symlink (master, softlink)
