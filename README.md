# NAME

Magick::Wand - ImageMagick's MagickWand, via FFI

# WARNING

We're just getting started here!

MagickWand by way of [FFI::Platypus](https://metacpan.org/pod/FFI::Platypus).

Not on CPAN yet and the interface should not be considered stable.

# SYNOPSIS

use Magick::Wand;

for my $file (glob '\*.jpg') {
  my $w = Magick::Wand->new;
  $w->read\_image($file);
  $w->auto\_orient\_image;
  $w->write\_image($file);
}

# DESCRIPTION

MagickWand is the library and API that ImageMagick recommends for use.
`Magick::Wand` is an interface to MagickWand using [FFI::Platypus](https://metacpan.org/pod/FFI::Platypus).
MagickWand is an object-like pattern so it maps nicely to one Perl object per
instance of a Wand.

Unlike PerlMagick (aka [Image::Magick](https://metacpan.org/pod/Image::Magick)), Magick::Wand does not itself need
a C compiler, nor is it bundled into the ImageMagick source distribution and
tied to specific versions of ImageMagick - all troublesome when working on
Windows.

# IMAGE STACK

Each Wand holds one or more images, and has an "iterator", which is like the
currently selected image in the stack.  Many operations work on the currently
selected image, or insert new images at the current selection.  There is
a group of methods dealing with this:

["next\_image"](#next_image), ["previous\_image"](#previous_image), ["get\_iterator\_index"](#get_iterator_index),
["set\_iterator\_index"](#set_iterator_index), ["set\_first\_iterator"](#set_first_iterator), ["set\_last\_iterator"](#set_last_iterator),
["reset\_iterator"](#reset_iterator)

# ERRORS

Magick::Wand throws exceptions on error.  MagickWand has the concept of
a warning, and I still need to sort out how that is handled.

ImageMagick error IDs are classified:

[https://imagemagick.org/script/exception.php](https://imagemagick.org/script/exception.php)

# CLASS METHODS

## new

    my $wand = Magick::Wand->new;

Your basic constructor.

# METHODS

We do some light wrapping to hide things that aren't very Perlish, but for the
most part, methods are literally those provided by MagickWand.  If you need
more insight about anything, check out the library documentation:

[https://imagemagick.org/script/magick-wand.php](https://imagemagick.org/script/magick-wand.php)

## clear

Clears the wand of images (and properties?)

## clone

Returns a clone of the wand.

## read\_image

    $wand->read_image('path/to/file.png');
    $wand->read_image('logo:');
    $wand->read_image('http://foo.baz/image.jpg');

Given a file path or URL, attempts to read the image and add its layers to the
wand at the current index.

## read\_image\_blob

    $wand->read_image_blob($binary_string);

The same as ["read\_image"](#read_image), but for data already in memory.

## get\_exception

    my ($xstr, $xid) = $wand->get_exception;

Returns current exception string and exception id, if any. (See ["ERRORS"](#errors))

## get\_exception\_id

    my $xid = $wand->get_exception_id;

Returns current exception id, if any. (See ["ERRORS"](#errors))

## clear\_exception

Clears current exception.

...
