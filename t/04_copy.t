use strict;
use warnings;
use Test::More;
use Math::FixedPoint;

my $num  = Math::FixedPoint->new('1.23');
my $num2 = $num;
$num += 1;

is $num->value,           223, 'First instance - Value';
is $num->decimal_places,  2,   'First instance - Decimal Places';
is $num2->value,          123, 'Second instance - Value';
is $num2->decimal_places, 2,   'Second instance - Decimal Places';

done_testing();
