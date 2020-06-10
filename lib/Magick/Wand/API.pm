package Magick::Wand::API;

use warnings;
use strict;

use parent 'Exporter';

use File::Spec::Functions qw/catfile/;
use FFI::CheckLib qw/find_lib/;
use FFI::Platypus;

use namespace::clean;

our @EXPORT_OK = qw/$ffi/;

our $ffi = FFI::Platypus->new(api => 1);

$ffi->lib(locate_libs());

our $MAGICK_VERSION;  # < 0x700
$ffi->function(GetMagickVersion => ['size_t*'] => 'string')->call(\$MAGICK_VERSION);

$ffi->type('object(Magick::Wand)' => 'MagickWand');

$ffi->type('opaque' => $_) for qw/
  Image
  PixelWand
  /;

$ffi->type('int' => $_) for qw/
  CompositeOperator
  ExceptionType
  GravityType
  InterlaceType
  MagickBooleanType
  OrientationType
  NoiseType
  FilterType
  /;

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
  [MagickRelinquishMemory => ['opaque'] => 'opaque'],
  [MagickWandGenesis        => [] => 'void'],
  [IsMagickWandInstantiated => [] => 'MagickBooleanType'],
  [MagickWandTerminus       => [] => 'void'],
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
