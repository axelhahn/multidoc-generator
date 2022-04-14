# Multi Doc Generator #

## Description ##

A bash script to generate a collection of docs
from a list of repositories. Those must have a docs
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

* PHP 7.4 or 8 (CLI) and Composer <https://getcomposer.org/>
* Daux - generator to create static html pages from markdown. See <https://daux.io/>
* jq - JSON processor <https://stedolan.github.io/jq/>
* Each handled project must have a subfolder docs that is compatible with Daux generator

## Features ##

* customizable project list (JSON)
* customizable output: html, javascript, css (2 templates are delived)
* supports groups of projects (by programming language or type)
* project list can be filtered
* add files for webroot or each doc folder of a project

## Screenshot ##

Generated index.html using the template with boxes (config/overview.template.boxes.dist):

![Screenshot: Boxes](./images/page_boxes.png)
