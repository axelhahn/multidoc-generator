# Start generator #

Run `./generate_docs.sh` to clone/ pull the configured repositories
and generate static html pages with daux.

# Git repositories #

All processed repositories will be cloned/ pulled in ./tmp/ directory.

```text
.
:
├── tmp/
│  ├── [PROJECT_1]/                   << subir for docs of a repo
|  |   ├── docs/
|  |   ├── ...
|  |   └── ...
|  :
│  └── [PROJECT_N]/
:
```

If git made an update or the output dir of the project below public_html 
then a flag ist set to true to start the Daux converter for this project.

# Project documentation #

Per project the command `daux generate` will be started.

The ouput is in the public_html directory. 

```text
.
:
├── public_html/
│  ├── index.html
│  └── [PROJECT]/                     << subir for docs of a repo
│     ├── daux_libraries/             << daux helper scripts
│     ├── daux_search_index.js        << data file for integrated search
│     ├── index.html                  << to html onverted md files in ./docs/
│     :
│     └── themes/                     << subdirs and files of used daux theme
:
```

# Index page #

If all projects were handled then the index.html with an overview page will 
be generated. It uses the config/overview.template.

```text
.
:
├── public_html/
│  ├── index.html                     << overvew page
│  :
│  ├── [PROJECT_1]/
│  :
│  └── [PROJECT_N]/
:
```

# File injection #

In the config directory are 2 sub directories.

* add_2_projects - files that will be synced to each public_html/[PROJECT_1]/
* add_2_webroot - files hat will be synced into webroot public_html/

From the sync are excluded files matching to the file masks "\*.sample.*" or "\*.dist".

# public_html #

Like already noticed the final output directory is ./public_html/.

You can rsync its content to a webroot (or a subdir in it) of a webservice or just open
the generated static html files locally.

# Cronjob #

You should use a cronjob to regenerate all docs. Start `./generate_docs.sh` in a cycle of your choice, eg. hourly.
