#!/bin/sh
#

set_ROOTDIR() {
	# sets root_dir to first parameter or to current directory and 
	# returns err 2 if ROOTDIR does not contain the right code subdirs
	if [ -z $1 ]
		then ROOTDIR="."
		else ROOTDIR=$1
		fi
	if [ 	   -d $ROOTDIR \
		-a -d $ROOTDIR/bin \
		-a -d $ROOTDIR/configs \
		-a -d $ROOTDIR/footer \
		-a -d $ROOTDIR/header \
		-a -d $ROOTDIR/images \
		-a -d $ROOTDIR/lib \
		-a -d $ROOTDIR/modules ]
		then true
		else exit 1
		fi
	}

add_mod() {
        modules=${modules}" "${ROOTDIR}/modules/$1
        }

get_revision() {
	. $ROOTDIR/config/settings
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
