#!perl

use Test2::V0;

use Magick::Wand;

ok my $w = Magick::Wand->new,
  'new';

isa_ok $w, 'Magick::Wand';

ok $w->IsMagickWand, 'looks reasonable to the library too';

ok dies {
  $w->read_image("junk_path_$$.png")
}, 'autodies work';

# write an image then clear then read?

ok lives { undef $w }, 'no surprises with DESTROY';

done_testing;
