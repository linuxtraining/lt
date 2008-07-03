#!/bin/sh

command=$1
book=$2

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
	VERSIONSTRING=lt-$MAJOR.$MINOR.$REVISION
	echo "Subversion repository:\t$SVN_PROJECTDIR"
	echo "Current version:\t$VERSIONSTRING"
	}

build_book() {
	echo -n "Parsing config books/$book.cfg ... "
	. books/$book.cfg && echo "OK" || ( echo "Error!" ; exit )
	echo Building book $book, titled $BOOKTITLE
	[ -d ./output ] || mkdir ./output
	BOOKTITLE2=$(echo $BOOKTITLE | sed s/\ /\_/g)
	filename=$BOOKTITLE2-$VERSIONSTRING-$DATECODE
	xmlfile=output/$filename.xml
	pdffile=output/$filename.pdf
	headerfile=output/mod_header.xml
	footerfile=output/mod_footer.xml

	# make header
	cat modules/header/doctype.xml				 > $headerfile
	echo "<book>"                              		>> $headerfile
	echo "<bookinfo>"                          		>> $headerfile
	echo "<title>$booktitle</title>"           		>> $headerfile

	for author in $( <config/authors cut -d, -f1); do
		first=$(echo $author | cut -d\  -f1)
		last=$(echo $author | cut -d\  -f2-)
		echo "<author>"                        		>> $headerfile
		echo "<firstname>$first</firstname>"     	>> $headerfile
		echo "<surname>$last</surname>"      		>> $headerfile
		echo "</author>"                       		>> $headerfile
		done
	echo "<pubdate>$PUBDATE</pubdate>"         		>> $headerfile
	echo "<releaseinfo>$VERSIONSTRING</releaseinfo>"	>> $headerfile
	AUTHORSCONTACT=$(<config/authors awk -F, '{print $1,"(",$2,",",$3,")"}')
	AUTHORS=$(<config/authors awk -F, '{print $1}')
	cat abstract.xml  \
	 sed s/AUTHORSCONTACT/$AUTHORSCONTACT/ \
	 sed s/YEAR/$YEAR/ \
	 sed s/AUTHORS/$AUTHORS/                       		>> $headerfile
	echo "</bookinfo>"                         		>> $headerfile


	# make body

	# make footer
	cat modules/footer/footer.xml >$footerfile

	# build master xml
	cat $headerfile  > $xmlfile
	cat $footerfile >> $xmlfile

	echo
	../static/fop-0.95beta/fop -xml $xmlfile -xsl $xslfile -pdf $pdffile
	if [ $?=0 ]
		then echo; echo pdf generation done.
		else echo; echo error generating pdf.
		fi
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
			book="default"
		fi

	echo "Building '$book' book. Hit return to go or ctrl-c to cancel."
	read me
	build_book $book
	;;

  *)
	help
	;;
	
esac


