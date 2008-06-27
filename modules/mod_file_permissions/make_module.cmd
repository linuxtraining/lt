#
# This command generates a docbook-xml for this chapter
#


# Sets the name of the generated file
modfilename=mod_file_permissions.xml

# Sets the title of this module
modtitle="Standard File Permissions"


# Generate the <chapter> and <title> tags
echo "<chapter><title>"$modtitle"</title>" > $modfilename

# Generate all the sections
cat standard_permissions.xml >> $modfilename
cat practice_standard.xml    >> $modfilename
cat sticky_bit.xml           >> $modfilename
cat setgid_setuid.xml        >> $modfilename
cat practice_sst.xml         >> $modfilename


# Generate the end chapter tag
echo "</chapter>"      >> $modfilename
