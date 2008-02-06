    def store_image(self, img, inname, outname, ow, oh):
        """Store the thumbnail image it the correct location, adding
        the extra data required by the thumbnail spec."""
        s=os.stat(inname)

        img.save(outname+self.fname, 'png',
             {'tEXt::Thumb::Image::Width': str(ow),
              'tEXt::Thumb::Image::Height': str(oh),
              "tEXt::Thumb::Size": str(s.st_size),
              "tEXt::Thumb::MTime": str(s.st_mtime),
              'tEXt::Thumb::URI': rox.escape('file://'+inname),
              'tEXt::Software': self.name})
        os.rename(outname+self.fname, outname)

