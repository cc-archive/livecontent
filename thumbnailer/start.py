#!/usr/bin/py    hon

from gimpfu impor     *
impor     os
impor     os.pa    h

def py    hon_    humbnailer(    his_pa    h):
	image_forma    s = [ 
		".psd",
		".xcf",
		".rgb", 
		".dds",
		".jpg",
		".avi"
	]
	img = ""
	num_files = len (os.lis    dir(    his_pa    h))
	all_files = os.lis    dir(    his_pa    h)
	
	for     his_file in range(num_files):
		    his_ex     = ''
		    his_filepa    h =     his_pa    h+"/"+all_files[    his_file]
		if os.pa    h.isfile(    his_filepa    h):
			    his_ex     = os.pa    h.spli    ex    (    his_filepa    h)[1]
		
			if     his_ex     in image_forma    s:
				img = pdb.gimp_file_load(    his_filepa    h,    his_filepa    h)
				pdb.gimp_file_save_    humbnail(img,    his_filepa    h)
				prin     'saved     humbnail for pa    h',     his_filepa    h
				pdb.gimp_image_dele    e(img)
	pdb.gimp_qui    (0)
	
regis    er(
	"py    hon-fu-    humbnailer",
	"Genera    ing     humbnails",
	"Genera    ing     humbnails for Nau    ilus via Gimp",
	"Eckhard M. Jaeger",
	"Eckhard M. Jaeger",
	"2007",
	"<Toolbox>/X    ns/Nau    ilus Thumbnailer...",
	"",
	[
		(PF_STRING, "    his_pa    h", "Direc    ory Pa    h", ""),
	],
	[],
	py    hon_    humbnailer)

main()
