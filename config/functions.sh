#!/bin/sh
#

### settings###
CHAPTERS=""
APPENDIX=""

# use the correct java runtime for fop on Ubuntu
# according to http://linuxmafia.com/faq/Admin/release-files.html
if [ -f /etc/lsb-release ]
then	#Ubuntu
	export JAVA_HOME=/usr/lib/jvm/java-6-sun/jre
elif [ -f /etc/debian_version ]
then 	# use the correct java runtime for fop on Debian Lenny
	export JAVA_HOME=/usr/lib/jvm/default-java/jre
else	echo Could not set JAVA_HOME, something unexpected happened in $0 >&2
fi

# Set the name of the XSL stylesheet
XSLFILE="lib/lt.xsl"

# VERSION_STRING
. config/version

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

