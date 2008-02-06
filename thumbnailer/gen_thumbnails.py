### HTTP POST version
import urllib
import urllib2
import md5

def gen_thumb_data(path_to_image, alleged_base_path):
    url = 'http://10.0.2.2:8082/genthumb'
    values = {'image_data': open(path_to_image).read(),
              'path_to_image': path_to_image,
              'alleged_base_path': alleged_base_path}
    data = urllib.urlencode(values)
    req = urllib2.Request(url, data)
    return req.read()

def gen_thumb_filename(path_to_image, alleged_base_path):
    path = os.path.join(alleged_base_path, path_to_image)
    path = 'file://' + path
    assert path.startswith('file:///')
    return path

def gen_thumbdir_hashname(thumb_filename, outdir):
    return os.path.join(outdir,
        md5.md5(thumb_filename).hexdigest + '.png')

def main():
    import sys
    path_to_image = sys.argv[1]
    alleged_base_path = sys.argv[2]
    outdir = sys.argv[3]

    thumb_data = gen_thumb_data(path_to_image, alleged_base_path)
    thumb_filename = gen_thumb_filename(path_to_image, alleged_base_path)
    fd = open(gen_thumbdir_hashname(thumb_filename, outdir), 'w')
    fd.write(thumb_data)
    fd.close()

    print 'success with', path_to_image
