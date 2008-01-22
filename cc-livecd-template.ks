%include livecd-fedora-8-base-desktop.ks

lang en_US.UTF-8
keyboard us
timezone US/Eastern
auth --useshadow --enablemd5
selinux --disabled
firewall --disabled
#repo --name=devel --baseurl=http://download.fedora.redhat.com/pub/fedora/linux/releases/7/Everything/i386/os
#repo --name=update --baseurl=http://download.fedora.redhat.com/pub/fedora/linux/updates/7/i386
repo --name=fedora --baseurl=http://10.0.2.111/yum/base/$releasever/$basearch/
repo --name=updates --baseurl=http://10.0.2.111/yum/updates/$releasever/$basearch/
xconfig --startxonboot
services --enabled=NetworkManager,dhcdbd --disabled=network,sshd
%post
chmod 755 /etc/rc.d/init.d/cc-live
/sbin/restorecon /etc/rc.d/init.d/cc-live
/sbin/chkconfig --add cc-live

# if it exists use a new_splash
if [ -f /usr/lib/anaconda-runtime/splash.jpg ]
then
	echo "Copying isolinux splash image."
	mv -f /usr/lib/anaconda-runtime/splash.jpg /usr/lib/anaconda-runtime/syslinux-vesa-splash.jpg
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

%packages
%packages
@games
@graphical-internet
@graphics
@sound-and-video
@gnome-desktop
nss-mdns
NetworkManager-vpnc
NetworkManager-openvpn
abiword
gnumeric
evince
gnome-blog
#planner
#inkscape
# dictionaries are big
-aspell-*
-man-pages-*
-scim-tables-*
-wqy-bitmap-fonts
-dejavu-fonts-experimental
-dejavu-fonts
# more fun with space saving
-scim-lang-chinese
scim-chewing
scim-pinyin

# save some space
-gnome-user-docs
-gimp-help
-evolution-help
-autofs
-nss_db
-vino
%end

