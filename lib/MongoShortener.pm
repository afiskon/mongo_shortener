package MongoShortener;
use Mojo::Base 'Mojolicious';

sub startup {
  my $self = shift;

  my $r = $self->routes;

  $r->get('/')->to('main#get_main');
  $r->post('/')->to('main#post_main');
  $r->route('/:short_url', short_url => qr/[a-zA-Z0-9_\-]+/, format => 0)
    ->via('get')->to('main#get_resolve');

}

1;
