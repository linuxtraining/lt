#!/usr/bin/env bash
#set -e
####################



dot="$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P)"

set_xsl() {
	if	[ -r $BOOKSDIR/$book/lt.xsl ]
		then	XSLFILE="$BOOKSDIR/$book/lt.xsl"
		else	XSLFILE="$LIBDIR/lt.xsl"
	fi
}

set_JAVA() {
	# Debian / ubuntu specific
	if [[ -x "$(which java)" ]];then
	    JAVA_ALTERNATIVE=$(readlink /etc/alternatives/java)
		export JAVA_HOME=${JAVA_ALTERNATIVE%/bin/java}
	else    
		echo "Could not set JAVA_HOME, something unexpected happened in $0"
		exit 1
	fi
	}

check_ROOTDIR() {

	if	[[ -d $BOOKSDIR ]] && [[ -d $MODULESDIR ]] && [[ -d $BUILDDIR ]];then
		echor "Current dir is book project root directory."
	else	
		echor "Please run this script from the book root directory."
		return 1
	fi

        }

add_mod() {
        # add_mod $type $name
        # type is chapter appendix of minibook
        # name is name of module or book
        type=$1
        name=$2
        case $type in
            chapter)
                CHAPTERS=${CHAPTERS}" "$name
                ;;
            appendix)
                APPENDICES=${APPENDICES}" "$name
                ;;
            minibook)
                MINIBOOKS=${MINIBOOKS}" "$name
                ;;
        esac
        }

echor() {	# echo error
	
	sleep 0.1
	echo $* >&2
	}

echod() {	# echo debug
	
	sleep 0.1
	[[ $OPTDEBUG -ge 2 ]] && echo $* 
	}