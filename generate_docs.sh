#!/usr/bin/env bash
# ======================================================================
#
# MULTI DOC GENERATOR using DAUX
#
# ----------------------------------------------------------------------
# 2022-01-07   ah   v0.1  first lines
# 2022-01-08   ah   v0.2  fixes found by shellcheck
# 2022-01-09   ah   v0.3  index page template with datatables
# 2022-01-13   ah   v0.4  use config/overview.template for html page and entry templating
# 2022-01-20   ah   v0.5  added groups
# 2022-01-21   ah   v0.6  added footer with link to repo
# 2022-04-01   ah   v0.7  use a json config (parsed by jq)
# 2022-04-03   ah   v0.8  updated json config with page title
# 2022-04-04   ah   v0.9  detect change in git; fix spaces in jason values
# ======================================================================

SELFDIR=$( dirname "$0" )
GD_JSONCONFIG="$SELFDIR/config/repos.json"
OVERVIEW_TEMPLATE=$SELFDIR/config/overview.template
IDX=$SELFDIR/public_html/index.html

IDXDATA=/tmp/index_$$

__group__=

_repo="https://github.com/axelhahn/multidoc-generator"
__ABOUT__="<a href=\"$_repo\" target=\"_blank\">Axels MULTI DOC GENERATOR using DAUX v 0.9</a> - $( date +%Y-%m-%d\ %H:%M )"

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
        echo "WARNING: Binary jq was not found."
        exit 1
    fi
}


# ----------------------------------------------------------------------


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

# get data from a repo with git clone or git pull
function _gitUpdate(){
    local _url=$1
    local _dirgit=$2
    local _rc=0
    if [ -d "$_dirgit" ]; then
        cd "$_dirgit" || exit 1
        _logBefore=$( git log -1 );
        echo "Update local data from repo... with git pull "
        git pull
        _logAfter=$( git log -1 ); 
        if [ "$_logBefore" != "$_logAfter" ]; then
            _rc=1
        fi
        cd - >/dev/null || exit 1
    else
        echo "Cloning..."
        git clone "$_url" "$_dirgit"
        _rc=1
    fi
    return $_rc
}

# add section for a group
# param  string  name of the group
function addGroup(){
    local __group__="$1"
    local __groupinfo__="$2"

    . "${OVERVIEW_TEMPLATE}"
    echo "${html_group}" >> "$IDXDATA"
}

# close section for a group
function closeGroup(){
    . "${OVERVIEW_TEMPLATE}"
    echo "${html_group_close}" >> "$IDXDATA"
}

# add a table row for a project doc in the index page
# param  string  project subdir in ./public_html/
# param  string  label of the project (optional; overriden by config.json)
# param  string  url of the repository
# param  string  dir of the cloned directory
function add2Index(){
    local __group__="$1"
    local __url_doc__="$2"
    local _label="$3"
    local __url_repo__="$4"
    local _dirgit="$5"
    local _descr="$6"
    local _author="$7"

    local _lastlog=

    # the variables in the config/overview.template
    local __label__=
    local __descr__=
    local __author__=
    local __commit__=

    if [ -d "$_dirgit" ]; then
        cd "$_dirgit" || exit 1
        _lastlog="$( git log -1 )" 
        cd - >/dev/null || exit 1
        __label__=$(  _getFromRepoJson "${_dirgit}" ".title"   )
        __descr__=$(  _getFromRepoJson "${_dirgit}" ".tagline" )
        __author__=$( _getFromRepoJson "${_dirgit}" ".author"  )
    fi

    # if empty in git dir then take defaults from manual config config/repos.json
    test -z "$__label__" && __label__="${_label}"
    test -z "$__descr__" && __descr__="${_descr}"
    test -z "$__author__" && __author__="${_author}"

    # add br for spacing
    test -z "$__descr__" || __descr__="${__descr__}<br>"
    test -z "$__author__" || __author__="Author: ${__author__}<br>"

    # test -z "$_lastlog" || __commit__=$( echo "$_lastlog" | tr "<" '[' | tr '>' ']' | sed ':a;N;$!ba;s/\n/<br>/g' )
    test -z "$_lastlog" || __commit__=$( echo "$_lastlog" | grep -E  "^(Author|Date)" | tr "<" '[' | tr '>' ']' | sed ':a;N;$!ba;s/\n/<br>/g')

    . "${OVERVIEW_TEMPLATE}"
    echo "${html_element}" >> "$IDXDATA"
}

# generate index.html with overview of all doc pages
# It reads the ./config/overview.template
function generateIndex(){
    local _data
    local __page_title__
    local __page_descr__
    __page_title__=$( jq '.title' "$GD_JSONCONFIG" )
    __page_title__=${__page_title__//\"/}
    __page_descr__=$( jq '.descr' "$GD_JSONCONFIG" )
    __page_descr__=${__page_descr__//\"/}

    __CONTENT__=$( cat "$IDXDATA" 2>/dev/null )
    if [ -z "$__CONTENT__" ]; then
        __CONTENT__="WARNING: no project was rendered yet."
    fi

    . "${OVERVIEW_TEMPLATE}"
    echo "${html_page}" >"$IDX"

    ls -l "$IDX"
    rm -f "$IDXDATA"
}

# loop over config entries to re-generate the static doc pages
# and overview page
function processRepos(){

    typeset -i _iLength
    typeset -i _iIdx

    local _group=
    local _groupinfo=

    local _url=
    local _prj=
    local _label=
    local _line=

    local _dirgit=
    local _dirdoc=

    mkdir "$SELFDIR/public_html" 2>/dev/null

    # ----- JSON PARSING
    jq ".sections[] .group" "$GD_JSONCONFIG" | while read _mygroup
    do
        echo "=============== adding GROUP = $_mygroup"
        _group="${_mygroup//\"/}"
        _groupinfo=$( jq '.sections[] | select(.group=='$_mygroup') .descr' "$GD_JSONCONFIG" )
        addGroup "${_group}" "${_groupinfo//\"/}"
        # | jq '.[] | select(.group=="first") .items'

        echo
        echo "looping over group items ..."
        _iLength=$( jq '.sections[] | select(.group=='$_mygroup') .items|length' "$GD_JSONCONFIG" )
        for _iItem in $( seq $_iLength )
        do
            _iIdx=$_iItem-1
            _item=$( jq '.sections[] | select(.group=='$_mygroup') .items['$_iIdx']' "$GD_JSONCONFIG" )

            _url=$(    echo "$_item" | jq ".repo"    | tr -d '"')
            _title=$(  echo "$_item" | jq ".title"   | tr -d '"')
            _descr=$(  echo "$_item" | jq ".descr"   | tr -d '"')
            _author=$( echo "$_item" | jq ".author"  | tr -d '"')

            _prj=$( echo "$_url" | rev | cut -f 1 -d '/' | rev | sed "s#.git##" )

            echo
            echo "---------- $_prj - $_url"
            echo

            _dirgit="$SELFDIR/tmp/$_prj"
            _dirdoc="$SELFDIR/public_html/$_prj"

            echo "--- update git repo"
            if _gitUpdate "$_url" "$_dirgit"
            then 
                echo NO CHANGE.
            else
                echo

                echo "--- generate docs"
                rm -rf "$_dirdoc" 2>/dev/null
                if daux generate -s "$SELFDIR/tmp/$_prj/docs" -d "$_dirdoc";
                then
                    add2Index "$_group" "$_prj" "$_label" "$_url" "$_dirgit"
                else
                    echo "ERROR occured in Daux generator ... removing target dir $_dirdoc"
                    rm -rf "$_dirdoc"
                fi
            fi
        done

        closeGroup
        
    done
    echo
    echo "---------- processing of projects finished. Generating overview..."
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
        echo "NO PARAMS supported so far. All entries in $GD_JSONCONFIG will be processed."
        echo
        exit 1
        ;;
esac

checkRequirements
processRepos

echo "--- DONE."

# ----------------------------------------------------------------------
