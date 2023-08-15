# Config file

The main config file is `./config/repos.json`.

## top level

On top level is a genral index page information:

* title - {string} main page title
* descr - {string} some intro text
* inject - {hash} html codes you can inject to the index page or all documentation files in head or body
* replacements - {hash} define replacements
* sections - {hash} a key for an array of groups

## 2nd level - inject

**inject** can contain the subkeys:

* idx_body - {string} html code at the end of the body of index page
* idx_head - {string} html code at the end of the html head of index page
* doc_body - {string} html code at the end of the body of each documentation page
* doc_head - {string} html code at the end of the html head of each documentation page

In those keys you can add functionality that are independent from a template, eg. website tracking with Matomo.

## 2nd level - replacements

**replacements** is an array of replacements.
You can define es many replacements you want.

### replace all between 2 markers

Each array value can contain the subkeys:

* from - {string} identifier for start
* to - {string} identifier for end
* content - {array} array items are single lines to insert between the markers

**Limitation**: 

Only the first occurance will be replaced.

**Example**: 

In your markdown you should use html comments (which are invisible in html output) and set a specific starting and ending marker.

```txt
...
<!-- START-EXAMPLE-MARKER -->
  whatever here is ... it will be removed by the content value
<!-- END-EXAMPLE-MARKER -->
...
```

For the replacement set in the repos.json:

```json
    ...
    "replacements": [
        {
            "from": "<!-- START-EXAMPLE-MARKER -->", 
            "to": "<!-- END-EXAMPLE-MARKER -->",
            "content": [
                "Here is line 1 to insert between the markers.",
                "Here is line 2 to insert between the markers."
            ]
        },
        ...
    ],
    ...
```

### string search and replace

* search - {string} search string
* content - {string} replacement

All occurances of the search string will be replaced.

For the replacement set in the repos.json:

```json
    ...
    "replacements": [
        {
            "search": "[PLACEHOLDER_1]",
            "content": "I am the real value. "
        },
        {
            "search": "[PLACEHOLDER_2]",
            "content": "I am something else. "
        }
    ],
    ...
```

## 2nd level - sections

**sections** contains

* group - {string} the name of a group
* descr - {string} some intro text
* items - {hash} a key for an array of projects/ docs

## 3rd level - sections -> # -> items

An object in sections->[number]->**items** describes a single documentation of a product or process.
You need one of the keys:

* repo - {string} url to a git repo with https:// protocol; it will be cloned in ./tmp/ and Daux will be used to generate its docs below public_html/[NAME]
* docurl - {śtring} optional: absolute url to an external doc page

OR

* subdir - {string} static, already existing subdir in public_html to be added in index too

Remark:
If a "repo" url or a given "subdir" does not exist then won't appear in the index page.

Next to repo|subdir there are default values that will be overrided by ./tmp/[PROJECT]/docs/config.json. 

* title - {string} title of a project
* descr - {string} description of a project
* author - {string} author

# Example repo.json

Example with 2 groups and some entries. The 2nd group "PHP" has one project using overrides.

```json
{
    "title": "Axels Open source docs",
    "descr": "Docs of my tools...",
    
    "inject": {
        "idx_body": "<!-- script type=\"text/javascript\" src=\"functions.js\" defer=\"defer\"></script -->",
        "idx_head": "<!-- no inject idx_head -->",
        "doc_body": "<!-- script type=\"text/javascript\" src=\"/docs/functions.js\" defer=\"defer\"></script -->",
        "doc_head": "<!-- no inject doc_head -->"
    },

    "replacements": [
        {
            "from": "<!-- START-ADD-TTY-PLAYER -->", 
            "to": "<!-- END-ADD-TTY-PLAYER -->",
            "content": [
                "<html>",
                "  <script src=/docs/addons/ttyrec/webcomponents-lite.min.js></script>",
                "  <link rel=stylesheet href=/docs/addons/ttyrec/tty-player.css>",
                "  <script src=/docs/addons/ttyrec/term.min.js></script>",
                "  <script src=/docs/addons/ttyrec/tty-player.min.js></script>",
                "</html>"
            ]
        },
        {
            "search": "[SOMETHING]",
            "content": "I am the replacement. "
        }
    ],

    "sections":
    [
        {
            "group": "Bash",
            "descr": "Shellscript based stuff",
            "items":
                [
                    {
                        "subdir": "manuell_1",
                        "title": "Static dir 1",
                        "descr": "A Non-Daux-Doc",
                        "author": "John Doe"
                    },
                    {"repo": "https://github.com/axelhahn/multidoc-generator.git"},
                    {"repo": "https://git-repo.iml.unibe.ch/iml-open-source/iml-backup.git"}                
                ]
        },
        {
            "group": "PHP",
            "descr": "Projects written in PHP",
            "items":
                [
                    {
                        "repo": "https://github.com/iml-it/appmonitor.git",
                        "title": "IML Appmonitor",
                        "descr": "Axels Multidoc generator",
                        "author": "Axels Hahn"
                        }
                ]
        }
    ]
}```
