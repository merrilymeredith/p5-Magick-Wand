package Magick::Wand::API;

use warnings;
use strict;

use File::Spec::Functions qw/catfile/;
use FFI::CheckLib qw/find_lib/;
use FFI::Platypus;

use namespace::clean;

my $ffi = FFI::Platypus->new;

$ffi->lib(locate_libs());

$ffi->type('opaque' => $_) for qw/
  MagickWand
  PixelWand
  /;

$ffi->type('int' => $_) for qw/
  CompositeOperator
  ExceptionType
  GravityType
  InterlaceType
  MagickBooleanType
  OrientationType
  /;

$ffi->type('int*' => 'ExceptionType_p');

my $exception_check = sub {
  my ($sub, $wand, @args) = @_;
  $sub->($wand, @args) and return;

  my ($xid, $xstr);
  $xstr = MagickGetException($wand, \$xid);  # TODO: this returns a string that FFI copies but we still need to release the memory of the returned string.
  MagickClearException($wand);
  die "ImageMagick Exception $xid: $xstr"; # TODO: Exception class once we pull moo in?
};

$ffi->attach(@$_)
  for (
  [MagickWandGenesis        => [] => 'void'],
  [IsMagickWandInstantiated => [] => 'MagickBooleanType'],
  [MagickWandTerminus       => [] => 'void'],

  [NewMagickWand     => []             => 'MagickWand'],
  [IsMagickWand      => ['MagickWand'] => 'MagickBooleanType'],
  [CloneMagickWand   => ['MagickWand'] => 'MagickWand'],
  [ClearMagickWand   => ['MagickWand'] => 'void'],
  [DestroyMagickWand => ['MagickWand'] => 'MagickWand'],

  [MagickGetException => ['MagickWand', 'ExceptionType_p'] => 'string'],
  [MagickGetExceptionType => ['MagickWand'] => 'ExceptionType'],
  [MagickClearException => ['MagickWand'] => 'MagickBooleanType'],

  [MagickRelinquishMemory => ['void*'] => 'void*'],

  [MagickReadImage => ['MagickWand', 'string'] => 'MagickBooleanType', $exception_check],
  [MagickReadImageBlob => ['MagickWand', 'void*', 'size_t' ] => 'MagickBooleanType', $exception_check],

  [MagickWriteImage => ['MagickWand', 'string'] => 'MagickBooleanType', $exception_check],
  [MagickGetImageBlob => ['MagickWand', 'size_t*'] => 'string'], # TODO: Probably need to cast opaque-string then free?

  [MagickGetImageWidth => ['MagickWand'] => 'int'],
  [MagickGetImageHeight => ['MagickWand'] => 'int'],

  [MagickAddImage => ['MagickWand', 'MagickWand'] => 'MagickBooleanType', $exception_check],

  [MagickGetImageFormat => ['MagickWand'] => 'string'],
  [MagickSetImageFormat => ['MagickWand', 'string'] => 'MagickBooleanType', $exception_check],

  );

#TODO:
# - is this type of search slow?
# - Wonder if i could dump every permutation in then pick the first two.
# - Someone may want to force a specific suffix.
sub locate_libs {
  my @priority =
    qw/7.Q16HDRI 7.Q16 7.Q8HDRI 7.Q8 6.Q16HDRI 6.Q16 6.Q8HDRI 6.Q8/;

  my @findopts = !$ENV{MAGICK_HOME} ? () : (
    systempath => [],
    libpath    => $ENV{MAGICK_HOME},
  );

  if ($^O eq 'MSWin32') {
    return find_lib(
      lib => ['CORE_RL_magick_', 'CORE_RL_wand_'],
      @findopts,
    );
  }
  else {
    for my $suffix (@priority) {
      my @libs = find_lib(
        lib => ["MagickCore-$suffix", "MagickWand-$suffix"],
        @findopts,
      );

      return @libs if @libs;
    }
  }

  die "No suitable MagickWand library found";
}

# Do this on first -new?
MagickWandGenesis() unless IsMagickWandInstantiated();

END {
  # We play it careful so we don't make noise if no library was loaded at all.
  if (my $f = __PACKAGE__->can('IsMagickWandInstantiated')) {
    MagickWandTerminus() if $f->();
  }
};

1;
