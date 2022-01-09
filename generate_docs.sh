#!/usr/bin/env bash
# ======================================================================
#
# MULTI DOC GENERATOR using DAUX
#
# ----------------------------------------------------------------------
# 2022-01-07   ah   v0.1  first lines
# 2022-01-08   ah   v0.2  fixes found by shellcheck
# 2022-01-09   ah   v0.3  index page template with datatables
# ======================================================================

SELFDIR=$( dirname "$0" )
CFG="$SELFDIR/config/repos.cfg"
IDXTEMPLATE=$SELFDIR/config/index.html.template
IDX=$SELFDIR/public_html/index.html

IDXDATA=/tmp/index_$$

# ABOUT="MULTI DOC GENERATOR using DAUX v 0.3 - $( date )"

# ----------------------------------------------------------------------
# FUNCTIONS
# ----------------------------------------------------------------------


# check requirements to run this tool
function checkRequirements(){
    if ! which daux >/dev/null; 
    then
        echo "ERROR: Install daux first and add it to \$PATH"
        exit 1
    fi
    if ! which jq >/dev/null; 
    then
        echo "WARNING: Binary jq was not found. It is highly recommended to install it."
    fi
}


# ----------------------------------------------------------------------

# get uncommented lines from config file
function _getRepos(){
    grep "^[a-zA-Z]" "$CFG"
}


# get data from a repo with git clone or git pull
function _gitUpdate(){
    local _url=$1
    local _dirgit=$2
    if [ -d "$_dirgit" ]; then
        echo "Update local data from repo..."
        cd "$_dirgit" || exit 1
        git pull
        cd - >/dev/null || exit 1
    else
        echo "Cloning..."
        git clone "$_url" "$_dirgit"
    fi

}

# helper function for add2Index()
# get a meta info from docs/config.json of the selected repository
# A "null" result will be returned as empty string
# param  string  path to cloned git repo
# param  string  jq filter, i.e. ".title"
function _getFromRepoJson(){
    local _dirgit=$1
    local _filter=$2
    jq "${_filter}" "${_dirgit}/docs/config.json" 2>/dev/null | grep -v "null" | tr -d '"'
}

# add a table row for a project doc in the index page
# param  string  project subdir in ./public_html/
# param  string  label of the project (optional; overriden by config.json)
# param  string  url of the repository
# param  string  dir of the cloned directory
function add2Index(){
    local _prj=$1
    local _label=$2
    local _url=$3
    local _dirgit=$4

    local _lastlog=
    local _log=

    local _visLabel=
    local _visDescr=
    local _visAuthor=

    # echo "<li><a href=\"$_prj\">$_label</a></li>" >>"$IDXDATA"
    if [ -d "$_dirgit" ]; then
        cd "$_dirgit" || exit 1
        _lastlog="$( git log -1 )" 
        cd - >/dev/null || exit 1
        _visLabel=$(  _getFromRepoJson "${_dirgit}" ".title"   )
        _visDescr=$(  _getFromRepoJson "${_dirgit}" ".tagline" )
        _visAuthor=$( _getFromRepoJson "${_dirgit}" ".author"  )
    fi

    test -z "$_visLabel" && _visLabel="${_label}"
    test -z "$_visDescr" || _visDescr="${_visDescr}<br>"
    test -z "$_visAuthor" || _visAuthor="Author: ${_visAuthor}<br>"

    test -z "$_lastlog" || _log=$( echo "$_lastlog" | tr "<" '[' | tr '>' ']' | sed ':a;N;$!ba;s/\n/<br>/g' )

    echo "<tr>
        <td>
            <a href=\"${_prj}/\"><strong>${_visLabel}</strong></a><br>
            $_visDescr
            $_visAuthor
        </td>
        <td><a href=\"${_url}\" target=\"_blank\">${_url}</a></td>
        <td><pre>${_log}</pre></td>
    </tr>" >>"$IDXDATA"
}

# generate index.html with overview of all doc pages
# It reads the ./config/index.html.template
function generateIndex(){
    local _data=$( cat "$IDXDATA" 2>/dev/null )
    if [ -z "$_data" ]; then
        _data="WARNING: no project was rendered yet."
    else 
        _data="
            <table id=\"table_id\" class=\"display\">
                <thead>
                    <tr>
                        <th>App</th>
                        <th>Repository</th>
                        <th>Last commit</th>
                    </tr>
                </thead>
                <tbody>
                    $_data
                </tbody>
            </table>


        "
        # echo "$_data"
        _data=$( echo "$_data" | tr -d "\n" )
    fi

    sed "s#__CONTENT__#${_data}#g" "$IDXTEMPLATE" >"$IDX"
    ls -l "$IDX"
    rm -f "$IDXDATA"
}

# loop over config entries to re-generate the static doc pages
# and overview page
function processRepos(){
    local _url=
    local _prj=
    local _label=
    local _line=

    local _dirgit=
    local _dirdoc=

    mkdir "$SELFDIR/public_html" 2>/dev/null

    # _getRepos | while read -r _line
    _getRepos | while IFS="|" read -r _url _label
    do
        _prj=$( echo "$_url" | rev | cut -f 1 -d '/' | rev | sed "s#.git##" )

        echo "---------- $_prj - $_url"
        echo

        _dirgit="$SELFDIR/tmp/$_prj"
        _dirdoc="$SELFDIR/public_html/$_prj"

        _gitUpdate "$_url" "$_dirgit"

        rm -rf "$_dirdoc" 2>/dev/null

        if daux generate -s "$SELFDIR/tmp/$_prj/docs" -d "$_dirdoc";
        then
            add2Index "$_prj" "$_label" "$_url" "$_dirgit"
        else
            echo "ERROR occured in Daux generator ... removing target dir $_dirdoc"
            rm -rf "$_dirdoc"
        fi
        
        echo
    done

    echo "---------- generate overview"
    echo
    generateIndex
    echo
}

# ----------------------------------------------------------------------
# MAIN
# ----------------------------------------------------------------------

echo "

+--------------------------------------------------------------------------------+
|                                                                                |
|           --==##  Axels MULTI DOC GENERATOR using DAUX  ##==--                 |
|                                                                                |
+--------------------------------------------------------------------------------+


"

action=$1
case $action in
    -h|--help|-?)
        echo "HELP:"
        echo "NO PARAMS supported so far. All entries in $CFG will be processed."
        echo
        exit 1
        ;;
esac

checkRequirements
processRepos

# cat $IDX
echo "--- DONE."

# ----------------------------------------------------------------------
