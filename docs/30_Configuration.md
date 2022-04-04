# Config file #

Edit the file `./config/repos.json`.

On top level is page information:

* title - main page title
* descr - some intro text
* sections - a key for an array of groups

A group contains

* group - the name of a group
* descr - some intro text
* items - akey for an array of projects/ docs

A group item contains

* repo - url to a git repo; it will be cloned in ./tmp/ and Daux will be used to generate its docs below public_html/[NAME]

OR

* subdir - static, already existing subdir in public_html to be added in index too

There are defaults that will be overrided by ./tmp/[NAME]/docs/config.json. 

* title - title of a project
* descr - description of a project
* author - author

# Example #

Example with 2 groups and some entries. The 2nd group "PHP" has one project using overrides.


```json
{
    "title": "Axels Open source docs",
    "descr": "Docs of my tools...",
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
