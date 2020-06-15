#!perl
use Test2::V0;

use Magick::Wand;

subtest 'false-not-always-an-exception' => sub {
  my $w = Magick::Wand->new;

  ok dies { $w->next_image },
    'next_image is an exception when empty';

  $w->read_image('logo:');

  ok lives { $w->next_image; $w->next_image },
    'but not an exception when false and looping around';
};

subtest 'override-throw' => sub {
  package My::Wand {
    use parent 'Magick::Wand';
    sub new {
      my $class = shift;
      bless $class->next::method(@_), (ref $class || $class);
    };
    sub _throw { return }
  }

  my $w = My::Wand->new;
  ok lives { $w->next_image },
    'in our subclass, autodie is suppressed';

  ok lives { $w->add_image_from("junk_path_$$.png") },
    'no accidental parent classes throwing exceptions';
};

done_testing;
