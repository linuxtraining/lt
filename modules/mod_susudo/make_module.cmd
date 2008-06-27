#
# This command generates a docbook-xml for this chapter
#


# Sets the name of the generated file
modfilename=mod_susudo.xml

# Sets the title of this module
modtitle="About su and sudo"


# Generate the <chapter> and <title> tags
echo "<chapter><title>"$modtitle"</title>" > $modfilename

# Generate all the sections
cat susudo.xml   >> $modfilename

# Generate the end chapter tag
echo "</chapter>"      >> $modfilename
