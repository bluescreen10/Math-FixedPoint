use strict;
use warnings;
use Test::More;
use Math::FixedPoint;

my $num1 = Math::FixedPoint->new('1.23');
my $num2 = Math::FixedPoint->new('2.44');

my $result = $num1 + $num2;
is $result->{value},          367, 'Integer addition - Num';
is $result->{decimal_places}, 2,   'Integer addition - Decimal Places';
