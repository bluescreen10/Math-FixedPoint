use strict;
use warnings;
use Test::More tests => 8;
use Math::FixedPoint;

my ( $num, $decimal_places ) = Math::FixedPoint->_parse_num(1.23);
is $num,            '123', 'Simple Positive Float - Num';
is $decimal_places, 2,     'Simple Positive Float - Decimal Places';

( $num, $decimal_places ) = Math::FixedPoint->_parse_num(123);
is $num,            '123', 'Simple Positive Integer - Num';
is $decimal_places, 0,     'Simple Positive Integer - Decimal Places';

( $num, $decimal_places ) = Math::FixedPoint->_parse_num(.23);
is $num,            '023', 'No Trailing Zero Positive Float - Num';
is $decimal_places, 2,     'No Trailing Zero Positive  Float - Decimal Places';

( $num, $decimal_places ) = Math::FixedPoint->_parse_num('1.23e1');
is $num,            '123', 'Scientific Positive Float > 1 - Num';
is $decimal_places, 1,     'Scientific Positive Float > 1 - Decimal Places';
