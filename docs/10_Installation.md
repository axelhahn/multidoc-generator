# Install Daux #

Go to <https://daux.io/> and follow the instructions for installation of daux, i.e. with composer.

Add the path of the bin directory, i.e. `~/.config/composer/vendor/daux/daux.io/bin/` in $PATH.

# Install generator #

Extract archive anywhere. The result is:

```text
.
├── config/
|  ├── add_2_projects/
|  ├── add_2_webroot/
│  ├── overview.template.boxes.dist
│  ├── overview.template.datatable.dist
│  └── repos.cfg.dist
├── docs/
├── generate_docs.sh
├── LICENSE
├── public_html/
└── tmp/
```

# Initialize config #

Go to `./config/` directory.

* copy *.dist files to a name but without .dist
  * repos.json.dist --> repos.json
  * overview.template.boxes.dist --> overview.template (remove ".boxes" too!)
* edit config file in ./config/repos.json and add the repositories here; see [Configuration](30_Configuration.md)

