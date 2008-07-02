#!/bin/sh

if [ ! -e ../static ]
        then mkdir ../static && bin/setup.cmd ; exit
fi

# cleanup
if [ -d book ]
	then rm -rf book
fi
mkdir book

# use the correct java runtime for fop on Ubuntu
export JAVA_HOME=/usr/lib/jvm/java-6-sun-1.6.0.06/jre

# Set the name of the generated XML
xmlfile=book`date +%Y%m%d`.xml

# Set the name of the generated PDF
pdffile=book.pdf

# Set the name of the XSL stylesheet
xslfile="lib/lt.xsl"


# Include Linux Fundamentals (yes/no)?
linuxfun=yes

# Include Linux System Administration (yes/no)?
linuxsysadm=yes

# Include Linux Advanced Servers (yes/no)?
linuxadv=yes


# Set a descriptive title for the book
#booktitle="Linux Fundamentals"
booktitle="Linux System Administration"
#booktitle="Linux Servers"
(cd header;./make_header.cmd "$booktitle")


echo catting all chapters into $xmlfile ...

cat header/header.xml                                   > $xmlfile

if [ $linuxfun = 'yes' ] ; then
 cat modules/mod_intro_unix/mod_intro_unix.xml                 >> $xmlfile
 cat modules/mod_tech_intro_unix/mod_tech_intro_unix.xml       >> $xmlfile
 cat modules/mod_first_steps/mod_first_steps.xml               >> $xmlfile
 cat modules/mod_file_system_tree/mod_file_system_tree.xml     >> $xmlfile
 cat modules/mod_intro_bash/mod_intro_bash.xml                 >> $xmlfile
 cat modules/mod_intro_vi/mod_intro_vi.xml                     >> $xmlfile
 cat modules/mod_intro_users/mod_intro_users.xml               >> $xmlfile
 cat modules/mod_intro_groups/mod_intro_groups.xml             >> $xmlfile
 cat modules/mod_file_permissions/mod_file_permissions.xml     >> $xmlfile
 cat modules/mod_links/mod_links.xml                           >> $xmlfile
 cat modules/mod_intro_scripts/mod_intro_scripts.xml           >> $xmlfile
 cat modules/mod_processes/mod_processes.xml                   >> $xmlfile
 cat modules/mod_more_bash/mod_more_bash.xml                   >> $xmlfile
 cat modules/mod_pipes_filters/mod_pipes_filters.xml           >> $xmlfile
fi

if [ $linuxsysadm = 'yes' ] ; then
 cat modules/mod_disk_management/mod_disk_management.xml       >> $xmlfile
 cat modules/mod_lvm/mod_lvm.xml                               >> $xmlfile
 cat modules/mod_booting_linux/mod_booting_linux.xml           >> $xmlfile
 cat modules/mod_hardware_kernel/mod_hardware_kernel.xml       >> $xmlfile
 cat modules/mod_network/mod_network.xml                       >> $xmlfile
 cat modules/mod_scheduling/mod_scheduling.xml                 >> $xmlfile
 cat modules/mod_logging/mod_logging.xml                       >> $xmlfile
 cat modules/mod_memory/mod_memory.xml                         >> $xmlfile
 cat modules/mod_installing_linux/mod_installing_linux.xml     >> $xmlfile 
 cat modules/mod_package_management/mod_package_management.xml >> $xmlfile 
 cat modules/mod_backup/mod_backup.xml                         >> $xmlfile
 cat modules/mod_monitoring/mod_monitoring.xml                 >> $xmlfile
 cat modules/mod_vnc/mod_vnc.xml                               >> $xmlfile
 cat modules/mod_quotas/mod_quotas.xml                         >> $xmlfile
fi

if [ $linuxadv = 'yes' ] ; then
 cat modules/mod_cloning/mod_cloning.xml                       >> $xmlfile
 cat modules/mod_samba/mod_samba.xml                           >> $xmlfile
# cat modules/mod_selinux/mod_selinux.xml                       >> $xmlfile
 cat modules/mod_apache/mod_apache.xml                         >> $xmlfile
fi

cat footer/footer.xml                                  >> $xmlfile

echo running fop to create $pdffile using $xslfile ...
../static/fop-0.95beta/fop -xml $xmlfile -xsl $xslfile -pdf $pdffile 

