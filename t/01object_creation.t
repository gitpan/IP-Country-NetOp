# *-*-perl-*-*
use Test;
BEGIN { plan tests => 1 }
use strict;
$^W = 1;
use IP::Country::NetOp;

ok(IP::Country::NetOp->new());
