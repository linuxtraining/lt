#
# This command generates a docbook-xml for this chapter
#


# Sets the name of the generated file
modfilename=mod_intro_scripts.xml

# Sets the title of this module
modtitle="Introduction to Scripting"


# Generate the <chapter> and <title> tags
echo "<chapter><title>"$modtitle"</title>" > $modfilename

# Generate all the sections
cat about_scripting.xml  >> $modfilename
cat scripting.xml        >> $modfilename

# Generate the end chapter tag
echo "</chapter>"      >> $modfilename
