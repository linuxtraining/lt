#!/bin/sh

command=$1
book=$2

. config/settings.sh
. config/functions.sh

books=$( ls books | grep .cfg$ | sed s/.cfg// )

help() {
	echo
	echo "linux-training book build script"
	echo "http://linux-training.be"
	echo
	echo $0 "check\t\tcheck some settings"
	echo $0 "clean\t\tdelete output dir"
	echo $0 "install\tdownload static build environment to ../static"
	echo $0 "build\t\tbuild book"
	echo
	echo Available books: $books
	echo
	}

check() {
	if [ -z $REVISION ] ; then get_revision ; fi
	echo "Subversion repository:\t$SVN_PROJECTDIR"
	echo "Current version:\t$MAJOR.$MINOR.$REVISION"
	}

build_book() {
	echo "[building $book book to implement]"
	}

##############

set_ROOTDIR || ( echo "It does not look like I'm in the project root dir?"; exit)

case "$command" in
  check)
	check
	;;
  clean)
	[ -d output ] && rm -rf output || exit 0
	;;

  install)
	README/install_environment.cmd 
	;;
  build)
	check
	if [ ! -z $book ]
		then 	# check if $book parameter is one of the available books
			check=1
			for entry in $books ; do
				if [ $entry = $book ]
					then check=1
				fi
			done
			if [ $check = 1 ]
				then true
				else echo "$book is not an available book"; exit
			fi
		else
			$book="default"
		fi

	echo "Building '$book' book. Hit return to go or ctrl-c to cancel."
	read me
	build_book $book
	;;

  *)
	help
	;;
	
esac


