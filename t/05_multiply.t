use strict;
use warnings;
use Test::More;
use Math::FixedPoint;

{
    my $num1 = '1.23';
    my $num2 = '3.1245';

    my $instance = Math::FixedPoint->new($num1);
    my $result   = $instance * $num2;

    is $result->[0], 1,   "$num1 * $num2 - sign";
    is $result->[1], 384, "$num1 * $num2 - value";
    is $result->[2], 2,   "$num1 * $num2 - radix";
}

{
    my $num1 = '-3.1245';
    my $num2 = '1.26';

    my $instance1 = Math::FixedPoint->new($num1);
    my $instance2 = Math::FixedPoint->new($num2);
    my $result    = $instance1 * $instance2;

    is $result->[0], -1,    "$num1 * $num2 - sign";
    is $result->[1], 39369, "$num1 * $num2 - value";
    is $result->[2], 4,     "$num1 * $num2 - radix";
}

done_testing();
