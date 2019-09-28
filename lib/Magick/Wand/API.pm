package Magick::Wand::API;

use warnings;
use strict;

use File::Spec::Functions qw/catfile/;
use FFI::CheckLib qw/find_lib/;
use FFI::Platypus;
use FFI::Platypus::Buffer qw/buffer_to_scalar/;

use namespace::clean;

my $ffi = FFI::Platypus->new;

$ffi->lib(locate_libs());

our $MAGICK_VERSION;  # < 0x700
$ffi->function(GetMagickVersion => ['size_t*'] => 'string')->call(\$MAGICK_VERSION);

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
  my $rv = $sub->($wand, @args);
  return $rv if $rv;

  my ($xid, $xstr);
  $xstr = MagickGetException($wand, \$xid);
  MagickClearException($wand);
  die "ImageMagick Exception $xid: $xstr"; # TODO: Exception class once we pull moo in?
};

$ffi->attach(MagickRelinquishMemory => ['opaque'] => 'opaque');

$ffi->custom_type('copied_string' => {
  native_type    => 'opaque',
  native_to_perl => sub {
    my ($ptr) = @_;
    my $str = $ffi->cast('opaque' => 'string', $ptr);
    MagickRelinquishMemory($ptr);
    $str;
  },
});

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

  [MagickGetException => ['MagickWand', 'ExceptionType_p'] => 'copied_string'],
  [MagickGetExceptionType => ['MagickWand'] => 'ExceptionType'],
  [MagickClearException => ['MagickWand'] => 'MagickBooleanType'],

  [MagickReadImage => ['MagickWand', 'string'] => 'MagickBooleanType', $exception_check],
  [MagickReadImageBlob => ['MagickWand', 'string', 'size_t' ] => 'MagickBooleanType', $exception_check],

  [MagickWriteImage => ['MagickWand', 'string'] => 'MagickBooleanType', $exception_check],

  # my $blob = MagickGetImageBlob($wand); - signature differs because of wrapping
  [MagickGetImageBlob => ['MagickWand', 'size_t*'] => 'opaque' => sub {
    my ($sub, $wand) = @_;
    my $ptr = $sub->($wand, \(my $size));
    my $blob = buffer_to_scalar($ptr, $size);
    MagickRelinquishMemory($ptr);
    $blob;
  }],

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
