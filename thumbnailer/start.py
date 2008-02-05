# Source: http://www.nabble.com/thumbnail-generation-for-nautilus-via-gimp-td14108887.html

from gimpfu import *
import os
import os.path

def python_thumbnailer(this_path):
  image_formats = [
    ".psd",
    ".xcf",
    ".rgb"
  ]
  num_files = len (os.listdir(this_path))
  all_files = os.listdir(this_path)
 
  for this_file in range(num_files):
    this_ext = ''
    this_filepath = this_path+"/"+all_files[this_file]
    if os.path.isfile(this_filepath):
      this_ext = splitext(this_filepath)[1]
   
      if this_ext in image_formats:
        pdb.gimp_file_load(this_filepath,this_filepath)
        pdb.gimp_file_save_thumbnail(this_filepath,this_filepath)
        pdb.gimp_image_delete(this_filepath)
  pdb.gimp_quit(0)
register(
  "python-fu-thumbnailer",
  "Generating thumbnails",
  "Generating thumbnails for Nautilus via Gimp",
  "Eckhard M. Jaeger",
  "Eckhard M. Jaeger",
  "2007",
  "<Toolbox>/Xtns/Nautilus Thumbnailer...",
  "",
  [
    (PF_STRING, "this_path", "Directory Path", ""),
  ],
  [],
  python_thumbnailer)

main()
