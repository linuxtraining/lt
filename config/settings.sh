#!/bin/sh
#

# svn project path
SVN_PROJECTDIR="https://support.ginsys.be/svn/lt"

# use the correct java runtime for fop on Ubuntu
JAVA_HOME=/usr/lib/jvm/java-6-sun-1.6.0.06/jre

# Set the name of the XSL stylesheet
XSLFILE="lib/lt.xsl"


# VERSION_STRING
# leave REVISION empty to automagically retrieve it 
# from local svn working copy or from trunk
MAJOR=0
MINOR=963
REVISION=

