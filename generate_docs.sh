#!/usr/bin/env bash
# ======================================================================
#
# MULTI DOC GENERATOR using DAUX
#
# ----------------------------------------------------------------------
# 2022-01-07   ah   v0.1  first lines
# ======================================================================

SELFDIR=$( dirname $0 )
CFG=$SELFDIR/config/repos.cfg
IDXTEMPLATE=$SELFDIR/config/index.html.template
IDX=$SELFDIR/public_html/index.html

IDXDATA=/tmp/index_$$

ABOUT="MULTI DOC GENERATOR using DAUX v 0.1 - $( date )"

# ----------------------------------------------------------------------
# FUNCTIONS
# ----------------------------------------------------------------------


# check requirements to run this tool
function checkRequirements(){
    which daux >/dev/null
    if [ $? -ne 0 ]; then
        echo "ERROR: Install daux first and add it to $PATH"
        exit 1
    fi
}


# ----------------------------------------------------------------------

# get uncommented lines from config file
function _getRepos(){
    grep "^[a-zA-Z]" $CFG 
}


# get data from a repo with git clone or git pull
function _gitUpdate(){
    local _url=$1
    local _dirgit=$2
    if [ -d "$_dirgit" ]; then
        echo "Update local data from repo..."
        cd "$_dirgit"
        git pull
        cd - >/dev/null
    else
        echo "Cloning..."
        git clone $_url "$_dirgit"
    fi

}

# add a LI item for a project doc in the index page
function add2Index(){
    local _prj=$1
    local _label=$2
    echo "<li><a href=\"$_prj\">$_label</a></li>" >>$IDXDATA
}

# generate index.html with overview of all doc pages
# It reads the ./config/index.html.template
function generateIndex(){
    local _data=$( cat $IDXDATA 2>/dev/null )
    test -z "$_data" && _data="<li>WARNING: no project was rendered yet.</li>"
    cat $IDXTEMPLATE | sed "s#__CONTENT__#$_data#g" >$IDX
    ls -l $IDX
    rm -f $IDXDATA
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

    _getRepos | while read _line
    do
        _url=$( echo $_line | cut -f 1 -d '|' )
        _prj=$( echo $_url | rev | cut -f 1 -d '/' | rev | sed "s#.git##" )
        _label=$( echo $_line | cut -f 2 -d '|' )

        echo ---------- $_prj - $_url
        echo

        _dirgit=$SELFDIR/tmp/$_prj
        _dirdoc=$SELFDIR/public_html/$_prj

        _gitUpdate "$_url" "$_dirgit"

        rm -rf "$_dirdoc" 2>/dev/null

        daux generate -s "$SELFDIR/tmp/$_prj/docs" -d "$_dirdoc"
        if [ $? -eq 0 ]; then
            add2Index "$_prj" "$_label"
        else
            echo "ERROR occured in Daux generator ... removing target dir $_dirdoc"
            rm -rf "$_dirdoc"
        fi
        
        echo
    done

    echo ---------- generate overview
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
