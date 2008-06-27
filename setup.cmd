#!/bin/bash
# setup for first time use of lt

echo This script will download static files needed to make the pdf
echo  to ../static
echo 
if [ ! -e ../static ] 
	then mkdir ../static
fi

echo Downloading static docbook, xsl and fop
cd ../static
wget https://support.ginsys.be/files/svn/lt/docbook.tbz
wget https://support.ginsys.be/files/svn/lt/fop.tbz
wget https://support.ginsys.be/files/svn/lt/xsl.tbz
tar -xvjf docbook.tbz
tar -xvjf fop.tbz
tar -xvjf xsl.tbz
rm docbook.tbz fop.tbz xsl.tbz

