package Magick::Wand;

use warnings;
use strict;

use Magick::Wand::API qw/$ffi/;

sub methodize;
sub exception_check;
sub copy_sized_buffer;

use namespace::clean;

$ffi->attach(@$_)
  for (
  [[NewMagickWand => 'new']            => [] => 'MagickWand'],
  [[IsMagickWand  => 'is_magick_wand'] => ['MagickWand'] => 'MagickBooleanType'],

  [[CloneMagickWand   => 'clone']     => ['MagickWand'] => 'MagickWand'],
  [[ClearMagickWand   => 'clear']     => ['MagickWand'] => 'void'],
  [[DestroyMagickWand => 'DESTROY'] => ['MagickWand'] => 'void'],

  # I'm not sure there's a use for these if you stay in MagickWand land?
  # [NewMagickWandFromImage => ['Image'] => 'MagickWand'],
  # [GetImageFromMagickWand => ['MagickWand'] => 'Image'],
  # [MagickDestroyImage     => ['Image'] => 'void'],
  );

# All of the below are attached as snake_case without 'magick_'
# so MagickReadImage => installed as 'read_image'
# Let's also try to wrap to hide "outbound args" and things that are weird to perl

$ffi->attach(@$_)
  for map {$$_[0] = [$$_[0] => methodize($$_[0])]; $_} (
  [MagickGetException     => ['MagickWand', 'ExceptionType*'] => 'copied_string' => sub {
    my ($sub, $wand) = @_;
    my $xstr = $sub->($wand, \(my $xid));
    $xid, $xstr;
  }],
  [MagickGetExceptionType => ['MagickWand'] => 'ExceptionType'],
  [MagickClearException   => ['MagickWand'] => 'MagickBooleanType'],

  [MagickReadImage => ['MagickWand', 'string'] => 'MagickBooleanType', \&exception_check],
  [MagickReadImageBlob => ['MagickWand', 'string', 'size_t'] => 'MagickBooleanType' => sub {
    exception_check(@_, length $_[-1]);
  }],

  [MagickNextImage        => ['MagickWand'] => 'MagickBooleanType' => \&exception_check],
  [MagickPreviousImage    => ['MagickWand'] => 'MagickBooleanType' => \&exception_check],
  [MagickGetNumberImages  => ['MagickWand'] => 'size_t'],
  [MagickGetIteratorIndex => ['MagickWand'] => 'ssize_t'],
  [MagickSetIteratorIndex => ['MagickWand', 'ssize_t'] => 'MagickBooleanType', \&exception_check],
  [MagickSetFirstIterator => ['MagickWand'] => 'void'],
  [MagickSetLastIterator  => ['MagickWand'] => 'void'],
  [MagickResetIterator    => ['MagickWand'] => 'void'],

  [MagickGetImage => ['MagickWand'] => 'MagickWand'],

  [MagickWriteImage => ['MagickWand', 'string'] => 'MagickBooleanType', \&exception_check],

  # my $blob = MagickGetImageBlob($wand); - signature differs because of wrapping
  [MagickGetImageBlob  => ['MagickWand', 'size_t*'] => 'opaque' => \&copy_sized_buffer],
  [MagickGetImagesBlob => ['MagickWand', 'size_t*'] => 'opaque' => \&copy_sized_buffer],

  [MagickGetImageWidth  => ['MagickWand'] => 'int'],
  [MagickGetImageHeight => ['MagickWand'] => 'int'],

  [MagickAddImage      => ['MagickWand', 'MagickWand'] => 'MagickBooleanType', \&exception_check],
  [MagickAddNoiseImage => ['MagickWand', 'NoiseType', 'double'] => 'MagickBooleanType', \&exception_check],

  [MagickGetImageFormat => ['MagickWand'] => 'string'],
  [MagickSetImageFormat => ['MagickWand', 'string'] => 'MagickBooleanType', \&exception_check],

  # TODO: command line and perlmagick have alternate syntax for specifying
  # geometry, i should try for that too
  [MagickResizeImage => ['MagickWand', 'size_t', 'size_t', 'FilterType'] => 'MagickBooleanType', \&exception_check],
  );

sub tap {
  my ($self, $method, @args) = @_;
  $self->$method(@args);
  $self;
}

sub new_from      { $_[0]->new->tap(read_image      => $_[1]) }
sub new_from_blob { $_[0]->new->tap(read_image_blob => $_[1]) }


## Convenience functions, scrubbed from namespace

sub methodize {
  my $name = $_[0]; $name =~ s/^Magick//;
  join '_', map {lc} grep {length} split /([A-Z][^A-Z]*)/, $name;
}

sub exception_check {
  my ($sub, $wand, @args) = @_;
  my $rv = $sub->($wand, @args);
  return $rv if $rv;

  my ($xid, $xstr) = $wand->get_exception;
  return $rv unless $xid;  # no exception, just a falsey result

  $wand->clear_exception;
  die "ImageMagick Exception $xid: $xstr"; # TODO: Exception class?
};

# Only useful if the size is last arg... hm
sub copy_sized_buffer {
  my ($sub, @args) = @_;
  my $ptr = $sub->(@args, \(my $size));
  my $blob = buffer_to_scalar($ptr, $size);
  Magick::Wand::API::MagickRelinquishMemory($ptr);
  $blob;
};

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

=head1 BEHAVIOR

=head2 Image Stack

Each Wand holds one or more images, and has an "iterator", which is like the
currently selected image in the stack.  Many operations work on the currently
selected image, or insert new images at the current selection.  There is
a group of methods dealing with this:

L</next_image>, L</previous_image>, L</get_number_images>,
L</get_iterator_index>, L</set_iterator_index>, L</set_first_iterator>,
L</set_last_iterator>, L</reset_iterator>

=head2 Errors

Magick::Wand throws exceptions on error.  MagickWand has the concept of
a warning, and I still need to sort out how that is handled.

ImageMagick error IDs are classified:

L<https://imagemagick.org/script/exception.php>

=head1 CLASS METHODS

=head2 new

  my $wand = Magick::Wand->new;

Your basic constructor.

=head2 new_from

=head2 new_from_blob

  my $wand = Magick::Wand->new_from('file.jpg');

Shortcuts for:

  my $wand = Magick::Wand->new->tap(read_image => 'file.jpg');

=head1 METHODS

We do some light wrapping to hide things that aren't very Perlish, but for the
most part, methods are literally those provided by MagickWand.  If you need
more insight about anything, check out the library documentation:

L<https://imagemagick.org/script/magick-wand.php>

=head2 tap

  $wand = $wand->tap(method => @args);

This C<tap> method is included to make chaining easier.

  Magick::Wand->new
    ->tap(read_image => 'logo:')
    ->tap(gaussian_blur_image => 2, 0.25)
    ->write_image('logo.jpg');

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

Returns current exception string and exception id, if any. (See L</Errors>)

=head2 get_exception_id

  my $xid = $wand->get_exception_id;

Returns current exception id, if any. (See L</Errors>)

=head2 clear_exception

Clears current exception.

...

=head1 AUTHOR

Meredith Howard <mhoward@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2019 by Meredith Howard.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
