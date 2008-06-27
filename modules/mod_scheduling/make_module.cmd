#
# This command generates a docbook-xml for this chapter
#


# Sets the name of the generated file
modfilename=mod_scheduling.xml

# Sets the title of this module
modtitle="Scheduling"


# Generate the <chapter> and <title> tags
echo "<chapter><title>"$modtitle"</title>" > $modfilename

# Generate all the sections
cat about.xml     >> $modfilename
cat at.xml        >> $modfilename
cat cron.xml      >> $modfilename
cat practice.xml  >> $modfilename


# Generate the end chapter tag
echo "</chapter>"      >> $modfilename
