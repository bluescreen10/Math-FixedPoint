use strict;
use warnings;
use Test::More tests => 2;
use Math::FixedPoint;

my $num = Math::FixedPoint->new(1.23);
is $num->{value}, 123;
is $num->{decimal_places}, 2;
