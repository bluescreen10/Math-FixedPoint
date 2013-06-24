use strict;
use warnings;
use Test::More;
use Math::FixedPoint;

my $num1 = Math::FixedPoint->new('1.23');
my $num2 = Math::FixedPoint->new('2.44');

$num1 += $num2;
is $num1->value,          367, 'Fixed Point Addition - Num';
is $num1->decimal_places, 2,   'Fixed Point Addition - Decimal Places';

$num1 = Math::FixedPoint->new('1.23');
$num1 += 1.23;
is $num1->value,          246, 'Fixed Point Addition - Num';
is $num1->decimal_places, 2,   'Fixed Point Addition - Decimal Places';

done_testing();
