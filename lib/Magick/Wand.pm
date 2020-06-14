package Magick::Wand;

=head1 NAME

Magick::Wand - ImageMagick's MagickWand, via FFI

=head1 WARNING

We're just getting started here!

MagickWand by way of L<FFI::Platypus>.

Not on CPAN yet and the interface should not be considered stable.

=head1 SYNOPSIS

  use Magick::Wand;

  for my $file (glob '*.jpg') {
    my $w = Magick::Wand->new_from($file);
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

=head2 Errors

MagickWand the library is based around explicitly checking for exceptions after
an operation, while here we try to throw perl exceptions automatically.
MagickWand has the concept of a warning, and right now that's treated equally
with more severe errors.  See also: L</_throw>.

ImageMagick error IDs are classified:

L<https://imagemagick.org/script/exception.php>

=cut

use warnings;
use strict;

use Magick::Wand::API qw/
  $ffi
  copy_sized_buffer
  copy_sized_string_array
/;

use Carp qw/croak/;

use subs qw/
  attach
  method
  demethodize
  autodie
/;

use namespace::clean;

=head1 CLASS METHODS

=head2 new

  my $wand = Magick::Wand->new;

Your basic constructor.

=head2 new_from

=head2 new_from_blob

  my $wand = Magick::Wand->new_from('file.jpg');

Shortcuts for:

  my $wand = Magick::Wand->new->tap(read_image => 'file.jpg');

See also: L</read_image>, L</read_image_blob>

=cut

attach [NewMagickWand => 'new'] => [] => 'MagickWand';

sub new_from      { (ref $_[0] || $_[0])->new->tap(read_image      => $_[1]) }
sub new_from_blob { (ref $_[0] || $_[0])->new->tap(read_image_blob => $_[1]) }

attach [DestroyMagickWand => 'DESTROY'] => ['MagickWand'] => 'void';

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

=cut

sub tap {
  my ($self, $method, @args) = @_;
  $self->$method(@args);
  $self;
}

=head2 clear

Clears the wand of images (and properties?)

=cut

attach [ClearMagickWand => 'clear'] => ['MagickWand'] => 'void';

=head2 clone

Returns a clone of the wand.

=cut

method [CloneMagickWand => 'clone'] => ['MagickWand'] => 'MagickWand';

=head2 get_exception

  my ($xstr, $xid) = $wand->get_exception;

Returns current exception string and exception id, if any. (See L</Errors>)

=cut

attach get_exception => ['MagickWand', 'ExceptionType*'] => 'copied_string' => sub {
  my ($sub, $wand) = @_;
  my $xstr = $sub->($wand, \(my $xid));
  $xid, $xstr;
};

=head2 get_exception_id

  my $xid = $wand->get_exception_id;

Returns current exception id, if any. (See L</Errors>)

=cut

attach get_exception_type => ['MagickWand'] => 'ExceptionType';

=head2 clear_exception

Clears current exception.

=cut

attach clear_exception    => ['MagickWand'] => 'MagickBooleanType';

=head2 read_image

  $wand->read_image('path/to/file.png');
  $wand->read_image('logo:');
  $wand->read_image('http://foo.baz/image.jpg');

Given a file path or URL, attempts to read the image and add its layers to the
wand at the current index.

=cut

method read_image => ['MagickWand', 'string'] => 'MagickBooleanType';

=head2 read_image_blob

  $wand->read_image_blob($binary_string);

The same as L</read_image>, but for data already in memory.

=cut

# $wand->read_image_blob($blob); - sig differs thanks to wrapper, it adds size
method read_image_blob => ['MagickWand', 'string', 'size_t'] => 'MagickBooleanType' => sub {
  (shift)->(@_, length $_[-1]);
};

method [IsMagickWand => 'is_magick_wand'] => ['MagickWand'] => 'MagickBooleanType';

# I'm not sure there's a use for these if you stay in MagickWand land?
# NewMagickWandFromImage => ['Image'] => 'MagickWand';
# GetImageFromMagickWand => ['MagickWand'] => 'Image';
# MagickDestroyImage     => ['Image'] => 'void';
# This "Image" would be a distinct class too.  Getting an image in the wand api
# returns a wand.

=head2 Image Stack

Each Wand holds one or more images, and has an "iterator", which is like the
currently selected image in the stack.  Many operations work on the currently
selected image, or insert new images at the current selection.  This group of
methods deals with the stack.

=head3 next_image

=head3 previous_image

=head3 get_number_images

=head3 get_iterator_index

=head3 set_iterator_index

=head3 set_first_iterator

=head3 set_last_iterator

=head3 reset_iterator

=cut

method next_image         => ['MagickWand'] => 'MagickBooleanType';
method previous_image     => ['MagickWand'] => 'MagickBooleanType';
method get_number_images  => ['MagickWand'] => 'size_t';
method get_iterator_index => ['MagickWand'] => 'ssize_t';
method set_iterator_index => ['MagickWand', 'ssize_t'] => 'MagickBooleanType';
method set_first_iterator => ['MagickWand'] => 'void';
method set_last_iterator  => ['MagickWand'] => 'void';
method reset_iterator     => ['MagickWand'] => 'void';


method get_image => ['MagickWand'] => 'MagickWand';

sub get_image_at { $_[0]->tap(set_iterator_index => $_[1])->get_image }

method write_image => ['MagickWand', 'string'] => 'MagickBooleanType';

# my $blob = $wand->get_image_blob; - signature differs because of wrapping, no size ref req'd
method get_image_blob  => ['MagickWand', 'size_t*'] => 'opaque' => \&copy_sized_buffer;
method get_images_blob => ['MagickWand', 'size_t*'] => 'opaque' => \&copy_sized_buffer;

method add_image => ['MagickWand', 'MagickWand'] => 'MagickBooleanType';

sub add_image_from      { $_[0]->add_image($_[0]->new_from($_[1])) }
sub add_image_from_blob { $_[0]->add_image($_[0]->new_from_blob($_[1])) }

method add_noise_image => ['MagickWand', 'NoiseType', 'double'] => 'MagickBooleanType';


## Property methods

method get_image_width  => ['MagickWand'] => 'int';
method get_image_height => ['MagickWand'] => 'int';

sub get_image_geometry { $_[0]->get_image_width, $_[0]->get_image_height }

method get_image_format => ['MagickWand'] => 'copied_string';
method set_image_format => ['MagickWand', 'string'] => 'MagickBooleanType';

method get_options => ['MagickWand', 'string', 'size_t*'] => 'opaque' => sub {
  push @_, '' if $#_ == 1;  # default for 'string', avoids a segfault
  goto \&copy_sized_string_array;
};

sub get_options_hash {
  my ($self, $pattern) = @_;
  return {
    map {$_ => $self->get_option($_)} $self->get_options($pattern)
  };
}

method get_option => ['MagickWand', 'string'] => 'copied_string' => sub {
  return undef unless defined $_[2];
  goto shift;
};

method get_image_properties => ['MagickWand', 'string', 'size_t*'] => 'opaque' => sub {
  push @_, '' if $#_ == 1;  # default for 'string', avoids a segfault
  goto \&copy_sized_string_array;
};

sub get_image_properties_hash {
  my ($self, $pattern) = @_;
  return {
    map {$_ => $self->get_image_property($_)} $self->get_image_properties($pattern)
  };
}

method get_image_property => ['MagickWand', 'string'] => 'copied_string' => sub {
  return undef unless defined $_[2];
  goto shift;
};


## Image Methods

method auto_orient_image => ['MagickWand'] => 'MagickBooleanType';

method merge_image_layers => ['MagickWand', 'LayerMethod'] => 'MagickWand';

# TODO: command line and perlmagick have alternate syntax for specifying
# geometry, i should try for that too

method minify_image => ['MagickWand'] => 'MagickBooleanType';

method resize_image   => ['MagickWand', 'size_t', 'size_t', 'FilterType'] => 'MagickBooleanType';

method resample_image => ['MagickWand', 'size_t', 'size_t'] => 'MagickBooleanType';

method sample_image   => ['MagickWand', 'size_t', 'size_t'] => 'MagickBooleanType';

method scale_image    => ['MagickWand', 'size_t', 'size_t'] => 'MagickBooleanType';

method thumbnail_image => ['MagickWand', 'size_t', 'size_t'] => 'MagickBooleanType';


=head1 PRIVATE METHODS

=head2 _throw

This method is called to throw an exception, its default behavior is to croak.
You can create a subclass that overrides C<_throw>.

=cut

sub _throw {
  my ($self, $xid, $xstr) = @_;
  croak "ImageMagick Exception $xid: $xstr";
}


## Convenience functions, these are namespace::cleaned

# Shortcut for ffi attach
sub attach {
  my ($name, @etc) = @_;
  $ffi->attach(ref $name ? $name : [demethodize($name) => $name], @etc);
}

# attach, but wrappped in autodie
sub method {
  my ($name, @sig) = @_;
  my $wrapper = (ref $sig[-1] eq 'CODE') && pop @sig;

  $wrapper =
    $wrapper
    ? sub { autodie($wrapper, @_) }
    : \&autodie;

  attach $name, @sig, $wrapper;
}

sub demethodize {
  my $name = shift;
  return 'Magick' . join '', map { ucfirst lc } split '_', $name;
}

sub autodie {
  my ($sub, $wand, @args) = @_;
  my $rv = $sub->($wand, @args);

  my ($xid, $xstr) = $wand->get_exception;
  if ($xid) {
    $wand->clear_exception;
    $wand->throw($xid, $xstr);
  }

  return $rv;
}

1;
__END__

=head1 AUTHOR

Meredith Howard <mhoward@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2020 by Meredith Howard.

This is free software; you can redistribute it and/or modify it under the same
terms as the Perl 5 programming language system itself.

=cut
