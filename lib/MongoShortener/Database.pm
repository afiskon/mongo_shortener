package MongoShortener::Database;

use strict;
use warnings;
use MongoDB;

my $db;

sub getHandle {
  unless( defined $db ) {
    $db = MongoDB::Connection->new(
      host => 'mongodb://localhost:27017',
    )->get_database('MongoShortener');

    $db->urls->ensure_index({ code => 1 }, { unique => 1});
  }

  return $db;
}

1;
