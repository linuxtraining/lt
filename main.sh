#!/usr/bin/env bash
set -x
########################################################
#created by:
#porpuse:
#date:
#version: v1.0.15
########################################################

dot="$(cd "$(dirname "$0")"; pwd)"

#####
#script imports
#####
. $dot/lib/vars.sh
. $dot/lib/setup.sh
. $dot/lib/build.sh
. $dot/lib/dep.sh

main(){

while getopts "d: h" option
do
	case $option in
		d ) 	OPTDEBUG=$OPTARG
			shift 2
			;;
		h ) help
			shift 1
			exit 0
			;;
        esac
done

command=$1
book=$2

case $OPTDEBUG in
	0)	# DEBUG 0 is zero output (except help message)
		REDIR=">$redirfile 2>&1"
		;;
	"" | 1)	# DEBUG 1 is default, only STDOUT
		REDIR="2>$redirfile"
		;;
	2)	# DEBUG 2 is all output we get normally
		REDIR=""
		;;
	3)	# DEBUG 3 is all output we get normally + verbose flag everywhere
		REDIR=""
		V="-v"
		;;
	4)	# DEBUG 4 is all output we get normally + fop exec debug on + verbose flag everywhere
		REDIR=""
		EXECDEBUG="--execdebug"
		V="-v"
		;;
	*)	help
		exit 0
		;;
esac

##############

check_ROOTDIR || exit 1

books=$( cd $BOOKSDIR ; find * -maxdepth 1 -type d)
superbooks=$( cd $BOOKSDIR ; find * -maxdepth 1 -type d | grep -v minibook )
minibooks=$( cd $BOOKSDIR ; find * -maxdepth 1 -type d | grep minibook)

mkdir -p $OUTPUTDIR

# Redirect everything according to REDIR var from now on.
eval "exec $REDIR"

# Main loop
case "$command" in
  clean)
	clean
	;;
  build)
	clean
	check_book
	echo "Building '$book' book."
	build_xml
	echo "Generating pdf for '$book' book."
	build_pdf
	echo "Done generating pdf $OUTPUTDIR/book.pdf -> $pdffile" 
	;;
  html)
	[ -x "$(which xmlto)" ] || echor "xmlto not installed." || exit 1
	clean 
	check_book
	echo "Building '$book' book."
	build_xml
	echo "Generating html for '$book' book."
	build_html
 	echo "Done Generating html for '$book' book."
	;;
  *)
	help
	;;
	
esac

}











#####
# Main - _- _- _- _- _- DO NOT REMOVE - _- _- _- _- _- _- _- _
#####
main
