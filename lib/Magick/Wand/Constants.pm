package Magick::Wand::Constants;

use warnings;
use strict;

use parent 'Exporter';

sub enum { my $i = 0; map {$_ => $i++} @_ }

our %const;

BEGIN {
  %const = (
    MagickBooleanType => {enum qw/
      MagickFalse
      MagickTrue
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
