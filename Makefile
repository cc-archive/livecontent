# Let's control the CD creation process with a makefile.

TEMPDIR := $(shell mktemp -d /var/tmp/cc-livecontent-makefilework-XXXX)

all: iso

iso: hometarball
	 sudo yum -y install rpm-build livecd-tools createrepo rsync gimp
	 ./make_cd.sh cc-livecd-template.ks home.tar.gz init.sh
	 rsync -avz *.iso paulproteus@10.0.2.2:cctools/livecontent/built-images/

hometarball:
	svn export home ${TEMPDIR}/home
	(cd "${TEMPDIR}" ; tar zcf - home) > home.tar.gz

clean:
	rm -f home.tar.gz
	sudo rm -rf /var/tmp/cc-livecd/
	sudo rm -rf /var/tmp/cc-livecontent-*
