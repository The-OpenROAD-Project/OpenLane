# SPDX-FileCopyrightText: 2020 Efabless Corporation
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
# SPDX-License-Identifier: Apache-2.0

# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
import os
import sys
# sys.path.insert(0, os.path.abspath('.'))
from recommonmark.parser import CommonMarkParser
sys.path.insert(0, os.path.abspath('docs/_ext'))

# -- Project information -----------------------------------------------------

project = 'OpenLANE'
copyright = '2020, efabless'
author = 'efabless'


# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
  'sphinx.ext.todo',
  'markdown_code_links',
  'markdown_cross_doc_section_links',
  'sphinx.ext.autosectionlabel',
  'sphinx_markdown_tables',
  'image_links',
  'toc_from_markdown',
  'recommonmark',
]

# Expand source suffixes

source_parsers = {
    '.md': CommonMarkParser,
}

source_suffix = {
    '.rst': 'restructuredtext',
    '.md' : 'markdown',
}




# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = [
    '_build',
    'Thumbs.db',
    'scripts/tcl_commands/README.md',
    'scripts/spef_extractor/README.md',
    # Files included in other rst files.
]


# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_theme = 'sphinx_rtd_theme'

# Theme options are theme-specific and customize the look and feel of a theme
# further.  For a list of options available for each theme, see the
# documentation.
#
# artifact sphinx_symbiflow_theme configs
"""
html_theme_options = {
    # Specify a list of menu in Header.
    # Tuples forms:
    #  ('Name', 'external url or path of pages in the document', boolean, 'icon name')
    #
    # Third argument:
    # True indicates an external link.
    # False indicates path of pages in the document.
    #
    # Fourth argument:
    # Specify the icon name.
    # For details see link.
    # https://material.io/icons/
    'header_links': [
        ('Home', 'index', False, 'home'),
        ("GitHub", "https://github.com/efabless/openlane", True, 'code'),
        ("efabless", "https://www.efabless.com/", True, 'link'),
    ],

    # Customize css colors.
    # For details see link.
    # https://getmdl.io/customize/index.html
    #
    # Values: amber, blue, brown, cyan deep_orange, deep_purple, green, grey, indigo, light_blue,
    #         light_green, lime, orange, pink, purple, red, teal, yellow(Default: indigo)
    'primary_color': 'deep_purple',
    # Values: Same as primary_color. (Default: pink)
    'accent_color': 'teal',

    # Customize layout.
    # For details see link.
    # https://getmdl.io/components/index.html#layout-section
    'fixed_drawer': True,
    'fixed_header': True,
    'header_waterfall': True,
    'header_scroll': False,

    # Render title in header.
    # Values: True, False (Default: False)
    'show_header_title': False,
    # Render title in drawer.
    # Values: True, False (Default: True)
    'show_drawer_title': True,
    # Render footer.
    # Values: True, False (Default: True)
    'show_footer': True,

    # Hide the symbiflow links
    'hide_symbiflow_links': True,
    'license_url' : 'https://www.apache.org/licenses/LICENSE-2.0',
}
"""

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['docs/_static']

todo_include_todos = True
numfig = True
markdown_code_links_githubrepo   = 'https://github.com/efabless/openlane'
markdown_code_links_githubbranch = 'blob/master'
markdown_code_links_codefileextensions = ['.tcl', '.sh', '.cfg', '.gds', '.sdc', '/', '.json', 'Makefile']
autosectionlabel_prefix_document = True

suppress_warnings = ['misc.highlighting_failure'] # supress json highlight warnings

def setup(app):
    app.emit('create_index_softlink', 'README.md', True)
    app.emit('toc_from_markdown', 'README.md', '.autotoc.rst', True)

