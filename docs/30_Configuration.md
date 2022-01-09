# Config file #

Edit the file `./config/repos.cfg`.
It is parsed by reading lines starting with a letter in the 1st column. 
You can use `#` or `;` to add comments.

Each config line contains of
* repository url on any git server
* Label to identify the project in an overview page; This label will be used 
  only if no title was set in docs/config.json inside a project repo

In a line divide values with pipe `|`

# Example #

Example with 2 entries:

```text
# ----------------------------------------------------------------------
# CONFIG
#
# Syntax:
# [Repo url] | [Label]
#
# Example:
# https://github.com/iml-it/appmonitor.git|IML Appmonitor
#
# ----------------------------------------------------------------------

https://github.com/axelhahn/multidoc-generator.git|Axels Multidoc generator|
https://github.com/iml-it/appmonitor.git|IML Appmonitor|

```