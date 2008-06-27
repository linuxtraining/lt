#
# This command generates a docbook-xml for this chapter
#


# Sets the name of the generated file
modfilename=mod_hardware_kernel.xml

# Sets the title of this module
modtitle="Hardware and Kernel"


# Generate the <chapter> and <title> tags
echo "<chapter><title>"$modtitle"</title>" > $modfilename

# Generate all the sections
cat hardware.xml    >> $modfilename
cat kernel.xml    >> $modfilename

# Generate the end chapter tag
echo "</chapter>"      >> $modfilename
