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

$ffi->custom_type('MagickWand' => {
  native_type => 'opaque',
  native_to_perl => sub { bless \$_[0], 'Magick::Wand' },
  perl_to_native => sub { ${$_[0]} },
});

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
  /;

$ffi->type('int*' => 'ExceptionType_p');

$ffi->custom_type('copied_string' => {
  native_type    => 'opaque',
  native_to_perl => sub {
    my ($ptr) = @_;
    my $str = $ffi->cast('opaque' => 'string', $ptr);
    MagickRelinquishMemory($ptr);
    $str;
  },
});

# Only useful if the size is last arg... hm
my $copy_sized_buffer = sub {
  my ($sub, @args) = @_;
  my $ptr = $sub->(@args, \(my $size));
  my $blob = buffer_to_scalar($ptr, $size);
  MagickRelinquishMemory($ptr);
  $blob;
};

$ffi->attach(@$_)
  for (
  [MagickRelinquishMemory => ['opaque'] => 'opaque'],
  [MagickWandGenesis        => [] => 'void'],
  [IsMagickWandInstantiated => [] => 'MagickBooleanType'],
  [MagickWandTerminus       => [] => 'void'],
  );

package Magick::Wand {
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

  use namespace::clean;

  $ffi->attach(@$_)
    for (
    [[NewMagickWand => 'new']            => [] => 'MagickWand'],
    [[IsMagickWand  => 'is_magick_wand'] => ['MagickWand'] => 'MagickBooleanType'],

    [[CloneMagickWand => 'clone']     => ['MagickWand'] => 'MagickWand'],
    [[ClearMagickWand => 'clear']     => ['MagickWand'] => 'void'],
    [[DestroyMagickWand => 'DESTROY'] => ['MagickWand'] => 'void'],

    # I'm not sure there's a use for these if you stay in MagickWand land?
    # [NewMagickWandFromImage => ['Image'] => 'MagickWand'],
    # [GetImageFromMagickWand => ['MagickWand'] => 'Image'],
    # [MagickDestroyImage     => ['Image'] => 'void'],
    );

  # All of the below are attached as snake_case without 'magick_'
  # MagickReadImage => read_image
  # Let's also try to wrap to hide "outbound args" and things that are weird to perl
  $ffi->attach(@$_)
    for map {$$_[0] = [$$_[0] => methodize($$_[0])]; $_} (
    [MagickGetException     => ['MagickWand', 'ExceptionType_p'] => 'copied_string' => sub {
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

    [MagickNextImage => ['MagickWand'] => 'MagickBooleanType' => \&exception_check],
    [MagickPreviousImage => ['MagickWand'] => 'MagickBooleanType' => \&exception_check],
    [MagickGetNumberImages => ['MagickWand'] => 'size_t'],
    [MagickGetIteratorIndex => ['MagickWand'] => 'ssize_t'],
    [MagickSetIteratorIndex => ['MagickWand', 'ssize_t'] => 'MagickBooleanType', \&exception_check],
    [MagickSetFirstIterator => ['MagickWand'] => 'void'],
    [MagickSetLastIterator => ['MagickWand'] => 'void'],
    [MagickResetIterator => ['MagickWand'] => 'void'],

    [MagickGetImage => ['MagickWand'] => 'MagickWand'],

    [MagickWriteImage => ['MagickWand', 'string'] => 'MagickBooleanType', \&exception_check],

    # my $blob = MagickGetImageBlob($wand); - signature differs because of wrapping
    [MagickGetImageBlob  => ['MagickWand', 'size_t*'] => 'opaque' => $copy_sized_buffer],
    [MagickGetImagesBlob => ['MagickWand', 'size_t*'] => 'opaque' => $copy_sized_buffer],

    [MagickGetImageWidth => ['MagickWand'] => 'int'],
    [MagickGetImageHeight => ['MagickWand'] => 'int'],

    [MagickAddImage => ['MagickWand', 'MagickWand'] => 'MagickBooleanType', \&exception_check],
    [MagickAddNoiseImage => ['MagickWand', 'NoiseType', 'double'] => 'MagickBooleanType', \&exception_check],

    [MagickGetImageFormat => ['MagickWand'] => 'string'],
    [MagickSetImageFormat => ['MagickWand', 'string'] => 'MagickBooleanType', \&exception_check],
    );
}

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
