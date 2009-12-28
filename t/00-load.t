#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Net::eNom' );
}

diag( "Testing Net::eNom $Net::eNom::VERSION, Perl $], $^X" );
