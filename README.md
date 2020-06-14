# NAME

Magick::Wand - ImageMagick's MagickWand, via FFI

# WARNING

We're just getting started here!

MagickWand by way of [FFI::Platypus](https://metacpan.org/pod/FFI%3A%3APlatypus).

Not on CPAN yet and the interface should not be considered stable.

# SYNOPSIS

    use Magick::Wand;

    for my $file (glob '*.jpg') {
      my $w = Magick::Wand->new_from($file);
      $w->auto_orient_image;
      $w->write_image($file);
    }

# DESCRIPTION

MagickWand is the library and API that ImageMagick recommends for use.
`Magick::Wand` is an interface to MagickWand using [FFI::Platypus](https://metacpan.org/pod/FFI%3A%3APlatypus).
MagickWand is an object-like pattern so it maps nicely to one Perl object per
instance of a Wand.

Unlike PerlMagick (aka [Image::Magick](https://metacpan.org/pod/Image%3A%3AMagick)), Magick::Wand does not itself need
a C compiler, nor is it bundled into the ImageMagick source distribution and
tied to specific versions of ImageMagick - all troublesome when working on
Windows.

# BEHAVIOR

## Errors

MagickWand the library is based around explicitly checking for exceptions after
an operation, while here we try to throw perl exceptions automatically.
MagickWand has the concept of a warning, and right now that's treated equally
with more severe errors.  See also: ["\_throw"](#_throw).

ImageMagick error IDs are classified:

[https://imagemagick.org/script/exception.php](https://imagemagick.org/script/exception.php)

# CLASS METHODS

## new

    my $wand = Magick::Wand->new;

Your basic constructor.

## new\_from

## new\_from\_blob

    my $wand = Magick::Wand->new_from('file.jpg');

Shortcuts for:

    my $wand = Magick::Wand->new->tap(read_image => 'file.jpg');

See also: ["read\_image"](#read_image), ["read\_image\_blob"](#read_image_blob)

# METHODS

We do some light wrapping to hide things that aren't very Perlish, but for the
most part, methods are literally those provided by MagickWand.  If you need
more insight about anything, check out the library documentation:

[https://imagemagick.org/script/magick-wand.php](https://imagemagick.org/script/magick-wand.php)

## tap

    $wand = $wand->tap(method => @args);

This `tap` method is included to make chaining easier.

    Magick::Wand->new
      ->tap(read_image => 'logo:')
      ->tap(gaussian_blur_image => 2, 0.25)
      ->write_image('logo.jpg');

## clear

Clears the wand of images (and properties?)

## clone

Returns a clone of the wand.

## get\_exception

    my ($xstr, $xid) = $wand->get_exception;

Returns current exception string and exception id, if any. (See ["Errors"](#errors))

## get\_exception\_id

    my $xid = $wand->get_exception_id;

Returns current exception id, if any. (See ["Errors"](#errors))

## clear\_exception

Clears current exception.

## read\_image

    $wand->read_image('path/to/file.png');
    $wand->read_image('logo:');
    $wand->read_image('http://foo.baz/image.jpg');

Given a file path or URL, attempts to read the image and add its layers to the
wand at the current index.

## read\_image\_blob

    $wand->read_image_blob($binary_string);

The same as ["read\_image"](#read_image), but for data already in memory.

## Image Stack

Each Wand holds one or more images, and has an "iterator", which is like the
currently selected image in the stack.  Many operations work on the currently
selected image, or insert new images at the current selection.  This group of
methods deals with the stack.

### next\_image

### previous\_image

### get\_number\_images

### get\_iterator\_index

### set\_iterator\_index

### set\_first\_iterator

### set\_last\_iterator

### reset\_iterator

# PRIVATE METHODS

## \_throw

This method is called to throw an exception, its default behavior is to croak.
You can create a subclass that overrides `_throw`.

# AUTHOR

Meredith Howard <mhoward@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2020 by Meredith Howard.

This is free software; you can redistribute it and/or modify it under the same
terms as the Perl 5 programming language system itself.
