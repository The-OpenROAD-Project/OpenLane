Installation of sphinx for documentation
------------

In order to contribute to documentation you can install the sphinx and build the documentation.

.. code-block:: console

    # assuming you are inside OpenLane folder

    python -m venv venv
    source venv/bin/activate

    python -m pip install -r docs/requirements.txt 


You can check the installation and see that sphinx was installed.

.. image:: ../_static/docs_contribution_tools_installation.png
  :width: 800
  :alt: docs contribution tools installation successful

After installation, everytime you want to build the documentation you can enter the venv and run following commands: 

.. code-block:: console

    source venv/bin/activate
    sphinx-build . ../sphinx_output

.. image:: ../_static/docs_contribution_sphinx_build.png
  :width: 800
  :alt: docs contribution tools installation successful

Then you can view the generated html files using Firefox or other browser. To open this document in browser:

.. code-block:: console

    firefox ../sphinx_output/docs/source/contributing_to_docs.html

Making screenshots
-----------
The screenshots in documentation should use following prompt:

.. code-block:: console

    export PS1="\W> "

You can add it to your `.bashrc` or just run it before you take the screenshot.


Troubleshooting
----------------

If you did not source `venv/bin/activate` when running `sphinx-build` then you will get error similar to the one below.

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