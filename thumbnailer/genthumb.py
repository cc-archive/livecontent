import os
import md5
import gtk.gdk

def gen_thumb(thumbnail_storage_land,
              alleged_filenames,
              path_to_image):
    for (size, height, width) in ( ('normal', 128, 128),
                                   ('large',  256, 256) ):
        outpath = os.path.join(thumbnail_storage_land, size)
        thumb = gtk.gdk.pixbuf_new_from_file_at_size(height, width)
        for hashme in alleged_filenames:
            if not hashme.startswith('file://'):
                hashme = 'file://' + hashme 
            assert hashme.startswith('file:///')
            hashed = md5.md5(hashme).hexdigest()
            out_filename = os.path.join(outpath, hashed + '.png')
            thumb.save(out_filename, 'png', 
                {'tEXt::Thumb::URI': hashme,
                 'tEXt::Thumb::MTime': str(os.stat(path_to_image)[8]),
                 'tEXt::Thumb::Size': str(os.stat(path_to_image)[6])})

def main():
    # Note: This part is a little hard-codey.  Sorry about that.
    import sys
    path_to_image, alleged_base_path, thumbnail_storage_land = sys.argv[1:4]
    
    alleged_filenames = [os.path.join(alleged_base_path, path_to_image)]
    gen_thumb(thumbnail_storage_land, alleged_filenames, path_to_image)
