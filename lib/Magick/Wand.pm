package Magick::Wand;

use warnings;
use strict;

use Magick::Wand::API;
use Magick::Wand::Constants ':all';

1;
__END__
=head1 NAME

Magick::Wand - ImageMagick's MagickWand, via FFI

=head1 WARNING

We're just getting started here!

MagickWand by way of L<FFI::Platypus>.

Not on CPAN yet and the interface should not be considered stable.

=head1 SYNOPSIS

  use Magick::Wand;

  for my $file (glob '*.jpg') {
    my $w = Magick::Wand->new;
    $w->read_image($file);
    $w->auto_orient_image;
    $w->write_image($file);
  }

=head1 DESCRIPTION

MagickWand is the library and API that ImageMagick recommends for use.
C<Magick::Wand> is an interface to MagickWand using L<FFI::Platypus>.
MagickWand is an object-like pattern so it maps nicely to one Perl object per
instance of a Wand.

Unlike PerlMagick (aka L<Image::Magick>), Magick::Wand does not itself need
a C compiler, nor is it bundled into the ImageMagick source distribution and
tied to specific versions of ImageMagick - all troublesome when working on
Windows.

=head1 IMAGE STACK

Each Wand holds one or more images, and has an "iterator", which is like the
currently selected image in the stack.  Many operations work on the currently
selected image, or insert new images at the current selection.  There is
a group of methods dealing with this:

L</next_image>, L</previous_image>, L</get_iterator_index>,
L</set_iterator_index>, L</set_first_iterator>, L</set_last_iterator>,
L</reset_iterator>

=head1 ERRORS

Magick::Wand throws exceptions on error.  MagickWand has the concept of
a warning, and I still need to sort out how that is handled.

ImageMagick error IDs are classified:

L<https://imagemagick.org/script/exception.php>

=head1 CLASS METHODS

=head2 new

  my $wand = Magick::Wand->new;

Your basic constructor.

=head1 METHODS

We do some light wrapping to hide things that aren't very Perlish, but for the
most part, methods are literally those provided by MagickWand.  If you need
more insight about anything, check out the library documentation:

L<https://imagemagick.org/script/magick-wand.php>

=head2 clear

Clears the wand of images (and properties?)

=head2 clone

Returns a clone of the wand.

=head2 read_image

  $wand->read_image('path/to/file.png');
  $wand->read_image('logo:');
  $wand->read_image('http://foo.baz/image.jpg');

Given a file path or URL, attempts to read the image and add its layers to the
wand at the current index.

=head2 read_image_blob

  $wand->read_image_blob($binary_string);

The same as L</read_image>, but for data already in memory.

=head2 get_exception

  my ($xstr, $xid) = $wand->get_exception;

Returns current exception string and exception id, if any. (See L</ERRORS>)

=head2 get_exception_id

  my $xid = $wand->get_exception_id;

Returns current exception id, if any. (See L</ERRORS>)

=head2 clear_exception

Clears current exception.

...

=cut
