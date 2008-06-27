#
# This command generates a docbook-xml for this chapter
#


# Sets the name of the generated file
modfilename=mod_file_system_tree.xml

# Sets the title of this module
modtitle="The Linux File system Tree"


# Generate the <chapter> and <title> tags
echo "<chapter><title>"$modtitle"</title>" > $modfilename

# Generate all the sections
cat file_system_tree.xml   >> $modfilename

# Generate the end chapter tag
echo "</chapter>"      >> $modfilename
