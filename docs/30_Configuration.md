# Config file

The main config file is `./config/repos.json`.

## top level

On top level is a genral index page information:

* title - {string} main page title
* descr - {string} some intro text
* inject - {hash} html codes you can inject to the index page or all documentation files in head or body
* sections - {hash} a key for an array of groups

## 2nd level - inject

**inject** can contain the subkeys:

* idx_body - {string} html code at the end of the body of index page
* idx_head - {string} html code at the end of the html head of index page
* doc_body - {string} html code at the end of the body of each documentation page
* doc_head - {string} html code at the end of the html head of each documentation page

In those keys you can add functionality that are independent from a template, eg. website tracking with Matomo.

## 2nd level - sections

**sections** contains

* group - {string} the name of a group
* descr - {string} some intro text
* items - {hash} a key for an array of projects/ docs

## 3rd level - sections -> # -> items

A sections->[number]->**items** item contains

* repo - {string} url to a git repo; it will be cloned in ./tmp/ and Daux will be used to generate its docs below public_html/[NAME]

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
