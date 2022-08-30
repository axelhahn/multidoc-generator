#!/usr/bin/env bash
# ======================================================================
#
# MULTI DOC GENERATOR using DAUX
#
# ----------------------------------------------------------------------
# 2022-01-07   ah   v0.1   first lines
# 2022-01-08   ah   v0.2   fixes found by shellcheck
# 2022-01-09   ah   v0.3   index page template with datatables
# 2022-01-13   ah   v0.4   use config/overview.template for html page and entry templating
# 2022-01-20   ah   v0.5   added groups
# 2022-01-21   ah   v0.6   added footer with link to repo
# 2022-04-01   ah   v0.7   use a json config (parsed by jq)
# 2022-04-03   ah   v0.8   updated json config with page title
# 2022-04-04   ah   v0.9   detect change in git; fix spaces in jason values
# 2022-04-05   ah   v0.10  support of static dirs
# 2022-04-12   ah   v0.11  add file injection into webroot and per project
# 2022-08-07   ah   v0.12  fixed: select values with spaces
# 2022-08-21   ah   v0.13  add injection code before </head> and </body>
# 2022-08-31   ah   v0.14  fix injection function add2page
# ======================================================================

GD_VERSION="0.14"

GD_GITREPO="https://github.com/axelhahn/multidoc-generator"
GD_SELFDIR=$( dirname "$0" )
GD_JSONCONFIG="$GD_SELFDIR/config/repos.json"
GD_OVERVIEW_TEMPLATE=$GD_SELFDIR/config/overview.template
GD_DIR_PUBLISH=$GD_SELFDIR/public_html
GD_IDX=$GD_DIR_PUBLISH/index.html

GD_IDXDATA=/tmp/index_$$

__group__=

# will be inserted in footer:
__ABOUT__="<a href=\"${GD_GITREPO}\" target=\"_blank\">MULTI DOC INDEX using DAUX :: v${GD_VERSION}</a> - $( date +%Y-%m-%d\ %H:%M )"

# ----------------------------------------------------------------------
# FUNCTIONS
# ----------------------------------------------------------------------


# check requirements to run this tool
function checkRequirements(){
    if ! which daux >/dev/null; 
    then
        echo "ERROR: [daux] cannot be executed."
        echo "- Install Daux first (see https://daux.io/) and"
        echo "- Add its to \$PATH (e.g. ~/.config/composer/vendor/daux/daux.io/bin)"
        exit 1
    fi
    if ! which jq >/dev/null; 
    then
        echo "ERROR: [jq] cannot be executed."
        echo "Install jq first (eg. using package manager or download from https://stedolan.github.io/jq/)."
        exit 1
    fi
    if ! jq '.' "$GD_JSONCONFIG" >/dev/null 2>&1
    then
        echo "ERROR: There is a syntax error in the config [${GD_JSONCONFIG}]."
        jq '.' "$GD_JSONCONFIG"
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
# returns 0 if there was noch change
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

    . "${GD_OVERVIEW_TEMPLATE}"
    echo "${html_group}" >> "$GD_IDXDATA"
}

# close section for a group
function closeGroup(){
    . "${GD_OVERVIEW_TEMPLATE}"
    echo "${html_group_close}" >> "$GD_IDXDATA"
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

    . "${GD_OVERVIEW_TEMPLATE}"
    echo "${html_element}" >> "$GD_IDXDATA"
}

# ----------------------------------------------------------------------

# add string from add2body before </body> in a file
# param  string  filename to update
# param  string  html code to inject
# param  string  before what string; one of </head>|</body>
function add2Page(){
    local _file=$1
    local _what="$2"
    local _before=$3

    if [ -n "${_what}" ] && [ "${_what}" != "null" ]; then
        echo "DEBUG: add ${_what}"
        echo "DEBUG: to file $_file"
        echo "DEBUG: before $_before"
        sed -i "s#${_before}#${_what}\n${_before}#" "$_file"
    fi
}

# inject code into index page
# param  string  filename
function add2IdxPage(){
    if [ -z "${__page_add_idx_head__}" ]; then
        __page_add_idx_head__=$( jq '.inject.idx_head' "$GD_JSONCONFIG" | sed 's#^\"##' | sed 's#\"$##' )
    fi
    if [ -z "${__page_add_idx_body__}" ]; then
        __page_add_idx_body__=$( jq '.inject.idx_body' "$GD_JSONCONFIG" | sed 's#^\"##' | sed 's#\"$##' )
    fi

    add2Page "$1" "$__page_add_idx_head__" "</head>"
    add2Page "$1" "$__page_add_idx_body__" "</body>"

}

# inject code into documentation page
# param  string  filename
function add2DocPage(){
    if [ -z "${__page_add_doc_head__}" ]; then
        __page_add_doc_head__=$( jq '.inject.doc_head' "$GD_JSONCONFIG" | sed 's#^\"##' | sed 's#\"$##' )
    fi
    if [ -z "${__page_add_doc_body__}" ]; then
        __page_add_doc_body__=$( jq '.inject.doc_body' "$GD_JSONCONFIG" | sed 's#^\"##' | sed 's#\"$##' )
    fi

    add2Page "$1" "$__page_add_doc_head__" "</head>"
    add2Page "$1" "$__page_add_doc_body__" "</body>"

}

# ----------------------------------------------------------------------

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

    __CONTENT__=$( cat "$GD_IDXDATA" 2>/dev/null )
    if [ -z "$__CONTENT__" ]; then
        __CONTENT__="WARNING: no project was rendered yet."
    fi

    . "${GD_OVERVIEW_TEMPLATE}"
    echo "${html_page}" >"$GD_IDX"
    add2IdxPage "$GD_IDX"

    ls -l "$GD_IDX"
    rm -f "$GD_IDXDATA"
}

# loop over config entries to re-generate the static doc pages
# and overview page
function processRepos(){

    typeset -i _iLength
    typeset -i _iIdx

    local _group=
    local _groupinfo=

    local _subdir=
    local _url=
    local _prj=
    local _label=
    local _line=

    local _dirgit=
    local _dirdoc=

    local _bSkipIndex

    mkdir "$GD_DIR_PUBLISH" 2>/dev/null

    # ----- JSON PARSING
    jq ".sections[] .group" "$GD_JSONCONFIG" | while read _mygroup
    do
        
        _group="${_mygroup//[\"]/}" # $_mygroup without surrounding quotes

        echo
        echo "=============== adding GROUP = $_group"
        _groupinfo=$( jq ".sections[] | select(.group==${_mygroup}) .descr" "$GD_JSONCONFIG" )
        addGroup "${_group}" "${_groupinfo//\"/}"
        # | jq '.[] | select(.group=="first") .items'
        echo
        echo "looping over group items ..."
        _iLength=$( jq ".sections[] | select(.group==${_mygroup}) .items|length" "$GD_JSONCONFIG" )
        for _iItem in $( seq $_iLength )
        do
            _bSkipIndex=0
            _iIdx=$_iItem-1
            _item=$( jq ".sections[] | select(.group==${_mygroup}) .items[$_iIdx]" "$GD_JSONCONFIG" )

            # echo "DEBUG: item =  $_item"

            _title=$(  echo "$_item" | jq ".title"   | tr -d '"')
            _descr=$(  echo "$_item" | jq ".descr"   | tr -d '"')
            _author=$( echo "$_item" | jq ".author"  | tr -d '"')

            _prj=$(    echo "$_item" | jq ".subdir"  | tr -d '"')
            _url=$(    echo "$_item" | jq ".url"     | tr -d '"')

            if [ "$_prj" != "null" ]; then

                echo
                echo "---------- static dir: $_prj"
                echo
                _dirdoc="$GD_DIR_PUBLISH/$_prj"
                test -d "$_dirdoc" || _bSkipIndex=1

            else

                _url=$(    echo "$_item" | jq ".repo"    | tr -d '"')
                _prj=$( echo "$_url" | rev | cut -f 1 -d '/' | rev | sed "s#.git##" )

                echo
                echo "---------- git repo: $_prj - $_url"
                echo

                _dirgit="$GD_SELFDIR/tmp/$_prj"
                _dirdoc="$GD_DIR_PUBLISH/$_prj"

                echo "--- update git repo"
                _bDoGenerate=0
                if _gitUpdate "$_url" "$_dirgit"
                then 
                    echo NO CHANGE in git data.
                else
                    echo CHANGES DETECTED.
                    _bDoGenerate=1
                fi

                if ! test -d "$_dirdoc"
                then 
                    echo Output dir does not exist yet.
                    _bDoGenerate=1
                fi

                if test $_bDoGenerate -eq 1
                then
                    echo

                    echo "--- generate docs"
                    rm -rf "$_dirdoc" 2>/dev/null
                    daux generate -s "$GD_SELFDIR/tmp/$_prj/docs" -d "$_dirdoc";
                    for myfile in $( find "$_dirdoc" -name "*.html" )
                    do
                        add2DocPage "$myfile"
                    done
                    _bSkipIndex=$?
                fi
                test -d "$GD_SELFDIR/config/add_2_projects/" && (
                    echo "Syncing $GD_SELFDIR/config/add_2_projects/ to $_dirdoc"
                    rsync -rav \
                        --exclude "*.sample.*" \
                        --exclude "*.dist" \
                        "$GD_SELFDIR/config/add_2_projects/"* "$_dirdoc"
                )
            fi

            if test "$_bSkipIndex" = "0"
            then
                echo \> add2Index "$_group" "$_prj" "$_title" "$_url" "$_dirgit" "$_descr" "$_author"
                add2Index "$_group" "$_prj" "$_title" "$_url" "$_dirgit" "$_descr" "$_author"
            else
                echo "ERROR: do not add to index: $_dirdoc - static subdir does not exist or daux generator failed."
                rm -rf "$_dirdoc"
            fi

        done

        closeGroup
        
    done
    echo
    echo "=============== processing of projects finished. Generating overview..."
    echo
    generateIndex
    test -d "$GD_SELFDIR/config/add_2_webroot/" && (
        echo "Syncing $GD_SELFDIR/config/add_2_webroot/ to $GD_DIR_PUBLISH/"
        rsync -rav \
            --exclude "*.sample.*" \
            --exclude "*.dist" \
            "$GD_SELFDIR/config/add_2_webroot/"* "$GD_DIR_PUBLISH/"
    )

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
+---------------------------------------------------------------------- v$GD_VERSION ---+

"

action=$1
case $action in
    -h|--help|-?)
        echo "HELP:"
        # echo "NO PARAMS supported so far. All entries in $GD_JSONCONFIG will be processed."
        echo "An optional given param will be used as target dir (default: $GD_DIR_PUBLISH)"
        echo
        exit 1
        ;;
esac
if [ -n "$1" ]; then
    GD_DIR_PUBLISH=$1
    GD_IDX=$GD_DIR_PUBLISH/index.html
fi

checkRequirements
processRepos

echo "--- DONE."

# ----------------------------------------------------------------------
