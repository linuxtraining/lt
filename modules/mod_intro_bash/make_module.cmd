#
# This command generates a docbook-xml for this chapter
#


# Sets the name of the generated file
modfilename=mod_intro_bash.xml

# Sets the title of this module
modtitle="Introduction to Bash"


# Generate the <chapter> and <title> tags
echo "<chapter><title>"$modtitle"</title>" > $modfilename

# Generate all the sections
cat iabout_bash.xml             >> $modfilename
cat ibash_shell_expansion.xml   >> $modfilename
cat ibash_shell_history.xml     >> $modfilename

# Generate the end chapter tag
echo "</chapter>"      >> $modfilename
