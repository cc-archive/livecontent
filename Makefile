# Let's control the CD creation process with a makefile.

all: iso

iso:
	 sudo yum install rpm-build livecd-tools createrepo
	 ./make_cd.sh cc-livecd-template.ks home.tar.gz init.sh

clean:
	sudo rm -rf /var/tmp/cc-livecd/
	sudo rm -rf /var/tmp/cc-livecontent-*
