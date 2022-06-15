Installation of sphinx for documentation
------------

In order to contribute to documentation you can install the sphinx and build the documentation.

.. code-block:: console

    # assuming you are inside OpenLane folder

    python -m venv ven
    source venv/bin/activate

    python -m pip install -r docs/requirements.txt 


You can check the installation and see that sphinx was installed.

.. image:: ../_static/docs_contribution_tools_installation.png
  :width: 800
  :alt: docs contribution tools installation successful

After installation everytime you can enter the venv and build the documentation. 

.. code-block:: console

    source venv/bin/activate
    sphinx-build . ../sphinx_output

.. image:: ../_static/docs_contribution_sphinx_build.png
  :width: 800
  :alt: docs contribution tools installation successful

Then you can view the generated html files using Firefox or other browser. To open this document in browser:

.. code-block:: console

    firefox ./sphinx_output/docs/source/contributing_to_docs.html

