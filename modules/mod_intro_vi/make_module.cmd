#
# This command generates a docbook-xml for this chapter
#


# Sets the name of the generated file
modfilename=mod_intro_vi.xml

# Sets the title of this module
modtitle="Introduction to vi"


# Generate the <chapter> and <title> tags
echo "<chapter><title>"$modtitle"</title>" > $modfilename

# Generate all the sections
cat iabout_vi.xml   >> $modfilename
cat iintro_vi.xml   >> $modfilename
cat ipractice_vi.xml   >> $modfilename

# Generate the end chapter tag
echo "</chapter>"      >> $modfilename
