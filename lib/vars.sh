#!/usr/bin/env bash 
#set -e
### module info ###
# The build environment expects to live in a subdir build/
# It expects to find book information in the parent dir
# ./books/
# ./images/
# ./modules/
# ./build/

dot=$(realpath --relative-to={PWD} {PWD})
### settings ###

OUTPUTDIR=".$dot/output"
redirfile="$OUTPUTDIR/debug.txt"
HTMLDIR="$OUTPUTDIR/html"
HTMLIMGDIR="$HTMLDIR/images"
IMAGESDIR="$dot/images" 
MODULESDIR="$dot/modules"
BUILDDIR="$dot"
LIBDIR="$BUILDDIR/lib"
export FOP_OPTS="-Xms512m -Xmx512m"
export BOOKSDIR=$dot/books
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



#####
# Main - _- _- _-is implemented in main.sh file _- _- _- _- _- _- _- _- _- _- _- _ 
#####
