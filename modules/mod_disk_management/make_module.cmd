#
# This command generates a docbook-xml for this chapter
#


# Sets the name of the generated file
modfilename=mod_disk_management.xml

# Sets the title of this module
modtitle="Disk Management"


# Generate the <chapter> and <title> tags
echo "<chapter><title>"$modtitle"</title>" > $modfilename

# Generate all the sections
cat diskdevices.xml     >> $modfilename
cat partitions.xml      >> $modfilename
cat filesystems.xml     >> $modfilename
cat mounting.xml        >> $modfilename
cat uuid.xml            >> $modfilename
cat raid.xml            >> $modfilename
# cat lvm.xml           >> $modfilename

# Generate the end chapter tag
echo "</chapter>"      >> $modfilename
