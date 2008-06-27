#
# This command generates a docbook-xml for the whole book
#

#
# set variables
#

# Sets the name of the generated file, including date YYYYMMDDhhmmss
bookfilename=book`date +%Y%m%d%H%M%S`.xml

#
# cat all chapters
#


cat header/header.xml > $bookfilename
cat mod_intro_unix/mod_intro_unix.xml >> $bookfilename
cat footer/footer.xml >> $bookfilename


