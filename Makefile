# Let's control the CD creation process with a makefile.

iso:
	 ./make_cd.sh cc-livecd-template.ks home.tar.gz init.sh

clean:
	rm -rf /var/tmp/cc-livecd/
	rm -rf /var/tmp/cc-livecontent-*
