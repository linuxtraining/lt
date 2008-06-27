#
# This command generates a docbook-xml for this chapter
#


# Sets the name of the generated file
modfilename=mod_booting_linux.xml

# Sets the title of this module
modtitle="Booting Linux"


# Generate the <chapter> and <title> tags
echo "<chapter><title>"$modtitle"</title>" > $modfilename

# Generate all the sections
cat boot.xml           >> $modfilename
cat grub.xml           >> $modfilename
cat lilo.xml           >> $modfilename
cat system_init.xml    >> $modfilename
cat practice.xml       >> $modfilename


# Generate the end chapter tag
echo "</chapter>"      >> $modfilename
