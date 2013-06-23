use strict;
use warnings;
use Test::More tests => 4;
use Math::FixedPoint;

my ( $num, $decimal_places ) = Math::FixedPoint->_parse_num(1.23);
is $num,            123;
is $decimal_places, 2;

( $num, $decimal_places ) = Math::FixedPoint->_parse_num(123);
is $num,            123;
is $decimal_places, 0;
