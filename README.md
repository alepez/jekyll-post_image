jekyll-post_image
=================

Jekyll plugin: resize images automatically to fit post size

Usage:
------

Specify wanted dimension in `_config.yml`

    post_image:
        dimensions: '870x'

Put this tag in posts where you need it:

     {% image filename.ext "Alternative text" %}

Example:
--------

In post `_posts/2013-04-25-foo-bar.md`, write this

    {% image my-portrait.jpg "My portrait" %}

Jekyll searches for image source in `_assets/2013-04-25-foo-bar/my-portrait.jpg`
puts a resized image in `assets/2013-04-25-foo-bar/my-portrait.jpg` and replace
the tag with an `img` tag.

Notes:
------

Adding `assets` in `.gitignore` avoid git tracking of automatically created images.
