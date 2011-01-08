#!/bin/sh

outputdir="./output"
htmldir="$outputdir/html"
htmlimgdir="$htmldir/images"
imgdir="./images"

. config/functions.sh

DEBUG=""

export FOP_OPTS="-Xms512m -Xmx512m"
export BOOKDIR=./config/books

books=$( ls $BOOKDIR | grep .cfg$ | sed s/.cfg// )

help() {
	echo
	echo "linux-training book build script\t\thttp://linux-training.be"
	echo
	echo $0 [OPTION] command [book]
	echo 
	echo "Options"
	echo "  -d 0,1,2,3		Set debug level, 1 is default"
	echo "					0	No output"
	echo "					1	Error output"
	echo "					2	Normal output"
	echo "					3	PDF generation debug output"
	echo "  -h			Help"
	echo
	echo "Commands"
	echo "  clean			delete output dir"
	echo "  build [BOOK]		build book"
	echo "  html [BOOK]		build book and generate html"
	echo
	echo "Available books:" $books
	echo
	}

clean() {
	[ ! -z $DEBUG ] && echo "Cleaning up $outputdir directory"
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
			[ ! -z $DEBUG ] && echo -n "Checking if $book.cfg exists in ./books directory ... "
			check=0
			for entry in $books ; do
				if [ $entry = $book ]
					then check=1
				fi
			done
			if [ $check = 1 ]
				then [ ! -z $DEBUG ] && echo OKOKOKOK
				else echo "$book is not available"; exit
			fi
		else
			[ ! -z $DEBUG ] && echo "No book specified, assuming default book"
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
	[ ! -z $DEBUG ] && echo -n "Parsing config $BOOKDIR/$book.cfg ... "
	. $BOOKDIR/$book.cfg 

    	# Major and minor are set in functions.sh but can be overruled in $book.cfg
    	VERSIONSTRING=lt-$MAJOR.$MINOR

	[ ! -z $DEBUG ] && echo "Generating book $book (titled \"$BOOKTITLE\")"
	[ -d $outputdir ] || mkdir $outputdir

	BOOKTITLE2=$(echo $BOOKTITLE | sed -e 's/\ /\_/g' -e 's@/@-@g' )
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
	[ ! -z $DEBUG ] && echo "Building $xmlfile"
	cat $headerfile  > $xmlfile
	cat $bodyfile   >> $xmlfile
	cat $footerfile >> $xmlfile

	[ ! -z $DEBUG ] && echo "Generating $pdffile"
	eval $(echo ./lib/fop/fop -xml $xmlfile -xsl $XSLFILE -pdf $pdffile $EXECDEBUG $REDIR)
	ln -s $filename.pdf $outputdir/book.pdf
	}

build_html() {
    [ -d $htmldir ] && rm -rf $htmldir
    mkdir $htmldir || ( echo Error creating $htmldir >&22; exit 1 )
    mkdir $htmlimgdir || ( echo Error creating $htmlimgdir >&2 ; exit 1 )

    # We only need the one xml file
    cp $xmlfile $htmldir || ( echo error copying $xmlfile >&2 ; exit 1 )

    # Locate the used images in the xml file
    images=`grep imagedata $htmldir/*.xml | cut -d/ -f2 | cut -d\" -f1`

    # Copy all the used images
    for img in $images
    do
         [ ! -z $DEBUG ] && echo Copying $img to $htmlimgdir ...
         cp "$imgdir/$img" $htmlimgdir/ || echo Error copying $img >2&
    done

    # Run xmlto in $htmldir to generate the html
    ( cd $htmldir && xmlto html *.xml 2>&1 | grep -v "Writing" ) || ( echo  Error generating the html $htmldir >&2 ; exit 1 )

    # don't need the xml anymore in the $htmldir
    rm $htmldir/*.xml

}

while getopts "d: h" option
do
	case $option in
		d ) 	OPTDEBUG=$OPTARG
			shift 2
			;;
		h ) 	help
			shift 1
			exit 0
			;;
        esac
done

command=$1
book=$2

case $OPTDEBUG in
	0)	# DEBUG 0 is zero output (except help message)
		REDIR=">$outputdir/debug.txt 2>&1"
		DEBUG=""
		;;
	"",1)	# DEBUG 1 is default, only STDERR
		REDIR=">$outputdir/debugs.txt 2>&1"
		DEBUG=""
		;;
	2)	# DEBUG 2 is all output we get normally
		REDIR=""
		DEBUG="y"
		;;
	3)	# DEBUG 4 is all output we get normally + fop exec debug on 
		REDIR=""
		EXECDEBUG="--execdebug"
		DEBUG="y"
		;;
	*)	help
		exit 0
		;;
esac

##############

set_ROOTDIR || ( echo "It does not look like I'm in the project root dir?">&2; exit 1 )

case "$command" in
  clean)
	clean
	;;
  build)
	clean
	check_book
	[ ! -z $DEBUG ] && echo "Building '$book' book. Set DEBUG=[123] to watch output."
	build_book $book
	[ ! -z $DEBUG ] && echo "Done generating pdf $outputdir/book.pdf -> $pdffile" 
	;;
  html)
	if which xmlto >/dev/null 
	then 	true
	else	echo xmlto not installed. >&2 
		exit 1
	fi
	clean
	check_book
	[ ! -z $DEBUG ] && echo "Building '$book' book. Set DEBUG=[123] to watch output."
	build_book $book
	[ ! -z $DEBUG ] && echo "Done generating pdf $outputdir/book.pdf -> $pdffile"
	[ ! -z $DEBUG ] && echo "Generating html for '$book' book."
	build_html
 	[ ! -z $DEBUG ] && echo "Done Generating html for '$book' book."
	;;
  *)
	help
	;;
	
esac

