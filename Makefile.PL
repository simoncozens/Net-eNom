use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Net::eNom',
    AUTHOR              => q{Simon Cozens <simon@simon-cozens.org>},
    VERSION_FROM        => 'lib/Net/eNom.pm',
    ABSTRACT_FROM       => 'lib/Net/eNom.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'URI' => 0,
        'XML::Simple' => 0,
        'LWP::Simple' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Net-eNom-*' },
);
