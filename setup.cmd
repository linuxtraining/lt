# setup for first time use of lt
# added by paul

echo This script will copy everything in your current directory 
echo Script will create ./static and ./current
mkdir ./static
mkdir ./current

echo Downloading static docbook, xsl and fop
cd ./static
wget -r https://support.ginsys.be/files/svn/lt/


echo Checking out latest trunk from svn
cd ../current
svn

