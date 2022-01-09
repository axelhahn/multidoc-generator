# Installation #

Go to <https://daux.io/> and follow the instructions for installation of daux, i.e. with composer.

Add the path of the bin directory, i.e. `~/.config/composer/vendor/daux/daux.io/bin/` in $PATH.

Extract archive anywhere. The result is:

```
.
├── config
│  ├── index.html.template.dist
│  └── repos.cfg.dist
├── docs
├── generate_docs.sh
├── LICENSE
├── public_html
└── tmp
```

Go to `./config/` directory.
* copy *.dist files to the same name but without .dist
* edit config file in ./config/repos.cfg and add the repositories here
* edit ./config/index.html.template to style the overview page
