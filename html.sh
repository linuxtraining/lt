#!/bin/bash
#
# generate html from lt.xml
# Paul Cobbaut, 2010-april-11
# 

outputdir="./output"
htmldir="$outputdir/html"
imgdir="$htmldir/images"
imgsrcdir="./images"

# Clear and recreate html and image directory
[ -d $htmldir ] && rm -rf $htmldir
mkdir -p $imgdir || echo error creating $imgdir

# We only need the one xml file
cp $outputdir/Linux*.xml $htmldir || echo error copying Linux*.xml

# Locate the used images in the xml file
images=`grep imagedata $htmldir/*.xml | cut -d/ -f2 | cut -d\" -f1`

# Copy all the used images
for img in $images
 do
  echo Copying $img to $imgdir ...
  cp "$imgsrcdir/$img" $imgdir/ || echo error copying $img
 done

# Run xmlto in the new directory
cd $htmldir && xmlto html *.xml || echo could not enter $htmldir

# don't need the xml on the webserver
rm *.xml
exit 0
