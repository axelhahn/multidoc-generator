# Multi Doc Generator #

License: GNU GPL 3.0

# Requirements #

* PHP 7.4 or 8
* Daux - generator to create static html pages from markdown. See <https://daux.io/>

# Installation #

* extract archive anywhere
* go to ./config/ directory 
  * copy *.dist files to the same name but without .dist
  * edit config file in ./config/repos.cfg and add the repositories here
  * edit ./config/index.html.template to style the overview page

# Usage #

Run `generate_docs.sh` to clone/ pull the configured repositories
and generate static html pages with daux.

The ouput is in the public_html directory. You can rsync its content
to a webroot (or a subdir in it) of a webservice or just open
the generated static html files locally.