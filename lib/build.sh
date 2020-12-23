#!/usr/bin/env bash 
#set -e

dot="$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P)"

help() {

	echo
	echo -e "linux-training book build script\t\thttp://linux-training.be"
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
	echo "Available books:" $superbooks
	echo "      minibooks:" $minibooks
	echo
	sleep 2
	}

clean_dir() {
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
	    if [ -d modules/$mod ]
	    then	MODULES=$(ls modules/${mod}/*)
 	    else	echo "Error: module $mod does not exist!" 
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
                echod -e "\t.. adding module $module"
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

    if [ "$PART" = "CUSTOMPART" ]
    then    # just build the part body using the chapters and apendices from the main book config
	    if [ "$BUNDLE_APPENDICES" = 1 ]
	    then	echod "restore the bundled appendices: ${APPENDICES_BUNDLE}"
			APPENDICES=${APPENDICES_BUNDLE}
	    fi
            . $BOOKSDIR/$book/config
            build_part_body
    else    # first read in the config of this part minibook
            . $BOOKSDIR/$PART/config
	    if [ "$BUNDLE_APPENDICES" = 1 ]
	    then	# move content of APPENDICES var to be used later in the custompart
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

    if [ -z "$MINIBOOKS" ]
    then    # no minibooks
            HAZ_MINIBOOKS=0
    else    # build minibooks
            HAZ_MINIBOOKS=1
            for minibook in $MINIBOOKS
            do  echod "Assembling the part for minibook $minibook"
		build_part $minibook
                fill_part $partfile
            done
    fi

    if [ -z "$CHAPTERS $APPENDICES" ]
    then    # no custom part
            HAZ_CUSTOMPART=0
    else    # simple custom book or custom part
            HAZ_CUSTOMPART=1
	    # just build the custom book
	    echod "Assembling the custom part or simple book."
            build_part CUSTOMPART
	    if [ $HAZ_MINIBOOKS = 0 ]
	    then	# just use partfile as bookbody
            		cat $partfile   >>$bodyfile
	    else	# add custom part as extra part
			# set booktitle for custompart
			if [ $(echo $CHAPTERS $APPENDICES | wc -w ) -gt 1 ]
			then	BOOKTITLE="Appendices"
			else	BOOKTITLE="Appendix"
			fi
			echod "Adding the custom part at the end."
			fill_part $partfile
	    fi
    fi
    }

build_xml() {
	echo -n "Parsing config $BOOKSDIR/$book/config ... "
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
	[ -d $OUTPUTDIR ] || mkdir $OUTPUTDIR

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
	echo "Building $xmlfile"
	cat $headerfile  > $xmlfile
	cat $bodyfile   >> $xmlfile
	cat $footerfile >> $xmlfile
	}

build_pdf() {
	#set -x
	validate_dependencies
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
	#set +x
	echo "---------------------------------"
	}

build_html() {
    [[ -d $HTMLDIR ]] && rm -rf $V $HTMLDIR
    mkdir $V $HTMLDIR || ( echor Error creating $HTMLDIR; exit 1 )
    mkdir $V $HTMLIMGDIR || ( echor Error creating $HTMLIMGDIR; exit 1 )

    # We only need the one xml file
    cp $V $xmlfile $HTMLDIR || ( echor error copying $xmlfile ; exit 1 )

    # Locate the used images in the xml file
    images=`grep imagedata $HTMLDIR/*.xml | cut -d/ -f2 | cut -d\" -f1`

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