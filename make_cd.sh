#! /bin/bash -xe
if [ $# -lt 3 ]
then
	echo "Too few arguments. Three are needed.  The first is the kickstart config file and the second a .tar.gz of cc's home directory. The third is an init script to be run when the cd boots up."
	exit 1
fi

ORIGPWD="$PWD"

WORK="/tmp/cc-livecontent-$$/"
echo "Going to make a mess in $WORK."
mkdir -p "$WORK"

echo "Building rpm"

RPM_WORK="$WORK/home-rpm/"
mkdir -p "$RPM_WORK"

# Step 1: Copy the spec
cp cc-home.spec "$RPM_WORK/cc-home.spec"

# Step 2: Make space for, and then unpack, the $HOME
mkdir -p "$RPM_WORK/home-tar/home/cc"
pushd "$RPM_WORK/home-tar/home/cc"
tar -mxzf "$ORIGPWD/$2"

# Step 3: Jam in the init scripts and the roll_credits program
pushd "$RPM_WORK/home-tar"
mkdir -p ./etc/rc.d/init.d
cp "$ORIGPWD/$3" ./etc/rc.d/init.d/cc-live
chmod 755 ./etc/rc.d/init.d/cc-live
#cp ../../.credits home/cc/
mkdir -p usr/bin
cp "$ORIGPWD/roll_credits" usr/bin/
chmod +x usr/bin/roll_credits

# Step 4: Optional: set up the anaconda-runtime splash (?)
if [ "$4" != "" ]
then
	mkdir -p usr/lib/anaconda-runtime/
	cp ../../$4 usr/lib/anaconda-runtime/splash.jpg
fi

# Step 5: Optional: set up the grub splash!
if [ "$5" != "" ]
then
	mkdir -p boot/grub
	cp ../../$5 boot/grub/new_splash.xpm.gz
fi

# Step 6: Wrap all this up into a tar file
cd "$RPM_WORK"
tar -czf "$WORK/cc-home.tar.gz" .

# Step 7: Copy that to the evil redhat SOURCES directory
#         and annotate the spec
cp "$WORK/cc-home.tar.gz" /usr/src/redhat/SOURCES/cc-home.tar.gz
echo "/home/" >> tmp-cc-home.spec
echo "/etc/" >> tmp-cc-home.spec
echo "/usr/" >> tmp-cc-home.spec

# Step 7a: if there was a grub splash, add those files too
if [ "$5" != "" ]
then
	echo "/boot/" >> tmp-cc-home.spec
fi

# Step 8: Actually build the RPM
rpmbuild -bb tmp-cc-home.spec

# Step 9: Put the RPM into 
REPO_WORK="$WORK/repo/"
mkdir -p "$REPO_WORK"

# FIXME: Don't get *all* RPMs - what's ours called?
cp /usr/src/redhat/RPMS/i386/*.rpm "$REPO_WORK"

echo "Fetching new rpms."
while read -r line
do
	echo -e "\tGetting $line:"
	if ls /tmp/cc-livecd/$line-?.* > /dev/null
	then
		echo "Already found, won't update."
	else
		repotrack -p /tmp/cc-livecd $line
	fi
done < $1;
echo "Creating the repo."
wget http://download.fedora.redhat.com/pub/fedora/linux/releases/7/Everything/i386/os/repodata/comps-f7.xml
cp comps-f7.xml /tmp/cc-livecd/
createrepo --update -g comps-f7.xml /tmp/cc-livecd/
rm comps-f7.xml

echo "Making kickstart file."
cp cc-livecd-template.ks cc-livecd.ks
cat $1 >> cc-livecd.ks
cat cc-packages.txt >> cc-livecd.ks
echo "cc-home" >> cc-livecd.ks
echo "Estimating total size."
echo "Building CD."
livecd-creator --config cc-livecd.ks --fslabel=ccLiveContent-1.0
echo "Removing temp directories."
rm -rf /tmp/home-tar
