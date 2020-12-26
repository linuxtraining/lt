#!/usr/bin/env bash
######################################################
#created by: Serge
#edited by: Alex M. Schapelle
#purpose: build pdf or html files for linux-training learning material
#version; v1.9.23
#####################################################


### module info ###
# The build environment expects to live in a subdir build/
# It expects to find book information in the parent dir
# ./books/
# ./images/
# ./modules/
# ./build/



### settings ###
L="#####################################"
OUTPUTDIR="./output"
redirfile="$OUTPUTDIR/debug.txt"
HTMLDIR="$OUTPUTDIR/html"
HTMLIMGDIR="$HTMLDIR/images"
IMAGESDIR="./images" 
MODULESDIR="./modules"
BUILDDIR="."
LIBDIR="$BUILDDIR/lib"
export FOP_OPTS="-Xms512m -Xmx512m"
export BOOKSDIR=./books
HTMLXSL="$LIBDIR/html.xsl"
HTMLCSS="$LIBDIR/html.css"
INSTALLER="apt-get"
### script configuration ###

# set this to empty or zero to disable this feature
# this could be moved to a book config
BUNDLE_APPENDICES=1

### initialisation ###

V=""
CHAPTERS=""
APPENDICES=""

DATECODE=$(date +%y%m%d | sed s/^0//)
PUBDATE=$(date +'%Y-%m-%d')
YEAR=$(date +%Y)

### functions ###

help() {
	clear
	deco "Linux-Training book build script:  http://linux-training.be
	$0 [OPTION] command [book] 
	 Options
	  -d 0,1,2,3,4		Set debug level, 1 is default
						0	No output
						1	Standard output
						2	Verbose output
						3	Extra verbose output
						4	Debug output
	  -h			Help
	
	 Commands
	  clean			clean output dir
	  build [BOOK]		build book
	  html [BOOK]		generate html
	"
	 deco "Available books: ${superbooks[*]}"     
	 deco "Minibooks: ${minibooks[*]}"
	
	}

set_xsl() {
	if	[[ -r $BOOKSDIR/$book/lt.xsl ]];then
		XSLFILE="$BOOKSDIR/$book/lt.xsl"
	else	
		XSLFILE="$LIBDIR/lt.xsl"
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

clean() {
	echo "Cleaning up $OUTPUTDIR directory"
	# We don't need the .xml files
	rm -rf $V $OUTPUTDIR/*.xml
	# We don't need the previous errors.txt
	[[ -f $redirfile ]] && rm -rf $V $redirfile
	# Symlink creation fails unless we remove this symlink first
	[[ -h $OUTPUTDIR/book.pdf ]] && rm -rf $V $OUTPUTDIR/book.pdf
	# Clean $HTMLDIR
	[[ -d $HTMLDIR ]] && rm -rf $V $HTMLDIR/*.xml
	}

check_book() {
	if [[ ! -z $book ]];then 	# check if $book parameter is one of the available books
			echo -n "Checking if $book.cfg exists in ./books directory ... "
			check=0
			for entry in ${books[@]} 
				do
					if [[ $entry == ${book[@]} ]];then
						check=1
					fi
				done

			if [[ $check -eq 1 ]];then
				deco "Selected book $book"
			else
				deco "$book is not available"; exit
			fi
		else
			deco "No book specified, assuming default book"
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
		"$TEACHER"			                            		>> $headerfile	 
        echo "</bookinfo>"                                      >> $headerfile
	}

build_footer() {
	cat modules/footer/footer.xml >$footerfile
	}

build_part_body() {

    for modtype in CHAPTERS APPENDICES
    do
        echod Building $modtype ..
        for mod in ${!modtype}
        do
            echod -n "Building module $mod "
            modfile=$OUTPUTDIR/mod_$mod.xml

            # enumerate module files for this module $mod
	    if [[ -d modules/$mod ]];then	
			MODULES=$(ls modules/${mod}/*)
 	    else	
		 	echo "Error: module $mod does not exist!" 
			echor "Fatal error occurred!"
			exit 1
	    fi
            echo $MODULES

            # Generate the start chapter/appendix tag
            case $modtype in
                CHAPTERS)
                    echo "<chapter>"      > $modfile
                    ;;
                APPENDICES)
        		    echo "<appendix>" 	 > $modfile
                    ;;
            esac
            # Generate all the sections
            for module in $MODULES
            do
                echod -n "\t.. adding module $module"
                cat $module                                 >> $modfile
            done
            echod

            # Generate the end chapter tag
            case $modtype in
                CHAPTERS)
                    echo "</chapter>"                               >> $modfile
                    ;;
                APPENDICES)
                    echo "</appendix>"                               >> $modfile
                    ;;
            esac

            # add the module to the body
            cat $modfile >> $partfile

        done
    done

}

fill_part() {
	echo "<part>"       			>>$bodyfile
	# Here we use the BOOKTITLE as a title for the PART
	echo "<title>$BOOKTITLE</title>"        >>$bodyfile
	cat $1              			>>$bodyfile
	echo "</part>"      			>>$bodyfile

}

build_part() {
    PART=$1

    # empty the partfile and reset the variables
    >$partfile
    CHAPTERS=""
    APPENDICES=""

    if [[ "$PART" = "CUSTOMPART" ]];then    # just build the part body using the chapters and apendices from the main book config
	    if [[ "$BUNDLE_APPENDICES" = 1 ]];then
			echod "restore the bundled appendices: ${APPENDICES_BUNDLE}"
			APPENDICES=${APPENDICES_BUNDLE}
	    fi
            . $BOOKSDIR/$book/config
            build_part_body
    else    # first read in the config of this part minibook
            . $BOOKSDIR/$PART/config
	    if [[ "$BUNDLE_APPENDICES" == 1 ]]; then	# move content of APPENDICES var to be used later in the custompart
			APPENDICES_BUNDLE=${APPENDICES_BUNDLE}${APPENDICES}
			APPENDICES=""
	    fi
            # then build that part body
            build_part_body
    fi
    }

build_body() {
    # first build minibooks, each minibook is a "<part>"
    # then chapters, then appendices "which each are "<chapter>
    # if we have both minibooks and separate chapters+appendices, then build the latter set as a custom minibook in a separate <part>
    # if we have no minibooks, then no need for "<part>"

    if [[ -z "$MINIBOOKS" ]];then    # no minibooks
            HAZ_MINIBOOKS=0
    else    # build minibooks
            HAZ_MINIBOOKS=1
            for minibook in $MINIBOOKS
            	do  
					echod "[+] Assembling the part for minibook $minibook"
					build_part $minibook
                	fill_part $partfile
            	done
    fi

    if [[ -z "$CHAPTERS $APPENDICES" ]];then    # no custom part
            HAZ_CUSTOMPART=0
    else    # simple custom book or custom part
            HAZ_CUSTOMPART=1
	    		# just build the custom book
	    	echod "[+] Assembling the custom part or simple book."
            build_part CUSTOMPART
	    if [[ $HAZ_MINIBOOKS = 0 ]];then	# just use partfile as bookbody
            		cat $partfile   >>$bodyfile
	    else	# add custom part as extra part
			# set booktitle for custompart
			if [[ $(echo $CHAPTERS $APPENDICES | wc -w ) -gt 1 ]];then	
					BOOKTITLE="Appendices"
			else	
					BOOKTITLE="Appendix"
			fi
			echod "[+] Adding the custom part at the end."
			fill_part $partfile
	    fi
    fi
    }

build_xml() {
	echo -ne "[:] Parsing config $BOOKSDIR/$book/config ... "
	CHAPTERS=""
	APPENDICES=""
	. $BOOKSDIR/$book/config
	. $BOOKSDIR/$book/version

	echod "This book contains:"
	echod "MINIBOOKS = $MINIBOOKS"
	echod "CHAPTERS = $CHAPTERS"
	echod "APPENDICES = $APPENDICES"

	VERSIONSTRING=lt-$MAJOR.$MINOR

	echo "generating book $book (titled \"$BOOKTITLE\")"
	[[ -d $OUTPUTDIR ]] || mkdir $OUTPUTDIR

	BOOKTITLE2=$(echo $BOOKTITLE | sed -e 's/\ /\_/g' -e 's@/@-@g' )
	filename=$BOOKTITLE2-$VERSIONSTRING-$DATECODE
	xmlfile=$OUTPUTDIR/$filename.xml
	tmp_xmlfile=$OUTPUTDIR/$filename.tmp.xml
	pdffile=$OUTPUTDIR/$filename.pdf
	headerfile=$OUTPUTDIR/section_header.xml
	footerfile=$OUTPUTDIR/section_footer.xml
	bodyfile=$OUTPUTDIR/section_body.xml
	partfile=$OUTPUTDIR/part.xml
	partcustomfile=$OUTPUTDIR/partcustom.xml

	# make header
	build_header

	# make footer
	build_footer

	# make body
	build_body

	# build master xml
	echo "[+] Building $xmlfile"
	cat $headerfile  > $xmlfile
	cat $bodyfile   >> $xmlfile
	cat $footerfile >> $xmlfile
	}

build_pdf() {
	set_xsl
	set_JAVA
	echo 
	echo "---------------------------------"
	echo "Generating $pdffile"
	tail -n +2 $xmlfile > $tmp_xmlfile
	eval $(echo fop -xml $tmp_xmlfile -xsl $XSLFILE -pdf $pdffile ) >&2
	#eval $(echo fop -xml $tmp_xmlfile -xsl $XSLFILE -pdf $pdffile $EXECDEBUG) >&2 #there is an issue with EXECDEBUG param
	#fop -xml $tmp_xmlfile -xsl $XSLFILE -pdf $pdffile 
	ln -s $V $filename.xml $OUTPUTDIR/book.pdf
	echo "---------------------------------"
	}

build_html() {
    [[ -d $HTMLDIR ]] && rm -rf $V $HTMLDIR
    mkdir $V $HTMLDIR || ( echor Error creating $HTMLDIR; exit 1 )
    mkdir $V $HTMLIMGDIR || ( echor Error creating $HTMLIMGDIR; exit 1 )

    # We only need the one xml file
    cp $V $xmlfile $HTMLDIR || ( echor error copying $xmlfile ; exit 1 )

    # Locate the used images in the xml file
    images=$(grep imagedata $HTMLDIR/*.xml | cut -d/ -f2 | cut -d\" -f1)

    # Copy all the used images
    for img in $images
    do
         echo Copying $img to $HTMLIMGDIR ...
         cp $V "$IMAGESDIR/$img" $HTMLIMGDIR/ || echor Error copying $img 
    done

    # Copy css file to html directory
    cp $HTMLCSS $HTMLDIR
    # Run xmlto in $HTMLDIR to generate the html
    echo "Converting xml to html ..."
    ( cd $HTMLDIR && xmlto html *.xml --skip-validation -m ../../$HTMLXSL 2>&1 | grep -v "Writing" ) || ( echor  Error generating the html $HTMLDIR ; exit 1 )

    # don't need the xml anymore in the $HTMLDIR
    rm $HTMLDIR/*.xml

}

deco(){
	
    printf "$L\n# %s\n$L\n" "$@"
    sleep 0.5
}


try_fix(){
	echod "Trying to install dependencies"
	sudo $INSTALLER install -y ${tool[@]}
}


check_os_type(){
   local _os=$(cat /etc/*-release|grep '^ID='|awk -F= '{print$2}')
    if [[ "${_os,,}" == 'debian' ]] || [[ "${_os,,}" == 'ubuntu' ]] || [[ "${_os,,}" == 'linuxmint' ]];then 
        true
    else  
        deco "OS not Supported"
        exit 1 
    fi
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

cmd=$1
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

books=($( cd $BOOKSDIR ; find * -maxdepth 1 -type d))
superbooks=($( cd $BOOKSDIR ; find * -maxdepth 1 -type d | grep -v minibook ))
minibooks=($( cd $BOOKSDIR ; find * -maxdepth 1 -type d | grep minibook))

mkdir -p $OUTPUTDIR

# Redirect everything according to REDIR var from now on.
#eval "exec $REDIR"

# Main loop
case "$cmd" in
  clean)
	clean
	;;
  build)
	check_os_type
	clean
	[[ -x "$(which fop)" ]] || echor "fop not installed." || exit 1
	check_book
	deco "Building '$book' book."
	build_xml
	deco "Generating pdf for '$book' book."
	build_pdf
	deco "Done generating pdf $OUTPUTDIR/book.pdf -> $pdffile" 
	;;
  html)
	[[ -x "$(which xmlto)" ]] || echor "xmlto not installed."|| exit 1
	clean 
	check_book
	deco "Building '$book' book."
	build_xml
	deco "Generating html for '$book' book."
	build_html
 	deco "Done Generating html for '$book' book."
	;;
  *)
	help
	;;
	
esac