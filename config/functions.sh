#!/bin/sh
#

### settings###
CHAPTERS=""
APPENDIX=""

# svn project path
SVN_PROJECTDIR="https://support.ginsys.be/svn/lt"

# use the correct java runtime for fop on Ubuntu
# according to http://linuxmafia.com/faq/Admin/release-files.html
if [ -f /etc/lsb-release ]
then export JAVA_HOME=/usr/lib/jvm/java-6-sun/jre
fi

# use the correct java runtime for fop on Debian Lenny
if [ -f /etc/debian_version ]
then export JAVA_HOME=/usr/lib/jvm/default-java/jre
fi

# Set the name of the XSL stylesheet
XSLFILE="lib/lt.xsl"

# VERSION_STRING
# leave REVISION empty to automagically retrieve it 
# from local svn working copy or from trunk
MAJOR=0
MINOR=970
REVISION=

DATECODE=$(date +%y%m%d | sed s/^0//)
PUBDATE=$(date +%c)
YEAR=$(date +%Y)

### functions ###

set_ROOTDIR() {
	# sets root_dir to first parameter or to current directory and 
	# returns err 2 if ROOTDIR does not contain the right code subdirs
	if [ -z $1 ]
		then ROOTDIR="."
		else ROOTDIR=$1
		fi
	if [ 	   -d $ROOTDIR \
		-a -d $ROOTDIR/config \
		-a -d $ROOTDIR/config/books \
		-a -d $ROOTDIR/images \
		-a -d $ROOTDIR/lib \
		-a -d $ROOTDIR/modules ]
		then true
		else return 1
		fi
	}

add_mod() {
        MODULES=${MODULES}" "${ROOTDIR}/modules/$1
        }

add_chapt() {
        CHAPTERS=${CHAPTERS}" "$1
        }

add_appen() {
        APPENDIX=${APPENDIX}" "$1
        }

get_revision() {
	if [ -z $1 ]
                then file=$ROOTDIR
                else file=$1
                fi
	revision_ROOTDIR=$( svn info $file 2>/dev/null | grep Revision | awk '{print $2}' )
	revision_trunk=$( svn info $SVN_PROJECTDIR/trunk 2>/dev/null | grep Revision | awk '{print $2}' )
	if [ ! -z $revision_ROOTDIR ]
		then REVISION=$revision_ROOTDIR
		elif [ ! -z $revision_trunk ] 
		then REVISION=$revision_trunk
		else REVISION="unknown"
		fi
		
	}
