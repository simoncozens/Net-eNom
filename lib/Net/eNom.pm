package Net::eNom;
use Carp qw/croak/;
use warnings;
use strict;
use constant TEST_URI => "http://resellertest.enom.com/interface.asp";
use constant LIVE_URI => "http://reseller.enom.com/interface.asp";
use URI;
use LWP::Simple;
use XML::Simple;
our $AUTOLOAD;

=head1 NAME

Net::eNom - Interact with eNom.com reseller API

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

    use Net::eNom;
    my $enom = Net::eNom->new(
        username => $u,
        password => $p,
        test     => 1
    );
    $enom->AddToCart(
        EndUserIP => "1.2.3.4",
        ProductType => "Register",
        SLD => "myspiffynewdomain",
        TLD => "com"
    );
    ...

=head1 METHODS

=head2 new

Constructs a new object for interacting with the eNom API. If the
"test" parameter is given, then the API calls will be made to the test
server instead of the live one.

=cut

sub new {
    my $class = shift;
    my %args  = @_;
    croak "Username must be provided" unless $args{username};
    croak "Password must be provided" unless $args{password};
    bless \%args, $class;
}

sub _uri {
    my ($self, $command, %args) = @_;
    my $uri = URI->new($self->{test} ? TEST_URI : LIVE_URI);
    if ($command ne "CertGetApproverEmail" and 
        my $domain = delete $args{Domain}) {
        $domain =~ /^(.*)\.(.*)$/;
        $args{TLD} = $2; $args{SLD} = $1;
    }
    $uri->query_form({
            command      => $command,
            uid          => $self->{username},
            pw           => $self->{password},
            responsetype => "xml",
            %args
    });
    return $uri;
}

# API version 3.3
#
our @commands = qw/ AddBulkDomains AddContact AddDomainFolder AddToCart
    AdvancedDomainSearch AssignToDomainFolder AuthorizeTLD CertConfigureCert
    CertGetApproverEmail CertGetCertDetail CertGetCerts CertModifyOrder
    CertParseCSR CertPurchaseCert Check CheckLogin CheckNSStatus
    CommissionAccount Contacts CreateAccount CreateSubAccount
    DeleteAllPOPPaks DeleteContact DeleteCustomerDefinedData
    DeleteDomainFolder DeleteFromCart DeleteHostedDomain DeleteNameServer
    DeletePOP3 DeletePOPPak DeleteRegistration DeleteSubaccount
    EnableServices Extend Extend_RGP ExtendDomainDNS Forwarding
    GetAccountInfo GetAccountPassword GetAccountValidation GetAddressBook
    GetAgreementPage GetAllAccountInfo GetAllDomains GetBalance
    GetCartContent GetCatchAll GetCerts GetConfirmationSettings GetContacts
    GetCusPreferences GetCustomerDefinedData GetCustomerPaymentInfo GetDNS
    GetDNSStatus GetDomainCount GetDomainExp GetDomainFolderDetail
    GetDomainFolderList GetDomainInfo GetDomainMap GetDomainNameID
    GetDomainPhone GetDomains GetDomainServices GetDomainSLDTLD
    GetDomainSRVHosts GetDomainStatus GetDomainSubServices
    GetDotNameForwarding GetExpiredDomains GetExtAttributes GetExtendInfo
    GetForwarding GetFraudScore GetGlobalChangeStatus
    GetGlobalChangeStatusDetail GetHomeDomainList GetHosts GetIPResolver
    GetMailHosts GetMetaTag GetOrderDetail GetOrderList GetPasswordBit
    GetPOPExpirations GetPOPForwarding GetRegHosts GetRegistrationStatus
    GetRegLock GetRenew GetReport GetResellerInfo GetSPFHosts
    GetServiceContact GetSubAccountDetails GetSubAccountPassword
    GetSubAccounts GetSubaccountsDetailList GetTLDList GetTransHistory
    GetWebHostingAll GetWhoisContact GetWPPSInfo HE_CancelAccount
    HE_ChangePassword HE_CreateAccount HE_GetAccountDetails HE_GetAccounts
    HE_GetPricing HE_UpgradeAccount InsertNewOrder ME_AddChannelReseller
    ModifyNS ModifyNSHosting ModifyPOP3 NameSpinner ParseDomain
    PE_GetCustomerPricing PE_GetDomainPricing PE_GetPOPPrice
    PE_GetProductPrice PE_GetResellerPrice PE_GetRetailPrice
    PE_GetRetailPricing PE_GetRocketPrice PE_GetTLDID PE_SetPricing
    Preconfigure PreRegAddList Purchase PurchaseHosting PurchasePOPBundle
    PurchasePreview PurchaseServices PushDomain RefillAccount
    RegisterNameServer RemoveUnsyncedDomains RenewPOPBundle RenewServices
    RPT_GetReport SendAccountEmail ServiceSelect SetCatchAll
    SetCustomerDefinedData SetDNSHost SetDomainMap SetDomainPhone
    SetDomainSRVHosts SetDomainSubServices SetDotNameForwarding SetHosts
    SetIPResolver SetPakRenew SetPassword SetPOPForwarding SetRegLock
    SetRenew SetResellerServicesPricing SetResellerTLDPricing SetSPFHosts
    SetUpPOP3User StatusDomain SubAccountDomains SynchAuthInfo
    TP_CancelOrder TP_CreateOrder TP_GetDetailsByDomain TP_GetOrder
    TP_GetOrderDetail TP_GetOrderReview TP_GetOrdersByDomain
    TP_GetOrderStatuses TP_GetTLDInfo TP_ResendEmail TP_ResubmitLocked
    TP_SubmitOrder TP_UpdateOrderDetail UpdateAccountInfo
    UpdateAccountPricing UpdateCart UpdateCusPreferences UpdateDomainFolder
    UpdateExpiredDomains UpdateMetaTag UpdateNameServer
    UpdateNotificationAmount UpdatePushList UpdateRenewalSettings
    ValidatePassword WSC_GetAllPackages WSC_GetPricing WSC_Update_Ops/;

=head2 AddBulkDomains (and many others)

    my $response = $enom->AddBulkDomains(
        ProductType => "register",
        ListCount => 1,
        SLD1 => "myspiffynewdomain",
        TLD1 => "com",
        UseCart => 1
    );

Performs the specified command - see the eNom API users guide
(https://www.enom.com/resellers/APICommandCatalog.pdf) for the commands
and their arguments.

For convenience, if you pass the 'Domain' argument, it will be split
into 'SLD' and 'TLD'; that is, you can say

    my $response = $enom->Check(SLD => "myspiffynewdomain", TLD => "com");

or

    my $response = $enom->Check(Domain => "myspiffynewdomain.com");

The return value is a Perl hash representing the response XML from the
eNom API; the only differences are

=over 3

=item *

The "errors" key returns an array instead of a hash

=item *

"responses" returns an array of hashes

=item *

Keys which end with a number are transformed into an array

=back

So for instance, a command C<Check(Domain => "enom.@")> (the "@" means
"com, net, org") might return:

        {
          'Domain' => [ 'enom.com', 'enom.net', 'enom.org' ],
          'Command' => 'CHECK',
          'RRPCode' => [ '211', '211', '211' ],
          'RRPText' => [
                       'Domain not available',
                       'Domain not available',
                       'Domain not available'
                     ]
        };

You will need to read the API guide to check whether to expect responses
in "RRPText" or "responses"; it's not exactly consistent.

=cut

for my $command (@commands) {
    no strict 'refs';
    *$command = sub {
        my $self = shift;
        my $uri  = $self->_uri($command, @_);

        my $data = get($uri);

        #warn $data;
        my $response = XMLin($data, SuppressEmpty => undef);
        $response->{errors} &&= [ values %{$response->{errors}} ];
        $response->{responses} &&= $response->{responses}{response};
        $response->{responses} = [ $response->{responses} ]
            if $response->{ResponseCount} == 1;
        for (keys %$response) {
            next unless /(.*?)(\d+)$/;
            $response->{$1}[$2 - 1] = delete $response->{$_};
        }
        $response;
    }
}

=head1 AUTHOR

Simon Cozens, C<< <simon at simon-cozens.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-net-enom at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-eNom>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Net::eNom


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Net-eNom>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Net-eNom>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Net-eNom>

=item * Search CPAN

L<http://search.cpan.org/dist/Net-eNom/>

=back


=head1 ACKNOWLEDGEMENTS

Thanks to the UK Free Software Network (http://www.ukfsn.org/) for their
support of this module's development. For free-software-friendly hosting
and other Internet services, try UKFSN.

=head1 COPYRIGHT & LICENSE

Copyright 2009 Simon Cozens.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;    # End of Net::eNom
