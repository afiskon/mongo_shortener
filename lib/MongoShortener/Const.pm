package MongoShortener::Const;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT = qw/HOME_URL/;

sub HOME_URL { $ENV{'MONGO_SHORTENER_HOME_URL'} || 'http://localhost:3000/' }

1;
