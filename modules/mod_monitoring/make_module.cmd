#
# This command generates a docbook-xml for this chapter
#


# Sets the name of the generated file
modfilename=mod_monitoring.xml

# Sets the title of this module
modtitle="Performance Monitoring"


# Generate the <chapter> and <title> tags
echo "<chapter><title>"$modtitle"</title>" > $modfilename

# Generate all the sections
cat monitoring.xml         >> $modfilename


# Generate the end chapter tag
echo "</chapter>"      >> $modfilename
