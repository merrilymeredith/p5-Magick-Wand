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
  my $VERSION = $Magick::Wand::API::MAGICK_VERSION;

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

  if ($VERSION >= 0x700) {
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
  map {%$_} grep {(ref($_) // '') eq 'HASH'} values %const,
};

our @EXPORT_OK = (
  keys %const,
  map {keys %$_} grep {(ref($_) // '') eq 'HASH'} values %const,
);

1;
