use strict;
use warnings;
use Test::More;
use Math::FixedPoint;

my ( $num, $decimal_places ) = Math::FixedPoint->_parse_num('1.23');
is $num,            '123', 'Simple Positive Float - Num';
is $decimal_places, 2,     'Simple Positive Float - Decimal Places';

( $num, $decimal_places ) = Math::FixedPoint->_parse_num('123');
is $num,            '123', 'Simple Positive Integer - Num';
is $decimal_places, 0,     'Simple Positive Integer - Decimal Places';

( $num, $decimal_places ) = Math::FixedPoint->_parse_num('.23');
is $num,            '23', 'No Trailing Zero Positive Float - Num';
is $decimal_places, 2,    'No Trailing Zero Positive  Float - Decimal Places';

( $num, $decimal_places ) = Math::FixedPoint->_parse_num('9.23e1');
is $num,            '923', 'Scientific Positive Float > 1 - Num';
is $decimal_places, 1,     'Scientific Positive Float > 1 - Decimal Places';

( $num, $decimal_places ) = Math::FixedPoint->_parse_num('9.23e-1');
is $num,            '923', 'Scientific Positive Float < 1 - Num';
is $decimal_places, 3,     'Scientific Positive Float < 1 - Decimal Places';

( $num, $decimal_places ) = Math::FixedPoint->_parse_num('-123e-2');
is $num,            '-123', 'Scientific Negative Float > 1 - Num';
is $decimal_places, 2,      'Scientific Negative Float > 1 - Decimal Places';

( $num, $decimal_places ) = Math::FixedPoint->_parse_num('0.00');
is $num,            '00', 'Zero - Num';
is $decimal_places, 2,    'Zero - Decimal Places';

done_testing();
