# Start generator #

Run `./generate_docs.sh` to clone/ pull the configured repositories
and generate static html pages with daux.

# Git repositories #

All processed repositories will be cloned/ pulled in tmp directory.
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

# Output #

Per project the command `daux generate` will be started.

The ouput is in the public_html directory. You can rsync its content
to a webroot (or a subdir in it) of a webservice or just open
the generated static html files locally.

```text
.
:
├── public_html/
│  ├── index.html                     << overvew page
│  └── [PROJECT]/                     << subir for docs of a repo
│     ├── daux_libraries/             << daux helper scripts
│     ├── daux_search_index.js        << data file for integrated search
│     ├── index.html                  << to html onverted md files in ./docs/
│     :
│     └── themes/                     << subdirs and files of used daux theme
:
```

# Cronjob #

You should use a cronjob to regenerate all docs. Start `./generate_docs.sh` in a cycle of your choice, eg. hourly.
