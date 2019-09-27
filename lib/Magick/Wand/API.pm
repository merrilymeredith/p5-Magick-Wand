package Magick::Wand::API;

use warnings;
use strict;

use FFI::Platypus;

my $ffi = FFI::Platypus->new;

# TODO: respect MAGICK_HOME
$ffi->find_lib(lib => [map {("MagickCore-$_", "MagickWand-$_")} qw/7.Q16HDRI 7.Q16 7.Q8HDRI 7.Q8 6.Q16HDRI 6.Q16 6.Q8HDRI 6.Q8/]);
# TODO: Don't actually want multiples, probably need to use CheckLib with a prio list


$ffi->type('opaque' => $_) for qw/
  MagickWand
  PixelWand
  /;

$ffi->type('int' => $_) for qw/
  MagickBooleanType
  CompositeOperator
  GravityType
  OrientationType
  InterlaceType
  /;

$ffi->type('int*' => 'ExceptionType_p');

my $exception_check = sub {
  my ($sub, $wand, @args) = @_;
  $sub->($wand, @args) and return;

  my ($xid, $xstr);
  $xstr = MagickGetException($wand, \$xid);
  die "ImageMagick Exception $xid: $xstr"; # TODO: Exception class once we pull moo in?
};

$ffi->attach(@$_)
  for (
  [MagickWandGenesis        => [] => 'void'],
  [IsMagickWandInstantiated => [] => 'MagickBooleanType'],
  [MagickWandTerminus       => [] => 'void'],

  [NewMagickWand     => []             => 'MagickWand'],
  [CloneMagickWand   => ['MagickWand'] => 'MagickWand'],
  [DestroyMagickWand => ['MagickWand'] => 'MagickWand'],

  [MagickRelinquishMemory => ['void*'] => 'void*'],

  [MagickReadImage => ['MagickWand', 'string'] => 'MagickBooleanType', $exception_check],
  [MagickReadImageBlob => ['MagickWand', 'void*', 'size_t' ] => 'MagickBooleanType', $exception_check],

  [MagickWriteImage => ['MagickWand', 'string'] => 'MagickBooleanType', $exception_check],
  [MagickGetImageBlob => ['MagickWand', 'size_t*'] => 'string'], # TODO: Probably need to cast opaque-string then free?

  [MagickGetException => ['MagickWand', 'ExceptionType_p'] => 'string'],

  [MagickGetImageWidth => ['MagickWand'] => 'int'],
  [MagickGetImageHeight => ['MagickWand'] => 'int'],

  [MagickAddImage => ['MagickWand', 'MagickWand'] => 'MagickBooleanType', $exception_check],

  [MagickGetImageFormat => ['MagickWand'] => 'string'],
  [MagickSetImageFormat => ['MagickWand', 'string'] => 'MagickBooleanType', $exception_check],

  );

# Do this on first -new?
MagickWandGenesis() unless IsMagickWandInstantiated();

END { MagickWandTerminus() if IsMagickWandInstantiated(); };

1;
