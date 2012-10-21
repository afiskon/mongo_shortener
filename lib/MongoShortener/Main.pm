package MongoShortener::Main;
use Mojo::Base 'Mojolicious::Controller';
use MongoShortener::Database;
use MongoShortener::Const;
use MIME::Base64 qw/encode_base64url decode_base64url/;
use Regexp::Common qw /URI/;
use Try::Tiny;

sub get_main {
  my $self = shift;
  $self->render('main');
}

sub post_main {
  my $self = shift;
  my $url = $self->param('url') || '';
  $url =~ s/(^\s+|\s+$)//g;
  $url = "http://$url" unless $url =~ m!://!;

  unless($self->_is_valid_url($url)) {
    $self->render('main', invalid_url => 1);
    return;
  }

  my ($short_url, $internal_error);
  try {
    $short_url = $self->_create_short_url($url);
  } catch {
    $internal_error = 1;
  };

  $self->render(
      'main',
      short_url => $short_url,
      internal_error => $internal_error,
    );
}

sub get_resolve {
  my ($self) = @_;
  my $short_url = $self->param('short_url');
  my $goto = $self->_resolve_short_url($short_url);
  $self->redirect_to($goto || HOME_URL());
}

sub _create_short_url {
  my ($self, $url) = @_;
  my $db = MongoShortener::Database::getHandle();
  my $code = undef;
  for (1..5) {
    $code = int rand(2**40);
    try {
      $db->urls->insert({ code => $code, url => $url }, { safe => 1 });
    } catch {
      $code = undef;
    };
    last if defined $code;
  }
  die 'CODE_GEN_FAILED' unless defined $code;

  my $short_url = encode_base64url(pack('Q', $code));
  $short_url =~ s/A+$//;

  return HOME_URL().$short_url;
}

sub _resolve_short_url {
  my ($self, $short_url) = @_;
  $short_url .= 'A' x (11 - length $short_url);
  my $code = unpack('Q', decode_base64url($short_url));

  my $db = MongoShortener::Database::getHandle();
  my $doc = $db->urls->find_one({ code => $code });
  return defined $doc ? $doc->{url} : undef;;
}

sub _is_valid_url {
  my ($self, $url) = @_;
  return $url =~ /^$RE{URI}{HTTP}{-scheme=>qr{(ftp|http)s?}}$/ ? 1 : 0;
}

1;
