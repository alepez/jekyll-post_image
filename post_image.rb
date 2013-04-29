# Generates an image that fit post, using as source directory
# _assets/POSTNAME/
#
# Usage:
# ------
#
# Specify wanted dimension in _config.yml
#
#     post_image:
#         dimensions: '870x'
#
# Put this tag in posts where you need it:
#
#     {% image filename.ext "Alternative text" %}
#
# Example:
# --------
#
# In post `_posts/2013-04-25-foo-bar.md`, write this
#
#
#     {% image my-portrait.jpg "My portrait" %}
#
# Jekyll searches for image source in `_assets/2013-04-25-foo-bar/my-portrait.jpg`
# puts a resized image in `assets/2013-04-25-foo-bar/my-portrait.jpg` and replace
# the tag with an `img` tag.
#
#

require 'mini_magick'

module Jekyll
  class PagePathGenerator < Generator
    safe true
    ## See post.dir and post.base for directory information.
    def generate(site)
      site.posts.each do |post|
        post.data['path'] = post.name
      end

    end
  end

  class Jekyll::PostImage < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      if /(?<src>[^\s]+)\s+"(?<alt>.+)"/i =~ markup
        @src = src
        @alt = alt
      elsif /(?<src>[^\s]+)\s*/i =~ markup
        @src = src
      end
      super
    end

    def render(context)
      if @src
        # Source
        src = @src
        site_src = context.environments.first['site']['source']
        post_name = context.environments.first['page']['path']
        post_name = File.basename(post_name, File.extname(post_name))
        src_path = "#{site_src}/_assets/#{post_name}/#{src}"
        raise "#{src_path} is not readable" unless File.readable?(src_path)
        # Destination
        original_ext = File.extname(src_path)
        basename = File.basename(src_path, File.extname(src_path))
        resized = basename + '.jpg'
        original = basename + '.original' + original_ext
        resized_url = "/assets/#{post_name}/#{resized}"
        original_url = "/assets/#{post_name}/#{original}"
        resized_path = "#{site_src}#{resized_url}"
        original_path = "#{site_src}#{original_url}"
        dst_dir = File.dirname("#{site_src}#{resized_url}")
        FileUtils.mkdir_p(dst_dir) unless File.exists?(dst_dir)
        # only thumbnail the image if it doesn't exist tor is less recent than the source file
        # will prevent re-processing thumbnails for a ton of images...
        if !File.exists?(resized_path) || File.mtime(resized_path) <= File.mtime(src_path)
          puts "Resizing #{src} to #{resized_path}"
          dimensions = Jekyll.configuration({})['post_image']['dimensions']
          image = MiniMagick::Image.open(src_path)
          image.strip
          image.resize dimensions
          image.write resized_path
        end
        if @alt
          """<img src='#{resized_url}' alt='#{@alt}' />"""
        else
          """<img src='#{resized_url}' />"""
        end
      else
        ""
      end
    end
  end

  Liquid::Template.register_tag('image',   Jekyll::PostImage)

end
