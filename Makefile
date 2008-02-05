# Let's control the CD creation process with a makefile.

all: iso

iso:
	 sudo yum -y install rpm-build livecd-tools createrepo rsync
	 #./make_cd.sh cc-livecd-template.ks home.tar.gz init.sh
	 rsync -avz *.iso paulproteus@10.0.2.2:cctools/livecontent/built-images/

clean:
	sudo rm -rf /var/tmp/cc-livecd/
	sudo rm -rf /var/tmp/cc-livecontent-*
