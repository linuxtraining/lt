#!/bin/sh

command=$1
book=$2

. config/functions.sh

books=$( ls books | grep .cfg$ | sed s/.cfg// )

help() {
	echo
	echo "linux-training book build script\t\thttp://linux-training.be"
	echo
	echo $0 "check\t\tcheck some settings"
	echo $0 "clean\t\tdelete output dir"
	echo $0 "install\tdownload static build environment to ../static"
	echo $0 "build [BOOK]\tbuild book"
	echo
	echo Available books: $books
	echo
	}

clean() {
	echo "Removing ./output/ directory"
	[ -d output ] && ( rm -rf output || exit 0 )
	}

check() {
	if [ -z $REVISION ] ; then get_revision ; fi
	VERSIONSTRING=lt-$MAJOR.$MINOR.$REVISION
	echo "Subversion repository:\t$SVN_PROJECTDIR"
	echo "Current version:\t$VERSIONSTRING"
	}

build_header() {
	cat modules/header/doctype.xml                           > $headerfile
        echo "<book>"                                           >> $headerfile
        echo "<bookinfo>"                                       >> $headerfile
        echo "<title>$BOOKTITLE</title>"                        >> $headerfile
	config/buildheader.pl \
		"modules/header/abstract.xml" \
		"config/authors" \
		"$PUBDATE" \
		"$YEAR" \
		"$VERSIONSTRING"					>> $headerfile	 
        echo "</bookinfo>"                                      >> $headerfile
	}

build_footer() {
	cat modules/footer/footer.xml >$footerfile
	}

build_body() {
	for chapter in $CHAPTERS; do
		modfile=output/mod_$chapter.xml
		# load the chapter specific settings
		eval chapt_$chapter
		# Generate the end chapter tag
		echo "<chapter><title>"$chaptitle"</title>" 	 > $modfile
		# Generate all the sections
		for module in $MODULES; do
			cat $module 				>> $modfile
			done
		# Generate the end chapter tag
		echo "</chapter>"      				>> $modfile
		cat $modfile					>> $bodyfile
	done
	}

build_book() {
	echo -n "Parsing config books/$book.cfg ... "
	. books/$book.cfg && echo "OK" || ( echo "Error!" ; exit )

	echo "Generating book $book (titled \"$BOOKTITLE\")"
	[ -d ./output ] || mkdir ./output

	BOOKTITLE2=$(echo $BOOKTITLE | sed s/\ /\_/g)
	filename=$BOOKTITLE2-$VERSIONSTRING-$DATECODE
	xmlfile=output/$filename.xml
	pdffile=output/$filename.pdf
	headerfile=output/section_header.xml
	footerfile=output/section_footer.xml
	bodyfile=output/section_body.xml

	# make header
	build_header

	# make body
	build_body

	# make footer
	build_footer

	# build master xml
	echo "Building $xmlfile"
	cat $headerfile  > $xmlfile
	cat $bodyfile   >> $xmlfile
	cat $footerfile >> $xmlfile

	echo "Generating $pdffile"
	../static/fop-0.95beta/fop -xml $xmlfile -xsl $XSLFILE -pdf $pdffile #--execdebug
	if [ $?=0 ]
		then echo; echo pdf generation done.
		else echo; echo error generating pdf.
		fi
	}

##############

echo
set_ROOTDIR || ( echo "It does not look like I'm in the project root dir?"; exit)

case "$command" in
  check)
	check
	;;
  clean)
	clean
	;;

  install)
	README/install_environment.cmd 
	;;
  build)
	check
	clean
	if [ ! -z $book ]
		then 	# check if $book parameter is one of the available books
			echo -n "Checking if $book.cfg exists in ./books directory ... "
			check=0
			for entry in $books ; do
				echo books = $books
				echo entry = $entry
				if [ $entry = $book ]
					then check=1
				fi
			done
			if [ $check = 1 ]
				then echo OK
				else echo "$book is not available"; exit
			fi
		else
			echo "No book specified, assuming default book"
			book="default"
		fi

	echo "Building '$book' book. Hit return to go or ctrl-c to cancel."
	build_book $book
	;;

  *)
	help
	;;
	
esac


