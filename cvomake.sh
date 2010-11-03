#!/bin/sh

command=$1
book=$2

. config/functions.sh
VERSIONSTRING=lt-$MAJOR.$MINOR

export FOP_OPTS="-Xms512m -Xmx512m"

export BOOKDIR=./config/books

books=$( ls $BOOKDIR | grep .cfg$ | sed s/.cfg// )

help() {
	echo
	echo "linux-training book build script\t\thttp://www.linux-training.be"
	echo
	echo $0 "clean\t\tdelete output dir"
	echo $0 "build [BOOK]\tbuild book"
	echo
	echo Available books: $books
	echo
	}

clean() {
	# echo "Removing ./output/ directory"
	# [ -d output ] && ( rm -rf output || exit 0 )

	echo "Cleaning up ./output/ directory"
	# We don't need the .xml files
	rm -rf ./output/*.xml 2> /dev/null
	# We don't need the previous errors.txt
	[ -f output/errors.txt ] && ( rm -rf output/errors.txt || exit 0 )
	# Symlink creation fails unless we remove this symlink first
	[ -h output/book.pdf ] && ( rm -rf output/book.pdf || exit 0 )

	# let's also purge the old static dir, which contents were moved to lib and put under source control
	[ -d static ] && ( rm -rf static || exit 0 )
	}

check_book() {
	if [ ! -z $book ]
		then 	# check if $book parameter is one of the available books
			echo -n "Checking if $book.cfg exists in ./books directory ... "
			check=0
			for entry in $books ; do
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
	}

build_header() {
	cat modules/header/doctype.xml                           > $headerfile
        echo "<book>"                                           >> $headerfile
        echo "<bookinfo>"                                       >> $headerfile
        echo "<title>$BOOKTITLE</title>"                        >> $headerfile
	echo "<author><firstname>Paul</firstname><surname>Cobbaut</surname></author>" >>$headerfile
	echo "<pubdate>26 oktober 2010</pubdate><abstract>" 		>> $headerfile
	echo '<para>Deze cursus wordt gemaakt als leidraad voor de studenten die de module "Datacommunicatie en Netwerken" volgen aan het cvotsm in Mechelen. </para>' 		>> $headerfile
	echo "<para>Deze cursus wordt op vrijwillige basis gemaakt, en bevat misschien niet de volledige leerstof. Vergeet dus niet te noteren tijdens de les.</para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para></para>" 	>> $headerfile
	echo "<para>Copyright 2007-2011 Paul Cobbaut</para>" 	>> $headerfile
	echo "<para>Permission is granted to copy, distribute and/or modify this document under the terms of the <command>GNU Free Documentation License</command>, Version 1.3 or any later version published by the Free Software Foundation; with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts. A copy of the license is included in the section entitled 'GNU Free Documentation License'.</para>" >> $headerfile
	echo "<para>paul.cobbaut@gmail.com</para>" 	>> $headerfile
	echo "<para>paulc@cvotsm-leren.be</para>" 	>> $headerfile
        echo "</abstract></bookinfo>"                   >> $headerfile
	}

build_footer() {
	cat modules/footer/footer.xml >$footerfile
	}

build_body() {
	for chapter in $CHAPTERS; do
		if [ ! -z $DEBUG ] ; then echo -n "Building chapter $chapter .. " ; fi
		modfile=output/mod_$chapter.xml
		# load the chapter specific settings
		if [ ! -z $DEBUG ] ; then echo " .. loading settings chapt_$chapter" ; fi
		eval chapt_$chapter
		# Generate the end chapter tag
		echo "<chapter><title>"$chaptitle"</title>" 	 > $modfile
		# Generate all the sections
		for module in $MODULES; do
			if [ ! -z $DEBUG ] ; then echo "     adding module $module" ; fi
			cat $module 				>> $modfile
			done
		# Generate the end chapter tag
		echo "</chapter>"      				>> $modfile
		cat $modfile					>> $bodyfile
	done
	for appendix in $APPENDIX; do
		if [ ! -z $DEBUG ] ; then echo -n "Building appendix $appendix .. " ; fi
		modfile=output/mod_$appendix.xml
		# load the chapter specific settings
		if [ ! -z $DEBUG ] ; then echo " .. loading settings chapt_$appendix" ; fi
		eval chapt_$appendix
		# Generate the end chapter tag
		echo "<appendix><title>"$chaptitle"</title>" 	 > $modfile
		# Generate all the sections
		for module in $MODULES; do
			if [ ! -z $DEBUG ] ; then echo "     adding module $module" ; fi
			cat $module 				>> $modfile
			done
		# Generate the end chapter tag
		echo "</appendix>"     				>> $modfile
		cat $modfile					>> $bodyfile
	done
	}

build_book() {
	echo -n "Parsing config $BOOKDIR/$book.cfg ... "
	. $BOOKDIR/$book.cfg && echo "OK" || ( echo "Error!" ; exit )

    # Major and minor are set in functions.sh but can be overruled in $book.cfg
    VERSIONSTRING=lt-$MAJOR.$MINOR

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
	if [ -z $DEBUG ] ; then DEBUG="0"; fi
	if 	[ $DEBUG = "2" ]; then REDIR=""
	elif 	[ $DEBUG = "3" ]; then REDIR="--execdebug"
	else	REDIR=">./output/errors.txt 2>&1"; fi
	eval $(echo ./lib/fop/fop -xml $xmlfile -xsl $XSLFILE -pdf $pdffile $REDIR)
	ln -s $filename.pdf output/book.pdf
	}

##############

echo
set_ROOTDIR || ( echo "It does not look like I'm in the project root dir?"; exit)

case "$command" in
  clean)
	clean
	;;
  build)
	clean
	check_book
	echo "Building '$book' book. Set DEBUG=[123] to watch output."
	build_book $book
	echo "Done generating pdf output/book.pdf -> $pdffile"
	;;

  *)
	help
	;;
	
esac
