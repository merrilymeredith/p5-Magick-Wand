#!perl

use Test2::V0;

use Magick::Wand;

ok my $w = Magick::Wand::API::NewMagickWand(),
  'NewMagickWand';

ok !Magick::Wand::API::DestroyMagickWand($w),
  'DestroyMagickWand';

done_testing;
