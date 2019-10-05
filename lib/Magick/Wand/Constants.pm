package Magick::Wand::Constants;

use warnings;
use strict;

use parent 'Exporter';

use Magick::Wand::API;
use Hash::Util qw/lock_hash_recurse/;

sub enum { my $i = 0; map {$_ => $i++} @_ }

use namespace::clean;

our %const;

BEGIN {
  %const = (
    MagickBooleanType => {enum qw/
      MagickFalse
      MagickTrue
    /},

    ImageType => {enum qw/
      UndefinedType
      BilevelType
      GrayscaleType
      GrayscaleMatteType
      PaletteType
      PaletteMatteType
      TrueColorType
      TrueColorMatteType
      ColorSeparationType
      ColorSeparationMatteType
      OptimizeType
      PaletteBilevelMatteType
    /},

    InterlaceType => {enum qw/
      UndefinedInterlace
      NoInterlace
      LineInterlace
      PlaneInterlace
      PartitionInterlace
      GIFInterlace
      JPEGInterlace
      PNGInterlace
    /},

    OrientationType => {enum qw/
      UndefinedOrientation
      TopLeftOrientation
      TopRightOrientation
      BottomRightOrientation
      BottomLeftOrientation
      LeftTopOrientation
      RightTopOrientation
      RightBottomOrientation
      LeftBottomOrientation
    /},

    ResolutionType => {enum qw/
      UndefinedResolution
      PixelsPerInchResolution
      PixelsPerCentimeterResolution
    /},

    NoiseType => {enum qw/
      UndefinedNoise
      UniformNoise
      GaussianNoise
      MultiplicativeGaussianNoise
      ImpulseNoise
      LaplacianNoise
      PoissonNoise
      RandomNoise
    /},

    CompositeOperator => {enum qw/
      UndefinedCompositeOp
      AlphaCompositeOp
      AtopCompositeOp
      BlendCompositeOp
      BlurCompositeOp
      BumpmapCompositeOp
      ChangeMaskCompositeOp
      ClearCompositeOp
      ColorBurnCompositeOp
      ColorDodgeCompositeOp
      ColorizeCompositeOp
      CopyBlackCompositeOp
      CopyBlueCompositeOp
      CopyCompositeOp
      CopyCyanCompositeOp
      CopyGreenCompositeOp
      CopyMagentaCompositeOp
      CopyAlphaCompositeOp
      CopyRedCompositeOp
      CopyYellowCompositeOp
      DarkenCompositeOp
      DarkenIntensityCompositeOp
      DifferenceCompositeOp
      DisplaceCompositeOp
      DissolveCompositeOp
      DistortCompositeOp
      DivideDstCompositeOp
      DivideSrcCompositeOp
      DstAtopCompositeOp
      DstCompositeOp
      DstInCompositeOp
      DstOutCompositeOp
      DstOverCompositeOp
      ExclusionCompositeOp
      HardLightCompositeOp
      HardMixCompositeOp
      HueCompositeOp
      InCompositeOp
      IntensityCompositeOp
      LightenCompositeOp
      LightenIntensityCompositeOp
      LinearBurnCompositeOp
      LinearDodgeCompositeOp
      LinearLightCompositeOp
      LuminizeCompositeOp
      MathematicsCompositeOp
      MinusDstCompositeOp
      MinusSrcCompositeOp
      ModulateCompositeOp
      ModulusAddCompositeOp
      ModulusSubtractCompositeOp
      MultiplyCompositeOp
      NoCompositeOp
      OutCompositeOp
      OverCompositeOp
      OverlayCompositeOp
      PegtopLightCompositeOp
      PinLightCompositeOp
      PlusCompositeOp
      ReplaceCompositeOp
      SaturateCompositeOp
      ScreenCompositeOp
      SoftLightCompositeOp
      SrcAtopCompositeOp
      SrcCompositeOp
      SrcInCompositeOp
      SrcOutCompositeOp
      SrcOverCompositeOp
      ThresholdCompositeOp
      VividLightCompositeOp
      XorCompositeOp
      StereoCompositeOp
    /},
  );

  if ($Magick::Wand::API::MAGICK_VERSION >= 0x700) {
    $const{AlphaChannelOption} = {enum qw/
      UndefinedAlphaChannel
      ActivateAlphaChannel
      AssociateAlphaChannel
      BackgroundAlphaChannel
      CopyAlphaChannel
      DeactivateAlphaChannel
      DiscreteAlphaChannel
      DisassociateAlphaChannel
      ExtractAlphaChannel
      OffAlphaChannel
      OnAlphaChannel
      OpaqueAlphaChannel
      RemoveAlphaChannel
      SetAlphaChannel
      ShapeAlphaChannel
      TransparentAlphaChannel
    /};
  }
  else {
    $const{AlphaChannelOption} = {enum qw/
      UndefinedAlphaChannel
      ActivateAlphaChannel
      BackgroundAlphaChannel
      CopyAlphaChannel
      DeactivateAlphaChannel
      ExtractAlphaChannel
      OpaqueAlphaChannel
      ResetAlphaChannel
      SetAlphaChannel
      ShapeAlphaChannel
      TransparentAlphaChannel
      FlattenAlphaChannel
      RemoveAlphaChannel
      AssociateAlphaChannel
      DisassociateAlphaChannel
    /};
  }

  lock_hash_recurse %const;
}


use constant {
  %const,
  map {%$_} grep {ref($_) eq 'HASH'} values %const,
};

our @EXPORT_OK = (
  keys %const,
  map {keys %$_} grep {ref($_) eq 'HASH'} values %const,
);

1;
__END__
=head1 NAME

Magick::Wand::Constants - MagickWand API Constants

=head1 SYNOPSIS

  use Magick::Wand::Constants 'NoiseType';
  ...;
  $wand->add_noise_image(NoiseType->{GaussianNoise}, 1.25);

  use Magick::Wand::Constants 'GaussianNoise';
  ...;
  $wand->add_noise_image(GaussianNoise, 1.25);

=head1 DESCRIPTION

Magick::Wand::Constants exports constants for use with L</Magick::Wand>, which
are mostly enumerations.  For any enumeration, you can import the enumeration
name, which is a constant sub returning a hashref, or you can import specific
values from within any enumeration as a numeric constant.

Why would you use one or the other?  Using a hashref may be easier if you need
to vary at runtime, while using a numeric constant can protect against typos
(moving the failure to startup rather than runtime) if your value is
unchanging.

=head2 ImageMagick 6 Compatibility

Some enums have changed since ImageMagick 6.  We're primarily supporting 7, so
if an enum's name has changed, we prefer the newer name.  The options within
that enum should match the ImageMagick version that we were able to load at
startup (see L<Magick::Wand::API>).

Be aware that this means if you try to import a numeric constant that isn't
present in the loaded version of ImageMagick, you should get a compile-time
error.  Hashref constants, on the other hand, are locked, and will trigger
a run-time error if you try to use a key that isn't present.

=head1 CONSTANTS

This documention only lists the enum names (hashref constants) available, in
part because the keys within them may depend on your environment.  For more
info you can check the module source, ImageMagick and MagickWand documentation,
and their source.

You can display the numeric constants currently available:

  perl -MMagick::Wand::Constants -E 'say for sort keys %{$Magick::Wand::Constants::const{AlphaChannelOption}}'

Substituting C<AlphaChannelOption> with the enum name you'd like to see.

=over

=item AlphaChannelOption

=item CompositeOperator

=item ImageType

=item InterlaceType

=item MagickBooleanType

=item NoiseType

=item OrientationType

=item ResolutionType

=back

=cut
