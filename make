#!/bin/sh

### module info ###
# The build environment expects to live in a subdir build/
# It expects to find book information in the parent dir
# ./books/
# ./images/
# ./modules/
# ./build/

### settings ###

OUTPUTDIR="./output"
redirfile="$OUTPUTDIR/debug.txt"
HTMLDIR="$OUTPUTDIR/html"
HTMLIMGDIR="$HTMLDIR/images"
IMAGESDIR="./images" 
MODULESDIR="./modules"
BUILDDIR="./build"
LIBDIR="$BUILDDIR/lib"
XSLFILE="$LIBDIR/lt.xsl"
FOPDIR="$LIBDIR/fop"
export FOP_OPTS="-Xms512m -Xmx512m"
export BOOKSDIR=./books

### initialization ###

V=""
CHAPTERS=""
APPENDIX=""

DATECODE=$(date +%y%m%d | sed s/^0//)
PUBDATE=$(date +%c)
YEAR=$(date +%Y)
books=$( cd $BOOKSDIR ; find * -maxdepth 1 -type d )

### functions ###

help() {
	echo
	echo "linux-training book build script\t\thttp://linux-training.be"
	echo
	echo $0 [OPTION] command [book]
	echo 
	echo "Options"
	echo "  -d 0,1,2,3,4		Set debug level, 1 is default"
	echo "					0	No output"
	echo "					1	Standard output"
	echo "					2	Verbose output"
	echo "					3	Extra verbose output"
	echo "					4	Debug output"
	echo "  -h			Help"
	echo
	echo "Commands"
	echo "  clean			clean output dir"
	echo "  build [BOOK]		build book"
	echo "  html [BOOK]		generate html"
	echo
	echo "Available books:" $books
	echo
	}

set_JAVA() {
	# use the correct java runtime for fop on Ubuntu
	# according to http://linuxmafia.com/faq/Admin/release-files.html
	if [ -f /etc/lsb-release ]
	then    #Ubuntu
	        export JAVA_HOME=/usr/lib/jvm/java-6-sun/jre
	elif [ -f /etc/debian_version ]
	then    # use the correct java runtime for fop on Debian Lenny
	        export JAVA_HOME=/usr/lib/jvm/default-java/jre
	else    echor Could not set JAVA_HOME, something unexpected happened in $0
	fi
	}

check_ROOTDIR() {

	if	[ -x make.sh -a -x buildheader.pl ]
	then	echor "We are in the build directory, changing to parent directory."
		cd ..
	fi
	if	[ -d $BOOKSDIR -a -d $BOOKSDIR -a -d $MODULESDIR -a -d $BUILDDIR ]
	then	echor "Current dir is book project root directory."
	else	echor "Please run this script from the book root directory."
		return 1
	fi

        }

add_mod() {
        MODULES=${MODULES}" "$MODULESDIR/$1
        }

add_chapt() {
        CHAPTERS=${CHAPTERS}" "$1
        }

add_appen() {
        APPENDIX=${APPENDIX}" "$1
        }

echor() {	# echo error
	echo $* >&2
	}

echod() {	# echo debug
	[ $OPTDEBUG -ge 2 ] && echo $* 
	}

clean() {
	echo "Cleaning up $OUTPUTDIR directory"
	# We don't need the .xml files
	rm -rf $V $OUTPUTDIR/*.xml
	# We don't need the previous errors.txt
	[ -f $redirfile ] && rm -rf $V $redirfile
	# Symlink creation fails unless we remove this symlink first
	[ -h $OUTPUTDIR/book.pdf ] && rm -rf $V $OUTPUTDIR/book.pdf
	# Clean $HTMLDIR
	[ -d $HTMLDIR ] && rm -rf $V $HTMLDIR/*.xml
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
				then echo "Selected book $book"
				else echo "$book is not available"; exit
			fi
		else
			echo "No book specified, assuming default book"
			book="default"
		fi
	}

build_header() {
	cat modules/header/doctype.xml | sed s@LIBDIR@../$LIBDIR@g	> $headerfile
        echo "<book>"                                           >> $headerfile
        echo "<bookinfo>"                                       >> $headerfile
        echo "<title>$BOOKTITLE</title>"                        >> $headerfile
	$BUILDDIR/buildheader.pl \
		"modules/header/abstract.xml" \
		"$BOOKSDIR/$book/copyrights" \
		"$BOOKSDIR/$book/authors" \
		"$BOOKSDIR/$book/contributors" \
		"$BOOKSDIR/$book/reviewers" \
		"$PUBDATE" \
		"$YEAR" \
		"$VERSIONSTRING" \
		"$TEACHER"			                            		>> $headerfile	 
        echo "</bookinfo>"                                      >> $headerfile
	}

build_footer() {
	cat modules/footer/footer.xml >$footerfile
	}

build_body() {
	for chapter in $CHAPTERS; do
		echod -n "Building chapter $chapter " 
		modfile=$OUTPUTDIR/mod_$chapter.xml
		# load the chapter specific settings
		echod -n "\t.. loading settings chapt_$chapter" 
		eval chapt_$chapter
		# Generate the end chapter tag
		echo "<chapter><title>"$chaptitle"</title>" 	 > $modfile
		# Generate all the sections
		for module in $MODULES
		do
			echod -n "\t.. adding module $module" 
			cat $module 				>> $modfile
		done
		echod
		# Generate the end chapter tag
		echo "</chapter>"      				>> $modfile
		cat $modfile					>> $bodyfile
	done
	for appendix in $APPENDIX; do
		echod -n "Building appendix $appendix .. " 
		modfile=$OUTPUTDIR/mod_$appendix.xml
		# load the chapter specific settings
		echod " .. loading settings chapt_$appendix"
		eval chapt_$appendix
		# Generate the end chapter tag
		echo "<appendix><title>"$chaptitle"</title>" 	 > $modfile
		# Generate all the sections
		for module in $MODULES; do
			echod "     adding module $module"
			cat $module 				>> $modfile
			done
		# Generate the end chapter tag
		echo "</appendix>"     				>> $modfile
		cat $modfile					>> $bodyfile
	done
	}

build_xml() {
	echo -n "Parsing config $BOOKSDIR/$book/config ... "
	. $BOOKSDIR/$book/config
	. $BOOKSDIR/$book/version

    VERSIONSTRING=lt-$MAJOR.$MINOR

	echo "Generating book $book (titled \"$BOOKTITLE\")"
	[ -d $OUTPUTDIR ] || mkdir $OUTPUTDIR

	BOOKTITLE2=$(echo $BOOKTITLE | sed -e 's/\ /\_/g' -e 's@/@-@g' )
	filename=$BOOKTITLE2-$VERSIONSTRING-$DATECODE
	xmlfile=$OUTPUTDIR/$filename.xml
	pdffile=$OUTPUTDIR/$filename.pdf
	headerfile=$OUTPUTDIR/section_header.xml
	footerfile=$OUTPUTDIR/section_footer.xml
	bodyfile=$OUTPUTDIR/section_body.xml

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
	}

build_book() {
	set_JAVA
	echo 
	echo "---------------------------------"
	echo "Generating $pdffile"
	eval $(echo $FOPDIR/fop -xml $xmlfile -xsl $XSLFILE -pdf $pdffile $EXECDEBUG) >&2
	ln -s $V $filename.pdf $OUTPUTDIR/book.pdf
	echo "---------------------------------"
	}

build_html() {
    [ -d $HTMLDIR ] && rm -rf $V $HTMLDIR
    mkdir $HTMLDIR || ( echor Error creating $HTMLDIR; exit 1 )
    mkdir $HTMLIMGDIR || ( echor Error creating $HTMLIMGDIR; exit 1 )

    # We only need the one xml file
    cp $xmlfile $HTMLDIR || ( echor error copying $xmlfile ; exit 1 )

    # Locate the used images in the xml file
    images=`grep imagedata $HTMLDIR/*.xml | cut -d/ -f2 | cut -d\" -f1`

    # Copy all the used images
    for img in $images
    do
         echo Copying $img to $HTMLIMGDIR ...
         cp $V "$imgdir/$img" $HTMLIMGDIR/ || echor Error copying $img 
    done

    # Run xmlto in $HTMLDIR to generate the html
    echo "Converting xml to html ..."
    ( cd $HTMLDIR && xmlto html *.xml 2>&1 | grep -v "Writing" ) || ( echor  Error generating the html $HTMLDIR ; exit 1 )

    # don't need the xml anymore in the $HTMLDIR
    rm $HTMLDIR/*.xml

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

check_ROOTDIR || ( echo "It does not look like I'm in the project root dir?" $REDIR; exit 1 )

# Redirect everything according to REDIR var from now on.
mkdir -p $OUTPUTDIR
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
	build_book
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

