# Overview page

To generate the overview page with all projects the template `./config/overview.template` will be sourced.

This file is used as a bash include. Here are 2 variables:

* **html_page**
  the html code of the html page.
  You can add links to a custom css or javascript - and must put your own files to the `./public_html/` directory.
  It has one placeholder: `${CONTENT}` to insert all elements.

* **html_element**
  This is the html code per project. The combined html code of all projects will be used as `${__CONTENT__}` in the variable $html_page (see above)
  Placeholders are the following variables:
  * `${__url_doc__}` - url to the generated docs
  * `${__label__}` - label for the project; it is taken from config.json - entry "title"; if it is missing it is taken from config/repos.cfg.
  * `${__descr__}` - description of the project; it is taken from config.json - entry "tagline"
  * `${__author__}` - description of the project; it is taken from config.json - entry "author"
  * `${__url_repo__}` - repo url; taken from config/repos.cfg
  * `${__commit__}` - last commit message; it is a automatically read info of author and date from git log

Because it is Bash: quote the `"` char with a backslash in both variables.

# distributed template: datatable

There is a template to use a table where you get a table row per project.

We load the datatables.net library and jQuery to get a table that can be filtered and sorted.

```shell
# ================================================================================
#
# HTML TEMPLATE FOR OVERVIEW PAGE
#
# >>> datatable
#
# --------------------------------------------------------------------------------
# 2021-01-12  v0.1  ahahn  init
# ================================================================================


# --------------------------------------------------------------------------------
# html page
# --------------------------------------------------------------------------------
html_page="<!doctype html>
<html>
    <head>
        <script src=\"https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js\" integrity=\"sha512-894YE6QWD5I59HgZOGReFYm4dnWc1Qt5NtvYSaNcOP+u1T9qYdvdihz0PPSiiqn/+/3e7Jo4EaG7TubfWGUrMQ==\" crossorigin=\"anonymous\" referrerpolicy=\"no-referrer\"></script>
        <link rel=\"stylesheet\" type=\"text/css\" href=\"https://cdn.datatables.net/1.11.3/css/jquery.dataTables.css\">
        <script type=\"text/javascript\" charset=\"utf8\" src=\"https://cdn.datatables.net/1.11.3/js/jquery.dataTables.js\"></script>
        <style>
            body{background:#f8f8f8; color: #345; margin: 1% 3%;}
            a{color: #23c; }
            h1{margin: 0 0 0.3em;}
            div.dataTables_wrapper{border: 3px solid #fff; box-shadow: 0 0 2em #ddd; padding: 1.5em;}
        </style>
    </head>
    <body>
        <h1>My Docs</h1>

        <table id=\"table_id\" class=\"display\">
            <thead>
                <tr>
                    <th>App</th>
                    <th>Repository</th>
                    <th>Last commit</th>
                </tr>
            </thead>
            <tbody>

                ${__CONTENT__}

            </tbody>
        </table>

        <script>
            \$(document).ready( function () {
                \$('#table_id').DataTable();
            } );
        </script>
      
    </body>
</html>
"

# --------------------------------------------------------------------------------
# The replacement for ${__CONTENT__} is multiple concatination per project
# of the next html snippet "html_element"
# --------------------------------------------------------------------------------
html_element="
    <tr>
        <td>
            <a href=\"${__url_doc__}/\"><strong>${__label__}</strong></a><br>
            ${__descr__}
            ${__author__}
        </td>
        <td><a href=\"${__url_repo__}\" target=\"_blank\">${__url_repo__}</a></td>
        <td><pre>${__commit__}</pre></td>
    </tr>
"

# --------------------------------------------------------------------------------
```
