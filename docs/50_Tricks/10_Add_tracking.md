# Example: Matomo tracking

The 1st question is: what are our requirements?

* a javascript function that adds the tracking request
* we need to call this function on page start
* this must be embedded on the overview page and each single documentation page

Let's start from bottom to top.

## Add a javascript file to each page

In the `config/repos.json` we can inject html code to the overview page by using 
`idx_body` ... and to each documentation file with the subkey `doc_body`:

```txt
{
    ...

    "inject": {
        "idx_body": "<script type=\"text/javascript\" src=\"functions.js\" defer=\"defer\"></script>",
        "idx_head": "<!-- no inject idx_head -->",
        "doc_body": "<script type=\"text/javascript\" src=\"functions.js\" defer=\"defer\"></script>",
        "doc_head": "<!-- no inject doc_head -->"
    },
    ...
}
```

Next to the html code we need to put a file `functions.js` into the
created target folder. Because it should be allowed to delete the complete output folder,
we create it as a source. Therefor exist 

* `config/add_2_webroot/` - add these files into output directory
* `config/add_2_projects/` - add these files into each [output-directory]/[projectname]/

So we put a file named `functions.js` into `config/add_2_webroot/`

## Execute something on page load

in the function.js you add a snippet like this

```javascript
window.onload = (event) => {
    // function1();
    // functionN();
};
```

## Add the tracking code

In Matomo you need to add a website and have look to the pre generated tracking code. 


In the on page load section I add the embed function with 2 parameters. 

* In this example I use the siteid 1 and add a simple tracking request. 
* My Matomo instance is on the same server below "/matomo" (otherwise set an absolute url like `https://matomo.example.com/`)

```javascript
/**
 * add matomo
 * @param  {string}  url   matomo url; can be relative too
 * @param  {int}     id    website id in matomo confguration
 */
 function embedTrackingCode(url, id) {
        var _paq = window._paq = window._paq || [];
        _paq.push(["trackPageView"]);
        _paq.push(["enableLinkTracking"]);

        var u=url;
        _paq.push(['setTrackerUrl', u+'matomo.php']);
        _paq.push(['setSiteId', id]);

        var d=document, g=d.createElement("script"), s=d.getElementsByTagName("script")[0]; g.type="text/javascript";
        g.defer=true; g.async=true; g.src=u+"matomo.js"; s.parentNode.insertBefore(g,s);    
}

// --------------------------------------------------------------------------------
// MAIN
// --------------------------------------------------------------------------------

window.onload = (event) => {
        embedTrackingCode("/matomo/", 1);
};

```

## Final notice

If you add the javascript code and want to apply it on already generated
help pages, then delete the project subdirs in `./tmp/`.
Otherwise the inject code will be applied only on changed documentations.

Then run `generate_docs.sh` to regenerate all projects from point zero.