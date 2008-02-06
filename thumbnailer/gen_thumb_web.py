import web
import tempfile
import os

import genthumb

urls = (
    '/genthumb', 'GenThumb'
)

class GenThumb(object):
    def POST(self):
        # Pull data out
        input = web.input()
        image_data = input.image_data
        alleged_base_path = input.alleged_base_path
        path_to_image = input.path_to_image

        # Save filename
        myfilename = tempfile.mkstemp()[1]
        myfile = open(myfilename, 'w')
        myfile.write(image_data)
        myfile.close()

        # Gen thumb
        mythumbname = genthumb.gen_thumb('/tmp/', 
            [os.path.join(alleged_base_path, path_to_image)],
            myfilename)
        ret = open(mythumbname).read()

        # Clean up after ourselves manually, boo-hiss
        os.unlink(mythumbname)
        os.unlink(myfilename)

        return ret

if __name__ == "__main__":
    web.run(urls, globals())

