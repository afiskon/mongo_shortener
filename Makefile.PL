use strict;
use warnings;
use ExtUtils::MakeMaker;

die "Please, ignore $0 - this file is not for you. Use INSETALLDEPS.sh.\n"
  unless defined $ENV{CPANM_INSTALLDEPS_IS_RUNNING};


 WriteMakefile(
     NAME             => 'MongoShortener',
     VERSION          => 0.01,
     MIN_PERL_VERSION => 5.010,
     PREREQ_PM        => {
	'Starman' => '0.3003',
	'Mojolicious' => '3.44',
        'MongoDB' => '0.46.3',
        'Regexp::Common' => '2011121001',
        'MIME::Base64' => '3.13',
        'Try::Tiny' => '0.11',
	'Test::More' => '0.98',
        'Test::MockObject' => '1.20120301',
     },
     PREREQ_PRINT => 1,
     dist         => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
     clean => { FILES => 'App-*' },
     test  => { TESTS => 't/*.t' },
);

