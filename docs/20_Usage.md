# Usage #

Run `generate_docs.sh` to clone/ pull the configured repositories
and generate static html pages with daux.

The ouput is in the public_html directory. You can rsync its content
to a webroot (or a subdir in it) of a webservice or just open
the generated static html files locally.

```
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