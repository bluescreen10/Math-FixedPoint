use strict;
use warnings;
use Test::More;
use Math::FixedPoint;

my $num1 = Math::FixedPoint->new('1.23');
my $num2 = Math::FixedPoint->new('2.44');

my $result = $num1 + $num2;
is $result->{value},          367, 'Fixed Point Addition - Num';
is $result->{decimal_places}, 2,   'Fixed Point Addition - Decimal Places';

$result = $num1 + 2;
is $result->{value},          323, 'Integer addition - Num';
is $result->{decimal_places}, 2,   'Integer addition - Decimal Places';

$result = $num1 + 1.2355;
is $result->{value},          247, 'Float addition - Num';
is $result->{decimal_places}, 2,   'Float addition - Decimal Places';

$result = $num1 + 1.2;
is $result->{value},          243, 'Float addition - Num';
is $result->{decimal_places}, 2,   'Float addition - Decimal Places';

done_testing();
