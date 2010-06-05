use strict;
use warnings;
use Test::More;
use Plack::Util;
use Plack::Middleware::Lint;
use Test::WWW::Mechanize::PSGI;

my $app = Plack::Util::load_psgi('gyazo.psgi') // die;
$app = Plack::Middleware::Lint->wrap($app);

my $ONE_DOT_PNG =
  (     "\x89\x50\x4e\x47\x0d\x0a\x1a\x0a\x00\x00\x00\x0d\x49\x48\x44\x52\x00"
      . "\x00\x00\x01\x00\x00\x00\x01\x01\x03\x00\x00\x00\x25\xdb\x56\xca\x00"
      . "\x00\x00\x06\x50\x4c\x54\x45\xff\xff\xff\x00\x00\x00\x55\xc2\xd3\x7e"
      . "\x00\x00\x00\x0a\x49\x44\x41\x54\x78\xda\x63\x60\x00\x00\x00\x02\x00"
      . "\x01\xe5\x27\xde\xfc\x00\x00\x00\x00\x49\x45\x4e\x44\xae\x42\x60\x82"
  );

my $mech = Test::WWW::Mechanize::PSGI->new(
    app => $app,
);
$mech->get_ok('/', 'top');
$mech->post_ok('/upload', {imagedata => $ONE_DOT_PNG});
$mech->get_ok($mech->content);
is($mech->content, $ONE_DOT_PNG);
done_testing;
