# Install Daux #

Go to <https://daux.io/> and follow the instructions for installation of daux, i.e. with composer.

Add the path of the bin directory, i.e. `~/.config/composer/vendor/daux/daux.io/bin/` in $PATH.

# Install generator #

Extract archive anywhere. The result is:

```text
.
├── config/
│  ├── index.html.template.dist
│  └── repos.cfg.dist
├── docs/
├── generate_docs.sh
├── LICENSE
├── public_html/
└── tmp/
```

# Initialize config #

Go to `./config/` directory.
* copy *.dist files to the same name but without .dist
* edit config file in ./config/repos.cfg and add the repositories here
* edit ./config/index.html.template to style the overview page
