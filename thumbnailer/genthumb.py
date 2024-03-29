import os
import sys
import md5
import gtk.gdk

def gen_thumb(thumbnail_storage_land,
              alleged_filenames,
              path_to_image, size):
    height, width = {'normal': (128, 128),
                     'large': (256, 256)}[size]
    outpath = os.path.join(thumbnail_storage_land, size)
    if not os.path.exists(outpath):
        os.makedirs(outpath, mode=0755)

    thumb = gtk.gdk.pixbuf_new_from_file_at_size(path_to_image, height, width)
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
    print >> sys.stderr, 'Made', out_filename
    assert len(open(out_filename).read())
    return out_filename

def main():
    # Note: This part is a little hard-codey.  Sorry about that.
    import sys
    path_to_image, alleged_base_path, thumbnail_storage_land = sys.argv[1:4]
    
    alleged_filenames = [os.path.join(alleged_base_path, path_to_image)]
    gen_thumb(thumbnail_storage_land, alleged_filenames, path_to_image, 'normal')
