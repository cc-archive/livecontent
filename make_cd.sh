#! /bin/bash -xe

ANACONDA_SPLASH="splash.jpg"
BOOT_SPLASH="livecd_splash.xpm.gz"

if [ $# -lt 3 ]
then
	echo "Too few arguments. Three are needed.  The first is the kickstart config file and the second a .tar.gz of cc's home directory. The third is an init script to be run when the cd boots up."
	exit 1
fi

ORIGPWD="$PWD"

REPO_WORK="/var/tmp/cc-livecd/" # Evil, lame path.

WORK="/var/tmp/cc-livecontent-$$/"
echo "Going to make a mess in $WORK."
mkdir -p "$WORK"
cd "$WORK"

echo "Building rpm"

RPM_WORK="$WORK/rpmbuild/"
RPM_TREE="$RPM_WORK/tree"
mkdir -p "$RPM_WORK"
mkdir -p "$RPM_TREE"

# Step 1: Copy the spec to RPM_WORK
cp "$ORIGPWD/cc-home.spec" "$RPM_WORK/cc-home.spec"

# Step 2: Make space for, and then unpack, the $HOME
HOME_WORK="$WORK/home-build"
mkdir -p "$HOME_WORK/home/cc"

pushd "$HOME_WORK/home/cc"
# if there is only one directory here, then we should cd into it first
tar -mxzf "$ORIGPWD/$2"
if [ `ls -d * | wc -l` = 1 ] ; then
    if [ `ls | wc -l` = 1 ] ; then
        dir=$(ls)
        for thing in $dir/*; do
            mv "$thing" .
        done
        for hiddenthing in $(ls --almost-all $dir); do
            mv "$dir/$hiddenthing" .
        done
        # NOTE: Will fail for dot directories with spaces. :-(
        rmdir $dir # but we'll know at this point

        echo "Moved directory contents one up, BTW."
    fi
fi
popd

# Step 3: Jam in the init scripts and the roll_credits program
mkdir -p "$HOME_WORK/etc/rc.d/init.d"
cp "$ORIGPWD/$3" "$HOME_WORK/etc/rc.d/init.d/cc-live"
chmod 755 "$HOME_WORK/etc/rc.d/init.d/cc-live"
#cp ../../.credits home/cc/
mkdir -p "$HOME_WORK/usr/bin"
cp "$ORIGPWD/roll_credits" "$HOME_WORK/usr/bin/"
chmod +x "$HOME_WORK/usr/bin/roll_credits"

# Step 4: Optional: set up the anaconda-runtime splash (?)
mkdir -p usr/lib/anaconda-runtime/
cp "$ORIGPWD/$ANACONDA_SPLASH" usr/lib/anaconda-runtime/syslinux-vesa-splash.jpg

# Step 5: Optional: set up the grub splash!
mkdir -p boot/grub
cp "$ORIGPWD/$BOOT_SPLASH" boot/grub/new_splash.xpm.gz

# Step 6: Wrap all this up into a tar file
pushd "$HOME_WORK"
tar -czf "$WORK/cc-home.tar.gz" .
popd

# Step 7: Copy that to the evil redhat SOURCES directory
#         and annotate the spec
sudo cp "$WORK/cc-home.tar.gz" /usr/src/redhat/SOURCES/cc-home.tar.gz
echo "/home/" >> "$RPM_WORK/cc-home.spec"
echo "/etc/" >> "$RPM_WORK/cc-home.spec"
echo "/usr/" >> "$RPM_WORK/cc-home.spec"

# Step 7a: if there was a grub splash, add those files too
if [ "$5" != "" ]
then
	echo "/boot/" >> "$RPM_WORK/cc-home.spec"
fi

# Step 8: Actually build the RPM
pushd "$RPM_TREE"
sudo rpmbuild -bb  "$RPM_WORK/cc-home.spec"
popd

# Step 9: Put the RPM into $REPO_WORK
mkdir -p "$REPO_WORK"

# Preferably grab only the latest-generated RPM.
cp /usr/src/redhat/RPMS/i386/cc-home*.rpm "$REPO_WORK"

cd "$REPO_WORK"
echo "Fetching new rpms."
#repotrack -p "$REPO_WORK" cc-home
wget -c http://download.fedora.redhat.com/pub/fedora/linux/releases/8/Everything/i386/os/repodata/Fedora-8-comps.xml
createrepo --update -g Fedora-8-comps.xml "$REPO_WORK"

echo "Making kickstart file."
cp "$ORIGPWD/cc-livecd-template.ks" cc-livecd.ks # LAME
cat "$ORIGPWD/packages-whitelist.txt" >> cc-livecd.ks # whitelist
cat "$ORIGPWD/packages-blacklist.txt" >> cc-livecd.ks # blacklist
echo "cc-home" >> cc-livecd.ks
echo "Estimating total size."
echo "Building CD."
sudo livecd-creator --config cc-livecd.ks --fslabel=ccLiveContent-1.0
mv *.iso "$ORIGPWD"
echo "Not removing temp directories."
