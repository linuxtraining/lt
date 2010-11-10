#!/bin/sh

command=$1
book=$2

. config/functions.sh

export FOP_OPTS="-Xms512m -Xmx512m"

export BOOKDIR=./config/books

outputdir="./output"
htmldir="$outputdir/html"
htmlimgdir="$htmldir/images"
imgdir="./images"

which xmlto >/dev/null || ( echo xmlto not installed. ; exit 1 )

books=$( ls $BOOKDIR | grep .cfg$ | sed s/.cfg// )

help() {
	echo
	echo "linux-training book build script\t\thttp://www.linux-training.be"
	echo
	echo $0 "clean\t\tdelete output dir"
	echo $0 "build [BOOK]\tbuild book"
    echo $0 "html [BOOK]\tbuild book and generate html"
	echo
	echo Available books: $books
	echo
	}

clean() {
	echo "Cleaning up $outputdir directory"
	# We don't need the .xml files
	rm -rf $outputdir/*.xml 2> /dev/null
	# We don't need the previous errors.txt
	[ -f $outputdir/errors.txt ] && ( rm -rf $outputdir/errors.txt || exit 0 )
	# Symlink creation fails unless we remove this symlink first
	[ -h $outputdir/book.pdf ] && ( rm -rf $outputdir/book.pdf || exit 0 )
    # Clean $htmldir
    [ -d $htmldir ] && ( rm -rf $htmldir/*.xml || exit 0 )

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
	config/buildheader.pl \
		"modules/header/abstract.xml" \
		"config/authors" \
		"config/contributors" \
		"config/reviewers" \
		"$PUBDATE" \
		"$YEAR" \
		"$VERSIONSTRING" \
		"$TEACHER"					>> $headerfile	 
        echo "</bookinfo>"                                      >> $headerfile
	}

build_footer() {
	cat modules/footer/footer.xml >$footerfile
	}

build_body() {
	for chapter in $CHAPTERS; do
		if [ ! -z $DEBUG ] ; then echo -n "Building chapter $chapter .. " ; fi
		modfile=$outputdir/mod_$chapter.xml
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
		modfile=$outputdir/mod_$appendix.xml
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
	[ -d $outputdir ] || mkdir $outputdir

	BOOKTITLE2=$(echo $BOOKTITLE | sed s/\ /\_/g)
	filename=$BOOKTITLE2-$VERSIONSTRING-$DATECODE
	xmlfile=$outputdir/$filename.xml
	pdffile=$outputdir/$filename.pdf
	headerfile=$outputdir/section_header.xml
	footerfile=$outputdir/section_footer.xml
	bodyfile=$outputdir/section_body.xml

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
	else	REDIR=">$outputdir/errors.txt 2>&1"; fi
	eval $(echo ./lib/fop/fop -xml $xmlfile -xsl $XSLFILE -pdf $pdffile $REDIR)
	ln -s $filename.pdf $outputdir/book.pdf
	}

build_html() {
    [ -d $htmldir ] && rm -rf $htmldir || ( echo Error cleaning up $htmmldir ; exit 1 )
    mkdir $htmldir || ( echo Error creating $htmldir ; exit 1 )
    mkdir $htmlimgdir || ( echo Error creating $htmlimgdir ; exit 1 )

    # We only need the one xml file
    cp $xmlfile $htmldir || ( echo error copying $xmlfile ; exit 1 )

    # Locate the used images in the xml file
    images=`grep imagedata $htmldir/*.xml | cut -d/ -f2 | cut -d\" -f1`

    # Copy all the used images
    for img in $images
    do
         echo Copying $img to $htmlimgdir ...
         cp "$imgdir/$img" $htmlimgdir/ || echo Error copying $img
    done

    # Run xmlto in $htmldir to generate the html
    ( cd $htmldir && xmlto html *.xml ) || ( echo  Error generating the html $htmldir ; exit 1 )

    # don't need the xml anymore in the $htmldir
    rm $htmldir/*.xml

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
	echo "Done generating pdf $outputdir/book.pdf -> $pdffile"
	;;
  html)
    clean
    check_book
    echo "Building '$book' book. Set DEBUG=[123] to watch output."
    build_book $book
    echo "Done generating pdf $outputdir/book.pdf -> $pdffile"
    echo "Generating html for '$book' book."
    build_html
    echo "Done Generating html for '$book' book."
    ;;

  *)
	help
	;;
	
esac

echo

