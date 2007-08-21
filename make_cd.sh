#! /bin/bash
if [ $# -lt 3 ]
then
	echo "Too few arguments. Three are needed.  The first is the kickstart config file and the second a .tar.gz of cc's home directory. The third is an init script to be run when the cd boots up."
	exit 1
fi

echo "Building rpm."
cp cc-home.spec tmp-cc-home.spec
mkdir -p /tmp/home-tar/home/cc
cd /tmp/home-tar/home/cc
tar -mxzf ../../../../$2
cd /tmp/home-tar
mkdir -p ./etc/rc.d/init.d
cp ../../$3 ./etc/rc.d/init.d/cc-live
chmod 755 ./etc/rc.d/init.d/cc-live
#cp ../../.credits home/cc/
mkdir -p usr/bin
cp ../../roll_credits usr/bin/
chmod +x usr/bin/roll_credits
if [ $4 != "" ]
then
	mkdir -p usr/lib/anaconda-runtime/
	cp ../../$4 usr/lib/anaconda-runtime/splash.jpg
fi
if [ $5 != "" ]
then
	mkdir -p boot/grub
	cp ../../$5 boot/grub/new_splash.xpm.gz
fi
tar -czf cc-home.tar.gz *
mv cc-home.tar.gz ../
cd /
cp /tmp/cc-home.tar.gz /usr/src/redhat/SOURCES/cc-home.tar.gz
echo "/home/" >> tmp-cc-home.spec
echo "/etc/" >> tmp-cc-home.spec
echo "/usr/" >> tmp-cc-home.spec
if [ $5 != "" ]
then
	echo "/boot/" >> tmp-cc-home.spec
fi
rpmbuild -bb tmp-cc-home.spec
cp /usr/src/redhat/RPMS/i386/*.rpm /tmp/cc-livecd/
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
