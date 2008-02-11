lang en_US.UTF-8
keyboard us
timezone US/Eastern
auth --useshadow --enablemd5
selinux --disabled
firewall --disabled
#repo --name=devel --baseurl=http://download.fedora.redhat.com/pub/fedora/linux/releases/7/Everything/i386/os
#repo --name=update --baseurl=http://download.fedora.redhat.com/pub/fedora/linux/updates/7/i386
repo --name=f8         --baseurl=http://10.0.2.2/~fmirror/yum/base/8/i386/
repo --name=f8_updates --baseurl=http://10.0.2.2/~fmirror/yum/updates/8/i386/
repo --name=home --baseurl=file:///var/tmp/cc-livecd
xconfig --startxonboot

# Below hack necessary to get the CD to boot on a CC Dell.
# I can't believe it's 2008 and I'm still doing this.
bootloader --append "noapic"
# </hack>

services --enabled=NetworkManager --disabled=network

%post --nochroot

# FIX BOOTLOADER SPLASH
# LIVECD-CREATOR RUNS configureBootLoader() BEFORE runPost()
# This is a hack that might be possible to remove by reorganizing things?
# Does RPM have an equivalent to dpkg-divert?   But who cares, really.
cp -f "$INSTALL_ROOT/usr/lib/anaconda-runtime/staging-splash.jpg" \
   "$LIVE_ROOT/isolinux/splash.jpg"

cd "$LIVE_ROOT"
mkdir -p Content
cd Content

### Grab Content
NEWDIR="Wikimedia Commons Featured Pictures"
mkdir "$NEWDIR"
pushd "$NEWDIR"
wget http://10.0.2.2/~paulproteus/wikimedia-poty/livecontent.zip
unzip livecontent.zip

# Create thumbnail directory
mkdir -p "$INSTALL_ROOT/home/cc/.thumbnails/normal/"

# For each jpg or svg or png, generate the thumbnail
find -iname \*.jpg -or -iname \*.svg -or -iname \*.png -print0 | xargs -0 -n1 -I '{}' \
    python "$INSTALL_ROOT"/usr/bin/gen_thumbnails.py '{}' "/mnt/live/Content/$NEWDIR/" "$INSTALL_ROOT/home/cc/.thumbnails/normal/"

rm -f livecontent.zip

pushd "$INSTALL_ROOT"/home/cc/Desktop/Image/
ln -sf "/mnt/live/Content/$NEWDIR"

# For each jpg or svg or png, generate the thumbnail
find -iname \*.jpg -or -iname \*.svg -or -iname \*.png -print0 | xargs -0 -n1 -I '{}' \
    python "$INSTALL_ROOT"/usr/bin/gen_thumbnails.py '{}' "/home/cc/Desktop/Image/$NEWDIR/" "$INSTALL_ROOT/home/cc/.thumbnails/normal/"

popd

### FIXME: Fix thumbnails

popd

### Grab Flickr content
curl --max-time 900 10.0.2.2:8080/make_zip
wget 10.0.2.2:8080/grab_zip -O flickr.tar.gz
tar zxvf flickr.tar.gz

NEWDIR="Flickr.com Interesting photos"
pushd "$NEWDIR"

pushd "$INSTALL_ROOT"/home/cc/Desktop/Image/
ln -s "$OLDPWD"
popd

popd

rm -f flickr.tar.gz

### FIXME: Fix thumbnails
%end

%post
chmod 755 /etc/rc.d/init.d/cc-live
/sbin/restorecon /etc/rc.d/init.d/cc-live
/sbin/chkconfig --add cc-live

# if it exists use a new_splash
if [ -f /usr/lib/anaconda-runtime/staging-splash.jpg ]
then
	echo "Copying isolinux splash image."
	mv -f /usr/lib/anaconda-runtime/staging-splash.jpg /usr/lib/anaconda-runtime/syslinux-vesa-splash.jpg
else
	echo "No custom isolinux splash."
fi
# if it exists use a new_splash
if [ -f /boot/grub/new_splash.xpm.gz ]
then
	echo "Copying grub splash image."
	mv -f /boot/grub/new_splash.xpm.gz /boot/grub/splash.xpm.gz
else
	echo "No custom grub splash."
fi

/usr/sbin/useradd -c "Creative Commoner" cc
/usr/bin/passwd -d cc &> /dev/null
/bin/chown -R cc:cc /home/cc

# save a little bit of space at least...
rm -f /boot/initrd*
%end

%packages
