#
# This command generates a docbook-xml for this chapter
#


# Sets the name of the generated file
modfilename=mod_intro_users.xml

# Sets the title of this module
modtitle="Introduction to Users"


# Generate the <chapter> and <title> tags
echo "<chapter><title>"$modtitle"</title>" > $modfilename

# Generate all the sections
cat about_users.xml    >> $modfilename
cat intro_users.xml    >> $modfilename
cat susudo.xml         >> $modfilename
cat practice_users.xml >> $modfilename

# Generate the end chapter tag
echo "</chapter>"      >> $modfilename
