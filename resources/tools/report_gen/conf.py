# -*- coding: utf-8 -*-
#
# CSIT 17.01 report documentation build configuration file, created by
# sphinx-quickstart on Sun Jan 15 09:49:36 2017.
#
# This file is execfile()d with the current directory set to its
# containing dir.
#
# Note that not all possible configuration values are present in this
# autogenerated file.
#
# All configuration values have a default; values that are commented out
# serve to show the default.

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
import os
import sys

sys.path.insert(0, os.path.abspath('.'))

# -- General configuration ------------------------------------------------

# If your documentation needs a minimal Sphinx version, state it here.
#
# needs_sphinx = '1.0'

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = []

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# The suffix(es) of source filenames.
# You can specify multiple suffix as a list of string:
#
source_suffix = ['.rst', '.md']

# The master toctree document.
master_doc = 'index'

# General information about the project.
project = u'FD.io CSIT'
copyright = u'2017, FD.io'
author = u'FD.io CSIT'

# The version info for the project you're documenting, acts as replacement for
# |version| and |release|, also used in various other places throughout the
# built documents.
#
# The short X.Y version.
#version = u''
# The full version, including alpha/beta/rc tags.
#release = u''

rst_epilog = """
.. |release-1| replace:: rls1704
.. |vpp-release| replace:: VPP-17.07 release
.. |vpp-release-1| replace:: VPP-17.04 release
.. |dpdk-release| replace:: DPDK 17.05
.. |trex-release| replace:: TRex v2.25
.. |virl-image-ubuntu| replace:: ubuntu-16.04.1_2017-02-23_1.8
.. |virl-image-centos| replace:: centos-7.3-1611_2017-02-23_1.4

.. _tag documentation rst file: https://git.fd.io/csit/tree/docs/tag_documentation.rst?h=rls1707
.. _TRex intallation: https://git.fd.io/csit/tree/resources/tools/trex/trex_installer.sh?h=rls1707
.. _TRex driver: https://git.fd.io/csit/tree/resources/tools/trex/trex_stateless_profile.py?h=rls1707
.. _CSIT Honeycomb Functional Tests Documentation: https://docs.fd.io/csit/rls1707/doc/tests.vpp.func.html
.. _CSIT DPDK Performance Tests Documentation: https://docs.fd.io/csit/rls1707/doc/tests.dpdk.perf.html
.. _CSIT VPP Functional Tests Documentation: https://docs.fd.io/csit/rls1707/doc/tests.vpp.func.html
.. _CSIT VPP Performance Tests Documentation: https://docs.fd.io/csit/rls1707/doc/tests.vpp.perf.html
.. _CSIT NSH_SFC Functional Tests Documentation: https://docs.fd.io/csit/rls1707/doc/tests.nsh_sfc.func.html
.. _VPP test framework documentation: https://docs.fd.io/vpp/17.07/vpp_make_test/html/
.. _FD.io test executor vpp performance jobs: https://jenkins.fd.io/view/csit/job/csit-vpp-perf-1707-all
.. _FD.io test executor dpdk performance jobs: https://jenkins.fd.io/view/csit/job/csit-dpdk-perf-1707-all
.. _FD.io VPP compile job: https://jenkins.fd.io/view/vpp/job/vpp-merge-1707-ubuntu1604/
.. _FD.io VPP compile job: https://jenkins.fd.io/view/vpp/job/vpp-merge-1707-ubuntu1604/
.. _CSIT Testbed Setup: https://git.fd.io/csit/tree/resources/tools/testbed-setup/README.md?h=rls1707
"""

# The language for content autogenerated by Sphinx. Refer to documentation
# for a list of supported languages.
#
# This is also used if you do content translation via gettext catalogs.
# Usually you set "language" from the command line for these cases.
language = 'en'

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This patterns also effect to html_static_path and html_extra_path
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

# The name of the Pygments (syntax highlighting) style to use.
pygments_style = 'sphinx'

# If true, `todo` and `todoList` produce output, else they produce nothing.
todo_include_todos = False

# pdf_documents = [('index', u'rst2pdf', u'Sample rst2pdf doc', u'Your Name'),]


# -- Options for HTML output ----------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_theme = 'sphinx_rtd_theme'

# Theme options are theme-specific and customize the look and feel of a theme
# further.  For a list of options available for each theme, see the
# documentation.
#
# html_theme_options = {}

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_theme_path = ['env/lib/python2.7/site-packages/sphinx_rtd_theme']

html_static_path = ['../../../docs/report/_static']

html_context = {
    'css_files': [
        '_static/theme_overrides.css',  # overrides for wide tables in RTD theme
        ],
    }
