#
# This command generates a docbook-xml for this chapter
#


# Sets the name of the generated file
modfilename=mod_network.xml

# Sets the title of this module
modtitle="Introduction to Networking"


# Generate the <chapter> and <title> tags
echo "<chapter><title>"$modtitle"</title>" > $modfilename

# Generate all the sections

cat about_tcpip.xml      >> $modfilename
cat using_tcpip.xml      >> $modfilename
cat multiple_ip.xml      >> $modfilename
cat bonding.xml          >> $modfilename
cat iptables.xml         >> $modfilename
cat inetd_xinetd.xml     >> $modfilename
cat ssh.xml              >> $modfilename
cat nfs.xml              >> $modfilename

# Generate the end chapter tag
echo "</chapter>"      >> $modfilename
