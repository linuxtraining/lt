#!/usr/bin/env bash 

### module info ###
# The build environment expects to live in a subdir build/
# It expects to find book information in the parent dir
# ./books/
# ./images/
# ./modules/
# ./build/

### import for testting  dependencies ###
. ./dependencies.sh

### settings ###

OUTPUTDIR="./output"
redirfile="$OUTPUTDIR/debug.txt"
HTMLDIR="$OUTPUTDIR/html"
HTMLIMGDIR="$HTMLDIR/images"
IMAGESDIR="./images" 
MODULESDIR="./modules"
BUILDDIR="."
LIBDIR="$BUILDDIR/lib"
export FOP_OPTS="-Xms512m -Xmx512m"
export BOOKSDIR=./books
HTMLXSL="$LIBDIR/html.xsl"
HTMLCSS="$LIBDIR/html.css"

### script configuration ###

# set this to empty or zero to disable this feature
# this could be moved to a book config
BUNDLE_APPENDICES=1

### initialisation ###

V=""
CHAPTERS=""
APPENDICES=""

DATECODE=$(date +%y%m%d | sed s/^0//)
PUBDATE=$(date +'%Y-%m-%d')
YEAR=$(date +%Y)
