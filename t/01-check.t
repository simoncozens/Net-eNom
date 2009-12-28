#!perl
use Test::More tests => 1;
use Net::eNom;
my $test = Net::eNom->new(
    username => "resellid",
    password => "resellpw",
    test => 1,
);

my $response = $test->Check(Domain => "enom.\@");
is_deeply($response->{Domain}, [qw/ enom.com enom.net enom.org /], 
    "Domain check returned sensible repsonse");

