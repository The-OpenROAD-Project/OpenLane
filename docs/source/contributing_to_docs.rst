Documentation Contributors guide
================================================================================

.. note:: This page is for documentation contributors. For developers see `CONTRIBUTING.md <../../CONTRIBUTING>`_

Introduction
--------------------------------------------------------------------------------
Documentation plays an important role in OpenLane.
Good documentation should cover as much information as possible,
while staying readable, up-to-date and clean.
This page covers installation of required tools
and outlines simple principles that are used when current documentation was created.

In order to fix typos, you do not need to install anything.
Pull requests can be created from ReadTheDocs page, using GitHub's editor.

For more complex documentation it is recommended to follow this steps:

1. Read this guide
2. Either create a new page in ``docs/source/``. Then you need to add your page to the Table of Contents in ``index.rst``
3. ... or open existing one from the same folder.
4. Then create the general structure of the documentation.
  
This steps ensures continuity with the rest of the documentation and allows the writer to better organize their thoughts.

5. Use reStructuredText and existing plugins to write the documentation.
6. Create as much visual documentation as possible. More is better.

Pictures, figures, tables significantly improve the quality of documentation and make the documentation available for begginers.

7. Add links to references, guide and pointers to other available documentation or books.
8. Use :ref:`building_docs_locally` to preview and visualize the documentation.
9. Copy the text from preview into an editor that highlights the mistakes and fix them.
10. Rebuild documentation and repeat.
11. Once satisfied commit the changes to your repository using git.
12. Create a Pull-request to the main repository, so the maintainers can review your changes.
13. Maintainers will request some tweaking, do it and then push the changes again.
14. Once changes are approved they will be merged and then you can delete your branch or repository.

.. _building_docs_locally:

Building documentation locally
--------------------------------------------------------------------------------

Assuming you have OpenLane installed it will create ``venv``. Install requirements for documentation building inside ``venv``.

.. code-block:: console

    cd OpenLane/
    # assuming you are inside OpenLane folder
    # assuming you have bash installed at /bin/bash

    # Install required modules
    make -C docs/ install

After installation, every time you want to build the documentation proceed to enter the venv and run ``sphinx-build`` following commands: 

.. code-block:: console

    cd OpenLane/
    # assuming you are inside OpenLane folder
    make -C docs/ html

View the generated html files using Firefox or other browser. Open this document in browser:

.. code-block:: console

    # Assuming same folder as OpenLane
    cd OpenLane/

    firefox docs/_build/html/docs/source/contributing_to_docs.html

Documentation `regarding reStructuredText can be found here <https://sublime-and-sphinx-guide.readthedocs.io/en/latest/index.html>`_. 

Documentation organization
--------------------------------------------------------------------------------
All of the documentation is concetrated in ``docs/``.
Static files are stored in ``docs/_static`` in respective directory.
For example, screenshots for this guide are located in ``docs/_static/docs_contrbution``,
while the screenshots for the installation guide are located in ``docs/_static/installation``.

Directory ``docs/source/`` contains all of the page's content.
You can add pages by creating the corresponding file in that folder.
Then you need to add your page to the Table of Contents in ``index.rst``.
Or if you want it to be in category, then modify the Table of Contents of said category.
If you want to create new category than take a look at the source code of existing category.

Writing Style and Consistency
--------------------------------------------------------------------------------

* New documentation should be written in reStructuredText not Markdown. Take a look at existing RST documentation to get glimpse of its syntax.
* Use ``of`` instead of ``'``, for example: ``Docker's Installation`` → ``after the installation of the Docker``.
* Instead of ``don't`` and ``can't`` use full forms: ``do not`` and ``cannot``
* The first command of the page should have `cd` in it to specify where you are running and all following commands assume the continuation of the session and don't need the cd command.
* In Markdown avoid using same header type both for the title of the document and its content. It looks awful in the table of content.

Terms Consistency
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In order to improve the readability of the documentation it is recommended to use the names of the projects properly. Some examples you can see below:

.. code-block::

    OpenLANE → OpenLane
    OpenRoad → OpenROAD
    Mac OS X → macOS
    MAGIC → Magic
    open source → open-source
    Skywater130 → sky130
    Klayout → KLayout

* For technical terms use OpenROAD documentation preferences:

.. code-block::

    co-ordinates → coordinates
    pad ring → padring
    pad cell → padcell
    key value pair → key-value pair
    micrometre → micron (or, micrometer)

Making screenshots
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The screenshots in documentation should use following prompt:

.. code-block:: console

    export PS1="\W> "

You can add it to your ``.bashrc`` or just run it before you run the command.


Confusing Header structure of RST
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Use headers to make structure of the documentation better. For underline and overlines use 80 symbols. Here are the header priorities. Top is the highest priority.

.. code-block::

    # with overline
    * with overline
    =
    -
    ^
    "

What's overline?

.. code-block::

    ################## <- Overline
    OVERLINED TITLE
    ##################

Troubleshooting
--------------------------------------------------------------------------------

Your ``code-block`` s do not look like they are supposed to
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. important::
    Intendation, whitespaces, newlines of the reStructuredText are really important. They all have meaning in .rst files, so take a look at the already existing code to help you figure out the issues.

How it looks:

.. image:: ../_static/docs_contribution/code_block_issue.png

How it is supposed to look:

.. image:: ../_static/docs_contribution/code_block_supposed_look.png

This is because ``code-blocks`` need to have empty lines around code sections, like shown in the picture below:

.. image:: ../_static/docs_contribution/code_block_spaces_around_the_code.png

Pip module related errors
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
If you did not source ``../venv/bin/activate`` when running ``sphinx-build`` then you will get error similar to the one below.

.. code-block:: console

    Running Sphinx v5.0.1

    Configuration error:
    There is a programmable error in your configuration file:

    Traceback (most recent call last):
    File "/home/armleo/.local/lib/python3.10/site-packages/sphinx/config.py", line 343, in eval_config_file
        exec(code, namespace)
    File "/home/armleo/Desktop/OpenLaneGSOC/conf.py", line 24, in <module>
        from recommonmark.parser import CommonMarkParser
    ModuleNotFoundError: No module named 'recommonmark'

In order to resolve this, repeat the steps above for enabling venv.

Sphinx build complains about title underline being too short
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

When running ``sphinx-build`` you may get following warning:

.. code-block:: console

    /home/armleo/Desktop/OpenLaneGSOC/docs/source/installation.rst:3: WARNING: Title underline too short.

    Installation of OpenLane
    ########

Try to use 80 symbol long header underlines. This makes replacing them easier and keeps the documentation code consistent.
