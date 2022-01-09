# Overview page #

To generate the overview page with all projects the template `./config/index.html.template` will be used.


```html
<!doctype html>
<html>
    <head>
        ...
    </head>
    <body>
        <h1>My Docs</h1>

        __CONTENT__

        ...

    </body>
</html>
```

The string `__CONTENT__` will be replaced with a table.

You can add links to a custom css or javascript - and must put your own files to the `./public_html/` directory.
