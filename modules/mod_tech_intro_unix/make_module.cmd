#
# This command generates a docbook-xml for this chapter
#


# Sets the name of the generated file
modfilename=mod_tech_intro_unix.xml

# Sets the title of this module
modtitle="Technical Introduction to Unix and Linux"


# Generate the <chapter> and <title> tags
echo "<chapter><title>"$modtitle"</title>" > $modfilename

# Generate all the sections
cat ioperating_system.xml     >> $modfilename
cat ihelp.xml               >> $modfilename  
cat classroom.xml            >> $modfilename

# Generate the end chapter tag
echo "</chapter>"      >> $modfilename
