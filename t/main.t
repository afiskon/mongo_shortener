use Mojo::Base -strict;

use Test::More;
use Test::Mojo;
use Test::MockObject;

$ENV{'MONGO_SHORTENER_HOME_URL'} = 'http://localhost/';

my $mock = Test::MockObject->new();
$mock->fake_module(
    'MongoDB::Connection',
    'new' => sub { $mock },
  );

$mock->mock(
    $_ => sub { $mock },
  ) for qw/urls ensure_index insert get_database/;

my $t = Test::Mojo->new('MongoShortener');
$t->get_ok('/')->status_is(200);

$t->post_form_ok('/')
  ->status_is(200)
  ->content_unlike(qr{http://localhost/[a-zA-Z0-9_\-]+});

for my $protocol (qw/http https ftp ftps/) {
  $t->post_form_ok('/', { url => $protocol.'://example.ru/' } )
    ->status_is(200)
    ->content_like(qr{http://localhost/[a-zA-Z0-9_\-]+});
}

for my $url ("example.ru", " \texample.ru\t ", "  http://example.ru/  ") {
  $t->post_form_ok('/', { url => $url } )
   ->status_is(200)
   ->content_like(qr{http://localhost/[a-zA-Z0-9_\-]+});
}

$mock->mock(find_one => sub { undef });
$t->get_ok('/3_jIY-I')->status_is(302)->header_is(Location => 'http://localhost/');

$mock->mock(find_one => sub { { url => 'http://example.ru/' } });
$t->get_ok('/3_jIY-I')->status_is(302)->header_is(Location => 'http://example.ru/');

$mock->mock(insert => sub { die });
$t->post_form_ok('/', { url => 'http://example.ru/' } )
  ->status_is(200)
  ->content_unlike(qr{http://localhost/[a-zA-Z0-9_\-]+});

done_testing();
