#!perl
use Test2::V0;
use File::Temp;
use File::Spec::Functions qw/catfile/;

use Magick::Wand;
use Magick::Wand::Constants;

ok my $w = Magick::Wand->new,
  'new wand';

isa_ok $w, 'Magick::Wand';

ok $w->is_magick_wand, 'looks reasonable to the library too';

ok dies {
  $w->read_image("junk_path_$$.png")
}, 'autodies work';

my $scratch = File::Temp->newdir;

ok $w->read_image('logo:'), 'got logo';
ok $w->write_image(catfile($scratch, 'test.png')), 'wrote png';
ok lives { $w->clear }, 'cleared wand';
ok $w->read_image(catfile($scratch, 'test.png')), 'read back png';


ok lives { undef $w }, 'no surprises with DESTROY';
done_testing;
