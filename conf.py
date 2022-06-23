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
# Yes, it needs to be in this directory. Don't try to move it.
# Yes, it needs to be called conf.py


# -- Path setup --------------------------------------------------------------
import os
import sys
from recommonmark.parser import CommonMarkParser

sys.path.insert(0, os.path.abspath("docs/_ext"))

# -- Project information -----------------------------------------------------
project = "OpenLane"
copyright = "2020-2021 Efabless Corporation"
author = "Efabless Corporation"


# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    "sphinx.ext.todo",
    "markdown_code_links",  # CUSTOM
    "markdown_cross_doc_section_links",  # CUSTOM
    "sphinx.ext.autosectionlabel",
    "sphinx_markdown_tables",
    "image_links",  # CUSTOM
    "toc_from_markdown",  # CUSTOM
    "recommonmark"
]

# Expand source suffixes

source_parsers = {
    ".md": CommonMarkParser,
}

source_suffix = {
    ".rst": "restructuredtext",
    ".md": "markdown",
}


# Add any paths that contain templates here, relative to this directory.
templates_path = ["_templates"]

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = [
    "_build",
    "Thumbs.db",
    "scripts/tcl_commands/README.md",
    ".github/ISSUE_TEMPLATE"
    "venv/lib"
    # Files included in other rst files.
]


# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_title = "OpenLane Documentation"

html_theme = "furo"

# Theme options are theme-specific and customize the look and feel of a theme
# further.  For a list of options available for each theme, see the
# documentation.
html_theme_options = {}

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ["docs/_static"]

html_sidebars = {}

todo_include_todos = True
numfig = True
markdown_code_links_githubrepo = "https://github.com/The-OpenROAD-Project/OpenLane"
markdown_code_links_githubbranch = "blob/master"
markdown_code_links_codefileextensions = [
    ".tcl",
    ".sh",
    ".cfg",
    ".gds",
    ".sdc",
    "/",
    ".json",
    "Makefile",
]
autosectionlabel_prefix_document = True

suppress_warnings = ["misc.highlighting_failure"]  # supress json highlight warnings


def setup(app):
    app.emit("create_index_softlink", "docs/source/index.rst", True)
    # app.emit("toc_from_markdown", "docs/source/index.rst", ".autotoc.rst")


root_doc = 'docs/source/index'
