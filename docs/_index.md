# Multi Doc Generator #

## Description ##

A bash script to generate a collection of docs
from a list oven repositories. Those must have a docs
subdirectory what can be generated to static files
with Daux <https://daux.io/>

The script make a git clone/ pull to fetch each project.
It starts `daux generate` and creates static html files
below `./public_html/[project]` 

Additionally a `./public_html/index.html` will be generated to have an overvew page of all documentations.

All files below `./public_html/` you can read offline or it can be copied to a webserver (it is not needed that it is in the webroot).

Source: https://github.com/axelhahn/multidoc-generator

License: GNU GPL 3.0

## Requirements ##

* PHP 7.4 or 8
* Daux - generator to create static html pages from markdown. See <https://daux.io/>
