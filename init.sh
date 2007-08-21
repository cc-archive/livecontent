#!/bin/bash
#
# live: Init script for live image
#
# chkconfig: 345 00 99
# description: Init script for live image.

. /etc/init.d/functions

if ! cat /proc/cmdline | grep -q "liveimg" || [ "$1" != "start" ] || [ -e /.liveimg-configured ] ; then
    exit 0
fi

exists() {
    which $1 >/dev/null 2>&1 || return
    $*
}
echo "Setting up ccLiveContent..."
touch /.liveimg-configured
mv -f /home/cc/.config/menus/applications-live.menu /home/cc/.config/menus/applications.menu
# mount live image
#if [ -b /dev/live ]; then
#   mkdir -p /mnt/live
#   mount -o ro /dev/live /mnt/live
#fi

# configure X
exists system-config-display --noui --reconfig --set-depth=24

# unmute sound card
exists alsaunmute 0 2> /dev/null

# remove the install to hard disk desktop icon
rm /home/cc/Desktop/liveinst.desktop &> /dev/null

# disable screensaver locking
gconftool-2 --direct --config-source=xml:readwrite:/etc/gconf/gconf.xml.defaults -s -t bool /apps/gnome-screensaver/lock_enabled false &>/dev/null
# set up timed auto-login for after 60 seconds
sed -i -e 's/\[daemon\]/[daemon]\nDefaultSession=gnome.desktop\nAutomaticLoginEnable=true\nAutomaticLogin=cc/' /etc/gdm/custom.conf
if [ -e /usr/share/icons/hicolor/96x96/apps/fedora-logo-icon.png ] ; then
    cp /usr/share/icons/hicolor/96x96/apps/fedora-logo-icon.png /home/cc/.face
    chown cc:cc /home/cc/.face
    # TODO: would be nice to get e-d-s to pick this one up too... but how?
fi
# turn off firstboot for livecd boots
echo "RUN_FIRSTBOOT=NO" > /etc/sysconfig/firstboot

# don't start yum-updatesd for livecd boots
chkconfig --level 345 yum-updatesd off &> /dev/null

# don't start cron/at as they tend to spawn things which are
# disk intensive that are painful on a live image
chkconfig --level 345 crond off &> /dev/null
chkconfig --level 345 atd off &> /dev/null
chkconfig --level 345 anacron off &> /dev/null
chkconfig --level 345 readahead_early off &> /dev/null
chkconfig --level 345 readahead_later off &> /dev/null

# Stopgap fix for RH #217966; should be fixed in HAL instead
touch /media/.hal-mtab
