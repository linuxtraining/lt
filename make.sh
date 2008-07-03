#!/bin/sh

. config/settings.sh
. config/functions.sh


help() {
	echo
	echo $0 "clean\t\tdelete output dir"
	echo $0 "install\tdownload static build environment to ../static"
	echo $0 "build\t\tbuild book"
	echo
	echo Available books: $( ls books/*.cfg | sed s/.cfg// )
	echo
	}

check() {
	set_ROOTDIR || ( echo "It does not look like I'm in the project root dir?"; exit)
	if [ -z $REVISION ] ; then get_revision ; fi
	echo "Current dir $(pwd) appears to match the project root dir"
	echo
	echo "Subversion repository:\t$SVN_PROJECTDIR"
	echo "Current version:\t$MAJOR.$MINOR.$REVISION"
	help
	}

case "$1" in
  check)
	check
	;;
  clean)
	[ -d output ] && rm -rf output || exit 0
	;;

  install)
	README/install_environment.cmd 
	;;

  *)
	help
	;;
	
esac


