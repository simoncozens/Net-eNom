#!perl
use Test::More tests => 1;
use Net::eNom;
my $test = Net::eNom->new(
    username => "resellid",
    password => "resellpw",
    test => 1,
);

my $response = $test->CertGetApproverEmail(Domain => "cpan.org");
is($response->{CertGetApproverEMail}{Approver}[0]{ApproverEmail},
    'elaine@chaos.wustl.edu', "Found CPAN domain admin");
