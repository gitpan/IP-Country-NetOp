package IP::Country::NetOp;
use strict;
use warnings;

use Socket;
use Net::DNS;
use Carp;

use vars qw ( $VERSION );
$VERSION = '1.00';

my $server = 'country.netop.org';
my $resolver   = Net::DNS::Resolver->new;
my $ip_match = qr/^(\d|[01]?\d\d|2[0-4]\d|25[0-5])\.(\d|[01]?\d\d|2[0-4]\d|25[0-5])\.(\d|[01]?\d\d|2[0-4]\d|25[0-5])\.(\d|[01]?\d\d|2[0-4]\d|25[0-5])$/o;

my $singleton = undef;
sub new ()
{
    my $caller = shift;
    unless (defined $singleton){
        my $class = ref($caller) || $caller;
	$singleton = bless {}, $class;
    }
    return $singleton;
}

sub db_time
{
    return 0;
}

sub inet_atocc
{
    my $inet_a = $_[1] || $_[0];
    my $dnsbl_host;
    if ($inet_a =~ $ip_match){
	$dnsbl_host = "$4.$3.$2.$1.$server";
    } else {
	my $inet_n = inet_aton($inet_a) || return undef; # host lookup
	$inet_a = inet_ntoa($inet_n)    || return undef;
	if ($inet_a =~ $ip_match){
	    $dnsbl_host = "$4.$3.$2.$1.$server";
	} else {
	    return undef;
	}
    }
    my $packet = $resolver->query($dnsbl_host,"TXT") || return undef;
    foreach my $rr($packet->answer){
	next unless $rr->type eq 'TXT';
	my $data = $rr->rdata();
	$data =~ s/[^a-zA-Z]//g;
	return $data;
    }
    return undef;
}

sub inet_ntocc
{
    my $inet_n = $_[1] || $_[0];
    my $inet_a = inet_ntoa($inet_n) || return undef;
    return inet_atocc($inet_a);
}

1;
__END__
=head1 NAME

IP::Country::NetOp - NetOp IP geolocation via DNS

=head1 SYNOPSIS

  use IP::Country::NetOp;
  my $reg = IP::Country::NetOp->new();
  print $reg->inet_atocc('212.67.197.128')   ."\n";
  print $reg->inet_atocc('www.slashdot.org') ."\n";

=head1 DESCRIPTION

Finding the home country of a client using only the IP address can be difficult.
Looking up the domain name associated with that address can provide some help,
but many IP address are not reverse mapped to any useful domain, and the
most common domain (.com) offers no help when looking for country.

This module queries a netop.org server to find the correct country code.

=head1 CONSTRUCTOR

The constructor takes no arguments.

  use IP::Country::NetOp;
  my $reg = IP::Country::NetOp->new();

=head1 OBJECT METHODS

All object methods are designed to be used in an object-oriented fashion.

  $result = $object->foo_method($bar,$baz);

Using the module in a procedural fashion (without the arrow syntax) won't work.

=over 4

=item $cc = $reg-E<gt>inet_atocc(HOSTNAME)

Takes a string giving the name of a host, and translates that to an
two-letter country code. Takes arguments of both the 'rtfm.mit.edu' 
type and '18.181.0.24'. If the host name cannot be resolved, returns undef. 
If the resolved IP address is not contained within the database, returns undef.
For multi-homed hosts (hosts with more than one address), the first 
address found is returned.

=item $cc = $reg-E<gt>inet_ntocc(IP_ADDRESS)

Takes a string (an opaque string as returned by Socket::inet_aton()) 
and translates it into a two-letter country code. If the IP address is 
not contained within the database, returns undef.

=back

=head1 BUGS/LIMITATIONS

Only works with IPv4 addresses and ASCII hostnames.

=head1 SEE ALSO

L<http://www.netop.org/geoip.html> - NetOp: IP geolocation via DNS

L<IP::Country::Fast> - uses local database for lookups.

=head1 COPYRIGHT

Copyright (C) 2006, Nigel Wetters Gourlay.

NO WARRANTY. This module is free software; you can redistribute 
it and/or modify it under the same terms as Perl itself.

=cut
