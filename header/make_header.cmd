#
# This command generates a docbook-xml header for a book.
# 
# This is called form the parent make with $1 as the booktitle !
#


# Sets the name of the generated file
filename=header.xml

booktitle="$1"
pubdate="2008/06/27 12:01:42"
version="v0.963"

cat doctype.xml                              > $filename
echo "<book>"                               >> $filename
echo "<bookinfo>"                           >> $filename
echo "<title>$booktitle</title>"            >> $filename
echo "<author>"                             >> $filename
echo "<firstname>Paul</firstname>"          >> $filename
echo "<surname>Cobbaut</surname>"           >> $filename
echo "</author>"                            >> $filename
echo "<author>"                             >> $filename
echo "<firstname>Serge</firstname>"         >> $filename
echo "<surname>Vanginderachter</surname>"   >> $filename
echo "</author>"                            >> $filename
echo "<pubdate>$pubdate</pubdate>"          >> $filename
echo "<releaseinfo>$version</releaseinfo>"  >> $filename
cat abstract.xml                            >> $filename
echo "</bookinfo>"                          >> $filename

